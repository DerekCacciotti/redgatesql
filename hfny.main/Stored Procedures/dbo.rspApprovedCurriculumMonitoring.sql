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
	@ProgramFK	VARCHAR(MAX) = Null,
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
	 , CasesOnLevel4 int
	 , CasesNoLevel4 int
	 , CasesWithApprovedCurriculaOnLevel4 int
	 , CasesWithApprovedCurriculaNoLevel4 int
	 , CasesWithCurriculaOnLevel4 int
	 , CasesWithCurriculaNoLevel4 int
	 , CasesWithNoApprovedCurriculaOnLevel4 int
	 , CasesWithNoApprovedCurriculaNoLevel4 int
	 , CaseOnLevel4 int
	 , CurriculumUsed int
	 , ApprovedCurriculumUsed int
	 , Curriculum247Dads int
	 , CurriculumBoyz2Dads int
	 , CurriculumGreatBeginnings int
	 , CurriculumGrowingGreatKids int
	 , CurriculumHelpingBabiesLearn int
	 , CurriculumInsideOutDads int
	 , CurriculumMomGateway int
	 , CurriculumParentsForLearning int
	 , CurriculumPartnersHealthyBaby int
	 , CurriculumPAT int
	 , CurriculumPATFocusFathers int
	 , CurriculumSanAngelo int	 
	)

	declare @CaseLevels as table (
		HVCaseFK int
		, LevelAssignDate datetime
		, LevelFK int
		, RowNum int
	)

	declare @CaseOnLevel4 as table (
		HVCaseFK int
	  , Level4AssignDate datetime
	  , RowNum int
	)

	declare @CaseLevelAfter4 as table (
	   HVCaseFK int
	 , LevelAssignDate datetime
	 , RowNum int
	)

	declare @CaseNoApprovedCurriculum as table (
	   HVCaseFK int
	  ,ApprovedCurriculumNotUsed int
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
		, case when Curriculum247Dads = 1 then 1 else 0 end
		, case when  CurriculumBoyz2Dads = 1 then 1 else 0 end
		, case when  CurriculumGreatBeginnings = 1 then 1 else 0 end
		, case when  CurriculumGrowingGreatKids = 1 then 1 else 0 end
		, case when  CurriculumHelpingBabiesLearn = 1 then 1 else 0 end
		, case when  CurriculumInsideOutDads = 1 then 1 else 0 end
		, case when  CurriculumMomGateway = 1 then 1 else 0 end
		, case when  CurriculumParentsForLearning = 1 then 1 else 0 end
		, case when   CurriculumPartnersHealthyBaby = 1 then 1 else 0 end
		, case when   CurriculumPAT = 1 then 1 else 0 end 
		, case when   CurriculumPATFocusFathers = 1 then 1 else 0 end 
		, case when   CurriculumSanAngelo = 1 then 1 else 0 end
		 from hvlog hv
		INNER JOIN dbo.CaseProgram cp on cp.HVCaseFK = hv.HVCaseFK 
		INNER JOIN dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFK) cf ON cf.HVCaseFK = hv.HVCaseFK
		INNER JOIN dbo.Worker w ON w.WorkerPK = cp.CurrentFSWFK
		INNER JOIN dbo.WorkerProgram wp ON wp.WorkerFK = w.WorkerPK AND wp.ProgramFK = cp.ProgramFK		
		INNER JOIN dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
		where VisitStartTime between @StartDate and @EndDate and substring(VisitType, 4, 1) <> '1' 
		AND cp.CurrentFSWFK = ISNULL(@FSWFK, cp.CurrentFSWFK)

	--find cases that used any curriculum
	update @Cohort 
	set CurriculumUsed = case when  Curriculum247Dads = 1
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
	then 1 else 0 end

	update @Cohort set 
	ApprovedCurriculumUsed = case when  
	       CurriculumGrowingGreatKids = 1
	    or CurriculumPartnersHealthyBaby = 1
	    or CurriculumPAT = 1
	    or CurriculumSanAngelo = 1
		then 1 else 0 end

	insert into @CaseNoApprovedCurriculum (HVCaseFK, ApprovedCurriculumNotUsed)
	select HVCaseFK
	      ,case when sum(c.ApprovedCurriculumUsed) > 0 then 0 else 1 end
    from @Cohort c group by HVCaseFK

	insert into @CaseLevels (HVCaseFK, LevelAssignDate, LevelFK, RowNum)
	select HVCaseFK
	     , LevelAssignDate
		 , LevelFK
		 , row_number() over (partition by hl.HVCaseFK order by hl.LevelAssignDate)
	from dbo.HVLevel hl
	where hvcasefk in (select hvcasefk from @Cohort c)

	insert @CaseOnLevel4 (HVCaseFK, Level4AssignDate, RowNum)
	select HVCaseFK
		 , LevelAssignDate
		 , RowNum
	from @CaseLevels where LevelFK = 20

	insert @CaseLevelAfter4 (HVCaseFK, LevelAssignDate, RowNum)
	select cl.hvcasefk, LevelAssignDate, cl.RowNum from @CaseLevels cl inner join @CaseOnLevel4 col on col.HVCaseFK = cl.HVCaseFK
	where cl.RowNum - col.RowNum = 1

	--finding cases on level 4 in time period

	--if they started on level 4 in time period
	update @Cohort set CaseOnLevel4 = 1 where hvcasefk in (select hvcasefk from @CaseOnLevel4 col where col.Level4AssignDate between @StartDate and @EndDate)

	--if they started their next level during the time period
	update @Cohort set CaseOnLevel4 = 1 where hvcasefk in (select hvcasefk from @CaseLevelAfter4 cla where cla.LevelAssignDate between @StartDate and @EndDate)

	--if the last level they were assigned was level 4
    update @Cohort set CaseOnLevel4 = 1 where hvcasefk in 
	(select sub.hvcasefk from 
		(select hvcasefk, max(RowNum)[RowNum] from @CaseLevels cl group by hvcasefk) as sub
			inner join @CaseLevels on [@CaseLevels].HVCaseFK = sub.HVCaseFK and [@CaseLevels].RowNum = sub.RowNum where LevelFK = 20																)
	--count total cases

	update @Cohort set CaseOnLevel4 = 0 where CaseOnLevel4 is null

	update @Cohort set CasesOnLevel4 = (select count(distinct hvcasefk) from @Cohort c where CaseOnLevel4 = 1)
	update @Cohort set CasesNoLevel4 = (select count(distinct hvcasefk) from @Cohort c where CaseOnLevel4 = 0)

	update @Cohort set CasesWithApprovedCurriculaOnLevel4 = (select count(distinct hvcasefk) from @Cohort where ApprovedCurriculumUsed = 1 and CaseOnLevel4 = 1)
	update @Cohort set CasesWithApprovedCurriculaNoLevel4 = (select count(distinct hvcasefk) from @Cohort where ApprovedCurriculumUsed = 1 and CaseOnLevel4 = 0)

	update @Cohort set CasesWithCurriculaOnLevel4 = (select count(distinct hvcasefk) from @Cohort c where CurriculumUsed = 1 and CaseOnLevel4 = 1)
	update @Cohort set CasesWithCurriculaNoLevel4 = (select count(distinct hvcasefk) from @Cohort c where CurriculumUsed = 1 and CaseOnLevel4 = 0)

	update @Cohort set CasesWithNoApprovedCurriculaOnLevel4 = (select count(distinct cnac.hvcasefk) 
	                                                           from @CaseNoApprovedCurriculum cnac inner join @Cohort c on cnac.HVCaseFK = c.HVCaseFK 
															   where c.CaseOnLevel4 = 1 and cnac.ApprovedCurriculumNotUsed = 1)

    update @Cohort set CasesWithNoApprovedCurriculaNoLevel4 = (select count(distinct c.hvcasefk) 
	                                                           from @Cohort c inner join @CaseNoApprovedCurriculum cnac on cnac.HVCaseFK = c.HVCaseFK 
															   where c.CaseOnLevel4 = 0 and cnac.ApprovedCurriculumNotUsed = 1 )

	select c.HVCaseFK	
		 , c.PC1ID
		 , count(c.HVCaseFK) as VisitCount
		 , sum(c.ApprovedCurriculumUsed) as ApprovedCurriculumUsedCt
		 , sum(c.CurriculumUsed) as CurriculumUsedCt
		 , case when sum(c.ApprovedCurriculumUsed) > 0 then 0 else 1 end as ApprovedCurriculumNotUsed
		 , c.CaseOnLevel4 
		 , c.CasesOnLevel4
		 , c.CasesNoLevel4
		 , c.CasesWithApprovedCurriculaOnLevel4
		 , c.CasesWithApprovedCurriculaNoLevel4
		 , c.CasesWithCurriculaOnLevel4
		 , c.CasesWithCurriculaNoLevel4
		 , c.CasesWithNoApprovedCurriculaOnLevel4
		 , c.CasesWithNoApprovedCurriculaNoLevel4
	from @Cohort c
	group by c.PC1ID, c.HVCaseFK, c.CasesOnLevel4, c.CasesNoLevel4, c.CasesWithApprovedCurriculaOnLevel4,
	 c.CasesWithApprovedCurriculaNoLevel4, c.CasesWithCurriculaOnLevel4, c.CasesWithCurriculaNoLevel4, c.CasesWithNoApprovedCurriculaOnLevel4
		 , c.CasesWithNoApprovedCurriculaNoLevel4, c.CaseOnLevel4
	order by c.CaseOnLevel4, sum(c.ApprovedCurriculumUsed) 
END
GO
