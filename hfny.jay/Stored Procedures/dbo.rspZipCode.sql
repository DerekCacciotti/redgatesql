
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn> <john & dar made some modification on Sep/24/2013>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
CREATE procedure [dbo].[rspZipCode]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime
)
as



--DECLARE @programfk varchar(max)    = '18'
--DECLARE @sdate     DATETIME = '09/01/2012'
--DECLARE @edate     DATETIME = '08/31/2013'


	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','');

	with cteAllZips (ProgramFK,zipcode,screenedzip,servedzip)
	as (select ProgramFK
			  ,case
				   when PCZip IS NULL OR len(PCZip) = 0 then       --hvcase.initialzip is null or len(hvcase.initialzip) = 0 then
					   'Missing/UNK'
				   else
					   left(PCZip,5) --left(hvcase.initialzip,5)
			   end zipcode
			  ,(case
					when screendate between @sdate and @edate then
						1
					else
						0
				end) screenedzip
			  ,(case
					when intakedate <= @edate and (dischargedate is null or dischargedate >= @sdate) then
						1
					else
						0
				end) servedzip
			from hvcase
				inner join caseprogram on hvcasepk = hvcasefk
				inner join pc pc1 on pc1fk = pc1.pcpk)
	--select * from cteAllZips
	select zipcode
		  ,sum(screenedzip) as ScreenedZip
		  ,sum(servedzip) as ServedZip
		from cteAllZips
			inner join dbo.SplitString(@programfk,',') on cteAllZips.ProgramFK = listitem
		WHERE NOT (screenedzip = 0 AND servedzip = 0)
		group by zipcode
		order by zipcode
GO
