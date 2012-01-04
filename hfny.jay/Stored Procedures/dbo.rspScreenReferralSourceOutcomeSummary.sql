SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Report - Screen Referral Source Outcome Summary>
-- =============================================

CREATE PROCEDURE [dbo].[rspScreenReferralSourceOutcomeSummary](@programfk VARCHAR(MAX) = NULL
																,@sdate datetime
																,@edate datetime)
AS

IF @programfk IS NULL BEGIN
	SELECT @programfk = 
		SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
					FROM HVProgram
					FOR XML PATH('')),2,8000)
END

SET @programfk = REPLACE(@programfk,'"','')

select ReferralSourceName
		,screens
		,positivescreen
		,positivescreen/(screens * 1.0) as ppositivescreen
		,ClosedPreassessment
		,case when positivescreen > 0 then ClosedPreassessment / (positivescreen * 1.0) else 0 end as pClosedPreassessment
		,PreAssessmentPendingAssessment
		,case when positivescreen > 0 then PreAssessmentPendingAssessment / (positivescreen * 1.0) else 0 end as pPreAssessmentPendingAssessment
		,PreintakeAssessmentCompleteAssigned
		,case when positivescreen > 0 then PreintakeAssessmentCompleteAssigned / (positivescreen * 1.0) else 0 end as pPreintakeAssessmentCompleteAssigned
		,ClosedAssessmentCompleteNotAssigned
		,case when positivescreen > 0 then ClosedAssessmentCompleteNotAssigned / (positivescreen * 1.0) else 0 end as pClosedAssessmentCompleteNotAssigned
		,ClosedPreIntakeAssessmentCompleteAssigned
		,case when positivescreen > 0 then ClosedPreIntakeAssessmentCompleteAssigned / (positivescreen * 1.0) else 0 end as pClosedPreIntakeAssessmentCompleteAssigned
		,Enrolled
		,case when positivescreen > 0 then Enrolled / (positivescreen * 1.0) else 0 end as pEnrolled
from(
	select count(HVCase.PC1FK) screens,
	SUM(case when ScreenResult=1 and ReferralMade=1 then 1 else 0 end) positivescreen,
	SUM(Case when caseprogress = 3 then 1 else 0 end) ClosedPreassessment,
	SUM(Case when CurrentLevelFK = 5 then 1 else 0 end) PreAssessmentPendingAssessment,
	SUM(Case when currentlevelfk = 9 then 1 else 0 end) PreintakeAssessmentCompleteAssigned,
	SUM(Case when CaseProgress = 4 and DischargeDate <> null then 1 else 0 end) ClosedAssessmentCompleteNotAssigned,
	SUM(Case when CaseProgress = 7 then 1 else 0 end) ClosedPreIntakeAssessmentCompleteAssigned,
	SUM(CASE when intakedate IS NOT NULL then 1 else 0 end) Enrolled,
	ReferralSourceName
	from hvscreen
	inner join HVCase
	on HVScreen.HVCaseFK = HVCasePK
	inner join caseprogram
	on caseprogram.hvcasefk = hvcasepk
	inner join dbo.listReferralSource
	on ReferralSourceFK = listReferralSourcePK
	INNER JOIN dbo.SplitString(@programfk,',')
	ON caseprogram.programfk  = listitem
	where hvscreen.ScreenDate between @sdate and @edate
	group by ReferralSourceName) t
order by screens desc

GO
