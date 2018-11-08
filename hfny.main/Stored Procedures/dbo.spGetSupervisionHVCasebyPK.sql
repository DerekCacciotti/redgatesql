SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/16/18
-- Description:	This stored procedure gets a single home visit 
--				supervision case for the passed PK
-- =============================================
CREATE procedure [dbo].[spGetSupervisionHVCasebyPK]
	(@SupervisionHomeVisitCasePK int)
as
begin
	set noCount on ;

	select	shvc.*
			, cp.PC1ID
	from	SupervisionHomeVisitCase shvc
	inner join CaseProgram cp on cp.HVCaseFK = shvc.HVCaseFK
	where	SupervisionHomeVisitCasePK = @SupervisionHomeVisitCasePK ;
end
GO
