SELECT
  AG.Account_id,
  address =  S.Street_name
             + ' '
             + A.House_id 
             + case  when A.flat_number is null 
                     then ''
                     else ' кв.'+A.flat_number end,

	SUBGROUP_ID=IsNUll(AG.SUBGROUP_ID,0),
	A.account_name
FROM
	Accounts	A(NOLOCK),
	AccountGroups AG (NOLOCK),
	Streets S (NOLOCK),
	Houses H(NOLOCK),
	SumServices SST(NOLOCK)
WHERE
	A.ACCOUNT_ID *= SST.ACCOUNT_ID AND
	S.STREET_ID = A.STREET_ID AND
	H.STREET_ID = A.STREET_ID AND
  H.HOUSE_ID = A.HOUSE_ID AND
	SST.SERV_ID=13 AND
  SST.SUPPL_ID=600	AND
	A.ACCOUNT_ID = AG.ACCOUNT_ID AND
	AG.GROUP_ID = 10001
and isnull(AG.subgroup_id,0) in (0,8)

ORDER BY
	AG.SUBGROUP_ID


/*
select 
  A.Account_id,
  address =  S.Street_name
             + ' '
             + A.House_id 
             + case  when A.flat_number is null 
                     then ''
                     else ' кв.'+A.flat_number end,
  subgroup_id = Isnull(AG.Subgroup_id,0),
  A.account_name
from AccountGroups AG (nolock),
     Accounts      A  (nolock),
     Streets       S  (nolock)
where AG.account_id = A.account_id
    and AG.group_id = 10001
    and isnull(AG.subgroup_id,0) in (0,8) 
    and isnull(A.street_id,0) <> 0
    and A.street_id = S.street_id
ORDER BY
	AG.SUBGROUP_ID
   
*/
