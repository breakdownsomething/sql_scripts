-- REQUEST
/*Вывод @siRowCount записей из списка лицевых счетов, упорядоченного
по № телефона до или после (в зависимости от @bUpMode) тел. №  @iCode*/
DECLARE
        @bUpMode     bit,
        @siRowCount  smallint,
        @iCode       int,
        @siGroupElectric smallint
SELECT
        @bUpMode=:pUpMode,
        @siRowCount=:pRowCount,
        @iCode=:pCode
SELECT
        @siGroupElectric=CONVERT(smallint,CONST_VALUE)
FROM
        Const (NOLOCK)
WHERE
        CONST_NAME='GROUP_ELECTRIC'
TRUNCATE  TABLE #reqServicesList
SET ROWCOUNT @siRowCount
IF(@bUpMode=0)
BEGIN
/*Режим прокрутки вниз*/
	INSERT
		#reqAccountsList
	SELECT
	        A.ACCOUNT_ID,
	        A.ACCOUNT_NAME,
		A.STREET_ID,
		STREET=
		(SELECT
			SPACE(5-LEN(STR(S.STREET_ID,5)))+STR(S.STREET_ID,5)+' '+
			(CASE STREET_NAME
			WHEN NULL THEN ''
			ELSE STREET_NAME
			END)+' '+ISNULL(ST.STREET_TYPE_SHORT_NAME,'')+' '+
			(CASE	S.TOWN_ID
			WHEN	0	THEN	''
			ELSE
			T.TOWN_NAME
			END)
		FROM
	        	Streets	             S   (NOLOCK),
			StreetTypes	     ST  (NOLOCK),
			Towns		     T   (NOLOCK)
		WHERE
	        	S.STREET_ID=A.STREET_ID		    AND
	        	ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
	        	T.TOWN_ID=S.TOWN_ID),
	        A.HOUSE_ID,
                NULL,
	        A.FLAT_NUMBER,
        	P.PHONE,
		HOUSE_MANAGE=
        	(SELECT
			SPACE(5-LEN(STR(AG.GROUP_ID,5)))+STR(AG.GROUP_ID,5)+' '+
			G.GROUP_NAME
		FROM
        		AccountGroups        AG  (NOLOCK),
        		Groups               G   (NOLOCK)
		WHERE
        		AG.ACCOUNT_ID=A.ACCOUNT_ID         AND
	        	G.GROUP_ID=AG.GROUP_ID              AND
			G.GROUP_ID<10000),
		SUBGROUP_ID=
		(SELECT
	      		AG1.SUBGROUP_ID
		FROM
	      		AccountGroups   AG1(NOLOCK)
		WHERE
		        AG1.ACCOUNT_ID=A.ACCOUNT_ID AND
	   	        AG1.GROUP_ID=@siGroupElectric),
       		POST_INDEX_ID=
		(SELECT
	        	(CASE
	        	WHEN  H.POST_INDEX_ID IS NULL  THEN     A.POST_INDEX_ID
	        	ELSE  H.POST_INDEX_ID
	        	END)
		FROM
			Houses               H   (NOLOCK)
		WHERE
	        	H.STREET_ID=A.STREET_ID           AND
	        	H.HOUSE_ID=A.HOUSE_ID
		),
	        A.QUANTITY_PEOPLE,
	        A.ALL_SQUARE,
	        A.QUANTITY_ROOM,
	        A.FLOOR
	FROM
		Phones		     P(FASTFIRSTROW NOLOCK),
	        Accounts             A(FASTFIRSTROW NOLOCK)
	WHERE
		P.PHONE>=@iCode		AND
	  	A.ACCOUNT_ID=P.ACCOUNT_ID
	ORDER	BY
		P.PHONE
END
ELSE
/*Режим прокрутки вверх*/
BEGIN
	INSERT
		#reqAccountsList
	SELECT
	        A.ACCOUNT_ID,
	        A.ACCOUNT_NAME,
		A.STREET_ID,
		STREET=
		(SELECT
			SPACE(5-LEN(STR(S.STREET_ID,5)))+STR(S.STREET_ID,5)+' '+
			(CASE STREET_NAME
			WHEN NULL THEN ''
			ELSE STREET_NAME
			END)+' '+ISNULL(ST.STREET_TYPE_SHORT_NAME,'')+' '+
			(CASE	S.TOWN_ID
			WHEN	0	THEN	''
			ELSE
			T.TOWN_NAME
			END)
		FROM
	        	Streets	             S   (NOLOCK),
			StreetTypes	     ST  (NOLOCK),
			Towns		     T   (NOLOCK)
		WHERE
	        	S.STREET_ID=A.STREET_ID		    AND
	        	ST.STREET_TYPE_ID=*S.STREET_TYPE_ID AND
	        	T.TOWN_ID=S.TOWN_ID),
	        A.HOUSE_ID,
                NULL,
	        A.FLAT_NUMBER,
        	P.PHONE,
		HOUSE_MANAGE=
        	(SELECT
			SPACE(5-LEN(STR(AG.GROUP_ID,5)))+STR(AG.GROUP_ID,5)+' '+
			G.GROUP_NAME
		FROM
        		AccountGroups        AG  (NOLOCK),
        		Groups               G   (NOLOCK)
		WHERE
        		AG.ACCOUNT_ID=A.ACCOUNT_ID         AND
	        	G.GROUP_ID=AG.GROUP_ID              AND
			G.GROUP_ID<10000),
		SUBGROUP_ID=
		(SELECT
	      		AG1.SUBGROUP_ID
		FROM
	      		AccountGroups   AG1(NOLOCK)
		WHERE
		        AG1.ACCOUNT_ID=A.ACCOUNT_ID AND
	   	        AG1.GROUP_ID=@siGroupElectric),
       		POST_INDEX_ID=
		(SELECT
	        	(CASE
	        	WHEN  H.POST_INDEX_ID IS NULL  THEN     A.POST_INDEX_ID
	        	ELSE  H.POST_INDEX_ID
	        	END)
		FROM
			Houses               H   (NOLOCK)
		WHERE
	        	H.STREET_ID=A.STREET_ID           AND
	        	H.HOUSE_ID=A.HOUSE_ID
		),
	        A.QUANTITY_PEOPLE,
	        A.ALL_SQUARE,
	        A.QUANTITY_ROOM,
	        A.FLOOR
	FROM
		Phones		     P(FASTFIRSTROW NOLOCK),
	        Accounts             A(FASTFIRSTROW NOLOCK)
	WHERE
		P.PHONE<=@iCode		AND
	  	A.ACCOUNT_ID=P.ACCOUNT_ID
	ORDER	BY
		P.PHONE	DESC
END
SET ROWCOUNT 0
INSERT
	#reqServicesList
SELECT
      SS.ACCOUNT_ID,
      SS.SERV_ID,
      SERV=SPACE(3-LEN(STR(SS.SERV_ID,3)))+STR(SS.SERV_ID,3)+' '+
      ST.SERV_NAME,
      SS.SUPPL_ID,
      SUPPL=SPACE(5-LEN(STR(SS.SUPPL_ID,5)))+STR(SS.SUPPL_ID,5)+' '+
      (SELECT
             SSI.SUPPL_NAME
      FROM
             ServiceSupplInfo SSI(NOLOCK)
      WHERE
             SSI.SUPPL_ID=SS.SUPPL_ID    AND
             SSI.DAY=
             (SELECT
                     MAX(SSI1.DAY)
             FROM
                     ServiceSupplInfo SSI1(NOLOCK)
             WHERE
                     SSI1.SUPPL_ID=SSI.SUPPL_ID
             )
      ),
      SS.TARIF_ID,
      TV.TARIF_VALUE,
      SS.SUM_SALDO,
      SS.SUM_CALC,
      SS.SERV_SIGNS
FROM
	#reqAccountsList	tA,
	SumServices	        SS(NOLOCK),
        ServiceTypes            ST(NOLOCK),
        TarifValues             TV(NOLOCK)
WHERE
	SS.ACCOUNT_ID=tA.ACCOUNT_ID         AND
        ST.SERV_ID=SS.SERV_ID               AND
        TV.SERV_ID=SS.SERV_ID               AND
        TV.SUPPL_ID=SS.SUPPL_ID             AND
        TV.TARIF_ID=SS.TARIF_ID
SELECT
	*
FROM
	#reqAccountsList
ORDER	BY
	PHONE
TRUNCATE TABLE #reqAccountsList

 