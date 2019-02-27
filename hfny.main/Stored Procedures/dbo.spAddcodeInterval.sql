SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeInterval](@IntervalDescription char(100)=NULL,
@IntervalMaxMonth int=NULL,
@IntervalName char(10)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeIntervalPK
FROM codeInterval lastRow
WHERE 
@IntervalDescription = lastRow.IntervalDescription AND
@IntervalMaxMonth = lastRow.IntervalMaxMonth AND
@IntervalName = lastRow.IntervalName
ORDER BY codeIntervalPK DESC) 
BEGIN
INSERT INTO codeInterval(
IntervalDescription,
IntervalMaxMonth,
IntervalName
)
VALUES(
@IntervalDescription,
@IntervalMaxMonth,
@IntervalName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
