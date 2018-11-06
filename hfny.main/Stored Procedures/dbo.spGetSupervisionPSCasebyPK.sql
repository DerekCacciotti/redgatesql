SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 10/16/18
-- Description:	This stored procedure gets a single parent survey 
--				supervision case for the passed PK
-- =============================================
CREATE procedure [dbo].[spGetSupervisionPSCasebyPK]

(@SupervisionParentSurveyCasePK int)
as
begin
	set noCount on ;

	select	spsc.*
			, cp.PC1ID
	from	SupervisionParentSurveyCase spsc
	inner join CaseProgram cp on cp.HVCaseFK = spsc.HVCaseFK
	where	SupervisionParentSurveyCasePK = @SupervisionParentSurveyCasePK ;
end
GO
