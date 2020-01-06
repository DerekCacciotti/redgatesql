SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spgetAllRegions] AS

SELECT cr.codeRegionPK, cr.RegionName FROM codeRegion cr
GO
