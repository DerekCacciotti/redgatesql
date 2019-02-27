SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeRegion](@RegionDescription varchar(100)=NULL,
@RegionName varchar(20)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeRegionPK
FROM codeRegion lastRow
WHERE 
@RegionDescription = lastRow.RegionDescription AND
@RegionName = lastRow.RegionName
ORDER BY codeRegionPK DESC) 
BEGIN
INSERT INTO codeRegion(
RegionDescription,
RegionName
)
VALUES(
@RegionDescription,
@RegionName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
