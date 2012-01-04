SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<udfHVRecords - helper function for HV Achievement Rate reports>
-- =============================================
CREATE FUNCTION [dbo].[udfHVRecords]
(
	-- Add the parameters for the function here
	@programfk varchar(max) = null,
	@sdate datetime, 
	@edate datetime
	
)
RETURNS 
@tHVRecords TABLE(casefk int, startdate datetime, enddate datetime, levelname varchar(30),programfk int,
		workerfk int, reqvisitcalc float, hvlevelpk int, reqvisit float,
		hvlogpk int, visittype varchar(3), visitlengthminute int, visitlengthhour int, VisitStartTime datetime, pc1id varchar(13), dischargedate datetime)
AS
BEGIN

	IF @programfk IS NULL BEGIN
		SELECT @programfk = 
			SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
						FROM HVProgram
						FOR XML PATH('')),2,8000)
	END

	SET @programfk = REPLACE(@programfk,'"','')

	--match the hvlog records to this
	INSERT INTO @THVRecords
	select tlp.*, 
	HVLogPK,VisitType,VisitLengthMinute, VisitLengthHour,VisitStartTime,cp.PC1id,cp.DischargeDate
	from [dbo].[udfLevelPieces](@programfk, @sdate, @edate) tlp
	Left OUTER JOIN hvlog 
	on tlp.casefk=hvlog.hvcasefk
	and VisitStartTime between tlp.StartDate and tlp.EndDate 
	Inner Join CaseProgram cp
	ON cp.HVCaseFK=tlp.Casefk 
	and cp.ProgramFK=tlp.programfk

  RETURN

END
GO
