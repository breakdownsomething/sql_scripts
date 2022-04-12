declare 
  @contract_id int,
  @year        smallint,
  @month       smallint

select @contract_id  = 204015

select @year =  [YEAR],
       @month = [MONTH]
from aspCommon..YearMonth

SELECT
	ACCOUNT_ID,
	POWER_ACCOUNT_NAME='['+CONVERT(VARCHAR(9),ACCOUNT_ID)+'] '+isnull(ACCOUNT_NAME,'???')
FROM 
	ProAccounts
WHERE
  CONTRACT_ID = @contract_id AND
	POWER_GROUP_ID =0 AND
	AUDIT_PARAM_ID<>2 AND
	AUDIT_METHOD_ID = 4  

  and  ACCOUNT_ID not in 
 (select distinct 
    PTPA.TRANC_POWER_ACCOUNT_ID
  from ProTrancPowerAcc PTPA (nolock)
  where PTPA.contract_id = @contract_id and 
      (PTPA.date_calc_end is null or
        (YEAR(PTPA.date_calc_end) = @year and
         MONTH(PTPA.date_calc_end) = @month) 
      )
  )
ORDER BY
	ACCOUNT_ID


--select * from PRoContracts where contract_number = 50033