
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Use of Creative Outreach - Detail>
--				Moved from FamSys - 02/05/12 jrobohn
-- =============================================
CREATE procedure [dbo].[rspPC1IDList]
(
    @programfk int = 1
)
as

	select top 100 percent
						  programname
						 ,hvcasepk
						 ,pc1id
						 ,oldid
						 ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as workername
						 ,codelevelpk
						 ,levelname
						 ,currentleveldate
						 ,LTRIM(RTRIM(pc.pcfirstname))+' '+LTRIM(RTRIM(pc.pclastname)) as pcname
						 ,LTRIM(RTRIM(tcid.tcfirstname))+' '+LTRIM(RTRIM(tcid.tclastname)) as tcname
						 ,hvcase.tcdob
						 ,hvcase.edc
						 ,hvcase.screendate
						 ,HVCase.kempedate
						 ,hvcase.intakedate
						 ,pc2fk
						 ,case
							  when pc2fk is null or pc2fk = 0 then
								  0
							  else
								  1
						  end as pc2exists
						 ,case
							  when pc2fk is not null and pc2fk > 0
								  then
								  (select LTRIM(RTRIM(pcfirstname))+' '+LTRIM(RTRIM(pclastname)) as pc2name
									   from pc
									   where pcpk = pc2fk)
							  else
								  ''
						  end as pc2name
						 ,obpfk
						 ,case
							  when obpfk is null or obpfk = 0 then
								  0
							  else
								  1
						  end as obpexists
						 ,case
							  when obpfk is not null and obpfk > 0
								  then
								  (select LTRIM(RTRIM(pcfirstname))+' '+LTRIM(RTRIM(pclastname)) as obpname
									   from pc
									   where pcpk = obpfk)
							  else
								  ''
						  end as obpname
						 ,cpfk as ecfk
						 ,case
							  when cpfk is null or cpfk = 0 then
								  0
							  else
								  1
						  end as ecexists
						 ,case
							  when cpfk is not null and cpfk > 0
								  then
								  (select LTRIM(RTRIM(pcfirstname))+' '+LTRIM(RTRIM(pclastname)) as cpname
									   from pc
									   where pcpk = cpfk)
							  else
								  ''
						  end as ecname
		from hvcase
			inner join caseprogram
					  on caseprogram.hvcasefk = hvcasepk
			inner join HVProgram
					  on hvprogrampk = caseprogram.programfk
			inner join codelevel
					  on codelevelpk = currentlevelfk
			inner join pc
					  on pc.pcpk = pc1fk
			left join tcid
					 on tcid.hvcasefk = hvcasepk
			inner join worker fsw
					  on CurrentFSWFK = fsw.workerpk
			inner join workerprogram
					  on workerfk = fsw.workerpk
		where caseprogram.programfk = @programfk
			 and dischargedate is null
			 and kempedate is not null
			 and casestartdate <= dateadd(dd,1,datediff(dd,0,GETDATE()))
		order by oldid
				,workername
				,screendate

	/* SET NOCOUNT ON */
	return
GO
