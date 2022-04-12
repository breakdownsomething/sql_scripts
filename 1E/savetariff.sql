declare
  @row_id         int,
  @tariff_id      int,

  @old_row_id     int,
  @old_list_codes varchar(255),
  @position       int,
  @left_string    varchar(255),
  @right_string   varchar(255),
  @mask_tariff_id varchar(6)

select
  @row_id  = 230,
  @tariff_id  = 69

select @mask_tariff_id = '% '+convert(varchar(4),@tariff_id)+',%'

-- <1> сначала удаляем номер выбранного тарифа
-- из группы (или групп), к которой он принадлежал раньше

declare curSource cursor static for
  select row_id, list_codes
  from SOURCE_1E
  where list_codes like @mask_tariff_id
open curSource
fetch next from curSource into @old_row_id, @old_list_codes
while (@@fetch_status<>-1)
  begin
  select @position = patindex(@mask_tariff_id,@old_list_codes)     
  select @left_string  = substring(@old_list_codes,0,@position)
  select @right_string  = substring(@old_list_codes,
                                   (@position+len(@mask_tariff_id)-1)
                                  ,(len(@old_list_codes)-len(@left_string)))

  select @left_string,@right_string

  update SOURCE_1E
  set list_codes = @left_string+' '+@right_string
  where row_id = @old_row_id
  fetch next from curSource into @old_row_id, @old_list_codes
  end
close curSource
deallocate curSource

-- <2> занесение тарифа в новую группу
update SOURCE_1E
set list_codes = case when (select list_codes
                            from SOURCE_1E
                            where row_id = @row_id) is null
                      then ' '+ convert(varchar(4),@tariff_id)+', '
                      else list_codes + convert(varchar(4),@tariff_id)+', 'end
where row_id = @row_id


--230 --69


--select * from SOURCE_1E where list_codes like ('%69,%')

/*
update
Source_1E
set list_codes = null
where row_id =  720
*/






select * from Source_1E  where row_id in(720,230)
--select * from ProTariffs 