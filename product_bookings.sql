with t as (
select close_yyyyqq as close_date,
  created_yyyyqq as created_date,
  owner_role_vp_team as owner_vp_team,
  owner_role_dir_team as owner_dir_team,
  "Total" as mrr_type,
  0 as mrr_type_sort,
  replace(type,"New Business","New") as type,
  case when coalesce(account_mrr_prior_qtr,0) > 0 then "Expansion" else "New" end as type_derived,
  status,
  sum( total_booking_mrr ) as booking_mrr,
  sum( 1 ) booking_mrr_count
from gtm_operations_general.opportunities
where close_date >= "2015-01-01" and total_booking_mrr != 0 and owner_role_vp_team = "APAC"
group by 1, 2, 3, 4, 5, 6, 7, 8, 9
union all select close_yyyyqq,
  created_yyyyqq,
  owner_role_vp_team,
  owner_role_dir_team,
  "Support",
  1,
  replace(type,"New Business","New"),
  case when coalesce(account_mrr_prior_qtr_support,0) > 0 then "Expansion" else "New" end,
  status,
  sum( total_support_mrr ),
  sum( 1 )
from gtm_operations_general.opportunities
where close_date >= "2015-01-01" and coalesce(total_support_mrr,0) != 0 and owner_role_vp_team = "APAC"
group by 1, 2, 3, 4, 5, 6, 7, 8, 9
union all select close_yyyyqq,
  created_yyyyqq,
  owner_role_vp_team,
  owner_role_dir_team,
  "Chat",
  2,
  replace(type,"New Business","New"),
  case when coalesce(account_mrr_prior_qtr_chat,0) > 0 then "Expansion" else "New" end,
  status,
  sum( total_chat_mrr ),
  sum( 1 )
from gtm_operations_general.opportunities
where close_date >= "2015-01-01" and coalesce(total_chat_mrr,0) != 0 and owner_role_vp_team = "APAC"
group by 1, 2, 3, 4, 5, 6, 7, 8, 9
union all select close_yyyyqq,
  created_yyyyqq,
  owner_role_vp_team,
  owner_role_dir_team,
  "Talk",
  3,
  replace(type,"New Business","New"),
  case when coalesce(account_mrr_prior_qtr_talk,0) > 0 then "Expansion" else "New" end,
  status,
  sum( total_talk_mrr ),
  sum( 1 )
from gtm_operations_general.opportunities
where close_date >= "2015-01-01" and coalesce(total_talk_mrr,0) != 0 and owner_role_vp_team = "APAC"
group by 1, 2, 3, 4, 5, 6, 7, 8, 9
union all select close_yyyyqq,
  created_yyyyqq,
  owner_role_vp_team,
  owner_role_dir_team,
  "Guide",
  4,
  replace(type,"New Business","New"),
  case when coalesce(account_mrr_prior_qtr_guide,0) > 0 then "Expansion" else "New" end,
  status,
  sum( total_guide_mrr ),
  sum( 1 )
from gtm_operations_general.opportunities
where close_date >= "2015-01-01" and coalesce(total_guide_mrr,0) != 0 and owner_role_vp_team = "APAC"
group by 1, 2, 3, 4, 5, 6, 7, 8, 9 )
select close_date,
  created_date,
  owner_vp_team,
  owner_dir_team,
  mrr_type,
  type,
  type_derived,
  status,
  booking_mrr,
  booking_mrr_count
from t
order by 1 desc, 2 desc, 3, 4, mrr_type_sort, 6, 7, 8;


-- cmrr

select concat(cast(extract(year from o.closedate) as string),"Q",cast(extract(quarter from o.closedate) as string)) as close_date,
  o.non_commissionable__c as non_comm,
  sum( o.booking_mrr__c/coalesce(fx.conversionrate,1) ) as totl_mrr,
  sum( o.total_commissionable_mrr__c/coalesce(fx.conversionrate,1) ) as comm_mrr,
  sum( o.total_support_mrr__c/coalesce(fx.conversionrate,1) ) as supp_mrr,
  sum( o.total_chat_mrr__c/coalesce(fx.conversionrate,1) ) as chat_mrr,
  sum( o.total_guide_mrr__c/coalesce(fx.conversionrate,1) ) as guid_mrr,
  sum( o.total_talk_mrr__c/coalesce(fx.conversionrate,1) ) as talk_mrr,
  sum( case when o.total_support_mrr__c > 0 then o.total_support_mrr__c/coalesce(fx.conversionrate,1) end ) as supp_mrr_pos,
  sum( case when o.total_chat_mrr__c > 0 then o.total_chat_mrr__c/coalesce(fx.conversionrate,1) end ) as chat_mrr_pos,
  sum( case when o.total_guide_mrr__c > 0 then o.total_guide_mrr__c/coalesce(fx.conversionrate,1) end ) as guid_mrr_pos,
  sum( case when o.total_talk_mrr__c > 0 then o.total_talk_mrr__c/coalesce(fx.conversionrate,1) end ) as talk_mrr_pos,
  sum( case when o.seasonal_term__c = "True" then o.booking_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.booking_mrr__c/coalesce(fx.conversionrate,1) end ) as totl_adj,
  sum( case when o.seasonal_term__c = "True" then o.total_support_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_support_mrr__c/coalesce(fx.conversionrate,1) end ) as supp_adj,
  sum( case when o.seasonal_term__c = "True" then o.total_chat_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_chat_mrr__c/coalesce(fx.conversionrate,1) end ) as chat_adj,
  sum( case when o.seasonal_term__c = "True" then o.total_guide_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_guide_mrr__c/coalesce(fx.conversionrate,1) end ) as guid_adj,
  sum( case when o.seasonal_term__c = "True" then o.total_talk_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_talk_mrr__c/coalesce(fx.conversionrate,1) end ) as talk_adj,
  sum( case when o.total_support_mrr__c > 0 then case when o.seasonal_term__c = "True" then o.total_support_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_support_mrr__c/coalesce(fx.conversionrate,1) end end ) as supp_adj_pos,
  sum( case when o.total_chat_mrr__c > 0 then case when o.seasonal_term__c = "True" then o.total_chat_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_chat_mrr__c/coalesce(fx.conversionrate,1) end end ) as chat_adj_pos,
  sum( case when o.total_guide_mrr__c > 0 then case when o.seasonal_term__c = "True" then o.total_guide_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_guide_mrr__c/coalesce(fx.conversionrate,1) end end ) as guid_adj_pos,
  sum( case when o.total_talk_mrr__c > 0 then case when o.seasonal_term__c = "True" then o.total_talk_mrr__c/12*o.contract_months__c/coalesce(fx.conversionrate,1) else o.total_talk_mrr__c/coalesce(fx.conversionrate,1) end end ) as talk_adj_pos,
  string_agg( case when o.non_commissionable__c = "True" and total_chat_mrr__c > 0 then substr(o.id,1,15) end ) as chat_ids,
  string_agg( case when o.non_commissionable__c = "True" and total_talk_mrr__c > 0 then substr(o.id,1,15) end ) as talk_ids
from sfdc.opp_scd2 o join sfdc.account_scd2 a on a.id = o.accountid and a.test_account__c = "False" and a.dw_curr_ind = "Y"
left join sfdc.datedconvrate_scd2 fx on fx.isocode = o.currencyisocode and fx.startdate <= o.closedate and fx.nextstartdate > o.closedate and fx.dw_curr_ind = "Y"
where o.type in ("Expansion","New Business") and o.stagename = "07 - Closed"  and o.closedate >= "2015-01-01" and o.dw_curr_ind = "Y"
group by 1, 2
order by 1 desc, 2;

select DISTINCT seasonal_term__c
from sfdc.opp_scd2 where dw_curr_ind = "Y"