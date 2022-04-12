exec pCalcContract 215411, 1, 612




alter table ProCntCounts disable trigger trProCntCountsUpd
alter table ProCalcs disable trigger trProCalcsUpd
alter table ProCalcDetails disable trigger trProCalcDetailsDel
alter table ProCalcDetails disable trigger trProCalcDetailsIns

select  *
--into #ProCalcs
 from ProCalcs where contract_id = 215411

select * from #ProCalcs

select *
into #ProCalcDetails
 from ProCalcDetails where calc_id = -8024711