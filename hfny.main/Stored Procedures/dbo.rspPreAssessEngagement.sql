
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:      <Dar Chen>
-- Create date: <Jul 16, 2012>
-- Description: 
-- exec rspPreAssessEngagement 19, '07/01/2012', '07/01/2012', '09/30/2012'
-- exec rspPreAssessEngagement 5, '07/01/2012', '07/01/2012', '09/30/2012'

-- =============================================
CREATE procedure [dbo].[rspPreAssessEngagement] (@programfk varchar(max) = null
											  , @StartDtT datetime = null
											  , @StartDt datetime = null
											  , @EndDt datetime = null
											   )
as 

--DECLARE @StartDtT DATE = '01/01/2012'
--DECLARE @StartDt DATE = '09/01/2012'
--DECLARE @EndDt DATE = '11/30/2012'
--DECLARE @programfk INT = 4

	if @programfk is null
		begin
			select	@programfk = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
											from	HVProgram
										   for
											xml	path('')
										   ), 2, 8000)
		end
	set @programfk = replace(@programfk, '"', '');
	with ScreensThisPeriod
			  as (select	a.HVCasePK
						  , c.ScreenResult
						  , isnull(a.TCDOB, a.EDC) DOB
						  , a.ScreenDate
						  , c.ReferralMade
						  , b.DischargeReason
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  join		HVScreen as c on a.HVCasePK = c.HVCaseFK
				  where		a.ScreenDate between @StartDt and @EndDt
				 ) ,
			ScreensThisPeriod_1e
			  as (select	HVCasePK
				  from		ScreensThisPeriod
				  where		ScreenResult = 1
							and ReferralMade = 1
				 ) ,
			PreAssessmentCasesAtBeginningOfPeriod
			  as (select distinct
							a.HVCasePK
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  where		(a.ScreenDate < @StartDt)
							and (a.KempeDate >= @StartDt
								 or a.KempeDate is null
								)
							and (b.DischargeDate is null
								 or b.DischargeDate >= @StartDt
								)
				 ) ,
			section2Q
			  as (select	count(*) [Q2PreAssessmentBeforePeriod]
				  from		PreAssessmentCasesAtBeginningOfPeriod
				 ) ,
			TotalCasesToBeAssessedThisPeriod_2_1e
			  as (select distinct
							isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
				  from		PreAssessmentCasesAtBeginningOfPeriod as a
				  full outer join ScreensThisPeriod_1e as b on a.HVCasePK = b.HVCasePK
				 ) ,
			PreAssessment_MaxPADate
			  as (select	a.HVCaseFK
						  , max(a.PADate) [max_PADATE]
				  from		Preassessment as a
				  join		dbo.SplitString(@programfk, ',') on a.programfk = listitem
				  where		a.PADate between @StartDt and @EndDt
				  group by	a.HVCaseFK
				 ) ,
			PreAssessment_LastOneInPeriod
			  as (select	a.HVCaseFK
						  , a.CaseStatus
						  , a.FSWAssignDate
						  , a.KempeResult
						  , a.PADate
				  from		Preassessment as a
				  join		PreAssessment_MaxPADate as b on a.HVCaseFK = b.HVCaseFK
															and a.PADate = b.max_PADATE
				 ) ,
			Outcomes
			  as (select	a.HVCasePK
						  , b.*
				  from		TotalCasesToBeAssessedThisPeriod_2_1e as a
				  left outer join PreAssessment_LastOneInPeriod as b on a.HVCasePK = b.HVCaseFK
				 ) ,
			section4Q
			  as (select	count(*) [Q3TotalCasesThisPerion]
						  , sum(case when CaseStatus in ('02', '04') then 1
									 else 0
								end) [Q4bCompleted]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate <= @EndDt then 1
									 else 0
								end) [Q4b1PositiveAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate > @EndDt then 1
									 else 0
								end) [Q4b2PositivePendingAssignd]
						  , sum(case when CaseStatus = '04'
										  and KempeResult = 1
										  and FSWAssignDate is null then 1
									 else 0
								end) [Q4b3PositiveNotAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 0 then 1
									 else 0
								end) [Q4b4Negative]
						  , sum(case when CaseStatus = '03' then 1
									 else 0
								end) [Q4cTerminated]
						  , sum(case when CaseStatus = '01'
										  and datediff(d, PADate, @EndDt) <= 30 then 1
									 else 0
								end) [Q4aEffortContnue]
				  from		Outcomes
				 ) ,
			section1QX
			  as (select	sum(1) [Q1Screened]
						  , sum(case when ScreenResult = 1 then 1
									 else 0
								end) [Q1aScreenResultPositive]
						  , sum(case when ScreenResult != 1 then 1
									 else 0
								end) [Q1bScreenResultNegative]
						  , sum(case when DOB > ScreenDate then 1
									 else 0
								end) [Q1cPrenatal]
						  , sum(case when DOB <= ScreenDate then 1
									 else 0
								end) [Q1dPostnatal]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 1 then 1
									 else 0
								end) [Q1ePositiveReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0 then 1
									 else 0
								end) [Q1fPositiveNotReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason in ('05', '07', '35', '36', '06', '08', '33', '34', '99',
																  '13', '25') then 1
									 else 0
								end) [Q1DischargeAll]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '05' then 1
									 else 0
								end) [Q1f1IncomeIneligible]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '07' then 1
									 else 0
								end) [Q1f2OutOfGeoTarget]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '35' then 1
									 else 0
								end) [Q1f3NonCompliant]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '36' then 1
									 else 0
								end) [Q1f3Refuse]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '06' then 1
									 else 0
								end) [Q1f4InappropriateScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '08' then 1
									 else 0
								end) [Q1f5CaseLoadFull]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '33' then 1
									 else 0
								end) [Q1f6PositiveScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '34' then 1
									 else 0
								end) [Q1f7SubsequentBirthOnOpenCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '99' then 1
									 else 0
								end) [Q1f8Other]
						  , 0 [Q1f9NoReason]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '13' then 1
									 else 0
								end) [Q1f10ControlCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '25' then 1
									 else 0
								end) [Q1f11Transferred]
				  from		ScreensThisPeriod
				 ) ,
			section1Q
			  as (select	Q1Screened
						  , cast(cast(case when Q1Screened > 0
										   then round(100.0 * Q1aScreenResultPositive / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1aScreenResultPositive]
						  , cast(cast(case when Q1Screened > 0
										   then round(100.0 * Q1bScreenResultNegative / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1bScreenResultNegative]
						  , cast(cast(case when Q1Screened > 0 then round(100.0 * Q1cPrenatal / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1cPrenatal]
						  , cast(cast(case when Q1Screened > 0 then round(100.0 * Q1dPostnatal / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1dPostnatal]
						  , cast(cast(case when Q1Screened > 0 then round(100.0 * Q1ePositiveReferred / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1ePositiveReferredPercent]
						  , Q1ePositiveReferred
						  , cast(cast(case when Q1Screened > 0
										   then round(100.0 * Q1fPositiveNotReferred / Q1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [Q1fPositiveNotReferredPercent]
						  , Q1fPositiveNotReferred
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f1IncomeIneligible / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f1IncomeIneligible
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f2OutOfGeoTarget / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f2OutOfGeoTarget
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f3NonCompliant / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f3NonCompliant
						  , cast(cast(case when Q1DischargeAll > 0 then round(100.0 * Q1f3Refuse / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f3Refuse
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f4InappropriateScreen / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f4InappropriateScreen
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f5CaseLoadFull / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f5CaseLoadFull
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f6PositiveScreen / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f6PositiveScreen
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f7SubsequentBirthOnOpenCase / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f7SubsequentBirthOnOpenCase
						  , cast(cast(case when Q1DischargeAll > 0 then round(100.0 * Q1f8Other / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f8Other
						  , cast(cast(case when Q1DischargeAll > 0 then round(100.0 * Q1f9NoReason / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f9NoReason
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f10ControlCase / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f10ControlCase
						  , cast(cast(case when Q1DischargeAll > 0
										   then round(100.0 * Q1f11Transferred / Q1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' Q1f11Transferred
				  from		section1QX
				 ) ,
			section5Q
			  as (select	sum(PAParentLetter) [Q5aPAParentLetter]
						  , sum(PACall2Parent) [Q5bPACall2Parent]
						  , sum(PACallFromParent) [Q5cPACallFromParent]
						  , sum(PAVisitAttempt) [Q5dPAVisitAttempt]
						  , sum(PAVisitMade) [Q5ePAVisitMade]
						  , sum(PAOtherHVProgram) [Q5fPAOtherHVProgram]
						  , sum(PAParent2Office) [Q5gPAParent2Office]
						  , sum(PAProgramMaterial) [Q5hPAProgramMaterial]
						  , sum(PAGift) [Q5iPAGift]
						  , sum(PACaseReview) [Q5jPACaseReview]
						  , sum(PAOtherActivity) [Q5kPAOtherActivity]
				  from		Preassessment
				  join		dbo.SplitString(@programfk, ',') on programfk = listitem
				  where		PADate between @StartDt and @EndDt
				 ) ,

/* total */	ScreensThisPeriodT
			  as (select	a.HVCasePK
						  , c.ScreenResult
						  , isnull(a.TCDOB, a.EDC) DOB
						  , a.ScreenDate
						  , c.ReferralMade
						  , b.DischargeReason
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  join		HVScreen as c on a.HVCasePK = c.HVCaseFK
				  where		a.ScreenDate between @StartDtT and @EndDt
				 ) ,
			ScreensThisPeriod_1eT
			  as (select	HVCasePK
				  from		ScreensThisPeriodT
				  where		ScreenResult = 1
							and ReferralMade = 1
				 ) ,
			PreAssessmentCasesAtBeginningOfPeriodT
			  as (select distinct
							a.HVCasePK
				  from		HVCase as a
				  join		CaseProgram as b on a.HVCasePK = b.HVCaseFK
				  join		dbo.SplitString(@programfk, ',') on b.programfk = listitem
				  where		(a.ScreenDate < @StartDtT)
							and (a.KempeDate >= @StartDtT
								 or a.KempeDate is null
								)
							and (b.DischargeDate is null
								 or b.DischargeDate >= @StartDtT
								)
				 ) ,
			section2QT
			  as (select	count(*) [T2PreAssessmentBeforePeriod]
				  from		PreAssessmentCasesAtBeginningOfPeriodT
				 ) ,
			TotalCasesToBeAssessedThisPeriod_2_1eT
			  as (select distinct
							isnull(a.HVCasePK, b.HVCasePK) [HVCasePK]
				  from		PreAssessmentCasesAtBeginningOfPeriodT as a
				  full outer join ScreensThisPeriod_1eT as b on a.HVCasePK = b.HVCasePK
				 ) ,
			PreAssessment_MaxPADateT
			  as (select	a.HVCaseFK
						  , max(a.PADate) [max_PADATE]
				  from		Preassessment as a
				  join		dbo.SplitString(@programfk, ',') on a.programfk = listitem
				  where		a.PADate between @StartDtT and @EndDt
				  group by	a.HVCaseFK
				 ) ,
			PreAssessment_LastOneInPeriodT
			  as (select	a.HVCaseFK
						  , a.CaseStatus
						  , a.FSWAssignDate
						  , a.KempeResult
						  , a.PADate
				  from		Preassessment as a
				  join		PreAssessment_MaxPADateT as b on a.HVCaseFK = b.HVCaseFK
															 and a.PADate = b.max_PADATE
				 ) ,
			OutcomesT
			  as (select	a.HVCasePK
						  , b.*
				  from		TotalCasesToBeAssessedThisPeriod_2_1eT as a
				  left outer join PreAssessment_LastOneInPeriodT as b on a.HVCasePK = b.HVCaseFK
				 ) ,
			section4QT
			  as (select	count(*) [T3TotalCasesThisPerion]
						  , sum(case when CaseStatus in ('02', '04') then 1
									 else 0
								end) [T4bCompleted]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate <= @EndDt then 1
									 else 0
								end) [T4b1PositiveAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 1
										  and FSWAssignDate > @EndDt then 1
									 else 0
								end) [T4b2PositivePendingAssignd]
						  , sum(case when CaseStatus = '04'
										  and KempeResult = 1
										  and FSWAssignDate is null then 1
									 else 0
								end) [T4b3PositiveNotAssignd]
						  , sum(case when CaseStatus = '02'
										  and KempeResult = 0 then 1
									 else 0
								end) [T4b4Negative]
						  , sum(case when CaseStatus = '03' then 1
									 else 0
								end) [T4cTerminated]
						  , sum(case when CaseStatus = '01'
										  and datediff(d, PADate, @EndDt) <= 30 then 1
									 else 0
								end) [T4aEffortContnue]
				  from		OutcomesT
				 ) ,
			section1QXT
			  as (select	sum(1) [T1Screened]
						  , sum(case when ScreenResult = 1 then 1
									 else 0
								end) [T1aScreenResultPositive]
						  , sum(case when ScreenResult != 1 then 1
									 else 0
								end) [T1bScreenResultNegative]
						  , sum(case when DOB > ScreenDate then 1
									 else 0
								end) [T1cPrenatal]
						  , sum(case when DOB <= ScreenDate then 1
									 else 0
								end) [T1dPostnatal]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 1 then 1
									 else 0
								end) [T1ePositiveReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0 then 1
									 else 0
								end) [T1fPositiveNotReferred]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason in ('05', '07', '35', '36', '06', '08', '33', '34', '99',
																  '13', '25') then 1
									 else 0
								end) [T1DischargeAll]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '05' then 1
									 else 0
								end) [T1f1IncomeIneligible]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '07' then 1
									 else 0
								end) [T1f2OutOfGeoTarget]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '35' then 1
									 else 0
								end) [T1f3NonCompliant]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '36' then 1
									 else 0
								end) [T1f3Refuse]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '06' then 1
									 else 0
								end) [T1f4InappropriateScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '08' then 1
									 else 0
								end) [T1f5CaseLoadFull]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '33' then 1
									 else 0
								end) [T1f6PositiveScreen]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '34' then 1
									 else 0
								end) [T1f7SubsequentBirthOnOpenCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '99' then 1
									 else 0
								end) [T1f8Other]
						  , 0 [T1f9NoReason]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '13' then 1
									 else 0
								end) [T1f10ControlCase]
						  , sum(case when ScreenResult = 1
										  and ReferralMade = 0
										  and DischargeReason = '25' then 1
									 else 0
								end) [T1f11Transferred]
				  from		ScreensThisPeriodT
				 ) ,
			section1QT
			  as (select	T1Screened
						  , cast(cast(case when T1Screened > 0
										   then round(100.0 * T1aScreenResultPositive / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1aScreenResultPositive]
						  , cast(cast(case when T1Screened > 0
										   then round(100.0 * T1bScreenResultNegative / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1bScreenResultNegative]
						  , cast(cast(case when T1Screened > 0 then round(100.0 * T1cPrenatal / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1cPrenatal]
						  , cast(cast(case when T1Screened > 0 then round(100.0 * T1dPostnatal / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1dPostnatal]
						  , T1ePositiveReferred
						  , T1fPositiveNotReferred
						  , cast(cast(case when T1Screened > 0 then round(100.0 * T1ePositiveReferred / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1ePositiveReferredPercent]
						  , cast(cast(case when T1Screened > 0
										   then round(100.0 * T1fPositiveNotReferred / T1Screened, 0)
										   else 0
									  end as int) as varchar(20)) + '%' [T1fPositiveNotReferredPercent]
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f1IncomeIneligible / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f1IncomeIneligible
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f2OutOfGeoTarget / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f2OutOfGeoTarget
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f3NonCompliant / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f3NonCompliant
						  , cast(cast(case when T1DischargeAll > 0 then round(100.0 * T1f3Refuse / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f3Refuse
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f4InappropriateScreen / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f4InappropriateScreen
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f5CaseLoadFull / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f5CaseLoadFull
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f6PositiveScreen / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f6PositiveScreen
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f7SubsequentBirthOnOpenCase / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f7SubsequentBirthOnOpenCase
						  , cast(cast(case when T1DischargeAll > 0 then round(100.0 * T1f8Other / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f8Other
						  , cast(cast(case when T1DischargeAll > 0 then round(100.0 * T1f9NoReason / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f9NoReason
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f10ControlCase / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f10ControlCase
						  , cast(cast(case when T1DischargeAll > 0
										   then round(100.0 * T1f11Transferred / T1DischargeAll, 0)
										   else 0
									  end as int) as varchar(20)) + '%' T1f11Transferred
				  from		section1QXT
				 ) ,
			section5QT
			  as (select	sum(PAParentLetter) [T5aPAParentLetter]
						  , sum(PACall2Parent) [T5bPACall2Parent]
						  , sum(PACallFromParent) [T5cPACallFromParent]
						  , sum(PAVisitAttempt) [T5dPAVisitAttempt]
						  , sum(PAVisitMade) [T5ePAVisitMade]
						  , sum(PAOtherHVProgram) [T5fPAOtherHVProgram]
						  , sum(PAParent2Office) [T5gPAParent2Office]
						  , sum(PAProgramMaterial) [T5hPAProgramMaterial]
						  , sum(PAGift) [T5iPAGift]
						  , sum(PACaseReview) [T5jPACaseReview]
						  , sum(PAOtherActivity) [T5kPAOtherActivity]
				  from		Preassessment
				  join		dbo.SplitString(@programfk, ',') on programfk = listitem
				  where		PADate between @StartDtT and @EndDt
				 ) ,
			xxxx
			  as (select	section1Q.*
						  , section2Q.*
						  , section4Q.*
						  , 0 [Q4dNoStatus1]
						  , 0 [Q4dNoStatus2]
						  , section4Q.Q3TotalCasesThisPerion - ([Q4aEffortContnue] + [Q4bCompleted] + [Q4cTerminated]) as [Q4dNoStatus]
						  , section5Q.*
						  , section1QT.*
						  , section2QT.*
						  , section4QT.*
						  , 0 [T4dNoStatus1]
						  , 0 [T4dNoStatus2]
						  , section4QT.T3TotalCasesThisPerion - ([T4aEffortContnue] + [T4bCompleted] + [T4cTerminated]) as [T4dNoStatus]
						  , section5QT.*
				  from		section1Q
				  join		section2Q on 1 = 1
				  join		section4Q on 1 = 1
				  join		section5Q on 1 = 1
				  join		section1QT on 1 = 1
				  join		section2QT on 1 = 1
				  join		section4QT on 1 = 1
				  join		section5QT on 1 = 1
				 )
		select	*
		from	xxxx


GO
