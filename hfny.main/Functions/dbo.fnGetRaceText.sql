SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--Returns text representation of all MIECHV Race bits and Race_Specify text

CREATE FUNCTION [dbo].[fnGetRaceText]
(
	@Race_AmericanIndian bit
	, @Race_Asian bit
	, @Race_Black bit
	, @Race_Hawaiian bit
	, @Race_White bit
	, @Race_Other bit
	, @Race_Specify varchar(MAX)
)
RETURNS varchar(MAX)


BEGIN
	declare @RaceText varchar(MAX)
	declare @AmericanIndian varchar(32) = 'American Indian '
	declare @Asian varchar(32) = 'Asian '
	declare @Black varchar(32) = 'Black '
	declare @Hawaiian varchar(32) = 'Hawaiian '
	declare @White varchar(32) = 'White '

	set @RaceText = Case When @Race_AmericanIndian = 1 Then @AmericanIndian  Else '' End +
					Case When @Race_Asian = 1 Then @Asian  Else '' End +
					Case When @Race_Black = 1 Then @Black  Else '' End +
					Case When @Race_Hawaiian = 1 Then @Hawaiian  Else '' End +
					Case When @Race_White = 1 Then @White  Else '' End +
					Case When @Race_Other = 1 Then @Race_Specify  Else '' End

    RETURN(@RaceText)

END
GO
