SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetSupervisionParentSurveyCasebyPK]

(@SupervisionParentSurveyCasePK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM SupervisionParentSurveyCase
WHERE SupervisionParentSurveyCasePK = @SupervisionParentSurveyCasePK
GO
