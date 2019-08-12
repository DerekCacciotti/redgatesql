SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/11/2012
-- Description:	Gets Training List by program for the TrainingHome.aspx page
-- =============================================
CREATE procedure [dbo].[spGetTrainingsByProgram_WorkerOptional]
	-- Add the parameters for the stored procedure here
	@ProgFK as INT,
    @WorkerFK AS INT = NULL, -- 0 if not part of search
    @TopicFK AS INT = NULL, -- 0 if not part of search
    @IsApproved AS INT = NULL, -- 1 for approved
	@StartDate AS DATE = NULL,
	@EndDate AS DATE = NULL

    WITH recompile
as
	BEGIN
	DECLARE @WorkerFK2 AS INT = NULL
	DECLARE @TopicFK2 AS INT = NULL
	DECLARE @IsApprovedSTR AS VARCHAR(1) = NULL
	
	IF @WorkerFK > 0 SET @WorkerFK2 = @WorkerFK
	IF @TopicFK > 0 SET @TopicFK2 = @TopicFK
	IF @IsApproved <> NULL SET @IsApprovedSTR = @IsApproved


		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set noCount on ;

		-- Insert statements for procedure here
		select		distinct IsApproved
						, tr.[TrainingPK]
						, tr.[ProgramFK]
						, tr.[TrainerFK]
						, tr.[TrainingMethodFK]
						, tr.[TrainingCreateDate]
						, tr.[TrainingCreator]
						, tr.TrainingDate
						--, convert(varchar(10), tr.[TrainingDate], 126) as TrainingDate
						, tr.[TrainingDays]
						, tr.[TrainingDescription]
						, tr.[TrainingDuration]
						, tr.[TrainingEditDate]
						, tr.[TrainingEditor]
						, tr.[TrainingHours]
						, tr.[TrainingMinutes]
						, tr.[TrainingTitle]
						, ct.TopicCode
						, ct.TopicName
		from		[dbo].[Training] tr
		INNER JOIN  dbo.TrainingDetail td ON td.TrainingFK = tr.TrainingPK
		INNER JOIN	dbo.TrainingAttendee ta ON ta.TrainingFK = tr.TrainingPK
		INNER JOIN dbo.codeTopic ct ON ct.codeTopicPK = td.TopicFK
		inner join	FormReviewedTableList('TR', @ProgFK) on FormFK = tr.TrainingPK
		where		tr.ProgramFK = @ProgFK 
					and (tr.IsExempt is null or tr.IsExempt = 0)
					AND Workerfk = ISNULL(@WorkerFK2, ta.WorkerFK)
					AND ct.codeTopicPK = ISNULL( @TopicFK2,ct.codeTopicPK )
					AND  IsApproved = ISNULL(@IsApprovedSTR, IsApproved)
					AND tr.TrainingDate  BETWEEN ISNULL(@StartDate,tr.TrainingDate) AND ISNULL(@EndDate, tr.TrainingDate)
					order by	TrainingDate desc ;


	end ;
GO
