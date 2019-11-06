SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 10/31/2019 
-- Description:	Partner Violence Screen data by HVCaseFK
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllPVSByHVCaseFK]
(
    @HVCaseFK INT
)

AS
BEGIN
	SET NOCOUNT ON;
	SELECT * from dbo.PartnerViolenceScreen p
	where p.HVCaseFK = @HVCaseFK
	order by p.PVSDate asc
END
GO
