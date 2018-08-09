SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 24, 2011>
-- Description:	<Gets all items in the codeReportCatalog table for maintenance form>
-- =============================================
create procedure [dbo].[spGetAllReportsForMaintenance]
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select codeReportCatalogPK
		  ,rc.ReportName
		  ,ReportCategory
		  ,ReportDescription
		  ,ReportClass
		  ,CriteriaOptions
		  ,Defaults
		  --,'O:'+rtrim(CriteriaOptions)+' D(calc):'+rtrim(dbo.CalculateReportDefaults([Defaults]))+' D(raw):'+rtrim([Defaults]) as DefaultsBag
		  ,Keywords
		from codeReportCatalog rc
		left outer join Attachment a on a.FormFK = rc.codeReportCatalogPK and a.FormType = 'RC'
		where ReportClass is not null
		order by [ReportCategory]
				,[ReportName]

end
GO
