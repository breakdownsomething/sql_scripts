-------------------------------------------------------------------------------------------------
-- Автор  :  Матесов Д.С.
-- Цель   :  Согласно план-задания №13, прилоджение№2
-- Дата   :  4.11.2003
-------------------------------------------------------------------------------------------------



declare
  @dcTarif decimal(15, 2)

select
  @dcTarif  = (select top 1 tarif_value from ##tmp_1__62 where serv_id = 37)

select
  isnull(r.subgroup_name, 'Неизвестный филиал') as Название_филиала,
  t.account_id as Номер_ЛС,
  s.serv_name as Услуга,
  Cnt_M3 =  sum(case
                                            when t.serv_id not in (47, 48, 56, 61, 88) and
                                            t.lock_sign_current = 0
                                              then
                                                 convert(decimal(15, 3),
                                                   (case
                                                      when t.serv_id in (37,49,50,51)
                                                        then
                               case when isnull(cnt_sum_calc, 0) < 0
                                    then isnull(cnt_sum_calc, 0) else 0
                               end
                                                        else 0
                                                      end) / @dcTarif)
                                                else 0 end),
  Cnt_tg                      =  sum(case
                                            when t.serv_id not in (47, 48, 56, 61, 88) and
                                            t.lock_sign_current = 0
                                              then
                                                 convert(decimal(15, 3),
                                                   (case
                                                      when t.serv_id in (37,49,50,51)
                                                        then
                               case when isnull(cnt_sum_calc, 0) < 0
                                    then isnull(cnt_sum_calc, 0) else 0
                               end
                                                        else 0
                                                      end))
                                                else 0 end),
  Norm_M3  =  sum(
    case
      when t.serv_id not in (47, 48, 56, 61, 88) and
        t.lock_sign_current = 0
      then
        convert(decimal(15, 3),
          (case
            when t.serv_id not in (37,49,50,51)
            then
                               case when
                                      (isnull(sum_calc, 0) -
                                      isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
                                      isnull(replace_sum_saldo, sum_saldo_begin)) < 0
                                    then
                                      isnull(sum_calc, 0) -
                                      isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
                                      isnull(replace_sum_saldo, sum_saldo_begin)
                                    else 0
                               end
            else 0
          end)/@dcTarif)
    else 0 
  end),


  Norm_tg    =  sum(
    case
      when t.serv_id not in (47, 48, 56, 61, 88) and
        t.lock_sign_current = 0
      then
        convert(decimal(15, 3),
          (case
            when t.serv_id not in (37,49,50,51)
            then
                               case when
                                      (isnull(sum_calc, 0) -
                                      isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
                                      isnull(replace_sum_saldo, sum_saldo_begin)) < 0
                                    then
                                      isnull(sum_calc, 0) -
                                      isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
                                      isnull(replace_sum_saldo, sum_saldo_begin)
                                    else 0
                               end
            else 0
          end))
    else 0 
  end)

/*select 
    sum_gas_m        = sum(case
                         when t.serv_id not in (47, 48, 56, 61, 88) and
                           lock_sign_current = 0
                         then
                           convert(decimal(15, 3),
                           (case
                             when t.serv_id in (37,49,50,51)
                             then 
                               case when isnull(cnt_sum_calc, 0) < 0
                                    then isnull(cnt_sum_calc, 0) else 0
                               end
                             else
                               case when
                                      (isnull(sum_calc, 0) -
                                      isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
                                      isnull(replace_sum_saldo, sum_saldo_begin)) < 0
                                    then
                                      isnull(sum_calc, 0) -
                                      isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
                                      isnull(replace_sum_saldo, sum_saldo_begin)
                                    else 0
                               end
                           end)/11.88)
                         else 0 end)*/
from 
  ##tmp_1__62                   t,
  aspBase2003_09..servicetypes  s (nolock),
  aspGas..GroupSub	        r (nolock)
where 
  s.serv_id = t.serv_id         and 
  r.subgroup_id =* t.subgroup_id and
  s.serv_id not in (47, 48, 56, 61, 88) and
  counter_sign = 1              and
  (case
     when t.serv_id in (47, 48, 56, 61, 88)
     then
       case 
         when isnull(cnt_sum_calc, 0) < 0
         then isnull(cnt_sum_calc, 0) 
         else 0
       end
     else
       case when
         (isnull(sum_calc, 0) -
         isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
         isnull(replace_sum_saldo, sum_saldo_begin)) < 0
       then
         isnull(sum_calc, 0) -
         isnull(delta_sum_saldo, 0) + isnull(sum_saldo_begin, 0) -
         isnull(replace_sum_saldo, sum_saldo_begin)
       else 0
       end
     end) <= -5000 and                 
  t.sector_id = 11000   
GROUP BY
 isnull(r.subgroup_name, 'Неизвестный филиал'),
 t.account_id,
 s.serv_name
