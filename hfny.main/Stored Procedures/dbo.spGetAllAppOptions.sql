SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 11/22/2019
-- Description:	Get all the app options
-- =============================================

CREATE PROC [dbo].[spGetAllAppOptions] 
	@AppName VARCHAR(100)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	--Get all the app options from the database
    SELECT ao.AppOptionsPK,
           ao.OptionDataType,
           ao.OptionDescription,
           ao.OptionEnd,
           ao.OptionItem,
           ao.OptionStart,
           ao.OptionValue,
           ao.ProgramFK,
           ao.AppName,
           hp.ProgramName
    FROM dbo.AppOptions ao
		LEFT JOIN dbo.HVProgram hp ON ao.ProgramFK = hp.HVProgramPK
	WHERE ao.AppName = @AppName;

END;
GO
