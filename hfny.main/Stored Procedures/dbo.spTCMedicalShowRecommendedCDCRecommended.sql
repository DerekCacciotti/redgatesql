SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spTCMedicalShowRecommendedCDCRecommended] @TCDOB VARCHAR(128), @TCIDFK INT AS

DECLARE @numofdays INT

SET @numofdays = (SELECT DATEDIFF(DAY,@TCDOB, GETDATE()))
PRINT @numofdays

--red
SELECT  EventDescription, ScheduledEvent, Optional, DueBy, MedicalItemCode, TCItemDate, TCMedicalCreator, CONVERT(CHAR(10),DATEADD(DAY,DueBy,@TCDOB),111) AS estdate, 'past due' AS type FROM dbo.codeDueByDates INNER JOIN dbo.codeMedicalItem ON MedicalItemTitle = ScheduledEvent 
LEFT join dbo.TCMedical ON TCMedicalItem = MedicalItemCode  AND TCIDFK = @TCIDFK
 WHERE MedicalItemGroup = 'Immunization'   AND TCItemDate IS null AND DATEADD(MONTH,-3,DATEADD(DAY,DueBy,@TCDOB)) < GETDATE()

 UNION
 -- yellow
 (SELECT  EventDescription, ScheduledEvent, Optional, DueBy, MedicalItemCode, TCItemDate, TCMedicalCreator, CONVERT(CHAR(10),DATEADD(DAY,DueBy,@TCDOB),111) AS estdate, 'upcoming' AS type FROM dbo.codeDueByDates INNER JOIN dbo.codeMedicalItem ON MedicalItemTitle = ScheduledEvent 
LEFT join dbo.TCMedical ON TCMedicalItem = MedicalItemCode  AND TCIDFK = @TCIDFK
 WHERE MedicalItemGroup = 'Immunization'  AND TCItemDate IS NULL AND TCMedicalCreator IS NULL AND DATEADD(MONTH,-3,DATEADD(DAY,DueBy,@TCDOB)) >= GETDATE())
 
UNION
 (SELECT  EventDescription, ScheduledEvent, Optional, DueBy, MedicalItemCode, TCItemDate, TCMedicalCreator,CONVERT(CHAR(10),DATEADD(DAY,DueBy,@TCDOB),111) AS estdate, 'done' AS type FROM dbo.codeDueByDates INNER JOIN dbo.codeMedicalItem ON MedicalItemTitle = ScheduledEvent 
LEFT join dbo.TCMedical ON TCMedicalItem = MedicalItemCode  AND TCIDFK = @TCIDFK
 WHERE MedicalItemGroup = 'Immunization'  AND TCItemDate IS NOT NULL
 )




 --(SELECT  EventDescription, ScheduledEvent, Optional, DueBy, MedicalItemCode, TCItemDate, TCMedicalCreator, MedicalItemGroup, DATEADD(DAY,DueBy,@TCDOB) AS estdate, 'upcoming' AS type FROM dbo.codeDueByDates INNER JOIN dbo.codeMedicalItem ON MedicalItemTitle = ScheduledEvent 
--LEFT join dbo.TCMedical ON TCMedicalItem = MedicalItemCode  AND TCIDFK = @TCIDFK
-- WHERE MedicalItemGroup = 'Immunization' AND TCItemDate IS NULL AND TCMedicalCreator IS NULL)
-- UNION

ORDER BY type DESC
GO
