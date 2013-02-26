
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 11, 2013>
-- Description:	<This Performance Target report gets you 'Summary for all Performance Target reports '>
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- mods by jrobohn 20130222 - clean up names, code and layout
-- mods by jrobohn 20130223 - added PCI1 report
-- =============================================

CREATE procedure [dbo].[rspPerformanceTargetReportSummary]
(
    @ProgramFKs				varchar(max)    = null,
    @StartDate				datetime,
    @EndDate				datetime,
    @FSWFK					int             = null,
    @SiteFK					int             = null,
    @IncludeClosedCases		bit             = 0,
    @CaseFiltersPositive	varchar(100)    = ''
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @CaseFiltersPositive = case when @CaseFiltersPositive = '' then null else @CaseFiltersPositive end

	/** For performance reasons, get the active cases that belong to the cohort now **/
	/* Declare a variable that references the type. */
	declare @tblPTCohort as PTCases; -- PTCases is a user defined type

	/* Add data to the table variable. */
	insert into @tblPTCohort (HVCaseFK
							 , PC1ID
							 , PC1FullName
							 , CurrentWorkerFK
							 , CurrentWorkerFullName
							 , CurrentLevelName
							 , ProgramFK
							 , TCIDPK
							 , TCDOB
			   )
		select
			  HVCasePK
			 , PC1ID
			 , rtrim(P.PCFirstName) + ' ' + rtrim(P.PCLastName) as PC1FullName
			 , cp.CurrentFSWFK
			 , rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as CurrentWorkerFullName
			 , LevelName as CurrentLevelName
			 , @ProgramFKs
			 , tcid.TCIDPK
			 , case
				  when h.tcdob is not null then
					  h.tcdob
				  else
					  h.edc
			  end as TCDOB
			from HVCase h
				inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
				inner join PC P on P.PCPK = h.PC1FK
				inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
				inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
				inner join codeLevel l on l.codeLevelPK = cp.CurrentLevelFK
				inner join dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFKs) cf on cf.HVCaseFK = h.HVCasePK
				left join tcid on tcid.hvcasefk = h.hvcasepk -- for dead babies dod
			where
				 cp.ProgramFK = @ProgramFKs
				 and h.CaseProgress >= 9
				 -- dead babies
				 and (h.IntakeDate is not null
					 and h.IntakeDate <= @EndDate
					and h.TCDOD is null)
				 and (tcid.TCDOD is null
						or tcid.TCDOD > @EndDate) -- 5/23/05 JH/DB if all children are dead don't include in performance target (FoxPro)
				 -- inclusion / exclusion of closed case
				 and (cp.DischargeDate is null
					or case -- closed cases are not included
						 when @IncludeClosedCases = 0 then
							 (case
								 when cp.DischargeDate > @EndDate then
									 1
								 else
									 0
							 end)
						 else -- include closed cases
							 (case
								 when cp.DischargeDate >= @StartDate then
									 1
								 else
									 0
							 end)
					 end = 1)
				 --siteFK
				 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

	--SELECT * FROM @tblPTCohort

	/***************************/

	declare @tblPTSummary table(
		[ReportTitleText] varchar(max),
		[PercentageMeetingPT] [varchar](50),
		[NumberMeetingPT] [varchar](50),
		[TotalValidCases] [varchar](50),
		[TotalCases] [varchar](50)
	)

	declare @tblPTDetails table
		(
		HVCaseFK			int
		, PC1ID				char(13)
		, TCDOB				datetime
		, PC1Fullname		varchar(50)
		, WorkerFullName	varchar(50)
		, CurrentLevelName	varchar(20)
		, FormDate			datetime
		, FormReviewed		bit
		, FormOutOfWindow	bit
		, FormMissing		bit
		, FormMeetsStandard	bit
		)
		
	--Note: passing 'summary' will return just one line containg [ReportTitleText],[PercentageMeetingPT],[NumberMeetingPT],[TotalValidCases],[TotalCase]
	--- for summary page
	--For testing
	--exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort,'summary'
	insert into @tblPTSummary
		exec rspPerformanceTargetHD1 @StartDate,@EndDate,@tblPTCohort,'summary'

	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD1 @StartDate, @EndDate, @tblPTCohort, 'summary' 
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD2 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD3 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD4 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD5 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD6 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD7 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetHD8 @StartDate, @EndDate ,@tblPTCohort ,'summary'

	insert into @tblPTSummary
		exec rspPerformanceTargetPCI1 @StartDate,@EndDate,@tblPTCohort,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetPCI2 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetPCI3 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetPCI4 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetPCI5 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetPCI6 @StartDate, @EndDate ,@tblPTCohort ,'summary'

	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetMLC1 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetMLC2 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetMLC3 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetMLC4 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetMLC5 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetMLC6 @StartDate, @EndDate ,@tblPTCohort ,'summary'
	--INSERT INTO @tblPTSummary 
	--				EXEC rspPerformanceTargetMLC7 @StartDate, @EndDate ,@tblPTCohort ,'summary'

	select *
		from @tblPTSummary

end
GO
