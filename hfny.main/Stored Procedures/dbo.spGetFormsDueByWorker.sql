SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/03/18
-- Description:	This stored procedure is used to retrieve all the forms
-- that a worker needs to enter in a certain time period.
--
-- NOTE:  This does NOT calculate if the forms have been completed,
-- just when the forms are due and if they are in the time period supplied.
-- added by derek c for dashboards 
-- =============================================
CREATE PROC [dbo].[spGetFormsDueByWorker]
(
	@WorkerFK INT,
	@ProgramFK INT,
	@StartDate DATETIME,
	@EndDate DATETIME
)

AS

-- TimeLine
DECLARE @timeline TABLE
(
	recid INT IDENTITY(1, 1),
	PC1ID VARCHAR(13),
	eventDescription VARCHAR(200),
	DueDate DATETIME
);

-- ASQ
INSERT INTO @timeline
SELECT	PC1ID,
		EventDescription,
		CASE WHEN Interval < 24 THEN DATEADD(dd, DueBy, (((40 - GestationalAge) * 7) + HVCase.TCDOB))
		ELSE	DATEADD(dd, DueBy, HVCase.TCDOB)
		END DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'ASQ-3'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND CASE WHEN Interval < 24 THEN DATEADD(dd, DueBy, (((40 - GestationalAge) * 7) + HVCase.TCDOB))
			ELSE	DATEADD(dd, DueBy, HVCase.TCDOB)
			END BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- ASQ-SE
SELECT	PC1ID,
		EventDescription,
		CASE WHEN Interval < 24 THEN DATEADD(dd, DueBy, (((40 - GestationalAge) * 7) + HVCase.TCDOB))
		ELSE	DATEADD(dd, DueBy, HVCase.TCDOB)
		END DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'ASQSE-2'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND CASE WHEN Interval < 24 THEN DATEADD(dd, DueBy, (((40 - GestationalAge) * 7) + HVCase.TCDOB))
			ELSE	DATEADD(dd, DueBy, HVCase.TCDOB)
			END  BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- HOME
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, DueBy, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'HOME'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, DueBy, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- HOME EC
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, DueBy, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'HOMEEC'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, DueBy, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- FOLLOW UP
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, DueBy, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'FOLLOW UP'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, DueBy, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- TCMedical
-- DTaP
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'DTaP'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- HIB
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'HIB'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- PCV
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'PCV'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Polio
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'POLIO'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- MMR
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'MMR'		
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- HEP-B
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'HEP-B'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- VZ
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'VZ'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Flu
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'FLU'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Roto
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'Roto'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- HEP-A
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'HEP-A'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- WBV
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'WBV'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Lead
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'Lead'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- IFSP
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.IntakeDate) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'IFSP'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.IntakeDate) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Safety Checklist
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, MinimumDue, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'SafetyCheckList'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, MinimumDue, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Benefits Status Change Form
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, DueBy, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'BenefitsStatusChange'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, DueBy, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Received Period of Purple Crying Kit (just a reminder, not form data to back this up)
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, DueBy, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'CryingKit'		
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, DueBy, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Hearing (OAE)
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, DueBy, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'OAE'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, DueBy, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL

UNION

-- Vision & Health Record
SELECT	PC1ID,
		EventDescription,
		DATEADD(dd, DueBy, HVCase.TCDOB) DueDate
FROM	CaseProgram
	INNER JOIN HVCase
		ON HVCasePK = CaseProgram.HVCaseFK
	INNER JOIN TCID
		ON TCID.HVCaseFK = HVCasePK
	INNER JOIN codeDueByDates
		ON ScheduledEvent = 'VHR'
WHERE CASE WHEN CurrentFSWFK IS NOT NULL THEN CurrentFSWFK ELSE CurrentFAWFK END = @WorkerFK
	AND CaseProgram.ProgramFK = @ProgramFK
	AND CaseProgress >= 11
	AND DATEADD(dd, DueBy, HVCase.TCDOB) BETWEEN @StartDate AND @EndDate
	AND DischargeDate IS NULL;

-- FINAL TIMELINE
SELECT	PC1ID,
		eventDescription AS EventName,
		DueDate AS DateRequired
FROM	@timeline
ORDER BY PC1ID, DueDate;
GO
