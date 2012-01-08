SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 6, 2012>
-- Description:	<reporting stored proc for Signed Confidentiality report>
-- =============================================
CREATE PROCEDURE [dbo].[rspRightsConfidentiality] (@programfk INT = 1
													,@ReportStartPeriodDate DATETIME
													,@ReportEndPeriodDate DATETIME)
AS

with cteMain
as (SELECT pc1id, 
			oldid,
			hvcase.intakedate,
			LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) as workername,
			Confidentiality
	FROM hvcase
	INNER JOIN caseprogram ON caseprogram.hvcasefk = hvcasepk
	INNER JOIN HVProgram on hvprogrampk=caseprogram.programfk
	LEFT JOIN kempe ON kempe.hvcasefk = hvcasepk
	INNER JOIN codelevel ON codelevelpk = currentlevelfk
	INNER JOIN pc ON pc.pcpk = pc1fk
	LEFT JOIN tcid ON tcid.hvcasefk = hvcasepk
	INNER JOIN worker fsw ON CurrentFSWFK = fsw.workerpk
	INNER JOIN workerprogram ON workerfk = fsw.workerpk
	WHERE caseprogram.programfk = @programfk
			AND dischargedate IS NULL
			AND HVCase.KempeDate IS NOT NULL
			AND casestartdate <= DATEADD(dd,1,DATEDIFF(dd,0,GETDATE()))
	)
,ctePC1ID_TotalCount
as (SELECT COUNT(*) as TotalCount
	FROM cteMain
	)
,ctePC1ID_NotSignedCount
as (SELECT COUNT(*) NotSignedCount
	FROM cteMain 
	WHERE Confidentiality<>1
	)

SELECT TotalCount,
	NotSignedCount,
	pc1id, 
	oldid,
	workername,
	intakedate
FROM cteMain
left join ctePC1ID_NotSignedCount on NotSignedCount>0
left join ctePC1ID_TotalCount on TotalCount>0
WHERE IntakeDate is not null
		and IntakeDate between @ReportStartPeriodDate and @ReportEndPeriodDate
		and Confidentiality<>1 or Confidentiality is null
ORDER BY pc1id, oldid
	-- ORDER BY workername,oldid,screendate

/* SET NOCOUNT ON */
RETURN

GO
