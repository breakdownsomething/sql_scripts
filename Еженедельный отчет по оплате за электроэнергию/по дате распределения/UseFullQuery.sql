if exists(select * from tempdb..sysobjects where id = object_id('tempdb..#TmpVid'))
begin
  drop table #TmpVid
end
create table #TmpVid(pay_type int)
insert into #TmpVid(pay_type) values (1)
insert into #TmpVid(pay_type) values (2)
insert into #TmpVid(pay_type) values (3)
insert into #TmpVid(pay_type) values (4)
insert into #TmpVid(pay_type) values (5)

---------------------------------------------------------------------------
DECLARE
  @dtCalcBegin    DateTime,
  @dtCalcEnd      DateTime,
  @dtMainCalcEnd  DateTime,
  @dtAnother      Decimal(18,2)

SELECT
  @dtCalcBegin   = '2004-11-01',--:pdtCalcBegin,
  @dtCalcEnd     = '2004-11-30',--:pdtCalcEnd,
  @dtMainCalcEnd = '2004-11-30'--:pdtMainCalcEnd


if exists(select * from tempdb..sysobjects where id = object_id('tempdb..#TmpRez'))
begin
  drop table #TmpRez
end

CREATE TABLE
  #TmpRez
 (CONSUMER_GROUP_ID SmallInt Not Null,
  CONSUMER_GROUP_NAME VarChar(30)  Null,
  SUM_PAY Decimal(18,2)  Null,
  SUM_NDS_PAY Decimal(18,2)  Null,
  SUM_FINE_PAY Decimal(18,2)  Null,
  SUM_ALL_PAY Decimal(18,2)  Null,
  Primary Key (CONSUMER_GROUP_ID))


if exists(select * from tempdb..sysobjects where id = object_id('tempdb..#TmpPays'))
begin
  drop table #TmpPays
end

SELECT
  Cn.CONTRACT_ID,
  Cn.CONSUMER_GROUP_ID,
  PAYMENT_TYPE=IsNull(P.PAYMENT_TYPE,0),
  SUM_PAY=SUM(IsNull(P.SUM_EE,0)),
  SUM_NDS_PAY=SUM(IsNull(P.SUM_ACT,0)),
  SUM_FINE_PAY=SUM(IsNull(P.SUM_FINE,0)),
  SUM_ALL_PAY=SUM(IsNull(P.SUM_EE,0)+IsNull(P.SUM_ACT,0)+IsNull(P.SUM_FINE,0))
 INTO
  #TmpPays
 FROM
  ProContracts Cn (NOLOCK),
  ProPayments P (NOLOCK)
 WHERE
  P.CONTRACT_ID=*Cn.CONTRACT_ID AND
--  P.DATE_OPL Between @dtCalcBegin AND @dtCalcEnd
  P.DATE_PAY Between @dtCalcBegin AND @dtCalcEnd
 GROUP BY
  Cn.CONTRACT_ID,
  Cn.CONSUMER_GROUP_ID,
  IsNull(P.PAYMENT_TYPE,0)
ALTER TABLE
    #TmpPays
 ADD PRIMARY KEY (CONTRACT_ID,PAYMENT_TYPE)


insert into #TmpRez
(
  CONSUMER_GROUP_ID,
  CONSUMER_GROUP_NAME,
  SUM_PAY,
  SUM_NDS_PAY,
  SUM_FINE_PAY,
  SUM_ALL_PAY
)
select
  CONSUMER_GROUP_ID   = Convert(SmallInt,PAG.abonent_group_id),
  CONSUMER_GROUP_NAME = Convert(VarChar(30),PAG.abonent_group_name),
  SUM_PAY             = Convert(Decimal(18,2),SUM(C.SUM_PAY)),
  SUM_NDS_PAY         = Convert(Decimal(18,2),SUM(C.SUM_NDS_PAY)),
  SUM_FINE_PAY        = Convert(Decimal(18,2),SUM(C.SUM_FINE_PAY)),
  SUM_ALL_PAY         = Convert(Decimal(18,2),SUM(C.SUM_ALL_PAY))
 FROM
  #TmpPays          C,
  #TmpVid           V,
  ProConsumerGroups PCG (nolock),
  ProAbonentGroups  PAG (nolock)
 WHERE
   V.PAY_TYPE          = C.PAYMENT_TYPE AND
   C.CONSUMER_GROUP_ID = PCG.CONSUMER_GROUP_ID and
   PCG.top_group_id    = PAG.abonent_group_id
 group by
   PAG.abonent_group_name,
   PAG.abonent_group_id


INSERT
 INTO
  #TmpRez
 SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,100),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Частный сектор (физ. лица)'),
  SUM_PAY=Convert(Decimal(18,2),SUM(UP.SUMm)),
  SUM_NDS_PAY=Convert(Decimal(18,2),0),
  SUM_FINE_PAY=Convert(Decimal(18,2),0),
  SUM_ALL_PAY=Convert(Decimal(18,2),SUM(UP.SUMm))
 FROM
  UnitPay UP,
  #TmpVid V
 WHERE
  V.PAY_TYPE=Convert(SmallInt,UP.VO) AND
  UP.KORS='30101' AND
  UP.KAUKS='0000' AND
  UP.DATAP Between @dtCalcBegin AND @dtCalcEnd



INSERT
 INTO
  #TmpRez
 SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,999),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'ВСЕГО'),
  SUM_PAY=Convert(Decimal(18,2),SUM(TR.SUM_PAY)),
  SUM_NDS_PAY=Convert(Decimal(18,2),SUM(TR.SUM_NDS_PAY)),
  SUM_FINE_PAY=Convert(Decimal(18,2),SUM(TR.SUM_FINE_PAY)),
  SUM_ALL_PAY=Convert(Decimal(18,2),SUM(TR.SUM_ALL_PAY))
 FROM
  #TmpRez TR


INSERT
 INTO
  #TmpRez
 SELECT
  CONSUMER_GROUP_ID=Convert(SmallInt,99),
  CONSUMER_GROUP_NAME=Convert(VarChar(30),'Итого промсектор (юр. лица)'),
  SUM_PAY=Convert(Decimal(18,2),SUM(C.SUM_PAY)),
  SUM_NDS_PAY=Convert(Decimal(18,2),SUM(C.SUM_NDS_PAY)),
  SUM_FINE_PAY=Convert(Decimal(18,2),SUM(C.SUM_FINE_PAY)),
  SUM_ALL_PAY=Convert(Decimal(18,2),SUM(C.SUM_ALL_PAY))
 FROM
  #TmpPays C,
  #TmpVid V
 WHERE
   V.PAY_TYPE=C.PAYMENT_TYPE

SELECT
  *
 FROM
  #TmpRez
 ORDER BY
  CONSUMER_GROUP_ID


