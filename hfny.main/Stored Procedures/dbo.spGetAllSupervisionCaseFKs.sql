SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 2018-09-20
-- Edit date: 
-- Edited by: 
-- Edit Reason: 
-- Description:	Get all cases discussed in a specific supervision session
-- =============================================
CREATE procedure [dbo].[spGetAllSupervisionCaseFKs]

	-- Add the parameters for the stored procedure here
	@SupervisionFK as int
as
	begin
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set noCount on ;
		
		declare @listStr varchar(max) ;
		
		select	@listStr = coalesce(@listStr+',', '')+cast([HVCaseFK] as varchar(max))
		from
				(
				select	distinct HVCaseFK
				from	SupervisionCase sc
				where	SupervisionFK = @SupervisionFK
				) a ;
		select @listStr ;

	end ;
GO
