SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/12/2019
-- Description:	Get the forms from codeForm joined on the access rows for the form
-- =============================================

CREATE PROC [dbo].[spGetFormsForManagement]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get all the form rows from the database
    SELECT cf.codeFormPK, cf.codeFormName, STRING_AGG(s.Abbreviation, ', ') WITHIN GROUP (ORDER BY s.Abbreviation ASC) AS StatesAllowed
	FROM dbo.codeForm cf
	INNER JOIN dbo.codeFormAccess cfa ON cfa.codeFormFK = cf.codeFormPK
	INNER JOIN dbo.State s ON s.StatePK = cfa.StateFK
	GROUP BY cf.codeFormPK, cf.codeFormName

END;
GO
