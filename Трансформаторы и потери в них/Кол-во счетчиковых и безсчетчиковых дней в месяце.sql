declare
  @account_id     int
 ,@dtDateBeg      datetime -- ������ ������
 ,@dtDateEnd      datetime -- ����� ������
-- ��������� ����������
 ,@last_action_id int -- ��������� �������� �� ��������
 ,@days           int -- ���-�� ���� ������ ��� ��������
 ,@CurDate        datetime -- ���������� ���� ��� ������������� � �����
 ,@CountFlag      int -- 0 - � ���� ���� ������� ���, 1 - �� ����
select  
  @account_id = 740100201

/*(select tranc_power_account_id
                                from ProAccounts
                                where account_id = 133200102)*/
 ,@dtDateEnd  = '2004-09-30'
 ,@dtDateBeg  = dateadd(mm,-1,dateadd(dd,+1,@dtDateEnd))
--<1>---------------------------------------------------
-- ������� �������� � ������� ������� 
-- ��� �������� ����������/�����������, ������/���������

if Exists (select * from TempDB..SysObjects
           where id = OBJECT_ID('TempDB..#TmpActions'))
exec('DROP TABLE #TmpActions')

select pcad.date_id
      ,pcad.action_id
      ,cal.action_name
into  #TmpActions
from  ProCntActionDates pcad (nolock)
     ,CntActionList     cal  (nolock)
     ,ProCnt            pc   (nolock)     
where pcad.action_id    = cal.action_id
  and pcad.account_id   = @account_id
  and pcad.delete_sign  = 0
  and pcad.action_id   in (1,10,7,8,2) -- 2 - ������
  and date_id          <= @dtDateEnd 
  and pcad.account_id = pc.account_id
  and pcad.counter_number_id = pc.counter_number_id
order by pcad.date_id

--<2>----------------------------------------------
-- ���������� ����� ���� ��������� ��������
select @last_action_id = action_id
from #TmpActions
where date_id = (select max(date_id)
                 from #TmpActions)
-- ���� �� ����� ������ ������� ���� ��� �������� ��������
-- ������� ��� � ��� ���� ����� ��� �����/��������� �.� �� �����
-- ������� ������� ��� � �������
select @CurDate  = case when @last_action_id in (1,8,2) -- �����������, ���������
                        then @dtDateEnd 
                        when @last_action_id in (10,7) -- ����������, ������
                        then (select max(date_id) from #TmpActions)
                        end
select @days = 0
select @last_action_id = 0
select @CountFlag = 1

while @CurDate >= @dtDateBeg 
  begin
  select @last_action_id =isnull((select action_id
                                  from #TmpActions
                                  where date_id = @CurDate),@last_action_id)
  select
  @CountFlag = case when @last_action_id in (1,8,2)  then 0 
                    when @last_action_id in (10,7) then 1
                    else @CountFlag end
  select @days = case when @CountFlag = 1 then @days + 1
                      when @CountFlag = 0 then @days end
  select @CurDate = dateadd(dd,-1,@CurDate) 
  end

select CntDays   = @days
      ,NoCntDays = (datediff(dd,@dtDateBeg,@dtDateEnd)+1) - @days
      ,AllDays   = datediff(dd,@dtDateBeg,@dtDateEnd)+1

drop table #TmpActions

