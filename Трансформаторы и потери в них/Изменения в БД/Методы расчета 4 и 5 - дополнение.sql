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
'[4] - �� ��������� � �������������',
'������=������.������ * 0.025'
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
'[5] - �� ��������� � ���. � �����.',
'������=������.������+(����������������� ��� ���������)*0.025'
)

update ProTrancPowerMethods
set comment = '������=���������, ������ �� �����������'
where tranc_power_method_id = 1

update ProTrancPowerMethods
set comment = '������=���.+(���.�����. ��� ���.), ������ �� ���-��'
where tranc_power_method_id = 2

update ProTrancPowerMethods
set comment = '������ = Const'
where tranc_power_method_id = 3

alter table ProTrancPowerMethods enable trigger trProTrancPowerMethodsIns
alter table ProTrancPowerMethods enable trigger trProTrancPowerMethodsUpd

select * from ProTrancPowerMethods