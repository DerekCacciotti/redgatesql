SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelSupervisionParentSurveyCase](@SupervisionParentSurveyCasePK int)

AS


DELETE 
FROM SupervisionParentSurveyCase
WHERE SupervisionParentSurveyCasePK = @SupervisionParentSurveyCasePK
GO
