
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: ASQ Tickler Summary>
--				Moved from FamSys - 02/05/12 jrobohn
-- =============================================
CREATE procedure [dbo].[rspASQTicklerSummary]
(
    @programfk    varchar(max)    = null,
    @rdate        datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')

	-- ASQ
	select pc1id
		  ,hvcase.tcdob
		  ,gestationalage
		  ,(((40-gestationalage)*7)+hvcase.tcdob) cdob
		  ,eventDescription
		  ,case
			   when interval < 24 then
				   dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
			   else
				   dateadd(dd,dueby,hvcase.tcdob)
		   end DueDate
		  ,rtrim(tcfirstname)+' '+rtrim(tclastname) TargetChild
		  ,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
		  ,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) as supervisor
		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
			--inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asq version'
			inner join codeduebydates on scheduledevent = 'ASQ' --optionValue
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker fsw on fsw.workerpk = currentfswfk
			inner join workerprogram on workerfk = fsw.workerpk
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			left join asq on asq.hvcasefk = hvcasepk and asq.programfk = caseprogram.programfk and codeduebydates.interval = TCAge
		where asq.hvcasefk is NULL
		     AND HVCase.TCDOD IS NULL
			 and caseprogress >= 11
			 and currentFSWFK = isnull(@workerfk,currentFSWFK)
			 and supervisorfk = isnull(@supervisorfk,supervisorfk)
			 and (dischargedate is null)
			 and year(case
						  when interval < 24 then
							  dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
						  else
							  dateadd(dd,dueby,hvcase.tcdob)
					  end) = year(@rdate)
			 and month(case
						   when interval < 24 then
							   dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
						   else
							   dateadd(dd,dueby,hvcase.tcdob)
					   end) = month(@rdate)
		order by fswname
				,DueDate
GO
