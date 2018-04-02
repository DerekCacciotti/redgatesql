SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Chris Papas>
-- Create date: <Jan 9, 2018>
-- Description:	<for peer review team during accredidation.  This fills in the 'Participant Roster' list for sites>
-- =============================================
CREATE procedure [dbo].[rspParticipantRoster]
(
    @programfk varchar(max)    = NULL
)
as

  if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')

	
	DECLARE @participantroster TABLE(
		hvcasefk INT,
		tcidpk INT,
		pc1id VARCHAR(13),
		tcdob DATE,
		codelevelpk INT,
		levelname VARCHAR(MAX),
		lengthinprogram VARCHAR(MAX),
		DevelopmentalDelay VARCHAR(MAX),
		CurrentWorkerfk INT,
		CurrentWorker VARCHAR(200),
		supervisorfk INT,
		supervisor VARCHAR(200),
		cpsreport VARCHAR(3)
	)

		DECLARE @asqdelays TABLE(
		hvcasefk INT,
		tcidpk INT,
		asqpk INT,
		asqmonth VARCHAR(2),
		asqver VARCHAR(6)
	)

	
		DECLARE @CPSReportPastYear TABLE(
		hvcasefk INT,
		followuppk INT
	)

	INSERT INTO	@participantroster (   hvcasefk,
									   tcidpk,
									   pc1id ,
	                                   tcdob ,
	                                   codelevelpk ,
	                                   levelname ,
	                                   lengthinprogram ,
	                                   DevelopmentalDelay ,
	                                   CurrentWorkerfk ,
	                                   CurrentWorker ,
	                                   supervisorfk ,
	                                   supervisor
	                               )
	SELECT 		h.HVCasePK
	, MAX(T.TCIDPK)
	, cp.PC1ID
	, ISNULL(h.tcdob,h.EDC)
	, cp.CurrentLevelFK
	, clv.LevelName
	, dbo.CalcAge( h.IntakeDate, GETDATE())
	, NULL --we'll get the ASQ later for developmental delays
	, cp.CurrentFSWFK
	, RTRIM(fsw.FirstName) + ' ' + RTRIM(fsw.LastName)
	, wp.SupervisorFK
	, RTRIM(supervisor.FirstName) + ' ' + RTRIM(supervisor.LastName)
	
	FROM HVCase h
		inner join CaseProgram cp on cp.hvcasefk = h.hvcasePk	
		inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
		inner join dbo.codeLevel clv ON cp.CurrentLevelFK = clv.codeLevelPK
		left join worker fsw on cp.CurrentFSWFK = fsw.workerpk
		INNER JOIN workerprogram wp ON wp.workerfk = fsw.workerpk AND wp.ProgramFK = ListItem
		left JOIN worker supervisor ON wp.supervisorfk = supervisor.workerpk
		left join TCID T on T.HVCaseFK = h.HVCasePK 	
	
	where
	(h.CaseProgress >= 10.0)  
	AND (cp.DischargeDate IS null)  --- case not closed. 
	GROUP BY h.HVCasePK, cp.PC1ID, h.tcdob, edc, cp.CurrentLevelFK, clv.LevelName
	, h.IntakeDate, cp.CurrentFSWFK, fsw.FirstName, fsw.LastName, wp.SupervisorFK, supervisor.FirstName, supervisor.LastName


	INSERT INTO	@asqdelays (   hvcasefk ,
	                           tcidpk ,
	                           asqpk ,
	                           asqmonth ,
	                           asqver
	                       )
	SELECT asq.hvcasefk,
	tcidfk,
	asqpk,
	asq.TCAge,
	'ASQ'
	FROM ASQ
	INNER JOIN @participantroster ON [@participantroster].hvcasefk = ASQ.HVCaseFK
	WHERE ([UnderCommunication] = 1 OR [UnderFineMotor] = 1 OR [UnderGrossMotor] = 1
     OR [UnderPersonalSocial] = 1 OR [UnderProblemSolving] = 1)


	--INSERT INTO	@asqdelays (   hvcasefk ,
	--                           tcidpk ,
	--                           asqpk ,
	--                           asqmonth ,
	--                           asqver
	--                       )
	--SELECT asqse.hvcasefk,
	--tcidfk,
	--asqsepk,
	--asqse.ASQSETCAge,
	--'ASQ-SE'
	--FROM ASQSE
	--INNER JOIN @participantroster ON [@participantroster].hvcasefk = ASQSE.HVCaseFK
	--WHERE asqse.ASQSEOverCutOff = 1

	UPDATE PR 
	SET DevelopmentalDelay = delays.asqver + ' - ' + delays.asqmonth + ' month'
	FROM @participantroster AS PR INNER JOIN
		@asqdelays AS delays ON delays.hvcasefk = PR.hvcasefk AND delays.tcidpk = PR.tcidpk
	WHERE PR.hvcasefk = delays.hvcasefk	

	--get any cps reports in past year
	INSERT	INTO	@CPSReportPastYear (   hvcasefk ,
	                                   followuppk
	                               )
	SELECT hvcasefk, followuppk
	FROM dbo.FollowUp fu
	inner join dbo.SplitString(@programfk,',') on fu.ProgramFK = ListItem
	WHERE GETDATE() <= dateadd(dd, 365, fu.FollowUpDate)  --must have occurred in past year
	AND fu.CPSACSReport = 1
	
	UPDATE PR 
	SET PR.cpsreport = 'Yes'
	FROM @participantroster AS PR INNER JOIN
		@CPSReportPastYear AS cps ON cps.hvcasefk = PR.hvcasefk 
	WHERE PR.hvcasefk = cps.hvcasefk	

	SELECT *
	, ROW_NUMBER() OVER(ORDER BY hvcasefk) AS 'RowNumber'
	FROM @participantroster
GO
