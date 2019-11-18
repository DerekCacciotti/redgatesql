SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/18/2019
-- Description:	Returns the app name from the app name table
-- =============================================
CREATE PROC [dbo].[spGetAppName]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
	--To hold the number of app names
    DECLARE @numResults INT = 0;

	--To hold the app names
    DECLARE @tblAppName TABLE
    (
        AppName VARCHAR(50) NULL
    );

	--Get the app name (there should only be 1)
    INSERT INTO @tblAppName
    (
        AppName
    )
    SELECT an.AppName
    FROM dbo.AppName an;

	--Set the number of results to the count from the app name table
    SET @numResults =
    (
        SELECT COUNT(ta.AppName) FROM @tblAppName ta
    );

	--If the number of results is 1, the result is valid and it should return the 1 app name
	--If the number of results is not 1, the result is not valid ant is should return null
    IF (@numResults = 1)
    BEGIN
        SELECT ta.AppName
        FROM @tblAppName ta;
    END;
    ELSE
    BEGIN
        SELECT NULL;
    END;

END;
GO
