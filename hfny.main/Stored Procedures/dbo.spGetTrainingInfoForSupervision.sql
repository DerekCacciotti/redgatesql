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

	select top 20 t.TrainingPK
		 , t.ProgramFK
		 , t.TrainerFK
		 , t.TrainingMethodFK
		 , 'TrainingSummary' as TrainingSummary
		 , rtrim(t2.TrainerFirstName) + ' ' + rtrim(t2.TrainerLastName) as TrainerName
		 , t.TrainingCreateDate
		 , t.TrainingCreator
		 , t.TrainingDate
		 , t.TrainingDays
		 , t.TrainingDescription
		 , case when t.TrainingDays is not null and t.TrainingDays > 0 
				then convert(char(2), t.TrainingDays) + ' Day' +
						case when TrainingDays > 1 then 's' else '' end + ' '
				else ''
				end +
			case when t.TrainingHours is not null and t.TrainingHours > 0 
				then convert(char(2), t.TrainingHours) + ' Hour' + 
						case when t.TrainingHours > 1 then 's' else '' end + ' '
				else ''
				end +
			case when t.TrainingMinutes is not null and t.TrainingMinutes > 0 
				then convert(char(2), t.TrainingMinutes) + ' Min' +
						case when t.TrainingMinutes > 1 then 's' else '' end
				else ''
				end as TrainingDuration		 
			-- above was left(..., 25) then replaced 25 with
				--convert(int, len(case when t.TrainingDays is not null and t.TrainingDays > 0 
				--	then convert(char(2), t.TrainingDays) + ' Day' +
				--			case when TrainingDays > 1 then 's' else '' end + ', '
				--	else ''
				--	end +
				--case when t.TrainingHours is not null and t.TrainingHours > 0 
				--	then convert(char(2), t.TrainingHours) + ' Hour' + 
				--			case when t.TrainingHours > 1 then 's' else '' end + ', '
				--	else ''
				--	end +
				--case when t.TrainingMinutes is not null and t.TrainingMinutes > 0 
				--	then convert(char(2), t.TrainingMinutes) + ' Minute' +
				--			case when t.TrainingMinutes > 1 then 's' else '' end + ', '
				--	else ''
				--	end) - 2)
		 , SubTopicDescription = 
					substring((select	', ' + st.SubTopicCode + '-' + st.SubTopicName
		 						from	SubTopic st
								where	st.SubTopicPK = td.SubTopicFK
							   for
								xml	path('')
							   ), 3, 1000)
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
	from Training t
	inner join TrainingDetail td on td.TrainingFK = t.TrainingPK
	inner join TrainingAttendee ta on ta.TrainingFK = t.TrainingPK
	inner join  Trainer t2 on t2.TrainerPK = t.TrainerFK
	where ta.WorkerFK = @WorkerFK
	order by t.TrainingDate desc
end ;

GO
