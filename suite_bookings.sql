select concat("\'",close_yyyymm) as close_date,
  case when coalesce(replace(replace(omnichannel_bundle,"True","Y"),"False","N"),"N") = "Y" then concat("\'",created_yyyymm) end as create_date,
  owner_role_vp_team as owner_region,
  rtrim( concat( case when concat(coalesce(account_products_at_close_date,""),products) like "%Support%" then "Support/" else "" end,
                 case when concat(coalesce(account_products_at_close_date,""),products) like "%Chat%" then "Chat/" else "" end,
                 case when concat(coalesce(account_products_at_close_date,""),products) like "%Talk%" then "Talk/" else "" end,
                 case when concat(coalesce(account_products_at_close_date,""),products) like "%Guide%" then "Guide" else "" end ), "/") as products,
  concat( "\'", cast( case when concat(coalesce(account_products_at_close_date,""),products) like "%Support%" then 1 else 0 end +
                     case when concat(coalesce(account_products_at_close_date,""),products) like "%Chat%" then 1 else 0 end +
                     case when concat(coalesce(account_products_at_close_date,""),products) like "%Talk%" then 1 else 0 end +
                     case when concat(coalesce(account_products_at_close_date,""),products) like "%Guide%" then 1 else 0 end as string ) ) as count,
  case when has_suite = "True" or ( omnichannel_bundle = "True" and close_date >= "2018-05-17" ) then "Y" else "N" end as omn_c,
  case when has_suite = "True" then "Y" else "N" end as suite,
  replace(replace(type,"New Business","New"),"Expansion","Expand") as type,
  status,
  sum( 1 ) as num_total,
  sum( case when stage_name in ( "02 - Discovery","03 - Solution Review","04 - Solution Validation","05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying" ) then 1 end ) as num_total_2,
  sum( case when stage_name in ( "03 - Solution Review","04 - Solution Validation","05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery" ) then 1 end ) as num_total_3,
  sum( case when stage_name in ( "04 - Solution Validation","05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery","03 - Solution Review" ) then 1 end ) as num_total_4,
  sum( case when stage_name in ( "05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery","03 - Solution Review","04 - Solution Validation" ) then 1 end ) as num_total_5,
  sum( case when stage_name in ( "06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery","03 - Solution Review","04 - Solution Validation","05 - Contracting / Verbal" ) then 1 end ) as num_total_6,
  sum( total_booking_mrr ) as mrr_total,
  sum( case when stage_name in ( "02 - Discovery","03 - Solution Review","04 - Solution Validation","05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying" ) then total_booking_mrr end ) as mrr_total_2,
  sum( case when stage_name in ( "03 - Solution Review","04 - Solution Validation","05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery" ) then total_booking_mrr end ) as mrr_total_3,
  sum( case when stage_name in ( "04 - Solution Validation","05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery","03 - Solution Review" ) then total_booking_mrr end ) as mrr_total_4,
  sum( case when stage_name in ( "05 - Contracting / Verbal","06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery","03 - Solution Review","04 - Solution Validation" ) then total_booking_mrr end ) as mrr_total_5,
  sum( case when stage_name in ( "06 - Signed","Failed Finance Audit","Pending Sales Review","07 - Closed" ) or stage_name_lost not in ( "01 - Qualifying","02 - Discovery","03 - Solution Review","04 - Solution Validation","05 - Contracting / Verbal" ) then total_booking_mrr end ) as mrr_total_6,
  sum( total_support_mrr ) as mrr_support,
  sum( total_chat_mrr ) as mrr_chat,
  sum( total_talk_mrr ) as mrr_talk,
  sum( total_guide_mrr ) as mrr_guide,
  sum( total_booking_mrr - coalesce(total_support_mrr,0) - coalesce(total_chat_mrr,0) - coalesce(total_talk_mrr,0) - coalesce(total_guide_mrr,0) ) as mrr_other,
  string_agg( case when has_suite = "True" or ( omnichannel_bundle = "True" and close_date >= "2018-05-17" ) then substr(id,1,15) end ) as omn_c_ids
from gtm_operations_general.opportunities
where date(close_date) >= date_add(date_trunc(current_date,month), interval -14 month) and total_booking_mrr != 0
group by 1, 2, 3, 4, 5, 6, 7, 8, 9
order by 1 desc, 2 desc, 3, 4, 5, 6, 7, 8, 9;