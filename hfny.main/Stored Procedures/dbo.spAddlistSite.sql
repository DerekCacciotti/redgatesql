SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistSite](@listSitePK_old int=NULL,
@ProgramFK int=NULL,
@SiteCode char(30)=NULL,
@SiteName char(30)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listSitePK
FROM listSite lastRow
WHERE 
@listSitePK_old = lastRow.listSitePK_old AND
@ProgramFK = lastRow.ProgramFK AND
@SiteCode = lastRow.SiteCode AND
@SiteName = lastRow.SiteName
ORDER BY listSitePK DESC) 
BEGIN
INSERT INTO listSite(
listSitePK_old,
ProgramFK,
SiteCode,
SiteName
)
VALUES(
@listSitePK_old,
@ProgramFK,
@SiteCode,
@SiteName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
