SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2014-07-28
-- Description:	Gets all the data needed to display the Case Home Page
-- exec rspCaseHomePage 7908
-- =============================================
create procedure [dbo].[spGetAllDataForCaseHomePage]
(
	@HVCaseFK int
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	with ctePreAssessmentCount 
	as
		(select count(PreassessmentPK) as CountOfPreassessments
			from Preassessment pa
			where HVCaseFK = @HVCaseFK
		)
	, ctePreIntakeCount
	as
		(select count(PreintakePK) as CountOfPreintakes
			from Preintake pi
			where HVCaseFK = @HVCaseFK
		)
	, cteServiceReferralCount
	as
		(select count(ServiceReferralPK) as CountOfServiceReferrals
			from ServiceReferral sr
			where HVCaseFK = @HVCaseFK
		)
	, cteHomeVisitLogCount
	as
		(select count(HVLogPK) as CountOfHomeVisitLogs
			from HVLog hl
			where HVCaseFK = @HVCaseFK
		)
	, ctePC1MedicalCount
	as
		(select count(PC1MedicalPK) as CountOfPC1MedicalForms
			from PC1Medical pm
			where HVCaseFK = @HVCaseFK
		)
	, cteFatherFigureCount
	as
		(select count(FatherFigurePK) as CountOfFatherFigures
			from FatherFigure ff
			where HVCaseFK = @HVCaseFK
		)
	, cteTCIDCount
	as
		(select count(TCIDPK) as CountOfTCIDs
			from TCID t
			where HVCaseFK = @HVCaseFK
		)
	, cteTCMedicalCount
	as
		(select count(TCMedicalPK) as CountOfTCMedicalForms
			from TCMedical tm
			where HVCaseFK = @HVCaseFK
		)
	, ctePSICount
	as
		(select count(PSIPK) as CountOfPSIs
			from PSI p
			where HVCaseFK = @HVCaseFK
		)
	, cteASQCount
	as
		(select count(ASQPK) as CountOfASQs
			from ASQ a
			where HVCaseFK = @HVCaseFK
		)
	, cteASQSECount
	as
		(select count(ASQSEPK) as CountOfASQSEs
			from ASQSE ase
			where HVCaseFK = @HVCaseFK
		)
	, cteFollowUpCount
	as
		(select count(FollowUpPK) as CountOfFollowUps
			from FollowUp fu
			where HVCaseFK = @HVCaseFK
		)
	
	select HVCasePK
			, PC1ID
			, hc.ScreenDate
			, hc.TCDOB
			, rtrim(pc.PCFirstName) + ' ' + rtrim(pc.PCLastName) as PC1Name
			, rtrim(ec.PCFirstName) + ' ' + rtrim(ec.PCLastName) as EmergencyContactName
			, LevelName as CurrentLevelname
			, hc.KempeDate
			, DischargeDate
			, rtrim(obp.PCFirstName) + ' ' + rtrim(obp.PCLastName) as OBPName
			, rtrim(t.TCFirstName) + ' ' + rtrim(t.TCLastName) as TargetChildName
			, rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as CurrentWorkerName
			, IntakeDate
			, rtrim(pc2.PCFirstName) + ' ' + rtrim(pc2.PCLastName) as PC2Name
			, CountOfPreassessments
			, CountOfPreintakes
			, CountOfServiceReferrals
			, CountOfHomeVisitLogs
			, CountOfPC1MedicalForms
			, CountOfFatherFigures
			, CountOfTCIDs
			, CountOfTCMedicalForms
			, CountOfPSIs
			, CountOfASQs
			, CountOfASQSEs
			, CountOfFollowUps
			
		from HVCase hc
		inner join CaseProgram cp on cp.HVCaseFK = hc.HVCasePK 
		inner join PC pc on pc.PCPK = hc.PC1FK
		inner join PC ec on ec.PCPK = hc.CPFK
		inner join PC obp on obp.PCPK = hc.OBPFK
		inner join PC pc2 on pc2.PCPK = hc.PC2FK
		inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
		--inner join HVScreen s on s.HVCaseFK = hc.HVCasePK
		inner join TCID t on t.HVCaseFK = hc.HVCasePK
		inner join ctePreAssessmentCount on 1 = 1
		inner join ctePreIntakeCount on 1 = 1
		inner join cteServiceReferralCount on 1 = 1
		inner join cteHomeVisitLogCount on 1 = 1
		inner join ctePC1MedicalCount on 1 = 1
		inner join cteFatherFigureCount on 1 = 1
		inner join cteTCIDCount on 1 = 1
		inner join cteTCMedicalCount on 1 = 1
		inner join ctePSICount on 1 = 1
		inner join cteASQCount on 1 = 1
		inner join cteASQSECount on 1 = 1
		inner join cteFollowUpCount on 1 = 1
		where hc.HVCasePK = @HVCaseFK
end
GO
