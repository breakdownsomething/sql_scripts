declare
  @account_id    int,
  @serv_id       int,
  @last_pay_date smalldatetime,
  @last_count_pay int,
  @noncounted_pay int,
  @EndDate       smalldatetime
select
  @account_id = 11088,
  @serv_id    = 13,
  @EndDate    = '2004-02-01'

if (year(@EndDate)  = (select year from aspCommon..YearMonth)) and
   (month(@EndDate) = (select month from aspCommon..YearMonth))
  begin 
    select @last_pay_date = last_pay_date,
           @last_count_pay = last_count_pay 
    from   LastCountPays
    where  account_id = @account_id
       and serv_id    = @serv_id
  end
else
  begin
    select @last_pay_date = last_pay_date,
           @last_count_pay = last_count_pay 
    from   LCPMonth
    where  account_id = @account_id
       and serv_id    = @serv_id
       and year       = year(@EndDate)
       and month      = month(@EndDate)
  end


SELECT
 @noncounted_pay = isnull(sum(DRP.COUNT_PAY),0)
FROM
	Rcp                      R   (NOLOCK),
	RcpPays	                 RP  (NOLOCK),
	DayRcpPays               DRP (NOLOCK)
WHERE
	R.ACCOUNT_ID       = @account_id    	 AND
	RP.DATE_ID         = R.DATE_ID				 AND
  RP.LABEL_NUMBER    = R.LABEL_NUMBER		 AND
	RP.RECIEPT_NUMBER  = R.RECIEPT_NUMBER	 AND
	RP.SERV_ID         = @serv_id	  			 AND
	DRP.DATE_ID        = RP.DATE_ID				 AND
 	DRP.LABEL_NUMBER   = RP.LABEL_NUMBER	 AND
	DRP.RECIEPT_NUMBER = RP.RECIEPT_NUMBER AND
	DRP.SERV_ID        = RP.SERV_ID        AND
  DRP.DATE_ID        > @last_pay_date    AND
  DRP.DATE_ID        < @EndDate

select qnt = @last_count_pay + @noncounted_pay




