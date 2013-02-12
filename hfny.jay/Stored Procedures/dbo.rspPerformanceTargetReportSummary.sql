
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 11, 2013>
-- Description:	<This Performance Target report gets you 'Summary for all Performance Target reports '>

-- rspPerformanceTargetReportSummary 19 ,'10/01/2012' ,'12/31/2012'

-- =============================================

CREATE PROCEDURE [dbo].[rspPerformanceTargetReportSummary](
@programfk    varchar(max)    = NULL,
@sdate        datetime,
@edate        datetime,
@workerfk     int             = NULL,
@sitefk int             = NULL,
@casefilterspositive  varchar(100) = '' 
)


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

/** For performance reasons, get the active cases that belong to the cohort now **/
/* Declare a variable that references the type. */
DECLARE @tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod AS PTCases; -- PTCases is a user defined type

/* Add data to the table variable. */
INSERT INTO @tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod 
      (HVCaseFK
      , PC1ID
      , PC1FullName
      , CurrentWorkerFK
      , CurrentWorkerFullName
      , CurrentLevel
      , ProgramFK
      )
    SELECT HVCasePK
    , PC1ID
    , P.PCFirstName + ' ' + P.PCLastName AS PC1FullName
    , cp.CurrentFSWFK
    , w.FirstName + ' ' + w.LastName AS CurrentWorkerFullName
    , cp.CurrentLevelFK
    , @programfk
    FROM HVCase 
    INNER JOIN CaseProgram cp ON cp.HVCaseFK = HVCase.HVCasePK
    INNER JOIN PC P ON P.PCPK = HVCase.PC1FK
    INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
    WHERE cp.ProgramFK = @programfk
    AND (dischargedate is null or dischargedate >= @edate)

--SELECT * FROM @tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod

/***************************/


DECLARE @tbl4PerformanceTargetReportSummary TABLE(	
	[ReportTitleText] varchar(max),
	[PercentageMeetingPT] [varchar](50),
	[NumberMeetingPT] [varchar](50),
	[TotalValidCases] [varchar](50),
	[TotalCase] [varchar](50)	
	
)

		



--Note: passing 'summary' will return just one line containg [ReportTitleText],[PercentageMeetingPT],[NumberMeetingPT],[TotalValidCases],[TotalCase]

--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD1 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD2 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD3 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD4 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD5 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD6 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD7 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD8 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page

--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC11 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC12 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC13 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC14 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC15 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC16 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page


--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC1 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC2 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC3 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC4 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC5 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC6 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page
--INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC7 @sdate, @edate ,@tbl4PTMainCohortContainingActiveCasesAtEndOfPeriod ,'summary'	--- for summary page

--SELECT * FROM @tbl4PerformanceTargetReportSummary
END
GO
