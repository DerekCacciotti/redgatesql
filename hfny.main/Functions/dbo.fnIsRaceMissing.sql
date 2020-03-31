SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 03/31/2020
-- Description:	This function returns true if all the passed bit fields are null or zero, false otherwise
-- =============================================
CREATE FUNCTION [dbo].[fnIsRaceMissing]
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
	--A bit value that contains true if race is missing, false otherwise
	DECLARE @IsRaceMissing BIT = 0

	--Determine if the race is missing
	SET @IsRaceMissing = CASE WHEN (ISNULL(@Race_AmericanIndian, 0) = 0 AND 
									ISNULL(@Race_Asian, 0) = 0 AND 
									ISNULL(@Race_Black, 0) = 0 AND
									ISNULL(@Race_Hawaiian, 0) = 0 AND
									ISNULL(@Race_White, 0) = 0 AND
									ISNULL(@Race_Other, 0) = 0) THEN 1 ELSE 0 END
	--Return the bit value
    RETURN(@IsRaceMissing)

END
GO
