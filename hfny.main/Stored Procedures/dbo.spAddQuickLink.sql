SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddQuickLink](@LinkType char(4)=NULL,
@LinkURL varchar(100)=NULL,
@QuickLinkDescription varchar(50)=NULL,
@UserName varchar(max)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) QuickLinkPK
FROM QuickLink lastRow
WHERE 
@LinkType = lastRow.LinkType AND
@LinkURL = lastRow.LinkURL AND
@QuickLinkDescription = lastRow.QuickLinkDescription AND
@UserName = lastRow.UserName
ORDER BY QuickLinkPK DESC) 
BEGIN
INSERT INTO QuickLink(
LinkType,
LinkURL,
QuickLinkDescription,
UserName
)
VALUES(
@LinkType,
@LinkURL,
@QuickLinkDescription,
@UserName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
