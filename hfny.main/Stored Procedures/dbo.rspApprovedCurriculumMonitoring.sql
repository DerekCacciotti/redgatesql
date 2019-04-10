SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 04/09/19
-- Description:	Approved Curriculum Monitoring Report
-- =============================================
CREATE PROC [dbo].[rspApprovedCurriculumMonitoring] 
	-- Add the parameters for the stored procedure here
	@ProgramFK	VARCHAR(MAX) = NULL,
	@StartDate datetime,
	@EndDate datetime,
	@SiteFK INT = NULL,
    @CaseFiltersPositive varchar(100) = '',
	@FSWFK INT = NULL

AS
BEGIN
	 IF @ProgramFK IS NULL
	BEGIN
		SELECT @ProgramFK = SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
											FROM HVProgram
											FOR XML PATH ('')),2,8000);
	END
	SET @ProgramFK = REPLACE(@ProgramFK,'"','')
	set @CaseFiltersPositive = case when @CaseFiltersPositive = '' then null else @CaseFiltersPositive end
	SET @SiteFK = isnull(@SiteFK, 0)

	declare @Cohort as table (
	  HVCaseFK int
	 , PC1ID char(13)
	 , Curriculum247Dads bit
	 , CurriculumBoyz2Dads bit
	 , CurriculumGreatBeginnings bit
	 , CurriculumGrowingGreatKids bit
	 , CurriculumHelpingBabiesLearn bit
	 , CurriculumInsideOutDads bit
	 , CurriculumMomGateway bit
	 , CurriculumParentsForLearning bit
	 , CurriculumPartnersHealthyBaby bit
	 , CurriculumPAT bit
	 , CurriculumPATFocusFathers bit
	 , CurriculumSanAngelo bit
	 , CurriculumUsed bit
	)

	declare @UsedCurriculum as table (
	   HVCaseFK int
	 , UsedCurriculum bit
	)

	declare @Results as table (
		TotalCases int
	   ,CasesWithApprovedCurricula int
	   ,CasesWithoutApprovedCurricula int
	   ,PC1IDNoCurricula char(13)
	)


	--get cases that had a homevisit in time period
	insert into @Cohort (
	    hvcasefk
		, PC1ID
		, Curriculum247Dads
		, CurriculumBoyz2Dads
		, CurriculumGreatBeginnings
		, CurriculumGrowingGreatKids
		, CurriculumHelpingBabiesLearn
		, CurriculumInsideOutDads
		, CurriculumMomGateway
		, CurriculumParentsForLearning
		, CurriculumPartnersHealthyBaby
		, CurriculumPAT
		, CurriculumPATFocusFathers
		, CurriculumSanAngelo)

	select hv.hvcasefk
		, cp.PC1ID
		, Curriculum247Dads
		, CurriculumBoyz2Dads
		, CurriculumGreatBeginnings
		, CurriculumGrowingGreatKids
		, CurriculumHelpingBabiesLearn
		, CurriculumInsideOutDads
		, CurriculumMomGateway
		, CurriculumParentsForLearning
		, CurriculumPartnersHealthyBaby
		, CurriculumPAT
		, CurriculumPATFocusFathers
		, CurriculumSanAngelo from hvlog hv
		INNER JOIN dbo.CaseProgram cp on cp.HVCaseFK = hv.HVCaseFK 
		INNER JOIN dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFK) cf ON cf.HVCaseFK = hv.HVCaseFK
		INNER JOIN dbo.Worker w ON w.WorkerPK = cp.CurrentFSWFK
		INNER JOIN dbo.WorkerProgram wp ON wp.WorkerFK = w.WorkerPK AND wp.ProgramFK = cp.ProgramFK		
		INNER JOIN dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
		where VisitStartTime between @StartDate and @EndDate and substring(VisitType, 4, 1) <> '1' 
		AND cp.CurrentFSWFK = ISNULL(@FSWFK, cp.CurrentFSWFK)

	
	--find cases that did use curriculum
	insert @UsedCurriculum (hvcasefk, UsedCurriculum)
	select distinct hvcasefk, 1 from @Cohort c where  
								Curriculum247Dads = 1
							 or CurriculumBoyz2Dads = 1
							 or CurriculumGreatBeginnings = 1
							 or CurriculumGrowingGreatKids = 1
							 or CurriculumHelpingBabiesLearn = 1
							 or CurriculumInsideOutDads = 1
							 or CurriculumMomGateway = 1
							 or CurriculumParentsForLearning = 1
							 or CurriculumPartnersHealthyBaby = 1
							 or CurriculumPAT = 1
							 or CurriculumPATFocusFathers = 1
							 or CurriculumSanAngelo = 1
	
	--fill results table with cases that did not use curriculum
	insert into @Results(PC1IDNoCurricula)
	select distinct c.PC1ID from @Cohort c left join @UsedCurriculum uc on uc.HVCaseFK = c.HVCaseFK where uc.UsedCurriculum is null

	--count total cases
	update @Results set TotalCases = (select count(distinct hvcasefk) from @Cohort c)

	--count cases that used curriculum
	update @Results set CasesWithApprovedCurricula = (select count(*) from @UsedCurriculum uc)

	--count cases that did not use curriculum
	update @Results set CasesWithoutApprovedCurricula = (select count(distinct hvcasefk) from @Cohort c where c.HVCaseFK not in (select hvcasefk from @UsedCurriculum uc))

	select * from @Results
END
GO
