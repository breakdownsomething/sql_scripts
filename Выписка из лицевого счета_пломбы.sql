Declare
  @vcBaseName   varchar (14)
 ,@iAccount_id  int
 ,@vcMaxDate    varchar (50)
 ,@siYear       smallint
 ,@tiMonth      tinyint
 ,@MaxDate      smalldatetime

/*
select
  @iAccount_id = :pAccount_id,
  @vcMaxDate   = :pMaxDate
*/

Select  @iAccount_id = 2301164
       ,@vcMaxDate   = '10.02.2004'

Select @siYear  = Year  (Convert (datetime, @vcMaxDate, 104))
      ,@tiMonth = Month (Convert (datetime, @vcMaxDate, 104))
      ,@MaxDate = Convert (datetime, @vcMaxDate, 104)

if (@siYear * 100 + @tiMonth) > (Select (year * 100 + month) From aspCommon..YearMonth)
  Begin
    Select @siYear  = Year
          ,@tiMonth = Month
    From aspCommon..YearMonth
  end

Select @vcBaseName = Base_Prefix + convert (char (4), @siyear)
                                 + '_'
                                 + substring (Convert(char(3), 100 + @tiMonth), 2, 2)
From aspCommon..YearMonth

Exec ('
Declare
   @tiSealingAct tinyint
  ,@tiDelSealAct tinyint

Select @tiSealingAct = Const_Value From ' + @vcBaseName + '..const
 Where Const_name = ''Cnt_Action_Seals''       --Действие - Пломбирование
Select @tiDelSealAct = Const_Value From ' + @vcBaseName + '..const
 Where Const_name = ''Cnt_Action_DeleteSeals'' --Действие - Распломбирование

------------------------------------------------------
Select CS.Date_id
      ,CS.Seal_Number
      ,CSP.Seal_Place_Name
      ,CAI.Check_Count
      ,CAI.Serv_Id

From   aspElectric..CntSeals              CS (nolock)
      ,aspElectric..CntSealPlaces        CSP (nolock)
      ,aspElectric..CntActionIndications CAI (nolock)

Where CS.Account_id    = ' + @iAccount_Id+ '
  and CS.Action_id     = @tiSealingAct
  and CS.Date_id      <= Convert (DateTime, ''' + @vcMaxDate+ ''', 104)
  and not exists (Select *
                  From aspElectric..CntSeals  CS1 (nolock)
                  Where CS1.Account_id           = CS.Account_id
                    and CS1.Counter_Number_id    = CS.Counter_Number_id
                    and CS1.Seal_Place_id        = CS.Seal_Place_id
                    and CS1.Seal_Place_Number_id = CS.Seal_Place_Number_id
                    and CS1.Seal_Number          = CS.Seal_Number
                    and CS1.Action_id            = @tiDelSealAct
                    and CS1.Date_id             <= Convert (DateTime, ''' + @vcMaxDate+ ''', 104))
-- CntSeals <=> CntSealPlaces
  and CS.Seal_Place_id = CSP.Seal_Place_id
-- CntSeals <=> CntActionIndications
  and CS.Account_id    = CAI.Account_id
  and CS.Counter_Number_id = CAI.Counter_Number_id
  and CS.Date_id       = CAI.Date_id
')