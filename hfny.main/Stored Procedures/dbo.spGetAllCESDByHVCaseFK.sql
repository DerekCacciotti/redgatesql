SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 10/31/2019 
-- Description:	CESD data by HVCaseFK
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllCESDByHVCaseFK]
(
    @HVCaseFK INT
)

AS
BEGIN
	SET NOCOUNT ON;
	SELECT * from dbo.CESD
	where HVCaseFK = @HVCaseFK
	order by CESDDate asc
END
GO
