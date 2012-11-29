SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 11/29/12
-- Description:	Get the PC1 Hightest Grade for FollowUp Validation
-- =============================================
CREATE PROCEDURE [dbo].[spGetHighestGradePC1] 
	@HVCaseFK [int]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

  SELECT max(highestgrade) FROM CommonAttributes ca
  WHERE (FormType = 'IN-PC1' OR FormType='KE' OR FormType = 'FU-PC1')
  AND HVCaseFK=@HVCaseFK

END
GO
