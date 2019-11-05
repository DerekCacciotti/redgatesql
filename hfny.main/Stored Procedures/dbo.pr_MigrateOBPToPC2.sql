SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[pr_MigrateOBPToPC2]  (@TargetCaseFK int)
---- Migrate a single cases' OBP to PC2
---- see bottom of function for original code and related queries
as 
begin

if exists(select * from tempdb.dbo.sysobjects where id=object_id(N'tempdb..#CaseListToBeMigrated'))
	-- where charindex('#',name)>0 order by name
	drop table #CaseListToBeMigrated

print 'Select HVCase row'
select HVCasePK,OBPFK 
into #CaseListToBeMigrated 
from HVCase h
inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
where HVCasePK=@TargetCaseFK

print 'Update CommonAttributes - switch FU-OBPs to FU-PC2'
update CommonAttributes
set FormType='FU-PC2'
from CommonAttributes ca
inner join #CaseListToBeMigrated cltbm on ca.HVCaseFK=cltbm.HVCasePK
where FormType='FU-OBP'

print 'Update CommonAttributes - switch IN-OBPs to IN-PC2'
update CommonAttributes
set FormType='IN-PC2'
from CommonAttributes ca
inner join #CaseListToBeMigrated cltbm on ca.HVCaseFK=cltbm.HVCasePK
where FormType='IN-OBP'

print 'Update FatherFigure - switch IsPC2 and IsOBP flags'
update FatherFigure
set IsPC2=IsOBP, 
	IsOBP=0
from FatherFigure ff
inner join #CaseListToBeMigrated cltbm on ff.HVCaseFK=cltbm.HVCasePK
where ff.RelationToTargetChild='01'

--print 'Update CommonAttributes - switch OBPInHome to PC2InHome'
--update CommonAttributes
--set PC2InHome=OBPInHome 
--from CommonAttributes ca
--inner join #CaseListToBeMigrated cltbm on ca.HVCaseFK=cltbm.HVCasePK and ca.FormType='FU-PC2'
--inner join FollowUp fu on ca.FormFK=FollowUpPK

--print 'Update FollowUp - set OBPInHome to No'
--update FollowUp
--set OBPInHome='0'
--from FollowUp fu
--inner join #CaseListToBeMigrated cltbm on fu.HVCaseFK=cltbm.HVCasePK

print 'Update HVLog - switch OBPParticipated to PC2Participated and set OBPParticipated to no'
update HVLog
set PC2Participated=OBPParticipated,
	OBPParticipated=0
from HVLog h
inner join #CaseListToBeMigrated cltbm on h.HVCaseFK=cltbm.HVCasePK

print 'Update PC - reverse PC2 and OBP flags'
update PC
set PC2=1,
	OBP=0
from PC p
inner join #CaseListToBeMigrated cltbm on p.PCPK=cltbm.OBPFK

print 'Update HVCase - switch all flags and values from OBP to PC2 and clear OBP flags and values'
update HVCase
set PC2FK=h.OBPFK,
	OBPFK=null,
	PC2inHomeIntake=OBPinHomeIntake,
	OBPinHomeIntake=null,
	OBPRelation2TC=null
from HVCase h
inner join #CaseListToBeMigrated cltbm on h.HVCasePK=cltbm.HVCasePK

print 'Update Education - switch OBP rows to PC2'
update Education
set PCType='PC2'
from Education e
where PCType='OBP' and e.HVCaseFK in (select HVCasePK from #CaseListToBeMigrated cltbm)

print 'Update Employment - switch OBP rows to PC2'
update Employment
set PCType='PC2'
from Employment e
where PCType='OBP' and e.HVCaseFK in (select HVCasePK from #CaseListToBeMigrated cltbm)


;-- part 2 - add ID Contact rows to common attributes using the no longer used OBPInHomeIntake column to set the OBPInHome column
--with cteCasesAtCP9
--as (select HVCasePK, ProgramFK, IntakeDate, OBPinHomeIntake, ScreenDate, KempeDate, CaseStartDate
--	from HVCase h 
--	inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
--	where CaseProgress>=9)

--insert into CommonAttributes (CommonAttributesCreateDate, CommonAttributesCreator, FormDate, FormInterval, FormType, HVCaseFK, OBPInHome, ProgramFK)
--			select current_timestamp, 'HFNYConv', isnull(IntakeDate, isnull(KempeDate, isnull(ScreenDate, CaseStartDate))), '1', 'ID', HVCasePK, OBPinHomeIntake, ProgramFK
--			from cteCasesAtCP9

-- select HVCasePK,PC2FK -- ,PC1FK,PC2Relation2TC
-- into #CaseListToBeMigrated 
-- from HVCase h
-- inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
-- where HVCasePK=@TargetCaseFK
--			PC2FK is not null
--			and PC2Relation2TC='01'
--			and ProgramFK=2

-- The select below had to be changed after running the update the first time, i.e. PC2FK already updated in HVCase.
-- Using a freshly converted database, the first select should be used.

--select HVCasePK,PC2FK -- ,PC1FK,PC2Relation2TC
--into #CaseListToBeMigrated 
--from HVCase h
--where OBPFK is not null

--select * 
--from #CaseListToBeMigrated cltbm

--select * from FatherFigure ff
--inner join #CaseListToBeMigrated cltbm on ff.HVCaseFK=cltbm.HVCasePK

--select *
--from FollowUp fu
--inner join #CaseListToBeMigrated cltbm on fu.HVCaseFK=cltbm.HVCasePK

--select distinct FormType
--from CommonAttributes ca
--where FormType like '%pc2' or FormType like '%obp'

--with cteCaseListToBeMigrated as
--	(
--	),
end
GO
