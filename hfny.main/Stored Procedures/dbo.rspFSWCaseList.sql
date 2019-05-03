SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Edit date: 5/10/17 Benjamin Simmons  -- Added average PC1 Kempe score and individual kempe score to report
										-- and included PCGender so that the proper kempe score is used

-- Edit Date 5/3/19 Derek C. --Added Phone Numbers for Pc2, OBP and Emergency Contact


CREATE procedure [dbo].[rspFSWCaseList](@programfk    varchar(max)    = null,
                                       @supervisorfk int             = null,
                                       @workerfk     int             = null
                                       )

as

--DECLARE @programfk    varchar(max)    = '1'
--DECLARE @supervisorfk int             = null
--DECLARE @workerfk     int             = null

	IF @programfk IS NULL
	BEGIN
		SELECT @programfk = substring((
			SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
			FROM HVProgram
			FOR XML PATH ('')
		), 2, 8000)
	END

	SET @programfk = REPLACE(@programfk, '"', '')

	DECLARE @caselist TABLE(
		pc1id VARCHAR(13),
		codelevelpk INT,
		levelname VARCHAR(MAX),
		levelabbr VARCHAR(10),
		levelgroup VARCHAR(MAX),
		currentleveldate DATETIME,
		CaseWeight FLOAT,
		pcfirstname VARCHAR(200),
		pclastname VARCHAR(200),
		pcGender char(2),
		pc1KempeScore int,
		street VARCHAR(200),
		pccsz VARCHAR(200),
		pcphone VARCHAR(MAX),
		pc2phone VARCHAR(max),
		obpphone varchar(MAX),
		ecphone VARCHAR(max),
		tcfirstname VARCHAR(200),
		tclastname VARCHAR(200),
		tcdob DATETIME,
		edc DATETIME,
		worker VARCHAR(200),
		workerlast VARCHAR(200),
		supervisor VARCHAR(200)
	)

	INSERT INTO @caselist
		SELECT TOP 100 PERCENT
			pc1id
			,codelevelpk
			,levelname
			,levelabbr
			,levelgroup
			,currentleveldate
			,CaseWeight
			,LTRIM(RTRIM(pc.pcfirstname))
			,LTRIM(RTRIM(pc.pclastname))
			,pc.Gender
			,(case
				when pc.Gender = '01' then
					cast(kempe.MomScore as int)
				when pc.Gender = '02' then
					cast(kempe.DadScore as int)
				when pc.Gender = '03' then
					cast(kempe.PartnerScore as int)
				else
					null
				end) as pcScore
			,rtrim(pc.pcstreet) + CASE
				WHEN pc.PCApt IS NULL OR pc.PCApt = '' THEN
					''
				ELSE
					', Apt: ' + RTRIM(pc.pcapt)
			END AS street
			,RTRIM(pc.pccity) + ', ' + pc.pcstate + ' ' + pc.pczip AS pccsz
			,'PC1 Primary: '+ CASE
				WHEN pc.pcphone IS NOT NULL AND pc.pcphone <> '' THEN
					pc.pcphone + ','
				ELSE
					'(None)'
			END + CASE
				WHEN pc.PCEmergencyPhone IS NOT NULL AND pc.PCEmergencyPhone <> '' THEN
					', PC1 Emergency: ' + pc.PCEmergencyPhone + ','
				ELSE
					''
			END + CASE
				WHEN pc.PCCellPhone IS NOT NULL AND pc.PCCellPhone <> '' THEN
					' PC1 Cell: ' + pc.PCCellPhone
				ELSE
					''
			END AS pcphone,


			-- pc2 phone 
			 CASE
			WHEN   pc2.PCPhone IS NOT NULL AND pc2.PCPhone <> '' THEN  ' PC2 Primary:' +  pc2.PCPhone + ','
			ELSE
            ''
			END + CASE
			WHEN pc2.PCCellPhone IS NOT NULL AND pc2.PCCellPhone <> '' THEN
            ' PC2 Cell: ' + pc2.PCCellPhone + ','
			ELSE
            ''
			END AS pc2phone,

			-- emergency contact phone
			 CASE 
			WHEN  ec.PCPhone IS NOT NULL AND ec.PCPhone <> '' THEN ' Emergency Contact Primary:' + ec.PCPhone + ','
			ELSE
            ''
			END + CASE
			WHEN ec.PCCellPhone IS NOT NULL AND ec.PCCellPhone <> '' THEN
           ' Emergency Contact Cell: ' + ec.PCCellPhone + ','
			ELSE
            ''
			END AS ecphone,


			-- obp contact phone
			CASE 
			WHEN  obp.PCPhone IS NOT NULL AND ec.PCPhone <> '' THEN 'OBP Primary:' +  obp.PCPhone + ','
			ELSE
            ''
			END + CASE
			WHEN obp.PCCellPhone IS NOT NULL AND obp.PCCellPhone <> '' THEN
            'OBP Cell: ' + obp.PCCellPhone
			ELSE
            ''
			END AS obpphone



			




		

		
			,LTRIM(RTRIM(tcid.tcfirstname))
			,LTRIM(RTRIM(tcid.tclastname))
			,hvcase.tcdob
			,hvcase.edc
			,LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) AS worker
			,LTRIM(RTRIM(fsw.lastname)) + ', ' + LTRIM(RTRIM(fsw.firstname)) AS workerlast
			,LTRIM(RTRIM(supervisor.firstname)) + ' ' + LTRIM(RTRIM(supervisor.lastname)) AS supervisor
		FROM
			hvcase
			INNER JOIN caseprogram ON caseprogram.hvcasefk = hvcasepk
			INNER JOIN workerassignment wa1 ON wa1.hvcasefk = caseprogram.hvcasefk
				AND wa1.programfk = caseprogram.programfk
			LEFT JOIN kempe	ON kempe.hvcasefk = hvcasepk
			INNER JOIN codelevel ON codelevelpk = currentlevelfk
			INNER JOIN pc ON pc.pcpk = pc1fk
			LEFT OUTER  JOIN pc pc2 ON pc2.PCPK = HVCase.PC2FK
			LEFT OUTER JOIN pc obp ON obp.PCPK = HVCase.OBPFK
			LEFT OUTER JOIN pc ec ON ec.PCPK = HVCase.CPFK
			LEFT JOIN tcid ON tcid.hvcasefk = hvcasepk AND TCID.TCDOD IS NULL
			INNER JOIN worker fsw ON CurrentFSWFK = fsw.workerpk
			INNER JOIN workerprogram ON workerprogram.workerfk = fsw.workerpk AND workerprogram.programfk = caseprogram.programfk
			INNER JOIN worker supervisor ON supervisorfk = supervisor.workerpk
			INNER JOIN dbo.SplitString(@programfk,',') ON caseprogram.programfk = listitem
		WHERE
			currentFSWFK = ISNULL(@workerfk,currentFSWFK)
			AND supervisorfk = isnull(@supervisorfk,supervisorfk)
			AND dischargedate IS NULL
			--AND kempedate IS NOT NULL 'Chris Papas removed 1/28/2011 This was screwing up because there is no kempe date in kempe table once PreAssessment was done, but before Kempe added
			and casestartdate <= DATEADD(dd, 1, DATEDIFF(dd, 0, GETDATE()))

	-- Get a distinct list after concatenating tcid's
	DECLARE @caselist_distinct TABLE(
		CaseWeight FLOAT,
		Enrolled_Cases INT,
		Preintake_Cases INT,
		pc1id VARCHAR(13),
		levelname VARCHAR(MAX),
		levelabbr VARCHAR(10),
		levelgroup VARCHAR(MAX),
		currentleveldate DATE,
		pcfirstname VARCHAR(200),
		pclastname VARCHAR(200),
		pcGender char(2),
		pc1KempeScore int,
		street VARCHAR(200),
		pccsz VARCHAR(200),
		pcphone VARCHAR(200),
		pc2phone VARCHAR(200),
		ecphone VARCHAR(200), 
		obpphone VARCHAR(200),
		TargetChild VARCHAR(MAX),
		TargetChildDOB VARCHAR(MAX),
		worker VARCHAR(200),
		workerlast VARCHAR(200),
		supervisor VARCHAR(200)
	)

	INSERT INTO @caselist_distinct
		SELECT DISTINCT
			CaseWeight
			,(
				SELECT
					COUNT(DISTINCT PC1ID)
				FROM
					@caselist c2
				WHERE
					codelevelpk >= 10
					AND c2.worker = r1.worker
			) AS Enrolled_Cases
			,(
				SELECT
					COUNT(DISTINCT PC1ID)
				FROM
					@caselist c2
				WHERE
					codelevelpk IN (7,8,9)
					AND c2.worker = r1.worker
			) AS Preintake_Cases
			,pc1id
			,levelname
			,levelabbr
			,levelgroup
			,currentleveldate
			,pcfirstname
			,pclastname
			,pcGender
			,pc1KempeScore
			,street
			,pccsz
			,pcphone,
			r1.pc2phone,
			r1.ecphone,
			r1.obpphone
			,CASE
				WHEN tcdob IS NOT NULL THEN
					SUBSTRING((
						SELECT DISTINCT
							', ' + tcfirstname + ' '+ tclastname
						FROM
							@caselist r2
						WHERE
							r1.pc1id = r2.pc1id
						FOR XML PATH ('')
					),3,1000)
				ELSE
					''
			END AS TargetChild
			,CASE
				WHEN tcdob IS NOT NULL THEN
					'DOB: (' + CONVERT(VARCHAR(12), tcdob, 101) + ')'
				ELSE
					'EDC: (' + CONVERT(VARCHAR(12), edc, 101) + ')'
			END AS TargetChildDOB
			,worker
			,workerlast
			,supervisor
		FROM
			@caselist r1

	-- Final Query
	SELECT
		@programfk programfk
		,@supervisorfk supervisorfk
		,@workerfk workerfk
		,(
			SELECT
				ISNULL(SUM(CaseWeight), 0)
			FROM
				@caselist_distinct c2
			WHERE
				c2.worker = r1.worker
		) AS CaseWeight_ttl
		,(
			select
				isnull(avg(pc1KempeScore), 0)
			from
				@caselist_distinct c2
			where
				c2.worker = r1.worker
		) as pc1KempeScore_average
		,pc1KempeScore
		,Enrolled_Cases
		,Preintake_Cases
		,PC1ID
		,CASE
			WHEN levelgroup = 'SUB' THEN
				'Level ' + levelabbr
			ELSE 
				levelname
		END AS 'CurrentLevelName'
		,'(' + CONVERT(VARCHAR(12), currentleveldate, 101) + ')' AS 'CurrentLevelDate'
		,LTRIM(RTRIM(pcfirstname)) + ' ' + LTRIM(RTRIM(pclastname)) AS PC1
		,street
		,PCCSZ
		,PCPhone,
	CASE WHEN	dbo.IsNullOrEmpty(r1.pc2phone) = 1 THEN NULL
	ELSE
	r1.pc2phone
	END AS pc2phone,
		CASE when dbo.IsNullOrEmpty(r1.ecphone) = 1 THEN NULL
		ELSE
        r1.ecphone
		END AS ecphone,
		CASE WHEN dbo.IsNullOrEmpty(r1.obpphone) = 1 THEN NULL
		ELSE
        r1.obpphone
		END AS obpphone
		,TargetChild
		,TargetChildDOB
		,worker
		,workerlast
		,Supervisor
	FROM
		@caselist_distinct r1
	ORDER BY
		supervisor
		,workerlast
		,pc1id
GO
