SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spTCMedicalShowRecommendedCDCRecommended]

    @TCIDFK INT
AS


 DECLARE @TCDOB DATE
--DECLARE @TCIDFK int 
DECLARE @numberofrowscdcmaster INT
DECLARE @counter int 
DECLARE @currentscheduledevent VARCHAR(150)
DECLARE @chickenpoxstatus BIT
DECLARE @immunizationstatus BIT

DECLARE @TCAgeInDays INT 

DECLARE @isTCMorethan3MonthsOld BIT = 0

DECLARE @beginningofyear DATETIME =  DATEADD(yy, DATEDIFF(yy, 0, GETDATE()), 0)
DECLARE @endofyear DATETIME = DATEADD(yy, DATEDIFF(yy, 0, GETDATE()) + 1, -1)
SET @counter = 0
--SET @TCIDFK = 40494







--get the TCDOB
SET @tcdob = (SELECT tcdob FROM dbo.TCID WHERE TCIDPK=@TCIDFK)
-- get the TC age in days 
SET @TCAgeInDays = (SELECT DATEDIFF(DAY, @TCDOB, GETDATE()))
-- check to see if the TC is greater or equal to 90 days old 
IF(@TCAgeInDays >= 90)
BEGIN

SET @isTCMorethan3MonthsOld = 1
END

--get the status of the chickenpox virus and overall immunizations
SET @chickenpoxstatus = (SELECT VaricellaZoster FROM dbo.TCID WHERE TCIDPK = @TCIDFK)
SET @immunizationstatus = (SELECT NoImmunization FROM dbo.TCID WHERE TCIDPK = @TCIDFK)

PRINT @chickenpoxstatus
PRINT @immunizationstatus


--This is my CDC Master Table
DECLARE @CDCMaster TABLE
( ID INT IDENTITY(1,1),
codeduebydatespk INT, 
dueby INT,
eventdescription VARCHAR(50),
interval CHAR(2),
maxdue INT,
mindue INT,
scheduledevent VARCHAR(20),
frequency INT,
optional BIT,
DisplayDate CHAR(10),
estdate CHAR(10)
)


INSERT INTO @CDCMaster
(
    codeduebydatespk,
    dueby,
    eventdescription,
    interval,
    maxdue,
    mindue,
    scheduledevent,
    frequency,
    optional,
	estdate
)
SELECT codeduebydatespk,
    dueby,
    eventdescription,
    interval,
    MaximumDue,
    MinimumDue,
    scheduledevent,
    frequency,
    optional,
	--DATEADD(day,DueBy, @TCDOB)
	CONVERT(CHAR(10), DATEADD(DAY, DueBy, @TCDOB), 111)

       FROM dbo.codeDueByDates INNER JOIN dbo.codeMedicalItem  ON MedicalItemTitle = ScheduledEvent
       WHERE (MedicalItemGroup = 'Immunization')
          ORDER BY codeDueByDates.DueBy



       SET @numberofrowscdcmaster = (SELECT COUNT(*) FROM @CDCMaster)

          

DECLARE @TCIDImmunizations TABLE
(
ImmunizationID INT IDENTITY(1,1),
EventDescription VARCHAR(120),
ScheduledEvent VARCHAR(120),
Optional BIT,
DueBy INT,
DisplayDate CHAR(10),
MedicalItemTitle VARCHAR(10),
estdate CHAR(10)
)

INSERT INTO @TCIDImmunizations
(
    --EventDescription,
    --ScheduledEvent,
    --Optional,
    --DueBy,
    DisplayDate,
       MedicalItemTitle
    --estdate
)
SELECT --EventDescription,
       --ScheduledEvent,
       --Optional,
       --DueBy,
       CONVERT(CHAR(10), TCItemDate, 111) AS TCItemDate
          , MedicalItemTitle
       --, CONVERT(CHAR(10), DATEADD(DAY, DueBy, @TCDOB), 111) AS estdate
FROM TCMedical
INNER JOIN codeMedicalItem ON MedicalItemCode = TCMedicalItem
--INNER JOIN dbo.codeDueByDates ON MedicalItemTitle = ScheduledEvent
WHERE (MedicalItemGroup = 'Immunization')
AND tcidfk = @TCIDFK



--set the estimated dates for when the CDC wants the immunizations in the master table
--UPDATE @CDCMaster SET estdate = CONVERT(CHAR(10), DATEADD(DAY, DueBy, @TCDOB), 111) 


--SELECT * FROM @CDCMaster ORDER BY dueby





WHILE @counter <= @numberofrowscdcmaster
BEGIN

       DECLARE @immunizationdate AS DATE = NULL --this is what we get from the @TCIDImmunizations table
       DECLARE @idDelete AS INT = NULL --this is what the TCIDImmunizations pk that we will delete once we get the immunization date
       DECLARE @myevent AS VARCHAR(10) = (SELECT scheduledevent FROM @CDCMaster WHERE id = @counter)

       PRINT @counter

       SET @immunizationdate = (SELECT TOP 1 DisplayDate FROM @TCIDImmunizations WHERE MedicalItemTitle = @myevent Order BY displaydate)
       SET @idDelete = (SELECT TOP 1 ImmunizationID FROM @TCIDImmunizations WHERE MedicalItemTitle = @myevent Order BY displaydate)
       
       UPDATE @CDCMaster SET DisplayDate = @immunizationdate WHERE id = @counter
       DELETE FROM @TCIDImmunizations WHERE ImmunizationID=@idDelete

SET @counter = @counter + 1
END


IF(@chickenpoxstatus = 1)
BEGIN 





IF(@isTCMorethan3MonthsOld = 0)
BEGIN

SELECT *, 'Past due' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
AND DATEADD(MONTH, -3, DATEADD(DAY,dueby, @TCDOB)) < GETDATE()
 AND DATEADD(DAY, DueBy, @TCDOB) < GETDATE()
 AND scheduledevent != 'VZ'
 


 UNION 

 SELECT *, 'Nearing' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
 --AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() 
 AND estdate BETWEEN @beginningofyear AND @endofyear
 AND scheduledevent != 'VZ' 

 UNION 

 SELECT *, 'Done' AS type FROM @CDCMaster WHERE DisplayDate IS NOT NULL OR scheduledevent = 'VZ'


 UNION
 SELECT  *, '' AS type FROM @CDCMaster WHERE DisplayDate IS NULL AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() AND estdate > @endofyear

END



ELSE

BEGIN


SELECT *, 'Past due' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
AND DATEADD(MONTH, -3, DATEADD(DAY,dueby, @TCDOB)) < GETDATE()
 AND DATEADD(DAY, DueBy, @TCDOB) < GETDATE()
 AND scheduledevent != 'VZ'
 


 UNION 

 SELECT *, 'Nearing' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
 AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() AND estdate BETWEEN @beginningofyear AND @endofyear
 AND scheduledevent != 'VZ' 

 UNION 

 SELECT *, 'Done' AS type FROM @CDCMaster WHERE DisplayDate IS NOT NULL OR scheduledevent = 'VZ'


 UNION
 SELECT  *, '' AS type FROM @CDCMaster WHERE DisplayDate IS NULL AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() AND estdate > @endofyear

END


END












-- else for the chicken pox virus check 
ELSE



IF(@isTCMorethan3MonthsOld = 0)
BEGIN

BEGIN

SELECT *, 'Past due' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
AND DATEADD(MONTH, -3, DATEADD(DAY,dueby, @TCDOB)) < GETDATE()
 AND DATEADD(DAY, DueBy, @TCDOB) < GETDATE()



 UNION 

 
 SELECT *, 'Nearing' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
 --AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() 
 AND estdate BETWEEN @beginningofyear AND @endofyear

 UNION 

 SELECT *, 'Done' AS type FROM @CDCMaster WHERE DisplayDate IS NOT NULL


 UNION
 SELECT  *, '' AS type FROM @CDCMaster WHERE DisplayDate IS NULL AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() AND estdate > @endofyear





end

 

END


ELSE
-- begin for the else 
BEGIN


 -- when TC is 3 months or older 
BEGIN

SELECT *, 'Past due' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
AND DATEADD(MONTH, -3, DATEADD(DAY,dueby, @TCDOB)) < GETDATE()
 AND DATEADD(DAY, DueBy, @TCDOB) < GETDATE()



 UNION 

 
 SELECT *, 'Nearing' AS type FROM @CDCMaster WHERE DisplayDate IS NULL 
 AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() AND estdate BETWEEN @beginningofyear AND @endofyear

 UNION 

 SELECT *, 'Done' AS type FROM @CDCMaster WHERE DisplayDate IS NOT NULL


 UNION
 SELECT  *, '' AS type FROM @CDCMaster WHERE DisplayDate IS NULL AND DATEADD(MONTH,-3,DATEADD(DAY, dueby, @TCDOB)) >= GETDATE() AND estdate > @endofyear





end

 

 

 -- end for the else 

END






GO
