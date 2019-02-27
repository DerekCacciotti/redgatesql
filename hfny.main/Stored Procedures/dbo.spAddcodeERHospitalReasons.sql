SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeERHospitalReasons](@ReasonCode varchar(2)=NULL,
@ReasonDescription varchar(100)=NULL,
@ReasonGroup varchar(50)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeERHospitalReasonsPK
FROM codeERHospitalReasons lastRow
WHERE 
@ReasonCode = lastRow.ReasonCode AND
@ReasonDescription = lastRow.ReasonDescription AND
@ReasonGroup = lastRow.ReasonGroup
ORDER BY codeERHospitalReasonsPK DESC) 
BEGIN
INSERT INTO codeERHospitalReasons(
ReasonCode,
ReasonDescription,
ReasonGroup
)
VALUES(
@ReasonCode,
@ReasonDescription,
@ReasonGroup
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
