
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/18/2012
-- Description:	Get all workers who participated in a specific training
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllDetailsByTrainingFK]
	-- Add the parameters for the stored procedure here
	@TrainingFK AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT topicfk, subtopicfk, CulturalCompetency FROM TrainingDetail td
	WHERE TrainingFK=@TrainingFK

END
GO
