SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelQuickLink](@QuickLinkPK int)

AS


DELETE 
FROM QuickLink
WHERE QuickLinkPK = @QuickLinkPK
GO
