SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Search PC1Id's given programfk and caseprogress ... Khalsa
-- exec spSearchCasesKhalsa null,null,null, null,null,null,null,null,null,1,9
-- exec spSearchCasesKhalsa null,null,null, null,null,null,null,null,null,null,4
create procedure [dbo].[spSearchCasesKhalsa]
(
    @PC1ID       varchar(13)    = null,
    @PCPK        int            = null,
    @PCFirstName varchar(20)    = null,
    @PCLastName  varchar(30)    = null,
    @PCDOB       datetime       = null,
    @TCFirstName varchar(20)    = null,
    @TCLastName  varchar(30)    = null,
    @TCDOB       datetime       = null,
    @WorkerPK    int            = null,
    @ProgramFK   int            = NULL,
    @CurrentLevel  NUMERIC      = null
)

as

	set nocount on;
	-- Rewrote this store proc to make it compatible with SQL 2008.
	with results (hvcasepk	
					,pcpk
					,PC1ID
					,pcfirstname
					,pclastname
					,pcdob
					,tcfirstname
					,tclastname
					,tcdob
					,workerlastname
					,workerfirstname
					,intakedate
					,dischargedate
					,currentCaseProgress
					,caseprogress
					,casehasobp
					,casehaspc2
					,levelname
					,WorkerPK
					,programfk
					)
	as
	(

	select hvcasepk
		  ,pc.pcpk
		  ,PC1ID
		  ,pc.pcfirstname
		  ,pc.pclastname
		  ,pc.pcdob
		  ,rtrim(tcid.tcfirstname)
		  ,rtrim(tcid.tclastname)
		  ,hv.tcdob
		  ,rtrim(worker.lastname) as workerlastname
		  ,rtrim(worker.firstname) as workerfirstname
		  ,IntakeDate
		  ,DischargeDate
		  ,CaseProgress AS currentCaseProgress
		  ,rtrim(cast(CaseProgress as char(4)))+'-'+ccp.CaseProgressBrief as CaseProgress
		  ,case when obpfk is not null then 'Yes' else 'No' end as CaseHasOBP
		  ,case when PC2FK is not null then 'Yes' else 'No' end as CaseHasPC2
		  ,cdlvl.levelname
		  ,WorkerPK
		  ,cp.ProgramFK 
		  
		from fnTableCaseProgram(@ProgramFK) cp -- Note: fnTableCaseProgram is like a parameterised view ... Khalsa
			inner join codeLevel cdlvl on cdlvl.codeLevelPK = cp.CurrentLevelFK
			inner join hvcase hv on cp.hvcasefk = hv.hvcasepk
			inner join pc on hv.pc1fk = pc.pcpk
			inner join codeCaseProgress ccp on hv.CaseProgress = ccp.CaseProgressCode
			left join tcid on tcid.hvcasefk = hv.hvcasepk
			left join Workerprogram wp on wp.workerfk = isnull(currentfswfk,currentfawfk) --IN(currentfswfk, currentfawfk)
					 and wp.programfk = cp.programfk
			left join worker on workerpk = workerfk
		where (pc1id like '%'+@PC1ID+'%'
			 or pcpk = @PCPK
			 or pc.pcfirstname like @PCFirstName+'%'
			 or pc.pclastname like @PCLastName+'%'
			 or pc.pcdob = @PCDOB
			 or tcid.tcfirstname like @TCFirstName+'%'
			 or tcid.tclastname like @TCLastName+'%'
			 or hv.tcdob = @TCDOB
			 or workerpk = @WorkerPK
			 OR CaseProgress = @CurrentLevel
			 )

	)

	select distinct top 100 hvcasepk
						   ,pcpk
						   ,PC1ID
						   ,pcfirstname+' '+pclastname as PC1
						   ,pcdob
						   ,tc = substring((select ', '+tcfirstname+' '+tclastname
												from results r2
												where r1.pc1id = r2.pc1id
												for xml path ('')),3,1000)
						   ,tcdob
						   ,workerfirstname+' '+workerlastname as worker
						   ,dischargedate
						   ,intakedate
						   ,currentCaseProgress
						   ,caseprogress
						   ,casehasobp
						   ,casehaspc2
						   ,levelname
						   ,case
								when dischargedate is null then 0
								else 1
							end

						   ,(
							case
								when pc1id = @PC1ID then 1
								else 0
							end+
							case
								when pcpk = @PCPK then 1
								else 0
							end+
							case
								when r1.pcfirstname like @PCFirstName+'%' then 1
								else 0
							end+
							case
								when r1.pclastname like @PCLastName+'%' then 1
								else 0
							end+
							case
								when r1.pcdob = @PCDOB then 1
								else 0
							end+
							case
								when r1.tcfirstname like @TCFirstName+'%' then 1
								else 0
							end+
							case
								when r1.tclastname like @TCLastName+'%' then 1
								else 0
							end+
							case
								when r1.tcdob = @TCDOB then 1
								else 0
							end+
							case
								when workerpk = @WorkerPK then 1
								else 0
							end) as SCORE4ORDERINGROWS
						, programfk 

		from results r1
		order by
				case
					when dischargedate is null then 0
					else 1
				end
			   ,SCORE4ORDERINGROWS desc
			   ,PC1ID
			   


-- exec spSearchCasesKhalsa null,null,a
GO
