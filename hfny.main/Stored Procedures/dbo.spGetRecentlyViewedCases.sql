SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 02/20/18
-- Description:	This stored procedure obtains the 50 most recently
-- viewed cases for a specific user and filters those results by program.
-- The @ProgramFK parameter is now optional.
-- =============================================
CREATE procedure [dbo].[spGetRecentlyViewedCases] (@UserName varchar(255), @ProgramFK int)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	create table #CaseViews 
		(
			PC1ID char(13), 
			ViewDateMax datetime
		);

	insert into #CaseViews (PC1ID, ViewDateMax)
	select		top 1000 cv.PC1ID
						, max(cv.ViewDate) as ViewDateMax
		from		CaseView cv
		inner join	CaseProgram cp on cp.PC1ID = cv.PC1ID
		where		cv.Username = @UserName and cp.ProgramFK = isnull(@ProgramFK, cp.ProgramFK)
		group by	cv.PC1ID
		order by	ViewDateMax desc

	select top 20 PC1ID from #CaseViews 
	order by ViewDateMax desc;
end ;
GO
