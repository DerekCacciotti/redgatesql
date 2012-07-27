
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Jyly 16th, 2012>
-- Description:	<gets you data for Pre-Intake Engagement in Detail>
-- exec [rspPreIntakeEngagementDetails] ',1,','09/01/2010','11/30/2010',null,0
-- exec [rspPreIntakeEngagementDetails] ',1,','09/01/2010','11/30/2010',null,1

-- =============================================
CREATE procedure [dbo].[rspPreIntakeEngagementDetails](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,                                                        
                                                        @sitefk int             = NULL,
                                                        @CustomQuarterlyDates bit                                                         
                                                        )

as
BEGIN

	-- if user picks up custom dates ( not specific quarter dates) then Don't show ContractPeriod Column
	--DECLARE @bDontShowContractPeriod BIT
	-- we will be receiving the value of @bDontShowContractPeriod from UI. 
	-- so time being, let us do the following
	--SET @bDontShowContractPeriod = 0



    declare @ContractStartDate DATE
    declare @ContractEndDate DATE

    if ((@ProgramFK IS not NULL) AND (@CustomQuarterlyDates = 0))
    BEGIN 
		set @ProgramFK = REPLACE(@ProgramFK,',','') -- remove comma's
		set @ContractStartDate = (select ContractStartDate FROM HVProgram P where HVProgramPK=@ProgramFK)
		set @ContractEndDate = (select ContractEndDate FROM HVProgram P where HVProgramPK=@ProgramFK)
	END 

--SELECT @ContractStartDate, @ContractEndDate

-- Let us declare few table variables so that we can manipulate the rows at our will
-- Note: Table variables are a superior alternative to using temporary tables 

---------------------------------------------
-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- table variable for holding Init Required Data
DECLARE @tblInitRequiredData TABLE(
	[HVCasePK] [int],	
	[IntakeDate] [datetime],
	[DischargeDate] [datetime],
	[KempeDate] [datetime],
	[KempeResult] [BIT],
	[CaseStartDate] [datetime],	
	[SiteFK] [int],
	[PC1ID] [char](13),
	[OldID] [char](23),
	[FSWWorkerName] [char](100)


)


DECLARE @tblInitRequiredDataTemp TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[DischargeDate] [datetime],
	[KempeDate] [datetime],
	[KempeResult] [BIT],
	[CaseStartDate] [datetime],	
	[SiteFK] [int],
	[PC1ID] [char](13),
	[OldID] [char](23),
	[FSWWorkerName] [char](100)

)

-- Fill this table i.e. @tblInitRequiredData as below
INSERT INTO @tblInitRequiredDataTemp(
	[HVCasePK],
	[IntakeDate],
	[DischargeDate],
	[KempeDate],
	[KempeResult],
	[CaseStartDate],	
	[SiteFK],
	[PC1ID],
	[OldID],
	[FSWWorkerName]	
)
SELECT 
h.HVCasePK,h.IntakeDate,cp.DischargeDate,k.KempeDate,k.KempeResult,cp.CaseStartDate
,CASE WHEN wp.SiteFK IS NULL THEN 0 ELSE wp.SiteFK END AS SiteFK,
cp.PC1ID,cp.OldID, LTRIM(rtrim(w.FirstName)) + ' ' + LTRIM(rtrim(w.LastName)) AS FSWWorkerName  
FROM HVCase h 
INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem

-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
-- so to solve this problem we make use of @tblInitRequiredDataTemp
INSERT INTO @tblInitRequiredData( 
	[HVCasePK],
	[IntakeDate],
	[DischargeDate],
	[KempeDate],
	[KempeResult],
	[CaseStartDate],	
	[PC1ID],
	[OldID],
	[FSWWorkerName]		
	)
SELECT 
	[HVCasePK],
	[IntakeDate],
	[DischargeDate],
	[KempeDate],
	[KempeResult],
	[CaseStartDate],		
	[PC1ID],
	[OldID],
	[FSWWorkerName]	

 FROM @tblInitRequiredDataTemp
WHERE SiteFK = isnull(@sitefk,SiteFK)

-- exec [rspPreIntakeEngagementDetails] ',1,','09/01/2010','11/30/2010',null,0



DECLARE @tblEngageAll TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[DischargeDate] [datetime],
	[KempeDate] [datetime],
	[KempeResult] [BIT],
	[CaseStartDate] [datetime],		
	[FSWAssignDate] [datetime],
	[PC1ID] [char](13),
	[OldID] [char](23),
	[FSWWorkerName] [char](100),	
	[CaseStatus] [char](2)


)

INSERT INTO @tblEngageAll
(
	[HVCasePK],
	[IntakeDate],
	[DischargeDate],
	[KempeDate],
	[KempeResult],
	[CaseStartDate],		
	[FSWAssignDate],
	[PC1ID],
	[OldID],
	[FSWWorkerName],	
	[CaseStatus]
)
(

		--Pre-Intakes
		SELECT 
			irq.[HVCasePK],
			irq.[IntakeDate],
			irq.[DischargeDate],
			irq.[KempeDate],
			irq.[KempeResult],
			irq.[CaseStartDate],			
			p.[FSWAssignDate],
			irq.[PC1ID],
			irq.[OldID],
			irq.[FSWWorkerName],
			p.[CaseStatus]				

		FROM @tblInitRequiredData irq
		INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK 
		WHERE 
		CaseStartDate <= @edate
		AND p.FSWAssignDate < @sDate 
		AND p.CaseStatus = '02'
		AND irq.KempeResult = '1'
		AND (IntakeDate IS NULL OR IntakeDate > @sDate)
		AND (DischargeDate IS NULL OR DischargeDate > @sDate)	

UNION ALL

		-- kempes
		SELECT 
			irq.[HVCasePK],
			irq.[IntakeDate],
			irq.[DischargeDate],
			irq.[KempeDate],
			irq.[KempeResult],
			irq.[CaseStartDate],			
			p.[FSWAssignDate],
			irq.[PC1ID],
			irq.[OldID],
			irq.[FSWWorkerName],	
			p.[CaseStatus]						

		FROM @tblInitRequiredData irq	
		INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
		LEFT JOIN Kempe k ON k.HVCaseFK = irq.HVCasePK		
		WHERE 
		irq.KempeDate BETWEEN @sDate AND @edate
		AND p.CaseStatus = '02'
		AND k.KempeResult = 1 
		AND p.FSWAssignDate BETWEEN @sDate AND @edate

UNION ALL

		--Previous Kempes
		SELECT 
			irq.[HVCasePK],
			irq.[IntakeDate],
			irq.[DischargeDate],
			irq.[KempeDate],
			irq.[KempeResult],
			irq.[CaseStartDate],			
			p.[FSWAssignDate],
			irq.[PC1ID],
			irq.[OldID],
			irq.[FSWWorkerName],	
			p.[CaseStatus]									

		FROM @tblInitRequiredData irq
		INNER JOIN Preassessment p ON irq.HVCasePK = p.HVCaseFK
		WHERE 
		(irq.KempeDate < @sDate AND irq.KempeDate IS NOT NULL)
		AND	(p.FSWAssignDate IS NOT NULL AND p.FSWAssignDate >= @sDate)	

)

DECLARE @tblLastPa TABLE(
	[HVCasePK] [int],
	[PIDate] [datetime]	
)

INSERT INTO @tblLastPa
(
	[HVCasePK],
	[PIDate]
)
(
SELECT  p.HVCaseFK, max(p.PIDate)  FROM @tblEngageAll e
LEFT JOIN Preintake p ON e.HVCasePK = p.HVCaseFK 
--WHERE PIDate BETWEEN @sDate AND @edate
GROUP BY p.HVCaseFK 
)

SELECT * FROM @tblLastPa

SELECT 
	ea.[PC1ID],
	ea.[FSWAssignDate],	

	CASE WHEN pre.[CaseStatus] IN ('02','03') THEN 
	datediff(day,ea.[FSWAssignDate], lp.PIDate)
	ELSE 
	datediff(day,ea.[FSWAssignDate],@edate)
	END PreIntakeDays,	
	ea.[FSWWorkerName],
	lp.PIDate, 

	Status =
		CASE pre.[CaseStatus]
			WHEN '01' THEN 'Engagement Continues'
			WHEN '02' THEN 'Enrolled'
			WHEN '03' THEN 'Terminated'
			ELSE ''
		END	

	,pre.[CaseStatus],	



	ea.[HVCasePK],
	ea.[OldID]	

 FROM @tblEngageAll ea
 INNER JOIN @tblLastPa lp ON lp.HVCasePK = ea.HVCasePK
 LEFT JOIN Preintake pre ON ea.HVCasePK = pre.HVCaseFK 
 WHERE lp.PIDate = pre.PIDate 
 ORDER BY [FSWWorkerName],[HVCasePK]

-- exec [rspPreIntakeEngagementDetails] ',1,','09/01/2010','11/30/2010',null,0



END
GO
