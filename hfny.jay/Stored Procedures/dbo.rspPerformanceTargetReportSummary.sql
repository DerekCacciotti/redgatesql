SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 11, 2013>
-- Description:	<This Performance Target report gets you 'Summary for all Performance Target reports '>

-- rspPerformanceTargetReportSummary 1 ,'10/01/2012' ,'12/31/2012'

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

/*********** TODO ***********/

-- The  following table will be returned from Chris's UDF_PTCases function. Let us just name it right now
DECLARE @tbl4PTMainCohortContainingActiveAtEndOfPeriod TABLE(
	[FAKE_Column1] INT,
	[FAKE_Column2] [varchar](200),
	[FAKE_Column3] [varchar](100)
)
-- SET @tbl4PTMainCohortContainingActiveAtEndOfPeriod =  UDF_PTCases(@programfk,@sdate,@edate,@workerfk,@sitefk,@casefilterspositive)

/***************************/


DECLARE @tbl4PerformanceTargetReportSummary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)


INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD1 @sdate, @edate ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD2 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD3 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD4 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD5 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD6 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD7 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetHD8 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page

INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC11 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC12 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC13 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC14 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC15 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetPC16 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page


INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC1 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC2 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC3 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC4 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC5 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC6 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page
INSERT INTO @tbl4PerformanceTargetReportSummary EXEC rspPerformanceTargetMLC7 @programfk ,@tbl4PTMainCohortContainingActiveAtEndOfPeriod ,'summary'	--- for summary page




SELECT * FROM @tbl4PerformanceTargetReportSummary
END
GO
