select sum(count_pay) from DayRcpPays
where serv_id = 24 and date_id between convert(smalldatetime,'2004-05-01')
                                   and convert(smalldatetime,'2004-05-31')


select * from RCP where  date_id between convert(smalldatetime,'2004-05-01')
                                   and convert(smalldatetime,'2004-05-31')
