SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 24, 2011>
-- Description:	<Gets all items in the codeReportCatalog table>
-- Edit Date: 12/09/2019 (Ben Simmons)
-- Edit Reason: Implemented the codeReportAccess table that will limit the reports that
-- users can see based on their state and the point in time that is passed to this stored proc.
-- =============================================
CREATE PROC [dbo].[spGetAllReports]
(
    @strProgramFK varchar(3)     = null,
    @UserName     varchar(50)    = NULL,
	@StateFK INT = NULL,
	@PointInTime DATETIME = NULL
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;
	declare @ProgramFK int = cast(@strProgramFK as int);

	-- Insert statements for procedure here
	with cteLastRunByUser
	as (select ProgramFK
			  ,ReportFK
			  ,max(TimeRun) as UserLastRun
			from dbo.ReportHistory rh
			where ProgramFK = @ProgramFK
				 and UserName = @UserName
			group by ProgramFK
					,ReportFK
	),
	cteLastRunByProgram
	as (select ProgramFK
			  ,ReportFK
			  ,max(TimeRun) as ProgramLastRun
			from dbo.ReportHistory rh
			where ProgramFK = @ProgramFK
			group by ProgramFK
					,ReportFK
	),
	cteFrequencyByUser
	as (select row_number() over (order by count(ReportFK) desc) as UserRank
			  ,count(ReportFK) as UserCount
			  ,ReportFK
			from dbo.ReportHistory rh
			where ProgramFK = @ProgramFK
				 and UserName = @UserName
			group by ProgramFK
					,ReportFK

	),
	cteFrequencyByProgram
	as (select row_number() over (order by count(ReportFK) desc) as ProgramRank
			  ,count(ReportFK) as ProgramCount
			  ,ReportFK
			from dbo.ReportHistory rh
			where ProgramFK = @ProgramFK
			group by ProgramFK
					,ReportFK

	)
	select rc.codeReportCatalogPK
		  ,rc.ReportName
		  ,rc.ReportCategory
		  ,rc.ReportDescription
		  ,rc.ReportClass
		  ,rc.CriteriaOptions
		  ,rc.Defaults
		  --,'O:'+rtrim(CriteriaOptions)+' D(calc):'+rtrim(dbo.CalculateReportDefaults([Defaults]))+' D(raw):'+rtrim([Defaults]) as DefaultsBag
		  ,rc.Keywords
		  ,'' as AttachmentName -- space(100) 
		  ,convert(varchar(10), UserLastRun, 126) as UserLastRun
		  ,convert(varchar(10), ProgramLastRun, 126) as ProgramLastRun
		  ,fbu.UserRank
		  ,fbu.UserCount
		  ,fbp.ProgramRank
		  ,fbp.ProgramCount
		from dbo.codeReportCatalog rc
			INNER JOIN dbo.codeReportAccess cra ON cra.ReportFK = rc.codeReportCatalogPK AND cra.StateFK = @StateFK
			left outer join dbo.Attachment a on a.FormFK = rc.codeReportCatalogPK and a.FormType = 'RC'
			left outer join cteLastRunByUser lrbu on lrbu.ReportFK = rc.codeReportCatalogPK
			left outer join cteLastRunByProgram lrbp on lrbp.ReportFK = rc.codeReportCatalogPK
			left outer join cteFrequencyByUser fbu on fbu.ReportFK = rc.codeReportCatalogPK
			left outer join cteFrequencyByProgram fbp on fbp.ReportFK = rc.codeReportCatalogPK
		where rc.ReportClass is not NULL
			AND cra.AllowedAccess =	1
		ORDER by rc.[ReportCategory]
				, rc.[ReportName]

--	,cteFrequencyByUser
--		as
--		(
--		select ROW_NUMBER() over(order by count(rh.ReportFK), UserLastRun desc) as UserRank
--				,Count(rh.ReportFK) as UserCount
--				,rh.ReportFK
--		from ReportHistory rh
--		inner join cteLastRunByUser lrbu on lrbu.ReportFK=rh.ReportFK
--		where rh.ProgramFK=@ProgramFK
--				and UserFK=@UserName
--		group by rh.ProgramFK, rh.ReportFK, UserLastRun

--		)
--	,cteFrequencyByProgram
--		as
--		(
--		select ROW_NUMBER() over(order by count(rh.ReportFK), ProgramLastRun desc) as ProgramRank
--				,Count(rh.ReportFK) as ProgramCount
--				,rh.ReportFK
--		from ReportHistory rh
--		inner join cteLastRunByProgram lrbp on lrbp.ReportFK=rh.ReportFK
--		where rh.ProgramFK=@ProgramFK
--		group by rh.ProgramFK, rh.ReportFK, ProgramLastRun

--		)
--select codeReportCatalogPK
--		,isnull(UserRank,0) as UserRank
--		,isnull(UserCount,0) as UserCount
--		,isnull(ProgramRank,0) as ProgramRank
--		,isnull(ProgramCount,0) as ProgramCount
--		,case when UserRank is null
--			then 'null'
--			else
--				convert(varchar(5),isnull(UserRank,0)) + ' (' +  convert(varchar(5),isnull(UserCount,0)) + ')'
--		end as UserRank
--	  ,	case when ProgramRank is null
--			then 'null'
--			else
--				convert(varchar(5),isnull(ProgramRank,0)) + ' (' +  convert(varchar(5),isnull(ProgramCount,0)) + ')' 
--		end as ProgramRank
end
GO
