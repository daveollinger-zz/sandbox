-- fortune 1000 companies

select concat(cast(extract(year from f.mrr_date) as string),"Q",cast(extract(quarter from f.mrr_date) as string)) as mrr_date,
  a.ult_parent_dnb_ult_name,
  a.ult_parent_name,
  sum( f.net_mrr_usd ) as net_mrr_usd,
  0 as open_mrr,
  "" as open_ids
from gtm_operations_general.mrr f
join gtm_operations_general.accounts a on a.account_id = f.crm_account_id
where f.mrr_type = "Total" and a.ult_parent_dnb_ult_rank is not null
group by 1, 2, 3
union all select "",
  a.ult_parent_dnb_ult_name,
  "",
  0,
  sum( o.total_booking_mrr ),
  string_agg( substr(o.id,1,15) )
from gtm_operations_general.accounts a
left join gtm_operations_general.opportunities o on o.accountid = a.account_id and o.status = "Open"
where a.ult_parent_dnb_ult_rank is not null
group by 1, 2, 3
order by 1 desc, sum(net_mrr_usd) over (partition by mrr_date, ult_parent_dnb_ult_name) desc, net_mrr_usd desc;


-- unique f1000 dnbs

select coalesce(d2.fortunerank,d1.fortunerank) as rank,
  case when d2.fortunerank is null then d1.name else d2.name end as ult_dnb_company,
  sum( f.net_mrr_usd ) as net_mrr ,
  sum( o.total_booking_mrr ) as open_mrr
from sfdc.dandbcompany_scd2 d2
join sfdc.dandbcompany_scd2 d1 on d1.globalultimatedunsnumber = d2.dunsnumber and d1.dw_curr_ind = "Y"
left join sfdc.account_scd2 a2 on a2.dandbcompanyid = d1.id and a2.dw_curr_ind = "Y"
left join ( select distinct x.accountid, x.account_ult_parentid from gtm_operations_general.accounts x ) c on c.account_ult_parentid = a2.id
left join sfdc.account_scd2 a1 on a1.id = c.accountid and a1.dw_curr_ind = "Y"
left join gtm_operations_general.mrr f on f.crm_account_id = a1.id and date_trunc(f.mrr_date,quarter) = date_trunc(current_date,quarter) and f.mrr_type = "Total"
left join gtm_operations_general.opportunities o on o.accountid = a1.id and o.status = "Open"
where coalesce(d2.fortunerank,d1.fortunerank) is not null and d2.dw_curr_ind = "Y"
group by 1, 2
order by 1, 3 desc, 4 desc;


-- missing f1000 dnbs

select d1.name as dnb_name, d1.fortunerank as dnb_rank, d1.globalultimatedunsnumber as dnb_ultn, d2.name as ult_name, d2.fortunerank as ult_rank,
  sum(f.net_mrr_usd)
from sfdc.dandbcompany_scd2 d1
left join sfdc.dandbcompany_scd2 d2 on d2.dunsnumber = d1.globalultimatedunsnumber and d2.dw_curr_ind = "Y"
left join sfdc.account_scd2 a2 on a2.dandbcompanyid = d1.id and a2.dw_curr_ind = "Y"
left join ( select distinct x.accountid, x.account_ult_parentid from gtm_operations_general.accounts x ) c on c.account_ult_parentid = a2.id
left join gtm_operations_general.mrr f on f.crm_account_id = c.accountid and date_trunc(f.mrr_date,quarter) = date_trunc(current_date,quarter) and f.mrr_type = "Total"
where d1.fortunerank is not null
  and d1.dw_curr_ind = "Y"
  and d1.name not in ( select distinct case when d2.fortunerank is null then d1.name else d2.name end as name
                       from sfdc.dandbcompany_scd2 d2
                       join sfdc.dandbcompany_scd2 d1 on d1.globalultimatedunsnumber = d2.dunsnumber and d1.dw_curr_ind = "Y"
                       where coalesce(d2.fortunerank,d1.fortunerank) is not null
                         and d2.dw_curr_ind = "Y" )
group by 1, 2, 3, 4, 5
order by 1;


-- 10k customers

select concat(cast(extract(year from f.mrr_date) as string),"Q",cast(extract(quarter from f.mrr_date) as string)) as mrr_date,
  p.name as crm_ult_parent,
  c.name as crm_account,
  f.net_mrr_usd,
  null as open_mrr,
  "" as open_ids
from ( select distinct x.account_ult_parentid
       from ( select distinct accountid, account_ult_parentid from gtm_operations_general.accounts ) x
       join gtm_operations_general.mrr y on y.crm_account_id = x.accountid and y.mrr_type = "Total"
       group by x.account_ult_parentid, y.mrr_date having sum(y.net_mrr_usd) >= 10000 ) z
join ( select distinct accountid, account_ult_parentid from gtm_operations_general.accounts ) r on r.account_ult_parentid = z.account_ult_parentid
join gtm_operations_general.mrr f on f.crm_account_id = r.accountid and f.mrr_type = "Total" and f.net_mrr_usd > 0
join sfdc.account_scd2 p on p.id = r.account_ult_parentid and p.dw_curr_ind = "Y"
join sfdc.account_scd2 c on c.id = r.accountid and c.dw_curr_ind = "Y"
group by 1, 2, 3, 4
union all select "",
  p.name,
  "",
  null,
  sum( o.total_booking_mrr ),
  string_agg( substr(o.id,1,15) )
from ( select distinct x.account_ult_parentid
       from ( select distinct accountid, account_ult_parentid from gtm_operations_general.accounts ) x
       join gtm_operations_general.mrr y on y.crm_account_id = x.accountid and y.mrr_type = "Total"
       group by x.account_ult_parentid, y.mrr_date having sum(y.net_mrr_usd) >= 10000 ) z
join ( select distinct accountid, account_ult_parentid from gtm_operations_general.accounts ) r on r.account_ult_parentid = z.account_ult_parentid
join gtm_operations_general.opportunities o on o.accountid = r.accountid and o.status = "Open"
join sfdc.account_scd2 p on p.id = r.account_ult_parentid and p.dw_curr_ind = "Y"
group by 2
order by 1 desc, sum(net_mrr_usd) over (partition by mrr_date, crm_ult_parent) desc, 4 desc, 5 desc;