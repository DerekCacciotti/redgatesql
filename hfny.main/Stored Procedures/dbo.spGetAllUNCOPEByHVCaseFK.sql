SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 10/31/2019 
-- Description:	UNCOPE data by HVCaseFK
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllUNCOPEByHVCaseFK]
(
    @HVCaseFK INT
)

AS
BEGIN
	SET NOCOUNT ON;
	SELECT * from dbo.UNCOPE
	where HVCaseFK = @HVCaseFK
	order by UNCOPEDate asc
END
GO
