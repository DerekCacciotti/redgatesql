SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 7/11/2012
-- Description:	Gets Training List by program for the TrainingHome.aspx page
-- =============================================
CREATE procedure [dbo].[spGetTrainingsLastYearbyProgFK]
	-- Add the parameters for the stored procedure here
	@ProgFK as int
as
	begin
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
						, convert(varchar(10), tr.[TrainingDate], 126) as TrainingDate
						, tr.[TrainingDays]
						, tr.[TrainingDescription]
						, tr.[TrainingDuration]
						, tr.[TrainingEditDate]
						, tr.[TrainingEditor]
						, tr.[TrainingHours]
						, tr.[TrainingMinutes]
						, tr.[TrainingTitle]
		from		[dbo].[Training] tr
		inner join	FormReviewedTableList('TR', @ProgFK) on FormFK = tr.TrainingPK
		where		tr.ProgramFK = @ProgFK and	tr.TrainingDate > dateadd(year, -1, getdate())
					and (tr.IsExempt is null or tr.IsExempt = 0)
		order by	TrainingDate desc ;
	end ;
GO
