

select Need_Recalc = case when (isnull(PCC.add_quantity,0) <> 0)
                          then 'Да'
                          else 'Нет' end,
       PTPL.account_id,
       PTPL.loss_quantity,
       PA.tranc_power_account_id, 
       PCC.quantity,
       PCC.add_quantity
from ProTrancPowerLoss PTPL (nolock),
     ProAccounts       PA   (nolock),
     ProCntCounts      PCC  (nolock)
where PA.account_id = PTPL.account_id and
      PCC.account_id = PA.tranc_power_account_id and
      PCC.date_id    = PTPL.date_calc
      


