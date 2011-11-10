SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistSite](@listSitePK int=NULL,
@ProgramFK int=NULL,
@SiteCode char(30)=NULL,
@SiteName char(30)=NULL)
AS
UPDATE listSite
SET 
ProgramFK = @ProgramFK, 
SiteCode = @SiteCode, 
SiteName = @SiteName
WHERE listSitePK = @listSitePK
GO
