SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeCounty](@CountyCode char(2)=NULL,
@CountyName char(15)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeCountyPK
FROM codeCounty lastRow
WHERE 
@CountyCode = lastRow.CountyCode AND
@CountyName = lastRow.CountyName
ORDER BY codeCountyPK DESC) 
BEGIN
INSERT INTO codeCounty(
CountyCode,
CountyName
)
VALUES(
@CountyCode,
@CountyName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
