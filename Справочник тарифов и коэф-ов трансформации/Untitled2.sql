select t.tarif_id
      ,t.tarif_name
      ,t.serv_id
      ,st.serv_name
      ,m.measure_name
      ,tarif_value = convert(decimal(12,4),tv.tarif_value)
from Tarifs       t  (nolock)
    ,MeasureItems m  (nolock)
    ,ServiceTypes st (nolock)
    ,TarifValues  tv (nolock)
where t.measure_id = m.measure_id
  and st.serv_id   = t.serv_id
  and tv.serv_id   = t.serv_id 
  and t.serv_id    in (13,23,24,29,86)
  and tv.suppl_id  = t.suppl_id
  and t.suppl_id   = 600
  and tv.tarif_id  = t.tarif_id
  and tv.day_calc  = (select max(day_calc)
                      from TarifValues tv1 (nolock)
                      where tv1.serv_id = t.serv_id
                        and tv1.suppl_id = t.suppl_id
                        and tv1.tarif_id = t.tarif_id)


--select top 10 * from tarifvalues where day_calc <> 1