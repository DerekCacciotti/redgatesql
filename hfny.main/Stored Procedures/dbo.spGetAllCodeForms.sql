SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/12/2019
-- Description:	Get the forms from codeForm table
-- =============================================

CREATE PROC [dbo].[spGetAllCodeForms]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get all the form rows from the database
    SELECT codeFormPK,
           FormPKName,
           canBeReviewed,
           codeFormAbbreviation,
           codeFormName,
           CreatorFieldName,
           FormDateName,
           MainTableName
    FROM dbo.codeForm cf;

END;
GO
