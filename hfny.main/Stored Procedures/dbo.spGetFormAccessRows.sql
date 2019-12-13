SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/12/2019
-- Description:	Get all the form access rows
-- =============================================

CREATE PROC [dbo].[spGetFormAccessRows] 
	@StateFK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get all the form access rows from the database
    SELECT cfa.codeFormAccessPK,
           cfa.AllowedAccess,
           cfa.CreateDate,
           cfa.Creator,
           cfa.EditDate,
           cfa.Editor,
           cfa.codeFormFK,
           cfa.StateFK
    FROM dbo.codeFormAccess cfa
    WHERE cfa.StateFK = ISNULL(@StateFK, cfa.StateFK);

END;
GO
