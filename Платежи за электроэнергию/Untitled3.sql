DECLARE
	@vcGroupId	varchar(10),
	@vcServId	varchar(20),
	@vcSupplId	varchar(10),
	@vcParamIn	varchar(30),
	@vcDateId	varchar(20),
	@vcTableName    varchar(35),
	@vcCurBase      varchar(35),
	@vcBasePrefix   varchar(35),
	@vcYear         varchar(5),
	@vcMonth        varchar(5),
	@vcInfrServId	varchar(5),
 	@vcRVPServId	varchar(5),
 	@vcSCServId	varchar(5),
 	@vcTarif	varchar(15),
	@vcSiteId	varchar(5)
SELECT
	@vcGroupId	= '10001',--    :pGroupId,
	@vcServId	=   '(13,23,24,29)',--    :pServId,
	@vcSupplId	= '600',--    :pSupplId,
	@vcParamIn	= '(1)',--    :pParamIn,
	@vcSiteId	= IsNull(''/*:pSiteId*/,''),
	@vcBasePrefix = 'aspBase',--  :pBasePrefix,
	@vcDateId	=     '2004-05-01',--  :pDateId,
	@vcYear 	=     '2004',--  :pYear,
	@vcMonth	=     '05',--  :pMonth,
	@vcInfrServId	= '24',-- :pInfrServId,
	@vcSCServId	=   '86',--  :pSecondC,
	@vcRVPServId	= '29',--  :pRVPServId,
        @vcTarif	= '1'--:pTarif
SELECT
      @vcCurBase=@vcBasePrefix+@vcYear+'_'+@vcMonth+'..'
EXEC("
DECLARE
	@sdtMinDate	smalldatetime,
	@sdtMaxDate	smalldatetime
SELECT
	@sdtMinDate	=CONVERT(smalldatetime,'"+@vcDateId+"')
SELECT
	@sdtMaxDate	=DATEADD(mi,-1,DATEADD(mm,1,@sdtMinDate))

--Print 'Create #Sites'

CREATE Table #Sites
(	SUBGROUP_ID SmallInt,
        SITE_ID VarChar(3),
	ACCOUNT_ID Int
   Primary Key (SUBGROUP_ID,SITE_ID,ACCOUNT_ID))

IF '"+@vcSiteId+"' <> ''
BEGIN

INSERT #Sites
(       SUBGROUP_ID,
        SITE_ID,
	ACCOUNT_ID)
SELECT
  IsNull(AG.SUBGROUP_ID,-1),
  IsNull(Str(NS.SITE_ID,3),'???'),
  AG.ACCOUNT_ID
 FROM
	"+@vcCurBase+"AccountGroups AG (NOLOCK),
	aspElectric..CntElectricity CE (NoLock),
	aspElectric..ElectNodeSites NS (NoLock)
 WHERE
  CE.ACCOUNT_ID=AG.ACCOUNT_ID AND
  NS.NODEID=*CE.NODEID AND
  NS.SUBGROUP_ID=*AG.SUBGROUP_ID AND
  AG.GROUP_ID= "+@vcGroupId+" AND
  AG.SUBGROUP_ID IN "+@vcParamIn+"
/*
 Select
   *
  From
   #Sites
*/
END

CREATE Table #Rcp
(
	RECIEPT_ID	         int	IDENTITY,
	DATE_ID		         smalldatetime,
	LABEL_NUMBER	         int,
	RECIEPT_NUMBER	         smallint
)

INSERT #Rcp
(
	DATE_ID,
	LABEL_NUMBER,
	RECIEPT_NUMBER
)
SELECT
	R.DATE_ID,
	R.LABEL_NUMBER,
	R.RECIEPT_NUMBER
FROM
	aspElectric..Rcp			R	(NOLOCK),
	"+@vcCurBase+"AccountGroups		AG	(NOLOCK)
WHERE
        ( '"+@vcSiteId+"' = ''  OR
        Exists(
        SELECT
          S.ACCOUNT_ID
         FROM
          #Sites S (Nolock)
         WHERE
          S.ACCOUNT_ID=AG.ACCOUNT_ID AND
          S.SITE_ID='"+@vcSiteId+"'AND
          S.SUBGROUP_ID=AG.SUBGROUP_ID
        )) AND
	R.DATE_ID BETWEEN @sdtMinDate	                	AND
		          @sdtMaxDate                           AND
	AG.ACCOUNT_ID=R.ACCOUNT_ID				AND
	AG.GROUP_ID="+@vcGroupId+"				AND
	AG.SUBGROUP_ID IN "+@vcParamIn+"			AND
	EXISTS(SELECT
			*
		FROM
			aspElectric..DayRcpPays	DRP	(NOLOCK)
		WHERE
			DRP.DATE_ID=R.DATE_ID			AND
			DRP.LABEL_NUMBER=R.LABEL_NUMBER		AND
			DRP.RECIEPT_NUMBER=R.RECIEPT_NUMBER	AND
			DRP.SERV_ID IN "+@vcServId+"            AND
			DRP.SUPPL_ID="+@vcSupplId+")

CREATE Table	#Result(
			 DAY			tinyint,
			 COUNT_RCP   		int,
			 COUNT_PAY		int,
			 SUM_PAY		decimal(12,2),
			 COUNT_INFRINGEMENT	int,
            SUM_INFR_PAY		decimal(12,2),
			 COUNT_RVP		int,
            SUM_RVP_PAY		decimal(12,2),
            SUM_ALL		decimal(12,2),
            qnt_infr_pay int,
            qnt_rvp_pay  int
            )
WHILE @sdtMinDate<=@sdtMaxDate
BEGIN
INSERT INTO
	#Result
SELECT
	DATEPART(dd,tR.DATE_ID),
	COUNT_RCP          = SUM(CASE WHEN NOT DRP.SERV_ID IN ("+@vcInfrServId+", "+@vcRVPServId+","+@vcSCServId+")
                                THEN 1
                                ELSE 0 END),
	COUNT_PAY          = SUM(CASE WHEN DRP.SERV_ID IN ("+@vcInfrServId+", "+@vcRVPServId+","+@vcSCServId+")
			                          THEN 0
	        	                    ELSE DRP.COUNT_PAY END),
	SUM_PAY            = SUM(CASE WHEN DRP.SERV_ID IN ("+@vcInfrServId+", "+@vcRVPServId+","+@vcSCServId+")
			                          THEN 0
	          	                  ELSE DRP.SUM_PAY	END),
	COUNT_INFRINGEMENT = SUM(CASE WHEN DRP.SERV_ID="+@vcInfrServId+"
                                THEN 1
                                ELSE 0 END),
	SUM_INFR_PAY       = SUM(CASE WHEN DRP.SERV_ID="+@vcInfrServId+"
				                        THEN DRP.SUM_PAY
	    		                      ELSE 0 END),
	COUNT_RVP          = SUM(CASE WHEN DRP.SERV_ID IN ("+@vcRVPServId+","+@vcSCServId+")
                                THEN 1
                                ELSE 0 END),
	SUM_RVP_PAY        = SUM(CASE	WHEN DRP.SERV_ID IN ("+@vcRVPServId+","+@vcSCServId+")
		                        	  THEN DRP.SUM_PAY
	    		                     	ELSE 0 END),
	SUM_ALL            = SUM(DRP.SUM_PAY),

  qnt_infr_pay       = SUM(CASE WHEN DRP.SERV_ID="+@vcInfrServId+"
				                        THEN DRP.COUNT_PAY
	    		                      ELSE 0 END),
  qnt_rvp_pay        = SUM(CASE	WHEN DRP.SERV_ID IN ("+@vcRVPServId+","+@vcSCServId+")
		                        	  THEN DRP.COUNT_PAY
	    		                     	ELSE 0 END)
FROM
	#Rcp			tR	(NOLOCK),
	aspElectric..DayRcpPays	DRP	(NOLOCK)
WHERE
	tR.DATE_ID=@sdtMinDate			AND
	DRP.DATE_ID=tR.DATE_ID			AND
	DRP.LABEL_NUMBER=tR.LABEL_NUMBER	AND
	DRP.RECIEPT_NUMBER=tR.RECIEPT_NUMBER	AND
	DRP.SERV_ID IN "+@vcServId+"		AND
	DRP.SUPPL_ID="+@vcSupplId+"
GROUP BY
	tR.DATE_ID

SELECT
	@sdtMinDate	=DATEADD(dd,1,@sdtMinDate)
END
SELECT
	day
 ,count_rcp
 ,count_pay
 ,sum_pay
 ,count_infringement
 ,sum_infr_pay
 ,count_rvp
 ,sum_rvp_pay
 ,sum_all
-------------------
 ,qnt_infr_pay
 ,qnt_rvp_pay
---------------------
-- ,SUM_ALLK = convert(int, COUNT_PAY + (SUM_RVP_PAY + SUM_INFR_PAY) / " + @vcTarif + ")
 ,SUM_ALLK = convert(int,count_pay + qnt_infr_pay + qnt_rvp_pay)
FROM
	#Result

DROP Table #Rcp
DROP Table #Result
DROP Table #Sites
")
