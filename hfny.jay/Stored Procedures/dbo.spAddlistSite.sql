SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistSite](@ProgramFK int=NULL,
@SiteCode char(30)=NULL,
@SiteName char(30)=NULL)
AS
INSERT INTO listSite(
ProgramFK,
SiteCode,
SiteName
)
VALUES(
@ProgramFK,
@SiteCode,
@SiteName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
