SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 12/19/2019
-- Description:	Get the forms from codeReportCatalog joined on the access rows for the reports
-- =============================================

CREATE PROC [dbo].[spGetReportsWithStatesAuthorized]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --Get all the report rows from the database
    SELECT crc.codeReportCatalogPK, crc.ReportName, crc.ReportDescription, crc.ReportClass,
		STRING_AGG(s.Abbreviation, ', ') WITHIN GROUP (ORDER BY s.Abbreviation ASC) AS StatesAllowed
	FROM dbo.codeReportCatalog crc
	LEFT JOIN dbo.codeReportAccess cra ON cra.ReportFK = crc.codeReportCatalogPK AND cra.AllowedAccess = 1
	LEFT JOIN dbo.State s ON s.StatePK = cra.StateFK
	GROUP BY crc.codeReportCatalogPK, crc.ReportName, crc.ReportDescription, crc.ReportClass

END;
GO
