SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <July 20, 2012>
-- Description:	<gets you data for Enrolled Program Caseload detail info>
-- exec [rspEnrolledProgramCaseloadDetail] 1,'06/01/2010','08/31/2010'
-- =============================================
CREATE procedure [dbo].[rspEnrolledProgramCaseloadDetail](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,                                                        
                                                        @sitefk int             = NULL
                                                                                                                  
                                                        )

as
BEGIN

-- Let us declare few table variables so that we can manipulate the rows at our will
-- Note: Table variables are a superior alternative to using temporary tables 

---------------------------------------------
-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- table variable for holding Init Required Data
DECLARE @tblInitRequiredData TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],
	[TCNumber] [int],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[SiteFK] [int],
	[PC1ID] [char](13),
	[LevelChangeStar] [char](1)
)


DECLARE @tblInitRequiredDataTemp TABLE(
	[HVCasePK] [int],
	[IntakeDate] [datetime],
	[TCDOB] [datetime],
	[TCDOD] [datetime],	
	[TCNumber] [int],
	[DischargeDate] [datetime],
	[DischargeReason] [char](2),
	[SiteFK] [int],
	[PC1ID] [char](13),
	[LevelChangeStar] [char](1)

)

;
WITH cteLevelChange
AS
(
SELECT 
count(*) count, hd.hvcasefk  FROM HVLevelDetail hd
INNER JOIN CaseProgram cp ON cp.HVCaseFK = hd.HVCaseFK
inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem	
WHERE hd.EndLevelDate BETWEEN @sdate AND @edate 
AND DischargeDate <> hd.EndLevelDate
GROUP BY hd.hvcasefk
HAVING count(*) > 0
)



-- Fill this table i.e. @tblInitRequiredData as below
INSERT INTO @tblInitRequiredDataTemp(
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[TCNumber],
	[DischargeDate],
	[DischargeReason],
	[SiteFK],
	[PC1ID],
	[LevelChangeStar]
)
SELECT 
h.HVCasePK,h.IntakeDate,

case
   when h.tcdob is not null then
	   h.tcdob
   else
	   h.edc
end as tcdob
,h.TCDOD 
,h.TCNumber,cp.DischargeDate, cp.DischargeReason,CASE WHEN wp.SiteFK IS NULL THEN 0 ELSE wp.SiteFK END AS SiteFK
,cp.PC1ID
,CASE WHEN lc.hvcasefk IS NULL THEN '' ELSE '*' END AS levelchange
FROM HVCase h 
INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
LEFT JOIN cteLevelChange lc ON lc.hvcasefk =  cp.HVCaseFK
inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem	 


-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
-- so to solve this problem we make use of @tblInitRequiredDataTemp
INSERT INTO @tblInitRequiredData( 
	[HVCasePK],
	[IntakeDate],
	[TCDOB],
	[TCDOD],
	[TCNumber],
	[DischargeDate],
	[DischargeReason],
	[SiteFK],
	[PC1ID],
	[LevelChangeStar]
	)
SELECT * FROM @tblInitRequiredDataTemp
WHERE SiteFK = isnull(@sitefk,SiteFK)

---------------------------------------------

---------------------------------------------
--- **************************************** ---
-- Part 1: Families Enrolled at the beginning of the period	(QUARTERLY STATS)
-- exec [rspEnrolledProgramCaseloadDetail] 1,'06/01/2010','08/31/2010'


;
WITH cteLevelChangeStatus
AS 
(

SELECT 
irq.HVCasePK,
(select max(convert(varchar(12), StartLevelDate,112) + LEFT(levelname,20) )
						  from hvleveldetail hld
						  where irq.HVCasePK = hld.hvcasefk
							   and StartLevelDate <= @edate) AS selectname
,LevelChangeStar							   
							   
							   
FROM @tblInitRequiredData irq
WHERE IntakeDate IS NOT NULL 
AND IntakeDate < @sdate
AND (DischargeDate IS NULL OR DischargeDate >= @sdate)
)



SELECT 
[PC1ID],
[IntakeDate],
[DischargeDate],
irq.[TCDOB],
substring(lcs.selectname,9, len(lcs.selectname)) + lcs.LevelChangeStar AS CurrentLevel
 FROM @tblInitRequiredData irq
 LEFT JOIN cteLevelChangeStatus lcs ON lcs.HVCasePK = irq.HVCasePK
WHERE IntakeDate IS NOT NULL 
AND IntakeDate < @sdate
AND (DischargeDate IS NULL OR DischargeDate >= @sdate)
ORDER BY PC1ID 	
END
GO
