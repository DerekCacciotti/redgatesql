SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/12/2019
-- Description:	Get the allowed access value for the form
-- and state
-- =============================================
CREATE PROC [dbo].[spGetFormAccessAllowed]
    @FormAbbreviation VARCHAR(2) = NULL,
    @StateFK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get the allowed access value for the form and state
    SELECT cfa.AllowedAccess
    FROM dbo.codeFormAccess cfa
        INNER JOIN dbo.codeForm cf
            ON cf.codeFormPK = cfa.codeFormFK
    WHERE cfa.StateFK = ISNULL(@StateFK, cfa.StateFK)
          AND cf.codeFormAbbreviation = ISNULL(@FormAbbreviation, cf.codeFormAbbreviation);

END;
GO
