SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 09/10/18
-- Description:	This stored procedure gets the list of supervision cases
--				for the passed Supervision FK
-- =============================================
CREATE procedure [dbo].[spGetSupervisionCaseList]
	@SupervisionFK int
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	select sc.SupervisionCasePK
		 , sc.HVCaseFK
		 , sc.ProgramFK
		 , sc.SupervisionFK
		 , sc.CaseComments
	from SupervisionCase sc
	where sc.SupervisionFK = @SupervisionFK;
end ;
GO
