SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 09/04/2019
-- Description:	12-3B Supervision of Supervisors Report
-- =============================================

CREATE procedure [dbo].[rspSupervisionOfSupervisors]
(
    @programfk varchar(max)    = null,
    @StartDt   datetime,
    @EndDt     datetime
)
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	

DECLARE @supCohort AS TABLE (
	SupervisionPK int
      ,Caseload BIT
      ,CaseloadStatus BIT    
      ,ProgramFK INT
      ,SupervisionDate DATE  
      ,SupervisionStartTime TIME
      ,SupervisionEndTime DATETIME
      ,SupervisionHours INT
      ,SupervisionMinutes INT  
      ,SupervisorFK INT    
      ,WorkerFK INT
	  )

INSERT INTO @supCohort ( SupervisionPK ,
                         Caseload ,
                         CaseloadStatus ,
                         ProgramFK ,
                         SupervisionDate ,
                         SupervisionStartTime ,
                         SupervisionEndTime ,
                         SupervisionHours ,
                         SupervisionMinutes ,
                         SupervisorFK ,
                         WorkerFK )
	SELECT [SupervisionPK]
      ,[Caseload]
      ,[CaseloadStatus]    
      ,[Supervision].[ProgramFK]
      ,[SupervisionDate] 
      ,[SupervisionStartTime]
      ,[SupervisionEndTime]
      ,[SupervisionHours]
      ,[SupervisionMinutes]     
      ,[Supervision].[SupervisorFK]  
      ,[Supervision].[WorkerFK] 
  FROM [Supervision]
  INNER JOIN dbo.SplitString(@programfk,',') on programfk = listitem
  INNER JOIN dbo.WorkerProgram wp ON wp.ProgramFK = Supervision.ProgramFK AND wp.WorkerFK = Supervision.WorkerFK
  WHERE SupervisionDate BETWEEN @StartDt AND @EndDt
  AND (SupervisionHours IS NOT NULL OR SupervisionMinutes IS NOT NULL)
  AND wp.SupervisorStartDate < @EndDt

  --This report is organized by month, so determine only the months in the report
	UPDATE @supCohort SET SupervisionDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, SupervisionDate), 0)

 DECLARE @tblWorkerGroup AS TABLE (
	  programfk INT
	, workerfk INT
	, supervisionmonth DATE
	, SupervisorFK INT  --workers supervisior
	, Caseload VARCHAR(3) --yes/no
	, NumberSupervisions INT
	, LengthSupervisions INT --total minutes per month

 )

 INSERT INTO @tblWorkerGroup ( programfk ,
                               workerfk ,
                               supervisionmonth 
                              )
  SELECT ProgramFK, workerfk, SupervisionDate
  FROM @supCohort
  GROUP BY ProgramFK, SupervisionDate, workerfk
  
  --get the workers supervisor into the output table
  UPDATE @tblWorkerGroup SET SupervisorFK = c.SupervisorFK
   FROM @tblWorkerGroup
   INNER JOIN @supCohort c ON c.WorkerFK = [@tblWorkerGroup].workerfk AND c.SupervisionDate=supervisionmonth


  --get the workers caseload for the month
  UPDATE @tblWorkerGroup SET Caseload= c.Caseload
   FROM @tblWorkerGroup
   INNER JOIN @supCohort c ON c.WorkerFK = [@tblWorkerGroup].workerfk AND c.SupervisionDate=supervisionmonth

 
  DECLARE @tblAlmostFinal AS TABLE(
          workerfk INT
		, SupervisionMonth DATE
		, SupCount INT
		, TimeInHours INT
		, TimeInMinutes INT
		, workercasecount INT
  )
  INSERT INTO @tblAlmostFinal ( workerfk ,
                                SupervisionMonth ,
                                SupCount ,
								TimeInHours,
                                TimeInMinutes )
  SELECT s.workerfk, s.SupervisionDate, COUNT(SupervisionPK)  AS SupCount
  , SUM(s.SupervisionHours * 60) AS TimeInHours
  , SUM(s.SupervisionMinutes) AS TimeInMinutes
  FROM @supCohort s
  INNER JOIN @tblWorkerGroup ON [@tblWorkerGroup].workerfk = s.WorkerFK AND [@tblWorkerGroup].programfk = s.ProgramFK
  AND [@tblWorkerGroup].supervisionmonth = s.SupervisionDate
  WHERE SupervisionDate=supervisionmonth AND s.WorkerFK= s.workerfk
  GROUP BY s.WorkerFK, s.SupervisionDate

  UPDATE @tblAlmostFinal SET TimeInMinutes = (ISNULL(TimeInHours, 0) + ISNULL(TimeInMinutes, 0))

	DECLARE @tblCaseCount AS TABLE (
		casecount INT
		, workerfk INT
		, supervisionmonth DATE
	)
	INSERT INTO	@tblCaseCount ( casecount ,
	                            workerfk ,
	                            supervisionmonth )
	  SELECT COUNT(wad.hvcasefk) AS casecount , twg.workerfk, twg.supervisionmonth
	  FROM dbo.WorkerAssignmentDetail wad
	  INNER JOIN @tblWorkerGroup twg ON twg.programfk = wad.ProgramFK AND twg.workerfk = wad.WorkerFK
	  INNER JOIN dbo.CaseProgram ON CaseProgram.HVCaseFK = wad.HVCaseFK
	  WHERE twg.supervisionmonth BETWEEN wad.StartAssignmentDate AND ISNULL(wad.EndAssignmentDate, @EndDt)
	  GROUP BY  twg.workerfk, twg.supervisionmonth


	  --find the case during the month that had the highest case weight (e.g. lowest level)  
	DECLARE @tblCaseWeight AS TABLE (
		CaseLevel VARCHAR(15)
		, workerfk INT
		, supervisionmonth DATE
	)

	INSERT INTO	@tblCaseWeight ( CaseLevel ,
	                            workerfk ,
	                            supervisionmonth )
	SELECT LevelName, workerfk, supervisionmonth
	FROM (
			  SELECT 'Level ' + cl.LevelAbbr AS LevelName , twg.workerfk, twg.supervisionmonth, MAX(cl.CaseWeight) AS CaseWeight
			  , ROW_NUMBER() OVER (PARTITION BY twg.workerfk, twg.supervisionmonth ORDER BY cl.CaseWeight DESC) AS workerrow
                                    
			  FROM dbo.WorkerAssignmentDetail wad
			  INNER JOIN @tblWorkerGroup twg ON twg.programfk = wad.ProgramFK AND twg.workerfk = wad.WorkerFK
			  INNER JOIN dbo.CaseProgram ON CaseProgram.HVCaseFK = wad.HVCaseFK
			  INNER JOIN dbo.HVLevelDetail hvd ON hvd.HVCaseFK = CaseProgram.HVCaseFK AND twg.supervisionmonth BETWEEN hvd.StartLevelDate AND ISNULL(hvd.EndLevelDate, @EndDt)
			  INNER JOIN dbo.codeLevel cl ON cl.codeLevelPK = hvd.LevelFK
			  WHERE twg.supervisionmonth BETWEEN wad.StartAssignmentDate AND ISNULL(wad.EndAssignmentDate, @EndDt)
			  GROUP BY twg.workerfk, cl.LevelAbbr ,  twg.supervisionmonth, cl.CaseWeight
			) y
	WHERE y.workerrow = 1
	 
	  -------End Find Highest Case Weight ------------------------------------------

UPDATE @tblAlmostFinal SET workercasecount = tcc.casecount
FROM @tblAlmostFinal
INNER JOIN @tblCaseCount tcc ON tcc.supervisionmonth = [@tblAlmostFinal].SupervisionMonth AND tcc.workerfk = [@tblAlmostFinal].workerfk


SELECT a.workerfk, RTRIM(w1.FirstName) + ' ' + RTRIM(w1.LastName) AS Worker
	, a.SupervisionMonth
	,  SupCount , TimeInMinutes
   , w.SupervisorFK , RTRIM(w2.FirstName) + ' ' + RTRIM(w2.LastName) AS Supervisor
   , Caseload , w.programfk, a.workercasecount, CaseLevel AS MaxLevelName
FROM @tblAlmostFinal a
INNER JOIN @tblWorkerGroup w ON w.workerfk = a.workerfk AND w.supervisionmonth = a.SupervisionMonth
INNER JOIN dbo.Worker w1 ON w1.WorkerPK = w.workerfk
INNER JOIN dbo.Worker w2 ON w2.WorkerPK = w.SupervisorFK
LEFT JOIN @tblCaseWeight ON [@tblCaseWeight].supervisionmonth = a.SupervisionMonth AND [@tblCaseWeight].workerfk = a.workerfk
ORDER BY programfk, SupervisionMonth, workerfk


end
GO
