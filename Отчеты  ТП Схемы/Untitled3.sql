--select * from tables where table_id = 105590
--select * from tablefields where table_id = (select table_id from tables where table_name='ElectNodes')

select  CE.account_id from CntElectricity CE (nolock)
where   CE.account_id not in (select AG.account_id
                               from  aspBase2004_04..AccountGroups AG (nolock)
                                    ,aspBase2004_04..SumServices   SS (nolock)
                               where
                                    AG.account_id = SS.account_id
                                and AG.group_id   = 10001
                                and SS.serv_id    = 13
                                and SS.suppl_id   = 600
                                )



select AG.account_id
      ,EN.substation_id
      ,EN.section_id
from  aspBase2004_04..AccountGroups AG (nolock)
     ,aspBase2004_04..SumServices   SS (nolock)
     ,CntElectricity                CE (nolock)
     ,ElectNodes                    EN (nolock)
where
      AG.account_id = SS.account_id
  and CE.account_id = AG.Account_id
  and CE.nodeid     = EN.nodeid
  and AG.group_id   = 10001
  and SS.serv_id    in (13,23)
  and SS.suppl_id   = 600
  and EN.substation_id = '7513'


select * from CntElectricity where account_id in (6670539, 6677134)  



select AG.account_id
      ,AG.group_id
      ,SS.Serv_id     
from aspBase2004_04..AccountGroups AG (nolock)
    ,aspBase2004_04..SumServices   SS (nolock)
where  AG.account_id = SS.account_id
  and  AG.account_id in (6670539, 6677134)  

 select * from aspBase2004_04..SumServices
where  account_id in (6670539, 6677134)  



