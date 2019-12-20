SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 19,2009>
-- Description:	<Return the OptionValue for OptionItem, ProgramCode, for specify date>
-- mod: <Jay Robohn> <Aug 06,2018> <Make ProgramFK optional>
-- Updated by Benjamin Simmons on 11/13/19. Modified so that it works properly if sending
-- the current datetime from the app service.
-- =============================================
CREATE PROC [dbo].[spGetOptionItem]
(
    @OptionItem VARCHAR(50),
    @ProgramFK INT,
    @CompareDate DATETIME,
    @AppName VARCHAR(100),
    @OptionValue VARCHAR(200) OUTPUT
)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT @OptionValue = ao.OptionValue
    FROM dbo.AppOptions ao
    WHERE OptionItem = @OptionItem
          AND ao.AppName = @AppName
          AND CASE
                  WHEN @ProgramFK = 0 THEN
                      1
                  WHEN ProgramFK = @ProgramFK THEN
                      1
                  ELSE
                      0
              END = 1
          AND @CompareDate
          BETWEEN OptionStart AND ISNULL(OptionEnd, @CompareDate);
			--If the end date is null, use the compare date to ensure inclusion (BETWEEN is inclusive)

END;
GO
