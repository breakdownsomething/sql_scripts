IF EXISTS (SELECT * 
	   FROM   sysobjects 
	   WHERE  name = N'fn_Tranc_Power_Loss')
	DROP FUNCTION dbo.fn_Tranc_Power_Loss
GO

CREATE FUNCTION dbo.fn_Tranc_Power_Loss(@iTruncPowerId  int, @iMonthQuantity int)
/*
 Copyright 2004 «јќ УјлсекоФ. All rights reserved.
 Name:                fn_Tranc_Power_Loss
 Short Description:   ‘ункци€ определени€ мес€чных потерь в 
                      трансформаторе заданного типа при заданном
                      мес€чном расходе электроэнергии в к¬т*ч
 in parameter  1:     @iTruncPowerId int - id типа трансформатора
 in parameter  2:     @iMonthQuantity int - фактический расход за мес€ц в к¬т*ч 
 Result:              «начение мем€чных потерь в к¬т*ч
 Autor:	              ћатесов ƒ.—.
 Date:	   	          25.03.2004
*/
RETURNS decimal(18,2)
AS
BEGIN
declare
  @siDuty_1   smallint 
 ,@siDuty_2   smallInt
 ,@dLosses_1  decimal(18,2)
 ,@dLosses_2  decimal(18,2)
 ,@siTruncPowerDuty smallint

select @siTruncPowerDuty = round((
                           (100 * @iMonthQuantity)/(730 * 0.9 * (select TRANC_POWER_CAPACITY
                                                                 from  ProTrancPowerList
                                                                 where TRANC_POWER_ID = @iTruncPowerId))
                           ),0)
select @siTruncPowerDuty = case when @siTruncPowerDuty > 100
                                then 100
                                else @siTruncPowerDuty end
select @siDuty_1 = round(@siTruncPowerDuty/5,0,1)*5
select @siDuty_2 = @siDuty_1 + 5
select @dLosses_1 = Isnull((select TRANC_POWER_LOSS
                            from ProTrancPowerCoef
                            where TRANC_POWER_ID   = @iTruncPowerId
                            and TRANC_POWER_COEF = @siDuty_1),0)
select @dLosses_2 = IsNull((select TRANC_POWER_LOSS
                            from ProTrancPowerCoef
                            where TRANC_POWER_ID   = @iTruncPowerId
                            and TRANC_POWER_COEF = @siDuty_2),0)
RETURN round((  @dLosses_1 +	
               (@dLosses_2 - @dLosses_1)*(@siTruncPowerDuty - @siDuty_1)/(@siDuty_2 - @siDuty_1)
             ),2)
END
GO

