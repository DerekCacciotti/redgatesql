SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 03/31/2020
-- Description:	This function returns true if more than one of the passed bits is true, false otherwise
-- =============================================
CREATE FUNCTION [dbo].[fnIsMultiRace]
(
	@Race_AmericanIndian BIT,
	@Race_Asian BIT,
	@Race_Black BIT,
	@Race_Hawaiian BIT,
	@Race_White BIT,
	@Race_Other BIT
)
RETURNS BIT

BEGIN

	DECLARE @RaceCount INT = 0


	SET @RaceCount =	  CASE WHEN @Race_AmericanIndian = 1 Then 1 Else 0 End + 
						  CASE WHEN @Race_Asian = 1 Then 1 Else 0 End +
						  CASE WHEN @Race_Black = 1 Then 1 Else 0 End +
						  CASE WHEN @Race_Hawaiian = 1 Then 1 Else 0 End +
						  CASE WHEN @Race_White = 1 Then 1 Else 0 End +
						  CASE WHEN @Race_Other = 1 Then 1 Else 0 End 

    RETURN(CASE WHEN @RaceCount > 1 THEN 1 ELSE 0 END)

END
GO
