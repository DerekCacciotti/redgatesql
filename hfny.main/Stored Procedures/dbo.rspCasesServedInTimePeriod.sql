SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[rspCasesServedInTimePeriod] @StartDate DATETIME, @EndDate DATETIME, @SiteFK INT, @ProgramFK varchar(200),  @CaseFiltersPositive varchar(200) AS

if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @ProgramFK = replace(@ProgramFK,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK END

    set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
										else @CaseFiltersPositive
								   end;

--Parsons
--DECLARE @BeginOfMonth AS DATE = '01/01/2019'
--DECLARE @EndOfMonth AS DATE = '01/31/2019'
--DECLARE @BeginOfMonth AS DATE
--DECLARE @EndOfMonth AS DATE
--DECLARE @SiteFK INT
select HVCasePK
,PC1ID
, IntakeDate
, cp.DischargeDate
, p.PCFirstName 
, p.PCLastName 
, p.PCDOB 
--,MultipleBirth as 'Multiple Birth Total'
, case when MultipleBirth ='1' then 'Yes' 
when MultipleBirth ='0' then 'No'
else '' end as MultipleBirth
, t.TCDOB as 'TC DOB'
, EDC
, t.TCFirstName 
, t.TCLastName 
, w.FirstName as 'Worker First Name'
,LastName as 'Worker Last Name'
, ls.SiteName
from hvcase
inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
inner join dbo.SplitString(@ProgramFK,',') on cp.ProgramFK = listitem
inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
LEFT outer JOIN listSite ls on ls.listSitePK = wp.SiteFK
inner join PC p on p.PCPK = HVCase.PC1FK
left outer join TCID t on t.HVCaseFK = HVCase.HVCasePK
inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK =cp.HVCaseFK
where 
		 IntakeDate is not null
		--for August 1 2016
		and IntakeDate <=@EndDate
		and (cp.DischargeDate is null or cp.DischargeDate>=@StartDate)
		--and (ls.SiteName='Parsons Cohoes Site' or ls.SiteName='Parsons Albany Site ')
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
order by [Worker Last Name], [Worker First Name], cp.PC1ID
GO
