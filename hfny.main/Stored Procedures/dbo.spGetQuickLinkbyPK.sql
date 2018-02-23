SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetQuickLinkbyPK]

(@QuickLinkPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM QuickLink
WHERE QuickLinkPK = @QuickLinkPK
GO
