SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseView](@PC1ID nchar(13)=NULL,
@UserName varchar(50)=NULL,
@ViewDate datetime=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) CaseViewPK
FROM CaseView lastRow
WHERE 
@PC1ID = lastRow.PC1ID AND
@UserName = lastRow.UserName AND
@ViewDate = lastRow.ViewDate
ORDER BY CaseViewPK DESC) 
BEGIN
INSERT INTO CaseView(
PC1ID,
UserName,
ViewDate
)
VALUES(
@PC1ID,
@UserName,
@ViewDate
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
