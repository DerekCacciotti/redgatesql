SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 06/06/18
-- Description: This stored procedure returns all the HVLog specific goal plan fields
-- for a specific goal plan PK
-- =============================================
CREATE PROCEDURE [dbo].[spGetGoalPlanHVLogStatusesbyGoalPlanFK]
	-- Add the parameters for the stored procedure here
	@GoalPlanFK INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT * FROM dbo.GoalPlanHVLogStatus gphls WHERE gphls.GoalPlanFK = @GoalPlanFK
END
GO
