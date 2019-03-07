SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 2/19/2019
-- Description:	PHQ9 data by HVCaseFK
-- =============================================
create PROCEDURE [dbo].[spGetAllPHQ9ByHVCaseFK]
(
    @HVCaseFK INT
)

AS
BEGIN
	SET NOCOUNT ON;
	SELECT * from dbo.PHQ9 p
	where p.HVCaseFK = @HVCaseFK
	order by p.DateAdministered asc
END
GO
