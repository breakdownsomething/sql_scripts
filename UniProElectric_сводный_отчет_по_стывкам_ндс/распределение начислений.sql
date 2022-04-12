--drop table #charges
declare
  @dtDateBeg           datetime
 ,@dtDateEnd           datetime
 ,@dtCurBeg            datetime
 ,@dtCurEnd            datetime
 ,@dtNextEnd           datetime
 ,@dtCurEnd_loop       DateTime -- служебная переменная

select
  @dtDateBeg = '1998-08-31'   -- период начала хранимых данных (конец)
 ,@dtDateEnd =  DateAdd(dd,-1,DateAdd(mm,-1,DateAdd(dd,+1,(select distinct date_calc_end from ProGroups))))
                -- :dtDateEnd, --последний закрытый месяц по базе данных (конец)
 ,@dtCurBeg  = '2004-02-01'   --:dtCurBeg,  -- первый день расчетного месяца
 ,@dtCurEnd  = DateAdd(dd,-1,DateAdd(mm,+1,@dtCurBeg))   --:dtCurEnd,  -- последний
 ,@dtNextEnd = Dateadd(mm,+1,@dtCurEnd)  -- последний день месяца, следующего после расчетного



SELECT
  CONTRACT_ID = C.CONTRACT_ID,
  QUANTITY    = C.QNT_ALL,
  SUM_EE      = C.SUM_FACT,
  SUM_ACT     = C.SUM_NDS,
  SUM_EXC     = C.SUM_EXC,

/* Дополнительные начисления за период с НДС 15% */
  QUANTITY_15 = convert(decimal(12,2),0),
  SUM_EE_15   = convert(decimal(12,2),0),
  SUM_ACT_15  = convert(decimal(12,2),0),
  SUM_EXC_15  = convert(decimal(12,2),0),

/* Дополнительные начисления за период с НДС 20% */
 /* сумма за электроэнергию*/
 /* SUM_ADD_20 -> SUM_EE_20 */
  SUM_EE_20   = Convert(Decimal(12,2),IsNull(
                   (SELECT SUM(CD.SUM_CALC) 
                    FROM ProCalcDetails CD
                    WHERE CD.CALC_ID = C.CALC_ID AND
                          CD.DECODE_ID = 8 AND
                          (SELECT DATE_CALC
                           FROM ProCalcs
                           WHERE CALC_ID = CD.SOURCE_ID) < '2001-07-31'),0)),
/*Количество кВт*/
  QUANTITY_20 = Convert(Integer,IsNull(
               (SELECT SUM(CD.CALC_QUANTITY)
                FROM ProCalcDetails CD
                WHERE CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),
/*сумма акциза*/
   SUM_EXC_20   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.CALC_QUANTITY*CC.EXCISE_TAX)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),
/*сумма НДС*/
   SUM_ACT_20   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM((CD.SUM_CALC + CD.CALC_QUANTITY*CC.EXCISE_TAX*
                         (CASE WHEN CC.DATE_CALC > '2000-09-30'
                               THEN 1
                               ELSE 0 END)
                   )*CC.ADD_COST_TAX/100)
                 /*Если дата платежа старше 2000-09-30 тогда НДС с акциза не начислять*/
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID)<'2001-07-31'),0)),

/* Дополнительные начисления за период с НДС 16% */
/*сумма за электроэнергию*/
  SUM_EE_16  = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.SUM_CALC) 
                   FROM ProCalcDetails CD
                   WHERE CD.CALC_ID = C.CALC_ID AND
                         CD.DECODE_ID = 8 AND
                         (SELECT DATE_CALC
                          FROM ProCalcs
                          WHERE CALC_ID = CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),
/*Количество кВт*/
  QUANTITY_16 =  Convert(Integer,IsNull(
                (SELECT SUM(CD.CALC_QUANTITY)
                 FROM ProCalcDetails CD
                 WHERE CD.CALC_ID  = C.CALC_ID AND
                       CD.DECODE_ID = 8 AND
                       (SELECT DATE_CALC
                        FROM ProCalcs
                        WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),

/*сумма акциза*/
   SUM_EXC_16   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM(CD.CALC_QUANTITY*CC.EXCISE_TAX)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0)),

/*сумма НДС*/
   SUM_ACT_16   = Convert(Decimal(12,2),IsNull(
                  (SELECT SUM((CD.SUM_CALC+CD.CALC_QUANTITY*CC.EXCISE_TAX)*CC.ADD_COST_TAX/100)
                   FROM ProCalcDetails CD,
                        ProCalcs       CC
                   WHERE CC.CALC_ID  = CD.SOURCE_ID AND
                      CD.CALC_ID  = C.CALC_ID AND
                      CD.DECODE_ID = 8 AND
                     (SELECT DATE_CALC
                      FROM ProCalcs
                      WHERE CALC_ID=CD.SOURCE_ID) BETWEEN '2001-07-31' AND '2003-12-31'),0))

 INTO #Charges
 FROM ProCalcs C (NoLock)
 WHERE C.DATE_CALC = @dtCurEnd
ALTER TABLE  #Charges
 ADD PRIMARY KEY (CONTRACT_ID)

if @dtCurEnd < '2001-07-31'
  begin
  update #Charges
   set
     QUANTITY_20 = QUANTITY
    ,SUM_EE_20   = SUM_EE
    ,SUM_ACT_20  = SUM_ACT 
    ,SUM_EXC_20  = SUM_EXC
  end

if @dtCurEnd BETWEEN '2001-07-31' AND '2003-12-31'
  begin
  update #Charges
    set
      QUANTITY_16 = QUANTITY - QUANTITY_20
     ,SUM_EE_16  = SUM_EE  - SUM_EE_20
     ,SUM_ACT_16 = SUM_ACT - SUM_ACT_20
     ,SUM_EXC_16 = SUM_EXC - SUM_EXC_20 
  end

if @dtCurEnd > '2003-12-31'
  begin
  update #Charges
    set
      QUANTITY_15 = QUANTITY - QUANTITY_20 - QUANTITY_16
     ,SUM_EE_15  = SUM_EE  - SUM_EE_20 - SUM_EE_16
     ,SUM_ACT_15 = SUM_ACT - SUM_ACT_20 - SUM_ACT_16
     ,SUM_EXC_15 = SUM_EXC - SUM_EXC_20 - SUM_EXC_16
  end

--select sum(SUM_EE_15 + SUM_ACT_15 + SUM_EXC_15+
--           SUM_EE_20 + SUM_ACT_20 + SUM_EXC_20+
--           SUM_EE_16 + SUM_ACT_16 + SUM_EXC_16) from #Charges


--select count(distinct contract_id) from #Charges
--select count(distinct contract_id) from ProDivSal
--     where date_calc = '2004-02-29'
--select count(distinct contract_id) from ProCalcs
--     where date_calc = '2004-02-29'
--drop table #Charges
--select * from #Charges
--where SUM_EE_15 + SUM_ACT_15 + SUM_EXC_15 +
--      SUM_EE_20 + SUM_ACT_20 + SUM_EXC_20+
--       SUM_EE_16 + SUM_ACT_16 + SUM_EXC_16 =0
-- Заполнение сумм начислений...---------------------------
declare
  @contract_id   int
 ,@date_calc     datetime
 ,@nquantity20   int
 ,@nsum_ee20     decimal(18,2)
 ,@nsum_act20    decimal(18,2)
 ,@nsum_exc20    decimal(18,2)
 ,@nquantity16   int
 ,@nsum_ee16     decimal(18,2)
 ,@nsum_act16    decimal(18,2)
 ,@nsum_exc16    decimal(18,2)
 ,@nquantity15   int
 ,@nsum_ee15     decimal(18,2)
 ,@nsum_act15    decimal(18,2)
 ,@nsum_exc15    decimal(18,2)
 ,@i             int
declare curExistsNach cursor for
 select  
  contract_id ,Date_calc = @dtCurEnd
 ,quantity_20  ,sum_ee_20   ,sum_act_20  ,sum_exc_20 
 ,quantity_16  ,sum_ee_16   ,sum_act_16  ,sum_exc_16
 ,quantity_15  ,sum_ee_15   ,sum_act_15  ,sum_exc_15
 from #Charges
 order by Contract_id

open curExistsNach

fetch next from curExistsNach
 into  
  @contract_id  ,@date_calc  
 ,@nquantity20  ,@nsum_ee20  ,@nsum_act20  ,@nsum_exc20
 ,@nquantity16  ,@nsum_ee16  ,@nsum_act16  ,@nsum_exc16
 ,@nquantity15  ,@nsum_ee15  ,@nsum_act15  ,@nsum_exc15 
select @i = 1
while (@@FETCH_STATUS <> -1)
begin
  if @nsum_ee20 <> 0
  begin 
     if exists (select * from ProDivsal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 20)
     begin
       update ProDivSal
       set nQUANTITY = @nquantity20
          ,nSUM_EE   = @nsum_ee20
          ,nSUM_NDS  = @nsum_act20
          ,nSUM_EXC  = @nsum_exc20          
       where contract_id = @contract_id
         and date_calc   = @date_calc
         and nds_tax     = 20
     end  
     else
     begin
        insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'20' 
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,@nquantity20  ,@nsum_ee20 ,@nsum_act20 ,@nsum_exc20
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  if @nsum_ee16 <> 0
  begin
     if exists (select * from ProDivsal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 16)
     begin
        update ProDivSal
        set nQUANTITY = @nquantity16
           ,nSUM_EE   = @nsum_ee16
           ,nSUM_NDS  = @nsum_act16
           ,nSUM_EXC  = @nsum_exc16          
        where contract_id = @contract_id
          and date_calc   = @date_calc
          and nds_tax     = 16
     end
     else
     begin
        insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'16' 
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,@nquantity16  ,@nsum_ee16 ,@nsum_act16 ,@nsum_exc16
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  if @nsum_ee15 <> 0
  begin
     if exists (select * from ProDivsal
                where contract_id = @contract_id
                  and date_calc   = @date_calc
                  and nds_tax     = 15)
     begin
        update ProDivSal
        set nQUANTITY = @nquantity15
           ,nSUM_EE   = @nsum_ee15
           ,nSUM_NDS  = @nsum_act15
           ,nSUM_EXC  = @nsum_exc15          
        where contract_id = @contract_id
          and date_calc   = @date_calc
          and nds_tax     = 15
      end
      else
      begin
        insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC)
                   values (@contract_id  ,@date_calc ,'15' 
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,@nquantity15  ,@nsum_ee15 ,@nsum_act15 ,@nsum_exc15
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0)
                          ,convert(decimal(18,2),0))  
     end
  end
  fetch next from curExistsNach
    into  
       @contract_id  ,@date_calc  
      ,@nquantity20  ,@nsum_ee20  ,@nsum_act20  ,@nsum_exc20
      ,@nquantity16  ,@nsum_ee16  ,@nsum_act16  ,@nsum_exc16
      ,@nquantity15  ,@nsum_ee15  ,@nsum_act15  ,@nsum_exc15 
select @i = @i+1
end
Print @i
close curExistsNach
deallocate curExistsNach


/*
--15%-------------
update ProDivSal 
set
  NQUANTITY = C.Quantity_15
 ,NSUM_EE   = C.Sum_EE_15 
 ,NSUM_NDS  = C.Sum_ACT_15
 ,NSUM_EXC  = C.Sum_Exc_15
from
 #Charges  C  (nolock)
 ,ProDivSal PC (nolock)
where
     PC.Contract_id = C.contract_id
 and Date_calc   = @dtCurEnd
 and Nds_tax     = 15

--16%------------------
update ProDivSal
set 
  NQUANTITY = C.Quantity_16
 ,NSUM_EE   = C.Sum_EE_16 
 ,NSUM_NDS  = C.Sum_ACT_16
 ,NSUM_EXC  = C.Sum_Exc_16
from
 #Charges  C  (nolock)
 ,ProDivSal PC (nolock)
where
     PC.Contract_id = C.contract_id
 and Date_calc   = @dtCurEnd
 and Nds_tax     = 16

--20%-------------------
update ProDivSal
set 
  NQUANTITY = C.Quantity_20
 ,NSUM_EE   = C.Sum_EE_20 
 ,NSUM_NDS  = C.Sum_ACT_20
 ,NSUM_EXC  = C.Sum_Exc_20
from
 #Charges  C  (nolock)
 ,ProDivSal PC (nolock)
where
     PC.Contract_id = C.contract_id
 and Date_calc   = @dtCurEnd
 and Nds_tax     = 20

*/

--select sum(nsum_ee+nsum_nds + nsum_exc) from ProDivSal