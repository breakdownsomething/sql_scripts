select sum(count_pay) from DayRcpPays
where serv_id = 24 and date_id between convert(smalldatetime,'2004-05-03')
                                   and convert(smalldatetime,'2004-05-03')


select * from RCP where  date_id between convert(smalldatetime,'2004-05-01')
                                   and convert(smalldatetime,'2004-05-31')



select sum(count_pay) from DayRcpPays
where serv_id in (24,29,86) and date_id= convert(smalldatetime,'2004-05-03')




select top 1 * from Rcp
select top 1 * from DayRcpPays
select top 1 * from aspBase2004_05..AccountGroups



select sum(count_pay)

from DayRcpPays drp (nolock),
     Rcp        r   (nolock),
     aspBase2004_05..AccountGroups  base (nolock)
   
where drp.serv_id in (24,29,86)
     and drp.date_id = convert(smalldatetime,'2004-05-03')
     and drp.date_id = r.date_id
     and drp.label_number = r.label_number
     and drp.reciept_number = r.reciept_number
     and r.account_id = base.account_id
     and base.subgroup_id = 1
