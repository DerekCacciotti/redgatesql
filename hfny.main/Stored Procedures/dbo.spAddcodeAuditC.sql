SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeAuditC](@codeGroup char(20)=NULL,
@codeScore int=NULL,
@codeText char(25)=NULL,
@codeValue char(2)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeAuditCPK
FROM codeAuditC lastRow
WHERE 
@codeGroup = lastRow.codeGroup AND
@codeScore = lastRow.codeScore AND
@codeText = lastRow.codeText AND
@codeValue = lastRow.codeValue
ORDER BY codeAuditCPK DESC) 
BEGIN
INSERT INTO codeAuditC(
codeGroup,
codeScore,
codeText,
codeValue
)
VALUES(
@codeGroup,
@codeScore,
@codeText,
@codeValue
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
