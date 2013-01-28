SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[pr_MigratePC2ToOBP]  (@TargetCaseFK int)
---- Migrate a single cases' PC2 to OBP 
---- see bottom of function for original code and related queries
as 
begin

if exists(select * from tempdb.dbo.sysobjects where id=object_id(N'tempdb..#CaseListToBeMigrated'))
	-- where charindex('#',name)>0 order by name
	drop table #CaseListToBeMigrated

select HVCasePK,PC2FK 
into #CaseListToBeMigrated 
from HVCase h
inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
where HVCasePK=@TargetCaseFK

update CommonAttributes
set FormType='FU-OBP'
from CommonAttributes ca
inner join #CaseListToBeMigrated cltbm on ca.HVCaseFK=cltbm.HVCasePK
where FormType='FU-PC2'

update CommonAttributes
set FormType='IN-OBP', 
	OBPInHome='1'	
from CommonAttributes ca
inner join #CaseListToBeMigrated cltbm on ca.HVCaseFK=cltbm.HVCasePK
where FormType='IN-PC2'

update FatherFigure
set IsOBP=IsPC2, 
	IsPC2=0
from FatherFigure ff
inner join #CaseListToBeMigrated cltbm on ff.HVCaseFK=cltbm.HVCasePK
where ff.RelationToTargetChild='01'

update CommonAttributes
set OBPInHome=PC2InHome 
from CommonAttributes ca
inner join #CaseListToBeMigrated cltbm on ca.HVCaseFK=cltbm.HVCasePK and ca.FormType='FU-OBP'
inner join FollowUp fu on ca.FormFK=FollowUpPK

update FollowUp
set PC2InHome='0'
from FollowUp fu
inner join #CaseListToBeMigrated cltbm on fu.HVCaseFK=cltbm.HVCasePK

update HVLog
set OBPParticipated=PC2Participated,
	PC2Participated=0
from HVLog h
inner join #CaseListToBeMigrated cltbm on h.HVCaseFK=cltbm.HVCasePK

update PC
set OBP=1,
	PC2=0
from PC p
inner join #CaseListToBeMigrated cltbm on p.PCPK=cltbm.PC2FK

update HVCase
set OBPFK=h.PC2FK,
	PC2FK=null,
	OBPinHomeIntake=PC2inHomeIntake,
	PC2inHomeIntake=null,
	PC2Relation2TC=null,
	PC2Relation2TCSpecify=null,
	OBPInformationAvailable=1,
	DateOBPAdded=h.IntakeDate
from HVCase h
inner join #CaseListToBeMigrated cltbm on h.HVCasePK=cltbm.HVCasePK

update HVCase
set OBPInformationAvailable=0
from HVCase h
where h.HVCasePK not in (select HVCasePK from #CaseListToBeMigrated cltbm)
		and h.CaseProgress >= 9
		
update Education
set PCType='OBP'
from Education e
where PCType='PC2' and e.HVCaseFK in (select HVCasePK from #CaseListToBeMigrated cltbm)

update Employment
set PCType='OBP'
from Employment e
where PCType='PC2' and e.HVCaseFK in (select HVCasePK from #CaseListToBeMigrated cltbm)


;-- part 2 - add ID Contact rows to common attributes using the no longer used OBPInHomeIntake column to set the OBPInHome column
with cteCasesAtCP9
as (select HVCasePK, ProgramFK, IntakeDate, OBPinHomeIntake, ScreenDate, KempeDate, CaseStartDate
	from HVCase h 
	inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
	where CaseProgress>=9)

insert into CommonAttributes (CommonAttributesCreateDate, CommonAttributesCreator, FormDate, FormInterval, FormType, HVCaseFK, OBPInHome, ProgramFK)
			select current_timestamp, 'HFNYConv', isnull(IntakeDate, isnull(KempeDate, isnull(ScreenDate, CaseStartDate))), '1', 'ID', HVCasePK, OBPinHomeIntake, ProgramFK
			from cteCasesAtCP9

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
