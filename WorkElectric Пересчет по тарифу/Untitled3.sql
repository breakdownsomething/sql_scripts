SET NOCOUNT ON

declare
  @dtBegin  smalldatetime,
  @dtEnd    smalldatetime

select 
  @dtBegin = convert(smalldatetime,'1998.08.01'),
  @dtEnd   = convert(smalldatetime,'2004.06.01')

declare
	@Year       smallint,
	@Month      tinyint,
	@BaseName   varchar(15),
	@FileName   varchar(30),
  @Serv_id    int,
  @Tarif_id   int
SELECT
	@Year     = year(@dtBegin),
	@Month    = month(@dtBegin),

	@BaseName = 'aspBase'+convert(varchar(4),@Year)+'_'+right(convert(varchar(3),100+@Month),2),
	@FileName = @BaseName+'..TarifValues',
  @Serv_id  = 13,
  @Tarif_id = 1

CREATE TABLE #TmpTarifValues (
	SERV_ID     smallint,
	YEAR_CALC   smallint,
	MONTH_CALC  smallint,
	DAY_CALC    smallint,
	TARIF_ID    smallint,
	TARIF_VALUE decimal(8,3),
  DATE_CALC   datetime)


WHILE 100*@Year+@Month<=100*year(@dtEnd)+month(@dtEnd)
BEGIN
EXEC ('
IF EXISTS (SELECT * FROM master..SysDataBases WHERE NAME='''+@BaseName+''')

INSERT #TmpTarifValues
SELECT DISTINCT
	SERV_ID,
	'+@Year+',
	'+@Month+',
	DAY_CALC,
	TARIF_ID,
	TARIF_VALUE,
  convert(datetime,convert(varchar(4),'+@Year+') +
                           ''-'' + convert(varchar(2),'+@Month+') +
                           ''-'' + convert(varchar(2),day_calc)) 
FROM '+@FileName+' (NOLOCK)
WHERE
	  SUPPL_ID = 600
and SERV_ID  ='+@Serv_id+'
and TARIF_ID = '+@Tarif_id+'
')

IF @Month=12 SELECT @Month=0,@Year=@Year+1
SELECT
	@Month=@Month+1,
	@BaseName='aspBase'+convert(varchar(4),@Year)+'_'+right(convert(varchar(3),100+@Month),2),
	@FileName=@BaseName+'..TarifValues'
END

/*
select distinct tarif_value = convert(decimal(12,4),tarif_value),
       day_calc = min(date_calc),
       serv_id
from #TmpTarifValues
group by serv_id, tarif_value
order by min(date_calc) asc
*/
select * from #TmpTarifValues


DROP TABLE #TmpTarifValues


select * from aspBase2004_06..TarifValues
where day_calc <> 1