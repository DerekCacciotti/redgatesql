SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 05/22/2013
-- Description:	Annual Child Abuse & Neglect
-- =============================================
CREATE procedure [dbo].[rspTraining7-5D_PHQ]

	-- Add the parameters for the stored procedure here
	@sdate as datetime ,
	@progfk as int
as
	begin
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set nocount on;
		if object_id('tempdb..#tmpTraining7DEventDates') is not null drop table #tmpTraining7DEventDates
		if object_id('tempdb..#tmpTraining7DCohort') is not null drop table #tmpTraining7DCohort

		--Get Workers in time period
		select WorkerPK ,
				WrkrLName ,
				rtrim(WrkrFName) + ' ' + rtrim(WrkrLName) as WorkerName ,
				HireDate ,
				FirstKempeDate ,
				FirstHomeVisitDate ,
				SupervisorFirstEvent ,
				FirstPHQDate ,
				'1' as TotalCounter --used to get a count of all workers in this report towards the end
		into #tmpTraining7DEventDates
		from   [dbo].[fnGetWorkerEventDates](@progfk, null, null)
		where  FirstPHQDate is not null
				and HireDate >= @sdate

		select t.TrainingDate as [PHQTrainingDt] ,
				WorkerPK ,
				ttded.FirstPHQDate ,
				t.IsExempt as [TrainingExempt] ,
				t.TrainingPK ,
				t.TrainingTitle ,
				workerrownumber = row_number() over ( partition by WorkerPK
														order by t.TrainingDate asc )
		into #tmpTraining7DCohort
		from   #tmpTraining7DEventDates ttded
				inner join TrainingAttendee ta on ta.WorkerFK = ttded.WorkerPK
				left join Training t on ta.TrainingFK = t.TrainingPK
				left join TrainingDetail td on td.TrainingFK = t.TrainingPK
				left join codeTopic cdT on cdT.codeTopicPK = td.TopicFK
		where  ( cdT.TopicCode = 39.0 );
				
		with ctePHQTraining
			as
				(
					--get only one training per worker
					select [PHQTrainingDt] ,
						   WorkerPK ,
						   FirstPHQDate ,
						   [TrainingExempt] ,
						   TrainingPK ,
						   TrainingTitle
					from   #tmpTraining7DCohort ttdc
					where  workerrownumber = 1
				) ,
		cteFinal
			as
				(
					select	 distinct WorkerName ,
							 ttded.WorkerPK ,
							 ttded.FirstPHQDate ,
							 [PHQTrainingDt] ,
							 case when [PHQTrainingDt] is not null then 1
							 end as ContentCompleted ,
							 case when [PHQTrainingDt] <= ttded.FirstPHQDate then
									  1
								  when [TrainingExempt] = '1' then '1'
								  else 0
							 end as [Meets Target] ,
							 TotalCounter ,
							 ctePHQTraining.TrainingTitle ,
							 vPHQ9.HVCaseFK
					from	 #tmpTraining7DEventDates ttded
							 left join ctePHQTraining on ctePHQTraining.WorkerPK = ttded.WorkerPK
							 inner join vPHQ9 on ttded.WorkerPK = vPHQ9.workerfk
												 and ttded.FirstPHQDate = vPHQ9.DateAdministered
					group by ttded.WorkerName ,
							 ttded.FirstPHQDate ,
							 [PHQTrainingDt] ,
							 ttded.WorkerPK ,
							 [TrainingExempt] ,
							 TotalCounter ,
							 ctePHQTraining.TrainingTitle ,
							 HVCaseFK
				) ,
		--Now calculate the number meeting count, by currentrole
		cteCountMeeting
			as
				(
					select count(*) as totalmeetingcount
					from   cteFinal
					where  [Meets Target] = 1
				) ,
		ctePutItAllTogether
			as
				(
					select	 WorkerName ,
							 WorkerPK ,
							 FirstPHQDate ,
							 [PHQTrainingDt] ,
							 ContentCompleted ,
							 totalmeetingcount ,
							 cteFinal.TotalCounter ,
							 case [cteFinal].[Meets Target]
								  when '1' then 'T'
								  else 'F'
							 end as [Meets Target] ,
							 count([TotalCounter]) over ( partition by TotalCounter ) as TotalWorkers ,
							 sum([cteFinal].[ContentCompleted]) over ( partition by TotalCounter ) as MeetTarget ,
							 sum([Meets Target]) over ( partition by TotalCounter ) as MeetTargetOnTime ,
							 case when count([TotalCounter]) over ( partition by TotalCounter ) = sum([Meets Target]) over ( partition by TotalCounter ) then
									  '3'
								  when cast(totalmeetingcount as decimal)
									   / cast(count([TotalCounter]) over ( partition by TotalCounter ) as decimal)
									   between .9 and .99 then '2'
								  else '1'
							 end as Rating ,
							 TrainingTitle ,
							 cast(totalmeetingcount as decimal)
							 / cast(count([TotalCounter]) over ( partition by TotalCounter ) as decimal) as PercentMeeting ,
							 HVCaseFK
					from	 cteFinal ,
							 cteCountMeeting
					group by WorkerName ,
							 WorkerPK ,
							 FirstPHQDate ,
							 [PHQTrainingDt] ,
							 ContentCompleted ,
							 [Meets Target] ,
							 TotalCounter ,
							 totalmeetingcount ,
							 TrainingTitle ,
							 HVCaseFK
				)
		select	 WorkerName ,
				 WorkerPK ,
				 FirstPHQDate ,
				 [PHQTrainingDt] ,
				 ContentCompleted ,
				 totalmeetingcount ,
				 TotalCounter ,
				 [Meets Target] ,
				 TotalWorkers ,
				 MeetTarget ,
				 MeetTargetOnTime ,
				 Rating ,
				 TrainingTitle ,
				 PercentMeeting ,
				 max(PC1ID) as PC1ID
		from	 ctePutItAllTogether
				 inner join CaseProgram cp on cp.HVCaseFK = ctePutItAllTogether.HVCaseFK
		group by WorkerName ,
				 WorkerPK ,
				 FirstPHQDate ,
				 [PHQTrainingDt] ,
				 ContentCompleted ,
				 totalmeetingcount ,
				 TotalCounter ,
				 [Meets Target] ,
				 TotalWorkers ,
				 MeetTarget ,
				 MeetTargetOnTime ,
				 Rating ,
				 TrainingTitle ,
				 PercentMeeting;
	end;
GO
