
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Combined Tickler Summary>
--				Moved from FamSys - 02/05/12 jrobohn
-- =============================================
CREATE procedure [dbo].[rspCombinedTicklerSummary]
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

	select *
		from (
			  -- ASQ
			  select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					,hvcase.tcdob
					,gestationalage
					,eventDescription
					,case
						 when interval < 24 then
							 dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
						 else
							 dateadd(dd,dueby,hvcase.tcdob)
					 end DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,rtrim(tcfirstname)+' '+rtrim(tclastname) ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  --inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asq version'
					  inner join codeduebydates on scheduledevent = 'ASQ' 
					  --inner join codeduebydates on scheduledevent = optionValue
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
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
			  union
			  ---- ASQ-SE
			  select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					,hvcase.tcdob
					,gestationalage
					,eventDescription
					,dateadd(dd,dueby,hvcase.tcdob) DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,rtrim(tcfirstname)+' '+rtrim(tclastname) ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  --inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asqse version'
					  inner join codeduebydates on scheduledevent = 'ASQSE-1'  --optionValue
					  --inner join codeduebydates on scheduledevent = optionValue
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join asqse on asqse.hvcasefk = hvcasepk and asqse.programfk = caseprogram.programfk 
					  and codeduebydates.interval = asqseTCAge
				  where asqse.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)
					   and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
					   and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
			  union
			  ---- FOLLOW UP
			  select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					,hvcase.tcdob
					,gestationalage
					,eventDescription
					,dateadd(dd,dueby,hvcase.tcdob) DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,null ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  inner join codeduebydates on scheduledevent = 'Follow Up'
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join followup on followup.hvcasefk = hvcasepk and followup.programfk = caseprogram.programfk 
					  and codeduebydates.interval = followupinterval
				  where followup.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)
					   and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
					   and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
			
			
				 union
			  ---- PSI 10/01/2012 added by dar chen
			  select LevelName
					,pc1id
					,rtrim(pc1.pcfirstname)+' '+rtrim(pc1.pclastname) pc1name
					,hvcase.tcdob
					,gestationalage
					,eventDescription
					,dateadd(dd,dueby,hvcase.tcdob) DueDate
					,substring((select distinct ', '+rtrim(tcfirstname)+' '+rtrim(tclastname)
									from tcid
									where hvcase.hvcasepk = tcid.hvcasefk
										 and tcid.programfk = caseprogram.programfk
									for xml path ('')),3,1000) TargetChild
					,rtrim(fsw.firstname)+' '+rtrim(fsw.lastname) fswname
					,ltrim(rtrim(supervisor.firstname))+' '+ltrim(rtrim(supervisor.lastname)) supervisor
					,null ForWhom
				  from caseprogram
					  inner join hvcase on hvcasepk = caseprogram.hvcasefk
					  inner join pc pc1 on pc1fk = pc1.pcpk
					  inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
					  inner join codeduebydates on scheduledevent = 'PSI'
					  inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
					  inner join worker fsw on fsw.workerpk = currentfswfk
					  inner join workerprogram on workerfk = fsw.workerpk
					  inner join worker supervisor on supervisorfk = supervisor.workerpk
					  inner join codelevel on codelevelpk = currentlevelfk
					  left join PSI on PSI.hvcasefk = hvcasepk and PSI.programfk = caseprogram.programfk 
					  and codeduebydates.interval = PSIInterval
				  where PSI.hvcasefk is NULL
				       AND HVCase.TCDOD IS NULL
					   and caseprogress >= 11
					   and currentFSWFK = isnull(@workerfk,currentFSWFK)
					   and supervisorfk = isnull(@supervisorfk,supervisorfk)
					   and (dischargedate is null)
					   and year(dateadd(dd,dueby,hvcase.tcdob)) = year(@rdate)
					   and month(dateadd(dd,dueby,hvcase.tcdob)) = month(@rdate)
					   
					   		   
					   ) t
		order by fswname
				,duedate
GO
