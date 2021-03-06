-- Скрип начального заполнения ProDivSal

-- Данныее за 02-2004 заполняются новым методом для того
-- чтобы потом правильно расчитать данные за 03-2004 (для
-- правильного расчета нужны значения исходящего сальдо за прошлый месяц)
-- Остальное (кроме 02-2004) конвертируется из старой таблицы ProDivSaldo
-- После перехода, когда март уже будет расчитан нужно будет 
-- заменить данные в ProDivSal за 02-2004 на старые из ProDivSaldo


-- <1> Полная чистка ProDivSal
delete from ProDivSal

-- <2> Растет данных за февраль новым методом
-- (При таком расчете, т.е. без данных по предыдущему месяцу
-- правильно будут расчитаны только начисления и сальдо на конец.
-- Что собственно и нужно для нормального расчета марта) 

exec sp_ProDivSal '2004-02-29'

-- <3> Перенос данных из ProDivSaldo c ProDivSal (кроме февральских)

declare
  @dtCurEnd            datetime
select 
  @dtCurEnd  = '2004-02-29'

declare
	@DATE_CALC             datetime,
	@CONTRACT_ID           int,
-- Сальдо на начало
	@BSALDO20              decimal(18,2),
	@BQUANTITY20           int,
	@BSUM_EE20             decimal(18,2),
	@BSUM_ACT20            decimal(18,2),
	@BSUM_EXC20            decimal(18,2),
	@BSALDO16              decimal(18,2),
	@BQUANTITY16           int,
	@BSUM_EE16             decimal(18,2),
	@BSUM_ACT16            decimal(18,2),
	@BSUM_EXC16            decimal(18,2),
 	@BSALDO15              decimal(18,2),
	@BQUANTITY15           int,
	@BSUM_EE15             decimal(18,2),
	@BSUM_ACT15            decimal(18,2),
	@BSUM_EXC15            decimal(18,2),
-- Начисления
	@NACH20                decimal(18,2),
	@NQUANTITY20           int,
	@NSUM_EE20             decimal(18,2),
	@NSUM_NDS20            decimal(18,2),
	@NSUM_EXC20            decimal(18,2),
	@NACH16                decimal(18,2),
	@NQUANTITY16           int,
	@NSUM_EE16             decimal(18,2),
	@NSUM_NDS16            decimal(18,2),
	@NSUM_EXC16            decimal(18,2),
	@NACH15                decimal(18,2),
	@NQUANTITY15           int,
	@NSUM_EE15             decimal(18,2),
	@NSUM_NDS15            decimal(18,2),
	@NSUM_EXC15            decimal(18,2),
-- Платежи
	@PAY20                 decimal(18,2),
	@PQUANTITY20           int,
	@PSUM_EE20             decimal(18,2),
	@PSUM_NDS20            decimal(18,2),
	@PSUM_EXC20            decimal(18,2),
	@PAY16                 decimal(18,2),
	@PQUANTITY16           int,
	@PSUM_EE16             decimal(18,2),
	@PSUM_NDS16            decimal(18,2),
	@PSUM_EXC16            decimal(18,2),
	@PAY15                 decimal(18,2),
	@PQUANTITY15           int,
	@PSUM_EE15             decimal(18,2),
	@PSUM_NDS15            decimal(18,2),
	@PSUM_EXC15            decimal(18,2),
-- Сальдо на конец
	@ESALDO20              decimal(18,2),
	@EQUANTITY20           int,
	@ESUM_EE20             decimal(18,2),
	@ESUM_ACT20            decimal(18,2),
	@ESUM_EXC20            decimal(18,2),
	@ESALDO16              decimal(18,2),
	@EQUANTITY16           int,
	@ESUM_EE16             decimal(18,2),
	@ESUM_ACT16            decimal(18,2),
	@ESUM_EXC16            decimal(18,2),
	@ESALDO15              decimal(18,2),
	@EQUANTITY15           int,
	@ESUM_EE15             decimal(18,2),
	@ESUM_ACT15            decimal(18,2),
	@ESUM_EXC15            decimal(18,2)
declare curExistsRecrd cursor for
select
	DATE_CALC,
	CONTRACT_ID,
-- Сальдо на начало
	BSALDO20, BQUANTITY20,	BSUM_EE20,	BSUM_ACT20,	BSUM_EXC20,
	BSALDO16,	BQUANTITY16,	BSUM_EE16,	BSUM_ACT16,	BSUM_EXC16,
	BSALDO15,	BQUANTITY15,	BSUM_EE15,	BSUM_ACT15,	BSUM_EXC15,
--Начисления
	NACH20,	NQUANTITY20,	NSUM_EE20,	NSUM_NDS20,	NSUM_EXC20,
	NACH16,	NQUANTITY16,	NSUM_EE16,	NSUM_NDS16,	NSUM_EXC16,
	NACH15,	NQUANTITY15,	NSUM_EE15,	NSUM_NDS15,	NSUM_EXC15,
-- Платежи
	PAY20,	PQUANTITY20,	PSUM_EE20,	PSUM_NDS20,	PSUM_EXC20,
	PAY16,	PQUANTITY16,	PSUM_EE16,	PSUM_NDS16,	PSUM_EXC16,
	PAY15,	PQUANTITY15,	PSUM_EE15,	PSUM_NDS15,	PSUM_EXC15,
--Сальдо на конец
	ESALDO20,	EQUANTITY20,	ESUM_EE20,	ESUM_ACT20,	ESUM_EXC20,
	ESALDO16,	EQUANTITY16,	ESUM_EE16,	ESUM_ACT16,	ESUM_EXC16,
	ESALDO15,	EQUANTITY15,	ESUM_EE15,	ESUM_ACT15,	ESUM_EXC15
from ProDivSaldo
where DATE_CALC <> @dtCurEnd

open curExistsRecrd
fetch next from curExistsRecrd
 into  
	@DATE_CALC,
	@CONTRACT_ID,
--Сальдонаначало
	@BSALDO20,	@BQUANTITY20,	@BSUM_EE20,	@BSUM_ACT20,	@BSUM_EXC20,
	@BSALDO16,	@BQUANTITY16,	@BSUM_EE16,	@BSUM_ACT16,	@BSUM_EXC16,
	@BSALDO15,	@BQUANTITY15,	@BSUM_EE15,	@BSUM_ACT15,	@BSUM_EXC15,
--Начисления
	@NACH20,	@NQUANTITY20,	@NSUM_EE20,	@NSUM_NDS20,	@NSUM_EXC20,
	@NACH16,	@NQUANTITY16,	@NSUM_EE16,	@NSUM_NDS16,	@NSUM_EXC16,
	@NACH15,	@NQUANTITY15,	@NSUM_EE15,	@NSUM_NDS15,	@NSUM_EXC15,
--Платежи
	@PAY20,	@PQUANTITY20,	@PSUM_EE20,	@PSUM_NDS20,	@PSUM_EXC20,
	@PAY16,	@PQUANTITY16,	@PSUM_EE16,	@PSUM_NDS16,	@PSUM_EXC16,
	@PAY15,	@PQUANTITY15,	@PSUM_EE15,	@PSUM_NDS15,	@PSUM_EXC15,
--Сальдо на конец
	@ESALDO20,	@EQUANTITY20,	@ESUM_EE20,	@ESUM_ACT20,	@ESUM_EXC20,
	@ESALDO16,	@EQUANTITY16,	@ESUM_EE16,	@ESUM_ACT16,	@ESUM_EXC16,
	@ESALDO15,	@EQUANTITY15,	@ESUM_EE15,	@ESUM_ACT15,	@ESUM_EXC15 

---------------------------------------------------------------------------------
while (@@FETCH_STATUS <> -1)
begin
---------------------------------------------------------------------
--    Запись данных в ProDivSal
---------------------------------------------------------------------
if   @BSUM_EE20   <> 0
  or @BSUM_ACT20  <> 0
  or @BSUM_EXC20  <> 0
  or @BQUANTITY20 <> 0
 
  or @NSUM_EE20   <> 0
  or @NSUM_NDS20  <> 0
  or @NSUM_EXC20  <> 0
  or @NQUANTITY20 <> 0 

  or @PSUM_EE20   <> 0
  or @PSUM_NDS20  <> 0
  or @PSUM_EXC20  <> 0
  or @PQUANTITY20 <> 0 

  or @ESUM_EE20   <> 0
  or @ESUM_ACT20  <> 0
  or @ESUM_EXC20  <> 0
  or @EQUANTITY20 <> 0 
    begin
    insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC)
                   values (@CONTRACT_ID  ,@DATE_CALC ,'20' 
                          ,@BQUANTITY20  ,@BSUM_EE20 ,@BSUM_ACT20  ,@BSUM_EXC20
                          ,@NQUANTITY20  ,@NSUM_EE20 ,@NSUM_NDS20  ,@NSUM_EXC20
                          ,@PQUANTITY20  ,@PSUM_EE20 ,@PSUM_NDS20  ,@PSUM_EXC20
                          ,@EQUANTITY20  ,@ESUM_EE20 ,@ESUM_ACT20  ,@ESUM_EXC20) 
    end

if   @BSUM_EE16   <> 0
  or @BSUM_ACT16  <> 0
  or @BSUM_EXC16  <> 0
  or @BQUANTITY16 <> 0
 
  or @NSUM_EE16   <> 0
  or @NSUM_NDS16  <> 0
  or @NSUM_EXC16  <> 0
  or @NQUANTITY16 <> 0 

  or @PSUM_EE16   <> 0
  or @PSUM_NDS16  <> 0
  or @PSUM_EXC16  <> 0
  or @PQUANTITY16 <> 0 

  or @ESUM_EE16   <> 0
  or @ESUM_ACT16  <> 0
  or @ESUM_EXC16  <> 0
  or @EQUANTITY16 <> 0 

    begin
    insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC)
                   values (@CONTRACT_ID  ,@DATE_CALC ,'16' 
                          ,@BQUANTITY16  ,@BSUM_EE16 ,@BSUM_ACT16  ,@BSUM_EXC16
                          ,@NQUANTITY16  ,@NSUM_EE16 ,@NSUM_NDS16  ,@NSUM_EXC16
                          ,@PQUANTITY16  ,@PSUM_EE16 ,@PSUM_NDS16  ,@PSUM_EXC16
                          ,@EQUANTITY16  ,@ESUM_EE16 ,@ESUM_ACT16  ,@ESUM_EXC16)  
     end

if   @BSUM_EE15   <> 0
  or @BSUM_ACT15  <> 0
  or @BSUM_EXC15  <> 0
  or @BQUANTITY15 <> 0
 
  or @NSUM_EE15   <> 0
  or @NSUM_NDS15  <> 0
  or @NSUM_EXC15  <> 0
  or @NQUANTITY15 <> 0 

  or @PSUM_EE15   <> 0
  or @PSUM_NDS15  <> 0
  or @PSUM_EXC15  <> 0
  or @PQUANTITY15 <> 0 

  or @ESUM_EE15   <> 0
  or @ESUM_ACT15  <> 0
  or @ESUM_EXC15  <> 0
  or @EQUANTITY15 <> 0 

    begin
    insert into ProdivSal (Contract_id   ,date_calc  ,nds_tax
                          ,BQUANTITY     ,BSUM_EE    ,BSUM_NDS    ,BSUM_EXC
                          ,NQUANTITY     ,NSUM_EE    ,NSUM_NDS    ,NSUM_EXC
                          ,PQUANTITY     ,PSUM_EE    ,PSUM_NDS    ,PSUM_EXC
                          ,EQUANTITY     ,ESUM_EE    ,ESUM_NDS    ,ESUM_EXC)
                   values (@CONTRACT_ID  ,@DATE_CALC ,'15' 
                          ,@BQUANTITY15  ,@BSUM_EE15 ,@BSUM_ACT15  ,@BSUM_EXC15
                          ,@NQUANTITY15  ,@NSUM_EE15 ,@NSUM_NDS15  ,@NSUM_EXC15
                          ,@PQUANTITY15  ,@PSUM_EE15 ,@PSUM_NDS15  ,@PSUM_EXC15
                          ,@EQUANTITY15  ,@ESUM_EE15 ,@ESUM_ACT15  ,@ESUM_EXC15) 
    end

---------------------------------------------------------------------
fetch next from curExistsRecrd
 into  
	@DATE_CALC,
	@CONTRACT_ID,
--Сальдо на начало
	@BSALDO20,	@BQUANTITY20,	@BSUM_EE20,	@BSUM_ACT20,	@BSUM_EXC20,
	@BSALDO16,	@BQUANTITY16,	@BSUM_EE16,	@BSUM_ACT16,	@BSUM_EXC16,
	@BSALDO15,	@BQUANTITY15,	@BSUM_EE15,	@BSUM_ACT15,	@BSUM_EXC15,
--Начисления
	@NACH20,	@NQUANTITY20,	@NSUM_EE20,	@NSUM_NDS20,	@NSUM_EXC20,
	@NACH16,	@NQUANTITY16,	@NSUM_EE16,	@NSUM_NDS16,	@NSUM_EXC16,
	@NACH15,	@NQUANTITY15,	@NSUM_EE15,	@NSUM_NDS15,	@NSUM_EXC15,
--Платежи
	@PAY20,	@PQUANTITY20,	@PSUM_EE20,	@PSUM_NDS20,	@PSUM_EXC20,
	@PAY16,	@PQUANTITY16,	@PSUM_EE16,	@PSUM_NDS16,	@PSUM_EXC16,
	@PAY15,	@PQUANTITY15,	@PSUM_EE15,	@PSUM_NDS15,	@PSUM_EXC15,
--Сальдо на конец
	@ESALDO20,	@EQUANTITY20,	@ESUM_EE20,	@ESUM_ACT20,	@ESUM_EXC20,
	@ESALDO16,	@EQUANTITY16,	@ESUM_EE16,	@ESUM_ACT16,	@ESUM_EXC16,
	@ESALDO15,	@EQUANTITY15,	@ESUM_EE15,	@ESUM_ACT15,	@ESUM_EXC15 
end
close curExistsRecrd
deallocate curExistsRecrd

