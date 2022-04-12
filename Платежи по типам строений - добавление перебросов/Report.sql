SELECT
	SUBGROUP_ID = IsNUll(AG.SUBGROUP_ID,0),
	BIG_HOUSE   = CASE WHEN S.TOWN_ID>0
                     THEN 2
		                 ELSE IsNull((Select H.Big_House
                                  From aspBase2004_07..Houses H (nolock)
                                  Where A.Street_id = H.Street_id
                                     and A.House_id = H.House_id),2)
                     END,
	COUNT_PAY   = SUM(DRP.COUNT_PAY),
	SUM_PAY     = SUM(DRP.SUM_PAY),
	COUNT_RCP   = COUNT(*),
	COUNT_ACC   = 0
INTO #Tmp1
FROM
  aspBase2004_07..Accounts 			            A  (NOLOCK),
  aspBase2004_07..AccountGroups             AG (NOLOCK),
	aspBase2004_07..Streets                   S  (NOLOCK),
--  '+@Base+'SumServices               SS (NOLOCK),
	aspElectric..Rcp	                        R  (NOLOCK),
	aspElectric..DayRcpPays                   DRP(NOLOCK)
WHERE
	A.ACCOUNT_ID       = AG.ACCOUNT_ID AND
	AG.GROUP_ID        = 10001         AND
	S.STREET_ID        = A.STREET_ID   AND
	R.ACCOUNT_ID       = AG.ACCOUNT_ID AND
  R.Date_id between '2004-07-01' and
                    '2004-07-31' and
  DRP.DATE_ID        = R.DATE_ID AND
  DRP.LABEL_NUMBER   = R.LABEL_NUMBER	AND
	DRP.RECIEPT_NUMBER = R.RECIEPT_NUMBER	AND
	DRP.SERV_ID  IN (13,23,24,29)
/* Добавлено для сходимости с 748-й формой---------------*/
  and DRP.Suppl_Id   = 600

-- and SS.Account_id = AG.Account_id
-- and SS.Serv_Id    = DRP.Serv_Id
-- and SS.Suppl_Id   = 600
/*-------------------------------------------------------*/
GROUP BY
	S.TOWN_ID,
	AG.SUBGROUP_ID,
  A.Street_id,
  A.House_id
--	BIG_HOUSE
ORDER BY
	AG.SUBGROUP_ID
--	BIG_HOUSE


select sum(sum_pay),
       sum(COUNT_RCP),
       sum(count_pay)
 from #Tmp1

--drop table #Tmp1
--truncate table #Tmp1

insert into #Tmp1 (SUBGROUP_ID,
                   BIG_HOUSE,
                   COUNT_PAY,
                   SUM_PAY,
                   COUNT_RCP,
                   COUNT_ACC)

  select
      AG.Subgroup_id,
      BIG_HOUSE   = CASE WHEN S.TOWN_ID>0
                     THEN 2
		                 ELSE IsNull((Select H.Big_House
                                  From aspBase2004_07..Houses H (nolock)
                                  Where A.Street_id = H.Street_id
                                     and A.House_id = H.House_id),2)
                     END,
      Count_pay = sum(DRP.Count_Pay),
      Sum_Pay   = sum(DRP.Sum_Pay),
      COUNT_RCP   = sum(swith_rmv), 
      COUNT_ACC = 0
  from
        aspBase2004_07..Accounts      A  (NOLOCK),
        aspBase2004_07..AccountGroups AG (nolock),
      	aspBase2004_07..RmvDayRcp	    R  (NOLOCK),
      	aspBase2004_07..RmvDayRcpPays	DRP(NOLOCK),
        aspBase2004_07..Streets       S  (NOLOCK)
      where
      	A.ACCOUNT_ID       = AG.ACCOUNT_ID  AND
      	S.STREET_ID        = A.STREET_ID    AND
        AG.Group_id        = 10001          and
        DRP.Account_id     = AG.Account_id      and
--------------------------------------------------------------
        R.DAY between
                    DAY(convert (DateTime,'2004-07-01')) and
                    DAY(convert (DateTime,'2004-07-31')) and
        R.Year_Old           = DRP.Year_Old and
        R.Month_Old          = DRP.Month_Old and
        R.Day_Old            = DRP.Day_Old and
        R.Label_Number_Old   = DRP.Label_Number_Old and
        R.Reciept_Number_Old = DRP.Reciept_Number_Old and
        DRP.Suppl_Id         = 600 
--------------------------------------------------------------
GROUP BY
   S.TOWN_ID,
	 AG.SUBGROUP_ID,
   A.Street_id,
   A.House_id

--select * from #Tmp2
select sum(sum_pay),
       sum(COUNT_RCP),
       sum(count_pay)
 from #Tmp1

-- drop table #Tmp1


--select * from aspElectric..tables where table_name = 'LCPMonth'

--select top 10 * from aspelectric..LCPMonth