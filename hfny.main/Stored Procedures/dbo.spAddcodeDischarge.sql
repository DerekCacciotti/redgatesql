SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeDischarge](@DischargeCode char(2)=NULL,
@DischargeReason char(100)=NULL,
@DischargeUsedWhere varchar(50)=NULL,
@ReportDischargeText char(30)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeDischargePK
FROM codeDischarge lastRow
WHERE 
@DischargeCode = lastRow.DischargeCode AND
@DischargeReason = lastRow.DischargeReason AND
@DischargeUsedWhere = lastRow.DischargeUsedWhere AND
@ReportDischargeText = lastRow.ReportDischargeText
ORDER BY codeDischargePK DESC) 
BEGIN
INSERT INTO codeDischarge(
DischargeCode,
DischargeReason,
DischargeUsedWhere,
ReportDischargeText
)
VALUES(
@DischargeCode,
@DischargeReason,
@DischargeUsedWhere,
@ReportDischargeText
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
