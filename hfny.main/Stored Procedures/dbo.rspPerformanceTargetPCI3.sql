SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 20130228
-- Description:	gets data for Performance Target report - PCI3. Reducing Parental Stress in highly stressed families 
--				by the target child's six month birthday
-- rspPerformanceTargetReportSummary 19, '07/01/2012', '09/30/2012', null, null, 0, null
-- =============================================
CREATE PROC [dbo].[rspPerformanceTargetPCI3]
(
    @StartDate      datetime,
    @EndDate		datetime,
    @tblPTCases		PTCases readonly,
    @ReportType		char(7)    = null
)

as
begin

DECLARE @tblCohort TABLE (
	HVCaseFK INT,
	PC1ID CHAR(13),
	OldID VARCHAR(23),
	PC1FullName VARCHAR(MAX),
	CurrentWorkerFK INT,
	CurrentWorkerFullName VARCHAR(MAX),
	CurrentLevelName VARCHAR(50),
	ProgramFK INT,
	TCIDPK INT,
	TCDOB DATETIME,
	DischargeDate DATETIME,
	tcAgeDays INT,
	lastDate DATETIME
);

	with cteTotalCases
	as
	(
	select
		  ptc.HVCaseFK
		 , ptc.PC1ID
		 , ptc.OldID
		 , ptc.PC1FullName
		 , ptc.CurrentWorkerFK
		 , ptc.CurrentWorkerFullName
		 , ptc.CurrentLevelName
		 , ptc.ProgramFK
		 , ptc.TCIDPK
		 , ptc.TCDOB
		 , DischargeDate
		 , case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  datediff(day,ptc.tcdob,DischargeDate)
			  else
				  datediff(day,ptc.tcdob,@EndDate)
		  end as tcAgeDays
		 , case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  DischargeDate
			  else
				  @EndDate
		  end as lastdate
		from @tblPTCases ptc
			inner join HVCase h WITH (NOLOCK) on ptc.hvcaseFK = h.HVCasePK
			inner join CaseProgram cp WITH (NOLOCK) on cp.CaseProgramPK = ptc.CaseProgramPK
			-- h.hvcasePK = cp.HVCaseFK and cp.ProgramFK = ptc.ProgramFK -- AND cp.DischargeDate IS NULL
	)
	INSERT INTO @tblCohort
		select tc.*	
			from cteTotalCases tc
			inner join HVCase c WITH (NOLOCK) on c.HVCasePK = tc.HVCaseFK
			INNER JOIN dbo.codeDueByDates cdbd ON cdbd.ScheduledEvent = 'Follow Up' AND cdbd.Interval = '18'
			where dateadd(day, cdbd.DueBy, tc.TCDOB) between @StartDate and @EndDate;
	
	WITH cte6MonthCCI
	AS
		(
		SELECT cci.CheersCheckInPK,
		coh.HVCaseFK,
		cci.TCIDFK,
		cci.ObservationDate,
		cci.TotalScore
		FROM dbo.CheersCheckIn cci
		INNER JOIN @tblCohort coh ON coh.HVCaseFK = cci.HVCaseFK AND coh.ProgramFK = cci.ProgramFK
		WHERE cci.Interval = '06' AND cci.TotalScore <= 18
		)
	,
	cte18MonthCCI
	AS
		(
		SELECT cci.CheersCheckInPK,
		coh.HVCaseFK,
		cci.TCIDFK,
		cci.ObservationDate,
		cci.TotalScore
		FROM dbo.CheersCheckIn cci
		INNER JOIN @tblCohort coh ON coh.HVCaseFK = cci.HVCaseFK AND coh.ProgramFK = cci.ProgramFK
		WHERE cci.Interval = '18'
		)
	,
	--cteExpectedForm
	--as
	--	(
	--	select coh.HVCaseFK
	--			, PSIPK
	--		from cteCohort coh
	--		left outer join PSI P on coh.hvcaseFK = P.HVCaseFK 
	--		where PSIInterval = '00' -- in ('00','01','02')
	--	)
	--,
	cteMain
	as
		(select DISTINCT 'PCI3' as PTCode
			  , coh.HVCaseFK
			  , PC1ID
			  , OldID
			  , t.TCDOB
			  , t.TCFirstName
			  , t.TCLastName
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , '18-month Cheers Check-In' as FormName
			  , eighteenMonthCCI.ObservationDate as FormDate		
			  , case when (fr.ReviewedBy IS NOT NULL OR (fr.ReviewedBy IS NULL AND fro.FormReviewOptionsPK IS NULL)) then 1 else 0 end as FormReviewed
			  , case when (eighteenMonthCCI.ObservationDate IS NOT NULL AND eighteenMonthCCI.ObservationDate NOT BETWEEN DATEADD(dd, cdbd.MinimumDue, coh.TCDOB) AND DATEADD(dd, cdbd.MaximumDue, coh.TCDOB)) THEN 1 else 0 end as FormOutOfWindow
			  , case when eighteenMonthCCI.CheersCheckInPK is null then 1 else 0 end as FormMissing
			  --, case when cci.CheersCheckInPK is not null then 1 else 0 end as FormMeetsTarget
			  , eighteenMonthCCI.TotalScore AS EighteenMonthScore
			  from @tblCohort coh
				INNER JOIN dbo.TCID t ON t.HVCaseFK = coh.HVCaseFK
				INNER JOIN cte6MonthCCI sixMonthCCI ON sixMonthCCI.HVCaseFK = coh.HVCaseFK AND sixMonthCCI.TCIDFK = t.TCIDPK
				LEFT JOIN cte18MonthCCI eighteenMonthCCI ON eighteenMonthCCI.HVCaseFK = sixMonthCCI.HVCaseFK AND eighteenMonthCCI.TCIDFK = sixMonthCCI.TCIDFK
			    LEFT JOIN dbo.codeDueByDates cdbd ON cdbd.ScheduledEvent = 'CHEERS' AND cdbd.Interval = '18'
				LEFT JOIN dbo.FormReview fr ON fr.HVCaseFK = coh.HVCaseFK
					AND fr.FormType = 'CC'
					AND fr.FormFK = eighteenMonthCCI.CheersCheckInPK
			    LEFT JOIN dbo.FormReviewOptions fro ON fro.FormType = 'CC' 
					AND fro.ProgramFK = coh.ProgramFK
					AND eighteenMonthCCI.ObservationDate BETWEEN fro.FormReviewStartDate AND ISNULL(fro.FormReviewEndDate, eighteenMonthCCI.ObservationDate)
		)
	select PTCode
				, HVCaseFK
				, PC1ID
				, OldID
				, TCDOB
				, PC1FullName
				, CurrentWorkerFullName
				, CurrentLevelName
				, FormName
				, FormDate
				, FormReviewed
				, FormOutOfWindow
				, FormMissing
				, case when FormMissing = 0 and FormOutOfWindow = 0 and FormReviewed = 1 
							AND cteMain.EighteenMonthScore > 18 then 1 else 0 end as FormMeetsTarget
				, case when FormMissing = 1 THEN 'Form missing for child: ' + cteMain.TCFirstName + ' ' + cteMain.TCLastName
						WHEN FormOutOfWindow = 1 then 'Form out of window for child: ' + cteMain.TCFirstName + ' ' + cteMain.TCLastName
						when cteMain.EighteenMonthScore <= 18 THEN 'Total score below cutoff on form for child: ' + cteMain.TCFirstName + ' ' + cteMain.TCLastName
						when FormReviewed = 0 then 'Form not reviewed by supervisor for child: ' + cteMain.TCFirstName + ' ' + cteMain.TCLastName
						else '' end as ReasonNotMeeting
	from cteMain
	-- order by OldID

	-- if (select HVCaseFK from cteMain) 
	
	
--select * from cteTotalCases
	--select * from cteCohort	--	begin
	--		select ReportTitleText
	--			  ,PC1ID
	--			  ,TCDOB
	--			  ,Reason
	--			  ,CurrentWorker
	--			  ,LevelAtEndOfReport
	--			  ,Explanation
	--			from @tblPTReportNotMeetingPT
	--			order by CurrentWorker
	--					,PC1ID
	--	end
end
GO
