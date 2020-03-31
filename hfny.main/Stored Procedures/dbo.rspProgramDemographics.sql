SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/18/2010
-- Description:	FAW Monthly Report
-- exec rspProgramDemographics @programfk2 = 18, @startdt2 = N'12/01/11', @enddt2 = N'11/30/12', @SiteFK2 = 21 
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
-- Edited by Benjamin Simmons
-- Edit Date: 8/17/17
-- Edit Reason: Optimized report so that it works better on Azure
-- Edit date: <03/31/2020>
-- Editor: <Bill O'Brien>
-- Edit Reason: Update to use new Race fields
-- =============================================
CREATE procedure [dbo].[rspProgramDemographics]
    --@programfk2 int = null,
    @programfk varchar(250)    = null,
    @startdt   date,
    @enddt    date,
    @SiteFK    int = 0, 
    @casefilterspositive varchar(100) = ''

	WITH RECOMPILE
as

	DECLARE @programfk2 INT = @programfk
	DECLARE @startdt2 DATETIME = @startdt
	DECLARE @enddt2 DATETIME = @enddt
	DECLARE @SiteFK2 INT = @SiteFK
	DECLARE @casefilterspositive2 VARCHAR(100) = @casefilterspositive

    if @programfk2 is null
	begin
		select @programfk2 = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk2 = replace(@programfk2,'"','')
	set @SiteFK2 = case when dbo.IsNullOrEmpty(@SiteFK2) = 1 then 0 else @SiteFK2 end;
	set @casefilterspositive2 = case	when @casefilterspositive2 = '' then null
									else @casefilterspositive2
							   end
	
	declare @MotherWithOtherChildren table (
		[PD08MotherWithOtherChild] int
	)
	insert into @MotherWithOtherChildren
	select count(distinct a.HVCasePK) 
			from
				dbo.HVCase as a 
				join dbo.CaseProgram as b on a.HVCasePK = b.HVCaseFK
				join PC as c on c.PCPK = a.PC1FK 
				join Intake as d on d.HVCaseFK = a.HVCasePK
				join OtherChild as oc on oc.FormFK = d.IntakePK and oc.FormType = 'IN' and oc.Relation2PC1 = '01'
				inner join worker fsw on b.CurrentFSWFK = fsw.workerpk
				inner join workerprogram wp on wp.workerfk = fsw.workerpk
				inner join dbo.SplitString(@programfk2,',') on b.programfk = listitem
				inner join dbo.udfCaseFilters(@casefilterspositive2, '', @programfk2) cf on cf.HVCaseFK = a.HVCasePK
			where
				 (b.DischargeDate is null
				 or b.DischargeDate >= @startdt2)
				 and a.IntakeDate <= @enddt2
				 --and b.ProgramFK = @programfk2
				 and (case when @SiteFK2 = 0 then 1 when wp.SiteFK = @SiteFK2 then 1 else 0 end = 1)
	

						 
	declare @x table (
		HVCasePK int
		, Race_AmericanIndian BIT
		, Race_Asian BIT
		, Race_Black BIT
		, Race_Hawaiian BIT
		, Race_Hispanic BIT
		, Race_Other BIT
		, Race_White BIT
		, [Age] int
		, [yrEnrolled] int
		, [Edu] char(2)
		, [pc1Employed] char(1)
		, [pc2Employed] char(1)
		, [obpEmployed] char(1)
		, [obpTrainingProgram] char(1)
		, [OBPInHousehold] char(1)
		, [pc1TrainingProgram] char(1)
		, [pc2TrainingProgram] char(1)
		, [pc1Medicaid] char(1)
		, [FoodStamps] char(1)
		, [TANF] char(1)
		, [WIC] char(1)
		, [pc1MaritalStatus] char(2)
		, [PC2InHousehold] bit
		, [lastdate] datetime
		, [PrenatalStatus] bit
		, [NeedInterpreter] bit
	)
	
	insert into @x
	select distinct a.HVCasePK
					   ,c.Race_AmericanIndian
					   ,c.Race_Asian
					   ,c.Race_Black
					   ,c.Race_Hawaiian
					   ,c.Race_Hispanic
					   ,c.Race_Other
					   ,c.Race_White
					   ,cast(datediff(dd,c.PCDOB,a.IntakeDate)/365.25 as int) [Age]
					   ,cast(datediff(dd,a.IntakeDate,case
							when b.DischargeDate is not null and b.DischargeDate <= @enddt2 then
								b.DischargeDate
							else
								@enddt2
						end)/365.25 as int) [yrEnrolled]
					   ,ca1.HighestGrade [Edu]
					   ,ca1.IsCurrentlyEmployed [pc1Employed]
					   ,ca2.IsCurrentlyEmployed [pc2Employed]
					   ,caOBP.IsCurrentlyEmployed [obpEmployed]
					   ,caOBP.EducationalEnrollment [obpTrainingProgram]
					   ,caID.OBPInHome [OBPInHousehold]
					   ,ca1.EducationalEnrollment [pc1TrainingProgram]
					   ,ca2.EducationalEnrollment [pc2TrainingProgram]
					   ,ca.PC1ReceivingMedicaid [pc1Medicaid]
					   ,ca.PBFoodStamps [FoodStamps]
					   ,ca.PBTANF [TANF]
					   ,ca.PBWIC [WIC]
					   ,ca1.MaritalStatus [pc1MaritalStatus]
					   ,PC2inHomeIntake [PC2InHousehold]
					   ,case
							when b.DischargeDate is not null and b.DischargeDate <= @enddt2 then
								b.DischargeDate
							else
								@enddt2
						end [lastdate]
					   ,case
							when isnull(t.TCDOB,a.EDC) > a.IntakeDate then
								1
							else
								0
						end [PrenatalStatus]
					   ,case
							when ca1.PrimaryLanguage in ('02','03') then
								1
							else
								0
						end [NeedInterpreter]

			from
				dbo.HVCase as a
				inner join dbo.CaseProgram as b on a.HVCasePK = b.HVCaseFK
				inner join PC as c on c.PCPK = a.PC1FK
				inner join Intake as d on d.HVCaseFK = a.HVCasePK
				inner join worker fsw on b.CurrentFSWFK = fsw.workerpk
				inner join workerprogram wp on wp.workerfk = fsw.workerpk
				inner join dbo.SplitString(@programfk2,',') on b.programfk = listitem
				left outer join CommonAttributes as ca on ca.FormFK = d.IntakePK and ca.FormType = 'IN'
				left outer join CommonAttributes as ca1 on ca1.FormFK = d.IntakePK and ca1.FormType = 'IN-PC1'
				left outer join CommonAttributes as ca2 on ca2.FormFK = d.IntakePK and ca2.FormType = 'IN-PC2'
				left outer join CommonAttributes as caOBP on caOBP.FormFK = d.IntakePK and caOBP.FormType = 'IN-OBP'
				left outer join CommonAttributes as caID on caID.HVCaseFK = a.HVCasePK and caID.FormType = 'ID'
				--left outer join PC as pc on pc.PCPK = caOBP.PCFK and pc.Gender = '02'
				left outer join (select HVCaseFK
									   ,min(TCDOB) [TCDOB]
									 from
										 TCID
									 group by
											 HVCaseFK) as t
							   on t.HVCaseFK = a.HVCasePK
				inner join dbo.udfCaseFilters(@casefilterspositive2, '', @programfk2) cf on cf.HVCaseFK = a.HVCasePK
			where
				 (b.DischargeDate is null
				 or b.DischargeDate >= @startdt2)
				 and a.IntakeDate <= @enddt2
				 --and b.ProgramFK = @programfk2
				 and (case when @SiteFK2 = 0 then 1 when wp.SiteFK = @SiteFK2 then 1 else 0 end = 1)
	

	declare @TCMedicaid_5 table (
		HVCasePK int
		,[MultipleBirth] bit
		,[NumberofChildren] int
		,[TCMedicaid] char(2)
		,[TCIDStatus] int
	)
	insert into @TCMedicaid_5
	select a.HVCasePK
			  ,tc.MultipleBirth 
			  ,tc.NumberofChildren 
			  ,caTC.TCReceivingMedicaid 
			  ,caTC.CommonAttributesPK 
			from
				dbo.HVCase as a
				join dbo.CaseProgram as b on a.HVCasePK = b.HVCaseFK
				join PC as c on c.PCPK = a.PC1FK
				join Intake as d on d.HVCaseFK = a.HVCasePK
				join TCID as tc on tc.HVCaseFK = a.HVCasePK and tc.TCDOB <= @enddt2
				join CommonAttributes as caTC on caTC.FormFK = tc.TCIDPK and caTC.FormType = 'TC'
				inner join worker fsw on b.CurrentFSWFK = fsw.workerpk
				inner join workerprogram wp on wp.workerfk = fsw.workerpk
				inner join dbo.SplitString(@programfk2,',') on b.programfk = listitem
				inner join dbo.udfCaseFilters(@casefilterspositive2, '', @programfk2) cf on cf.HVCaseFK = a.HVCasePK
			where
				 (b.DischargeDate is null
				 or b.DischargeDate >= @startdt2)
				 and a.IntakeDate <= @enddt2
				 --and b.ProgramFK = @programfk2
				 and (case when @SiteFK2 = 0 then 1 when wp.SiteFK = @SiteFK2 then 1 else 0 end = 1)
	
	declare @TCMedicaid table (
		[PD05TCMedicaid] int
		,[PD05TC] int
	)
	insert into @TCMedicaid
	select sum(case
				   when TCMedicaid = 1 then
					   1
				   else
					   0
			   end) 
			  ,count(*) 
			from
				@TCMedicaid_5






	declare @y table (
	    [n] int
		,[PD01White] int
		,[PD01Black] int
		,[PD01Hispanic] int
		,[PD01Asian] int
		,[PD01NativeAmerican] int
		,[PD01Multiracial] int
		,[PD01Other] int
		,[PD02Age_17] int
		,[PD02Age_18_20] int
		,[PD02Age_21_30] int
		,[PD02Age_30Plus] int
		,[PD03Less12Yr] int
		,[PD03HighSchool] int
		,[PD03PostSecondary] int
		,[PD04PC1Employed] int
		,[PD04PC2Employed] int
		,[PD04PC1orPC2Employed] int
		,[PD04PC1TrainingProgram] int
		,[PD04PC2TrainingProgram] int
		,[PD05PC1Medicaid] int
		,[PD05TANF] int
		,[PD05WIC] int
		,[PD05FoodStamps] int
		,[PD06Married] int
		,[PD07OBPInHousehold] int
		,[PD07PC2InHousehold] int
		,[PD09LessThan1Yr] int
		,[PD09UpTo2Yr] int
		,[PD09UpTo3Yr] int
		,[PD09Over3Yr] int
		,[PD10PrenatalAtEnrolled] int
		,[PD11NeedInterpreter] int
	)
	insert into @y
	select count(*) [n]
		,sum(case when x.Race_White = 1 then 1 else 0 end) 
		,sum(case when x.Race_Black = 1 then 1 else 0 end) 
		,sum(case when x.Race_Hispanic = 1 then 1 else 0 end) 
		,sum(case when x.Race_Asian = 1 then 1 else 0 end) 
		,sum(case when x.Race_AmericanIndian = 1 then 1 else 0 end) 
		,sum(case when dbo.fnIsMultiRace(x.Race_AmericanIndian, x.Race_Asian, x.Race_Black, x.Race_Hawaiian, x.Race_White, x.Race_Other) = 1 then 1 else 0 end) 
		,sum(case when x.Race_Other = 1 then 1 else 0 end)				 
		,sum(case when x.Age < 18 then 1 else 0 end) 
		,sum(case when x.Age between 18 and 19 then 1 else 0 end) 
		,sum(case when x.Age between 20 and 29 then 1 else 0 end) 
		,sum(case when x.Age >= 30 then 1 else 0 end) 
		,sum(case when x.Edu in ('01','02') then 1 else 0 end) 
		,sum(case when x.Edu in ('03','04') then 1 else 0 end) 
		,sum(case when x.Edu in ('05','06','07','08') then 1 else 0 end) 
		,sum(case when x.pc1Employed = 1 then 1 else 0 end) 
		,sum(case when x.pc2Employed = 1 or x.obpEmployed = 1 then 1 else 0 end) 
		,sum(case when x.pc1Employed = 1 or x.pc2Employed = 1 or x.obpEmployed = 1 then 1 else 0 end) 
		,sum(case when x.pc1TrainingProgram = 1 then 1 else 0 end) 
		,sum(case when x.pc2TrainingProgram = 1 or x.obpTrainingProgram = 1 then 1 else 0 end) 
		,sum(case when x.pc1Medicaid = '1' then 1 else 0 end) 
		,sum(case when x.TANF = 1 then 1 else 0 end) 
		,sum(case when x.WIC = 1 then 1 else 0 end) 
		,sum(case when x.FoodStamps = 1 then 1 else 0 end) 
		,sum(case when x.pc1MaritalStatus = '01' then 1 else 0 end) 
		,sum(convert(int, x.OBPInHousehold))
		,sum(convert(int, x.PC2InHousehold)) 
		,sum(case when x.yrEnrolled < 1 then 1 else 0 end) 
		,sum(case when x.yrEnrolled = 1 then 1 else 0 end) 
		,sum(case when x.yrEnrolled = 2 then 1 else 0 end) 
		,sum(case when x.yrEnrolled >= 3 then 1 else 0 end) 
		,sum(case when x.PrenatalStatus = 1 then 1 else 0 end) 
		,sum(case when x.NeedInterpreter = 1 then 1 else  0 end) 
			from
				@x as x
	
	;with z
	as (select y.*
			  ,case
				   when y.[n] = 0 then
					   1
				   else
					   y.[n]
			   end [m]
			  ,f.[PD08MotherWithOtherChild]
			  ,g.[PD05TCMedicaid]
			  ,case
				   when g.[PD05TC] = 0 then
					   1
				   else
					   g.[PD05TC]
			   end [PD05TCm]
			  ,g.[PD05TC]
			from
				@y y
				join @MotherWithOtherChildren as f on 1 = 1
				join @TCMedicaid as g on 1 = 1

	)
	select n
		  ,str([PD01White],5)+' ('+str(round((100.0*[PD01White]/[m]),0),3)+'%)' [PD01White]
		  ,str([PD01Black],5)+' ('+str(round((100.0*[PD01Black]/[m]),0),3)+'%)' [PD01Black]
		  ,str([PD01Hispanic],5)+' ('+str(round((100.0*[PD01Hispanic]/[m]),0),3)+'%)' [PD01Hispanic]
		  ,str([PD01Asian],5)+' ('+str(round((100.0*[PD01Asian]/[m]),0),3)+'%)' [PD01Asian]
		  ,str([PD01NativeAmerican],5)+' ('+str(round((100.0*[PD01NativeAmerican]/[m]),0),3)+'%)' [PD01NativeAmerican]
		  ,str([PD01Multiracial],5)+' ('+str(round((100.0*[PD01Multiracial]/[m]),0),3)+'%)' [PD01Multiracial]
		  ,str([PD01Other],5)+' ('+str(round((100.0*[PD01Other]/[m]),0),3)+'%)' [PD01Other]
		  ,str([PD02Age_18_20],5)+' ('+str(round((100.0*[PD02Age_18_20]/[m]),0),3)+'%)' [PD02Age_18_20]
		  ,str([PD02Age_17],5)+' ('+str(round((100.0*[PD02Age_17]/[m]),0),3)+'%)' [PD02Age_17]
		  ,str([PD02Age_21_30],5)+' ('+str(round((100.0*[PD02Age_21_30]/[m]),0),3)+'%)' [PD02Age_21_30]
		  ,str([PD02Age_30Plus],5)+' ('+str(round((100.0*[PD02Age_30Plus]/[m]),0),3)+'%)' [PD02Age_30Plus]
		  ,str([PD03Less12Yr],5)+' ('+str(round((100.0*[PD03Less12Yr]/[m]),0),3)+'%)' [PD03Less12Yr]
		  ,str([PD03HighSchool],5)+' ('+str(round((100.0*[PD03HighSchool]/[m]),0),3)+'%)' [PD03HighSchool]
		  ,str([PD03PostSecondary],5)+' ('+str(round((100.0*[PD03PostSecondary]/[m]),0),3)+'%)' [PD03PostSecondary]
		  ,str([PD04PC1Employed],5)+' ('+str(round((100.0*[PD04PC1Employed]/[m]),0),3)+'%)' [PD04PC1Employed]
		  ,str([PD04PC2Employed],5)+' ('+str(round((100.0*[PD04PC2Employed]/[m]),0),3)+'%)' [PD04PC2Employed]
		  ,str([PD04PC1orPC2Employed],5)+' ('+str(round((100.0*[PD04PC1orPC2Employed]/[m]),0),3)+'%)' [PD04PC1orPC2Employed]
		  ,str([PD04PC1TrainingProgram],5)+' ('+str(round((100.0*[PD04PC1TrainingProgram]/[m]),0),3)+'%)' [PD04PC1TrainingProgram]
		  ,str([PD04PC2TrainingProgram],5)+' ('+str(round((100.0*[PD04PC2TrainingProgram]/[m]),0),3)+'%)' [PD04PC2TrainingProgram]
		  ,str([PD05PC1Medicaid],5)+' ('+str(round((100.0*[PD05PC1Medicaid]/[m]),0),3)+'%)' [PD05PC1Medicaid]
		  ,str([PD05TANF],5)+' ('+str(round((100.0*[PD05TANF]/[m]),0),3)+'%)' [PD05TANF]
		  ,str([PD05WIC],5)+' ('+str(round((100.0*[PD05WIC]/[m]),0),3)+'%)' [PD05WIC]
		  ,str([PD05FoodStamps],5)+' ('+str(round((100.0*[PD05FoodStamps]/[m]),0),3)+'%)' [PD05FoodStamps]
		  ,str([PD06Married],5)+' ('+str(round((100.0*[PD06Married]/[m]),0),3)+'%)' [PD06Married]
		  ,str([PD07OBPInHousehold],5)+' ('+str(round((100.0*[PD07OBPInHousehold]/[m]),0),3)+'%)' [PD07OBPInHousehold]
		  ,str([PD07PC2InHousehold],5)+' ('+str(round((100.0*[PD07PC2InHousehold]/[m]),0),3)+'%)' [PD07PC2InHousehold]
		  ,str([PD09LessThan1Yr],5)+' ('+str(round((100.0*[PD09LessThan1Yr]/[m]),0),3)+'%)' [PD09LessThan1Yr]
		  ,str([PD09UpTo2Yr],5)+' ('+str(round((100.0*[PD09UpTo2Yr]/[m]),0),3)+'%)' [PD09UpTo2Yr]
		  ,str([PD09UpTo3Yr],5)+' ('+str(round((100.0*[PD09UpTo3Yr]/[m]),0),3)+'%)' [PD09UpTo3Yr]
		  ,str([PD09Over3Yr],5)+' ('+str(round((100.0*[PD09Over3Yr]/[m]),0),3)+'%)' [PD09Over3Yr]
		  ,str([PD10PrenatalAtEnrolled],5)+' ('+str(round((100.0*[PD10PrenatalAtEnrolled]/[m]),0),3)+'%)' [PD10PrenatalAtEnrolled]
		  ,str([PD11NeedInterpreter],5)+' ('+str(round((100.0*[PD11NeedInterpreter]/[m]),0),3)+'%)' [PD11NeedInterpreter]
		  ,str(n-[PD08MotherWithOtherChild],5)+' ('+str(round((100.0*(n-[PD08MotherWithOtherChild])/[m]),0),3)+'%)' 
			  [PD08FirstTimeMom]
		  ,str([PD05TCMedicaid],5)+' ('+str(round((100.0*[PD05TCMedicaid]/[PD05TCm]),0),3)+'%)' [PD05TCMedicaid]
		  ,[PD05TC]

		from
			z
GO
