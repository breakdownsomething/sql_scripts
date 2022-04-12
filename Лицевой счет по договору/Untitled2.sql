DECLARE
  @DateBegin      DateTime,
  @DateEnd        DateTime,
  @MainDateEnd    DateTime,
  @DateCalc       DateTime,
  @DateContract   DateTime,
  @iContractId    Integer,
  @String         VarChar(24),
  @SumPay         Decimal(18,2),
  @SumCalc        Decimal(18,2),
  @SumRea         Decimal(18,2),
  @Excise         Decimal(18,2),
  @CalcAddCostTax Decimal(18,2),
  @SumSaldo       Decimal(18,2),
  @Saldo          Decimal(18,2),
  @SaldoPeni      Decimal(18,2),
  @Quantity       Integer,
  @CalcFine       Decimal(18,2),
  @PayFine        Decimal(18,2),
  @iCalcPeriods   Integer,

  @sAbonentName   Varchar(100),
  @dtBegin        DateTime,
  @dtEnd          DateTime
SELECT
 @iContractId   = 165115,--: piContractId,
 @iCalcPeriods  = 36,--: piCalcPeriods,
 @DateBegin     = convert(datetime,'2004-05-01'),--: pdtDatBeg,
 @DateEnd       = convert(datetime,'2004-05-31'),--: pdtDatEnd,
 @MainDateEnd   = convert(datetime,'2004-05-31')--: pdtMainDatEnd

SELECT
 @DateCalc = @DateBegin

IF EXISTS (SELECT * FROM TempDB..sysobjects
           WHERE id = object_id('TempDB.dbo.#WorkTable') 
            and sysstat & 0xf = 3)
EXEC('DROP TABLE #WorkTable')



WHILE DATEDIFF(mm,@DateBegin,@DateCalc) <= @iCalcPeriods 

BEGIN
  SELECT @String=CONVERT(CHAR(5),DATEDIFF(MM,@DateBegin,@DateCalc))
  PRINT  @String

  SELECT
    @Saldo = CASE WHEN @DateEnd = @MainDateEnd
                  THEN (SELECT Max(Cn.SALDO) FROM ProContracts Cn
                        WHERE Cn.CONTRACT_ID = @iContractId)
                  ELSE SUM(C.SALDO) END,

    @SumSaldo = CASE WHEN @DateEnd = @MainDateEnd
                     THEN (SELECT Max(Cn.SUM_SALDO) FROM ProContracts Cn
                           WHERE Cn.CONTRACT_ID = @iContractId)
                     ELSE SUM(C.SUM_SALDO) END,

    @SaldoPeni = CASE WHEN @DateEnd = @MainDateEnd
                      THEN (SELECT Max(Cn.SALDO_PENI) FROM ProContracts Cn
                            WHERE Cn.CONTRACT_ID = @iContractId)
                      ELSE SUM(C.SALDO_PENI) END,

    @SumCalc        = SUM(C.SUM_FACT)  ,
    @Excise         = SUM(C.SUM_EXC)  ,
    @CalcAddCostTax = SUM(C.SUM_NDS) ,
    @CalcFine       = SUM(C.SUM_PENI)  ,
    @SumRea         = SUM(C.SUM_REACTIVE)  ,
    @Quantity       = SUM(C.QNT_ALL)
       FROM
        ProCalcs C
       WHERE
        C.CONTRACT_ID=@iContractId AND
       (C.DATE_CALC BETWEEN @DateBegin AND @DateEnd)

  SELECT
    @SumPay = COALESCE((SELECT SUM(P.SUM_EE+SUM_ACT) FROM  ProPayments P
                        WHERE P.CONTRACT_ID = @iContractId AND
                             (P.DATE_PAY BETWEEN @DateBegin AND @DateEnd)),0),
    @PayFine = COALESCE((SELECT SUM(P.SUM_FINE) FROM ProPayments P
                         WHERE P.CONTRACT_ID=@iContractId AND
                              (P.DATE_PAY BETWEEN @DateBegin AND @DateEnd)),0)

   select @sAbonentName = case when @DateEnd = @MainDateEnd
                               then (select abonent_name
                                         from ProAbonents
                                         where abonent_id = (select abonent_id 
                                                             from  ProContracts
                                                             where contract_id = @iContractId))
                               else
                                 isnull((select abonent_name
                                         from ProAbonentsArc
                                         where abonent_id = (select abonent_id 
                                                             from  ProContracts
                                                             where contract_id = @iContractId)
                                          and date_id    = @DateEnd),
                                        (select top 1 abonent_name
                                         from ProAbonentsArc
                                         where abonent_id = (select abonent_id 
                                                             from  ProContracts
                                                             where contract_id = @iContractId)
                                                             order by date_id asc)
                                        ) end

Print @Saldo
Print @SumSaldo
Print @SaldoPeni
Print @SumCalc
Print @Excise
Print @CalcAddCostTax
Print @CalcFine
Print @Quantity
Print @SaldoPeni
Print @SumPay
Print @PayFine
Print @SumRea

  IF DATEDIFF(mm,@DateBegin,@DateCalc) = 0
  BEGIN
    Print 'a'
    SELECT
      ABONENT_ID=A.ABONENT_ID,
      CONTRACT_NUMBER=Cn.CONTRACT_NUMBER,
      ABONENT_NAME=@sAbonentName,--A.ABONENT_NAME,
      ADDRESS= CASE
     WHEN ISnull(A.STREET_ID,0)<>0 THEN
      (SELECT
         Convert(VarChar(50),
           IsNull(RTrim(T.TOWN_NAME),'')+','+
           IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
           IsNull(RTrim(S.STREET_NAME),'')+','+
           IsNull(RTrim(A.HOUSE_ID),'')+','+
           IsNull(RTrim(A.FLAT_ID),''))
        FROM
         Streets S,
         StreetTypes ST,
         Towns T
        WHERE
         S.STREET_ID=A.STREET_ID AND
         ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
         T.TOWN_ID=*S.TOWN_ID ) 
     ELSE
       A.ADDRESS   
   END,
      PHONE=A.PHONE,
      DATE_BEGIN=@DateBegin,
      DATE_END=@DateEnd,
      SALDO_IN=@Saldo,
      QUANTITY=@Quantity,
      SUM_CALC=@SumCalc,
      EXCISE=@Excise,
      CALC_ADD_COST_TAX=@CalcAddCostTax,
      SUM_PAY=@SumPay,
      SALDO_PENI=@SaldoPeni,
      SUM_CALC_FINE=@CalcFine,
      SUM_PAY_FINE=@PayFine,
      SUM_REACTIVE=@SumRea
     INTO #WorkTable
     FROM
      ProContracts Cn,
      ProAbonents A
     WHERE
      Cn.CONTRACT_ID=@iContractId AND
      A.ABONENT_ID=Cn.ABONENT_ID
  END
  ELSE
  BEGIN
    Print 'b'
--    SELECT
--      @Saldo=@Saldo+@SumCalc+@CalcAddCostTax-@SumPay

    INSERT
      #WorkTable
     ( ABONENT_ID,
      CONTRACT_NUMBER,
      ABONENT_NAME,
      ADDRESS,
      PHONE,
      DATE_BEGIN,
      DATE_END,
      SALDO_IN,
      QUANTITY,
      SUM_CALC,
      EXCISE,
      CALC_ADD_COST_TAX,
      SUM_PAY,
      SALDO_PENI,
      SUM_CALC_FINE,
      SUM_PAY_FINE,
      SUM_REACTIVE)
     SELECT
      ABONENT_ID=A.ABONENT_ID,
      CONTRACT_NUMBER=Cn.CONTRACT_NUMBER,
      ABONENT_NAME=@sAbonentName,--A.ABONENT_NAME,
      ADDRESS= CASE
     WHEN ISnull(A.STREET_ID,0)<>0 THEN 
      (SELECT
         Convert(VarChar(50),
           IsNull(RTrim(T.TOWN_NAME),'')+','+
           IsNull(RTrim(ST.STREET_TYPE_SHORT_NAME),'')+
           IsNull(RTrim(S.STREET_NAME),'')+','+
           IsNull(RTrim(A.HOUSE_ID),'')+','+
           IsNull(RTrim(A.FLAT_ID),''))
        FROM
         Streets S,
         StreetTypes ST,
         Towns T
        WHERE
         S.STREET_ID=A.STREET_ID AND
         ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
         T.TOWN_ID=*S.TOWN_ID )
     ELSE
       A.ADDRESS
   END,
      PHONE=A.PHONE,
      DATE_BEGIN=@DateBegin,
      DATE_END=@DateEnd,
      SALDO_IN=@Saldo,
      QUANTITY=@Quantity,
      SUM_CALC=@SumCalc,
      EXCISE=@Excise,
      CALC_ADD_COST_TAX=@CalcAddCostTax,
      SUM_PAY=@SumPay,
      SALDO_PENI=@SaldoPeni,
      SUM_CALC_FINE=@CalcFine,
      SUM_PAY_FINE=@PayFine,
      SUM_REACTIVE=@SumRea
     FROM
      ProContracts Cn,
      ProAbonents A
     WHERE
      Cn.CONTRACT_ID=@iContractId AND
      A.ABONENT_ID=Cn.ABONENT_ID
  END
  SELECT
    @DateEnd=DATEADD(DD,-1,@DateBegin),
    @DateBegin=DATEADD(MM,-1,@DateBegin)

Print @DateBegin
Print @DateEnd

END

  SELECT
     @dtBegin = min(date_begin),
     @dtEnd   = max(date_end)
   FROM
    #WorkTable

SELECT
     *,
     dtBegin = @dtBegin,
     dtEnd   = @dtEnd
   FROM
    #WorkTable


/*
   WHERE
      SALDO_IN<>0 OR
      QUANTITY<>0 OR
      SUM_CALC<>0 OR
      SUM_PAY<>0 OR
      SUM_CALC_FINE<>0 OR
      SUM_PAY_FINE<>0
*/
    ORDER BY
      DATE_END

DROP TABLE #WorkTable

 
 