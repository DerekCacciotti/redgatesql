SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE  [dbo].[spGetHVLogsbyCaseStartDate](
	@HVCaseFK INT,
	@CaseStartDate DATETIME
)

AS
BEGIN
	SET NOCOUNT ON;

    SELECT DISTINCT hv.*
	FROM HVLog hv
	INNER JOIN caseprogram cp
	ON hv.hvcasefk = cp.hvcasefk
	AND hv.programfk = cp.programfk
	WHERE hv.HVCaseFK = @HVCaseFK
	AND casestartdate <= @CaseStartDate
	AND VisitStartTime <= ISNULL(dischargedate,GETDATE())
	ORDER BY VisitStartTime DESC, VisitType DESC
	 
END







GO
