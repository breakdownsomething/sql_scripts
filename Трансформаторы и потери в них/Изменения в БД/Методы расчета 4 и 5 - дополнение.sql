select * from ProTrancPowerMethods

alter table ProTrancPowerMethods disable trigger trProTrancPowerMethodsIns
alter table ProTrancPowerMethods disable trigger trProTrancPowerMethodsUpd

insert into ProTrancPowerMethods
(
tranc_power_method_id,
tranc_power_method_name,
comment
)
values
(
4,
'[4] - По основному с коэффициентом',
'Потери=Основн.Расход * 0.025'
)

insert into ProTrancPowerMethods
(
tranc_power_method_id,
tranc_power_method_name,
comment
)
values
(
5,
'[5] - По основному и доп. с коэфф.',
'Потери=Основн.Расход+(РаботаБезСчетчика или Допрасход)*0.025'
)

update ProTrancPowerMethods
set comment = 'Расход=ОснРасход, Потери из справочника'
where tranc_power_method_id = 1

update ProTrancPowerMethods
set comment = 'Расход=Осн.+(Раб.БезСч. или Доп.), Потери из спр-ка'
where tranc_power_method_id = 2

update ProTrancPowerMethods
set comment = 'Потери = Const'
where tranc_power_method_id = 3

alter table ProTrancPowerMethods enable trigger trProTrancPowerMethodsIns
alter table ProTrancPowerMethods enable trigger trProTrancPowerMethodsUpd

select * from ProTrancPowerMethods