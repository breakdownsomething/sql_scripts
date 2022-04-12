if exists (select * from tempdb..sysobjects where id = object_id('tempdb..#TmpAcc'))
begin
drop table #TmpAcc
end

declare 
@all_count   int, -- ќбщее кол-во лицевых счетов
------------------------------------------------
@with_cnt    int, -- кол-во лицевых со счетчиком
@without_cnt int, -- кол-во лицевых без счетчика
------------------------------------------------
@single_service int, -- ко-во лицевых с одной услугой
@double_service int, -- ко-во лицевых с двум€ услугами
------------------------------------------------------
@one_phase_cnt   int, -- ко-во лицевых с 1-фазными счетчиками
@three_phase_cnt int, -- ко-во лицевых с 3-фазными счетчиками
@unknown_phase_cnt int,
-------------------------------------------------------------
@multi_flat_house int,-- ко-во лицевых с признаком "многоквартирный"
@private_house    int,-- ко-во лицевых с признаком "частный" 
---------------------------------------------------------------------
@cooker_with_double_tariff int,-- ко-во лицевых с признаком "Ёлек. плита с 2-ым тарифом"
@cooker_with_single_tariff int,-- ко-во лицевых с признаком "ѕросто Ёлек. плита"
----------------------------------------------------------------------------------------
@mask_ss_delete smallint

select @mask_ss_delete = const_value
from Const
where const_name = 'MASK_SS_DELETE'

create table #TmpAcc
(
account_id int not null,
has_cnt   bit null,
count_services smallint null,
phases_cnt     smallint null,
big_house      bit      null,
double_cooker  bit      null
)

-- ¬ыборка всех лицевых, которые имеют электрические услуги
-- за исключением удаленных
insert into #TmpAcc
(
account_id,
has_cnt,
count_services,
phases_cnt,
big_house,
double_cooker
)
select
distinct A.account_id,
null,  --has_cnt = LCP.set_sign,
null,
null,
null,
null
from Accounts      A   (nolock),
     SumServices   SS  (nolock)--,
--     aspElectric..LastCountPays LCP (nolock)
where 
     A.account_id = SS.account_id and
     SS.suppl_id  = 600           and
     SS.serv_id   in (13,23) and
     SS.tarif_id  <> 0 and
     SS.serv_signs & @mask_ss_delete = 0 --and
--     A.account_id = LCP.account_id


-- наличие/отсутствие счетчика
update #TmpAcc
set has_cnt = LCP.set_sign
from #TmpAcc TMP,
     aspElectric..LastCountPays LCP (nolock)
where
  TMP.account_id = LCP.account_id

-- количество услуг
update #TmpAcc
set count_services = (select count(*)
                      from SumServices SS (nolock)
                      where TMP.account_id = SS.account_id   and
                            SS.suppl_id  = 600               and
                            SS.serv_id   in (13,23) and
                            SS.tarif_id  <> 0                and
                            SS.serv_signs & @mask_ss_delete = 0
                       )
from #TmpAcc TMP

-- однофазные или трехфазные счетчики
update #TmpAcc
set 
  phases_cnt = case when substring(CT.specifications,0,
                                 patindex('%;%',CT.specifications)) = '1-нофазный'
                         then 1
                         when substring(CT.specifications,0,
                                 patindex('%;%',CT.specifications)) = '3-хфазный'
                         then 3
                         else 0 end
from aspElectric..Cnt CNT     (nolock),
     aspElectric..CntTypes CT (nolock),
     #TmpAcc               TMP
where TMP.account_id = CNT.account_id and
      CNT.counter_type_id = CT.counter_type_id and
      CNT.counter_number_id = (select max(CNT1.counter_number_id)
                               from aspElectric..Cnt CNT1 (nolock)
                               where CNT1.account_id = TMP.account_id)

update #TmpAcc
set has_cnt = convert(bit,1)
where phases_cnt is not null and
has_cnt is null

update #TmpAcc
set has_cnt = convert(bit,0)
where phases_cnt is null and
      has_cnt is null

-- ћногоквартирный/частный дом
update #TmpAcc
set
  big_house = H.big_house
from
#TmpAcc TMP,
Accounts A (nolock),
Houses   H (nolock)
where TMP.account_id = A.account_id and
      A.house_id     = H.house_id   and
      A.street_id    = H.street_id

update #TmpAcc
set
  big_house = convert(bit,0)
where big_house is null

-- Ёлектроплита
update #TmpAcc
set
  double_cooker = case when SS.tarif_id = 2
                       then convert(bit,0)
                       when SS.tarif_id = 18
                       then convert(bit,1) end
from #TmpAcc TMP,
     SumServices SS (nolock)
where TMP.account_id = SS.account_id and
      SS.suppl_id    = 600          and
      SS.serv_id     = 13           and
      SS.tarif_id    in (2,18)      and
      SS.serv_signs & @mask_ss_delete = 0

----------- ¬ыборки-------------------------
select @all_count = count(*)
from #TmpAcc

-- наличие/отсутствие счетчика
select @with_cnt = count(*)
from #TmpAcc
where has_cnt = convert(bit,1)
select @without_cnt = count(*)
from #TmpAcc
where has_cnt = convert(bit,0)

-- одна/две услуги
select @single_service = count(*)
from #TmpAcc
where count_services = 1
select @double_service = count(*)
from #TmpAcc
where count_services = 2

--фазность счетчиков 
select @one_phase_cnt = count(*)
from #TmpAcc
where phases_cnt = 1
and has_cnt = convert(bit,1)
select @three_phase_cnt = count(*)
from #TmpAcc
where phases_cnt = 3
and has_cnt = convert(bit,1)
select @unknown_phase_cnt = count(*)
from #TmpAcc
where
 (phases_cnt is null
  or phases_cnt = 0)
and has_cnt = convert(bit,1)

-- многоквартирный/частный
select @multi_flat_house = count(*)
from #TmpAcc
where big_house = convert(bit,1)
select @private_house = count(*)
from #TmpAcc
where big_house = convert(bit,0)

-- Ёлектроплита
select @cooker_with_double_tariff = count(*)
from #TmpAcc
where double_cooker = convert(bit,1)

select @cooker_with_single_tariff = count(*)
from #TmpAcc
where double_cooker = convert(bit,0)

--- вывод итогов
select
all_count = @all_count, -- ќбщее кол-во лицевых счетов
------------------------------------------------
with_cnt = @with_cnt, -- кол-во лицевых со счетчиком
without_cnt = @without_cnt, -- кол-во лицевых без счетчика
------------------------------------------------
single_service = @single_service, -- ко-во лицевых с одной услугой
double_service = @double_service, -- ко-во лицевых с двум€ услугами
------------------------------------------------------
one_phase_cnt = @one_phase_cnt, -- ко-во лицевых с 1-фазными счетчиками
three_phase_cnt = @three_phase_cnt, -- ко-во лицевых с 3-фазными счетчиками
unknown_phase_cnt = @unknown_phase_cnt,
-------------------------------------------------------------
multi_flat_house = @multi_flat_house,-- ко-во лицевых с признаком "многоквартирный"
private_house = @private_house,-- ко-во лицевых с признаком "частный" 
---------------------------------------------------------------------
cooker_with_double_tariff = @cooker_with_double_tariff,-- ко-во лицевых с признаком "Ёлек. плита с 2-ым тарифом"
cooker_with_single_tariff = @cooker_with_single_tariff-- ко-во лицевых с признаком "ѕросто Ёлек. плита"

--drop table #TmpAcc

