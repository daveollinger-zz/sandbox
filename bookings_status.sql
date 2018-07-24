select p.yyyyqq, p.region, p.type, p.band, p.woq, o.signed, o.support, o.chat, o.talk, o.guide, o.connect, o.bime, i.created, p.signed_, p.pipeline_, p.value_, p.closed_,
       o.signed_00,o.signed_01,o.signed_02,o.signed_03,o.signed_04,o.signed_05,o.signed_06,o.signed_07,o.signed_08,o.signed_09,o.signed_10,o.signed_11,o.signed_12,o.signed_13,o.signed_otd
from ( select x.yyyyqq, x.region, x.type, x.band, x.woq, sum(x.signed_) as signed_, sum(x.pipeline_) as pipeline_, sum(x.closed_) as closed_, sum(x.pipeline_*y.probability) as value_
       from ( select as_of_yyyyqq as yyyyqq,
                owner_role_vp_team as region,
                case when type = "Expansion" then "Expand" else "New" end as type,
                case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
                as_of_type as woq,
                stage_name_as_of as stage,
                sum(case when close_quarter_as_of = 0 and status_as_of in ("Closed","Signed") then amount_as_of end ) as signed_,
                sum(case when close_quarter_as_of = 0 and status_as_of = "Open" then amount_as_of end ) as pipeline_,
                sum(case when close_quarter_as_of = 0 and status_as_of = "Open" and close_quarter = 0 and status in ("Closed","Signed") then amount_as_of end ) as closed_
              from gtm_operations_general.pipeline where date_set = "weeks"
              group by yyyyqq, region, type, band, woq, stage ) x
       left join ( select owner_role_vp_team as region,
                     case when type = "Expansion" then "Expand" else "New" end as type,
                     case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
                     as_of_type as woq,
                     stage_name_as_of as stage,
                     sum( case when close_quarter = close_quarter_as_of and stage_name = "07 - Closed" then amount_as_of end ) / nullif(sum( amount_as_of ),0) as probability
                   from gtm_operations_general.pipeline
                   where date_set = "weeks" and close_quarter_as_of = 0 and status_as_of = "Open" and date(as_of_date) < date_trunc(current_date,quarter)
                   group by region, type, band, woq, stage ) y on y.region = x.region and y.type = x.type and y.band = x.band and y.woq = x.woq and y.stage = x.stage
       group by x.yyyyqq, x.region, x.type, x.band, x.woq ) p
left join ( select close_yyyyqq as yyyyqq,
              owner_role_vp_team as region,
              case when type = "Expansion" then "Expand" else "New" end as type,
              case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
              case when ceil(close_doq/7) = 14 then 13 else ceil(close_doq/7) end as woq,
              sum(case when status in ("Closed","Signed") then total_booking_mrr end ) as signed,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 0 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_00,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 1 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_01,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 2 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_02,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 3 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_03,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 4 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_04,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 5 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_05,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 6 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_06,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 7 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_07,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 8 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_08,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 9 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_09,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 10 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_10,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 11 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_11,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 12 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_12,
              sum(case when status in ("Closed","Signed") and created_woq_in_quarter = 13 and account_name != "Expiring One Time Discounts" then total_booking_mrr end ) as signed_13,
              sum(case when status in ("Closed","Signed") and account_name = "Expiring One Time Discounts" then total_booking_mrr end ) as signed_otd,
              sum(case when status in ("Closed","Signed") then total_support_mrr end ) as support,
              sum(case when status in ("Closed","Signed") then total_chat_mrr end ) as chat,
              sum(case when status in ("Closed","Signed") then total_talk_mrr end ) as talk,
              sum(case when status in ("Closed","Signed") then total_guide_mrr end ) as guide,
              sum(case when status in ("Closed","Signed") then total_connect_mrr end ) as connect,
              sum(case when status in ("Closed","Signed") then total_bime_mrr end ) as bime
            from gtm_operations_general.opportunities
            group by yyyyqq, region, type, band, woq ) o on o.yyyyqq = p.yyyyqq and o.region = p.region and o.type = p.type and o.band = p.band and cast(o.woq as string) = p.woq
left join ( select created_yyyyqq as yyyyqq,
              owner_role_vp_team as region,
              case when type = "Expansion" then "Expand" else "New" end as type,
              case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
              case when ceil(created_doq/7) = 14 then 13 else ceil(created_doq/7) end as woq,
              sum( case when close_yyyyqq = created_yyyyqq and stage_name = "07 - Closed" then total_booking_mrr end ) as created
            from gtm_operations_general.opportunities
            group by yyyyqq, region, type, band, woq ) i on i.yyyyqq = p.yyyyqq and i.region = p.region and i.type = p.type and i.band = p.band and cast(i.woq as string) = p.woq
order by p.yyyyqq desc, p.region, p.type, p.band, cast(p.woq as int64) desc;


-- amer

select p.yyyyqq, p.region, p.type, p.band, p.woq, o.signed, o.support, o.chat, o.talk, o.guide, o.connect, o.bime, i.created, p.signed_, p.pipeline_, p.value_, p.closed_
from ( select x.yyyyqq, x.region, x.type, x.band, x.woq, sum(x.signed_) as signed_, sum(x.pipeline_) as pipeline_, sum(x.closed_) as closed_, sum(x.pipeline_*y.probability) as value_
       from ( select as_of_yyyyqq as yyyyqq,
                owner_role_dir_team as region,
                case when type = "Expansion" then "Expand" else "New" end as type,
                case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
                as_of_type as woq,
                stage_name_as_of as stage,
                sum(case when close_quarter_as_of = 0 and status_as_of in ("Closed","Signed") then amount_as_of end ) as signed_,
                sum(case when close_quarter_as_of = 0 and status_as_of = "Open" then amount_as_of end ) as pipeline_,
                sum(case when close_quarter_as_of = 0 and status_as_of = "Open" and close_quarter = 0 and status in ("Closed","Signed") then amount_as_of end ) as closed_
              from gtm_operations_general.pipeline where date_set = "weeks" and owner_role_vp_team = "AMER"
              group by yyyyqq, region, type, band, woq, stage ) x
       left join ( select owner_role_dir_team as region,
                     case when type = "Expansion" then "Expand" else "New" end as type,
                     case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
                     as_of_type as woq,
                     stage_name_as_of as stage,
                     sum( case when close_quarter = close_quarter_as_of and stage_name = "07 - Closed" then amount_as_of end ) / nullif(sum( amount_as_of ),0) as probability
                   from gtm_operations_general.pipeline
                   where date_set = "weeks" and close_quarter_as_of = 0 and status_as_of = "Open" and date(as_of_date) < date_trunc(current_date,quarter) and owner_role_vp_team = "AMER"
                   group by region, type, band, woq, stage ) y on y.region = x.region and y.type = x.type and y.band = x.band and y.woq = x.woq and y.stage = x.stage
       group by x.yyyyqq, x.region, x.type, x.band, x.woq ) p
left join ( select close_yyyyqq as yyyyqq,
              owner_role_dir_team as region,
              case when type = "Expansion" then "Expand" else "New" end as type,
              case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
              case when ceil(close_doq/7) = 14 then 13 else ceil(close_doq/7) end as woq,
              sum(case when status in ("Closed","Signed") then total_booking_mrr end ) as signed,
              sum(case when status in ("Closed","Signed") then total_support_mrr end ) as support,
              sum(case when status in ("Closed","Signed") then total_chat_mrr end ) as chat,
              sum(case when status in ("Closed","Signed") then total_talk_mrr end ) as talk,
              sum(case when status in ("Closed","Signed") then total_guide_mrr end ) as guide,
              sum(case when status in ("Closed","Signed") then total_connect_mrr end ) as connect,
              sum(case when status in ("Closed","Signed") then total_bime_mrr end ) as bime
            from gtm_operations_general.opportunities where owner_role_vp_team = "AMER"
            group by yyyyqq, region, type, band, woq ) o on o.yyyyqq = p.yyyyqq and o.region = p.region and o.type = p.type and o.band = p.band and cast(o.woq as string) = p.woq
left join ( select created_yyyyqq as yyyyqq,
              owner_role_dir_team as region,
              case when type = "Expansion" then "Expand" else "New" end as type,
              case when total_support_mrr <= 0 then "~ 0" when total_support_mrr < 1000 then "0 ~ 1K" when total_support_mrr < 5000 then "1K ~ 5K" else "5K ~" end as band,
              case when ceil(created_doq/7) = 14 then 13 else ceil(created_doq/7) end as woq,
              sum( case when close_yyyyqq = created_yyyyqq and stage_name = "07 - Closed" then total_booking_mrr end ) as created
            from gtm_operations_general.opportunities where owner_role_vp_team = "AMER"
            group by yyyyqq, region, type, band, woq ) i on i.yyyyqq = p.yyyyqq and i.region = p.region and i.type = p.type and i.band = p.band and cast(i.woq as string) = p.woq
order by p.yyyyqq desc, p.region, p.type, p.band, cast(p.woq as int64) desc;


-- deal band x employees

select close_yyyyqq,
  owner_role_vp_team,
  replace(replace(replace(segment,"Under 100","(1) Under 100"),"100 - 999","(2) 100 - 999"),"1000+","(3) 1000+") as segment,
  case when total_booking_mrr <= 0 then "~ 0" when total_booking_mrr < 1000 then "0 ~ 1K" when total_booking_mrr < 5000 then "1K ~ 5K" else "5K ~" end as deal_band,
  sum(total_booking_mrr) total_booking_mrr
from gtm_operations_general.opportunities
where status = "Closed" and close_date between "2017-01-01" and "2018-07-01" and type = "New Business"
group by 1, 2, 3, 4
order by 1 desc, 2, 3, 4;


-- script scraps

select dw_eff_start,
  role_label__c,
  vp_team__c,
  dir_team__c,
  business_unit__c
from sfdc.user_role_attribute__c
where isactive__c = "True" and dw_curr_ind = "Y"
order by 1;

select distinct owner_role, owner_role_historical from gtm_operations_general.opportunities where owner_role_vp_team = "Unknown" order by 1;

select date_trunc(date(a.createddate),quarter) as created_Date, u.name, count(*)
from sfdc.account_scd2 a
left join sfdc.user_scd2 u on u.id = a.createdbyid and u.dw_curr_ind = "Y"
where a.dw_curr_ind = "Y"
group by 1, 2

select u.name, count(*)
from sfdc.accthist ah
left JOIN sfdc.user_scd2 u on u.id = ah.createdbyid and u.dw_curr_ind = "Y"
where field = "BillingPostalCode" and oldvalue != newvalue
and ah.createddate > "2018-01-01"
group by 1
order by 2 desc;


-- 

select close_yyyyqq,
  sum(case when account_mrr_prior_qtr is not null then total_booking_mrr end) as starting_bob_expansion,
  sum(case when account_mrr_prior_qtr is null then total_booking_mrr end) as new_account_expansion
from gtm_operations_general.opportunities
where status = "Closed" and type = "Expansion" and close_date >= "2017-01-01"
group by close_yyyyqq
order by 1 desc;

( select x.net_mrr_usd_prior_qtr_end from edw_financials.pop_mrr_crm x where x.mrr_date = date_trunc(date(o.closedate),quarter) and x.crm_account_id = o.accountid ) as account_mrr_prior_qtr

select *
from edw_financials.pop_mrr_granular
where crm_account_id = "00180000010PBNQAA4" and mrr_date = "2018-07-02" --and autorenew = "True";

select * from gtm_operations_general.mrr where crm_account_id = "00180000010PBNQAA4" order by mrr_date desc;

select * from gtm_operations_general.customers where account_name like "%Zephyr%";

select * from edw_financials.pop_mrr_crm where crm_account_id = "001800000125RN9AAM" and mrr_date = "2018-07-02";
select * from edw_financials.pop_mrr_product where crm_account_id = "001800000125RN9AAM" and mrr_date = "2018-07-02";
select * from gtm_operations_general.mrr where crm_account_id = "001800000125RN9AAM";
