SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    jayrobot
-- Create date: May 20, 2019
-- Description: CHEERS Check In tickler summary
-- Edit date: 
-- =============================================
create procedure [dbo].[rspCHEERSCheckInTicklerSummary]
(
    @programfk    varchar(max)    = null,
    @rdate        datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	---- CHEERS Check-In
	select distinct pc1id
				   ,ISNULL(hvcase.tcdob, hvcase.edc) tcdob
				   ,eventDescription
				   ,dateadd(dd,dueby,ISNULL(hvcase.tcdob, hvcase.edc)) DueDate
				   ,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
								   from tcid
								   where hvcase.hvcasepk = tcid.hvcasefk
										and tcid.programfk = caseprogram.programfk
								   for xml path ('')),3,1000) TargetChild
				   ,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
				   ,LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
		from caseprogram
			inner join hvcase on hvcasepk = caseprogram.hvcasefk
			inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
			inner join codeduebydates on scheduledevent = 'CHEERS'
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker fsw on fsw.workerpk = currentfswfk
			inner join workerprogram on workerfk = fsw.workerpk AND workerprogram.ProgramFK = ListItem
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			
			left join CheersCheckIn cci on cci.hvcasefk = hvcasepk and cci.programfk = caseprogram.programfk 
			and codeduebydates.interval = cci.Interval
	
		where cci.hvcasefk is NULL
		     AND HVCase.TCDOD IS NULL
			 and CaseProgress >= 11
			 and CurrentFSWFK = isnull(@workerfk,CurrentFSWFK)
			 and SupervisorFK = isnull(@supervisorfk,SupervisorFK)
			 and (DischargeDate is null)
			 and year(dateadd(dd,dueby,ISNULL(hvcase.tcdob, hvcase.edc))) = year(@rdate)
			 and month(dateadd(dd,dueby,ISNULL(hvcase.tcdob, hvcase.edc))) = month(@rdate)
		order by fswname
				,DueDate
GO
