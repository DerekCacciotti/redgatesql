SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[rspuseofcheerscheckintool] @startdate DATETIME, @enddate DATETIME, @sitefk INT, @programfk VARCHAR(200),
 @WorkerFK INT, @CaseFiltersPostive VARCHAR(100) as

IF @ProgramFK IS NULL
	begin
		select @ProgramFK = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @ProgramFK = replace(@ProgramFK,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK END

	SET @CaseFiltersPostive = CASE WHEN @CaseFiltersPostive = '' THEN NULL ELSE @CaseFiltersPostive end
	
	DECLARE @tblallcases TABLE
	( tcidpk INT, 
	programfk INT, 
	tcdob DATETIME,
	hvcasefk INT, 
	intakedate DATETIME,
	dischargedate DATETIME,
	tcageindays INT,
	lastdate DATETIME, 
	pc1id CHAR(13)

	)

	INSERT INTO @tblallcases
	(
	    tcidpk,
	    programfk,
	    tcdob,
	    hvcasefk,
	    intakedate,
	    dischargedate,
	    tcageindays,
	    lastdate,
		pc1id
	)
	
	SELECT t.tcidpk,t.programfk,t.tcdob,t.hvcasefk, hv.IntakeDate, cp.DischargeDate, 
	CASE WHEN cp.DischargeDate IS NOT NULL AND cp.DischargeDate <> '' AND cp.DischargeDate <= @enddate THEN
    DATEDIFF(DAY,hv.TCDOB,cp.DischargeDate) ELSE
	DATEDIFF(DAY, hv.TCDOB, @enddate) 
	END,
	CASE WHEN cp.DischargeDate IS NOT NULL AND cp.DischargeDate <> '' AND cp.DischargeDate >= @enddate THEN cp.DischargeDate
	ELSE
	@enddate
	END, 
	cp.PC1ID
	 FROM dbo.TCID t 
	INNER JOIN dbo.HVCase hv ON hv.HVCasePK = t.HVCaseFK
	INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = hv.HVCasePK
	INNER JOIN dbo.SplitString(@programfk,',' ) ON cp.ProgramFK = ListItem
	inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
INNER JOIN dbo.udfCaseFilters(@CaseFiltersPostive,'', @programfk) cf ON cf.HVCaseFK = t.HVCaseFK
WHERE cp.CurrentFSWFK = ISNULL(@WorkerFK,cp.CurrentFSWFK)

	

	


	



	DECLARE @tblcohort TABLE
	( pc1id CHAR (13),
	tcidfk INT, 
	programfk INT, 
	tcdob DATETIME,
	hvcasefk INT, 
	intakedate DATETIME,
	dischargedate DATETIME,
	tcageindays INT,
	lastdate DATETIME,
	invervaldue CHAR(10)

	)




	INSERT INTO @tblcohort
	(	pc1id,	
	    tcidfk,
	    programfk,
	    tcdob,
	    hvcasefk,
	    intakedate,
	    dischargedate,
	    tcageindays,
	    lastdate
	
	
	)
	
	
	-- get tcs 7 months old or older 
	SELECT pc1id,tcidpk,programfk, tcdob,hvcasefk,intakedate,dischargedate,tcageindays,lastdate  FROM @tblallcases
	WHERE DATEDIFF(month,tcdob,@startdate) >= 7 AND intakedate <=@enddate 
	AND (dischargedate IS NULL OR dischargedate >= @startdate)
	




DECLARE @tblcheersatinterval TABLE
(
pc1id CHAR(13),
tcidfk INT,
hvcasefk INT,
programfk INT, 
tcdob DATETIME, 
intakedate DATETIME,
tcageindays INT,
intervaldue CHAR(10)
)


INSERT INTO @tblcheersatinterval
(	pc1id,
    tcidfk,
	hvcasefk,
    programfk,
    tcdob,
	intakedate,
    tcageindays,
    intervaldue
)


SELECT pc1id,tcidfk, co.hvcasefk, co.programfk, tcdob, co.intakedate, tcageindays,  cbd.Interval FROM @tblcohort co 
INNER JOIN dbo.codeDueByDates cbd ON cbd.ScheduledEvent = 'CHEERS' 
AND co.tcageindays >= cbd.DueBy







DECLARE @cohort2 TABLE
(pc1id CHAR(13),hvcasefk INT, tcidfk INT, interval CHAR(10) , tcageindays INT)



INSERT INTO @cohort2
(	pc1id,
    hvcasefk,
    tcidfk,
    interval,
    tcageindays
)

SELECT pc1id,hvcasefk, tcidfk, MAX(intervaldue) AS interval, tcageindays FROM @tblcheersatinterval

GROUP BY pc1id,hvcasefk, tcidfk, tcageindays




DECLARE @finaltablewithrownums TABLE
( pc1id CHAR(13), hvcasefk int, tcidfk INT, tcfirstname varchar(200), tcdob datetime, intakedate DATETIME, ccipk INT, 
interval CHAR(10), observationdate DATETIME, rownum INT, inwindow CHAR(10))





INSERT INTO @finaltablewithrownums
(
    pc1id,
    hvcasefk,
	tcidfk,
    tcfirstname,
    tcdob,
    intakedate,
	ccipk,
	interval,
	observationdate,
	rowNum,
	inwindow
)



SELECT pc1id, c.hvcasefk, c.tcidfk, tc.TCFirstName, tc.TCDOB, hv.IntakeDate, cci.cheerscheckinpk, 
cci.interval, cci.observationdate, 
ROW_NUMBER() OVER(PARTITION BY c.tcidfk ORDER BY ObservationDate), CASE WHEN c.tcageindays BETWEEN MinimumDue AND MaximumDue THEN 'Yes' ELSE 'No' end FROM @cohort2 c
LEFT JOIN dbo.CheersCheckIn cci ON cci.TCIDFK = c.tcidfk
--LEFT JOIN dbo.CheersCheckIn cci ON cci.TCIDFK = c.tcidfk AND ObservationDate BETWEEN @startdate AND @enddate
LEFT JOIN dbo.codeDueByDates ON codeDueByDates.Interval = c.interval
inner JOIN dbo.TCID tc ON tc.TCIDPK = c.tcidfk
inner JOIN dbo.HVCase hv ON hv.HVCasePK = c.hvcasefk
WHERE ScheduledEvent = 'CHEERS'





DECLARE @finaltable TABLE
( pc1id CHAR(13), hvcasefk int, tcidfk INT, tcfirstname varchar(200), tcdob datetime, intakedate DATETIME, 
dateoflastcci datetime, lastinterval CHAR(10), previousccidate DATETIME, previousinterval CHAR(10), rowNum INT, 
validintimeperiod CHAR(10), numvalidintimeperiod INT, inwindow CHAR(10), numoftcswithonecheers INT, inperiod CHAR(10) )



INSERT INTO @finaltable	
(
    pc1id,
    hvcasefk,
    tcidfk,
    tcfirstname,
    tcdob,
    intakedate,
    dateoflastcci,
    lastinterval,
    previousccidate,
    previousinterval,
	rowNum,
	validintimeperiod,
	inwindow, 
	numoftcswithonecheers,
	inperiod

	
    
)


SELECT t1.pc1id,t1.hvcasefk, t1.tcidfk,t1.tcfirstname, t1.tcdob,t1.intakedate,t1.observationdate,
t1.interval, t2.observationdate, t2.interval, t1.rownum, CASE WHEN t1.observationdate IS NULL THEN 'No' ELSE 'Yes' END, 
t1.inwindow, SUM(CASE WHEN t1.observationdate IS NOT NULL AND t1.rownum = 1 THEN 1 ELSE 0 END), 
CASE WHEN t1.observationdate BETWEEN @startdate AND @enddate THEN 'Yes' ELSE 'No' end
 FROM @finaltablewithrownums t1 left JOIN @finaltablewithrownums t2 ON t1.rownum - t2.rownum = 1 AND t1.tcidfk = t2.tcidfk
 GROUP BY t1.pc1id, t1.hvcasefk,t1.tcidfk,t1.tcfirstname, t1.tcdob, t1.intakedate, t1.observationdate, t1.interval,
  t2.observationdate,t2.interval, t1.rownum,t1.inwindow


 SELECT * FROM @finaltable ORDER BY pc1id
			
GO
