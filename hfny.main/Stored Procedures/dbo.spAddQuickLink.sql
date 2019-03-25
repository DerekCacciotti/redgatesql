SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddQuickLink](@LinkType char(4)=NULL,
@LinkURL varchar(100)=NULL,
@QuickLinkDescription varchar(50)=NULL,
@UserName varchar(max)=NULL)
AS
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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
