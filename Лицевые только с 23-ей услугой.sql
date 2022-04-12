if exists(select * from tempdb..sysobjects where id = object_id('tempdb..#TmpAcc'))
begin
  drop table #TmpAcc
end

select
  AG.account_id,
  SS.serv_id
into #TmpAcc
from 
  Accounts      A  (nolock),
  AccountGroups AG (nolock),
  SumServices   SS (nolock)
where
  A.account_id = AG.account_id and 
  AG.group_id = 10001 and
  SS.ACCOUNT_ID = AG.ACCOUNT_ID and
  SS.SUPPL_ID   = 600 AND
  SS.SERV_SIGNS&512 = 0 and
  SS.SERV_ID in (13,23)

  
select a.*
from #TmpAcc a (nolock)
where not exists (select * from #TmpAcc b (nolock)
                  where a.account_id = b.account_id and
                        b.serv_id = 13)

  
