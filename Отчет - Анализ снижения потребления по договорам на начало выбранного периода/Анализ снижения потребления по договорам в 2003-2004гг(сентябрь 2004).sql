declare
@main_date_begin smalldatetime,
@main_date_end   smalldatetime,

@prev_date_begin smalldatetime,
@prev_date_end   smalldatetime,

@next_date_begin smalldatetime,
@next_date_end   smalldatetime,

@current_date    smalldatetime

select 
  @current_date = (select top 1 date_calc_end from ProGroups )

select
  @main_date_end = '2004-12-31',
  @next_date_end = '2005-12-31'

select @main_date_begin =dateadd(dd,+1, 
                         dateadd(mm,-12,@main_date_end))

select @prev_date_begin = dateadd(yy,-1,@main_date_begin)
select @prev_date_end = dateadd(yy,-1,@main_date_end)


if @main_date_end >= @current_date
begin
  select @main_date_end =  dateadd(dd,-1,
                           dateadd(mm,-1, 
                           dateadd(dd,+1,@current_date)))   
  select @main_date_begin =dateadd(dd,+1, 
                           dateadd(mm,-12,@main_date_end))
end


select @next_date_begin =dateadd(dd,+1, 
                         dateadd(mm,-12,@next_date_end))

/*
select 
  main_date_begin = @main_date_begin,
  main_date_end = @main_date_end,
  next_date_begin = @next_date_begin,
  next_date_end = @next_date_end,
  prev_date_begin = @prev_date_begin,
  prev_date_end = @prev_date_end
*/

IF Object_Id('TempDB..#Tmp2004') Is NOT Null
  DROP TABLE  #Tmp2004

IF Object_Id('TempDB..#C2003') Is NOT Null
  DROP TABLE  #C2003
IF Object_Id('TempDB..#C2003_4') Is NOT Null
  DROP TABLE  #C2003_4
IF Object_Id('TempDB..#PlanDetails') Is Not Null
  DROP Table #PlanDetails

SELECT
  Cs.CONTRACT_ID,
  QNT_ALL=SUM(C1.QNT_ALL)
 INTO
   #C2003
 FROM
  ProContracts Cs (NoLock),
  ProCalcs C1 (NoLock)
 WHERE
  C1.CONTRACT_ID=Cs.CONTRACT_ID AND
  C1.DATE_CALC Between @prev_date_begin AND @prev_date_end
 GROUP BY 
  Cs.CONTRACT_ID

SELECT
  Cs.CONTRACT_ID,
  QNT_ALL=SUM(C2.QNT_ALL)
 INTO
   #C2003_4
 FROM
  ProContracts Cs (NoLock),
  ProCalcs C2 (NoLock) 
 WHERE
  C2.CONTRACT_ID=Cs.CONTRACT_ID AND
  C2.DATE_CALC Between @main_date_begin AND @main_date_end
 GROUP BY
  Cs.CONTRACT_ID

SELECT
  CONTRACT_ID=Cs.CONTRACT_ID,
  QNT_ALL=SUM(PD.CALC_QUANTITY)
 INTO 
  #PlanDetails
 FROM
  ProContracts Cs (NoLock),
  ProPlanDetails PD (NoLock)
 WHERE
  PD.CONTRACT_ID=*Cs.CONTRACT_ID AND
  PD.MEASURE_ID=4 AND
  PD.DATE_CALC Between @next_date_begin AND @next_date_end
 GROUP BY
  Cs.CONTRACT_ID
 ORDER BY
  Cs.CONTRACT_ID

SELECT
  Cs.CONSUMER_GROUP_ID,
  Cs.CONTRACT_NUMBER,
  Cs.GROUP_ID,
  Cs.CONTRACT_ID,
  A.ABONENT_NAME,
  Cs.FIRST_DATE_CONTRACT,
  Cs.DATE_CONTRACT_CLOSE,
  F1=C1.QNT_ALL,
  F2=C2.QNT_ALL,
  F3=PD.QNT_ALL 
 Into
  #Tmp2004
 FROM
  ProContracts Cs (NoLock),
  ProAbonents A (NoLock),
  #PlanDetails PD (NoLock),    
  #C2003 C1 (NoLock),
  #C2003_4 C2 (NoLock) 
 WHERE
  A.ABONENT_ID=Cs.ABONENT_ID  AND
  (Cs.DATE_CONTRACT_CLOSE Is Null OR Cs.DATE_CONTRACT_CLOSE>=@prev_date_end) AND
  PD.CONTRACT_ID=Cs.CONTRACT_ID AND
  C1.CONTRACT_ID=Cs.CONTRACT_ID AND
  C2.CONTRACT_ID=Cs.CONTRACT_ID AND
  C1.QNT_ALL>C2.QNT_ALL
 ORDER BY
  Cs.CONSUMER_GROUP_ID,
  Cs.CONTRACT_NUMBER,
  Cs.CONTRACT_ID
    

SELECT
--  T.CONSUMER_GROUP_ID,
  T.CONTRACT_NUMBER,
  RES = case when T.GROUP_ID = 10010 then 'ÃÝÐÑ'
             else 'ÐÝÑ-'+convert(char(1),(T.GROUP_ID - 10010)) end,
--  T.CONTRACT_ID,
  T.ABONENT_NAME,
--  T.FIRST_DATE_CONTRACT,
--  T.DATE_CONTRACT_CLOSE,
  col1 = IsNull(T.F1,0),
  col2 = IsNull(T.F2,0),
  col3 = IsNull(T.F3,0),
  col4 = IsNull(T.F2,0) - IsNull(T.F1,0),
  col5 = IsNull(T.F3,0) - IsNull(T.F2,0)
 FROM
  #Tmp2004 T (NoLock)
 ORDER BY
  T.CONSUMER_GROUP_ID,
  T.CONTRACT_NUMBER
  

