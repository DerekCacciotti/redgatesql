SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPC1ID](@NextNum int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) PC1IDPK
FROM PC1ID lastRow
WHERE 
@NextNum = lastRow.NextNum
ORDER BY PC1IDPK DESC) 
BEGIN
INSERT INTO PC1ID(
NextNum
)
VALUES(
@NextNum
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
