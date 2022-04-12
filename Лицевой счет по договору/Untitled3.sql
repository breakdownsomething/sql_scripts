select distinct abonent_id from ProabonentsArc a (nolock)
where (select count(distinct abonent_name)
       from ProabonentsArc b (nolock)
       where a.abonent_id = b.abonent_id) > 3





select * from ProAbonents where abonent_id = 536961
select abonent_name, * from ProAbonentsArc where abonent_id = 536961
order by date_id desc

select * from ProContracts where abonent_id = 536961

select abonent_name
from ProAbonentsArc
where abonent_id = (select abonent_id 
                    from  ProContracts
                    where contract_id = 165115)


                            and date_id    = @DateEnd)