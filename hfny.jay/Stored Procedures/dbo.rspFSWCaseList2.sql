SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- [rspFSWCaseList2] 19,null,null


CREATE procedure [dbo].[rspFSWCaseList2](@programfk    varchar(max)    = null,
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
		pccsz varchar(200),
		pcphone varchar(200),
		tcfirstname varchar(200),
		tclastname varchar(200),
		tcdob datetime,
		edc datetime,
		worker varchar(200),
		workerlast varchar(200),
		supervisor varchar(200)
	)

	
	
;	
	-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 	
	with cteGetInitRequiredData
			as (
				
				SELECT 
				cp.hvcasefk,cp.programfk,h.hvcasepk,cp.currentlevelfk,h.tcdob,h.edc,cp.currentleveldate,cp.pc1id,h.pc1fk,
			  LTRIM(RTRIM(w.firstname))+' '+LTRIM(RTRIM(w.lastname)) as worker		
			 ,LTRIM(RTRIM(w.lastname))+' '+LTRIM(RTRIM(w.firstname)) as workerlast	
			  ,LTRIM(RTRIM(sup.firstname))+' '+LTRIM(RTRIM(sup.lastname)) as supervisor	
				 
				FROM HVCase h 
				INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
				INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
				inner join workerprogram wp on wp.workerfk = w.workerpk
				INNER JOIN Worker sup on sup.WorkerPK = SupervisorFK	
				inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
				
			where cp.currentFSWFK = isnull(@workerfk,currentFSWFK)
				 --and supervisorfk = isnull(@supervisorfk,supervisorfk)
				 and cp.dischargedate is null
				 --AND kempedate IS NOT NULL 'Chris Papas removed 1/28/2011 This was screwing up because there is no kempe date in kempe table once PreAssessment was done, but before Kempe added
				 and casestartdate <= dateadd(dd,1,datediff(dd,0,GETDATE()))				
				
					
				
			)	
	
--Select * from cteGetInitRequiredData
-- [rspFSWCaseList2] 19,null,null
-- [rspFSWCaseList] 19,null,null

	insert
		into @caselist
		select top 100 percent mainCTE.pc1id
							  ,codelevelpk
							  ,levelname
							  ,mainCTE.currentleveldate
							  ,CaseWeight
							  ,LTRIM(RTRIM(pc.pcfirstname))
							  ,LTRIM(RTRIM(pc.pclastname))
							  ,rtrim(pc.pcstreet)+case
													  when pcapt is null or pcapt = '' then
														  ''
													  else
														  ', Apt: '+rtrim(pcapt)
												  end as street
							  ,rtrim(pc.pccity) + ', ' + pc.pcstate + ' ' + pc.pczip as pccsz
							  ,pc.pcphone+case
											  when pc.PCEmergencyPhone is not null and pc.PCEmergencyPhone <> '' then
												  ', EMR: '+pc.PCEmergencyPhone
											  else
												  ''
										  end as pcphone
							  ,LTRIM(RTRIM(tcid.tcfirstname))
							  ,LTRIM(RTRIM(tcid.tclastname))
							  ,mainCTE.tcdob
							  ,mainCTE.edc
							  ,mainCTE.worker
							  ,mainCTE.workerlast
							  ,mainCTE.supervisor

	
			from cteGetInitRequiredData mainCTE
				--inner join workerassignment wa1 on wa1.hvcasefk = mainCTE.hvcasefk
				--		  and wa1.programfk = mainCTE.programfk
				left join kempe on kempe.hvcasefk = mainCTE.hvcasepk
				inner join codelevel on codelevelpk = mainCTE.currentlevelfk
				inner join pc on pc.pcpk = mainCTE.pc1fk
				left join tcid on tcid.hvcasefk = mainCTE.hvcasepk


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
		pccsz varchar(200),
		pcphone varchar(200),
		TargetChild varchar(200),
		worker varchar(200),
		workerlast varchar(200),
		supervisor varchar(200)
	)

	insert
		into @caselist_distinct
		select distinct CaseWeight
					   ,(select count(distinct PC1ID)
							 from @caselist c2
							 where codelevelpk >= 10
								  and c2.worker = r1.worker) as Enrolled_Cases
					   ,(select count(distinct PC1ID)
							 from @caselist c2
							 where codelevelpk in (7,8,9)
								  and c2.worker = r1.worker) as Preintake_Cases
					   ,pc1id
					   ,RTRIM(levelname)+' ('+convert(varchar(12),currentleveldate,101)+')' currentlevel
					   ,pcfirstname
					   ,pclastname
					   ,street
					   ,pccsz
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
					   ,workerlast
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
		  ,PCCSZ
		  ,PCPhone
		  ,TargetChild
		  ,worker
		  ,workerlast
		  ,Supervisor
		from @caselist_distinct r1
		order by supervisor
				,workerlast
				,pc1id
GO
