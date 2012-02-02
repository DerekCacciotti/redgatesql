
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 24, 2011>
-- Description:	<Gets all items in the codeReportCatalog table>
-- =============================================
CREATE procedure [dbo].[spGetAllReports](@strProgramFK varchar(3) = null,
										@UserName varchar(15) = null)

as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;
	declare @ProgramFK int = cast(@strProgramFK as int);
	
	-- Insert statements for procedure here
	with cteLastRunByUser
		as 
		(
		select ProgramFK,ReportFK,max(TimeRun) as UserLastRun
		from ReportHistory rh
		where ProgramFK=@ProgramFK
				and UserFK=@UserName
		group by ProgramFK, ReportFK
		)
	,cteLastRunByProgram
		as 
		(
		select ProgramFK,ReportFK,max(TimeRun) as ProgramLastRun
		from ReportHistory rh
		where ProgramFK=@ProgramFK
		group by ProgramFK, ReportFK
		)
	,cteFrequencyByUser
		as
		(
		select ROW_NUMBER() over(order by count(ReportFK) desc) as UserRank,Count(ReportFK) as UserCount,ReportFK
		from ReportHistory rh
		where ProgramFK=@ProgramFK
				and UserFK=@UserName
		group by ProgramFK, ReportFK
		
		)
	,cteFrequencyByProgram
		as
		(
		select ROW_NUMBER() over(order by count(ReportFK) desc) as ProgramRank,Count(ReportFK) as ProgramCount,ReportFK
		from ReportHistory rh
		where ProgramFK=@ProgramFK
		group by ProgramFK, ReportFK
		
		)
select codeReportCatalogPK
	  ,rc.ReportName
	  ,ReportCategory
	  ,ReportDescription
	  ,ReportClass
	  ,CriteriaOptions
	  ,Defaults
	  ,'O:'+rtrim(CriteriaOptions)+' D(calc):'
	   +rtrim(dbo.CalculateReportDefaults([Defaults]))+' D(raw):'+rtrim([Defaults]) as DefaultsBag
	  ,Keywords
	  ,convert(varchar(10),UserLastRun,101) as UserLastRun
	  ,convert(varchar(10),ProgramLastRun,101) as ProgramLastRun
	  ,isnull(UserRank,0) as UserRank
	  ,isnull(ProgramRank,0) as ProgramRank
	from codeReportCatalog rc
		left outer join cteLastRunByUser lrbu on lrbu.ReportFK=rc.codeReportCatalogPK
		left outer join cteLastRunByProgram lrbp on lrbp.ReportFK=rc.codeReportCatalogPK
		left outer join cteFrequencyByUser fbu on fbu.ReportFK=rc.codeReportCatalogPK
		left outer join cteFrequencyByProgram fbp on fbp.ReportFK = rc.codeReportCatalogPK
	where ReportClass is not null
	order by [ReportCategory]
			,[ReportName]
end
GO
