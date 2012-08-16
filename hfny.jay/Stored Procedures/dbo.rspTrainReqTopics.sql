SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 8/16/2012
-- Description:	Report: Training Required Topics
-- =============================================
CREATE PROCEDURE [dbo].[rspTrainReqTopics]
	-- Add the parameters for the stored procedure here
	@prgfk AS INT,
	@super AS INT,
	@worker AS INT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
WITH ctMain AS
(
SELECT firstname, lastname
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
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=1) AS 'f1'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=65) AS 'f2a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=66) AS 'f2b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=67) AS 'f2c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=3) AS 'f3'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=4) AS 'f4'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=5) AS 'f5'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=6) AS 'f6'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=32) AS 'f7'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=7) AS 'f8'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=8) as 'f9'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=39) as 'f9.1'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=82) AS 'f10a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=10) as 'f11'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=11) as 'f12'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.TopicFK=12) as 'f13'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=1) AS 'f14a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=2) AS 'f14b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=3) AS 'f14c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=4) AS 'f14d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=5) AS 'f15a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=6) AS 'f15b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=7) AS 'f15c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=8) AS 'f15d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=9) AS 'f15e'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=10) AS 'f15f'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=11) AS 'f15g'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=12) AS 'f15h'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=13) AS 'f15i'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=14) AS 'f16a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=15) AS 'f16b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=16) AS 'f16c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=17) AS 'f16d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=18) AS 'f16e'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=19) AS 'f16f'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=20) AS 'f17a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=21) AS 'f17b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=22) AS 'f17c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=23) AS 'f17e' --as per FoxPro, there is no 'd'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=24) AS 'f18a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=25) AS 'f18b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=26) AS 'f18c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=27) AS 'f19a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=28) AS 'f19b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=29) AS 'f19c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=30) AS 'f19d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=31) AS 'f19e'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=32) AS 'f19f'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=33) AS 'f20a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=34) AS 'f20b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=35) AS 'f21a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=36) AS 'f21b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=37) AS 'f21c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=38) AS 'f21d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=76) AS 'f21e'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=83) AS 'f21f'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=84) AS 'f21g'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=39) AS 'f22a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=40) AS 'f22b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=71) AS 'f22c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=41) AS 'f22d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=42) AS 'f22e'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=43) AS 'f22f'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=44) AS 'f22g'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=45) AS 'f22h'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=46) AS 'f23a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=47) AS 'f23b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=48) AS 'f23c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=49) AS 'f23d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=50) AS 'f23e'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=51) AS 'f23f'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=52) AS 'f24a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=53) AS 'f24b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=54) AS 'f24c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=55) AS 'f24d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=56) AS 'f24e'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=57) AS 'f24f'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=58) AS 'f25a'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=59) AS 'f25b'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=60) AS 'f25c'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=61) AS 'f25d'
, (SELECT min(trainingdate) FROM Training t INNER JOIN TrainingAttendee ta ON ta.TrainingFK=t.TrainingPK
	INNER JOIN TrainingDetail td ON td.TrainingFK=t.TrainingPK WHERE ta.WorkerFK=w.WorkerPK AND td.SubTopicFK=62) AS 'f25e'
FROM Worker w
INNER JOIN dbo.fnGetWorkerEventDates(@prgfk, @super, @worker) fn ON fn.workerpk = w.workerpk
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK
WHERE wp.TerminationDate IS null
)

SELECT [FirstName]
	 , [LastName]
	 , [WorkerPK]
	 , [FAWInitialStart]
	 , [SupervisorInitialStart]
	 , [FSWInitialStart]
	 , [TerminationDate]
	 , [HireDate]
	 , [FirstASQDate]
	 , [FirstHomeVisitDate]
	 , [FirstKempeDate]
	 , [FirstEvent]
	 , [f1]
	 , CASE isnull([f1], 0)
		WHEN [f1] THEN
			CASE WHEN datediff(dd, [f1], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f1_ast'
	 , [f2a]
	 , CASE isnull([f2a], 0)
		WHEN [f2a] THEN
			CASE WHEN datediff(dd, [f2a], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2a_ast'
	 , [f2b]
	 , CASE isnull([f2b], 0)
		WHEN [f2b] THEN
			CASE WHEN datediff(dd, [f2b], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2b_ast'
	 , [f2c]
	 , CASE isnull([f2c], 0)
		WHEN [f2c] THEN
			CASE WHEN datediff(dd, [f2c], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f2c_ast'
	 , [f3]
	 , CASE isnull([f3], 0)
		WHEN [f3] THEN
			CASE WHEN datediff(dd, [f3], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f3_ast'
	 , [f4]
	 , CASE isnull([f4], 0)
		WHEN [f4] THEN
			CASE WHEN datediff(dd, [f4], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f4_ast'
	 , [f5]
	 , CASE isnull([f5], 0)
		WHEN [f5] THEN
			CASE WHEN datediff(dd, [f5], [FirstEvent]) < 0 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f5_ast'
	 , [f6]
	 , CASE isnull([f6], 0)
		WHEN [f6] THEN
			CASE WHEN datediff(dd, [f6], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f6_ast'
	 , [f7]
	 , CASE isnull([f7], 0)
		WHEN [f7] THEN
			CASE WHEN datediff(dd, [f7], [HireDate]) < -91 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f7_ast'
	 , [f8]
	 , CASE isnull(FSWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 8.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f8], [FirstHomeVisitDate]) < 0 THEN '*' END
		END AS 'f8_ast' 
	 , [f9]
	 , CASE isnull(FAWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f9], [FirstKempeDate]) < 0 THEN '*' END
		END AS 'f9_ast' 
	 , [f9.1]
	 , CASE isnull(SupervisorInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.1 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f9.1], [SupervisorFirstEvent]) < 0 THEN '*' END
		END AS 'f91_ast' 
	 , [f10a]
	 , CASE isnull(FAWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.0 is only for FAW's
		ELSE 
			CASE WHEN datediff(dd, [f10a], [FAWInitialStart]) < -183 THEN '*' END
		END AS 'f10a_ast'
	 , [f11]
	 , CASE isnull(FSWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 9.0 is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f11], [FSWInitialStart]) < -183 THEN '*' END
		END AS 'f11a_ast'
	 , [f12]
	 , CASE isnull(SupervisorInitialStart,0)
		WHEN 0 THEN '' --do nothing as 12 is only for Supervisors
		ELSE 
			CASE WHEN datediff(dd, [f12], [SupervisorInitialStart]) < -183 THEN '*' END
		END AS 'f12_ast'
	 , [f13]
	 , CASE isnull(FSWInitialStart,0)
		WHEN 0 THEN '' --do nothing as 13 ASQ is only for FSW's
		ELSE 
			CASE WHEN datediff(dd, [f13], [firstasqdate]) < 0 THEN '*' END
		END AS 'f13_ast'
	 , [f14a]
	 , CASE isnull([f14a], 0)
		WHEN [f14a] THEN
			CASE WHEN datediff(dd, [f14a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14a_ast'
	 , [f14b]
	 , CASE isnull([f14b], 0)
		WHEN [f14b] THEN
			CASE WHEN datediff(dd, [f14b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14b_ast'
	 , [f14c]
	 , CASE isnull([f14c], 0)
		WHEN [f14c] THEN
			CASE WHEN datediff(dd, [f14c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14c_ast'
	 , [f14d]
	 , CASE isnull([f14d], 0)
		WHEN [f14d] THEN
			CASE WHEN datediff(dd, [f14d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f14d_ast'
	 , [f15a]
	 , CASE isnull([f15a], 0)
		WHEN [f15a] THEN
			CASE WHEN datediff(dd, [f15a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15a_ast'
	 , [f15b]
	 , CASE isnull([f15b], 0)
		WHEN [f15b] THEN
			CASE WHEN datediff(dd, [f15b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15b_ast'
	 , [f15c]
	 , CASE isnull([f15c], 0)
		WHEN [f15c] THEN
			CASE WHEN datediff(dd, [f15c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15ac_ast'
	 , [f15d]
	 , CASE isnull([f15d], 0)
		WHEN [f15d] THEN
			CASE WHEN datediff(dd, [f15d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15d_ast'
	 , [f15e]
	 , CASE isnull([f15e], 0)
		WHEN [f15e] THEN
			CASE WHEN datediff(dd, [f15e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15e_ast'
	 , [f15f]
	 , CASE isnull([f15f], 0)
		WHEN [f15f] THEN
			CASE WHEN datediff(dd, [f15f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15f_ast'
	 , [f15g]
	 , CASE isnull([f15g], 0)
		WHEN [f15g] THEN
			CASE WHEN datediff(dd, [f15g], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15g_ast'
	 , [f15h]
	 , CASE isnull([f15h], 0)
		WHEN [f15h] THEN
			CASE WHEN datediff(dd, [f15h], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15h_ast'
	 , [f15i]
	 , CASE isnull([f15i], 0)
		WHEN [f15i] THEN
			CASE WHEN datediff(dd, [f15i], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f15i_ast'
	 , [f16a]
	 , CASE isnull([f16a], 0)
		WHEN [f16a] THEN
			CASE WHEN datediff(dd, [f16a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16a_ast'
	 , [f16b]
	 , CASE isnull([f16b], 0)
		WHEN [f16b] THEN
			CASE WHEN datediff(dd, [f16b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16b_ast'
	 , [f16c]
	 , CASE isnull([f16c], 0)
		WHEN [f16c] THEN
			CASE WHEN datediff(dd, [f16c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16c_ast'
	 , [f16d]
	 , CASE isnull([f16d], 0)
		WHEN [f16d] THEN
			CASE WHEN datediff(dd, [f16d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16d_ast'
	 , [f16e]
	 , CASE isnull([f16e], 0)
		WHEN [f16e] THEN
			CASE WHEN datediff(dd, [f16e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16e_ast'
	 , [f16f]
	 , CASE isnull([f16f], 0)
		WHEN [f16f] THEN
			CASE WHEN datediff(dd, [f16f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f16f'
	 , [f17a]
	 , CASE isnull([f17a], 0)
		WHEN [f17a] THEN
			CASE WHEN datediff(dd, [f17a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17a_ast'
	 , [f17b]
	 , CASE isnull([f17b], 0)
		WHEN [f17b] THEN
			CASE WHEN datediff(dd, [f17b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17b_ast'
	 , [f17c]
	 , CASE isnull([f17c], 0)
		WHEN [f17c] THEN
			CASE WHEN datediff(dd, [f17c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17c_ast'
	 , [f17e] --there's no 'd' in this report
	 , CASE isnull([f17e], 0)
		WHEN [f17e] THEN
			CASE WHEN datediff(dd, [f17e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f17e_ast'
	 , [f18a]
	 , CASE isnull([f18a], 0)
		WHEN [f18a] THEN
			CASE WHEN datediff(dd, [f18a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18a_ast'
	 , [f18b]
	 , CASE isnull([f18b], 0)
		WHEN [f18b] THEN
			CASE WHEN datediff(dd, [f18b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18b_ast'
	 , [f18c]
	 , CASE isnull([f18c], 0)
		WHEN [f18c] THEN
			CASE WHEN datediff(dd, [f18c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f18c_ast'
	 , [f19a]
	 , CASE isnull([f19a], 0)
		WHEN [f19a] THEN
			CASE WHEN datediff(dd, [f19a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19a_ast'
	 , [f19b]
	 , CASE isnull([f19b], 0)
		WHEN [f19b] THEN
			CASE WHEN datediff(dd, [f19b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19b_ast'
	 , [f19c]
	 , CASE isnull([f19c], 0)
		WHEN [f19c] THEN
			CASE WHEN datediff(dd, [f19c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19c_ast'
	 , [f19d]
	 , CASE isnull([f19d], 0)
		WHEN [f19d] THEN
			CASE WHEN datediff(dd, [f19d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19d_ast'
	 , [f19e]
	 , CASE isnull([f19e], 0)
		WHEN [f19e] THEN
			CASE WHEN datediff(dd, [f19e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19e_ast'
	 , [f19f]
	 , CASE isnull([f19f], 0)
		WHEN [f19f] THEN
			CASE WHEN datediff(dd, [f19f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f19f_ast'
	 , [f20a]
	 , CASE isnull([f20a], 0)
		WHEN [f20a] THEN
			CASE WHEN datediff(dd, [f20a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f20a_ast'
	 , [f20b]
	 , CASE isnull([f20b], 0)
		WHEN [f20b] THEN
			CASE WHEN datediff(dd, [f20b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f20b_ast'
	 , [f21a]
	 , CASE isnull([f21a], 0)
		WHEN [f21a] THEN
			CASE WHEN datediff(dd, [f21a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21a_ast'
	 , [f21b]
	 , CASE isnull([f21b], 0)
		WHEN [f21b] THEN
			CASE WHEN datediff(dd, [f21b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21b_ast'
	 , [f21c]
	 , CASE isnull([f21c], 0)
		WHEN [f21c] THEN
			CASE WHEN datediff(dd, [f21c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21c_ast'
	 , [f21d]
	 , CASE isnull([f21d], 0)
		WHEN [f21d] THEN
			CASE WHEN datediff(dd, [f21d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21d_ast'
	 , [f21e]
	 , CASE isnull([f21e], 0)
		WHEN [f21e] THEN
			CASE WHEN datediff(dd, [f21e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21e_ast'
	 , [f21f]
	 , CASE isnull([f21f], 0)
		WHEN [f21f] THEN
			CASE WHEN datediff(dd, [f21f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21f_ast'
	 , [f21g]
	 , CASE isnull([f21g], 0)
		WHEN [f21g] THEN
			CASE WHEN datediff(dd, [f21g], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f21g_ast'
	 , [f22a]
	 , CASE isnull([f22a], 0)
		WHEN [f22a] THEN
			CASE WHEN datediff(dd, [f22a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22a_ast'
	 , [f22b]
	 , CASE isnull([f22b], 0)
		WHEN [f22b] THEN
			CASE WHEN datediff(dd, [f22b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22b_ast'
	 , [f22c]
	 , CASE isnull([f22c], 0)
		WHEN [f22c] THEN
			CASE WHEN datediff(dd, [f22c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22c_ast'
	 , [f22d]
	 , CASE isnull([f22d], 0)
		WHEN [f22d] THEN
			CASE WHEN datediff(dd, [f22d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22d_ast'
	 , [f22e]
	 , CASE isnull([f22e], 0)
		WHEN [f22e] THEN
			CASE WHEN datediff(dd, [f22e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22e_ast'
	 , [f22f]
	 , CASE isnull([f22f], 0)
		WHEN [f22f] THEN
			CASE WHEN datediff(dd, [f22f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22f_ast'
	 , [f22g]
	 , CASE isnull([f22g], 0)
		WHEN [f22g] THEN
			CASE WHEN datediff(dd, [f22g], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22g_ast'
	 , [f22h]
	 , CASE isnull([f22h], 0)
		WHEN [f22h] THEN
			CASE WHEN datediff(dd, [f22h], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f22h_ast'
	 , [f23a]
	 , CASE isnull([f23a], 0)
		WHEN [f23a] THEN
			CASE WHEN datediff(dd, [f23a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23a_ast'
	 , [f23b]
	 , CASE isnull([f23b], 0)
		WHEN [f23b] THEN
			CASE WHEN datediff(dd, [f23b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23b_ast'
	 , [f23c]
	 , CASE isnull([f23c], 0)
		WHEN [f23c] THEN
			CASE WHEN datediff(dd, [f23c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23c_ast'
	 , [f23d]
	 , CASE isnull([f23d], 0)
		WHEN [f23d] THEN
			CASE WHEN datediff(dd, [f23d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23d_ast'
	 , [f23e]
	 , CASE isnull([f23e], 0)
		WHEN [f23e] THEN
			CASE WHEN datediff(dd, [f23e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23e_ast'
	 , [f23f]
	 , CASE isnull([f23f], 0)
		WHEN [f23f] THEN
			CASE WHEN datediff(dd, [f23f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f23f_ast'
	 , [f24a]
	 , CASE isnull([f24a], 0)
		WHEN [f24a] THEN
			CASE WHEN datediff(dd, [f24a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24a_ast'
	 , [f24b]
	 , CASE isnull([f24b], 0)
		WHEN [f24b] THEN
			CASE WHEN datediff(dd, [f24b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24b_ast'
	 , [f24c]
	 , CASE isnull([f24c], 0)
		WHEN [f24c] THEN
			CASE WHEN datediff(dd, [f24c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24c_ast'
	 , [f24d]
	 , CASE isnull([f24d], 0)
		WHEN [f24d] THEN
			CASE WHEN datediff(dd, [f24d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24d_ast'
	 , [f24e]
	 , CASE isnull([f24e], 0)
		WHEN [f24e] THEN
			CASE WHEN datediff(dd, [f24e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24e_ast'
	 , [f24f]
	 , CASE isnull([f24f], 0)
		WHEN [f24f] THEN
			CASE WHEN datediff(dd, [f24f], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f24f_ast'
	 , [f25a]
	 , CASE isnull([f25a], 0)
		WHEN [f25a] THEN
			CASE WHEN datediff(dd, [f25a], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25a_ast'
	 , [f25b]
	 , CASE isnull([f25b], 0)
		WHEN [f25b] THEN
			CASE WHEN datediff(dd, [f25b], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25b_ast'
	 , [f25c]
	 , CASE isnull([f25c], 0)
		WHEN [f25c] THEN
			CASE WHEN datediff(dd, [f25c], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25c_ast'
	 , [f25d]
	 , CASE isnull([f25d], 0)
		WHEN [f25d] THEN
			CASE WHEN datediff(dd, [f25d], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25d_ast'
	 , [f25e] 
	 , CASE isnull([f25e], 0)
		WHEN [f25e] THEN
			CASE WHEN datediff(dd, [f25e], [HireDate]) < -183 THEN '*' 
			ELSE '' END
		ELSE '' END AS 'f25e_ast'
FROM ctMain ORDER BY FirstName, LastName
END
GO
