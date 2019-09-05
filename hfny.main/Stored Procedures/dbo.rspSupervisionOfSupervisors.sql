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
		, TimeInMinutes INT
  )
  INSERT INTO @tblAlmostFinal ( workerfk ,
                                SupervisionMonth ,
                                SupCount ,
                                TimeInMinutes )
  SELECT s.workerfk, s.SupervisionDate, COUNT(SupervisionPK)  AS SupCount
  , SUM((s.SupervisionHours * 60) + s.SupervisionMinutes) AS TimeInMinutes
  FROM @supCohort s
  INNER JOIN @tblWorkerGroup ON [@tblWorkerGroup].workerfk = s.WorkerFK AND [@tblWorkerGroup].programfk = s.ProgramFK
  AND [@tblWorkerGroup].supervisionmonth = s.SupervisionDate
  WHERE SupervisionDate=supervisionmonth AND s.WorkerFK= s.workerfk
  GROUP BY s.WorkerFK, s.SupervisionDate


SELECT a.workerfk, RTRIM(w1.FirstName) + ' ' + RTRIM(w1.LastName) AS Worker
	,  CONVERT(CHAR(7),a.SupervisionMonth,120) AS SupervisionMonth
	,  SupCount , TimeInMinutes
   , w.SupervisorFK , RTRIM(w2.FirstName) + ' ' +  RTRIM(w2.LastName) AS Supervisor
   , Caseload , w.programfk
FROM @tblAlmostFinal a
INNER JOIN @tblWorkerGroup w ON w.workerfk = a.workerfk AND w.supervisionmonth = a.SupervisionMonth
INNER JOIN dbo.Worker w1 ON w1.WorkerPK = w.workerfk
INNER JOIN dbo.Worker w2 ON w2.WorkerPK = w.SupervisorFK
ORDER BY programfk, SupervisionMonth, workerfk


end
GO
