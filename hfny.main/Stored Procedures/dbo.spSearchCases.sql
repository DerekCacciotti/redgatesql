SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--Edited On: 4-5-2017
--Edited by Chris Papas - removed function and removed the XML inner join to speed up search

-- 'AD85030196603'
-- exec spSearchCases null,null,'Allison','Dough'
CREATE procedure [dbo].[spSearchCases] (@PC1ID varchar(13) = null
									 , @PCPK int = null
									 , @PCFirstName varchar(20) = null
									 , @PCLastName varchar(30) = null
									 , @PCDOB datetime = null
									 , @TCFirstName varchar(20) = null
									 , @TCLastName varchar(30) = null
									 , @TCDOB datetime = null
									 , @WorkerPK int = null
									 , @ProgramFK int = null
									 , @HVCasePK int = NULL
                                     ,@PCPhone CHAR(12) = NULL)
									 as



DECLARE @SearchResults TABLE
(HVCaseFK INT,
PC1ID VARCHAR(13),
PC1PK INT,
PCName VARCHAR(MAX),
PCOldName VARCHAR(max),
PCOldName2 VARCHAR(max),
PCDOB DATETIME, 
TCName VARCHAR(max),
TCDOB DATETIME,
WorkerFK INT,
WorkerName VARCHAR(max),
IntakeDate datetime,
Dischargedate DATETIME, 
CaseProgressBreif VARCHAR(max),
LevelPK INT,
LevelName VARCHAR(max),
HasOBP BIT,
HasPC2 BIT,
HasDischarageDate BIT,
HasIntakeDate BIT)


INSERT INTO @SearchResults
(	HVCaseFK,
    PC1ID,
    PC1PK,
	PCName,
    PCOldName,
    PCOldName2,
    PCDOB,
    TCName,
    TCDOB,
    WorkerFK,
    WorkerName,
    IntakeDate,
    Dischargedate,
	CaseProgressBreif,
    LevelPK,
    LevelName,
    HasOBP,
    HasPC2,
    HasDischarageDate,
    HasIntakeDate
)
SELECT hc.HVCasePK,cp.PC1ID,p.PCPK, CONCAT(LTRIM(RTRIM(p.PCFirstName)), ' ', LTRIM(RTRIM(p.PCLastName))),p.PCOldName,p.PCOldName2, p.PCDOB, 
CONCAT(LTRIM(RTRIM(t.TCFirstName)), ' ', LTRIM(RTRIM((t.TCLastName)))), hc.TCDOB, 
w.WorkerPK, CONCAT(LTRIM(RTRIM(w.FirstName)), ' ', LTRIM(RTRIM(w.LastName))), 
hc.IntakeDate, cp.DischargeDate,  CAST(hc.CaseProgress AS VARCHAR(MAX)) + '-' + ccp.CaseProgressBrief, 
cl.codeLevelPK, cl.LevelName, CASE WHEN hc.OBPFK IS NOT NULL THEN 1 ELSE 0 END,
CASE WHEN hc.PC2FK IS NOT NULL THEN 1 ELSE 0 END,
CASE WHEN cp.DischargeDate IS NOT NULL THEN 1 ELSE 0 END,
CASE WHEN hc.IntakeDate IS NOT NULL THEN 1 ELSE 0 END
  from		CaseProgram cp WITH (NOLOCK) 
				  inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
				  inner join HVCase hc on cp.HVCaseFK = hc.HVCasePK
				  inner join PC  p ON hc.PC1FK = p.PCPK
				  inner join codeCaseProgress ccp on hc.CaseProgress = ccp.CaseProgressCode
				  left join TCID t on t.HVCaseFK = hc.HVCasePK
				  left join WorkerProgram wp on wp.WorkerFK = isnull(CurrentFSWFK, CurrentFAWFK) --IN(currentfswfk, currentfawfk)
												and wp.ProgramFK = cp.ProgramFK
				  left join Worker w on WorkerPK = WorkerFK
				  where		(PC1ID like '%' + @PC1ID + '%'
							 or PCPK = @PCPK
							 or P.PCFirstName like @PCFirstName + '%'
							 or P.PCOldName like @PCFirstName + '%'
							 or P.PCOldName2 like @PCFirstName + '%'
							 or P.PCLastName like @PCLastName + '%'
							 or P.PCOldName like '%' + @PCLastName
							 or P.PCOldName2 like '%' + @PCLastName
							 or P.PCDOB = @PCDOB
							 or t.TCFirstName like @TCFirstName + '%'
							 or t.TCLastName like @TCLastName + '%'
							 or hc.TCDOB = @TCDOB
							 or WorkerPK = @WorkerPK
							 or HVCasePK = @HVCasePK
							 OR PCPhone = @PCPhone
							 OR PCCellPhone = @PCPhone
							 OR PCEmergencyPhone = @PCPhone
							)
							and cp.ProgramFK = isnull(@ProgramFK, cp.ProgramFK)


SELECT TOP 100 * FROM @SearchResults sr ORDER BY sr.HasDischarageDate ASC, sr.PC1ID

--as
--	set nocount on;
	
--		;with cteresults as (
	
--			select HVCasePK
--						  , PC.PCPK
--						  , PC1ID
--						  , PC.PCFirstName
--						  , PC.PCLastName
--						  , PC.PCOldName
--						  , PC.PCOldName2
--						  , PC.PCDOB
--						  , rtrim(TCID.TCFirstName) as TCFirstName
--						  , rtrim(TCID.TCLastName) as TCLastName
--						  , hv.TCDOB
--						  , rtrim(Worker.LastName) as workerlastname
--						  , rtrim(Worker.FirstName) as workerfirstname
--						  , IntakeDate
--						  , DischargeDate
--						  , rtrim(cast(CaseProgress as char(4))) + '-' + ccp.CaseProgressBrief as CaseProgress
--						  , case when OBPFK is not null then 'Yes'
--								 else 'No'
--							end as CaseHasOBP
--						  , case when PC2FK is not null then 'Yes'
--								 else 'No'
--							end as CaseHasPC2
--						  , cdlvl.LevelName
--						  , WorkerPK
--				  from		CaseProgram cp WITH (NOLOCK) --no reason to lock since we're just searching
--				  inner join codeLevel cdlvl on cdlvl.codeLevelPK = cp.CurrentLevelFK
--				  inner join HVCase hv on cp.HVCaseFK = hv.HVCasePK
--				  inner join PC on hv.PC1FK = PC.PCPK
--				  inner join codeCaseProgress ccp on hv.CaseProgress = ccp.CaseProgressCode
--				  left join TCID on TCID.HVCaseFK = hv.HVCasePK
--				  left join WorkerProgram wp on wp.WorkerFK = isnull(CurrentFSWFK, CurrentFAWFK) --IN(currentfswfk, currentfawfk)
--												and wp.ProgramFK = cp.ProgramFK
--				  left join Worker on WorkerPK = WorkerFK
--				  where		(PC1ID like '%' + @PC1ID + '%'
--							 or PCPK = @PCPK
--							 or PC.PCFirstName like @PCFirstName + '%'
--							 or PC.PCOldName like @PCFirstName + '%'
--							 or PC.PCOldName2 like @PCFirstName + '%'
--							 or PC.PCLastName like @PCLastName + '%'
--							 or PC.PCOldName like '%' + @PCLastName
--							 or PC.PCOldName2 like '%' + @PCLastName
--							 or PC.PCDOB = @PCDOB
--							 or TCID.TCFirstName like @TCFirstName + '%'
--							 or TCID.TCLastName like @TCLastName + '%'
--							 or hv.TCDOB = @TCDOB
--							 or WorkerPK = @WorkerPK
--							 or HVCasePK = @HVCasePK
--							 OR PCPhone = @PCPhone
--							 OR PCCellPhone = @PCPhone
--							 OR PCEmergencyPhone = @PCPhone
--							)
--							and cp.ProgramFK = isnull(@ProgramFK, cp.ProgramFK)
--				 )
--		select distinct	top 100 
--				hvcasepk
--			  , pcpk
--			  , PC1ID
--			  , pcfirstname + ' ' + pclastname as PC1
--			  , pcOldName
--			  , pcOldName2 
--			  , FORMAT(cteresults.PCDOB, 'MM/dd/yy') AS pcdob
--			  , tc = tcfirstname + ' ' + tclastname
--			  , FORMAT(cteresults.TCDOB, 'MM/dd/yy') AS tcdob
--			  , workerfirstname + ' ' + workerlastname as worker
--			  , FORMAT(cteresults.DischargeDate, 'MM/dd/yy') AS dischargedate
--			  , FORMAT(cteresults.IntakeDate,'MM/dd/yy') AS intakedate
--			  , caseprogress
--			  , casehasobp
--			  , casehaspc2
--			  , levelname
--			  , case when dischargedate is null then 0
--					else 1
--				END as HasDischargedate
--			  , (case when PC1ID = @PC1ID then 1
--						else 0
--					end + 
--				 case	when pcpk = @PCPK then 1
--						else 0
--					end + 
--				case when pcfirstname like @PCFirstName + '%' then 1
--					else 0
--				end + 
--				case when pclastname like @PCLastName + '%' then 1
--					else 0
--				end + 
--				case when pcOldName like @PCFirstName + '%' then 1
--					else 0
--				end + 
--				case when pcOldName2 like @PCFirstName + '%' then 1
--					else 0
--				end + 
--				case when pcOldName like '%' + @PCLastName then 1
--					else 0
--				end + 
--				case when pcOldName2 like '%' + @PCLastName then 1
--					else 0
--				end + 
--				case when pcdob = @PCDOB then 1
--					else 0
--				end + 
--				case when tcfirstname like @TCFirstName + '%' then 1
--					else 0
--				end + 
--				case when tclastname like @TCLastName + '%' then 1
--					else 0
--				end + 
--				case when tcdob = @TCDOB then 1
--					else 0
--				end + 
--				case when WorkerPK = @WorkerPK then 1
--					  else 0
--				end + 
--				case when HVCasePK = @HVCasePK then 1
--					  else 0
--				end) as Score4OrderingRows
--		from	cteresults
--		order by case when dischargedate is null then 0
--					  else 1
--				 end
--			  , Score4OrderingRows desc
--			  , PC1ID;
GO
