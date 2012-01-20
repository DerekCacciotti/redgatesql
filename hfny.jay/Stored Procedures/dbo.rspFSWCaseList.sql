
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[rspFSWCaseList](@programfk    varchar(max)    = null,
                                       @supervisorfk int             = null,
                                       @workerfk     int             = null
                                       )

as

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	declare @caselist table(
		pc1id varchar(13),
		codelevelpk int,
		levelname varchar(200),
		currentleveldate datetime,
		CaseWeight float,
		pcfirstname varchar(200),
		pclastname varchar(200),
		street varchar(200),
		pccity varchar(200),
		pcstate varchar(2),
		pczip varchar(200),
		pcphone varchar(200),
		tcfirstname varchar(200),
		tclastname varchar(200),
		tcdob datetime,
		edc datetime,
		worker varchar(200),
		supervisor varchar(200)
	)

	insert
		into @caselist
		select top 100 percent pc1id
							  ,codelevelpk
							  ,levelname
							  ,currentleveldate
							  ,CaseWeight
							  ,LTRIM(RTRIM(pc.pcfirstname))
							  ,LTRIM(RTRIM(pc.pclastname))
							  ,rtrim(pc.pcstreet)+case
													  when pcapt is null or pcapt = '' then
														  ''
													  else
														  ', Apt: '+rtrim(pcapt)
												  end as street
							  ,pc.pccity
							  ,pc.pcstate
							  ,pc.pczip
							  ,pc.pcphone+case
											  when pc.PCEmergencyPhone is not null and pc.PCEmergencyPhone <> '' then
												  ', EMR: '+pc.PCEmergencyPhone
											  else
												  ''
										  end as pcphone
							  ,LTRIM(RTRIM(tcid.tcfirstname))
							  ,LTRIM(RTRIM(tcid.tclastname))
							  ,hvcase.tcdob
							  ,hvcase.edc
							  ,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) worker
							  ,LTRIM(RTRIM(supervisor.firstname))+' '+LTRIM(RTRIM(supervisor.lastname)) supervisor
			from hvcase
				inner join caseprogram on caseprogram.hvcasefk = hvcasepk
				inner join workerassignment wa1 on wa1.hvcasefk = caseprogram.hvcasefk
						  and wa1.programfk = caseprogram.programfk
				left join kempe on kempe.hvcasefk = hvcasepk
				inner join codelevel on codelevelpk = currentlevelfk
				inner join pc on pc.pcpk = pc1fk
				left join tcid on tcid.hvcasefk = hvcasepk
				inner join worker fsw on CurrentFSWFK = fsw.workerpk
				inner join workerprogram on workerprogram.workerfk = fsw.workerpk
				inner join worker supervisor on supervisorfk = supervisor.workerpk
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where currentFSWFK = isnull(@workerfk,currentFSWFK)
				 and supervisorfk = isnull(@supervisorfk,supervisorfk)
				 and dischargedate is null
				 --AND kempedate IS NOT NULL 'Chris Papas removed 1/28/2011 This was screwing up because there is no kempe date in kempe table once PreAssessment was done, but before Kempe added
				 and casestartdate <= dateadd(dd,1,datediff(dd,0,GETDATE()))

	-- Get a distinct list after concatenating tcid's
	declare @caselist_distinct table(
		CaseWeight float,
		Enrolled_Cases int,
		Preintake_Cases int,
		pc1id varchar(13),
		currentlevel varchar(200),
		pcfirstname varchar(200),
		pclastname varchar(200),
		street varchar(200),
		pccity varchar(200),
		pcstate varchar(2),
		pczip varchar(200),
		pcphone varchar(200),
		TargetChild varchar(200),
		worker varchar(200),
		supervisor varchar(200)
	)

	insert
		into @caselist_distinct
		select distinct CaseWeight
					   ,(select count(distinct PC1ID)
							 from @caselist c2
							 where codelevelpk >= 12
								  and c2.worker = r1.worker) as Enrolled_Cases
					   ,(select count(distinct PC1ID)
							 from @caselist c2
							 where codelevelpk in (9,10)
								  and c2.worker = r1.worker) as Preintake_Cases
					   ,pc1id
					   ,RTRIM(levelname)+' ('+convert(varchar(12),currentleveldate,101)+')' currentlevel
					   ,pcfirstname
					   ,pclastname
					   ,street
					   ,pccity
					   ,pcstate
					   ,pczip
					   ,pcphone
					   ,case
							when tcdob is not null then
								-- concatenate tcid's and hvcase.tcdob
								substring((select distinct ', '+tcfirstname+' '+tclastname
											   from @caselist r2
											   where r1.pc1id = r2.pc1id
											   for xml path ('')),3,1000)+' ('+convert(varchar(12),tcdob,101)+')'
							else
								'EDC: ('+convert(varchar(12),edc,101)+')'
						end TargetChild
					   ,worker
					   ,supervisor
			from @caselist r1

	-- Final Query
	select @programfk programfk
		  ,@supervisorfk supervisorfk
		  ,@workerfk workerfk
		  ,(select isnull(sum(CaseWeight),0)
				from @caselist_distinct c2
				where c2.worker = r1.worker) as CaseWeight_ttl
		  ,Enrolled_Cases
		  ,Preintake_Cases
		  ,PC1ID
		  ,CurrentLevel
		  ,LTRIM(RTRIM(pcfirstname))+' '+LTRIM(RTRIM(pclastname)) as PC1
		  ,street
		  ,PCCity
		  ,PCState
		  ,PCZip
		  ,PCPhone
		  ,TargetChild
		  ,worker
		  ,Supervisor
		from @caselist_distinct r1
		order by supervisor
				,worker
				,pclastname
GO
