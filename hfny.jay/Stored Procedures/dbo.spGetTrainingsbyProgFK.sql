SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/11/2012
-- Description:	Gets Training List by program for the TrainingHome.aspx page
-- =============================================
CREATE PROCEDURE [dbo].[spGetTrainingsbyProgFK]
	-- Add the parameters for the stored procedure here
	@ProgFK AS int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [TrainingPK]
		  ,[ProgramFK]
		  ,[TrainerFK]
		  ,[TrainingMethodFK]
		  ,[TrainingCreateDate]
		  ,[TrainingCreator]
		  ,[TrainingDate]
		  ,[TrainingDays]
		  ,[TrainingDescription]
		  ,[TrainingDuration]
		  ,[TrainingEditDate]
		  ,[TrainingEditor]
		  ,[TrainingHours]
		  ,[TrainingMinutes]
		  ,[TrainingPK_old]
		  ,[TrainingTitle]
	  FROM [HFNY].[dbo].[Training]
	  WHERE ProgramFK = @ProgFK
	  ORDER BY TrainingDate DESC
END
GO
