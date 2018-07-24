select concat(cast(extract(year from f.mrr_date) as string),"Q",cast(extract(quarter from f.mrr_date) as string)) as mrr_date,
  concat(cast(extract(year from f.mrr_date_init) as string),"Q",cast(extract(quarter from f.mrr_date_init) as string)) as mrr_date_init,
  case when date_diff(f.mrr_date,f.mrr_date_init,quarter) > 7 then "\'8"
       when date_diff(f.mrr_date,f.mrr_date_init,quarter) > 3 then case when f.mrr_date_init = "2014-03-31" then "\'-" else "\'4" end
       when date_diff(f.mrr_date,f.mrr_date_init,quarter) > 1 then case when f.mrr_date_init = "2014-03-31" then "\'-" else "\'2" end
       when date_diff(f.mrr_date,f.mrr_date_init,quarter) > 0 then case when f.mrr_date_init = "2014-03-31" then "\'-" else "\'1" end
       else case when f.mrr_date_init = "2014-03-31" then "\'-" else "\'0" end end as age,
  f.crm_account_owner_role_vp_team as owner_vp_team,
  f.crm_account_owner_role_dir_team as owner_dir_team,
--  f.crm_account_employee_range_segment as segment,
--  case when f.net_mrr_usd_usd < 1000 then "~ 1K" when f.net_mrr_usd_usd < 5000 then "1K ~ 5K" else "5K ~" end as segment,
  case when f.net_mrr_usd_qtd_diff_transfer_adj < 25000 then "Under 25K" else "25K+" end as segment,
  f.mrr_type,
  sum( f.net_mrr_usd ) as net_mrr,
  sum( f.net_mrr_usd_prior_qtr_end ) as net_mrr_prior_qtr,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) then case when f.net_mrr_usd > f0.net_mrr_usd then f.net_mrr_usd - f0.net_mrr_usd end end ) as net_mrr_exp,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) then case when f.net_mrr_usd < f0.net_mrr_usd then f.net_mrr_usd - f0.net_mrr_usd end end ) as net_mrr_con,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) then f0.net_mrr_usd end ) as net_mrr_init,
  sum( case when date_trunc(f.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter) then f.net_mrr_usd end ) as net_mrr_new,
  sum( f.net_mrr_usd_qtd_diff_transfer_adj ) as net_mrr_diff,
  sum( f.net_mrr_usd_qtd_diff_fx ) as net_mrr_diff_fx,
  sum( f.net_mrr_usd_transferred ) as net_mrr_diff_xfer,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "New" then f.net_mrr_usd_qtd_diff_transfer_adj end ) as net_mrr_diff_new,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Expansion" then f.net_mrr_usd_qtd_diff_transfer_adj end ) as net_mrr_diff_exp,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Contraction" then f.net_mrr_usd_qtd_diff_transfer_adj end ) as net_mrr_diff_con,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Churn" then f.net_mrr_usd_qtd_diff_transfer_adj end ) as net_mrr_diff_chu,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Return" then f.net_mrr_usd_qtd_diff_transfer_adj end ) as net_mrr_diff_ret,
  sum( f.recurring_discount_usd ) as discount_rec,
  sum( f.nonrecurring_discount_usd ) as discount_nonrec,
  sum( case when f.net_mrr_usd > 0 then 1 end ) as net_mrr_count,
  sum( case when f.net_mrr_usd_prior_qtr_end > 0 then 1 end ) as net_mrr_prior_qtr_count,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) and f.net_mrr_usd > 0 then case when f.net_mrr_usd > f0.net_mrr_usd then 1 end end ) as net_mrr_exp_count,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) and f.net_mrr_usd > 0 then case when f.net_mrr_usd < f0.net_mrr_usd then 1 end end ) as net_mrr_con_count,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) and f.net_mrr_usd > 0 then case when f.net_mrr_usd = f0.net_mrr_usd then 1 end end ) as net_mrr_init_count,
  sum( case when date_trunc(f.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter) and f.net_mrr_usd > 0 then 1 end ) as net_mrr_new_count,
  sum( case when f.net_mrr_usd_qtd_diff_transfer_adj != 0 then 1 end ) as net_mrr_diff_count,
  sum( case when f.net_mrr_usd_qtd_diff_fx != 0 then 1 end ) as net_mrr_diff_fx_count,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "New" and f.net_mrr_usd_qtd_diff_transfer_adj != 0 then 1 end ) as net_mrr_diff_new_count,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Expansion" and f.net_mrr_usd_qtd_diff_transfer_adj != 0 then 1 end ) as net_mrr_diff_exp_count,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Contraction" and f.net_mrr_usd_qtd_diff_transfer_adj != 0 then 1 end ) as net_mrr_diff_con_count,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Churn" and f.net_mrr_usd_qtd_diff_transfer_adj != 0 then 1 end ) as net_mrr_diff_chu_count,
  sum( case when replace(replace(f.qtd_mrr_diff_type_transfer_adj,"Customer ",""),"Product ","") = "Return" and f.net_mrr_usd_qtd_diff_transfer_adj != 0 then 1 end ) as net_mrr_diff_ret_count,
  sum( case when f.recurring_discount_usd != 0 then 1 end ) as discount_rec_count,
  sum( case when f.nonrecurring_discount_usd != 0 then 1 end ) as discount_nonrec_count
from gtm_operations_general.mrr f
--left join ( select y.mrr_date, y.id, y.currency, string_agg(concat(y.billing_cycle," (",cast(round(y.net_mrr_usd/z.net_mrr_usd*100,1) as string),"%)"),", " order by y.net_mrr_usd desc) as billing_cycle
--            from ( select x.mrr_date, x.id, x.currency, x.billing_cycle, sum(x.net_mrr_usd_loc) as net_mrr_usd
--                   from `edw-prod-153420.gtm_operations_general.fdw_crm` x
--                   group by x.mrr_date, x.id, x.currency, billing_cycle ) y
--            left join ( select x.mrr_date, x.id, x.currency, sum(x.net_mrr_usd_loc) as net_mrr_usd
--                        from `edw-prod-153420.gtm_operations_general.fdw_crm` x
--                        group by x.mrr_date, x.id, x.currency ) z on z.mrr_date = y.mrr_date and z.id = y.id and z.currency = y.currency
--            group by y.mrr_date, y.id, y.currency ) bc on bc.mrr_date = date(f.mrr_date) and bc.id = f.id and bc.currency = f.currency
left join gtm_operations_general.mrr f0 on date_trunc(f0.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter) and f0.crm_account_id = f.crm_account_id and f0.mrr_type = f.mrr_type
--where f.net_mrr_usd_qtd_diff_transfer_adj < 25000
--where f.crm_account_owner_role_vp_team = "APAC"
where f.mrr_date >= "2015-03-31"
group by 1, 2, 3, 4, 5, 6, 7, f.mrr_type_sort
order by 1 desc, 2 desc, 3, 4, 5, 6, 7, f.mrr_type_sort;


-- script scraps

select * from edw_financials.pop_mrr_crm where crm_account_id = "0018000001dOnA4AAK" order by mrr_date desc;

select mrr_date, crm_account_id, net_mrr_usd_prior_qtr_end, net_mrr_usd_qtd_diff_nonfx, net_mrr_usd_qtd_diff_transfer_adj, net_mrr_usd_qtd_diff_fx, net_mrr_usd, net_mrr_usd - ( net_mrr_usd_prior_qtr_end + net_mrr_usd_qtd_diff_transfer_adj + net_mrr_usd_qtd_diff_fx )
from gtm_operations_general.mrr
where abs( net_mrr_usd - ( net_mrr_usd_prior_qtr_end + net_mrr_usd_qtd_diff_transfer_adj + net_mrr_usd_qtd_diff_fx ) ) > 1
order by mrr_date desc, net_mrr_usd desc;

select distinct product_line from edw_financials.pop_mrr_product;
select * from gtm_operations_general.opportunities where owner_role_vp_team = "Unknown";

select sum(net_mrr_usd) from gtm_operations_general.mrr where mrr_date = date_add(current_date, interval -1 day) and mrr_type = "Total";
select DISTINCT mrr_type from gtm_operations_general.mrr;
select DISTINCT mrr_type, qtd_mrr_diff_type_transfer_adj from gtm_operations_general.mrr order by 1, 2;


-- init date f'ed up

select * from gtm_operations_general.mrr
where mrr_date = mrr_date_init
  and qtd_mrr_diff_type_transfer_adj not in ("Customer New","Customer Return","Customer No Change");
 
select sum(net_mrr_usd_prior_qtr_end) from gtm_operations_general.mrr
where mrr_date = mrr_date_init
  and qtd_mrr_diff_type_transfer_adj not in ("Customer New","Customer Return");

select * from edw_financials.pop_mrr_crm where crm_account_id = "0018000001YPIwAAAX" order by mrr_date desc;
select * from edw_financials.pop_mrr_crm where crm_account_id = "0018000001EdAY2AAN" order by mrr_date desc;
select * from edw_financials.pop_mrr_crm where crm_account_id = "0018000001RSiqCAAT" order by mrr_date desc;

select distinct qtd_mrr_diff_type_transfer_adj from edw_financials.pop_mrr_crm where mrr_date = "2014-01-01";

with t as (
select date_trunc(f.mrr_date,quarter) as mrr_date,
  date_trunc(f.mrr_date_init,quarter) as mrr_date_init,
  sum( f.net_mrr_usd ) as account_mrr,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) then case when f.net_mrr_usd > f0.net_mrr_usd then f.net_mrr_usd - f0.net_mrr_usd end end ) as account_mrr_exp,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) then case when f.net_mrr_usd < f0.net_mrr_usd then f.net_mrr_usd - f0.net_mrr_usd end end ) as account_mrr_con,
  sum( case when date_trunc(f.mrr_date,quarter) > date_trunc(f.mrr_date_init,quarter) then f0.net_mrr_usd end ) as account_mrr_init,
  sum( case when date_trunc(f.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter) then f.net_mrr_usd end ) as account_mrr_new
from gtm_operations_general.mrr f
left join gtm_operations_general.mrr f0 on f0.crm_account_id = f.crm_account_id and date_trunc(f0.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter)
where date_trunc(f.mrr_date,quarter) = "2018-04-01"
group by mrr_date, mrr_date_init )
select t.*, account_mrr - account_mrr_exp + account_mrr_con + account_mrr_init + account_mrr_new )
from t
--where account_mrr != coalesce(account_mrr_exp,0) + coalesce(account_mrr_con,0) + coalesce(account_mrr_init,0) + coalesce(account_mrr_new,0)
order by 1 desc, 2 desc;

select f.crm_account_id, f.mrr_date, f.mrr_date_init, f0.mrr_date as f0date
from gtm_operations_general.mrr f
left join gtm_operations_general.mrr f0 on f0.crm_account_id = f.crm_account_id and date_trunc(f0.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter)
where f0.net_mrr_usd is null;

select * from gtm_operations_general.mrr where crm_account_id = "0018000001Kc6BxAAJ" order by mrr_date desc;
select * from edw_financials.pop_mrr_crm where crm_account_id = "0018000001Kc6BxAAJ" order by mrr_date desc;


-- null init date test 1 (pass)

select concat(cast(extract(year from f.mrr_date) as string),"Q",cast(extract(quarter from f.mrr_date) as string)) as mrr_date,
  concat(cast(extract(year from f.mrr_date_init) as string),"Q",cast(extract(quarter from f.mrr_date_init) as string)) as mrr_date_init,
  count(*)
from gtm_operations_general.mrr f
left join gtm_operations_general.mrr f0 on f0.crm_account_id = f.crm_account_id and date_trunc(f0.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter)
left join gtm_operations_general.mrr fn on fn.crm_account_id = f.crm_account_id and date_trunc(fn.mrr_date,quarter) = date_trunc(current_date,quarter)
group by mrr_date, mrr_date_init
order by 1 desc, 2 desc;


-- null init date test 2 (fail... intra-quarter churns!)

select f.mrr_date, count(*)
from gtm_operations_general.mrr f
left join gtm_operations_general.mrr f0 on f0.crm_account_id = f.crm_account_id and date_trunc(f0.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter)
where f0.mrr_date is null
group by f.mrr_date
order by 1 desc;

select distinct f.crm_account_id
from gtm_operations_general.mrr f
left join gtm_operations_general.mrr f0 on f0.crm_account_id = f.crm_account_id and date_trunc(f0.mrr_date,quarter) = date_trunc(f.mrr_date_init,quarter)
where f0.mrr_date is null;


select DISTINCT product_offering
from edw_financials.pop_mrr_product_offering
order by 1;