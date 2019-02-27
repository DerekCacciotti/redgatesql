SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodePerformanceTargetTitle](@PerformanceTargetCode varchar(5)=NULL,
@PerformanceTargetCohortDescription varchar(150)=NULL,
@PerformanceTargetDescription varchar(500)=NULL,
@PerformanceTargetSection varchar(32)=NULL,
@PerformanceTargetTitle varchar(150)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codePerformanceTargetTitlePK
FROM codePerformanceTargetTitle lastRow
WHERE 
@PerformanceTargetCode = lastRow.PerformanceTargetCode AND
@PerformanceTargetCohortDescription = lastRow.PerformanceTargetCohortDescription AND
@PerformanceTargetDescription = lastRow.PerformanceTargetDescription AND
@PerformanceTargetSection = lastRow.PerformanceTargetSection AND
@PerformanceTargetTitle = lastRow.PerformanceTargetTitle
ORDER BY codePerformanceTargetTitlePK DESC) 
BEGIN
INSERT INTO codePerformanceTargetTitle(
PerformanceTargetCode,
PerformanceTargetCohortDescription,
PerformanceTargetDescription,
PerformanceTargetSection,
PerformanceTargetTitle
)
VALUES(
@PerformanceTargetCode,
@PerformanceTargetCohortDescription,
@PerformanceTargetDescription,
@PerformanceTargetSection,
@PerformanceTargetTitle
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
