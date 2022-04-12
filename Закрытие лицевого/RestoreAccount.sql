----------------------------------------------------------------------
-- ������ ��������� ��������� ��������� ������������� �
-- ������� SumServices ����� tarif_id � serv_signs
-- � ���������� �� ������� ��������. �.�. ����������
-- ��������� ���������.
----------------------------------------------------------------------
declare
  @mask_ss_delete         int,
  @account_id             int, -- ����� �������� �����
  @user_id                int, -- id ����� ������������ ��������
  @label_number           int, -- label_number ��������� ���������

  @ActionId               tinyint,     --��� ��������
  @TableId                int,         --��� �������
  @AddKeys                varchar(80), --���������� �����
  @FieldName              varchar(30), --�������� ����,
  @FieldId                int,         --��� ����
  @FieldValue             varchar(80),  --�������� ����,
  @Status                 int  -- ��������� ���������� �������� ���������


select @account_id = 10014, -- :pAccointId
       @user_id    = 612    -- :pUserId

select @mask_ss_delete = convert(int,const_value)
from   Const
where  const_name = 'MASK_SS_DELETE'

select  @ActionId = 2

select @TableId = table_id
from Tables
where table_name = 'SumServices'


select @label_number = label_number
from EditLabels
where date_time_begin = (select max(date_time_begin)
                         from EditLabels
                         where label_number in (select distinct label_number
                                                from EditRecords
                                                where table_id = @TableId -- table_id of SumServices
                                                  and field_id in (4,5)   -- tarif_id, serv_signs
                                                  and account_id = @account_id
                                                  and convert(int,add_keys) in (13,23)
                                                )
                         )

--select @label_number
-- ��� ��������� ������� SumServices ������������ ���������
-- pInsertService. ��� �� ������� ������� ����� �����������
-- ��������� ������� #t_InsertServices

-- �������� ��������� ������� #t_InsertServices
IF OBJECT_ID ('tempdb..#t_InsertServices') IS NOT NULL
	DROP TABLE #t_InsertServices
CREATE TABLE #t_InsertServices
              (ACCOUNT_ID	 int,
		           SERV_ID		 tinyint,
		           SUPPL_ID 	 smallint NOT NULL ,
		           TARIF_ID 	 int      NOT NULL ,
		           SERV_SIGNS	 int      NOT NULL	)

-- ��������� � ��� ������ ������� ���������� ��������
insert into #t_InsertServices
  select
        account_id,
        serv_id,
        suppl_id,
        tarif_id,
        serv_signs
  from
        SumServices  (nolock)
  where
        account_id = @account_id
    and serv_signs&@mask_ss_delete = @mask_ss_delete
    and suppl_id = 600
    and tarif_id = 0
    and serv_id in (select distinct convert(int,add_keys)
                    from EditRecords
                    where label_number = @label_number)


-- ���������� ������ ��������
update #t_InsertServices
set
 serv_signs = serv_signs - @mask_ss_delete,
 tarif_id   = (select convert(int,field_value)
               from EditRecords
               where label_number = @label_number
                 and field_id = 4 -- tarif_id
                 and convert(int,add_keys)  = 13)
where  serv_id = 13

update #t_InsertServices
set
 serv_signs = serv_signs - @mask_ss_delete,
 tarif_id   = (select convert(int,field_value)
               from EditRecords
               where label_number = @label_number
                 and field_id = 4 -- tarif_id
                 and convert(int,add_keys)  = 23)
where  serv_id = 23


-- �������� ��������� � SumServices-----
exec pInsertService  @user_id, 600

drop table #t_InsertServices


------------------------------------------
/*
select  account_id,
        serv_id,
        suppl_id,
        tarif_id,
        serv_signs
from    SumServices  (nolock)
where   account_id = @account_id
    and suppl_id = 600
    and serv_id in (13,23)
*/
-----------------------------------------------
-- ������������ ������������� � ���� aspElectric
-- 1) ������� ������� label_number ��������� ��������
select
@label_number = label_number
from EditLabels (nolock)
where date_time_begin = (select max(date_time_begin)
                         from EditLabels (nolock)
                         where label_number in (select distinct label_number
                                                from EditRecords (nolock)
                                                where table_id = @TableId -- table_id of SumServices
                                                  and field_id in (4,5)   -- tarif_id, serv_signs
                                                  and account_id = @account_id
                                                  and convert(int,add_keys) in (13,23)
                                                )
                         )

--2) ���� �������� �� �������������� � ��������� �� � aspElectric..EditRecords

-------------------------------------------------------
--! ����� ���������� ��������� ����, ��� � aspBase � 
--! ������� EditRecords � ���� field_value �������
--! ������ �������� � � aspElectric �����, �������
--! ���� � ������ ������������� ���������� ������.
select
      field_id,
      add_keys,
      field_value
into #TmpEdits
from
      EditRecords
where
     label_number = @label_number
 and table_id = @TableId
 and field_id in (4,5)
 and account_id = @account_id
 and convert(int,add_keys) in (13,23)

-- ������ ������ �������� �� �����
update #TmpEdits
set field_value = case TMP.field_id when 5
                                    then SS.serv_signs
                                    when 4
                                    then SS.tarif_id end
from SumServices SS (nolock),
     #TmpEdits   TMP
where SS.account_id = @account_id
  and SS.suppl_id   = 600
  and SS.serv_id    = convert(int,add_keys)

----------------------------------------------------------

declare curEdits cursor for
select
      field_id,
      add_keys,
      field_value
from
      #TmpEdits

/*if exists (select * from TempDB..sysobjects
            where id = object_id('TempDB..#TmpFixEdits'))
begin
  drop table #TmpFixEdits
end
create table #TmpFixEdits
(action_id int null,
table_id    int null,
account_id int null,
add_keys varchar(80) null,
field_name varchar(80) null,
field_value varchar(80) null,
status int null
)
*/
open curEdits
fetch next from curEdits
into @FieldId, @AddKeys, @FieldValue
while (@@fetch_status <> -1)
  begin
    select @FieldName =  field_name
    from aspElectric..TableFields
    where table_id = @TableId
      and field_id = @FieldId

    exec @Status = aspElectric..pFixEdits @ActionId,   @TableId,
                                @account_id, @AddKeys,
                                @FieldName,  @FieldValue
/*
  insert into #TmpFixEdits(action_id, table_id,
                           account_id, add_keys,
                           field_name, field_value, status)
    values (@ActionId,   @TableId,
            @account_id, @AddKeys,
            @FieldName,  @FieldValue, @Status)
*/
    fetch next from curEdits
  into @FieldId, @AddKeys, @FieldValue
  end
close curEdits
deallocate curEdits

/*
select * from #TmpFixEdits
drop table #TmpFixEdits
*/

