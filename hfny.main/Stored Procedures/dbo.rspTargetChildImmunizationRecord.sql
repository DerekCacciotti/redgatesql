SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- =============================================
CREATE PROC [dbo].[rspTargetChildImmunizationRecord]
(
    @programfk varchar(max)    = null,
	@SiteFK	   INT			   = NULL,
    @CaseFiltersPositive varchar(100) = '',
    @rdate     datetime
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	set @CaseFiltersPositive = case when @CaseFiltersPositive = '' then null else @CaseFiltersPositive end	
	SET @SiteFK = isnull(@SiteFK, 0)

	---- TCMedical
	select PC1ID
		  ,TargetChild
		  ,TCDOB
		  ,TCAge
		  ,ShotsReceived
		  ,ShotsRequired
		  ,IsDelayed
		  ,case
			   when ShotsRequired <> 0 and (cast(ShotsReceived as float)/cast(ShotsRequired as float) <= 1) then
				   (cast(ShotsReceived as float)/cast(ShotsRequired as float))
			   when ShotsRequired <> 0 and (cast(ShotsReceived as float)/cast(ShotsRequired as float)) > 1 then
				   1
			   else
				   0
		   end as UpToDate
		  ,levelname
		from (select distinct pc1id
							 ,TargetChild
							 ,TCDOB
							 ,datediff(M,TCDOB,@rdate) TCAge
							 ,sum(case
									  when TCMedicalPK > 0 then
										  1
									  else
										  0
								  end) ShotsReceived
							 ,sum(case
									  when IsDelayed = 1 then
										  1
									  else
										  0
								  end) IsDelayed
							 ,(select count(*)
								   from codeduebydates
									   inner join codeMedicalItem cmi on ScheduledEvent = cmi.MedicalItemTitle and MedicalItemCode <= 13
								   where dateadd(dd,dueby,tcdob) <= @rdate) ShotsRequired
							 ,levelname
				  from (select distinct pc1id
									   ,rtrim(tcfirstname)+' '+rtrim(tclastname) TargetChild
									   ,hvcase.tcdob
									   ,hvcase.hvcasepk
									   ,caseprogram.programfk
									   ,null as TCItemDate
									   ,0 IsDelayed
									   ,0 TCMedicalPK
										,CurrentFSWFK
							from caseprogram
								inner join hvcase on hvcasepk = caseprogram.hvcasefk
								inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
								inner join (select EventDescription
												  ,Interval
												  ,DueBy
												  ,MedicalItemCode
												from codeduebydates
													inner join codeMedicalItem cmi on ScheduledEvent = cmi.MedicalItemTitle and MedicalItemCode <= 13) codeduebydates on codeduebydates.interval = datediff(M,dateadd(dd,-30.44,HVCase.TCDOB),@rdate)
								inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
								INNER JOIN dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFK) cf ON cf.HVCaseFK = HVCasePK
							where (hvcase.tcdob is not null
								 and hvcase.tcdob <= dateadd(dd,-30.44,@rdate)) -- caseprogress >= 11
								 and intakedate <= @rdate
								 and (dischargedate is null
								 or dischargedate > @rdate)
								 and (TCID.NoImmunization = 0
								 or TCID.NoImmunization is null)
						union
						select distinct pc1id
									   ,rtrim(tcfirstname)+' '+rtrim(tclastname) TargetChild
									   ,hvcase.tcdob
									   ,hvcase.hvcasepk
									   ,caseprogram.programfk
									   ,TCItemDate
									   ,IsDelayed
									   ,TCMedical.TCMedicalPK
										,CurrentFSWFK
							from caseprogram
								inner join hvcase on hvcasepk = caseprogram.hvcasefk
								inner join tcid on tcid.hvcasefk = hvcasepk and tcid.programfk = caseprogram.programfk
								inner join TCMedical on TCMedical.hvcasefk = hvcasepk and TCMedical.programfk = caseprogram.programfk and TCMedical.TCIDFK = TCID.TCIDPK and @rdate >= TCItemDate
								inner join codeMedicalItem cmi on MedicalItemCode = TCMedical.TCMedicalItem and MedicalItemCode <= 13
								inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
								INNER JOIN dbo.udfCaseFilters(@CaseFiltersPositive,'',@ProgramFK) cf ON cf.HVCaseFK = HVCasePK
							where (hvcase.tcdob is not null
								 and hvcase.tcdob <= dateadd(dd,-30.44,@rdate)) -- caseprogress >= 11
								 and intakedate <= @rdate
								 and (dischargedate is null)
								 and (TCID.NoImmunization = 0
								 or TCID.NoImmunization is null)) immunizations
					  INNER join worker fsw on CurrentFSWFK = fsw.workerpk
					  INNER join workerprogram on workerprogram.workerfk = fsw.workerpk
					  inner join (select hvcasefk
										,programfk
										,max(HVlevelpk) HVlevelpk
									  from HVLevelDetail
										  inner join dbo.SplitString(@programfk,',') on programfk = listitem
									  where StartLevelDate <= @rdate
									  group by hvcasefk
											  ,programfk) hl2 on hvcasepk = hl2.hvcasefk and immunizations.programfk = hl2.programfk
					  inner join HVLevelDetail hl1 on hl2.HVlevelpk = hl1.HVlevelpk
				  where levelname <> 'Level X'
					AND (CASE WHEN @SiteFK = 0 THEN 1 WHEN workerprogram.SiteFK = @SiteFK THEN 1 ELSE 0 END = 1)
				  group by PC1ID
						  ,HVCasePK
						  ,immunizations.ProgramFK
						  ,TCDOB
						  ,TargetChild
						  ,levelname) report

--select distinct
--	pc1id,
--	TargetChild,
--	TCDOB,
--	DATEDIFF(M, TCDOB, @rdate) TCAge,
--	TCMedicalPK,
--	IsDelayed,
--	NoImmunization,
--	(select COUNT(*)
--	from codeduebydates
--	inner join codeMedicalItem cmi
--	on ScheduledEvent = cmi.MedicalItemTitle
--	and MedicalItemCode <= 13
--	where dateadd(dd, dueby, tcdob) <= @rdate) ShotsRequired,
--	levelname
--from(
--select distinct
--	pc1id,
--	rtrim(tcfirstname) + ' ' + rtrim(tclastname) TargetChild,
--	hvcase.tcdob,
--	hvcase.hvcasepk, caseprogram.programfk,
--	null as TCItemDate,
--	0 IsDelayed,
--	0 TCMedicalPK,
--	case when TCID.NoImmunization = 0 or TCID.NoImmunization IS null then 0 else 1 end NoImmunization
--from caseprogram
--inner join hvcase
--on hvcasepk = caseprogram.hvcasefk
--inner join tcid
--on tcid.hvcasefk = hvcasepk
--and tcid.programfk = caseprogram.programfk
--inner join
--	(select EventDescription, Interval, DueBy, MedicalItemCode
--	from codeduebydates
--	inner join codeMedicalItem cmi
--	on ScheduledEvent = cmi.MedicalItemTitle
--	and MedicalItemCode <= 13) codeduebydates
--on codeduebydates.interval = DATEDIFF(M, dateadd(dd, -30.44, HVCase.TCDOB), @rdate)
--INNER JOIN dbo.SplitString(@programfk,',')
--ON caseprogram.programfk  = listitem
--where caseprogress >= 11
--and intakedate <= @rdate
--and (dischargedate is null)
--union
--select distinct
--	pc1id,
--	rtrim(tcfirstname) + ' ' + rtrim(tclastname) TargetChild,
--	hvcase.tcdob,
--	hvcase.hvcasepk, caseprogram.programfk,
--	TCItemDate,
--	IsDelayed,
--	TCMedical.TCMedicalPK,
--	case when TCID.NoImmunization = 0 or TCID.NoImmunization IS null then 0 else 1 end NoImmunization
--from caseprogram
--inner join hvcase
--on hvcasepk = caseprogram.hvcasefk
--inner join tcid
--on tcid.hvcasefk = hvcasepk
--and tcid.programfk = caseprogram.programfk
--inner join TCMedical
--on TCMedical.hvcasefk = hvcasepk
--and TCMedical.programfk = caseprogram.programfk
--and TCMedical.TCIDFK = TCID.TCIDPK
--and @rdate >= TCItemDate
--inner join codeMedicalItem cmi
--on MedicalItemCode = TCMedical.TCMedicalItem
--and MedicalItemCode <= 13
--INNER JOIN dbo.SplitString(@programfk,',')
--ON caseprogram.programfk  = listitem
--where caseprogress >= 11
--and intakedate <= @rdate
--and (dischargedate is null)) immunizations
--inner join (
--	select hvcasefk, programfk, MAX(HVlevelpk) HVlevelpk
--	from HVLevelDetail 
--	INNER JOIN dbo.SplitString(@programfk,',')
--	ON programfk  = listitem
--	where StartLevelDate <= @rdate
--	group by hvcasefk, programfk) hl2
--on hvcasepk = hl2.hvcasefk
--and immunizations.programfk = hl2.programfk
--inner join HVLevelDetail hl1
--on hl2.HVlevelpk = hl1.HVlevelpk
--where levelname <> 'Level X'
--order by PC1ID, TCDOB, TargetChild, levelname
GO
