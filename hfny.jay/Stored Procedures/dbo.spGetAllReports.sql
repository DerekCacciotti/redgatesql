SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 24, 2011>
-- Description:	<Gets all items in the codeReportCatalog table>
-- =============================================
CREATE procedure [dbo].[spGetAllReports]

as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;
	select [codeReportCatalogPK]
		  ,[ReportName]
		  ,[ReportCategory]
		  ,[ReportDescription]
		  ,[ReportClass]
		  ,CriteriaOptions
		  ,Defaults
		  ,'O:'+rtrim(CriteriaOptions)+' D(calc):'
			+rtrim(dbo.CalculateReportDefaults([Defaults]))+' D(raw):'+rtrim([Defaults]) as DefaultsBag
		from [codeReportCatalog]
		where ReportClass is not null
		order by [ReportCategory]
				,[ReportName]
-- Insert statements for procedure here
--   with cteLastRunByUser
--   as 
--   (
--   select ReportName
--   from ReportHistory rh
--   )
--select codeReportCatalogPK
--         ,rc.ReportName
--         ,ReportCategory
--         ,ReportDescription
--         ,ReportClass
--         ,CriteriaOptions
--         ,Defaults
--from codeReportCatalog rc
--inner join cteLastRunByUser lrbu on lrbu.ReportName = rc.ReportName
end
GO
