declare
@new_tranc_power_id int
select @new_tranc_power_id = max(tranc_power_id) + 1
                             from ProTrancPowerList

insert into ProTrancPowerList (tranc_power_id
                              ,tranc_power_name
                              ,tranc_power_capacity
                              ,comment
                              )
                       values (
                              @new_tranc_power_id
                              ,'New Pransformer'
                              ,1000
                              ,'Test Record'
                              )    
--alter table ProTrancPowerList disable trigger  trProTrancPowerListIns
select * from ProTrancPowerList

alter table ProTrancPowerList disable trigger  trProTrancPowerListDel
delete from ProTrancPowerList where tranc_power_id = 28