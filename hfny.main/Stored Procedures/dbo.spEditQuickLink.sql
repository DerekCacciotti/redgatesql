SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditQuickLink](@QuickLinkPK int=NULL,
@LinkType char(4)=NULL,
@LinkURL varchar(100)=NULL,
@QuickLinkDescription varchar(50)=NULL,
@UserName varchar(50)=NULL)
AS
UPDATE QuickLink
SET 
LinkType = @LinkType, 
LinkURL = @LinkURL, 
QuickLinkDescription = @QuickLinkDescription, 
UserName = @UserName
WHERE QuickLinkPK = @QuickLinkPK
GO
