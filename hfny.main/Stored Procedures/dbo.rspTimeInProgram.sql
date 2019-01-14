SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Chris Papas>
-- Create date: <Jan 23, 2018>
-- Description:	<simple list that show ALL clients (active/closed) in a program that had an intake in time period>
-- =============================================
CREATE procedure [dbo].[rspTimeInProgram]
(
    @programfk varchar(max)    = NULL,
	@startdt AS DATE = NULL,
	@enddt AS date = NULL
)
as

  if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')

	DECLARE @clientlist TABLE(
		hvcasefk INT,
		pc1id VARCHAR(13),
		IntakeDate DATE,
		DischargeDate DATE,
		lengthinprogram VARCHAR(MAX),
		Active VARCHAR(3),
		FSW VARCHAR(50),
		ProgSite INT,
		WorkerName VARCHAR(30),
		CurrentLevel VARCHAR(25)
	)


	INSERT INTO	@clientlist (   hvcasefk,
									   pc1id ,
	                                   lengthinprogram,
									   IntakeDate,
									   DischargeDate,
									   Active,
									   FSW,
									   ProgSite,
									   WorkerName,
									   CurrentLevel					                                   
	                               )
	SELECT 		h.HVCasePK
	, cp.PC1ID
	, dbo.CalcAge( h.IntakeDate, ISNULL(cp.DischargeDate, GETDATE()))
	, h.IntakeDate
	, cp.DischargeDate
	, CASE WHEN cp.DischargeDate IS NULL THEN 'Yes' ELSE 'No' END	
	, cp.CurrentFSWFK
	, workerprogram.SiteFK
	, RTRIM(worker.FirstName) + ' ' + RTRIM(worker.LastName)
	, codelevel.LevelName
	FROM HVCase h
		inner join CaseProgram cp on cp.hvcasefk = h.hvcasePk	
		inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
		INNER JOIN worker ON Worker.WorkerPK = cp.CurrentFSWFK
		INNER JOIN dbo.WorkerProgram ON workerprogram.WorkerFK = worker.WorkerPK AND WorkerProgram.ProgramFK = cp.ProgramFK
		INNER JOIN dbo.codeLevel ON cp.CurrentLevelFK = codeLevelPK
	where
	(h.CaseProgress >= 10.0)  
	AND h.IntakeDate BETWEEN @startdt AND @enddt
	 


	SELECT hvcasefk,pc1id, IntakeDate, DischargeDate, lengthinprogram, Active, fsw,ProgSite, SiteName, WorkerName, CurrentLevel
	, ROW_NUMBER() OVER(ORDER BY hvcasefk) AS 'RowNumber'
	FROM @clientlist
	LEFT JOIN listsite ON ProgSite=listSitePK
	ORDER BY DATEDIFF(dd, IntakeDate, ISNULL(DischargeDate, GETDATE())) DESC
GO
