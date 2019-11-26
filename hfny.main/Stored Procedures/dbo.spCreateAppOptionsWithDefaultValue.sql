SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 11/26/2019
-- Description:	This method creates AppOptions rows for each distinct
-- app name in the AppOptions table
-- =============================================
CREATE PROCEDURE [dbo].[spCreateAppOptionsWithDefaultValue]
    -- Add the parameters for the stored procedure here
    @OptionDataType VARCHAR(20),
    @OptionDescription VARCHAR(250),
    @OptionEnd DATETIME,
    @OptionStart DATETIME,
    @OptionItem VARCHAR(50),
    @OptionValue VARCHAR(250),
    @OptionCreator VARCHAR(MAX),
	@AppName VARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

	--To hold the distinct app names
    DECLARE @tblDistinctAppNames TABLE
    (
        AppName VARCHAR(MAX) NULL
    );

	--Get the distinct app names from AppOptions where
	--the app name doesn't match (the row for this app
	--is created by the .NET page)
    INSERT INTO @tblDistinctAppNames
    (
        AppName
    )
    SELECT DISTINCT
           ao.AppName
    FROM dbo.AppOptions ao
	WHERE ao.AppName <> @AppName;

	--Add an AppOptions row for each app name
    INSERT INTO dbo.AppOptions
    (
        OptionDataType,
        OptionDescription,
        OptionEnd,
        OptionItem,
        OptionStart,
        OptionValue,
        ProgramFK,
        AppName,
        OptionCreator,
        OptionCreateDate,
        OptionEditor,
        OptionEditDate
    )
    SELECT @OptionDataType,         -- OptionDataType - varchar(20)
           @OptionDescription,		-- OptionDescription - varchar(250)
           @OptionEnd,              -- OptionEnd - datetime
           @OptionItem,             -- OptionItem - varchar(50)
           @OptionStart,            -- OptionStart - datetime
           @OptionValue,            -- OptionValue - varchar(250)
           NULL,                    -- ProgramFK - int
           tdan.AppName,            -- AppName - varchar(100)
           @OptionCreator,          -- OptionCreator - varchar(max)
           GETDATE(),               -- OptionCreateDate - datetime
           NULL,                    -- OptionEditor - varchar(max)
           NULL                     -- OptionEditDate - datetime
    FROM @tblDistinctAppNames tdan;

    COMMIT;
END;
GO
