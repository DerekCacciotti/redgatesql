SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/10/2019
-- Description:	Get all the report access rows
-- =============================================

CREATE PROC [dbo].[spGetReportAccessRows]
    @StateFK INT = NULL,
    @ReportFK INT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get all the report access rows from the database
    SELECT cra.codeReportAccessPK,
           cra.StartDate,
           cra.EndDate,
           cra.ReportFK,
           cra.StateFK
    FROM dbo.codeReportAccess cra
    WHERE cra.StateFK = ISNULL(@StateFK, cra.StateFK)
          AND cra.ReportFK = ISNULL(@ReportFK, cra.ReportFK);

END;
GO
