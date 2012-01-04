SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<udfLevelPieces - returns distinct level periods for each caswe in cohort, used in many other sprocs>
-- =============================================
CREATE FUNCTION [dbo].[udfLevelPieces]
(
	-- Add the parameters for the function here
	@programfk varchar(max) = null,
	@sdate datetime, 
	@edate datetime
	
)
RETURNS 
@tLevelPieces TABLE(casefk int, startdate datetime, enddate datetime, levelname varchar(30),programfk varchar(max),
			workerfk int, reqvisitcalc float, hvlevelpk int, reqvisit float)
AS
BEGIN

	IF @programfk IS NULL BEGIN
		SELECT @programfk = 
			SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
						FROM HVProgram
						FOR XML PATH('')),2,8000)
	END

	SET @programfk = REPLACE(@programfk,'"','')

	--get the date ranges per worker, per level
	INSERT INTO @tLevelPieces
			select * , (datediff(day,beginning,ending)+1)/7 * maximumvisit as reqvisit 
			from (
				select wad.hvcasefk,
				CASE 	WHEN hld.StartLevelDate>StartAssignmentDate AND EndlevelDate>@sdate AND EndLevelDate <@edate AND hld.StartLevelDate<@sdate THEN @sdate --Chris Papas 07/26/2011 --below line did not cover all the bases.
						WHEN hld.StartLevelDate>StartAssignmentDate AND EndlevelDate>@sdate AND EndLevelDate <@edate THEN hld.StartLevelDate --Chris Papas, beginning date CASE was too simple and dates were wrong, this may not cover all the bases, but seems to work now.
						WHEN hld.StartLevelDate<StartAssignmentDate AND StartAssignmentDate>@sdate THEN StartAssignmentDate
						WHEN hld.StartLevelDate<@sdate THEN @sdate
						WHEN StartAssignmentDate>hld.StartLevelDate THEN StartAssignmentDate
						ELSE hld.StartLevelDate 
						END as beginning,
				CASE WHEN EndAssignmentDate < @edate THEN EndAssignmentDate
					 WHEN hld.EndLevelDate > @edate THEN @edate
					 WHEN hld.EndLevelDate > EndAssignmentDate THEN EndAssignmentDate
					 WHEN hld.EndLevelDate IS NULL THEN 
						CASE WHEN EndAssignmentDate IS NULL THEN @edate 
							 WHEN EndAssignmentDate > @edate THEN @edate
							 ELSE EndAssignmentDate END
					 Else hld.EndLevelDate END as ending,
					levelname,wad.programfk, workerfk, maximumvisit, hld.hvlevelpk
				FROM workerassignmentdetail wad 
				inner join hvleveldetail hld 
				on wad.hvcasefk=hld.hvcasefk
				INNER JOIN dbo.SplitString(@programfk,',')
				ON wad.programfk  = listitem
				where isnull(hld.endLevelDate,@edate)>=wad.StartAssignmentDate 
				and hld.StartLevelDate<=@edate
				and wad.StartAssignmentDate<=@edate --get assignments in report range
				and isnull(wad.EndAssignmentDate,@edate)>=@sdate 
				and ISNULL(hld.endlevelDate, @EDATE)>= @sdate 
			)a
			WHERE beginning < ending
	RETURN
END
GO
