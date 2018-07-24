select close_yyyyqq,
  owner_role_vp_team,
  owner_role_dir_team,
  case when total_support_mrr < 1000 then "~ 1K"
       when total_support_mrr < 5000 then "1K ~ 5K"
       when total_support_mrr < 10000 then "5K ~ 10K"
       when total_support_mrr < 25000 then "10K ~"
       else "25K ~" end as support_band,
  case when support_plan in ("Enterprise Legacy","Enterprise (non-Elite)","Enterprise","Enterprise Elite","Elite Bundle") then "Enterprise"
       when support_plan in ("Plus","Professional") then "Professional"
       when support_plan in ("Regular","Team") then "Team"
       when support_plan in ("Inbox","Starter","Essential") then "Essential"
       when support_plan in ("Add-on Only") then "Add-on only"
       else "Plan missing" end as support_plan,
  case when lead_source_derived = "Expansion" then "Expansion"
       when lead_source_derived = "Outbound" then "Outbound"
       when lead_source_derived in ( "Support Trial","Contact Us","Demo Request","Field","Chat Trial","Gated Resource","Non-Trial Other","Webinar Request","Social","BIME Trial" ) then "Inbound"
       else "Other" end as subtype,
  case when support_software_discount is null then "0"
       when support_software_discount <= 0 then "0"
       when support_software_discount < 20 then "~ 20"
       when support_software_discount < 40 then "20 ~ 40"
       when support_software_discount < 60 then "40 ~ 60"
       when support_software_discount < 80 then "60 ~ 80"
       else "80 ~" end as discount_band,
  sum(case when coalesce(total_support_mrr,0) != 0 then 1 else 0 end) as total_support_count,
  sum(coalesce(total_support_mrr,0)) as total_support_mrr,
  sum(coalesce(total_support_plan_mrr,0)) as total_support_plan_mrr,
  sum(coalesce(total_support_addon_mrr,0)) as total_support_addon_mrr,
  sum(coalesce(support_plan_mrr,0)) as support_plan_mrr,
  sum(coalesce(support_plan_adjustments,0)) as support_plan_adjustments,
  sum(coalesce(support_addon_mrr,0)) as support_addon_mrr,
  sum(coalesce(support_addon_adjustments,0)) as support_addon_adjustments,
  sum(coalesce(support_discount_amount,0)) as support_discount,
  string_agg( case when support_software_discount >= 40 then substr(id,1,15) end ) as opportunity_ids
from gtm_operations_general.opportunities
where type in ("New Business","Expansion") and close_date >= "2015-01-01" and total_support_mrr != 0 and probability = 100
group by close_yyyyqq, owner_role_vp_team, owner_role_dir_team, support_band, support_plan, subtype, discount_band
order by 1 desc, 2, 3, 4, 5, 6, 7, 8;

-- support plan audit

select support_plan,
  case when support_plan in ("Enterprise Legacy","Enterprise (non-Elite)","Enterprise","Enterprise Elite","Elite Bundle") then "Enterprise"
       when support_plan in ("Plus","Professional") then "Professional"
       when support_plan in ("Regular","Team") then "Team"
       when support_plan in ("Inbox","Starter","Essential") then "Essential"
       when support_plan in ("Add-on Only") then "Add-on only"
       else "Plan missing" end as support_plan_grouped,
  count(*)
from gtm_operations_general.opportunities
where type in ("New Business","Expansion") and close_date >= "2015-01-01" and total_support_mrr != 0
group by support_plan, support_plan_grouped
order by 2, 1;


select support_plan,
  case when support_plan in ("Enterprise Legacy","Enterprise (non-Elite)","Enterprise","Enterprise Elite","Elite Bundle") then "Enterprise"
       when support_plan in ("Plus","Professional") then "Professional"
       when support_plan in ("Regular","Team") then "Team"
       when support_plan in ("Inbox","Starter","Essential") then "Essential"
       when support_plan in ("Add-on Only") then "Add-on only"
       else "Plan missing" end as support_plan_grouped,
  count(*)
from gtm_operations_general.opportunities
where type in ("New Business","Expansion")
  and close_date >= "2015-01-01"
  and total_support_mrr != 0
  and support_plan is not NULL
  and of_agents = 0
group by support_plan, support_plan_grouped
order by 2, 1;