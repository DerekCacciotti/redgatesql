
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Main storedproc for Retention Rate report
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- exec rspRetentionRates 19, '20080101', '20121231'
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[rspRetentionRates]
	-- Add the parameters for the stored procedure here
	@programfk INT, @startdate DATETIME, @enddate DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--region declarations
	declare @tblResults table (
		LineDescription varchar(50)
		, LineGroupingLevel int
		, DisplayPercentages bit
		, TotalEnrolledParticipants int
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, RetentionRateEighteenMonths decimal(5,3)
		, RetentionRateTwoYears decimal(5,3)
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsOneYear int
		, EnrolledParticipantsEighteenMonths int
		, EnrolledParticipantsTwoYears int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedOneYear int
		, RunningTotalDischargedEighteenMonths int
		, RunningTotalDischargedTwoYears int
		, TotalNSixMonths int
		, TotalNOneYear int
		, TotalNEighteenMonths int
		, TotalNTwoYears int
		, AllParticipants int
		, SixMonthsIntake int
		, SixMonthsDischarge int
		, OneYearIntake int 
		, OneYearDischarge int
		, EighteenMonthsIntake int
		, EighteenMonthsDischarge int
		, TwoYearsIntake int
		, TwoYearsDischarge int);
	
	declare @tblPC1withStats table (
		PC1ID char(13)
		, IntakeDate datetime
		, DischargeDate datetime
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int
		, AgeAtIntake_Under18 int
		, AgeAtIntake_18UpTo20 int
		, AgeAtIntake_20UpTo30 int
		, AgeAtIntake_Over30 int
		, RaceWhite int
		, RaceBlack int
		, RaceHispanic int
		, RaceOther int
		, RaceUnknownMissing int
		, MarriedAtIntake int
		, MarriedAtDischarge int
		, NotMarriedAtIntake int
		, NotMarriedAtDischarge int
		, MarriedUnknownMissingAtIntake int
		, MarriedUnknownMissingAtDischarge int
		, OtherChildrenInHouseholdAtIntake int
		, OtherChildrenInHouseholdAtDischarge int
		, NoOtherChildrenInHouseholdAtIntake int
		, NoOtherChildrenInHouseholdAtDischarge int
		, ReceivingTANFAtIntake int
		, ReceivingTANFAtDischarge int
		, NotReceivingTANFAtIntake int
		, NotReceivingTANFAtDischarge int
		, MomScore int
		, DadScore int
		, PartnerScore int
		, PC1EducationAtIntakeLessThan12 int
		, PC1EducationAtDischargeLessThan12 int
		, PC1EducationAtIntakeHSGED int
		, PC1EducationAtDischargeHSGED int
		, PC1EducationAtIntakeMoreThan12 int
		, PC1EducationAtDischargeMoreThan12 int
		, PC1EducationAtIntakeUnknownMissing int
		, PC1EducationAtDischargeUnknownMissing int
		, PC1EducationalEnrollmentAtIntakeYes int
		, PC1EducationalEnrollmentAtDischargeYes int
		, PC1EducationalEnrollmentAtIntakeNo int
		, PC1EducationalEnrollmentAtDischargeNo int
		, PC1EducationalEnrollmentAtIntakeUnknownMissing int
		, PC1EducationalEnrollmentAtDischargeUnknownMissing int
		, PC1EmploymentAtIntakeYes int
		, PC1EmploymentAtDischargeYes int
		, PC1EmploymentAtIntakeNo int
		, PC1EmploymentAtDischargeNo int
		, PC1EmploymentAtIntakeUnknownMissing int
		, PC1EmploymentAtDischargeUnknownMissing int
		, OBPInHouseholdAtIntake int
		, OBPInHouseholdAtDischarge int
		, OBPEmploymentAtIntakeYes int
		, OBPEmploymentAtDischargeYes int
		, OBPEmploymentAtIntakeNo int
		, OBPEmploymentAtDischargeNo int
		, OBPEmploymentAtIntakeNoOBP int
		, OBPEmploymentAtDischargeNoOBP int
		, OBPEmploymentAtIntakeUnknownMissing int
		, OBPEmploymentAtDischargeUnknownMissing int
		, PC2InHouseholdAtIntake int
		, PC2InHouseholdAtDischarge int
		, PC2EmploymentAtIntakeYes int
		, PC2EmploymentAtDischargeYes int
		, PC2EmploymentAtIntakeNo int
		, PC2EmploymentAtDischargeNo int
		, PC2EmploymentAtIntakeNoPC2 int
		, PC2EmploymentAtDischargeNoPC2 int
		, PC2EmploymentAtIntakeUnknownMissing int
		, PC2EmploymentAtDischargeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtIntakeYes int
		, PC1OrPC2OrOBPEmployedAtDischargeYes int
		, PC1OrPC2OrOBPEmployedAtIntakeNo int
		, PC1OrPC2OrOBPEmployedAtDischargeNo int
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing int
		, CountOfHomeVisits int
		, DischargedOnLevelX int
		, PC1DVAtIntake int
		, PC1DVAtDischarge int
		, PC1MHAtIntake int
		, PC1MHAtDischarge int
		, PC1SAAtIntake int
		, PC1SAAtDischarge int
		, PC1PrimaryLanguageAtIntakeEnglish int
		, PC1PrimaryLanguageAtIntakeSpanish int
		, PC1PrimaryLanguageAtIntakeOtherUnknown int
		, TrimesterAtIntakePostnatal int
		, TrimesterAtIntake3rd int
		, TrimesterAtIntake2nd int
		, TrimesterAtIntake1st int
		, CountOfFSWs int);
	
--endregion
--region cteDischargeData - Get all discharge related data
    with cteDischargeData as 
	------------------------
		(select HVCasePK as HVCaseFK
			    ,cd.DischargeReason as DischargeReason
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,EducationalEnrollmentAtDischarge
			   	,case
					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK AND oc.FormType='FU') 
						then 1
					else 0
				end as OtherChildrenInHouseholdAtDischarge
				,case 
					when pc1is.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtDischarge
				,case
					when pc1is.SubstanceAbuse = '1' 
						then 1
					else 0
				end as SubstanceAbuseAtDischarge
				,case 
					when pc1is.DomesticViolence = '1' 
						then 1
					else 0
				end as DomesticViolenceAtDischarge
				,case 
					when pc1is.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtDischarge
				,case 
					when pc1is.Depression = '1'
						then 1
					else 0
				end as DepressionAtDischarge
				,OBPInHomeAtDischarge
				,PC2inHome as PC2InHomeAtDischarge
				,PC2EmploymentAtDischarge
				,OBPEmploymentAtDischarge
		from HVCase c
		inner join CaseProgram cp on cp.HVCaseFK=c.HVCasePK
		inner join Kempe k on k.HVCaseFK=c.HVCasePK
		inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
		inner join codeDischarge cd on cd.DischargeCode=cp.DischargeReason 
		left outer join (select *
						from FollowUp fu
						where fu.FollowUpInterval in (98,99)) fu ON fu.HVCaseFK=c.HVCasePK
		left outer join PC1Issues pc1is ON pc1is.PC1IssuesPK=fu.PC1IssuesFK
		left outer join (select MaritalStatus
								,AppCodeText as MaritalStatusAtDischarge
								,IsCurrentlyEmployed AS PC1EmploymentAtDischarge
								,EducationalEnrollment AS EducationalEnrollmentAtDischarge
								,HVCaseFK 
						   from CommonAttributes ca
						   left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
						  where FormType='FU-PC1' AND FormInterval IN (98,99)) pc1fuca ON pc1fuca.HVCaseFK=c.HVCasePK
		left outer join (SELECT IsCurrentlyEmployed AS OBPEmploymentAtDischarge
								,OBPInHome as OBPInHomeAtDischarge
								,HVCaseFK 
						   FROM CommonAttributes ca
						  WHERE FormType='FU-OBP' AND FormInterval IN (98,99)) obpfuca ON obpfuca.HVCaseFK=c.HVCasePK
		left outer join (SELECT IsCurrentlyEmployed AS PC2EmploymentAtDischarge
								, HVCaseFK
						   FROM CommonAttributes ca
						  WHERE FormType='FU-PC2' AND FormInterval IN (98,99)) pc2fuca ON pc2fuca.HVCaseFK=c.HVCasePK
		left outer join (SELECT AppCodeText as PC1EducationAtDischarge,HighestGrade,HVCaseFK 
						   FROM CommonAttributes ca
						   LEFT OUTER JOIN codeApp capp ON capp.AppCode=HighestGrade and AppCodeGroup='Education'
						  WHERE FormType='FU-PC1' AND FormInterval IN (98,99)) pc1edufu ON pc1edufu.HVCaseFK=c.HVCasePK
		where (IntakeDate is not null and IntakeDate between @startdate and @enddate)
			  and cp.ProgramFK=@programfk
			  AND Fu.FollowUpInterval IN (98,99)),
--endregion
--region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
	cteCaseLastHomeVisit AS 
	------------------------
		(SELECT HVCaseFK,MAX(vl.VisitStartTime) AS LastHomeVisit,COUNT(vl.VisitStartTime) AS CountOfHomeVisits
			FROM HVLog vl
			INNER JOIN hvcase c ON c.HVCasePK=vl.HVCaseFK 
			WHERE (IntakeDate is not null and IntakeDate between @startdate and @enddate)
				and vl.ProgramFK=@programfk
			GROUP BY HVCaseFK), 
--endregion
--region cteCaseFSWCount - get the count of FSWs for each case in the cohort, i.e. how many times it's changed
	cteCaseFSWCount AS 
	------------------------
		 (SELECT HVCaseFK, COUNT(wa.WorkerAssignmentPK) AS CountOfFSWs
		   FROM dbo.WorkerAssignment wa
			INNER JOIN hvcase c ON c.HVCasePK=wa.HVCaseFK 
			WHERE (IntakeDate is not null and IntakeDate between @startdate and @enddate)
				and wa.ProgramFK=@programfk
			GROUP BY HVCaseFK),
--endregion
--region ctePC1AgeAtIntake - get the PC1's age at intake
	ctePC1AgeAtIntake as
	------------------------
		(select HVCasePK as HVCaseFK
				,round(datediff(day,PCDOB,IntakeDate)/365.25,0) as PC1AgeAtIntake
			from PC 
			inner join PCProgram pcp on pcp.PCFK=PCPK
			inner join HVCase c on c.PC1FK=PCPK
			WHERE (IntakeDate is not null and IntakeDate between @startdate and @enddate)
				and pcp.ProgramFK=@programfk),
--endregion
--region ctePC1TANFAtDischarge - get the TANF status at discharge from TIP Status Change for PC1
	ctePC1TANFAtDischarge as 
	------------------------
	(select HVCaseFK, FormDate,PBTANF as PC1TANFAtDischarge
			from CommonAttributes ca
			where formtype = 'TP'
				and CONVERT(DATETIME,FormDate,112)+CommonAttributesPK in (select CAMatchingKey=MAX(CONVERT(DATETIME,FormDate,112)+CommonAttributesPK)
											from CommonAttributes cainner
											where cainner.hvcasefk=ca.hvcasefk 
													and formtype='TP')),
--endregion
--region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	cteMain as
	------------------------
		(select PC1ID
			   ,IntakeDate
			   ,LastHomeVisit
			   ,CountOfFSWs
			   ,CountOfHomeVisits
			   ,DischargeDate
			   ,LevelName
			   ,cp.DischargeReason AS DischargeReasonCode
               ,dd.DischargeReason
			   ,PC1AgeAtIntake
			   ,case 
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 182.125 then 1 
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 182.125 then 1
					else 0
				end	as ActiveAt6Months
			   ,case
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 365.25 then 1
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 365.25 then 1
					else 0
				end as ActiveAt12Months
			   ,case
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 547.375 then 1
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 547.375 then 1
					else 0
				end as ActiveAt18Months
			   ,case
					when LastHomeVisit is null and CURRENT_TIMESTAMP-IntakeDate > 730.50 then 1
					when LastHomeVisit is not null and LastHomeVisit-IntakeDate > 730.50 then 1
					else 0
				end as ActiveAt24Months
			   ,Race
			   ,carace.AppCodeText as RaceText
			   ,MaritalStatus
			   ,MaritalStatusAtIntake
			   ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
			   ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore
			   ,case when PartnerScore = 'U' then 0 else cast(PartnerScore as int) end as PartnerScore
			   ,HighestGrade
			   ,PC1EducationAtIntake
			   ,PC1EmploymentAtIntake
			   ,EducationalEnrollment AS EducationalEnrollmentAtIntake
			   ,PrimaryLanguage as PC1PrimaryLanguageAtIntake
			   ,case 
			   		when TCDOB is NULL then EDC
					else TCDOB
				end as TCDOB
			   ,case 
					when TCDOB is null and EDC is not null then 1
					when TCDOB is not null and TCDOB > IntakeDate then 1
					when TCDOB is not null and TCDOB <= IntakeDate then 0
				end
				as PrenatalEnrollment
				,case
					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK AND oc.FormType='IN') 
						then 1
					else 0
				end as OtherChildrenInHouseholdAtIntake
				,case 
					when pc1i.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtIntake
				,case 
					when pc1i.SubstanceAbuse = '1'
						then 1
					else 0
				end as SubstanceAbuseAtIntake
				,case 
					when pc1i.DomesticViolence = '1'
						then 1
					else 0
				end as DomesticViolenceAtIntake
				,case 
					when pc1i.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtIntake
				,case 
					when pc1i.Depression = '1'
						then 1
					else 0
				end as DepressionAtIntake
				,OBPInHomeIntake as OBPInHomeAtIntake
				,PC2InHomeIntake as PC2InHomeAtIntake
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,EducationalEnrollmentAtDischarge
		   		,OtherChildrenInHouseholdAtDischarge
				,AlcoholAbuseAtDischarge
				,SubstanceAbuseAtDischarge
				,DomesticViolenceAtDischarge
				,MentalIllnessAtDischarge
				,DepressionAtDischarge
				,OBPInHomeAtDischarge
				,OBPEmploymentAtDischarge
				,OBPEmploymentAtIntake
				,PC2InHomeAtDischarge
				,PC2EmploymentAtIntake
				,PC2EmploymentAtDischarge
				,PC1TANFAtDischarge
				,PC1TANFAtIntake
		FROM HVCase c
		left outer join cteDischargeData dd ON dd.hvcasefk=c.HVCasePK
		left outer join ctePC1TANFAtDischarge tanf on tanf.HVCaseFK=c.HVCasePK
		inner join cteCaseLastHomeVisit lhv ON lhv.HVCaseFK=c.HVCasePK
		inner join cteCaseFSWCount fc ON fc.HVCaseFK=c.HVCasePK
		inner join ctePC1AgeAtIntake aai on aai.HVCaseFK=c.HVCasePK
		inner join CaseProgram cp on cp.HVCaseFK=c.HVCasePK
		inner join PC on PC.PCPK=c.PC1FK
		inner join Kempe k on k.HVCaseFK=c.HVCasePK
		inner join PC1Issues pc1i ON pc1i.HVCaseFK=k.HVCaseFK AND pc1i.PC1IssuesPK=k.PC1IssuesFK
		inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
		left outer join codeApp carace on carace.AppCode=Race and AppCodeGroup='Race'
		left outer join (select MaritalStatus, PBTANF as PC1TANFAtIntake
								,AppCodeText as MaritalStatusAtIntake
								,IsCurrentlyEmployed AS PC1EmploymentAtIntake
								,EducationalEnrollment
								,PrimaryLanguage
								,HVCaseFK 
						   from CommonAttributes ca
						   left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
						  where FormType='IN-PC1') pc1ca ON pc1ca.HVCaseFK=c.HVCasePK
		left outer join (SELECT IsCurrentlyEmployed AS OBPEmploymentAtIntake
								,HVCaseFK 
						   FROM CommonAttributes ca
						  WHERE FormType='IN-OBP') obpca ON obpca.HVCaseFK=c.HVCasePK
		left outer join (SELECT HVCaseFK
								, IsCurrentlyEmployed AS PC2EmploymentAtIntake
						   FROM CommonAttributes ca
						  WHERE FormType='IN-PC2') pc2ca ON pc2ca.HVCaseFK=c.HVCasePK
		left outer join (SELECT AppCodeText as PC1EducationAtIntake,HighestGrade,HVCaseFK 
						   FROM CommonAttributes ca
						   LEFT OUTER JOIN codeApp capp ON capp.AppCode=HighestGrade and AppCodeGroup='Education'
						  WHERE FormType='IN-PC1') pc1eduai ON pc1eduai.HVCaseFK=c.HVCasePK
		where (IntakeDate is not null and IntakeDate between @startdate and @enddate)
			  and cp.ProgramFK=@programfk)
--endregion
--select *
--from cteDischargeData
--select *
--from cteMain
--order by PC1ID
--region Add rows to @tblPC1withStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1withStats 
		(PC1ID
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		, RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, AgeAtIntake_Under18
		, AgeAtIntake_18UpTo20
		, AgeAtIntake_20UpTo30
		, AgeAtIntake_Over30
		, RaceWhite
		, RaceBlack
		, RaceHispanic
		, RaceOther
		, RaceUnknownMissing
		, MarriedAtIntake
		, MarriedAtDischarge
		, NotMarriedAtIntake
		, NotMarriedAtDischarge
		, MarriedUnknownMissingAtIntake
		, MarriedUnknownMissingAtDischarge
		, OtherChildrenInHouseholdAtIntake
		, OtherChildrenInHouseholdAtDischarge
		, NoOtherChildrenInHouseholdAtIntake
		, NoOtherChildrenInHouseholdAtDischarge
		, ReceivingTANFAtIntake
		, ReceivingTANFAtDischarge
		, NotReceivingTANFAtIntake
		, NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, PC1EducationAtIntakeLessThan12
		, PC1EducationAtDischargeLessThan12
		, PC1EducationAtIntakeHSGED
		, PC1EducationAtDischargeHSGED
		, PC1EducationAtIntakeMoreThan12
		, PC1EducationAtDischargeMoreThan12
		, PC1EducationAtIntakeUnknownMissing
		, PC1EducationAtDischargeUnknownMissing
		, PC1EducationalEnrollmentAtIntakeYes
		, PC1EducationalEnrollmentAtDischargeYes
		, PC1EducationalEnrollmentAtIntakeNo
		, PC1EducationalEnrollmentAtDischargeNo
		, PC1EducationalEnrollmentAtIntakeUnknownMissing
		, PC1EducationalEnrollmentAtDischargeUnknownMissing
		, PC1EmploymentAtIntakeYes
		, PC1EmploymentAtDischargeYes
		, PC1EmploymentAtIntakeNo
		, PC1EmploymentAtDischargeNo
		, PC1EmploymentAtIntakeUnknownMissing
		, PC1EmploymentAtDischargeUnknownMissing
		, OBPInHouseholdAtIntake
		, OBPInHouseholdAtDischarge
		, OBPEmploymentAtIntakeYes
		, OBPEmploymentAtDischargeYes
		, OBPEmploymentAtIntakeNo
		, OBPEmploymentAtDischargeNo
		, OBPEmploymentAtIntakeNoOBP
		, OBPEmploymentAtDischargeNoOBP
		, OBPEmploymentAtIntakeUnknownMissing
		, OBPEmploymentAtDischargeUnknownMissing
		, PC2InHouseholdAtIntake
		, PC2InHouseholdAtDischarge
		, PC2EmploymentAtIntakeYes
		, PC2EmploymentAtDischargeYes
		, PC2EmploymentAtIntakeNo
		, PC2EmploymentAtDischargeNo
		, PC2EmploymentAtIntakeNoPC2
		, PC2EmploymentAtDischargeNoPC2
		, PC2EmploymentAtIntakeUnknownMissing
		, PC2EmploymentAtDischargeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtIntakeYes
		, PC1OrPC2OrOBPEmployedAtDischargeYes
		, PC1OrPC2OrOBPEmployedAtIntakeNo
		, PC1OrPC2OrOBPEmployedAtDischargeNo
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, DischargedOnLevelX
		, PC1DVAtIntake
		, PC1DVAtDischarge
		, PC1MHAtIntake
		, PC1MHAtDischarge
		, PC1SAAtIntake
		, PC1SAAtDischarge
		, PC1PrimaryLanguageAtIntakeEnglish
		, PC1PrimaryLanguageAtIntakeSpanish
		, PC1PrimaryLanguageAtIntakeOtherUnknown
		, TrimesterAtIntakePostnatal
		, TrimesterAtIntake3rd
		, TrimesterAtIntake2nd
		, TrimesterAtIntake1st
		, CountOfFSWs)
select distinct pc1id
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		, datediff(mm,IntakeDate,LastHomeVisit) as RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, case when PC1AgeAtIntake < 18 then 1 else 0 end as AgeAtIntake_Under18
		, case when PC1AgeAtIntake between 18 and 19 then 1 else 0 end as AgeAtIntake_18UpTo20
		, case when PC1AgeAtIntake between 20 and 29 then 1 else 0 end as AgeAtIntake_20UpTo30
		, case when PC1AgeAtIntake >= 30 then 1 else 0 end as AgeAtIntake_Over30
		, case when left(RaceText,5)='White' then 1 else 0 end as RaceWhite
		, case when left(RaceText,5)='Black' then 1 else 0 end as RaceBlack
		, case when left(RaceText,8)='Hispanic' then 1 else 0 end as RaceHispanic
		, case when left(RaceText,5) in('Asian','Nativ','Multi','Other') then 1 else 0 end as RaceOther
		, case when RaceText is null or RaceText='' then 1 else 0 end as RaceUnknownMissing
		, case when MaritalStatusAtIntake in ('Married, first time','Remarried','Separated') then 1 else 0 end as MarriedAtIntake
		, case when MaritalStatusAtDischarge in ('Married, first time','Remarried','Separated') then 1 else 0 end as MarriedAtDischarge
		, case when left(MaritalStatusAtIntake,6) in ('Single','Living','Divorc','Widowe') then 1 else 0 end as NotMarriedAtIntake
		, case when left(MaritalStatusAtDischarge,6) in ('Single','Living','Divorc','Widowe') then 1 else 0 end as NotMarriedAtDischarge
		, case when MaritalStatusAtIntake is null or MaritalStatusAtIntake='' then 1 else 0 end as MarriedUnknownMissingAtIntake
		, case when MaritalStatusAtDischarge is null or MaritalStatusAtDischarge='' then 1 else 0 end as MarriedUnknownMissingAtDischarge
		, case when OtherChildrenInHouseholdAtIntake > 0 then 1 else 0 end as OtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge > 0 then 1 else 0 end as OtherChildrenInHouseholdAtDischarge
		, case when OtherChildrenInHouseholdAtIntake = 0 or OtherChildrenInHouseholdAtIntake is null then 1 else 0 end as NoOtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge = 0 or OtherChildrenInHouseholdAtDischarge is null then 1 else 0 end as NoOtherChildrenInHouseholdAtDischarge
		, case when PC1TANFAtIntake = 1 then 1 else 0 end as ReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 1 then 1 else 0 end as ReceivingTANFAtDischarge
		, case when PC1TANFAtIntake = 0 or PC1TANFAtIntake is null or PC1TANFAtIntake = '' then 1 else 0 end as NotReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 0 or PC1TANFAtDischarge is null or PC1TANFAtDischarge='' then 1 else 0 end as NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, case when PC1EducationAtIntake in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtIntakeLessThan12
		, case when PC1EducationAtDischarge in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtDischargeLessThan12
		, case when PC1EducationAtIntake in ('High school grad','GED') then 1 else 0 end as PC1EducationAtIntakeHSGED
		, case when PC1EducationAtDischarge in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtDischargeHSGED
		, case when PC1EducationAtIntake in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtIntakeMoreThan12
		, case when PC1EducationAtDischarge in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtDischargeMoreThan12
		, case when PC1EducationAtIntake is null or PC1EducationAtIntake = '' then 1 else 0 end as PC1EducationAtIntakeUnknownMissing
		, case when PC1EducationAtDischarge is null or PC1EducationAtDischarge = '' then 1 else 0 end as PC1EducationAtDischargeUnknownMissing
		, case when EducationalEnrollmentAtIntake = 1 then 1 else 0 end as PC1EducationalEnrollmentAtIntakeYes
		, case when EducationalEnrollmentAtDischarge = 1 then 1 else 0 end as PC1EducationalEnrollmentAtDischargeYes
		, case when EducationalEnrollmentAtIntake = 0 then 1 else 0 end as PC1EducationalEnrollmentAtIntakeNo
		, case when EducationalEnrollmentAtDischarge = 0 then 1 else 0 end as PC1EducationalEnrollmentAtDischargeNo
		, case when EducationalEnrollmentAtIntake is null or EducationalEnrollmentAtIntake = '' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeUnknownMissing
		, case when EducationalEnrollmentAtDischarge is null or EducationalEnrollmentAtDischarge = '' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = 1 then 1 else 0 end as PC1EmploymentAtIntakeYes
		, case when PC1EmploymentAtDischarge = 1 then 1 else 0 end as PC1EmploymentAtDischargeYes
		, case when PC1EmploymentAtIntake = 0 then 1 else 0 end as PC1EmploymentAtIntakeNo
		, case when PC1EmploymentAtDischarge = 0 then 1 else 0 end as PC1EmploymentAtDischargeNo
		, case when PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '' then 1 else 0 end as PC1EmploymentAtIntakeUnknownMissing
		, case when PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '' then 1 else 0 end as PC1EmploymentAtDischargeUnknownMissing
		, case when OBPInHomeAtIntake = 1 then 1 else 0 end as OBPInHouseholdAtIntake
		, case when OBPInHomeAtDischarge = 1 then 1 else 0 end as OBPInHouseholdAtDischarge
		, case when OBPEmploymentAtIntake = 1 then 1 else 0 end as OBPEmploymentAtIntakeYes
		, case when OBPEmploymentAtDischarge = 1 then 1 else 0 end as OBPEmploymentAtDischargeYes
		, case when OBPEmploymentAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNo
		, case when OBPEmploymentAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNo
		, case when OBPInHomeAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNoOBP
		, case when OBPinHomeAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNoOBP
		, case when OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is null or OBPEmploymentAtIntake = '') then 1 else 0 end as OBPEmploymentAtIntakeUnknownMissing
		, case when OBPInHomeAtDischarge = 1 and (OBPEmploymentAtDischarge is null or OBPEmploymentAtDischarge = '') then 1 else 0 end as OBPEmploymentAtDischargeUnknownMissing
		, case when PC2InHomeAtIntake = 1 then 1 else 0 end as PC2InHouseholdAtIntake
		, case when PC2InHomeAtDischarge = 1 then 1 else 0 end as PC2InHouseholdAtDischarge
		, case when PC2EmploymentAtIntake = 1 then 1 else 0 end as PC2EmploymentAtIntakeYes
		, case when PC2EmploymentAtDischarge = 1 then 1 else 0 end as PC2EmploymentAtDischargeYes
		, case when PC2EmploymentAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNo
		, case when PC2EmploymentAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNo
		, case when PC2InHomeAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNoPC2
		, case when PC2inHomeAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNoPC2
		, case when PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '') then 1 else 0 end as PC2EmploymentAtIntakeUnknownMissing
		, case when PC2InHomeAtDischarge = 1 and (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = '') then 1 else 0 end as PC2EmploymentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = 1 or PC2EmploymentAtIntake = 1 or OBPEmploymentAtIntake = 1 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeYes
		, case when PC1EmploymentAtDischarge = 1 or PC2EmploymentAtDischarge = 1 or OBPEmploymentAtDischarge = 1 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeYes
		, case when PC1EmploymentAtIntake = 0 and PC2EmploymentAtIntake = 0 and OBPEmploymentAtIntake = 0 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeNo
		, case when PC1EmploymentAtDischarge = 0 and PC2EmploymentAtDischarge = 0 and OBPEmploymentAtDischarge = 0 then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeNo
		, case when (PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '') 
					and (PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '')) 
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is NULL or OBPEmploymentAtIntake = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, case when (PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '') 
					and (PC2InHomeAtIntake = 1 and  (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = ''))
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtDischarge is NULL or OBPEmploymentAtDischarge = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, case when left(LevelName,7)='Level X' then 1 else 0 end as DischargedOnLevelX
		, case when DomesticViolenceAtIntake = 1 then 1 else 0 end as PC1DVAtIntake
		, case when DomesticViolenceAtDischarge = 1 then 1 else 0 end as PC1DVAtDischarge
		, case when MentalIllnessAtIntake = 1 or DepressionAtIntake = 1 then 1 else 0 end as PC1MHAtIntake
		, case when MentalIllnessAtDischarge = 1 or DepressionAtDischarge = 1 then 1 else 0 end as PC1MHAtDischarge
		, case when AlcoholAbuseAtIntake = 1 or SubstanceAbuseAtIntake = 1 then 1 else 0 end as PC1SAAtIntake
		, case when AlcoholAbuseAtDischarge = 1 or SubstanceAbuseAtDischarge = 1 then 1 else 0 end as PC1SAAtDischarge
		, case when PC1PrimaryLanguageAtIntake = '01' then 1 else 0 end as PC1PrimaryLanguageAtIntakeEnglish
		, case when PC1PrimaryLanguageAtIntake = '02' then 1 else 0 end as PC1PrimaryLanguageAtIntakeSpanish
		, case when PC1PrimaryLanguageAtIntake = '03' or PC1PrimaryLanguageAtIntake is null or PC1PrimaryLanguageAtIntake = '' then 1 else 0 end as PC1PrimaryLanguageAtIntakeOtherUnknown
		, case when IntakeDate>=TCDOB then 1 else 0 end as TrimesterAtIntakePostnatal
		, case when IntakeDate<TCDOB and datediff(day,IntakeDate,TCDOB) between 1 and round(30.44*3,0) then 1 else 0 end as TrimesterAtIntake3rd
		, case when IntakeDate<TCDOB and datediff(day,IntakeDate,TCDOB) between round(30.44*3,0)+1 and round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake2nd
		, case when IntakeDate<TCDOB and datediff(day,IntakeDate,TCDOB) > round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake1st		
		, CountOfFSWs
from cteMain
-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
where DischargeReasonCode is NULL or DischargeReasonCode not in ('07','17','18')
order by PC1ID,IntakeDate
--endregion

declare @TotalCohortCount int

-- now we have all the rows from the cohort in @tblPC1withStats
-- get the total count
select @TotalCohortCount = COUNT(*) 
  from @tblPC1withStats

--region declare vars to collect counts for final stats
declare @LineGroupingLevel int
		, @TotalEnrolledParticipants int
		, @RetentionRateSixMonths decimal(5,3)
		, @RetentionRateOneYear decimal(5,3)
		, @RetentionRateEighteenMonths decimal(5,3)
		, @RetentionRateTwoYears decimal(5,3)
		, @EnrolledParticipantsSixMonths int
		, @EnrolledParticipantsOneYear int
		, @EnrolledParticipantsEighteenMonths int
		, @EnrolledParticipantsTwoYears int
		, @RunningTotalDischargedSixMonths int
		, @RunningTotalDischargedOneYear int
		, @RunningTotalDischargedEighteenMonths int
		, @RunningTotalDischargedTwoYears int
		, @TotalNSixMonths int
		, @TotalNOneYear int
		, @TotalNEighteenMonths int
		, @TotalNTwoYears int

declare @AllEnrolledParticipants int
		, @SixMonthsTotal int
		, @TwelveMonthsTotal int
		, @EighteenMonthsTotal int
		, @TwentyFourMonthsTotal int
		, @SixMonthsAtIntake int
		, @SixMonthsAtDischarge int
		, @TwelveMonthsAtIntake int
		, @TwelveMonthsAtDischarge int
		, @EighteenMonthsAtIntake int
		, @EighteenMonthsAtDischarge int
		, @TwentyFourMonthsAtIntake int
		, @TwentyFourMonthsAtDischarge int
--endregion
--region Retention Rate %
select @SixMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt6Months = 1

select @TwelveMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt12Months = 1

select @EighteenMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt18Months = 1

select @TwentyFourMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt24Months = 1

set @RetentionRateSixMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@SixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateOneYear = case when @TotalCohortCount = 0 then 0.0000 else round((@TwelveMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateEighteenMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@EighteenMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateTwoYears = case when @TotalCohortCount = 0 then 0.0000 else round((@TwentyFourMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
--endregion
--region Enrolled Participants
select @EnrolledParticipantsSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and (LastHomeVisit is NULL or LastHomeVisit >= dateadd(day, 6*30.44, IntakeDate)) -- and dateadd(day, 12*30.44, IntakeDate)

select @EnrolledParticipantsOneYear = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and (LastHomeVisit is NULL or LastHomeVisit > dateadd(day, 12*30.44, IntakeDate)) -- and dateadd(day, 18*30.44, IntakeDate)

select @EnrolledParticipantsEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and (LastHomeVisit is NULL or LastHomeVisit > dateadd(day, 18*30.44, IntakeDate)) -- and dateadd(day, 24*30.44, IntakeDate)

select @EnrolledParticipantsTwoYears = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1 and (LastHomeVisit is NULL or LastHomeVisit > dateadd(day, 24*30.44, IntakeDate))
--endregion
--region Running Total Discharged
select @RunningTotalDischargedSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
--select @RunningTotalDischargedSixMonths = count(*)
--from @tblPC1withStats
--where ActiveAt6Months = 0 and LastHomeVisit between IntakeDate and dateadd(day, 6*30.44, IntakeDate)
--
--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1withStats
--where ActiveAt12Months = 0 and LastHomeVisit between dateadd(day, (6*30.44)+1, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)
--
--select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
--from @tblPC1withStats
--where ActiveAt18Months = 0 and LastHomeVisit between dateadd(day, (12*30.44)+1, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)
--
--select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
--from @tblPC1withStats
--where ActiveAt24Months = 0 and LastHomeVisit between dateadd(day, (18*30.44)+1, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)
--endregion
--region Total (N) - (Discharged)
select @TotalNSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @TotalNOneYear = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @TotalNEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @TotalNTwoYears = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
--endregion
--region Age @ Intake
--			Under 18
--			18 up to 20
--			20 up to 30
--			30 and over
set @LineGroupingLevel = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Age @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_Under18 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_Under18 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_Under18 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_Under18 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_Under18 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Under 18'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_18upto20 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_18upto20 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_18upto20 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_18upto20 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_18upto20 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    18 up to 20'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_20upto30 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_20upto30 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_20upto30 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_20upto30 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_20upto30 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    20 up to 30'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_Over30 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_Over30 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_Over30 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_Over30 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_Over30 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    30 and Over'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)
--endregion
--region Race
--			White
--			Black
--			Hispanic
--			Other
--			Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Race'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceWhite = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceWhite = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceWhite = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceWhite = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceWhite = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    White'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceBlack = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceBlack = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceBlack = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceBlack = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceBlack = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Black'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceHispanic = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceHispanic = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceHispanic = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceHispanic = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceHispanic = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Hispanic'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceOther = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceOther = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceOther = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceOther = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceOther = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Other'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Unknown / Missing'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)
--endregion
--region Marital Status
--			Married
--			Not Married
--			Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Marital Status'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MarriedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Married'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where NotMarriedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NotMarriedAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NotMarriedAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NotMarriedAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NotMarriedAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NotMarriedAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NotMarriedAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NotMarriedAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NotMarriedAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Not Married'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MarriedUnknownMissingAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedUnknownMissingAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedUnknownMissingAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedUnknownMissingAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedUnknownMissingAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedUnknownMissingAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedUnknownMissingAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedUnknownMissingAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedUnknownMissingAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
--endregion
-- Other Children in Household
--		Yes
--		No
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Other Children in Household'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OtherChildrenInHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OtherChildrenInHouseholdAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OtherChildrenInHouseholdAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OtherChildrenInHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OtherChildrenInHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where NoOtherChildrenInHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- Receiving TANF Services
--		Yes
--		No
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Receiving TANF Services'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where ReceivingTANFAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and ReceivingTANFAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and ReceivingTANFAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and ReceivingTANFAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and ReceivingTANFAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and ReceivingTANFAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and ReceivingTANFAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and ReceivingTANFAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and ReceivingTANFAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where NotReceivingTANFAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NotReceivingTANFAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NotReceivingTANFAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NotReceivingTANFAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NotReceivingTANFAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NotReceivingTANFAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NotReceivingTANFAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NotReceivingTANFAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NotReceivingTANFAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- Average Kempe Score
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = avg(MomScore)
from @tblPC1withStats

select @SixMonthsAtIntake = avg(MomScore)
from @tblPC1withStats
where ActiveAt6Months = 0

select @TwelveMonthsAtIntake = avg(MomScore)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0

select @EighteenMonthsAtIntake = avg(MomScore)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0

select @TwentyFourMonthsAtIntake = avg(MomScore)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('Average Kempe Score'
		, @LineGroupingLevel
		, 0
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

-- Education
--		Less than 12
--		HS / GED
--		More than 12
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Education'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeLessThan12 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeLessThan12 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeLessThan12 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeLessThan12 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeLessThan12 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Less than 12'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeHSGED = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeHSGED = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeHSGED = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeHSGED = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeHSGED = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeHSGED = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeHSGED = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeHSGED = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeHSGED = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    HS / GED'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeMoreThan12 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    More Than 12'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)


-- PC1 Enrolled In Education Program
--		Yes
--		No
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 Enrolled In Education Program'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationalEnrollmentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationalEnrollmentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
        
-- PC1 Employed
--		Yes
--		No
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtIntakeYes = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeYes = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtIntakeNo = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeNo = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
        
-- OBP in Household
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPInHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPInHouseholdAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPInHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPInHouseholdAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPInHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPInHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPInHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPInHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPInHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('OBP in Household'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- OBP Employed
--		Yes
--		No
--		No OBP for Case
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('OBP Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeYes = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeYes = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeNo = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeNo = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeNoOBP = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeNoOBP = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeNoOBP = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeNoOBP = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeNoOBP = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No OBP for case'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- PC2 in Household (can not be OBP)
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2InHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2InHouseholdAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2InHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2InHouseholdAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2InHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2InHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2InHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2InHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2InHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('PC2 in Household (can not be OBP)'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- PC2 Employed
--		Yes
--		No
--		No PC2 in Home
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC2 Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeYes = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeYes = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeNo = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeNo = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeNoPC2 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No PC2 in Home'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- PC1 or PC2 or OBP Employed
--		Yes
--		No
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 or PC2 or OBP Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- Average # of Actual Home Visits
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = avg(CountOfHomeVisits)
from @tblPC1withStats

select @SixMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt6Months = 0

select @TwelveMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0

select @EighteenMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0

select @TwentyFourMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsDischarge
						, OneYearDischarge
						, EighteenMonthsDischarge
						, TwoYearsDischarge)
values ('Average # of Actual Home Visits'
		, @LineGroupingLevel
		, 0
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtDischarge)

-- Discharged on Level X
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where DischargedOnLevelX = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and DischargedOnLevelX = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DischargedOnLevelX = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DischargedOnLevelX = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DischargedOnLevelX = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsDischarge
						, OneYearDischarge
						, EighteenMonthsDischarge
						, TwoYearsDischarge)
values ('Discharged on Level X'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtDischarge)

-- PC1 Current Issues
--		DV
--		MH
--		SA
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 Current Issues'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1DVAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1DVAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1DVAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1DVAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1DVAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1DVAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1DVAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1DVAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1DVAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    DV'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1MHAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1MHAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1MHAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1MHAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1MHAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1MHAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1MHAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1MHAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1MHAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    MH'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1SAAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1SAAtIntake = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1SAAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1SAAtIntake = 1

select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1SAAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1SAAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1SAAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1SAAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1SAAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    SA'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- Primary Language @ Intake
--		English
--		Spanish
--		Other / Unknown
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Primary Language @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeEnglish = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    English'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeSpanish = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Spanish'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Other/Missing/Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

-- Trimester @ Intake
--		Postnatal
--		1st
--		2nd
--		3rd
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Trimester @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntakePostnatal = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntakePostnatal = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntakePostnatal = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntakePostnatal = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntakePostnatal = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Postnatal'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake1st = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntake1st = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake1st = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake1st = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake1st = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    1st'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake2nd = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntake2nd = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake2nd = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake2nd = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake2nd = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    2nd'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake3rd = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntake3rd = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake3rd = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake3rd = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake3rd = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    3rd'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

-- Cases with More than 1 Home Visitor
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where CountOfFSWs>1

select @SixMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt6Months = 0 and CountOfFSWs>1

select @TwelveMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CountOfFSWs>1

select @EighteenMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CountOfFSWs>1

select @TwentyFourMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CountOfFSWs>1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsDischarge
						, OneYearDischarge
						, EighteenMonthsDischarge
						, TwoYearsDischarge)
values ('Cases With >1 Home Visitor'
		, @LineGroupingLevel
		, 0
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtDischarge)

--select *
--from @tblPC1withStats

select *
from @tblResults

--select VendorID, Employee, Orders
--from
--   (SELECT ActiveAt6Months, ActiveAt12Months, ActiveAt18Months, ActiveAt24Months
--   FROM @tblPC1withStats) p
--UNPIVOT
--   (Orders FOR Employee IN 
--      (Emp1, Emp2, Emp3, Emp4, Emp5)
--)AS unpvt;

END



GO
