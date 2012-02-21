SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
create procedure [dbo].[rspZipCode]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime
)
as
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
				   when hvcase.initialzip is null or len(hvcase.initialzip) = 0 then
					   'Missing/UNK'
				   else
					   left(hvcase.initialzip,5)
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
		group by zipcode
		order by zipcode
GO
