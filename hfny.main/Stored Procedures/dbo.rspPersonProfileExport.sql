SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[rspPersonProfileExport] @ProgramFK VARCHAR(200) AS


DECLARE @tblCohort TABLE
(HVCasePK INT)

INSERT into @tblCohort

SELECT HVCasePK FROM dbo.HVCase hc

INNER JOIN dbo.CaseProgram cp ON cp.HVCaseFK = hc.HVCasePK
WHERE cp.ProgramFK = @ProgramFK





SELECT TOP(2500) PC1ID
,hc.ScreenDate as [Screen Date]
,hc.KempeDate as [Kempe Date]
,hc.IntakeDate as [Intake Date]
,CaseProgram.DischargeDate as [Discharge Date]
-- ,CurrentLevelFK
,cd.DischargeReason
,caseprogram.DischargeReasonSpecify
,cl.LevelName
,pc1.PCFirstName as [PC1 First Name]
,pc1.PCLastName as [PC1 Last Name]
,pc1.PCDOB as [PC1 DOB]
,pc1.Ethnicity as [PC1Ethnicity]
--passed empty string for specify since, specify is its own field
,dbo.fnGetRaceText(pc1.Race_AmericanIndian, pc1.Race_Asian, pc1.Race_Black, pc1.Race_Hawaiian, pc1.Race_White, pc1.Race_Other, '') as [PC1Race]
,pc1.RaceSpecify as [PC1Race Specify]
,cappgn.AppCodeText as [Gender]
,concat(pc1.PCStreet, ' ', pc1.PCApt, ' ', pc1.PCState) as [Address]
,pc1.PCZip as [Zip Code]
,pc1.PCPhone as [Phone]
,pc1.PCCellPhone as [Cell]
,pc1.PCEmail as [Email]
,cappms.AppCodeText as [Marital Status]
,pc1.BirthCountry as [Birth Country]
,pc1.YearsInUSA as [Years in US]
,capppl.AppCodeText as [Primary Language] 
,cainpc1.LanguageSpecify as [Language Specify]
,capphg.AppCodeText as [Highest Grade]
,cain.HoursPerMonth as [Monthly Employment Hours]
,cain.AvailableMonthlyIncome as [Monthly Income]
,case cain.PC1ReceivingMedicaid when '1' then 'Yes'
when '0' then 'No'
when 'U' then 'Unknown' end as [Receiving Medicaid]
,case cain.TANFServices when '1' then 'Yes'
when '0' then 'No' end as [TANF]
,case cain.PBFoodStamps when '1' then 'Yes'
when '0' then 'No' end as [Food Stamps]
,case cain.PBEmergencyAssistance when '1' then 'Yes'
when '0' then 'No'
when '9' then 'Unknown' end as [Emergency Assistance]
,case cain.PBWIC when '1' then 'Yes'
when '0' then 'No'
when '9' then 'Unknown'
when '9' then 'Unknown' end as [WIC] 
,case cain.PBSSI when '1' then 'Yes'
when '0' then 'No'
when '9' then 'Unknown' end as [SSI]
,cain.NumberInHouse as [People in Household]
,t.TCFirstName
,t.TCLastName
,t.TCDOB
,hc.TCNumber
,EDC
,obp.PCFirstName as [OBP First Name]
,obp.PCLastName as [OBP Last Name]
,obp.PCDOB as [OBP DOB]
,concat(obp.PCStreet, ' ', obp.PCApt, ' ', obp.PCState) as [OBP Address]
,obp.PCZip as [OBP Zip Code]
,obp.PCPhone as [OBP Phone]
,obp.PCCellPhone as [OBP Cell]
,obp.PCEmail as [OBP Email]
,obp.BirthCountry as [OBP Birth Country]
,obp.YearsInUSA as [OBP Years in US]
,obp.Ethnicity as [OBPEthnicity]
--passed empty string for specify since, specify is its own field
,dbo.fnGetRaceText(obp.Race_AmericanIndian, obp.Race_Asian, obp.Race_Black, obp.Race_Hawaiian, obp.Race_White, obp.Race_Other, '') as [OBPRace]
,obp.RaceSpecify as [OBPRace Specify]
,pc2.PCFirstName as [PC2 First Name]
,pc2.PCLastName as [PC2 Last Name]
,pc2.PCDOB as [PC2 DOB]
,concat(pc2.PCStreet, ' ', pc2.PCApt, ' ', pc2.PCState) as [PC2 Address]
,pc2.PCZip as [PC2 Zip Code]
,pc2.PCPhone as [PC2 Phone]
,pc2.PCCellPhone as [PC2 Cell]
,pc2.PCEmail as [PC2 Email]
,pc2.BirthCountry as [PC2 Birth Country]
,pc2.YearsInUSA as [PC2 Years in US]
,pc2.Ethnicity as [pc2Ethnicity]
--passed empty string for specify since, specify is its own field
,dbo.fnGetRaceText(pc2.Race_AmericanIndian, pc2.Race_Asian, pc2.Race_Black, pc2.Race_Hawaiian, pc2.Race_White, pc2.Race_Other, '') as [pc2Race]
,pc2.RaceSpecify as [pc2Race Specify]
from @tblCohort c
inner join CaseProgram on CaseProgram.HVCaseFK = c.HVCasePK
inner join HVCase hc on hc.HVCasePK = c.HVCasePK
inner join PC pc1 on pc1.PCPK = hc.PC1FK
left outer join PC pc2 on pc2.PCPK = hc.PC2FK
left outer join PC obp on obp.PCPK = hc.OBPFK
left outer join TCID t on t.HVCaseFK = c.HVCasePK
--left outer join pc pc2 on pc2.PCPK = hc.PC2FK
--left outer join pc obp on obp.PCPK = hc.OBPFK
left outer join CommonAttributes cakempe on cakempe.HVCaseFK = c.HVCasePK and cakempe.FormType = 'KE'
left outer join CommonAttributes cain on cain.HVCaseFK = c.HVCasePK and cain.FormType = 'IN'
left outer join CommonAttributes cainpc1 on cainpc1.HVCaseFK = c.HVCasePK and cainpc1.FormType = 'IN-PC1'
left outer join codeApp cappms on cappms.AppCodeGroup = 'MaritalStatus' and cappms.AppCode = cakempe.MaritalStatus
left outer join codeApp capppl on capppl.AppCodeGroup = 'PrimaryLanguage' and capppl.AppCode = cainpc1.PrimaryLanguage
left outer join codeApp capphg on capphg.AppCodeGroup = 'Education' and capphg.AppCode = cakempe.HighestGrade
left outer join codeApp cappgn on cappgn.AppCodeGroup = 'Gender' and cappgn.AppCode = pc1.Gender
left outer join codeApp cappgn2 on cappgn2.AppCodeGroup = 'Gender' and cappgn2.AppCode = pc2.Gender
left outer join codeApp cappgnobp on cappgnobp.AppCodeGroup = 'Gender' and cappgnobp.AppCode = obp.Gender
inner join codeLevel cl on cl.codeLevelPK = CaseProgram.CurrentLevelFK
left outer join codeDischarge cd on cd.DischargeCode=caseprogram.DischargeReason
order by pc1.PCLastName, pc1.PCFirstName, hc.ScreenDate
GO
