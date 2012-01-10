SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    Chris Papas
-- Create date: Feb 5, 2010
-- Description: Get all Agency Sites
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllListSites] (@programfk int)
  -- Add the parameters for the stored procedure here
AS
BEGIN
  SELECT * FROM dbo.listSite 
  WHERE programfk = ISNULL(@ProgramFK,ProgramFK)
  ORDER BY sitename
END
GO
