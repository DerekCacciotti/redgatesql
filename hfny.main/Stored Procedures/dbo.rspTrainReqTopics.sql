SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 8/16/2012
-- Description:	Report: Training Required Topics
-- EXEC rspTrainReqTopics 1, NULL, NULL
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- Edit date: 6/12/2015 CP - Changes for new HFA standards
-- Edit date: 7/24/2019 CP -- Implicit conversion of date to integer began to fail with latest Azure database updates
-- =============================================

--exec dbo.rspTrainReqTopics @prgfk=1,@super=NULL,@worker=151


CREATE procedure [dbo].[rspTrainReqTopics]
	-- Add the parameters for the stored procedure here
	@prgfk AS INT,
	@super AS INT,
	@worker AS INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		SET NOCOUNT ON;

declare @minDate datetime = '01/01/1901'

declare @ctWorkerTable table (
	workerpk INT INDEX IDX1 NONCLUSTERED
	, workername varchar(100)
)

if @worker is null
	insert into @ctWorkerTable
	select workerfk, firstname + ' ' + lastname from WorkerProgram wp
	 INNER JOIN worker ON wp.workerfk = WorkerPK
	 where wp.ProgramFK = @prgfk;
else
    insert into @ctWorkerTable 	
	SELECT workerfk, firstname + ' ' + lastname from WorkerProgram wp
	 INNER JOIN worker ON wp.workerfk = WorkerPK
	 where wp.ProgramFK = @prgfk AND worker.workerpk = @worker;

declare @ctAttendee table (
	TrainingPK INT  INDEX IDX1 NONCLUSTERED
	,TrainingDate DATETIME  INDEX IDX2 NONCLUSTERED
	,WorkerFK int index ixWorkerFK nonClustered
	,SubtopicFK int  
	,topicfk int
	,topiccode numeric(4,1)
	,SubTopicName char(100)
	,IsExempt bit
)
insert into @ctAttendee

SELECT t.TrainingPK
	 , t.TrainingDate
	 , ta.WorkerFK
	 , td.SubTopicFK
	 , td.topicfk
	 , codetopic.topiccode
	 , st.SubTopicName
	 , t.IsExempt
FROM Training t
INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK 
INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK
INNER JOIN @ctWorkerTable w ON w.WorkerPK = ta.workerfk
INNER JOIN WorkerProgram wp ON wp.WorkerFK=w.WorkerPK  AND wp.ProgramFK=@prgfk
RIGHT JOIN codetopic ON codetopic.codeTopicPK = td.topicfk
left JOIN SubTopic st ON st.SubTopicPK=td.SubTopicFK
where ta.WorkerFK is not null

DECLARE @ctMain AS TABLE (
[Name] VARCHAR(100)
, WorkerPK INT  INDEX IDX1 NONCLUSTERED
, FAWInitialStart DATE  INDEX IDX2 NONCLUSTERED
, SupervisorInitialStart DATE  INDEX IDX3 NONCLUSTERED
, FSWInitialStart DATE  INDEX IDX4 NONCLUSTERED
, TerminationDate DATE
, HireDate DATE
, FirstASQDate DATE
, FirstHomeVisitDate DATE
, FirstKempeDate DATE
, FirstEvent DATE
, SupervisorFirstEvent DATE
, FirstPSIDate DATE
, FirstPHQDate DATE
, firstHITSDate DATE
, firstAuditCDate DATE
, firstCheersDate DATE
, f1  DATE
, f2 DATE
, f2a DATE
, f2b DATE
, f2c DATE
, f3 DATE
, f4 DATE
, f5 DATE
, [f5.5] DATE
, f6 DATE
, f7 DATE
, f7a DATE
, f8 DATE
, f9 DATE
, [f9.1] DATE
, f10 DATE
, f11 DATE
, f12 DATE
, [f12.1] DATE
, f13 DATE
, f14a DATE
, f14b DATE
, f14c DATE
, f14d DATE
, f15a DATE
, f15b DATE
, f15c DATE
, f15d DATE
, f15e DATE
, f15f DATE
, f15g DATE
, f15h DATE
, f15i DATE
, f16a DATE
, f16b DATE
, f16c DATE
, f16d DATE
, f16e DATE
, f16f DATE
, f16g DATE
, f17a DATE
, f17b DATE
, f17c DATE
, f17d DATE
, f17e DATE 
, f18a DATE
, f18b DATE
, f18c DATE
, f19a DATE
, f19b DATE
, f19c DATE
, f19d DATE
, f19e DATE
, f19f DATE
, f20a DATE
, f20b DATE
, f21a DATE
, f21b DATE
, f21c DATE
, f21d DATE
, f21e DATE
, f21f DATE
, f21g DATE
, f22a DATE
, f22b DATE
, f22c DATE
, f22d DATE
, f22e DATE
, f22f DATE
, f22g DATE
, f22h DATE
, f23a DATE
, f23b DATE
, f23c DATE
, f23d DATE
, f23e DATE
, f23f DATE
, f24a DATE
, f24b DATE
, f24c DATE
, f24d DATE
, f24e DATE
, f24f DATE
, f25a DATE
, f25b DATE
, f25c DATE
, f25d DATE
, f25e DATE
, f39 DATE
, f40 DATE
, f41 DATE
, f42 DATE
, f43 DATE
, f44 DATE
, f45 DATE
, f46 DATE
)



INSERT INTO @ctMain ( Name ,
                      WorkerPK ,
                      FAWInitialStart ,
                      SupervisorInitialStart ,
                      FSWInitialStart ,
                      TerminationDate ,
                      HireDate ,
                      FirstASQDate ,
                      FirstHomeVisitDate ,
                      FirstKempeDate ,
                      FirstEvent ,
                      SupervisorFirstEvent ,
                      FirstPSIDate ,
                      FirstPHQDate ,
                      firstHITSDate ,
                      firstAuditCDate ,
					  firstCheersDate,
                      f1 ,
                      f2 ,
                      f2a ,
                      f2b ,
                      f2c ,
                      f3 ,
                      f4 ,
                      f5 ,
                      [f5.5] ,
                      f6 ,
                      f7 ,
                      f7a ,
                      f8 ,
                      f9 ,
                      [f9.1] ,
                      f10 ,
                      f11 ,
                      f12 ,
                      [f12.1] ,
                      f13 ,
                      f14a ,
                      f14b ,
                      f14c ,
                      f14d ,
                      f15a ,
                      f15b ,
                      f15c ,
                      f15d ,
                      f15e ,
                      f15f ,
                      f15g ,
                      f15h ,
                      f15i ,
                      f16a ,
                      f16b ,
                      f16c ,
                      f16d ,
                      f16e ,
                      f16f ,
                      f16g ,
                      f17a ,
                      f17b ,
                      f17c ,
                      f17d ,
                      f17e ,
                      f18a ,
                      f18b ,
                      f18c ,
                      f19a ,
                      f19b ,
                      f19c ,
                      f19d ,
                      f19e ,
                      f19f ,
                      f20a ,
                      f20b ,
                      f21a ,
                      f21b ,
                      f21c ,
                      f21d ,
                      f21e ,
                      f21f ,
                      f21g ,
                      f22a ,
                      f22b ,
                      f22c ,
                      f22d ,
                      f22e ,
                      f22f ,
                      f22g ,
                      f22h ,
                      f23a ,
                      f23b ,
                      f23c ,
                      f23d ,
                      f23e ,
                      f23f ,
                      f24a ,
                      f24b ,
                      f24c ,
                      f24d ,
                      f24e ,
                      f24f ,
                      f25a ,
                      f25b ,
                      f25c ,
                      f25d ,
                      f25e ,
                      f39 ,
                      f40 ,
                      f41 ,
                      f42 ,
                      f43 ,
                      f44 ,
                      f45 ,
					  f46 )

(
SELECT workername
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
, fn.firstCheersDate
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 1.0) AS 'f1'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 2.0 AND ctA.SubTopicFK IS Null) AS 'f2'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=65) AS 'f2a'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=66) AS 'f2b'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.SubTopicFK=67) AS 'f2c'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 3.0) AS 'f3'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 4.0) AS 'f4'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 5.0) AS 'f5'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 5.5) AS 'f5.5'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 6.0) AS 'f6'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 7.0) AS 'f7'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 7.1) AS 'f7a'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 8.0) AS 'f8'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 9.0) as 'f9'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 9.1) as 'f9.1'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 10.0) AS 'f10'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 11.0) as 'f11'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 12.0) as 'f12'
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 12.1) as 'f12.1'
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
, (SELECT min(trainingdate) FROM @ctAttendee ctA WHERE ctA.WorkerFK=w.WorkerPK AND ctA.topiccode= 46.0) AS 'f46'

-------END CP 6/12/2015 Adding New HFA Required topics ---------------
FROM @ctWorkerTable w
INNER JOIN dbo.fnGetWorkerEventDates(@prgfk, @super, @worker) fn ON fn.workerpk = w.workerpk
)


SELECT distinct [Name]
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
	 , [FirstEvent]
	 , [FirstPSIDate]
	 , [FirstPHQDate]
	 , [FirstHITSDate]
	 , [FirstAuditCDate]
	 , [f1]
	 , CASE isnull([f1], '01/01/2100')
		WHEN [f1] THEN
			CASE WHEN datediff(dd, [f1], [FirstEvent]) < 0 THEN '*' 
				ELSE '' END
		ELSE '' END AS 'f1_ast'	 
	 , [f2]
	 , CASE isnull([f2], '01/01/2100')
		WHEN [f2] THEN
			CASE WHEN datediff(dd, [f2], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2_ast'
	 , [f2a]
	 , CASE isnull([f2a], '01/01/2100')
		WHEN [f2a] THEN
			CASE WHEN datediff(dd, [f2a], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2a_ast'
	 , [f2b]
	 , CASE isnull([f2b], '01/01/2100')
		WHEN [f2b] THEN
			CASE WHEN datediff(dd, [f2b], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2b_ast'
	 , [f2c]
	 , CASE isnull([f2c], '01/01/2100')
		WHEN [f2c] THEN
			CASE WHEN datediff(dd, [f2c], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2c_ast'
	 , [f3]
	 , CASE isnull([f3], '01/01/2100')
		WHEN [f3] THEN
			CASE WHEN datediff(dd, [f3], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f3_ast'
	 , [f4]
	 , CASE isnull([f4], '01/01/2100')
		WHEN [f4] THEN
			CASE WHEN datediff(dd, [f4], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f4_ast'
	 , [f5]
	 , CASE isnull([f5], '01/01/2100')
		WHEN [f5] THEN
			CASE WHEN datediff(dd, [f5], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f5_ast'
	 , [f5.5]
	 , CASE isnull([f5.5], '01/01/2100')
		WHEN [f5.5] THEN
			CASE WHEN datediff(dd, [f5.5], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f5.5_ast'
	 , [f6]
	 , CASE isnull([f6], '01/01/2100')
		WHEN [f6] THEN
			CASE WHEN datediff(dd, [f6], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f6_ast'
	 , [f7]
	 , CASE isnull([f7], '01/01/2100')
		WHEN [f7] THEN
			CASE WHEN datediff(dd, [f7], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f7_ast'
	 , [f7a]
	 , CASE isnull([f7a], '01/01/2100')
		WHEN [f7a] THEN
			CASE WHEN datediff(dd, [f7a], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f7.1_ast'
	 , [f8]
	 , [f9]
	 , CASE isnull(FAWInitialStart, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 9.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f9], [FirstKempeDate]) < 0 THEN '*' END
		END AS 'f9_ast' 
	 , [f9.1]
	 , CASE isnull(SupervisorInitialStart, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 9.1 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f9.1], [SupervisorFirstEvent]) < 0 THEN '*' END
		END AS 'f9_1_ast' 
	 , [f10]
	 , CASE isnull(FAWInitialStart, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 9.0 is only for FAW's
		ELSE 
			CASE WHEN datediff(dd, [f10], [FAWInitialStart]) < -183 THEN '*' END
		END AS 'f10_ast'		
	 , [f11]
	 , CASE isnull(FSWInitialStart, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 9.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f11], [FSWInitialStart]) < -183 THEN '*' END
		END AS 'f11a_ast'
	 , [f12]
	 , CASE isnull(SupervisorInitialStart, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 12 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f12], [SupervisorInitialStart]) < -183 THEN '*' END
		END AS 'f12_ast'
	 , [f12.1]
	 , CASE isnull(SupervisorInitialStart, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 12 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f12.1], [SupervisorInitialStart]) < -183 THEN '*' END
		END AS 'f12_1_ast'
	 , [f13]
	 , CASE isnull(FSWInitialStart, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 13 ASQ is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f13], [firstasqdate]) < 0 THEN '*' END
		END AS 'f13_ast'
	
 , [f39]
	 , CASE isnull([f39], '01/01/2100')
		WHEN [f39] THEN
			CASE WHEN datediff(dd, [f39], [FirstPHQDate]) < -1 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f39_ast'

 , [f40]
	 , CASE isnull([f40], '01/01/2100')
		WHEN [f40] THEN
			CASE WHEN datediff(dd, [f40], [HireDate]) < -181 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f40_ast'

 , [f41]
	 , CASE isnull([f41], '01/01/2100')
		WHEN [f41] THEN
			CASE WHEN datediff(dd, [f41], [HireDate]) < -181 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f41_ast'
	
 , [f42]
	 , CASE isnull([f42], '01/01/2100')
		WHEN [f42] THEN
			CASE WHEN datediff(dd, [f42], GETDATE()) < -365 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f42_ast'
			
 , [f43]
 	 , CASE isnull(FirstPSIDate, '01/01/2100')
		WHEN '01/01/2100' THEN '' --do nothing as 43 are only for people completing PSI's
		ELSE 
			CASE WHEN datediff(dd, [f43], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		END AS 'f43_ast'	
	
 , [f44]
	 , CASE isnull([f44], '01/01/2100')
		WHEN [f44] THEN
			CASE WHEN datediff(dd, [f44], [firstHITSDate]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f44_ast'		
		
 , [f45]
	 , CASE isnull([f45], '01/01/2100')
		WHEN [f45] THEN
			CASE WHEN datediff(dd, [f45], [firstAuditCDate]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f45_ast'
		
 , [f46]
	 , CASE isnull([f46], '01/01/2100')
		WHEN [f46] THEN
			CASE WHEN datediff(dd, [f46], [firstCheersDate]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f46_ast'
		
	 , [f14a]
	 , CASE isnull([f14a], '01/01/2100')
		WHEN [f14a] THEN
			CASE WHEN datediff(dd, [f14a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14a_ast'
	 , [f14b]
	 , CASE isnull([f14b], '01/01/2100')
		WHEN [f14b] THEN
			CASE WHEN datediff(dd, [f14b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14b_ast'
	 , [f14c]
	 , CASE isnull([f14c], '01/01/2100')
		WHEN [f14c] THEN
			CASE WHEN datediff(dd, [f14c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14c_ast'
	 , [f14d]
	 , CASE isnull([f14d], '01/01/2100')
		WHEN [f14d] THEN
			CASE WHEN datediff(dd, [f14d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14d_ast'
	 , [f15a]
	 , CASE isnull([f15a], '01/01/2100')
		WHEN [f15a] THEN
			CASE WHEN datediff(dd, [f15a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15a_ast'
	 , [f15b]
	 , CASE isnull([f15b], '01/01/2100')
		WHEN [f15b] THEN
			CASE WHEN datediff(dd, [f15b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15b_ast'
	 , [f15c]
	 , CASE isnull([f15c], '01/01/2100')
		WHEN [f15c] THEN
			CASE WHEN datediff(dd, [f15c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15ac_ast'
	 , [f15d]
	 , CASE isnull([f15d], '01/01/2100')
		WHEN [f15d] THEN
			CASE WHEN datediff(dd, [f15d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15d_ast'
	 , [f15e]
	 , CASE isnull([f15e], '01/01/2100')
		WHEN [f15e] THEN
			CASE WHEN datediff(dd, [f15e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15e_ast'
	 , [f15f]
	 , CASE isnull([f15f], '01/01/2100')
		WHEN [f15f] THEN
			CASE WHEN datediff(dd, [f15f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15f_ast'
	 , [f15g]
	 , CASE isnull([f15g], '01/01/2100')
		WHEN [f15g] THEN
			CASE WHEN datediff(dd, [f15g], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15g_ast'
	 , [f15h]
	 , CASE isnull([f15h], '01/01/2100')
		WHEN [f15h] THEN
			CASE WHEN datediff(dd, [f15h], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15h_ast'
	 , [f15i]
	 , CASE isnull([f15i], '01/01/2100')
		WHEN [f15i] THEN
			CASE WHEN datediff(dd, [f15i], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15i_ast'
	 , [f16a]
	 , CASE isnull([f16a], '01/01/2100')
		WHEN [f16a] THEN
			CASE WHEN datediff(dd, [f16a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16a_ast'
	 , [f16b]
	 , CASE isnull([f16b], '01/01/2100')
		WHEN [f16b] THEN
			CASE WHEN datediff(dd, [f16b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16b_ast'
	 , [f16c]
	 , CASE isnull([f16c], '01/01/2100')
		WHEN [f16c] THEN
			CASE WHEN datediff(dd, [f16c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16c_ast'
	 , [f16d] 
	 , CASE isnull([f16d], '01/01/2100')
		WHEN [f16d] THEN
			CASE WHEN datediff(dd, [f16d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16d_ast'
	 , [f16e]
	 , CASE isnull([f16e], '01/01/2100')
		WHEN [f16e] THEN
			CASE WHEN datediff(dd, [f16e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16e_ast'
	 , [f16f]
	 , CASE isnull([f16f], '01/01/2100')
		WHEN [f16f] THEN
			CASE WHEN datediff(dd, [f16f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16f_ast'
	 , [f16g]
	 , CASE isnull([f16g], '01/01/2100')
		WHEN [f16g] THEN
			CASE WHEN datediff(dd, [f16g], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16g_ast'
	 , [f17a]
	 , CASE isnull([f17a], '01/01/2100')
		WHEN [f17a] THEN
			CASE WHEN datediff(dd, [f17a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17a_ast'
	 , [f17b]
	 , CASE isnull([f17b], '01/01/2100')
		WHEN [f17b] THEN
			CASE WHEN datediff(dd, [f17b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17b_ast'
	 , [f17c]
	 , CASE isnull([f17c], '01/01/2100')
		WHEN [f17c] THEN
			CASE WHEN datediff(dd, [f17c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17c_ast'
	 , [f17d]
	 , CASE isnull([f17d], '01/01/2100')
		WHEN [f17d] THEN
			CASE WHEN datediff(dd, [f17d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17d_ast'
	 , [f17e] --there's no 'd' in this report
	 , CASE isnull([f17e], '01/01/2100')
		WHEN [f17e] THEN
			CASE WHEN datediff(dd, [f17e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17e_ast'
	 , [f18a]
	 , CASE isnull([f18a], '01/01/2100')
		WHEN [f18a] THEN
			CASE WHEN datediff(dd, [f18a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18a_ast'
	 , [f18b]
	 , CASE isnull([f18b], '01/01/2100')
		WHEN [f18b] THEN
			CASE WHEN datediff(dd, [f18b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18b_ast'
	 , [f18c]
	 , CASE isnull([f18c], '01/01/2100')
		WHEN [f18c] THEN
			CASE WHEN datediff(dd, [f18c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18c_ast'
	 , [f19a]
	 , CASE isnull([f19a], '01/01/2100')
		WHEN [f19a] THEN
			CASE WHEN datediff(dd, [f19a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19a_ast'
	 , [f19b]
	 , CASE isnull([f19b], '01/01/2100')
		WHEN [f19b] THEN
			CASE WHEN datediff(dd, [f19b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19b_ast'
	 , [f19c]
	 , CASE isnull([f19c], '01/01/2100')
		WHEN [f19c] THEN
			CASE WHEN datediff(dd, [f19c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19c_ast'
	 , [f19d]
	 , CASE isnull([f19d], '01/01/2100')
		WHEN [f19d] THEN
			CASE WHEN datediff(dd, [f19d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19d_ast'
	 , [f19e]
	 , CASE isnull([f19e], '01/01/2100')
		WHEN [f19e] THEN
			CASE WHEN datediff(dd, [f19e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19e_ast'
	 , [f19f]
	 , CASE isnull([f19f], '01/01/2100')
		WHEN [f19f] THEN
			CASE WHEN datediff(dd, [f19f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19f_ast'
	 , [f20a]
	 , CASE isnull([f20a], '01/01/2100')
		WHEN [f20a] THEN
			CASE WHEN datediff(dd, [f20a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f20a_ast'
	 , [f20b]
	 , CASE isnull([f20b], '01/01/2100')
		WHEN [f20b] THEN
			CASE WHEN datediff(dd, [f20b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f20b_ast'
	 , [f21a]
	 , CASE isnull([f21a], '01/01/2100')
		WHEN [f21a] THEN
			CASE WHEN datediff(dd, [f21a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21a_ast'
	 , [f21b]
	 , CASE isnull([f21b], '01/01/2100')
		WHEN [f21b] THEN
			CASE WHEN datediff(dd, [f21b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21b_ast'
	 , [f21c]
	 , CASE isnull([f21c], '01/01/2100')
		WHEN [f21c] THEN
			CASE WHEN datediff(dd, [f21c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21c_ast'
	 , [f21d]
	 , CASE isnull([f21d], '01/01/2100')
		WHEN [f21d] THEN
			CASE WHEN datediff(dd, [f21d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21d_ast'
	 , [f21e]
	 , CASE isnull([f21e], '01/01/2100')
		WHEN [f21e] THEN
			CASE WHEN datediff(dd, [f21e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21e_ast'
	 , [f21f]
	 , CASE isnull([f21f], '01/01/2100')
		WHEN [f21f] THEN
			CASE WHEN datediff(dd, [f21f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21f_ast'
	 , [f21g]
	 , CASE isnull([f21g], '01/01/2100')
		WHEN [f21g] THEN
			CASE WHEN datediff(dd, [f21g], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21g_ast'
	 , [f22a]
	 , CASE isnull([f22a], '01/01/2100')
		WHEN [f22a] THEN
			CASE WHEN datediff(dd, [f22a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22a_ast'
	 , [f22b]
	 , CASE isnull([f22b], '01/01/2100')
		WHEN [f22b] THEN
			CASE WHEN datediff(dd, [f22b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22b_ast'
	 , [f22c]
	 , CASE isnull([f22c], '01/01/2100')
		WHEN [f22c] THEN
			CASE WHEN datediff(dd, [f22c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22c_ast'
	 , [f22d]
	 , CASE isnull([f22d], '01/01/2100')
		WHEN [f22d] THEN
			CASE WHEN datediff(dd, [f22d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22d_ast'
	 , [f22e]
	 , CASE isnull([f22e], '01/01/2100')
		WHEN [f22e] THEN
			CASE WHEN datediff(dd, [f22e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22e_ast'
	 , [f22f]
	 , CASE isnull([f22f], '01/01/2100')
		WHEN [f22f] THEN
			CASE WHEN datediff(dd, [f22f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22f_ast'
	 , [f22g]
	 , CASE isnull([f22g], '01/01/2100')
		WHEN [f22g] THEN
			CASE WHEN datediff(dd, [f22g], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22g_ast'
	 , [f22h]
	 , CASE isnull([f22h], '01/01/2100')
		WHEN [f22h] THEN
			CASE WHEN datediff(dd, [f22h], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22h_ast'
	 , [f23a]
	 , CASE isnull([f23a], '01/01/2100')
		WHEN [f23a] THEN
			CASE WHEN datediff(dd, [f23a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23a_ast'
	 , [f23b]
	 , CASE isnull([f23b], '01/01/2100')
		WHEN [f23b] THEN
			CASE WHEN datediff(dd, [f23b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23b_ast'
	 , [f23c]
	 , CASE isnull([f23c], '01/01/2100')
		WHEN [f23c] THEN
			CASE WHEN datediff(dd, [f23c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23c_ast'
	 , [f23d]
	 , CASE isnull([f23d], '01/01/2100')
		WHEN [f23d] THEN
			CASE WHEN datediff(dd, [f23d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23d_ast'
	 , [f23e]
	 , CASE isnull([f23e], '01/01/2100')
		WHEN [f23e] THEN
			CASE WHEN datediff(dd, [f23e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23e_ast'
	 , [f23f]
	 , CASE isnull([f23f], '01/01/2100')
		WHEN [f23f] THEN
			CASE WHEN datediff(dd, [f23f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23f_ast'
	 , [f24a]
	 , CASE isnull([f24a], '01/01/2100')
		WHEN [f24a] THEN
			CASE WHEN datediff(dd, [f24a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24a_ast'
	 , [f24b]
	 , CASE isnull([f24b], '01/01/2100')
		WHEN [f24b] THEN
			CASE WHEN datediff(dd, [f24b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24b_ast'
	 , [f24c]
	 , CASE isnull([f24c], '01/01/2100')
		WHEN [f24c] THEN
			CASE WHEN datediff(dd, [f24c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24c_ast'
	 , [f24d]
	 , CASE isnull([f24d], '01/01/2100')
		WHEN [f24d] THEN
			CASE WHEN datediff(dd, [f24d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24d_ast'
	 , [f24e]
	 , CASE isnull([f24e], '01/01/2100')
		WHEN [f24e] THEN
			CASE WHEN datediff(dd, [f24e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24e_ast'
	 , [f24f]
	 , CASE isnull([f24f], '01/01/2100')
		WHEN [f24f] THEN
			CASE WHEN datediff(dd, [f24f], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24f_ast'
	 , [f25a]
	 , CASE isnull([f25a], '01/01/2100')
		WHEN [f25a] THEN
			CASE WHEN datediff(dd, [f25a], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25a_ast'
	 , [f25b]
	 , CASE isnull([f25b], '01/01/2100')
		WHEN [f25b] THEN
			CASE WHEN datediff(dd, [f25b], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25b_ast'
	 , [f25c]
	 , CASE isnull([f25c], '01/01/2100')
		WHEN [f25c] THEN
			CASE WHEN datediff(dd, [f25c], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25c_ast'
	 , [f25d]
	 , CASE isnull([f25d], '01/01/2100')
		WHEN [f25d] THEN
			CASE WHEN datediff(dd, [f25d], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25d_ast'
	 , [f25e]
	 , CASE isnull([f25e], '01/01/2100')
		WHEN [f25e] THEN
			CASE WHEN datediff(dd, [f25e], [HireDate]) < -366 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25e_ast'
FROM @ctMain ctm
WHERE ctm.WorkerPK = isnull(@worker,ctm.WorkerPK)
 ORDER BY Name


END
GO
