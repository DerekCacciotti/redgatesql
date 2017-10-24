SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dar Chen>
-- Create date: <04/04/2016>
-- Description:	<This Credentialing report gets you 'Summary for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Summary 1, '04/01/2012', '03/31/2013'

-- =============================================
CREATE procedure [dbo].[rspCredentialingKempeAnalysis_Summary]
	(
		@programfk varchar(max) = null ,
		@StartDate datetime ,
		@EndDate datetime ,
		@SiteFK int = null
	)
as
	declare @programfkX varchar(max);
	declare @StartDateX datetime = @StartDate;
	declare @EndDateX datetime = @EndDate;

	if @programfk is null
		begin
			select @programfk = substring(
								(	select ','
										   + ltrim(rtrim(str(HVProgramPK)))
									from   HVProgram
									for xml path('')) ,
								2 ,
								8000);
		end;

	set @programfk = replace(@programfk, '"', '');
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end;
	set @programfkX = @programfk;
	set @StartDateX = @StartDate;
	set @EndDateX = @EndDate;

	if object_id('tempdb..#cteMain') is not null
		drop table #cteMain;
	if object_id('tempdb..#cteMain1') is not null
		drop table #cteMain1;

	create table #cteMain
		(
			HVCasePK int ,
			tcdob datetime ,
			DischargeDate datetime ,
			IntakeDate datetime ,
			KempeDate datetime ,
			PC1FK int ,
			DischargeReason char(2) ,
			OldID char(23) ,
			PC1ID char(13) ,
			KempeResult bit ,
			cCurrentFSWFK int ,
			cCurrentFAWFK int ,
			babydate datetime ,
			testdate datetime ,
			PCDOB datetime ,
			Race char(2) ,
			MaritalStatus char(2) ,
			HighestGrade char(2) ,
			IsCurrentlyEmployed char(1) ,
			OBPInHome char(1) ,
			MomScore int ,
			DadScore int ,
			FOBPresent bit ,
			MOBPresent bit ,
			OtherPresent bit ,
			MOBPartnerPresent bit ,	 --as MOBPartner 
			FOBPartnerPresent bit ,	 --as FOBPartner
			GrandParentPresent bit , --as MOBGrandmother
			PIVisitMade int ,
			DV int ,
			MH int ,
			SA int ,
			presentCode int
		);

	create table #cteMain1
		(
			Status char(1) ,
			[IntakeDate2] datetime ,
			[KempeResult2] bit ,
			[PIVisitMade2] int ,
			[DischargeDate2] datetime ,
			[DischargeReason2] char(2) ,
			age int ,
			KempeScore int ,
			Trimester int ,
			HVCasePK int ,
			tcdob datetime ,
			DischargeDate datetime ,
			IntakeDate datetime ,
			KempeDate datetime ,
			PC1FK int ,
			DischargeReason char(2) ,
			OldID char(23) ,
			PC1ID char(13) ,
			KempeResult bit ,
			cCurrentFSWFK int ,
			cCurrentFAWFK int ,
			babydate datetime ,
			testdate datetime ,
			PCDOB datetime ,
			Race char(2) ,
			MaritalStatus char(2) ,
			HighestGrade char(2) ,
			IsCurrentlyEmployed char(1) ,
			OBPInHome char(1) ,
			MomScore int ,
			DadScore int ,
			FOBPresent bit ,
			MOBPresent bit ,
			OtherPresent bit ,
			MOBPartnerPresent bit ,	 --as MOBPartner 
			FOBPartnerPresent bit ,	 --as FOBPartner
			GrandParentPresent bit , --as MOBGrandmother
			PIVisitMade int ,
			DV int ,
			MH int ,
			SA int ,
			presentCode int
		);
	with
	ctePIVisits
		as
			(
				select	 KempeFK ,
						 sum(case when PIVisitMade > 0 then 1
								  else 0
							 end) PIVisitMade
				from	 Preintake pi
						 inner join dbo.SplitString(@programfk, ',') on pi.ProgramFK = ListItem
				group by KempeFK
			) ,
	ctePreviousPC1Issue
		as
			(
				select	 min(PC1IssuesPK) as PC1IssuesPK ,
						 HVCaseFK
				from	 PC1Issues
						 inner join dbo.SplitString(@programfk, ',') on PC1Issues.ProgramFK = ListItem
				where	 rtrim(Interval) = '1'
				group by HVCaseFK
			) ,
	cteIssues
		as
			(
				select a.HVCaseFK ,
					   case when DomesticViolence = 1 then 1
							else 0
					   end as DV ,
					   case when (	 Depression = 1
									 or MentalIllness = 1 ) then 1
							else 0
					   end as MH ,
					   case when (	 AlcoholAbuse = 1
									 or SubstanceAbuse = 1 ) then 1
							else 0
					   end as SA
				from   PC1Issues a
					   inner join (	  select   min(PC1IssuesPK) as PC1IssuesPK ,
											   HVCaseFK
									  from	   PC1Issues
									  where	   rtrim(Interval) = '1'
									  group by HVCaseFK ) b on a.PC1IssuesPK = b.PC1IssuesPK
			)
	insert into #cteMain
				select HVCasePK ,
					   case when h.TCDOB is not null then h.TCDOB
							else h.EDC
					   end as tcdob ,
					   DischargeDate ,
					   IntakeDate ,
					   k.KempeDate ,
					   PC1FK ,
					   cp.DischargeReason ,
					   OldID ,
					   PC1ID ,
					   KempeResult ,
					   cp.CurrentFSWFK ,
					   cp.CurrentFAWFK ,
					   case when h.TCDOB is not null then h.TCDOB
							else h.EDC
					   end as babydate ,
					   case when h.IntakeDate is not null then h.IntakeDate
							else cp.DischargeDate
					   end as testdate ,
					   P.PCDOB ,
					   P.Race ,
					   ca.MaritalStatus ,
					   ca.HighestGrade ,
					   ca.IsCurrentlyEmployed ,
					   ca.OBPInHome ,
					   case when MomScore = 'U' then 0
							else cast(MomScore as int)
					   end as MomScore ,
					   case when DadScore = 'U' then 0
							else cast(DadScore as int)
					   end as DadScore ,
					   FOBPresent ,
					   MOBPresent ,
					   OtherPresent ,
					   MOBPartnerPresent ,	--as MOBPartner 
					   FOBPartnerPresent ,	--as FOBPartner
					   GrandParentPresent , --as MOBGrandmother
					   PIVisitMade ,
					   i.DV ,
					   i.MH ,
					   i.SA ,
					   case when (	 isnull(k.MOBPartnerPresent, 0) = 0
									 and isnull(k.FOBPartnerPresent, 0) = 0
									 and isnull(k.GrandParentPresent, 0) = 0
									 and isnull(k.OtherPresent, 0) = 0 ) then
								case when k.MOBPresent = 1
										  and k.FOBPresent = 1 then 3 -- both parent
									 when k.MOBPresent = 1 then 1	  -- MOB Only
									 when k.FOBPresent = 1 then 2	  -- FOB Only
									 else 4							  -- parent/other
								end
							else 4 -- parent/other
					   end presentCode
				from   HVCase h
					   inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
					   inner join dbo.SplitString(@programfkX, ',') on cp.ProgramFK = ListItem
					   inner join Kempe k on k.HVCaseFK = h.HVCasePK
					   inner join PC P on P.PCPK = h.PC1FK
					   left outer join ctePIVisits piv on piv.KempeFK = k.KempePK
					   left outer join cteIssues i on i.HVCaseFK = h.HVCasePK
					   left join CommonAttributes ca on ca.HVCaseFK = h.HVCasePK
														and ca.FormType = 'KE'
					   left join Worker faw on CurrentFAWFK = faw.WorkerPK -- faw
					   left join WorkerProgram wpfaw on wpfaw.WorkerFK = faw.WorkerPK
					   left join Worker fsw on CurrentFSWFK = fsw.WorkerPK -- fsw	 
					   left join WorkerProgram wpfsw on wpfsw.WorkerFK = fsw.WorkerPK
				where  (   h.IntakeDate is not null
						   or cp.DischargeDate is not null ) -- only include kempes that are positive and where there is a clos_date or an intake date.
					   and k.KempeResult = 1
					   and k.KempeDate between @StartDateX and @EndDateX
					   and (case when @SiteFK = 0 then 1 when wpfaw.SiteFK = @SiteFK then 1 else 0 end = 1)
					   and (case when @SiteFK = 0 then 1 when wpfsw.SiteFK = @SiteFK then 1 else 0 end = 1);

	insert into #cteMain1
				select case when IntakeDate is not null then '1' --'AcceptedFirstVisitEnrolled' 
							when KempeResult = 1
								 and IntakeDate is null
								 and DischargeDate is not null
								 and (	 PIVisitMade > 0
										 and PIVisitMade is not null ) then
								'2'								 -- 'AcceptedFirstVisitNotEnrolled'
							else '3'							 -- 'Refused' 
					   end Status ,
					   a.IntakeDate as [IntakeDate2] ,
					   a.KempeResult as [KempeResult2] ,
					   a.PIVisitMade as [PIVisitMade2] ,
					   a.DischargeDate as [DischargeDate2] ,
					   a.DischargeReason as [DischargeReason2] ,
					   datediff(day, PCDOB, testdate) / 365.25 as age ,
					   case when a.MomScore > a.DadScore then a.MomScore
							else a.DadScore
					   end KempeScore ,
					   case when datediff(d, testdate, babydate) > 0
								 and datediff(d, testdate, babydate) < 30.44
																	   * 3 then
								3
							when (	 datediff(d, testdate, babydate) >= 30.44
																		* 3
									 and datediff(d, testdate, babydate) < 30.44
																		   * 6 ) then
								2
							when datediff(d, testdate, babydate) >= round(
																		30.44
																		* 6 ,
																		0) then
								1
							when datediff(d, testdate, babydate) <= 0 then 4
					   end as Trimester ,
					   *
				from   #cteMain as a;
	with
	total1
		as
			(
				select count(*) as total ,
					   sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3
				from   #cteMain1 as a
			) ,
	total2
		as
			(
				select 'Totals (N = ' + convert(varchar, total) + ')' as [title] ,
					   convert(varchar, totalG1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(totalG1 as float) * 100
									 / nullif(total, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, totalG2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(totalG2 as float) * 100
									 / nullif(total, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, totalG3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(totalG3 as float) * 100
									 / nullif(total, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   total1
			) ,
	total3
		as
			(
				select 'Acceptance Rate - '
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(( totalG1 + totalG2 ) as float)
									 * 100 / nullif(total, 0) ,
									 0) ,
								 0)) + '%' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
				from   total1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
			) ,
	age1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when age < 18 then 1
								else 0
						   end) as age18 ,
					   sum(case when a.Status = '1'
									 and age < 18 then 1
								else 0
						   end) as age18G1 ,
					   sum(case when a.Status = '2'
									 and age < 18 then 1
								else 0
						   end) as age18G2 ,
					   sum(case when a.Status = '3'
									 and age < 18 then 1
								else 0
						   end) as age18G3 ,
					   sum(case when (	 age >= 18
										 and age < 20 ) then 1
								else 0
						   end) as age20 ,
					   sum(case when a.Status = '1'
									 and (	 age >= 18
											 and age < 20 ) then 1
								else 0
						   end) as age20G1 ,
					   sum(case when a.Status = '2'
									 and (	 age >= 18
											 and age < 20 ) then 1
								else 0
						   end) as age20G2 ,
					   sum(case when a.Status = '3'
									 and (	 age >= 18
											 and age < 20 ) then 1
								else 0
						   end) as age20G3 ,
					   sum(case when (	 age >= 20
										 and age < 30 ) then 1
								else 0
						   end) as age30 ,
					   sum(case when a.Status = '1'
									 and (	 age >= 20
											 and age < 30 ) then 1
								else 0
						   end) as age30G1 ,
					   sum(case when a.Status = '2'
									 and (	 age >= 20
											 and age < 30 ) then 1
								else 0
						   end) as age30G2 ,
					   sum(case when a.Status = '3'
									 and (	 age >= 20
											 and age < 30 ) then 1
								else 0
						   end) as age30G3 ,
					   sum(case when ( age >= 30 ) then 1
								else 0
						   end) as age40 ,
					   sum(case when a.Status = '1'
									 and ( age >= 30 ) then 1
								else 0
						   end) as age40G1 ,
					   sum(case when a.Status = '2'
									 and ( age >= 30 ) then 1
								else 0
						   end) as age40G2 ,
					   sum(case when a.Status = '3'
									 and ( age >= 30 ) then 1
								else 0
						   end) as age40G3
				from   #cteMain1 as a
			) ,
	age2
		as
			(
				select 'Age' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
				union all
				select '  Under 18' as [title] ,
					   convert(varchar, age18G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age18G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, age18G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age18G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, age18G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age18G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   age1
				union all
				select '  18 up to 20' as [title] ,
					   convert(varchar, age20G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age20G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, age20G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age20G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, age20G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age20G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   age1
				union all
				select '  20 up to 30' as [title] ,
					   convert(varchar, age30G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age30G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, age30G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age30G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, age30G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age30G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   age1
				union all
				select '  30 and over' as [title] ,
					   convert(varchar, age40G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age40G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, age40G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age40G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, age40G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(age40G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   age1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
			) ,
	race1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when Race = '01' then 1
								else 0
						   end) as race01 ,
					   sum(case when a.Status = '1'
									 and Race = '01' then 1
								else 0
						   end) as race01G1 ,
					   sum(case when a.Status = '2'
									 and Race = '01' then 1
								else 0
						   end) as race01G2 ,
					   sum(case when a.Status = '3'
									 and Race = '01' then 1
								else 0
						   end) as race01G3 ,
					   sum(case when Race = '02' then 1
								else 0
						   end) as race02 ,
					   sum(case when a.Status = '1'
									 and Race = '02' then 1
								else 0
						   end) as race02G1 ,
					   sum(case when a.Status = '2'
									 and Race = '02' then 1
								else 0
						   end) as race02G2 ,
					   sum(case when a.Status = '3'
									 and Race = '02' then 1
								else 0
						   end) as race02G3 ,
					   sum(case when Race = '03' then 1
								else 0
						   end) as race03 ,
					   sum(case when a.Status = '1'
									 and Race = '03' then 1
								else 0
						   end) as race03G1 ,
					   sum(case when a.Status = '2'
									 and Race = '03' then 1
								else 0
						   end) as race03G2 ,
					   sum(case when a.Status = '3'
									 and Race = '03' then 1
								else 0
						   end) as race03G3 ,
					   sum(case when Race = '04' then 1
								else 0
						   end) as race04 ,
					   sum(case when a.Status = '1'
									 and Race = '04' then 1
								else 0
						   end) as race04G1 ,
					   sum(case when a.Status = '2'
									 and Race = '04' then 1
								else 0
						   end) as race04G2 ,
					   sum(case when a.Status = '3'
									 and Race = '04' then 1
								else 0
						   end) as race04G3 ,
					   sum(case when Race = '05' then 1
								else 0
						   end) as race05 ,
					   sum(case when a.Status = '1'
									 and Race = '05' then 1
								else 0
						   end) as race05G1 ,
					   sum(case when a.Status = '2'
									 and Race = '05' then 1
								else 0
						   end) as race05G2 ,
					   sum(case when a.Status = '3'
									 and Race = '05' then 1
								else 0
						   end) as race05G3 ,
					   sum(case when Race = '06' then 1
								else 0
						   end) as race06 ,
					   sum(case when a.Status = '1'
									 and Race = '06' then 1
								else 0
						   end) as race06G1 ,
					   sum(case when a.Status = '2'
									 and Race = '06' then 1
								else 0
						   end) as race06G2 ,
					   sum(case when a.Status = '3'
									 and Race = '06' then 1
								else 0
						   end) as race06G3 ,
					   sum(case when Race = '07' then 1
								else 0
						   end) as race07 ,
					   sum(case when a.Status = '1'
									 and Race = '07' then 1
								else 0
						   end) as race07G1 ,
					   sum(case when a.Status = '2'
									 and Race = '07' then 1
								else 0
						   end) as race07G2 ,
					   sum(case when a.Status = '3'
									 and Race = '07' then 1
								else 0
						   end) as race07G3 ,
					   sum(case when (	 Race is null
										 or Race = '' ) then 1
								else 0
						   end) as race08 ,
					   sum(case when a.Status = '1'
									 and (	 Race is null
											 or Race = '' ) then 1
								else 0
						   end) as race08G1 ,
					   sum(case when a.Status = '2'
									 and (	 Race is null
											 or Race = '' ) then 1
								else 0
						   end) as race08G2 ,
					   sum(case when a.Status = '3'
									 and (	 Race is null
											 or Race = '' ) then 1
								else 0
						   end) as race08G3
				from   #cteMain1 as a
			) ,
	race2
		as
			(
				select 'Race' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
				union all
				select '  White, non-Hispanic' as [title] ,
					   convert(varchar, race01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '  Black, non-Hispanic' as [title] ,
					   convert(varchar, race02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '  Hispanic/Latina/Latino' as [title] ,
					   convert(varchar, race03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '  Asian' as [title] ,
					   convert(varchar, race04G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race04G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race04G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race04G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race04G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race04G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '  Native American' as [title] ,
					   convert(varchar, race05G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race05G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race05G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race05G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race05G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race05G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '  Multiracial' as [title] ,
					   convert(varchar, race06G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race06G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race06G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race06G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race06G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race06G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '  Other' as [title] ,
					   convert(varchar, race07G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race07G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race07G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race07G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race07G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race07G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '  Missing' as [title] ,
					   convert(varchar, race08G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race08G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, race08G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race08G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, race08G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(race08G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   race1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
			) ,
	martial1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when MaritalStatus = '01' then 1
								else 0
						   end) as MaritalStatus01 ,
					   sum(case when a.Status = '1'
									 and MaritalStatus = '01' then 1
								else 0
						   end) as MaritalStatus01G1 ,
					   sum(case when a.Status = '2'
									 and MaritalStatus = '01' then 1
								else 0
						   end) as MaritalStatus01G2 ,
					   sum(case when a.Status = '3'
									 and MaritalStatus = '01' then 1
								else 0
						   end) as MaritalStatus01G3 ,
					   sum(case when MaritalStatus = '02' then 1
								else 0
						   end) as MaritalStatus02 ,
					   sum(case when a.Status = '1'
									 and MaritalStatus = '02' then 1
								else 0
						   end) as MaritalStatus02G1 ,
					   sum(case when a.Status = '2'
									 and MaritalStatus = '02' then 1
								else 0
						   end) as MaritalStatus02G2 ,
					   sum(case when a.Status = '3'
									 and MaritalStatus = '02' then 1
								else 0
						   end) as MaritalStatus02G3 ,
					   sum(case when MaritalStatus = '03' then 1
								else 0
						   end) as MaritalStatus03 ,
					   sum(case when a.Status = '1'
									 and MaritalStatus = '03' then 1
								else 0
						   end) as MaritalStatus03G1 ,
					   sum(case when a.Status = '2'
									 and MaritalStatus = '03' then 1
								else 0
						   end) as MaritalStatus03G2 ,
					   sum(case when a.Status = '3'
									 and MaritalStatus = '03' then 1
								else 0
						   end) as MaritalStatus03G3 ,
					   sum(case when MaritalStatus = '04' then 1
								else 0
						   end) as MaritalStatus04 ,
					   sum(case when a.Status = '1'
									 and MaritalStatus = '04' then 1
								else 0
						   end) as MaritalStatus04G1 ,
					   sum(case when a.Status = '2'
									 and MaritalStatus = '04' then 1
								else 0
						   end) as MaritalStatus04G2 ,
					   sum(case when a.Status = '3'
									 and MaritalStatus = '04' then 1
								else 0
						   end) as MaritalStatus04G3 ,
					   sum(case when MaritalStatus = '05' then 1
								else 0
						   end) as MaritalStatus05 ,
					   sum(case when a.Status = '1'
									 and MaritalStatus = '05' then 1
								else 0
						   end) as MaritalStatus05G1 ,
					   sum(case when a.Status = '2'
									 and MaritalStatus = '05' then 1
								else 0
						   end) as MaritalStatus05G2 ,
					   sum(case when a.Status = '3'
									 and MaritalStatus = '05' then 1
								else 0
						   end) as MaritalStatus05G3 ,
					   sum(case when (	 MaritalStatus is null
										 or MaritalStatus not in ( '01' ,
																   '02' ,
																   '03' ,
																   '04' , '05' )) then
									1
								else 0
						   end) as MaritalStatus06 ,
					   sum(case when a.Status = '1'
									 and (	 MaritalStatus is null
											 or MaritalStatus not in ( '01' ,
																	   '02' ,
																	   '03' ,
																	   '04' ,
																	   '05' )) then
									1
								else 0
						   end) as MaritalStatus06G1 ,
					   sum(case when a.Status = '2'
									 and (	 MaritalStatus is null
											 or MaritalStatus not in ( '01' ,
																	   '02' ,
																	   '03' ,
																	   '04' ,
																	   '05' )) then
									1
								else 0
						   end) as MaritalStatus06G2 ,
					   sum(case when a.Status = '3'
									 and (	 MaritalStatus is null
											 or MaritalStatus not in ( '01' ,
																	   '02' ,
																	   '03' ,
																	   '04' ,
																	   '05' )) then
									1
								else 0
						   end) as MaritalStatus06G3
				from   #cteMain1 as a
			) ,
	martial2
		as
			(
				select 'Martial Status' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
				union all
				select '  Married' as [title] ,
					   convert(varchar, MaritalStatus01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, MaritalStatus01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, MaritalStatus01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   martial1
				union all
				select '  Not Married' as [title] ,
					   convert(varchar, MaritalStatus02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, MaritalStatus02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, MaritalStatus02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   martial1
				union all
				select '  Separated' as [title] ,
					   convert(varchar, MaritalStatus03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, MaritalStatus03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, MaritalStatus03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   martial1
				union all
				select '  Divorced' as [title] ,
					   convert(varchar, MaritalStatus04G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus04G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, MaritalStatus04G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus04G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, MaritalStatus04G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus04G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   martial1
				union all
				select '  Widowed' as [title] ,
					   convert(varchar, MaritalStatus05G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus05G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, MaritalStatus05G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus05G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, MaritalStatus05G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus05G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   martial1
				union all
				select '  Unknown' as [title] ,
					   convert(varchar, MaritalStatus06G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus06G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, MaritalStatus06G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus06G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, MaritalStatus06G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(MaritalStatus06G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '1' as col4
				from   martial1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '1' as col4
			) ,
	edu1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when HighestGrade in ( '01', '02' ) then 1
								else 0
						   end) as HighestGrade01 ,
					   sum(case when a.Status = '1'
									 and HighestGrade in ( '01', '02' ) then
									1
								else 0
						   end) as HighestGrade01G1 ,
					   sum(case when a.Status = '2'
									 and HighestGrade in ( '01', '02' ) then
									1
								else 0
						   end) as HighestGrade01G2 ,
					   sum(case when a.Status = '3'
									 and HighestGrade in ( '01', '02' ) then
									1
								else 0
						   end) as HighestGrade01G3 ,
					   sum(case when HighestGrade in ( '03', '04' ) then 1
								else 0
						   end) as HighestGrade02 ,
					   sum(case when a.Status = '1'
									 and HighestGrade in ( '03', '04' ) then
									1
								else 0
						   end) as HighestGrade02G1 ,
					   sum(case when a.Status = '2'
									 and HighestGrade in ( '03', '04' ) then
									1
								else 0
						   end) as HighestGrade02G2 ,
					   sum(case when a.Status = '3'
									 and HighestGrade in ( '03', '04' ) then
									1
								else 0
						   end) as HighestGrade02G3 ,
					   sum(case when HighestGrade in ( '05', '06', '07', '08' ) then
									1
								else 0
						   end) as HighestGrade03 ,
					   sum(case when a.Status = '1'
									 and HighestGrade in ( '05', '06', '07' ,
														   '08' ) then 1
								else 0
						   end) as HighestGrade03G1 ,
					   sum(case when a.Status = '2'
									 and HighestGrade in ( '05', '06', '07' ,
														   '08' ) then 1
								else 0
						   end) as HighestGrade03G2 ,
					   sum(case when a.Status = '3'
									 and HighestGrade in ( '05', '06', '07' ,
														   '08' ) then 1
								else 0
						   end) as HighestGrade03G3 ,
					   sum(case when HighestGrade is null then 1
								else 0
						   end) as HighestGrade04 ,
					   sum(case when a.Status = '1'
									 and HighestGrade is null then 1
								else 0
						   end) as HighestGrade04G1 ,
					   sum(case when a.Status = '2'
									 and HighestGrade is null then 1
								else 0
						   end) as HighestGrade04G2 ,
					   sum(case when a.Status = '3'
									 and HighestGrade is null then 1
								else 0
						   end) as HighestGrade04G3
				from   #cteMain1 as a
			) ,
	edu2
		as
			(
				select 'Education' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
				union all
				select '  Less than 12' as [title] ,
					   convert(varchar, HighestGrade01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, HighestGrade01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, HighestGrade01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   edu1
				union all
				select '  HS/GED' as [title] ,
					   convert(varchar, HighestGrade02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, HighestGrade02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, HighestGrade02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   edu1
				union all
				select '  More than 12' as [title] ,
					   convert(varchar, HighestGrade03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, HighestGrade03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, HighestGrade03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   edu1
				union all
				select '  Unknown' as [title] ,
					   convert(varchar, HighestGrade04G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade04G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, HighestGrade04G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade04G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, HighestGrade04G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(HighestGrade04G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   edu1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
			) ,
	employed1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when IsCurrentlyEmployed = 1 then 1
								else 0
						   end) as Employed01 ,
					   sum(case when a.Status = '1'
									 and IsCurrentlyEmployed = 1 then 1
								else 0
						   end) as Employed01G1 ,
					   sum(case when a.Status = '2'
									 and IsCurrentlyEmployed = 1 then 1
								else 0
						   end) as Employed01G2 ,
					   sum(case when a.Status = '3'
									 and IsCurrentlyEmployed = 1 then 1
								else 0
						   end) as Employed01G3 ,
					   sum(case when IsCurrentlyEmployed = 0 then 1
								else 0
						   end) as Employed02 ,
					   sum(case when a.Status = '1'
									 and IsCurrentlyEmployed = 0 then 1
								else 0
						   end) as Employed02G1 ,
					   sum(case when a.Status = '2'
									 and IsCurrentlyEmployed = 0 then 1
								else 0
						   end) as Employed02G2 ,
					   sum(case when a.Status = '3'
									 and IsCurrentlyEmployed = 0 then 1
								else 0
						   end) as Employed02G3
				from   #cteMain1 as a
			) ,
	employed2
		as
			(
				select 'Employed' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
				union all
				select '  Yes' as [title] ,
					   convert(varchar, Employed01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Employed01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, Employed01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Employed01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, Employed01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Employed01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   employed1
				union all
				select '  No' as [title] ,
					   convert(varchar, Employed02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Employed02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, Employed02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Employed02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, Employed02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Employed02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   employed1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
			) ,
	inHome1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when OBPInHome = 1 then 1
								else 0
						   end) as InHome01 ,
					   sum(case when a.Status = '1'
									 and OBPInHome = 1 then 1
								else 0
						   end) as InHome01G1 ,
					   sum(case when a.Status = '2'
									 and OBPInHome = 1 then 1
								else 0
						   end) as InHome01G2 ,
					   sum(case when a.Status = '3'
									 and OBPInHome = 1 then 1
								else 0
						   end) as InHome01G3 ,
					   sum(case when OBPInHome = 0 then 1
								else 0
						   end) as InHome02 ,
					   sum(case when a.Status = '1'
									 and OBPInHome = 0 then 1
								else 0
						   end) as InHome02G1 ,
					   sum(case when a.Status = '2'
									 and OBPInHome = 0 then 1
								else 0
						   end) as InHome02G2 ,
					   sum(case when a.Status = '3'
									 and OBPInHome = 0 then 1
								else 0
						   end) as InHome02G3 ,
					   sum(case when OBPInHome is null then 1
								else 0
						   end) as InHome03 ,
					   sum(case when a.Status = '1'
									 and OBPInHome is null then 1
								else 0
						   end) as InHome03G1 ,
					   sum(case when a.Status = '2'
									 and OBPInHome is null then 1
								else 0
						   end) as InHome03G2 ,
					   sum(case when a.Status = '3'
									 and OBPInHome is null then 1
								else 0
						   end) as InHome03G3
				from   #cteMain1 as a
			) ,
	inHome2
		as
			(
				select 'Bio Father in Home' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
				union all
				select '  Yes' as [title] ,
					   convert(varchar, InHome01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, InHome01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, InHome01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   inHome1
				union all
				select '  No' as [title] ,
					   convert(varchar, InHome02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, InHome02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, InHome02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   inHome1
				union all
				select '  Unknown' as [title] ,
					   convert(varchar, InHome03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, InHome03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, InHome03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(InHome03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   inHome1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
			) ,
	score1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when MomScore >= 25
									 and DadScore < 25 then 1
								else 0
						   end) as Score01 ,
					   sum(case when a.Status = '1'
									 and MomScore >= 25
									 and DadScore < 25 then 1
								else 0
						   end) as Score01G1 ,
					   sum(case when a.Status = '2'
									 and MomScore >= 25
									 and DadScore < 25 then 1
								else 0
						   end) as Score01G2 ,
					   sum(case when a.Status = '3'
									 and MomScore >= 25
									 and DadScore < 25 then 1
								else 0
						   end) as Score01G3 ,
					   sum(case when MomScore < 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score02 ,
					   sum(case when a.Status = '1'
									 and MomScore < 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score02G1 ,
					   sum(case when a.Status = '2'
									 and MomScore < 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score02G2 ,
					   sum(case when a.Status = '3'
									 and MomScore < 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score02G3 ,
					   sum(case when MomScore >= 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score03 ,
					   sum(case when a.Status = '1'
									 and MomScore >= 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score03G1 ,
					   sum(case when a.Status = '2'
									 and MomScore >= 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score03G2 ,
					   sum(case when a.Status = '3'
									 and MomScore >= 25
									 and DadScore >= 25 then 1
								else 0
						   end) as Score03G3
				from   #cteMain1 as a
			) ,
	score2
		as
			(
				select 'Whose Score Qualifies' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
				union all
				select '  Mother' as [title] ,
					   convert(varchar, Score01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, Score01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, Score01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   score1
				union all
				select '  Father' as [title] ,
					   convert(varchar, Score02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, Score02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, Score02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   score1
				union all
				select '  Mother & Father' as [title] ,
					   convert(varchar, Score03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, Score03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, Score03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Score03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   score1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
			) ,
	kempescore1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when KempeScore
									 between 25 and 49 then 1
								else 0
						   end) as KempeScore01 ,
					   sum(case when a.Status = '1'
									 and KempeScore
									 between 25 and 49 then 1
								else 0
						   end) as KempeScore01G1 ,
					   sum(case when a.Status = '2'
									 and KempeScore
									 between 25 and 49 then 1
								else 0
						   end) as KempeScore01G2 ,
					   sum(case when a.Status = '3'
									 and KempeScore
									 between 25 and 49 then 1
								else 0
						   end) as KempeScore01G3 ,
					   sum(case when KempeScore
									 between 50 and 74 then 1
								else 0
						   end) as KempeScore02 ,
					   sum(case when a.Status = '1'
									 and KempeScore
									 between 50 and 74 then 1
								else 0
						   end) as KempeScore02G1 ,
					   sum(case when a.Status = '2'
									 and KempeScore
									 between 50 and 74 then 1
								else 0
						   end) as KempeScore02G2 ,
					   sum(case when a.Status = '3'
									 and KempeScore
									 between 50 and 74 then 1
								else 0
						   end) as KempeScore02G3 ,
					   sum(case when KempeScore >= 75 then 1
								else 0
						   end) as KempeScore03 ,
					   sum(case when a.Status = '1'
									 and KempeScore >= 75 then 1
								else 0
						   end) as KempeScore03G1 ,
					   sum(case when a.Status = '2'
									 and KempeScore >= 75 then 1
								else 0
						   end) as KempeScore03G2 ,
					   sum(case when a.Status = '3'
									 and KempeScore >= 75 then 1
								else 0
						   end) as KempeScore03G3
				from   #cteMain1 as a
			) ,
	kempescore2
		as
			(
				select 'Kempe Score' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
				union all
				select '  25-49' as [title] ,
					   convert(varchar, KempeScore01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, KempeScore01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, KempeScore01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   kempescore1
				union all
				select '  50-74' as [title] ,
					   convert(varchar, KempeScore02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, KempeScore02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, KempeScore02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   kempescore1
				union all
				select '  75+' as [title] ,
					   convert(varchar, KempeScore03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, KempeScore03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, KempeScore03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(KempeScore03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '2' as col4
				from   kempescore1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '2' as col4
			) ,
	issues1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when DV = 1 then 1
								else 0
						   end) as issues01 ,
					   sum(case when a.Status = '1'
									 and DV = 1 then 1
								else 0
						   end) as issues01G1 ,
					   sum(case when a.Status = '2'
									 and DV = 1 then 1
								else 0
						   end) as issues01G2 ,
					   sum(case when a.Status = '3'
									 and DV = 1 then 1
								else 0
						   end) as issues01G3 ,
					   sum(case when MH = 1 then 1
								else 0
						   end) as issues02 ,
					   sum(case when a.Status = '1'
									 and MH = 1 then 1
								else 0
						   end) as issues02G1 ,
					   sum(case when a.Status = '2'
									 and MH = 1 then 1
								else 0
						   end) as issues02G2 ,
					   sum(case when a.Status = '3'
									 and MH = 1 then 1
								else 0
						   end) as issues02G3 ,
					   sum(case when SA = 1 then 1
								else 0
						   end) as issues03 ,
					   sum(case when a.Status = '1'
									 and SA = 1 then 1
								else 0
						   end) as issues03G1 ,
					   sum(case when a.Status = '2'
									 and SA = 1 then 1
								else 0
						   end) as issues03G2 ,
					   sum(case when a.Status = '3'
									 and SA = 1 then 1
								else 0
						   end) as issues03G3
				from   #cteMain1 as a
			) ,
	issues2
		as
			(
				select 'PC1 Issues' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
				union all
				select '  DV' as [title] ,
					   convert(varchar, issues01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, issues01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, issues01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   issues1
				union all
				select '  MH' as [title] ,
					   convert(varchar, issues02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, issues02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, issues02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   issues1
				union all
				select '  SA' as [title] ,
					   convert(varchar, issues03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, issues03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, issues03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(issues03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   issues1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
			) ,
	trimester1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when Trimester = 1 then 1
								else 0
						   end) as trimester01 ,
					   sum(case when a.Status = '1'
									 and Trimester = 1 then 1
								else 0
						   end) as trimester01G1 ,
					   sum(case when a.Status = '2'
									 and Trimester = 1 then 1
								else 0
						   end) as trimester01G2 ,
					   sum(case when a.Status = '3'
									 and Trimester = 1 then 1
								else 0
						   end) as trimester01G3 ,
					   sum(case when Trimester = 2 then 1
								else 0
						   end) as trimester02 ,
					   sum(case when a.Status = '1'
									 and Trimester = 2 then 1
								else 0
						   end) as trimester02G1 ,
					   sum(case when a.Status = '2'
									 and Trimester = 2 then 1
								else 0
						   end) as trimester02G2 ,
					   sum(case when a.Status = '3'
									 and Trimester = 2 then 1
								else 0
						   end) as trimester02G3 ,
					   sum(case when Trimester = 3 then 1
								else 0
						   end) as trimester03 ,
					   sum(case when a.Status = '1'
									 and Trimester = 3 then 1
								else 0
						   end) as trimester03G1 ,
					   sum(case when a.Status = '2'
									 and Trimester = 3 then 1
								else 0
						   end) as trimester03G2 ,
					   sum(case when a.Status = '3'
									 and Trimester = 3 then 1
								else 0
						   end) as trimester03G3 ,
					   sum(case when Trimester = 4 then 1
								else 0
						   end) as trimester04 ,
					   sum(case when a.Status = '1'
									 and Trimester = 4 then 1
								else 0
						   end) as trimester04G1 ,
					   sum(case when a.Status = '2'
									 and Trimester = 4 then 1
								else 0
						   end) as trimester04G2 ,
					   sum(case when a.Status = '3'
									 and Trimester = 4 then 1
								else 0
						   end) as trimester04G3
				from   #cteMain1 as a
			) ,
	trimester2
		as
			(
				select 'Trimester (at time of Enrollment/Discharge)' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
				union all
				select '  1st' as [title] ,
					   convert(varchar, trimester01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, trimester01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, trimester01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   trimester1
				union all
				select '  2nd' as [title] ,
					   convert(varchar, trimester02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, trimester02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, trimester02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   trimester1
				union all
				select '  3rd' as [title] ,
					   convert(varchar, trimester03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, trimester03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, trimester03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   trimester1
				union all
				select '  Postnatal' as [title] ,
					   convert(varchar, trimester04G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester04G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, trimester04G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester04G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, trimester04G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(trimester04G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   trimester1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
			) ,
	assessment1
		as
			(
				select sum(case when a.Status = '1' then 1
								else 0
						   end) as totalG1 ,
					   sum(case when a.Status = '2' then 1
								else 0
						   end) as totalG2 ,
					   sum(case when a.Status = '3' then 1
								else 0
						   end) as totalG3 ,
					   sum(case when presentCode = 1 then 1
								else 0
						   end) as assessment01 ,
					   sum(case when a.Status = '1'
									 and presentCode = 1 then 1
								else 0
						   end) as assessment01G1 ,
					   sum(case when a.Status = '2'
									 and presentCode = 1 then 1
								else 0
						   end) as assessment01G2 ,
					   sum(case when a.Status = '3'
									 and presentCode = 1 then 1
								else 0
						   end) as assessment01G3 ,
					   sum(case when presentCode = 2 then 1
								else 0
						   end) as assessment02 ,
					   sum(case when a.Status = '1'
									 and presentCode = 2 then 1
								else 0
						   end) as assessment02G1 ,
					   sum(case when a.Status = '2'
									 and presentCode = 2 then 1
								else 0
						   end) as assessment02G2 ,
					   sum(case when a.Status = '3'
									 and presentCode = 2 then 1
								else 0
						   end) as assessment02G3 ,
					   sum(case when presentCode = 3 then 1
								else 0
						   end) as assessment03 ,
					   sum(case when a.Status = '1'
									 and presentCode = 3 then 1
								else 0
						   end) as assessment03G1 ,
					   sum(case when a.Status = '2'
									 and presentCode = 3 then 1
								else 0
						   end) as assessment03G2 ,
					   sum(case when a.Status = '3'
									 and presentCode = 3 then 1
								else 0
						   end) as assessment03G3 ,
					   sum(case when presentCode = 4 then 1
								else 0
						   end) as assessment04 ,
					   sum(case when a.Status = '1'
									 and presentCode = 4 then 1
								else 0
						   end) as assessment04G1 ,
					   sum(case when a.Status = '2'
									 and presentCode = 4 then 1
								else 0
						   end) as assessment04G2 ,
					   sum(case when a.Status = '3'
									 and presentCode = 4 then 1
								else 0
						   end) as assessment04G3
				from   #cteMain1 as a
			) ,
	assessment2
		as
			(
				select 'Present at Assessment' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
				union all
				select '  MOB only' as [title] ,
					   convert(varchar, assessment01G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment01G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, assessment01G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment01G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, assessment01G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment01G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   assessment1
				union all
				select '  FOB Only' as [title] ,
					   convert(varchar, assessment02G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment02G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, assessment02G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment02G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, assessment02G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment02G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   assessment1
				union all
				select '  Both Parents' as [title] ,
					   convert(varchar, assessment03G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment03G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, assessment03G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment03G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, assessment03G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment03G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   assessment1
				union all
				select '  Parent and Other' as [title] ,
					   convert(varchar, assessment04G1) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment04G1 as float) * 100
									 / nullif(totalG1, 0) ,
									 0) ,
								 0)) + '%)' as col1 ,
					   convert(varchar, assessment04G2) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment04G2 as float) * 100
									 / nullif(totalG2, 0) ,
									 0) ,
								 0)) + '%)' as col2 ,
					   convert(varchar, assessment04G3) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(assessment04G3 as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   assessment1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
			) ,
	refused1
		as
			(
				select count(*) as totalG3 ,
					   sum(case when DischargeReason = '36' then 1
								else 0
						   end) [Refused] ,
					   sum(case when DischargeReason = '12' then 1
								else 0
						   end) [UnableToLocate] ,
					   sum(case when DischargeReason = '19' then 1
								else 0
						   end) [TCAgedOut] ,
					   sum(case when DischargeReason = '07' then 1
								else 0
						   end) [OutOfTargetArea] ,
					   sum(case when DischargeReason in ( '25' ) then 1
								else 0
						   end) [Transfered] ,
					   sum(case when DischargeReason not in ( '36', '12' ,
															  '19' , '07' ,
															  '25' ) then 1
								else 0
						   end) [AllOthers]
				from   #cteMain1 as a
				where  a.Status = '3'
			) ,
	refused2
		as
			(
				select 'Reason for Refused' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
				union all
				select '  Refused' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   convert(varchar, Refused) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Refused as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   refused1
				union all
				select '  Unable To Locate' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   convert(varchar, UnableToLocate) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(UnableToLocate as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   refused1
				union all
				select '  TC Aged Out' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   convert(varchar, TCAgedOut) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(TCAgedOut as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   refused1
				union all
				select '  Out of Target Area' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   convert(varchar, OutOfTargetArea) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(OutOfTargetArea as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   refused1
				union all
				select '  Transfered' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   convert(varchar, Transfered) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(Transfered as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   refused1
				union all
				select '  All Others' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   convert(varchar, AllOthers) + ' ('
					   + convert(
							 varchar ,
							 round(
								 coalesce(
									 cast(AllOthers as float) * 100
									 / nullif(totalG3, 0) ,
									 0) ,
								 0)) + '%)' as col3 ,
					   '3' as col4
				from   refused1
				union all
				select '' as [title] ,
					   '' as col1 ,
					   '' as col2 ,
					   '' as col3 ,
					   '3' as col4
			) ,
	rpt1
		as
			(
				select *
				from   total2
				union all
				select *
				from   total3
				union all
				select *
				from   age2
				union all
				select *
				from   race2
				union all
				select *
				from   martial2
				union all
				select *
				from   edu2
				union all
				select *
				from   employed2
				union all
				select *
				from   inHome2
				union all
				select *
				from   score2
				union all
				select *
				from   kempescore2
				union all
				select *
				from   issues2
				union all
				select *
				from   trimester2
				union all
				select *
				from   assessment2
				union all
				select *
				from   refused2
			)

	-- listing records
	--SELECT * 
	--FROM main1 AS a
	--WHERE a.Status = 3

	select title as [Title] ,
		   col1 as [AcceptedFirstVisitEnrolled] ,
		   col2 as [AcceptedFirstVisitNotEnrolled] ,
		   col3 as [Refused] ,
		   col4 as [groupID]
	from   rpt1;

	drop table #cteMain;
	drop table #cteMain1;
GO
