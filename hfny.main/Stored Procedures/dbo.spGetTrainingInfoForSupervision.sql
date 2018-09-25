SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 09/21/18
-- Description:	This stored procedure obtains the last 10 Training sessions
--				associated with the passed Worker FK.
-- =============================================
CREATE procedure [dbo].[spGetTrainingInfoForSupervision]
				(
					@ProgramFK int
					, @WorkerFK int
				)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	select top 10 t.TrainingPK
		 , t.ProgramFK
		 , t.TrainerFK
		 , t.TrainingMethodFK
		 , 'TrainingSummary' as TrainingSummary
		 , t2.TrainerFirstName + ' ' + t2.TrainerLastName as TrainerName
		 , t.TrainingCreateDate
		 , t.TrainingCreator
		 , t.TrainingDate
		 , t.TrainingDays
		 , t.TrainingDescription
		 , t.TrainingDuration
		 , t.TrainingEditDate
		 , t.TrainingEditor
		 , t.TrainingHours
		 , t.TrainingMinutes
		 , t.TrainingTitle
		 , t.IsExempt
		 , td.TrainingDetailPK
		 , td.CulturalCompetency
		 , td.ProgramFK
		 , td.SubTopicFK
		 , td.SubTopicTime
		 , td.TopicFK
		 , td.TrainingDetailCreateDate
		 , td.TrainingDetailCreator
		 , td.TrainingDetailEditDate
		 , td.TrainingDetailEditor
		 , td.TrainingDetailPK_old
		 , td.TrainingFK
		 , td.ExemptDescription
		 , td.ExemptType
		 , ta.TrainingAttendeePK
		 , ta.TrainingAttendeeCreateDate
		 , ta.TrainingAttendeeCreator
		 , ta.TrainingAttendeeEditDate
		 , ta.TrainingAttendeeEditor
		 , ta.TrainingFK
		 , ta.WorkerFK
	from Training t
	inner join TrainingDetail td on td.TrainingFK = t.TrainingPK
	inner join TrainingAttendee ta on ta.TrainingFK = t.TrainingPK
	inner join  Trainer t2 on t2.TrainerPK = t.TrainerFK
	where ta.WorkerFK = @WorkerFK
	order by t.TrainingDate desc
end ;
GO
