SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<udfHVRecords - helper function for HV Achievement Rate reports>
-- =============================================
CREATE function [dbo].[udfHVRecords]
(-- Add the parameters for the function here
 @programfk varchar(max)    = null,
 @sdate     datetime,
 @edate     datetime
 )
returns
@tHVRecords table(
	casefk int,
	startdate datetime,
	enddate datetime,
	levelname varchar(50),
	programfk int,
	workerfk int,
	reqvisitcalc float,
	hvlevelpk int,
	reqvisit float,
	hvlogpk int,
	visittype varchar(6),
	visitlengthminute int,
	visitlengthhour int,
	VisitStartTime datetime,
	pc1id varchar(13),
	dischargedate datetime
)
as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	--match the hvlog records to this
	insert
		into @THVRecords
		select tlp.*
			  ,HVLogPK
			  ,VisitType
			  ,VisitLengthMinute
			  ,VisitLengthHour
			  ,VisitStartTime
			  ,cp.PC1ID
			  ,cp.DischargeDate
			from [dbo].[udfLevelPieces](@programfk, @sdate, @edate) tlp
				left outer join hvlog on tlp.casefk = hvlog.hvcasefk
							   and cast(VisitStartTime as date) between tlp.StartDate and tlp.EndDate
							   and FormComplete = 1
							   and dbo.IsFormReviewed(VisitStartTime, 'VL', HVLogPK) = 1
				inner join CaseProgram cp on cp.HVCaseFK = tlp.Casefk
						  and cp.ProgramFK = tlp.programfk

	return

end
GO
