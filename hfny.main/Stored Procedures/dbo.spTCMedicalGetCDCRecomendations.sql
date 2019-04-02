SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spTCMedicalGetCDCRecomendations] @TCDOB VARCHAR(128), @TCIDFK INT AS

DECLARE @numofdays INT



SET @numofdays = (SELECT DATEDIFF(DAY,@TCDOB, GETDATE()) AS numofdays)



-- currently due
SELECT  EventDescription, ScheduledEvent, MaximumDue, MinimumDue, Optional, TCItemDate, 'currently' AS type FROM dbo.codeDueByDates 
INNER JOIN dbo.codeMedicalItem ON MedicalItemTitle = ScheduledEvent
 LEFT JOIN dbo.TCMedical ON TCIDFK = @TCIDFK AND TCMedicalItem = MedicalItemCode AND TCItemDate BETWEEN MinimumDue AND MaximumDue
WHERE @numofdays BETWEEN MinimumDue AND MaximumDue AND TCMedicalPK IS NULL and
ScheduledEvent not LIKE  '%ASQ%' AND ScheduledEvent != 'CHEERS' AND ScheduledEvent != 'Follow Up' AND ScheduledEvent != 'PSI' AND ScheduledEvent != 'WBV' 
AND ScheduledEvent !='Lead'


UNION
SELECT  EventDescription, ScheduledEvent, MaximumDue, MinimumDue, Optional, TCItemDate, 'upcoming' AS type FROM dbo.codeDueByDates 
INNER JOIN dbo.codeMedicalItem ON MedicalItemTitle = ScheduledEvent
 LEFT JOIN dbo.TCMedical ON TCIDFK = @TCIDFK AND TCMedicalItem = MedicalItemCode
WHERE MaximumDue > @numofdays AND 
ScheduledEvent not LIKE  '%ASQ%' AND ScheduledEvent != 'CHEERS' AND ScheduledEvent != 'Follow Up' AND ScheduledEvent != 'PSI'AND  ScheduledEvent != 'WBV' 
AND ScheduledEvent !='Lead'



UNION

SELECT  EventDescription, ScheduledEvent, MaximumDue, MinimumDue, Optional, TCItemDate, 'past' AS type FROM dbo.codeDueByDates 
INNER JOIN dbo.codeMedicalItem ON MedicalItemTitle = ScheduledEvent
 LEFT JOIN dbo.TCMedical ON TCIDFK = @TCIDFK AND TCMedicalItem = MedicalItemCode
WHERE MaximumDue <= @numofdays and
ScheduledEvent not LIKE  '%ASQ%' AND ScheduledEvent != 'CHEERS' AND ScheduledEvent != 'Follow Up' AND ScheduledEvent != 'PSI' AND ScheduledEvent != 'WBV' 
AND ScheduledEvent !='Lead'


ORDER BY type asc
GO
