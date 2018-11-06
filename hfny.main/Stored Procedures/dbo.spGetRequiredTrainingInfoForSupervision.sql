SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 09/21/18
-- Description:	This stored procedure gets the rough equivalent
--				of the Training Required Topics report for the passed Worker FK.
-- =============================================
CREATE procedure [dbo].[spGetRequiredTrainingInfoForSupervision]
				(
					@ProgramFK int
					, @WorkerFK int
				)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	declare @minDate datetime = '01/01/1901'

	declare @ctWorkerTable table (
		workerpk int
	)

	insert into @ctWorkerTable (workerpk)
	values (@WorkerFK);
 
	declare @ctAttendee table (
		TrainingPK int
		,TrainingDate datetime
		,WorkerFK int index ixWorkerFK nonClustered
		,SubtopicFK int  
		,topicfk int
		,topiccode numeric(4,1)
		,SubTopicName char(100)
		,IsExempt bit
	)

	declare @tblFinal table (
		Field varchar(20)
		, Value varchar(10))

	insert into @ctAttendee

	select t.TrainingPK
		 , t.TrainingDate
		 , ta.WorkerFK
		 , td.SubTopicFK
		 , td.topicfk
		 , codetopic.topiccode
		 , st.SubTopicName
		 , t.IsExempt
	from Training t
	inner join TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK 
	inner join TrainingDetail td ON td.TrainingFK=t.TrainingPK
	inner join @ctWorkerTable w ON w.WorkerPK = ta.workerfk
	inner join WorkerProgram wp ON wp.WorkerFK=w.WorkerPK  AND wp.ProgramFK = @ProgramFK
	right join codetopic ON codetopic.codeTopicPK = td.topicfk
	left join SubTopic st ON st.SubTopicPK=td.SubTopicFK
	where ta.WorkerFK is not null

	--select * from @ctAttendee ca 

	;with ctMain AS
	(
	select rtrim(FirstName) + ' ' + rtrim(LastName) as Name
	, fn.WorkerPK
	, fn.FAWInitialStart
	, fn.SupervisorInitialStart
	, fn.FSWInitialStart
	, fn.TerminationDate
	, fn.HireDate
	, fn.FirstASQDate
	, fn.FirstHomeVisitDate
	, fn.FirstKempeDate
	, fn.FirstEvent
	, fn.SupervisorFirstEvent
	, fn.FirstPSIDate
	, fn.FirstPHQDate
	, fn.firstHITSDate
	, fn.firstAuditCDate
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 1.0) AS 'f1'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 2.0 AND ctA.SubTopicFK IS Null) AS 'f2'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=65) AS 'f2a'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=66) AS 'f2b'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=67) AS 'f2c'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 3.0) AS 'f3'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 4.0) AS 'f4'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 5.0) AS 'f5'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 5.5) AS 'f55'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 6.0) AS 'f6'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 7.0) AS 'f7'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 7.1) AS 'f7a'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 8.0) AS 'f8'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 9.0) as 'f9'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 9.1) as 'f91'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 10.0) AS 'f10'
	
		--HW997 Training Tickler and Required Topics - Remove Subtopic 82
	--, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=82) AS 'f10a'
		--END HW997	
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 11.0) as 'f11'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 12.0) as 'f12'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 12.1) as 'f121'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 13.0) as 'f13'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=1) AS 'f14a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=2) AS 'f14b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=3) AS 'f14c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=4) AS 'f14d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=5) AS 'f15a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=6) AS 'f15b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=7) AS 'f15c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=8) AS 'f15d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=9) AS 'f15e'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=10) AS 'f15f'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=11) AS 'f15g'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=12) AS 'f15h'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=13) AS 'f15i'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=14) AS 'f16a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=15) AS 'f16b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=16) AS 'f16c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=17) AS 'f16d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=18) AS 'f16e'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=19) AS 'f16f'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=3289) AS 'f16g'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=20) AS 'f17a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=21) AS 'f17b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=22) AS 'f17c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=70) AS 'f17d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=23) AS 'f17e' 
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=24) AS 'f18a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=25) AS 'f18b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=26) AS 'f18c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=27) AS 'f19a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=28) AS 'f19b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=29) AS 'f19c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=30) AS 'f19d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=31) AS 'f19e'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=32) AS 'f19f'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=33) AS 'f20a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=34) AS 'f20b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=35) AS 'f21a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=36) AS 'f21b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=37) AS 'f21c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=38) AS 'f21d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=76) AS 'f21e'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=83) AS 'f21f'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=84) AS 'f21g'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=39) AS 'f22a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=40) AS 'f22b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=71) AS 'f22c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=41) AS 'f22d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=42) AS 'f22e'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=43) AS 'f22f'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=44) AS 'f22g'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=45) AS 'f22h'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=46) AS 'f23a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=47) AS 'f23b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=48) AS 'f23c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=49) AS 'f23d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=50) AS 'f23e'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=51) AS 'f23f'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=52) AS 'f24a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=53) AS 'f24b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=54) AS 'f24c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=55) AS 'f24d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=56) AS 'f24e'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=57) AS 'f24f'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=58) AS 'f25a'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=59) AS 'f25b'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=60) AS 'f25c'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=61) AS 'f25d'
	, (SELECT CASE max(cast(ctA.IsExempt AS INT)) WHEN 1 THEN @minDate ELSE min(trainingdate) END AS ccc  FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=62) AS 'f25e'
	--CP 6/12/2015 Adding New HFA Required topics-----------------
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 39.0) AS 'f39'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 40.0) AS 'f40'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 41.0) AS 'f41'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 42.0) AS 'f42'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 43.0) AS 'f43'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 44.0) AS 'f44'
	, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 45.0) AS 'f45'

	-------END CP 6/12/2015 Adding New HFA Required topics ---------------
	from Worker w
	inner join dbo.fnGetWorkerEventDates(@ProgramFK, null, @WorkerFK) fn on fn.workerpk = w.workerpk
	)
	, cteMain as 
	(
		select distinct [Name]
			 , [WorkerPK]
			 , [FAWInitialStart]
			 , [SupervisorInitialStart]
			 , [SupervisorFirstEvent]
			 , [TerminationDate]
			 , [HireDate]
			 , [FirstASQDate]
			 , [FirstHomeVisitDate]
			 , [FirstKempeDate]
			 , [FirstEvent]
			 , [FirstPSIDate]
			 , [FirstPHQDate]
			 , [FirstHITSDate]
			 , [FirstAuditCDate]
			, coalesce(convert(varchar(10), [f1], 120), 'None') as [f1]
			, coalesce(convert(varchar(10), [f2], 120), 'None') as [f2]
			, coalesce(convert(varchar(10), [f2a], 120), 'None') as [f2a]
			, coalesce(convert(varchar(10), [f2b], 120), 'None') as [f2b]
			, coalesce(convert(varchar(10), [f2c], 120), 'None') as [f2c]
			, coalesce(convert(varchar(10), [f3], 120), 'None') as [f3]
			, coalesce(convert(varchar(10), [f4], 120), 'None') as [f4]
			, coalesce(convert(varchar(10), [f5], 120), 'None') as [f5]
			, coalesce(convert(varchar(10), [f55], 120), 'None') as [f55]
			, coalesce(convert(varchar(10), [f6], 120), 'None') as [f6]
			, coalesce(convert(varchar(10), [f7], 120), 'None') as [f7]
			, coalesce(convert(varchar(10), [f7a], 120), 'None') as [f7a]
			, coalesce(convert(varchar(10), [f8], 120), 'None') as [f8]
			, coalesce(convert(varchar(10), [f9], 120), 'None') as [f9]
			, coalesce(convert(varchar(10), [f91], 120), 'None') as [f91]
			, coalesce(convert(varchar(10), [f10], 120), 'None') as [f10]	
			, coalesce(convert(varchar(10), [f11], 120), 'None') as [f11]
			, coalesce(convert(varchar(10), [f12], 120), 'None') as [f12]
			, coalesce(convert(varchar(10), [f121], 120), 'None') as [f121]
			, coalesce(convert(varchar(10), [f13], 120), 'None') as [f13]
			, coalesce(convert(varchar(10), [f39], 120), 'None') as [f39]
			, coalesce(convert(varchar(10), [f40], 120), 'None') as [f40]
			, coalesce(convert(varchar(10), [f41], 120), 'None') as [f41]
			, coalesce(convert(varchar(10), [f42], 120), 'None') as [f42]
			, coalesce(convert(varchar(10), [f43], 120), 'None') as [f43]
			, coalesce(convert(varchar(10), [f44], 120), 'None') as [f44]
			, coalesce(convert(varchar(10), [f45], 120), 'None') as [f45]
			, coalesce(convert(varchar(10), [f14a], 120), 'None') as [f14a]
			, coalesce(convert(varchar(10), [f14b], 120), 'None') as [f14b]
			, coalesce(convert(varchar(10), [f14c], 120), 'None') as [f14c]
			, coalesce(convert(varchar(10), [f14d], 120), 'None') as [f14d]
			, coalesce(convert(varchar(10), [f15a], 120), 'None') as [f15a]
			, coalesce(convert(varchar(10), [f15b], 120), 'None') as [f15b]
			, coalesce(convert(varchar(10), [f15c], 120), 'None') as [f15c]
			, coalesce(convert(varchar(10), [f15d], 120), 'None') as [f15d]
			, coalesce(convert(varchar(10), [f15e], 120), 'None') as [f15e]
			, coalesce(convert(varchar(10), [f15f], 120), 'None') as [f15f]
			, coalesce(convert(varchar(10), [f15g], 120), 'None') as [f15g]
			, coalesce(convert(varchar(10), [f15h], 120), 'None') as [f15h]
			, coalesce(convert(varchar(10), [f15i], 120), 'None') as [f15i]
			, coalesce(convert(varchar(10), [f16a], 120), 'None') as [f16a]
			, coalesce(convert(varchar(10), [f16b], 120), 'None') as [f16b]
			, coalesce(convert(varchar(10), [f16c], 120), 'None') as [f16c]
			, coalesce(convert(varchar(10), [f16d], 120), 'None') as [f16d] 
			, coalesce(convert(varchar(10), [f16e], 120), 'None') as [f16e]
			, coalesce(convert(varchar(10), [f16f], 120), 'None') as [f16f]
			, coalesce(convert(varchar(10), [f16g], 120), 'None') as [f16g]
			, coalesce(convert(varchar(10), [f17a], 120), 'None') as [f17a]
			, coalesce(convert(varchar(10), [f17b], 120), 'None') as [f17b]
			, coalesce(convert(varchar(10), [f17c], 120), 'None') as [f17c]
			, coalesce(convert(varchar(10), [f17d], 120), 'None') as [f17d]
			, coalesce(convert(varchar(10), [f17e], 120), 'None') as [f17e] --there's no 'd' in this report
			, coalesce(convert(varchar(10), [f18a], 120), 'None') as [f18a]
			, coalesce(convert(varchar(10), [f18b], 120), 'None') as [f18b]
			, coalesce(convert(varchar(10), [f18c], 120), 'None') as [f18c]
			, coalesce(convert(varchar(10), [f19a], 120), 'None') as [f19a]
			, coalesce(convert(varchar(10), [f19b], 120), 'None') as [f19b]
			, coalesce(convert(varchar(10), [f19c], 120), 'None') as [f19c]
			, coalesce(convert(varchar(10), [f19d], 120), 'None') as [f19d]
			, coalesce(convert(varchar(10), [f19e], 120), 'None') as [f19e]
			, coalesce(convert(varchar(10), [f19f], 120), 'None') as [f19f]
			, coalesce(convert(varchar(10), [f20a], 120), 'None') as [f20a]
			, coalesce(convert(varchar(10), [f20b], 120), 'None') as [f20b]
			, coalesce(convert(varchar(10), [f21a], 120), 'None') as [f21a]
			, coalesce(convert(varchar(10), [f21b], 120), 'None') as [f21b]
			, coalesce(convert(varchar(10), [f21c], 120), 'None') as [f21c]
			, coalesce(convert(varchar(10), [f21d], 120), 'None') as [f21d]
			, coalesce(convert(varchar(10), [f21e], 120), 'None') as [f21e]
			, coalesce(convert(varchar(10), [f21f], 120), 'None') as [f21f]
			, coalesce(convert(varchar(10), [f21g], 120), 'None') as [f21g]
			, coalesce(convert(varchar(10), [f22a], 120), 'None') as [f22a]
			, coalesce(convert(varchar(10), [f22b], 120), 'None') as [f22b]
			, coalesce(convert(varchar(10), [f22c], 120), 'None') as [f22c]
			, coalesce(convert(varchar(10), [f22d], 120), 'None') as [f22d]
			, coalesce(convert(varchar(10), [f22e], 120), 'None') as [f22e]
			, coalesce(convert(varchar(10), [f22f], 120), 'None') as [f22f]
			, coalesce(convert(varchar(10), [f22g], 120), 'None') as [f22g]
			, coalesce(convert(varchar(10), [f22h], 120), 'None') as [f22h]
			, coalesce(convert(varchar(10), [f23a], 120), 'None') as [f23a]
			, coalesce(convert(varchar(10), [f23b], 120), 'None') as [f23b]
			, coalesce(convert(varchar(10), [f23c], 120), 'None') as [f23c]
			, coalesce(convert(varchar(10), [f23d], 120), 'None') as [f23d]
			, coalesce(convert(varchar(10), [f23e], 120), 'None') as [f23e]
			, coalesce(convert(varchar(10), [f23f], 120), 'None') as [f23f]
			, coalesce(convert(varchar(10), [f24a], 120), 'None') as [f24a]
			, coalesce(convert(varchar(10), [f24b], 120), 'None') as [f24b]
			, coalesce(convert(varchar(10), [f24c], 120), 'None') as [f24c]
			, coalesce(convert(varchar(10), [f24d], 120), 'None') as [f24d]
			, coalesce(convert(varchar(10), [f24e], 120), 'None') as [f24e]
			, coalesce(convert(varchar(10), [f24f], 120), 'None') as [f24f]
			, coalesce(convert(varchar(10), [f25a], 120), 'None') as [f25a]
			, coalesce(convert(varchar(10), [f25b], 120), 'None') as [f25b]
			, coalesce(convert(varchar(10), [f25c], 120), 'None') as [f25c]
			, coalesce(convert(varchar(10), [f25d], 120), 'None') as [f25d]
			, coalesce(convert(varchar(10), [f25e], 120), 'None') as [f25e]
		FROM ctMain
		WHERE ctMain.WorkerPK = isnull(@WorkerFK, ctMain.WorkerPK)
	)
	--select * from cteMain

	insert into @tblFinal (Field, Value)
		select	field
			, value
		from	cteMain as Col1
			unpivot
				(value for field in (--[WorkerPK]
									--, [FAWInitialStart]
									--, [SupervisorInitialStart]
									--, [SupervisorFirstEvent]
									--, [TerminationDate]
									--, [HireDate]
									--, [FirstASQDate]
									--, [FirstHomeVisitDate]
									--, [FirstKempeDate]
									--, [FirstEvent]
									--, [FirstPSIDate]
									--, [FirstPHQDate]
									--, [FirstHITSDate]
									--, [FirstAuditCDate]
									[f1]
									, [f2]
									, [f2a]
									, [f2b]
									, [f2c]
									, [f3]
									, [f4]
									, [f5]
									, [f55]
									, [f6]
									, [f7]
									, [f7a]
									, [f8]
									, [f9]
									, [f91]
									, [f10]
									, [f11]
									, [f12]
									, [f121]
									, [f13]
									, [f39]
									, [f40]
									, [f41]
									, [f42]
									, [f43]
									, [f44]
									, [f45]
									, [f14a]
									, [f14b]
									, [f14c]
									, [f14d]
									, [f15a]
									, [f15b]
									, [f15c]
									, [f15d]
									, [f15e]
									, [f15f]
									, [f15g]
									, [f15h]
									, [f15i]
									, [f16a]
									, [f16b]
									, [f16c]
									, [f16d]
									, [f16e]
									, [f16f]
									, [f16g]
									, [f17a]
									, [f17b]
									, [f17c]
									, [f17d]
									, [f17e]
									, [f18a]
									, [f18b]
									, [f18c]
									, [f19a]
									, [f19b]
									, [f19c]
									, [f19d]
									, [f19e]
									, [f19f]
									, [f20a]
									, [f20b]
									, [f21a]
									, [f21b]
									, [f21c]
									, [f21d]
									, [f21e]
									, [f21f]
									, [f21g]
									, [f22a]
									, [f22b]
									, [f22c]
									, [f22d]
									, [f22e]
									, [f22f]
									, [f22g]
									, [f22h]
									, [f23a]
									, [f23b]
									, [f23c]
									, [f23d]
									, [f23e]
									, [f23f]
									, [f24a]
									, [f24b]
									, [f24c]
									, [f24d]
									, [f24e]
									, [f24f]
									, [f25a]
									, [f25b]
									, [f25c]
									, [f25d]
									, [f25e]
								) 
				) unpiv1 ;

	with cteTesting as
	(
		select tf.Field
				, tf.Value
				, try_convert(int, substring(Field, 2, 1)) as tc1
				, try_convert(int, substring(Field, 2, 2)) as tc2
				, try_convert(int, substring(Field, 2, 3)) as tc3
				, try_convert(int, substring(Field, 2, 4)) as tc4
				, round(case when len(rtrim(Field)) = 2 
									and try_convert(int, substring(Field, 2, 1)) is not null  
									--and try_convert(int, substring(Field, 2, 2)) is null
							then convert(numeric, substring(Field, 2, 1))
							when len(rtrim(Field)) = 3
									and try_convert(int, substring(Field, 2, 2)) is not null 
									--and try_convert(int, substring(Field, 2, 3)) is null
									and try_convert(int, substring(Field, 2, 2)) < 50
							then convert(numeric, substring(Field, 2, 2))
							when len(rtrim(Field)) = 3
									and isnumeric(substring(Field, 3, 1)) <> 1
							then convert(numeric, substring(Field, 2, 1))
							when len(rtrim(Field)) = 3
									and try_convert(int, substring(Field, 2, 2)) is not null 
									and try_convert(int, substring(Field, 2, 2)) > 50
							then convert(numeric, substring(Field, 2, 2)) / 10
							when len(rtrim(Field)) = 4 
									and try_convert(int, substring(Field, 2, 2)) is not null 
									and try_convert(int, substring(Field, 2, 3)) is null 
							then convert(numeric, substring(Field, 2, 2))
							when len(rtrim(Field)) = 4 
									and isnumeric(substring(Field, 4, 1)) <> 1
							then convert(numeric, substring(Field, 2, 2))
							when len(rtrim(Field)) = 4 
									and try_convert(int, substring(Field, 2, 3)) is not null 
							then convert(numeric, substring(Field, 2, 3)) / 10
						else null
					end, 2) as ConvertedTopicCodeField
				, case when len(rtrim(Field)) = 3
								and isnumeric(substring(Field, 3, 1)) <> 1
						then substring(Field, 3, 1)
						when len(rtrim(Field)) = 4
								and isnumeric(substring(Field, 4, 1)) <> 1
						then substring(Field, 4, 1)
					else null
					end as ConvertedSubTopicCodeField
		from @tblFinal tf
	)
	select t.Field as LineID
			, t.Value as DateCompleted
			, t.ConvertedTopicCodeField
			, t.ConvertedSubTopicCodeField
			, ct.TopicName
			, ct.TopicCode
			, st.ProgramFK
			, st.RequiredBy
			, st.SATFK
			, st.SubTopicCode
			, st.SubTopicName
	from cteTesting t
	left outer join codeTopic ct on convert(numeric(4,2), t.ConvertedTopicCodeField) 
									= convert(numeric(4,2), ct.TopicCode)
	left outer join SubTopic st on ct.codeTopicPK = st.TopicFK 
									and t.ConvertedSubTopicCodeField = st.SubTopicCode
									and (st.ProgramFK is null 
											or st.ProgramFK = isnull(@ProgramFK, st.ProgramFK))
	where t.Value = 'None'
	order by t.ConvertedTopicCodeField, st.ProgramFK
end ;

GO
