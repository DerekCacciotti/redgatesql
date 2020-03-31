SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
	exec alter-procedure-rspCredentialingKempeAnalysis_Summary
*/
-- =============================================
-- Author:		<Dar Chen>
-- Create date: <04/04/2016>
-- Description:	<This Credentialing report gets you 'Summary for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Summary 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Summary 1, '04/01/2012', '03/31/2013'
-- rspCredentialingKempeAnalysis_Summary 6, '05/01/2017', '04/30/2018'
-- =============================================
CREATE procedure [dbo].[rspCredentialingKempeAnalysis_Summary] 
(@programfk varchar(max) = null
	, @StartDate datetime
	, @EndDate datetime
	, @WorkerFK int
)
as
begin
	if 1=0 begin
		set fmtOnly off
	end

	--declare @ProgramFK varchar(max), 
	--		@StartDate datetime,
	--		@EndDate datetime;
	--set @ProgramFK = '6'
	--set @StartDate = '2017-04-01'
	--set @EndDate = '2018-03-31'

	declare @programfkX varchar(max) ;
	declare @StartDateX datetime = @StartDate ;
	declare @EndDateX datetime = @EndDate ;
	declare @TotalRefused int
	declare @GrandTotalN int

	if @programfk is null
		begin
			select	@programfk = substring((
										select	','+ltrim(rtrim(str(HVProgramPK)))
										from	HVProgram
										for xml path('')
										), 2, 8000
										) ;
		end ;

	set @programfk = replace(@programfk, '"', '') ;
	set @programfkX = @programfk ;
	set @StartDateX = @StartDate ;
	set @EndDateX = @EndDate ;

	if object_id('tempdb..#cteMain') is not null
		drop table #cteMain ;
	if object_id('tempdb..#cteMain1') is not null
		drop table #cteMain1 ;

	create table #cteMain (
						HVCasePK	int
					, tcdob datetime
					, DischargeDate datetime
					, IntakeDate datetime
					, KempeDate datetime
					, PC1FK int
					, DischargeReason char(2)
					, OldID char(23)
					, PC1ID char(13)
					, KempeResult bit
					, cCurrentFSWFK int
					, cCurrentFAWFK int
					, babydate datetime
					, testdate datetime
					, PCDOB datetime
					, Race_AmericanIndian bit
					, Race_Asian bit
					, Race_Black bit
					, Race_Hawaiian bit
					, Race_White bit
					, Race_Hispanic bit
					, Race_Other bit
					, MaritalStatus char(2)
					, HighestGrade char(2)
					, IsCurrentlyEmployed char(1)
					, MomScore int
					, DadScore int
					, PIVisitMade int
					, DV int
					, MH int
					, SA int
					, presentCode int
					, MaxParity int
					, PrimaryLanguage char(2)
					, DaysBetween int
					, ReferralSourceType char(2)
					, ReferralSourceName char(20)
						) ;

	create table #cteMain1 (
						Status char(1)
					, [IntakeDate2] datetime
					, [KempeResult2] bit
					, [PIVisitMade2] int
					, [DischargeDate2] datetime
					, [DischargeReason2] char(2)
					, age int
					, KempeScore int
					, Trimester int
					, HVCasePK int
					, tcdob datetime
					, DischargeDate datetime
					, IntakeDate datetime
					, KempeDate datetime
					, PC1FK int
					, DischargeReason char(2)
					, OldID char(23)
					, PC1ID char(13)
					, KempeResult bit
					, cCurrentFSWFK int
					, cCurrentFAWFK int
					, babydate datetime
					, testdate datetime
					, PCDOB datetime
					, Race_AmericanIndian bit
					, Race_Asian bit
					, Race_Black bit
					, Race_Hawaiian bit
					, Race_White bit
					, Race_Hispanic bit
					, Race_Other bit
					, MaritalStatus char(2)
					, HighestGrade char(2)
					, IsCurrentlyEmployed char(1)
					, MomScore int
					, DadScore int
					, PIVisitMade int
					, DV int
					, MH int
					, SA int
					, presentCode int
					, MaxParity int
					, PrimaryLanguage char(2)
					, DaysBetween int
					, ReferralSourceType char(2)
					, ReferralSourceName char(20)
						) ;
	with ctePIVisits
	as (
		select		KempeFK
				, sum(case when PIVisitMade > 0 then 1 else 0 end) PIVisitMade
		from		Preintake pi
		inner join	dbo.SplitString(@programfk, ',') on pi.ProgramFK = ListItem
		group by	KempeFK
	)
	,	ctePreviousPC1Issue
	as (
		select		min(PC1IssuesPK) as PC1IssuesPK
				, HVCaseFK
		from		PC1Issues
		inner join	dbo.SplitString(@programfk, ',') on PC1Issues.ProgramFK = ListItem
		where		rtrim(Interval) = '1'
		group by	HVCaseFK
	)
	,	cteIssues
	as (
		select	a.HVCaseFK
			, case when DomesticViolence = 1 then 1 else 0 end as DV
			, case when (Depression = 1 or MentalIllness = 1) then 1 else 0 end as MH
			, case when (AlcoholAbuse = 1 or SubstanceAbuse = 1) then 1 else 0 end as SA
		from	PC1Issues a
		inner join
				(
				select		min(PC1IssuesPK) as PC1IssuesPK
						, HVCaseFK
				from		PC1Issues
				where		rtrim(Interval) = '1'
				group by	HVCaseFK
				) b on a.PC1IssuesPK = b.PC1IssuesPK
	)
	insert	into #cteMain
		(
			HVCasePK
		, tcdob
		, DischargeDate
		, IntakeDate
		, KempeDate
		, PC1FK
		, DischargeReason
		, OldID
		, PC1ID
		, KempeResult
		, cCurrentFSWFK
		, cCurrentFAWFK
		, babydate
		, testdate
		, PCDOB
		, Race_AmericanIndian
		, Race_Asian
		, Race_Black
		, Race_Hawaiian
		, Race_White
		, Race_Hispanic
		, Race_Other
		, MaritalStatus
		, HighestGrade
		, IsCurrentlyEmployed
		, MomScore
		, DadScore
		, PIVisitMade
		, DV
		, MH
		, SA
		, presentCode
		, MaxParity
		, PrimaryLanguage
		, DaysBetween
		, ReferralSourceType
		, ReferralSourceName
		)
	select			HVCasePK
				, case when h.TCDOB is not null then h.TCDOB else h.EDC end as tcdob
				, DischargeDate
				, IntakeDate
				, k.KempeDate
				, PC1FK
				, cp.DischargeReason
				, OldID
				, PC1ID
				, KempeResult
				, cp.CurrentFSWFK
				, cp.CurrentFAWFK
				, case when h.TCDOB is not null then h.TCDOB else h.EDC end as babydate
				, case when h.IntakeDate is not null then h.IntakeDate
					else cp.DischargeDate end as testdate
				, P.PCDOB
				, Race_AmericanIndian
				, Race_Asian
				, Race_Black
				, Race_Hawaiian
				, Race_White
				, Race_Hispanic
				, Race_Other
				, ca.MaritalStatus
				, ca.HighestGrade
				, ca.IsCurrentlyEmployed
				, case when MomScore = 'U' then 0 else cast(MomScore as int)end as MomScore
				, case when DadScore = 'U' then 0 else cast(DadScore as int)end as DadScore
				, PIVisitMade
				, i.DV
				, i.MH
				, i.SA
				, case when
							(
							isnull(k.MOBPartnerPresent, 0) = 0 and	isnull(k.FOBPartnerPresent, 0) = 0
							and isnull(k.GrandParentPresent, 0) = 0 and isnull(k.OtherPresent, 0) = 0
							) then case when k.MOBPresent = 1 and	k.FOBPresent = 1 then 3 -- both parent
									when k.MOBPresent = 1 then 1 -- MOB Only
									when k.FOBPresent = 1 then 2 -- FOB Only
									else 4 -- parent/other
									end
					else 4 -- parent/other
					end presentCode
				, convert(int, case when catc.Parity is not null then catc.Parity
									when catc.Parity is null and ca.Parity is not null then ca.Parity
									else '-1'
								end) as MaxParity
				, cain.PrimaryLanguage
				, datediff(day, h.ScreenDate, h.KempeDate) as DaysBetween
				, ReferralSource as ReferralSourceType
				, left(capp.AppCodeText, 20)  as ReferralSourceName
	from			HVCase h
	inner join		CaseProgram cp on cp.HVCaseFK = h.HVCasePK
	inner join		dbo.SplitString(@programfkX, ',') on cp.ProgramFK = ListItem
	inner join		Kempe k on k.HVCaseFK = h.HVCasePK
	inner join		HVScreen hs on hs.HVCaseFK = h.HVCasePK
	inner join		PC P on P.PCPK = h.PC1FK
	inner join codeApp capp on hs.ReferralSource = capp.AppCode and capp.AppCodeGroup = 'TypeofReferral' 
	left outer join ctePIVisits piv on piv.KempeFK = k.KempePK
	left outer join cteIssues i on i.HVCaseFK = h.HVCasePK
	left join		CommonAttributes ca on ca.HVCaseFK = h.HVCasePK and ca.FormType = 'KE'
	left join		CommonAttributes catc on catc.HVCaseFK = h.HVCasePK and catc.FormType = 'TC'
	left join		CommonAttributes cain on cain.HVCaseFK = h.HVCasePK and cain.FormType = 'IN-PC1'
	where			(h.IntakeDate is not null or cp.DischargeDate is not null) -- only include kempes that are positive and where there is a clos_date or an intake date.
						and k.KempeResult = 1 
						and k.KempeDate between @StartDateX and @EndDateX 
						and cp.CurrentFAWFK = isnull(@WorkerFK, cp.CurrentFAWFK) ;

	insert into #cteMain1
	select	case when IntakeDate is not null then '1' --'AcceptedFirstVisitEnrolled' 
			when KempeResult = 1 and IntakeDate is null and DischargeDate is not null
				and (PIVisitMade > 0 and PIVisitMade is not null) then '2' -- 'AcceptedFirstVisitNotEnrolled'
			else '3' -- 'Refused' 
			end Status
		, a.IntakeDate as [IntakeDate2]
		, a.KempeResult as [KempeResult2]
		, a.PIVisitMade as [PIVisitMade2]
		, a.DischargeDate as [DischargeDate2]
		, a.DischargeReason as [DischargeReason2]
		, datediff(day, PCDOB, testdate)/ 365.25 as age
		, case when a.MomScore > a.DadScore then a.MomScore else a.DadScore end KempeScore
		, case when datediff(d, testdate, babydate) > 0 and datediff(d, testdate, babydate) < 30.44 * 3 then
				3
		when
			(
			datediff(d, testdate, babydate) >= 30.44 * 3
			and datediff(d, testdate, babydate) < 30.44 * 6
			) then 2
		when datediff(d, testdate, babydate) >= round(30.44 * 6, 0) then 1
		when datediff(d, testdate, babydate) <= 0 then 4 end as Trimester
		, a.HVCasePK
		, a.tcdob
		, a.DischargeDate
		, a.IntakeDate
		, a.KempeDate
		, a.PC1FK
		, a.DischargeReason
		, a.OldID
		, a.PC1ID
		, a.KempeResult
		, a.cCurrentFSWFK
		, a.cCurrentFAWFK
		, a.babydate
		, a.testdate
		, a.PCDOB
		, Race_AmericanIndian
		, Race_Asian
		, Race_Black
		, Race_Hawaiian
		, Race_White
		, Race_Hispanic
		, Race_Other
		, a.MaritalStatus
		, a.HighestGrade
		, a.IsCurrentlyEmployed
		, a.MomScore
		, a.DadScore
		, a.PIVisitMade
		, a.DV
		, a.MH
		, a.SA
		, a.presentCode
		, a.MaxParity
		, a.PrimaryLanguage
		, a.DaysBetween
		, a.ReferralSourceType
		, a.ReferralSourceName
	from	#cteMain as a ;

	--select * from #cteMain cm
	--select *
	--from #cteMain1 cm
	--inner join CaseProgram cp on cm.HVCasePK = cp.HVCaseFK
	
	select @TotalRefused = count(HVCasePK)
	from #ctemain1 m
	where Status = '3' ;

	select	@GrandTotalN = count(*)
	from	#cteMain1 m ;
	
	with total1
	as (
		select	count(*) as total
			, sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
		from	#cteMain1 as a
	)
	,	total2
	as (
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '0' as GroupID
		union all
		select	'Totals (N = '+convert(varchar, total)+')' as [title]
			, total as TotalN
			, totalG1 as AcceptedFirstVisitEnrolled
			--, round(coalesce(cast(totalG1 as float)* 100 / nullif(total, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, totalG2 as AcceptedFirstVisitNotEnrolled
			--, convert(varchar, round(coalesce(cast(totalG2 as float)* 100 / nullif(total, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, totalG3 as Refused
			--, convert(varchar, round(coalesce(cast(totalG3 as float)* 100 / nullif(total, 0), 0), 0)) as RefusedPercent
			, '0' as GroupID
		from	total1
	)
	,	total3
	as (
		select	'Acceptance Rate - '
				+convert(
							varchar
						, round(
									coalesce(
												cast((totalG1+totalG2) as float)* 100
												/ nullif(total, 0), 0
											), 0
								)
						)+'%' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '0' as GroupID
		from	total1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '0' as GroupID
	)
	,	age1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when age < 18 then 1 else 0 end) as age18
			, sum(case when a.Status = '1' and age < 18 then 1 else 0 end) as age18G1
			, sum(case when a.Status = '2' and age < 18 then 1 else 0 end) as age18G2
			, sum(case when a.Status = '3' and age < 18 then 1 else 0 end) as age18G3
			, sum(case when (age >= 18 and age < 20) then 1 else 0 end) as age20
			, sum(case when a.Status = '1' and (age >= 18 and age < 20) then 1 else 0 end) as age20G1
			, sum(case when a.Status = '2' and (age >= 18 and age < 20) then 1 else 0 end) as age20G2
			, sum(case when a.Status = '3' and (age >= 18 and age < 20) then 1 else 0 end) as age20G3
			, sum(case when (age >= 20 and age < 30) then 1 else 0 end) as age30
			, sum(case when a.Status = '1' and (age >= 20 and age < 30) then 1 else 0 end) as age30G1
			, sum(case when a.Status = '2' and (age >= 20 and age < 30) then 1 else 0 end) as age30G2
			, sum(case when a.Status = '3' and (age >= 20 and age < 30) then 1 else 0 end) as age30G3
			, sum(case when (age >= 30) then 1 else 0 end) as age40
			, sum(case when a.Status = '1' and (age >= 30) then 1 else 0 end) as age40G1
			, sum(case when a.Status = '2' and (age >= 30) then 1 else 0 end) as age40G2
			, sum(case when a.Status = '3' and (age >= 30) then 1 else 0 end) as age40G3
		from	#cteMain1 as a
	)
	--select * from age1

	,	age2
	as (
		select 'Age' as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
		union all
		select	'  Under 18' as [title]
			, age18 as TotalN 
			, age18G1 as AcceptedFirstVisitEnrolled
			--, round(coalesce(cast(age18G1 as float)* 100 / nullif(age18, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, age18G2 as AcceptedFirstVisitNotEnrolled
			--, round(coalesce(cast(age18G2 as float)* 100 / nullif(age18, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, age18G3 as Refused
			--, round(coalesce(cast(age18G3 as float)* 100 / nullif(age18, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	age1
		union all
		select	'  18 up to 20' as [title]
			, age20 as TotalN 
			, age20G1 as AcceptedFirstVisitEnrolled
			--, round(coalesce(cast(age20G1 as float)* 100 / nullif(age20, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, age20G2 as AcceptedFirstVisitNotEnrolled
			--, round(coalesce(cast(age20G2 as float)* 100 / nullif(age20, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, age20G3 as Refused
			--, round(coalesce(cast(age20G3 as float)* 100 / nullif(age20, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	age1
		union all
		select	'  20 up to 30' as [title]
			, age30 as TotalN 
			, age30G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(age30G1 as float)* 100 / nullif(age30, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, age30G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(age30G2 as float)* 100 / nullif(age30, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, age30G3 as Refused
			-- , round(coalesce(cast(age30G3 as float)* 100 / nullif(age30, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	age1
		union all
		select	'  30 and over' as [title]
			, age40 as TotalN 
			, age40G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(age40G1 as float)* 100 / nullif(age40, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, age40G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(age40G2 as float)* 100 / nullif(age40, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, age40G3 as Refused
			-- , round(coalesce(cast(age40G3 as float)* 100 / nullif(age40, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	age1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
	)
	--select * from age2

	,	edu1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when HighestGrade in ('01', '02') then 1 else 0 end) as HighestGrade01
			, sum(	case when a.Status = '1' and	HighestGrade in ('01', '02') then 1
					else 0 end
				) as HighestGrade01G1
			, sum(	case when a.Status = '2' and	HighestGrade in ('01', '02') then 1
					else 0 end
				) as HighestGrade01G2
			, sum(	case when a.Status = '3' and	HighestGrade in ('01', '02') then 1
					else 0 end
				) as HighestGrade01G3
			, sum(case when HighestGrade in ('03', '04') then 1 else 0 end) as HighestGrade02
			, sum(	case when a.Status = '1' and	HighestGrade in ('03', '04') then 1
					else 0 end
				) as HighestGrade02G1
			, sum(	case when a.Status = '2' and	HighestGrade in ('03', '04') then 1
					else 0 end
				) as HighestGrade02G2
			, sum(	case when a.Status = '3' and	HighestGrade in ('03', '04') then 1
					else 0 end
				) as HighestGrade02G3
			, sum(case when HighestGrade in ('05', '06', '07', '08') then 1 else 0 end) as HighestGrade03
			, sum(	case when a.Status = '1' and	HighestGrade in ('05', '06', '07', '08') then 1
					else 0 end
				) as HighestGrade03G1
			, sum(	case when a.Status = '2' and	HighestGrade in ('05', '06', '07', '08') then 1
					else 0 end
				) as HighestGrade03G2
			, sum(	case when a.Status = '3' and	HighestGrade in ('05', '06', '07', '08') then 1
					else 0 end
				) as HighestGrade03G3
			, sum(case when HighestGrade is null then 1 else 0 end) as HighestGrade04
			, sum(case when a.Status = '1' and HighestGrade is null then 1 else 0 end) as HighestGrade04G1
			, sum(case when a.Status = '2' and HighestGrade is null then 1 else 0 end) as HighestGrade04G2
			, sum(case when a.Status = '3' and HighestGrade is null then 1 else 0 end) as HighestGrade04G3
		from	#cteMain1 as a
	)
	,	edu2
	as (
		select	'Education' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '1' as GroupID
		union all
		select	'  Less than 12' as [title]
			, HighestGrade01 as TotalN 
			, HighestGrade01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(HighestGrade01G1 as float)* 100 / nullif(HighestGrade01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, HighestGrade01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(HighestGrade01G2 as float)* 100 / nullif(HighestGrade01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, HighestGrade01G3 as Refused
			-- , round(coalesce(cast(HighestGrade01G3 as float)* 100 / nullif(HighestGrade01, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	edu1
		union all
		select	'  HS/GED' as [title]
			, HighestGrade02 as TotalN 
			, HighestGrade02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(HighestGrade02G1 as float)* 100 / nullif(HighestGrade02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, HighestGrade02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(HighestGrade02G2 as float)* 100 / nullif(HighestGrade02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, HighestGrade02G3 as Refused
			-- , round(coalesce(cast(HighestGrade02G3 as float)* 100 / nullif(HighestGrade02, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	edu1
		union all
		select	'  More than 12' as [title]
			, HighestGrade03 as TotalN 
			, HighestGrade03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(HighestGrade03G1 as float)* 100 / nullif(HighestGrade03, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, HighestGrade03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(HighestGrade03G2 as float)* 100 / nullif(HighestGrade03, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, HighestGrade03G3 as Refused
			-- , round(coalesce(cast(HighestGrade03G3 as float)* 100 / nullif(HighestGrade03, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	edu1
		union all
		select	'  Unknown' as [title]
			, HighestGrade04 as TotalN 
			, HighestGrade04G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(HighestGrade04G1 as float)* 100 / nullif(HighestGrade04, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, HighestGrade04G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(HighestGrade04G2 as float)* 100 / nullif(HighestGrade04, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, HighestGrade04G3 as Refused
			-- , round(coalesce(cast(HighestGrade04G3 as float)* 100 / nullif(HighestGrade04, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	edu1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
	)
	,	employed1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when IsCurrentlyEmployed = 1 then 1 else 0 end) as Employed01
			, sum(case when a.Status = '1' and IsCurrentlyEmployed = 1 then 1 else 0 end) as Employed01G1
			, sum(case when a.Status = '2' and IsCurrentlyEmployed = 1 then 1 else 0 end) as Employed01G2
			, sum(case when a.Status = '3' and IsCurrentlyEmployed = 1 then 1 else 0 end) as Employed01G3
			, sum(case when IsCurrentlyEmployed = 0 then 1 else 0 end) as Employed02
			, sum(case when a.Status = '1' and IsCurrentlyEmployed = 0 then 1 else 0 end) as Employed02G1
			, sum(case when a.Status = '2' and IsCurrentlyEmployed = 0 then 1 else 0 end) as Employed02G2
			, sum(case when a.Status = '3' and IsCurrentlyEmployed = 0 then 1 else 0 end) as Employed02G3
		from	#cteMain1 as a
	)
	,	employed2
	as (
		select	'Employed' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '1' as GroupID
		union all
		select	'  Yes' as [title]
			, Employed01 as TotalN 
			, Employed01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(Employed01G1 as float)* 100 / nullif(Employed01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, Employed01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(Employed01G2 as float)* 100 / nullif(Employed01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, Employed01G3 as Refused
			-- , round(coalesce(cast(Employed01G3 as float)* 100 / nullif(Employed01, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	employed1
		union all
		select	'  No' as [title]
			, Employed02 as TotalN 
			, Employed02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(Employed02G1 as float)* 100 / nullif(Employed02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, Employed02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(Employed02G2 as float)* 100 / nullif(Employed02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, Employed02G3 as Refused
			-- , round(coalesce(cast(Employed02G3 as float)* 100 / nullif(Employed02, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	employed1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
	)
	,	marital1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when MaritalStatus = '01' then 1 else 0 end) as MaritalStatus01
			, sum(case when a.Status = '1' and MaritalStatus = '01' then 1 else 0 end) as MaritalStatus01G1
			, sum(case when a.Status = '2' and MaritalStatus = '01' then 1 else 0 end) as MaritalStatus01G2
			, sum(case when a.Status = '3' and MaritalStatus = '01' then 1 else 0 end) as MaritalStatus01G3
			, sum(case when MaritalStatus = '02' then 1 else 0 end) as MaritalStatus02
			, sum(case when a.Status = '1' and MaritalStatus = '02' then 1 else 0 end) as MaritalStatus02G1
			, sum(case when a.Status = '2' and MaritalStatus = '02' then 1 else 0 end) as MaritalStatus02G2
			, sum(case when a.Status = '3' and MaritalStatus = '02' then 1 else 0 end) as MaritalStatus02G3
			, sum(case when MaritalStatus = '03' then 1 else 0 end) as MaritalStatus03
			, sum(case when a.Status = '1' and MaritalStatus = '03' then 1 else 0 end) as MaritalStatus03G1
			, sum(case when a.Status = '2' and MaritalStatus = '03' then 1 else 0 end) as MaritalStatus03G2
			, sum(case when a.Status = '3' and MaritalStatus = '03' then 1 else 0 end) as MaritalStatus03G3
			, sum(case when MaritalStatus = '04' then 1 else 0 end) as MaritalStatus04
			, sum(case when a.Status = '1' and MaritalStatus = '04' then 1 else 0 end) as MaritalStatus04G1
			, sum(case when a.Status = '2' and MaritalStatus = '04' then 1 else 0 end) as MaritalStatus04G2
			, sum(case when a.Status = '3' and MaritalStatus = '04' then 1 else 0 end) as MaritalStatus04G3
			, sum(case when MaritalStatus = '05' then 1 else 0 end) as MaritalStatus05
			, sum(case when a.Status = '1' and MaritalStatus = '05' then 1 else 0 end) as MaritalStatus05G1
			, sum(case when a.Status = '2' and MaritalStatus = '05' then 1 else 0 end) as MaritalStatus05G2
			, sum(case when a.Status = '3' and MaritalStatus = '05' then 1 else 0 end) as MaritalStatus05G3
			, sum(	case when
							(
							MaritalStatus is null
							or MaritalStatus not in ('01', '02', '03', '04', '05')
							) then 1
					else 0 end
				) as MaritalStatus06
			, sum(	case when a.Status = '1'
							and
								(
								MaritalStatus is null
								or	MaritalStatus not in ('01', '02', '03', '04', '05')
								) then 1
					else 0 end
				) as MaritalStatus06G1
			, sum(	case when a.Status = '2'
							and
								(
								MaritalStatus is null
								or	MaritalStatus not in ('01', '02', '03', '04', '05')
								) then 1
					else 0 end
				) as MaritalStatus06G2
			, sum(	case when a.Status = '3'
							and
								(
								MaritalStatus is null
								or	MaritalStatus not in ('01', '02', '03', '04', '05')
								) then 1
					else 0 end
				) as MaritalStatus06G3
		from	#cteMain1 as a
	)
	,	marital2
	as (
		select	'Marital Status' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '1' as GroupID
		union all
		select	'  Married' as [title]
			, MaritalStatus01 as TotalN 
			, MaritalStatus01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(MaritalStatus01G1 as float)* 100 / nullif(MaritalStatus01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, MaritalStatus01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(MaritalStatus01G2 as float)* 100 / nullif(MaritalStatus01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, MaritalStatus01G3 as Refused
			-- , round(coalesce(cast(MaritalStatus01G3 as float)* 100 / nullif(MaritalStatus01, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	marital1
		union all
		select	'  Not Married' as [title]
			, MaritalStatus02 as TotalN 
			, MaritalStatus02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(MaritalStatus02G1 as float)* 100 / nullif(MaritalStatus02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, MaritalStatus02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(MaritalStatus02G2 as float)* 100 / nullif(MaritalStatus02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, MaritalStatus02G3 as Refused
			-- , round(coalesce(cast(MaritalStatus02G3 as float)* 100 / nullif(MaritalStatus02, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	marital1
		union all
		select	'  Separated' as [title]
			, MaritalStatus03 as TotalN 
			, MaritalStatus03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(MaritalStatus03G1 as float)* 100 / nullif(MaritalStatus03, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, MaritalStatus03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(MaritalStatus03G2 as float)* 100 / nullif(MaritalStatus03, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, MaritalStatus03G3 as Refused
			-- , round(coalesce(cast(MaritalStatus03G3 as float)* 100 / nullif(MaritalStatus03, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	marital1
		union all
		select	'  Divorced' as [title]
			, MaritalStatus04 as TotalN 
			, MaritalStatus04G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(MaritalStatus04G1 as float)* 100 / nullif(MaritalStatus04, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, MaritalStatus04G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(MaritalStatus04G2 as float)* 100 / nullif(MaritalStatus04, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, MaritalStatus04G3 as Refused
			-- , round(coalesce(cast(MaritalStatus04G3 as float)* 100 / nullif(MaritalStatus04, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	marital1
		union all
		select	'  Widowed' as [title]
			, MaritalStatus05 as TotalN 
			, MaritalStatus05G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(MaritalStatus05G1 as float)* 100 / nullif(MaritalStatus05, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, MaritalStatus05G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(MaritalStatus05G2 as float)* 100 / nullif(MaritalStatus05, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, MaritalStatus05G3 as Refused
			-- , round(coalesce(cast(MaritalStatus05G3 as float)* 100 / nullif(MaritalStatus05, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	marital1
		union all
		select	'  Unknown' as [title]
			, MaritalStatus06 as TotalN 
			, MaritalStatus06G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(MaritalStatus06G1 as float)* 100 / nullif(MaritalStatus06, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, MaritalStatus06G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(MaritalStatus06G2 as float)* 100 / nullif(MaritalStatus06, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, MaritalStatus06G3 as Refused
			-- , round(coalesce(cast(MaritalStatus06G3 as float)* 100 / nullif(MaritalStatus06, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	marital1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
	)
	,	parity1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when a.MaxParity = 0 then 1 else 0 end) as parityfirsttime
			, sum(case when a.Status = '1' and a.MaxParity = 0 then 1 else 0 end) as parityfirsttimeG1
			, sum(case when a.Status = '2' and a.MaxParity = 0 then 1 else 0 end) as parityfirsttimeG2
			, sum(case when a.Status = '3' and a.MaxParity = 0 then 1 else 0 end) as parityfirsttimeG3
			, sum(case when a.MaxParity = 1 then 1 else 0 end) as parity1prior
			, sum(case when a.Status = '1' and a.MaxParity = 1 then 1 else 0 end) as parity1priorG1
			, sum(case when a.Status = '2' and a.MaxParity = 1 then 1 else 0 end) as parity1priorG2
			, sum(case when a.Status = '3' and a.MaxParity = 1 then 1 else 0 end) as parity1priorG3
			, sum(case when a.MaxParity >= 2 then 1 else 0 end) as parity2ormoreprior
			, sum(case when a.Status = '1' and a.MaxParity >= 2 then 1 else 0 end) as parity2ormorepriorG1
			, sum(case when a.Status = '2' and a.MaxParity >= 2 then 1 else 0 end) as parity2ormorepriorG2
			, sum(case when a.Status = '3' and a.MaxParity >= 2 then 1 else 0 end) as parity2ormorepriorG3
			, sum(case when a.MaxParity = -1 then 1 else 0 end) as parityunknownmissing
			, sum(case when a.Status = '1' and a.MaxParity = -1 then 1 else 0 end) as parityunknownmissingG1
			, sum(case when a.Status = '2' and a.MaxParity = -1 then 1 else 0 end) as parityunknownmissingG2
			, sum(case when a.Status = '3' and a.MaxParity = -1 then 1 else 0 end) as parityunknownmissingG3
		from	#cteMain1 as a
	)
	,	parity2
	as (
		select 'Parity' as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
		union all
		select	'  First-time parent' as [title]
			, parityfirsttime as TotalN 
			, parityfirsttimeG1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(parity0G1 as float)* 100 / nullif(parity0, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, parityfirsttimeG2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(parity0G2 as float)* 100 / nullif(parity0, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, parityfirsttimeG3 as Refused
			-- , round(coalesce(cast(parity0G3 as float)* 100 / nullif(parity0, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	parity1
		union all
		select	'  1 prior child' as [title]
			, parity1prior as TotalN 
			, parity1priorG1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(parity1G1 as float)* 100 / nullif(parity1, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, parity1priorG2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(parity1G2 as float)* 100 / nullif(parity1, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, parity1priorG3 as Refused
			-- , round(coalesce(cast(parity1G3 as float)* 100 / nullif(parity1, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	parity1
		union all
		select	'  2 or more prior children' as [title]
			, parity2ormoreprior as TotalN 
			, parity2ormorepriorG1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(parity2G1 as float)* 100 / nullif(parity2, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, parity2ormorepriorG2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(parity2G2 as float)* 100 / nullif(parity2, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, parity2ormorepriorG3 as Refused
			-- , round(coalesce(cast(parity2G3 as float)* 100 / nullif(parity2, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	parity1
		union all
		select	'  Missing/Unknown' as [title]
			, parityunknownmissing as TotalN 
			, parityunknownmissingG1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(parity3G1 as float)* 100 / nullif(parity3, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, parityunknownmissingG2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(parity3G2 as float)* 100 / nullif(parity3, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, parityunknownmissingG3 as Refused
			-- , round(coalesce(cast(parity3G3 as float)* 100 / nullif(parity3, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	parity1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
	)
	,	primarylanguage1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when a.PrimaryLanguage = '01' then 1 else 0 end) as PrimaryLanguageEnglish
			, sum(case when a.Status = '1' and a.PrimaryLanguage = '01' then 1 else 0 end) as PrimaryLanguageEnglishG1
			, sum(case when a.Status = '2' and a.PrimaryLanguage = '01' then 1 else 0 end) as PrimaryLanguageEnglishG2
			, sum(case when a.Status = '3' and a.PrimaryLanguage = '01' then 1 else 0 end) as PrimaryLanguageEnglishG3
			, sum(case when a.PrimaryLanguage = '02' then 1 else 0 end) as PrimaryLanguageSpanish 
			, sum(case when a.Status = '1' and a.PrimaryLanguage = '02' then 1 else 0 end) as PrimaryLanguageSpanishG1
			, sum(case when a.Status = '2' and a.PrimaryLanguage = '02' then 1 else 0 end) as PrimaryLanguageSpanishG2
			, sum(case when a.Status = '3' and a.PrimaryLanguage = '02' then 1 else 0 end) as PrimaryLanguageSpanishG3
			, sum(case when a.PrimaryLanguage = '03' or PrimaryLanguage is null or PrimaryLanguage = ''
						then 1 else 0 end) as PrimaryLanguageOtherUnknown
			, sum(case when a.Status = '1' and (PrimaryLanguage = '03' or PrimaryLanguage is null or PrimaryLanguage = '')
						then 1 else 0 end) as PrimaryLanguageOtherUnknownG1
			, sum(case when a.Status = '2' and (PrimaryLanguage = '03' or PrimaryLanguage is null or PrimaryLanguage = '')
						then 1 else 0 end) as PrimaryLanguageOtherUnknownG2
			, sum(case when a.Status = '3' and (PrimaryLanguage = '03' or PrimaryLanguage is null or PrimaryLanguage = '')
						then 1 else 0 end) as PrimaryLanguageOtherUnknownG3
		from	#cteMain1 as a
	)
	,	primarylanguage2
	as (
		select 'Primary Language' as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
		union all
		select	'  English' as [title]
			, PrimaryLanguageEnglish as TotalN 
			, PrimaryLanguageEnglishG1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(PrimaryLanguageEnglishG1 as float)* 100 / nullif(PrimaryLanguageEnglish, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, PrimaryLanguageEnglishG2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(PrimaryLanguageEnglishG2 as float)* 100 / nullif(PrimaryLanguageEnglish, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, PrimaryLanguageEnglishG3 as Refused
			-- , round(coalesce(cast(PrimaryLanguageEnglishG3 as float)* 100 / nullif(PrimaryLanguageEnglish, 0), 0), 0)) as RefusedPercent
			, '1' as GroupID
		from	primarylanguage1
		union all
		select	'  Spanish' as [title]
			, PrimaryLanguageSpanish as TotalN 
			, PrimaryLanguageSpanishG1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(PrimaryLanguageSpanishG1 as float)* 100 / nullif(PrimaryLanguageSpanish, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, PrimaryLanguageSpanishG2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(PrimaryLanguageSpanishG2 as float)* 100 / nullif(PrimaryLanguageSpanish, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, PrimaryLanguageSpanishG3 as Refused
			-- , round(coalesce(cast(PrimaryLanguageSpanishG3 as float)* 100 / nullif(PrimaryLanguageSpanish, 0), 0), 0)) as RefusedPercent
			, '1' as GroupID
		from	primarylanguage1
		union all
		select	'  Other/Unknown' as [title]
			, PrimaryLanguageOtherUnknown as TotalN 
			, PrimaryLanguageOtherUnknownG1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(PrimaryLanguageOtherUnknownG1 as float)* 100 / nullif(PrimaryLanguageOtherUnknown, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, PrimaryLanguageOtherUnknownG2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(PrimaryLanguageOtherUnknownG2 as float)* 100 / nullif(PrimaryLanguageOtherUnknown, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, PrimaryLanguageOtherUnknownG3 as Refused
			-- , round(coalesce(cast(PrimaryLanguageOtherUnknownG3 as float)* 100 / nullif(PrimaryLanguageOtherUnknown, 0), 0), 0)) as RefusedPercent
			, '1' as GroupID
		from	primarylanguage1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
	)
	,	race1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when Race_White = 1 then 1 else 0 end) as race01
			, sum(case when a.Status = '1' and Race_White = 1 then 1 else 0 end) as race01G1
			, sum(case when a.Status = '2' and Race_White = 1 then 1 else 0 end) as race01G2
			, sum(case when a.Status = '3' and Race_White = 1 then 1 else 0 end) as race01G3
			, sum(case when Race_Black = 1 then 1 else 0 end) as race02
			, sum(case when a.Status = '1' and Race_Black = 1 then 1 else 0 end) as race02G1
			, sum(case when a.Status = '2' and Race_Black = 1 then 1 else 0 end) as race02G2
			, sum(case when a.Status = '3' and Race_Black = 1 then 1 else 0 end) as race02G3
			, sum(case when Race_Hispanic = 1 then 1 else 0 end) as race03
			, sum(case when a.Status = '1' and Race_Hispanic = 1 then 1 else 0 end) as race03G1
			, sum(case when a.Status = '2' and Race_Hispanic = 1 then 1 else 0 end) as race03G2
			, sum(case when a.Status = '3' and Race_Hispanic = 1 then 1 else 0 end) as race03G3
			, sum(case when Race_Asian = 1 then 1 else 0 end) as race04
			, sum(case when a.Status = '1' and Race_Asian = 1 then 1 else 0 end) as race04G1
			, sum(case when a.Status = '2' and Race_Asian = 1 then 1 else 0 end) as race04G2
			, sum(case when a.Status = '3' and Race_Asian = 1 then 1 else 0 end) as race04G3
			, sum(case when Race_AmericanIndian = 1 then 1 else 0 end) as race05
			, sum(case when a.Status = '1' and Race_AmericanIndian = 1 then 1 else 0 end) as race05G1
			, sum(case when a.Status = '2' and Race_AmericanIndian = 1 then 1 else 0 end) as race05G2
			, sum(case when a.Status = '3' and Race_AmericanIndian = 1 then 1 else 0 end) as race05G3
			, sum(case when Race_Hawaiian = 1 then 1 else 0 end) as race06
			, sum(case when a.Status = '1' and Race_Hawaiian = 1 then 1 else 0 end) as race06G1
			, sum(case when a.Status = '2' and Race_Hawaiian = 1 then 1 else 0 end) as race06G2
			, sum(case when a.Status = '3' and Race_Hawaiian = 1 then 1 else 0 end) as race06G3
			, sum(case when Race_Other = 1 then 1 else 0 end) as race07
			, sum(case when a.Status = '1' and Race_Other = 1  then 1 else 0 end) as race07G1
			, sum(case when a.Status = '2' and Race_Other = 1  then 1 else 0 end) as race07G2
			, sum(case when a.Status = '3' and Race_Other = 1  then 1 else 0 end) as race07G3
			, sum(case when dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1 then 1 else 0 end) as race08
			, sum(case when a.Status = '1' and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1 then 1 else 0 end) as race08G1
			, sum(case when a.Status = '2' and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1 then 1 else 0 end) as race08G2
			, sum(case when a.Status = '3' and dbo.fnIsRaceMissing(Race_AmericanIndian, Race_Asian, Race_Black, Race_Hawaiian, Race_White, Race_Other) = 1 then 1 else 0 end) as race08G3
		from	#cteMain1 as a
	)
	,	race2
	as (
		select 'Race' as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
		union all
		select	'  White' as [title]
			, race01 as TotalN 
			, race01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race01G1 as float)* 100 / nullif(race01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race01G2 as float)* 100 / nullif(race01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race01G3 as Refused
			-- , round(coalesce(cast(race01G3 as float)* 100 / nullif(race01, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select	'  Black' as [title]
			, race02 as TotalN 
			, race02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race02G1 as float)* 100 / nullif(race02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race02G2 as float)* 100 / nullif(race02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race02G3 as Refused
			-- , round(coalesce(cast(race02G3 as float)* 100 / nullif(race02, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select	'  Hispanic/Latina/Latino' as [title]
			, race03 as TotalN 
			, race03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race03G1 as float)* 100 / nullif(race03, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race03G2 as float)* 100 / nullif(race03, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race03G3 as Refused
			-- , round(coalesce(cast(race03G3 as float)* 100 / nullif(race03, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select	'  Asian' as [title]
			, race04 as TotalN 
			, race04G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race04G1 as float)* 100 / nullif(race04, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race04G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race04G2 as float)* 100 / nullif(race04, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race04G3 as Refused
			-- , round(coalesce(cast(race04G3 as float)* 100 / nullif(race04, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select	'  Native American' as [title]
			, race05 as TotalN 
			, race05G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race05G1 as float)* 100 / nullif(race05, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race05G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race05G2 as float)* 100 / nullif(race05, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race05G3 as Refused
			-- , round(coalesce(cast(race05G3 as float)* 100 / nullif(race05, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select	'  Hawaiian' as [title]
			, race06 as TotalN 
			, race06G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race06G1 as float)* 100 / nullif(race06, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race06G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race06G2 as float)* 100 / nullif(race06, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race06G3 as Refused
			-- , round(coalesce(cast(race06G3 as float)* 100 / nullif(race06, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select	'  Other' as [title]
			, race07 as TotalN 
			, race07G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race07G1 as float)* 100 / nullif(race07, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race07G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race07G2 as float)* 100 / nullif(race07, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race07G3 as Refused
			-- , round(coalesce(cast(race07G3 as float)* 100 / nullif(race07, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select	'  Missing' as [title]
			, race08 as TotalN 
			, race08G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(race08G1 as float)* 100 / nullif(race08, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, race08G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(race08G2 as float)* 100 / nullif(race08, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, race08G3 as Refused
			-- , round(coalesce(cast(race08G3 as float)* 100 / nullif(race08, 0), 0), 0) as RefusedPercent
			, '1' as GroupID
		from	race1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '1' as GroupID
	)
	,	referralsource1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when a.ReferralSourceType = '01' then 1 else 0 end) as ReferralSource01
			, sum(case when a.Status = '1' and ReferralSourceType = '01' then 1 else 0 end) as ReferralSource01G1
			, sum(case when a.Status = '2' and ReferralSourceType = '01' then 1 else 0 end) as ReferralSource01G2
			, sum(case when a.Status = '3' and ReferralSourceType = '01' then 1 else 0 end) as ReferralSource01G3
			, sum(case when ReferralSourceType = '02' then 1 else 0 end) as ReferralSource02
			, sum(case when a.Status = '1' and ReferralSourceType = '02' then 1 else 0 end) as ReferralSource02G1
			, sum(case when a.Status = '2' and ReferralSourceType = '02' then 1 else 0 end) as ReferralSource02G2
			, sum(case when a.Status = '3' and ReferralSourceType = '02' then 1 else 0 end) as ReferralSource02G3
			, sum(case when ReferralSourceType = '03' then 1 else 0 end) as ReferralSource03
			, sum(case when a.Status = '1' and ReferralSourceType = '03' then 1 else 0 end) as ReferralSource03G1
			, sum(case when a.Status = '2' and ReferralSourceType = '03' then 1 else 0 end) as ReferralSource03G2
			, sum(case when a.Status = '3' and ReferralSourceType = '03' then 1 else 0 end) as ReferralSource03G3
			, sum(case when ReferralSourceType = '04' then 1 else 0 end) as ReferralSource04
			, sum(case when a.Status = '1' and ReferralSourceType = '04' then 1 else 0 end) as ReferralSource04G1
			, sum(case when a.Status = '2' and ReferralSourceType = '04' then 1 else 0 end) as ReferralSource04G2
			, sum(case when a.Status = '3' and ReferralSourceType = '04' then 1 else 0 end) as ReferralSource04G3
			, sum(case when ReferralSourceType = '05' then 1 else 0 end) as ReferralSource05
			, sum(case when a.Status = '1' and ReferralSourceType = '05' then 1 else 0 end) as ReferralSource05G1
			, sum(case when a.Status = '2' and ReferralSourceType = '05' then 1 else 0 end) as ReferralSource05G2
			, sum(case when a.Status = '3' and ReferralSourceType = '05' then 1 else 0 end) as ReferralSource05G3
			, sum(case when ReferralSourceType = '06' then 1 else 0 end) as ReferralSource06
			, sum(case when a.Status = '1' and ReferralSourceType = '06' then 1 else 0 end) as ReferralSource06G1
			, sum(case when a.Status = '2' and ReferralSourceType = '06' then 1 else 0 end) as ReferralSource06G2
			, sum(case when a.Status = '3' and ReferralSourceType = '06' then 1 else 0 end) as ReferralSource06G3
			, sum(case when ReferralSourceType = '07' then 1 else 0 end) as ReferralSource07
			, sum(case when a.Status = '1' and ReferralSourceType = '07' then 1 else 0 end) as ReferralSource07G1
			, sum(case when a.Status = '2' and ReferralSourceType = '07' then 1 else 0 end) as ReferralSource07G2
			, sum(case when a.Status = '3' and ReferralSourceType = '07' then 1 else 0 end) as ReferralSource07G3
			, sum(case when ReferralSourceType = '08' then 1 else 0 end) as ReferralSource08
			, sum(case when a.Status = '1' and ReferralSourceType = '08' then 1 else 0 end) as ReferralSource08G1
			, sum(case when a.Status = '2' and ReferralSourceType = '08' then 1 else 0 end) as ReferralSource08G2
			, sum(case when a.Status = '3' and ReferralSourceType = '08' then 1 else 0 end) as ReferralSource08G3
			, sum(case when ReferralSourceType = '09' then 1 else 0 end) as ReferralSource09
			, sum(case when a.Status = '1' and ReferralSourceType = '09' then 1 else 0 end) as ReferralSource09G1
			, sum(case when a.Status = '2' and ReferralSourceType = '09' then 1 else 0 end) as ReferralSource09G2
			, sum(case when a.Status = '3' and ReferralSourceType = '09' then 1 else 0 end) as ReferralSource09G3
			, sum(case when ReferralSourceType = '10' then 1 else 0 end) as ReferralSource10
			, sum(case when a.Status = '1' and ReferralSourceType = '10' then 1 else 0 end) as ReferralSource10G1
			, sum(case when a.Status = '2' and ReferralSourceType = '10' then 1 else 0 end) as ReferralSource10G2
			, sum(case when a.Status = '3' and ReferralSourceType = '10' then 1 else 0 end) as ReferralSource10G3
			, sum(case when ReferralSourceType = '11' then 1 else 0 end) as ReferralSource11
			, sum(case when a.Status = '1' and ReferralSourceType = '11' then 1 else 0 end) as ReferralSource11G1
			, sum(case when a.Status = '2' and ReferralSourceType = '11' then 1 else 0 end) as ReferralSource11G2
			, sum(case when a.Status = '3' and ReferralSourceType = '11' then 1 else 0 end) as ReferralSource11G3
			, sum(case when ReferralSourceType = '12' then 1 else 0 end) as ReferralSource12
			, sum(case when a.Status = '1' and ReferralSourceType = '12' then 1 else 0 end) as ReferralSource12G1
			, sum(case when a.Status = '2' and ReferralSourceType = '12' then 1 else 0 end) as ReferralSource12G2
			, sum(case when a.Status = '3' and ReferralSourceType = '12' then 1 else 0 end) as ReferralSource12G3
			, sum(case when ReferralSourceType = '13' then 1 else 0 end) as ReferralSource13
			, sum(case when a.Status = '1' and ReferralSourceType = '13' then 1 else 0 end) as ReferralSource13G1
			, sum(case when a.Status = '2' and ReferralSourceType = '13' then 1 else 0 end) as ReferralSource13G2
			, sum(case when a.Status = '3' and ReferralSourceType = '13' then 1 else 0 end) as ReferralSource13G3
			, sum(case when ReferralSourceType = '14' then 1 else 0 end) as ReferralSource14
			, sum(case when a.Status = '1' and ReferralSourceType = '14' then 1 else 0 end) as ReferralSource14G1
			, sum(case when a.Status = '2' and ReferralSourceType = '14' then 1 else 0 end) as ReferralSource14G2
			, sum(case when a.Status = '3' and ReferralSourceType = '14' then 1 else 0 end) as ReferralSource14G3
			, sum(case when ReferralSourceType = '15' then 1 else 0 end) as ReferralSource15
			, sum(case when a.Status = '1' and ReferralSourceType = '15' then 1 else 0 end) as ReferralSource15G1
			, sum(case when a.Status = '2' and ReferralSourceType = '15' then 1 else 0 end) as ReferralSource15G2
			, sum(case when a.Status = '3' and ReferralSourceType = '15' then 1 else 0 end) as ReferralSource15G3
		from	#cteMain1 as a
	)
	,	referralsource2
	as (
		select	'Referral Source' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '2' as GroupID
		union all
		select	'  Private Physician' as [title]
			, ReferralSource01 as TotalN 
			, ReferralSource01G1 as AcceptedFirstVisitEnrolled
			---------------------------------------------------------------- , round(coalesce(cast(ReferralSource01G1 as float)* 100 / nullif(ReferralSource01, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource01G2 as float)* 100 / nullif(ReferralSource01, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource01G3 as Refused
			-- , round(coalesce(cast(ReferralSource01G3 as float)* 100 / nullif(ReferralSource01, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Health Clinic' as [title]
			, ReferralSource02 as TotalN 
			, ReferralSource02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource02G1 as float)* 100 / nullif(ReferralSource02, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource02G2 as float)* 100 / nullif(ReferralSource02, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource02G3 as Refused
			-- , round(coalesce(cast(ReferralSource02G3 as float)* 100 / nullif(ReferralSource02, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Hospital' as [title]
			, ReferralSource03 as TotalN 
			, ReferralSource03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource03G1 as float)* 100 / nullif(ReferralSource03, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource03G2 as float)* 100 / nullif(ReferralSource03, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource03G3 as Refused
			-- , round(coalesce(cast(ReferralSource03G3 as float)* 100 / nullif(ReferralSource03, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  WIC' as [title]
			, ReferralSource04 as TotalN 
			, ReferralSource04G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource04G1 as float)* 100 / nullif(ReferralSource04, 0), 0), 0)) as Percent
			, ReferralSource04G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource04G2 as float)* 100 / nullif(ReferralSource04, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource04G3 as Refused
			-- , round(coalesce(cast(ReferralSource04G3 as float)* 100 / nullif(ReferralSource04, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Child Protective Services' as [title]
			, ReferralSource05 as TotalN 
			, ReferralSource05G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource05G1 as float)* 100 / nullif(ReferralSource05, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource05G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource05G2 as float)* 100 / nullif(ReferralSource05, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource05G3 as Refused
			-- , round(coalesce(cast(ReferralSource05G3 as float)* 100 / nullif(ReferralSource05, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Home visiting program' as [title]
			, ReferralSource06 as TotalN 
			, ReferralSource06G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource06G1 as float)* 100 / nullif(ReferralSource06, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource06G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource06G2 as float)* 100 / nullif(ReferralSource06, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource06G3 as Refused
			-- , round(coalesce(cast(ReferralSource06G3 as float)* 100 / nullif(ReferralSource06, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Visiting Nurse' as [title]
			, ReferralSource07 as TotalN 
			, ReferralSource07G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource07G1 as float)* 100 / nullif(ReferralSource07, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource07G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource07G2 as float)* 100 / nullif(ReferralSource07, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource07G3 as Refused 
			-- , round(coalesce(cast(ReferralSource07G3 as float)* 100 / nullif(ReferralSource07, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Home health care agency' as [title]
			, ReferralSource08 as TotalN 
			, ReferralSource08G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource08G1 as float)* 100 / nullif(ReferralSource08, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource08G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource08G2 as float)* 100 / nullif(ReferralSource08, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource08G3 as Refused 
			-- , round(coalesce(cast(ReferralSource08G3 as float)* 100 / nullif(ReferralSource08, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Church' as [title]
			, ReferralSource09 as TotalN 
			, ReferralSource09G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource09G1 as float)* 100 / nullif(ReferralSource09, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource09G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource09G2 as float)* 100 / nullif(ReferralSource09, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource09G3 as Refused
			-- , round(coalesce(cast(ReferralSource09G3 as float)* 100 / nullif(ReferralSource09, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Community based Organization' as [title]
			, ReferralSource10 as TotalN 
			, ReferralSource10G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource10G1 as float)* 100 / nullif(ReferralSource10, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource10G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource10G2 as float)* 100 / nullif(ReferralSource10, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource10G3 as Refused
			-- , round(coalesce(cast(ReferralSource10G3 as float)* 100 / nullif(ReferralSource10, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  School' as [title]
			, ReferralSource11 as TotalN 
			, ReferralSource11G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource11G1 as float)* 100 / nullif(ReferralSource11, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource11G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource11G2 as float)* 100 / nullif(ReferralSource11, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource11G3 as Refused
			-- , round(coalesce(cast(ReferralSource11G3 as float)* 100 / nullif(ReferralSource11, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Day care center' as [title]
			, ReferralSource12 as TotalN 
			, ReferralSource12G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource12G1 as float)* 100 / nullif(ReferralSource12, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource12G2 as AcceptedFirstVisitNotEnrolled 
			-- , round(coalesce(cast(ReferralSource12G2 as float)* 100 / nullif(ReferralSource12, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource12G3 as Refused 
			-- , round(coalesce(cast(ReferralSource12G3 as float)* 100 / nullif(ReferralSource12, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Friends/family' as [title]
			, ReferralSource13 as TotalN 
			, ReferralSource13G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource13G1 as float)* 100 / nullif(ReferralSource13, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource13G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource13G2 as float)* 100 / nullif(ReferralSource13, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource13G3 as Refused
			-- , round(coalesce(cast(ReferralSource13G3 as float)* 100 / nullif(ReferralSource13, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Door to door outreach' as [title]
			, ReferralSource14 as TotalN 
			, ReferralSource14G1 as AcceptedFirstVisitEnrolled 
			-- , round(coalesce(cast(ReferralSource14G1 as float)* 100 / nullif(ReferralSource14, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource14G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource14G2 as float)* 100 / nullif(ReferralSource14, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource14G3 as Refused
			-- , round(coalesce(cast(ReferralSource14G3 as float)* 100 / nullif(ReferralSource14, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select	'  Other' as [title]
			, ReferralSource15 as TotalN 
			, ReferralSource15G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(ReferralSource15G1 as float)* 100 / nullif(ReferralSource15, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, ReferralSource15G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(ReferralSource15G2 as float)* 100 / nullif(ReferralSource15, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, ReferralSource15G3 as Refused
			-- , round(coalesce(cast(ReferralSource15G3 as float)* 100 / nullif(ReferralSource15, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	ReferralSource1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '2' as GroupID
	)
	,	daysbetween1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when a.DaysBetween between 0 and 30 then 1 else 0 end) as DaysBetween0And30
			, sum(case when a.Status = '1' and a.DaysBetween between 0 and 30 then 1 else 0 end) as DaysBetween0And30G1
			, sum(case when a.Status = '2' and a.DaysBetween between 0 and 30 then 1 else 0 end) as DaysBetween0And30G2
			, sum(case when a.Status = '3' and a.DaysBetween between 0 and 30 then 1 else 0 end) as DaysBetween0And30G3
			, sum(case when a.DaysBetween between 31 and 90 then 1 else 0 end) as DaysBetween31And90
			, sum(case when a.Status = '1' and a.DaysBetween between 31 and 90 then 1 else 0 end) as DaysBetween31And90G1
			, sum(case when a.Status = '2' and a.DaysBetween between 31 and 90 then 1 else 0 end) as DaysBetween31And90G2
			, sum(case when a.Status = '3' and a.DaysBetween between 31 and 90 then 1 else 0 end) as DaysBetween31And90G3
			, sum(case when a.DaysBetween > 90 then 1 else 0 end) as DaysBetweenMoreThan90
			, sum(case when a.Status = '1' and a.DaysBetween > 90 then 1 else 0 end) as DaysBetweenMoreThan90G1
			, sum(case when a.Status = '2' and a.DaysBetween > 90 then 1 else 0 end) as DaysBetweenMoreThan90G2
			, sum(case when a.Status = '3' and a.DaysBetween > 90 then 1 else 0 end) as DaysBetweenMoreThan90G3
		from	#cteMain1 as a
	)
	,	daysbetween2
	as (
		select 'Time between Screen and Assessment (days)' as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '2' as GroupID
		union all
		select	'  Between 0 and 30 ' as [title]
			, DaysBetween0And30 as TotalN 
			, DaysBetween0And30G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(DaysBetween0And30G1 as float)* 100 / nullif(DaysBetween0And30, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, DaysBetween0And30G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(DaysBetween0And30G2 as float)* 100 / nullif(DaysBetween0And30, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, DaysBetween0And30G3 as Refused
			-- , round(coalesce(cast(DaysBetween0And30G3 as float)* 100 / nullif(DaysBetween0And30, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	daysbetween1
		union all
		select	'  Between 31 and 90' as [title]
			, DaysBetween31And90 as TotalN 
			, DaysBetween31And90G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(DaysBetween31And90G1 as float)* 100 / nullif(DaysBetween31And90, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, DaysBetween31And90G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(DaysBetween31And90G2 as float)* 100 / nullif(DaysBetween31And90, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, DaysBetween31And90G3 as Refused
			-- , round(coalesce(cast(DaysBetween31And90G3 as float)* 100 / nullif(DaysBetween31And90, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	daysbetween1
		union all
		select	'  More than 90' as [title]
			, DaysBetweenMoreThan90 as TotalN 
			, DaysBetweenMoreThan90G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(DaysBetweenMoreThan90G1 as float)* 100 / nullif(DaysBetweenMoreThan90, 0), 0), 0)) as AcceptedFirstVisitEnrolledPercent
			, DaysBetweenMoreThan90G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(DaysBetweenMoreThan90G2 as float)* 100 / nullif(DaysBetweenMoreThan90, 0), 0), 0)) as AcceptedFirstVisitNotEnrolledPercent
			, DaysBetweenMoreThan90G3 as Refused
			-- , round(coalesce(cast(DaysBetweenMoreThan90G3 as float)* 100 / nullif(DaysBetweenMoreThan90, 0), 0), 0)) as RefusedPercent
			, '2' as GroupID
		from	daysbetween1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '2' as GroupID
	)
	,	trimester1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when Trimester = 1 then 1 else 0 end) as trimester01
			, sum(case when a.Status = '1' and Trimester = 1 then 1 else 0 end) as trimester01G1
			, sum(case when a.Status = '2' and Trimester = 1 then 1 else 0 end) as trimester01G2
			, sum(case when a.Status = '3' and Trimester = 1 then 1 else 0 end) as trimester01G3
			, sum(case when Trimester = 2 then 1 else 0 end) as trimester02
			, sum(case when a.Status = '1' and Trimester = 2 then 1 else 0 end) as trimester02G1
			, sum(case when a.Status = '2' and Trimester = 2 then 1 else 0 end) as trimester02G2
			, sum(case when a.Status = '3' and Trimester = 2 then 1 else 0 end) as trimester02G3
			, sum(case when Trimester = 3 then 1 else 0 end) as trimester03
			, sum(case when a.Status = '1' and Trimester = 3 then 1 else 0 end) as trimester03G1
			, sum(case when a.Status = '2' and Trimester = 3 then 1 else 0 end) as trimester03G2
			, sum(case when a.Status = '3' and Trimester = 3 then 1 else 0 end) as trimester03G3
			, sum(case when Trimester = 4 then 1 else 0 end) as trimester04
			, sum(case when a.Status = '1' and Trimester = 4 then 1 else 0 end) as trimester04G1
			, sum(case when a.Status = '2' and Trimester = 4 then 1 else 0 end) as trimester04G2
			, sum(case when a.Status = '3' and Trimester = 4 then 1 else 0 end) as trimester04G3
		from	#cteMain1 as a
	)
	,	trimester2
	as (
		select	'Trimester (at time of Enrollment/Discharge)' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '2' as GroupID
		union all
		select	'  1st' as [title]
			, trimester01 as TotalN 
			, trimester01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(trimester01G1 as float)* 100 / nullif(trimester01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, trimester01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(trimester01G2 as float)* 100 / nullif(trimester01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, trimester01G3 as Refused
			-- , round(coalesce(cast(trimester01G3 as float)* 100 / nullif(trimester01, 0), 0), 0) as RefusedPercent
			, '2' as GroupID
		from	trimester1
		union all
		select	'  2nd' as [title]
			, trimester02 as TotalN 
			, trimester02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(trimester02G1 as float)* 100 / nullif(trimester02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, trimester02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(trimester02G2 as float)* 100 / nullif(trimester02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, trimester02G3 as Refused
			-- , round(coalesce(cast(trimester02G3 as float)* 100 / nullif(trimester02, 0), 0), 0) as RefusedPercent
			, '2' as GroupID
		from	trimester1
		union all
		select	'  3rd' as [title]
			, trimester03 as TotalN 
			, trimester03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(trimester03G1 as float)* 100 / nullif(trimester03, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, trimester03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(trimester03G2 as float)* 100 / nullif(trimester03, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, trimester03G3 as Refused
			-- , round(coalesce(cast(trimester03G3 as float)* 100 / nullif(trimester03, 0), 0), 0) as RefusedPercent
			, '2' as GroupID
		from	trimester1
		union all
		select	'  Postnatal' as [title]
			, trimester04 as TotalN 
			, trimester04G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(trimester04G1 as float)* 100 / nullif(trimester04, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, trimester04G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(trimester04G2 as float)* 100 / nullif(trimester04, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, trimester04G3 as Refused
			-- , round(coalesce(cast(trimester04G3 as float)* 100 / nullif(trimester04, 0), 0), 0) as RefusedPercent
			, '2' as GroupID
		from	trimester1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '2' as GroupID
	)
	,	kempescore1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when KempeScore between 25 and 49 then 1 else 0 end) as KempeScore01
			, sum(	case when a.Status = '1' and	KempeScore between 25 and 49 then 1
					else 0 end
				) as KempeScore01G1
			, sum(	case when a.Status = '2' and	KempeScore between 25 and 49 then 1
					else 0 end
				) as KempeScore01G2
			, sum(	case when a.Status = '3' and	KempeScore between 25 and 49 then 1
					else 0 end
				) as KempeScore01G3
			, sum(case when KempeScore between 50 and 74 then 1 else 0 end) as KempeScore02
			, sum(	case when a.Status = '1' and	KempeScore between 50 and 74 then 1
					else 0 end
				) as KempeScore02G1
			, sum(	case when a.Status = '2' and	KempeScore between 50 and 74 then 1
					else 0 end
				) as KempeScore02G2
			, sum(	case when a.Status = '3' and	KempeScore between 50 and 74 then 1
					else 0 end
				) as KempeScore02G3
			, sum(case when KempeScore >= 75 then 1 else 0 end) as KempeScore03
			, sum(case when a.Status = '1' and KempeScore >= 75 then 1 else 0 end) as KempeScore03G1
			, sum(case when a.Status = '2' and KempeScore >= 75 then 1 else 0 end) as KempeScore03G2
			, sum(case when a.Status = '3' and KempeScore >= 75 then 1 else 0 end) as KempeScore03G3
		from	#cteMain1 as a
	)
	,	kempescore2
	as (
		select	'Kempe Score' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '3' as GroupID
		union all
		select	'  25-49' as [title]
			, KempeScore01 as TotalN 
			, KempeScore01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(KempeScore01G1 as float)* 100 / nullif(KempeScore01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, KempeScore01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(KempeScore01G2 as float)* 100 / nullif(KempeScore01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, KempeScore01G3 as Refused
			-- , round(coalesce(cast(KempeScore01G3 as float)* 100 / nullif(KempeScore01, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	kempescore1
		union all
		select	'  50-74' as [title]
			, KempeScore02 as TotalN 
			, KempeScore02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(KempeScore02G1 as float)* 100 / nullif(KempeScore02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, KempeScore02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(KempeScore02G2 as float)* 100 / nullif(KempeScore02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, KempeScore02G3 as Refused
			-- , round(coalesce(cast(KempeScore02G3 as float)* 100 / nullif(KempeScore02, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	kempescore1
		union all
		select	'  75+' as [title]
			, KempeScore03 as TotalN 
			, KempeScore03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(KempeScore03G1 as float)* 100 / nullif(KempeScore03, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, KempeScore03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(KempeScore03G2 as float)* 100 / nullif(KempeScore03, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, KempeScore03G3 as Refused
			-- , round(coalesce(cast(KempeScore03G3 as float)* 100 / nullif(KempeScore03, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	kempescore1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '3' as GroupID
	)
	,	score1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when MomScore >= 25 and DadScore < 25 then 1 else 0 end) as Score01
			, sum(	case when a.Status = '1' and	MomScore >= 25 and	DadScore < 25 then 1
					else 0 end
				) as Score01G1
			, sum(	case when a.Status = '2' and	MomScore >= 25 and	DadScore < 25 then 1
					else 0 end
				) as Score01G2
			, sum(	case when a.Status = '3' and	MomScore >= 25 and	DadScore < 25 then 1
					else 0 end
				) as Score01G3
			, sum(case when MomScore < 25 and DadScore >= 25 then 1 else 0 end) as Score02
			, sum(	case when a.Status = '1' and	MomScore < 25 and	DadScore >= 25 then 1
					else 0 end
				) as Score02G1
			, sum(	case when a.Status = '2' and	MomScore < 25 and	DadScore >= 25 then 1
					else 0 end
				) as Score02G2
			, sum(	case when a.Status = '3' and	MomScore < 25 and	DadScore >= 25 then 1
					else 0 end
				) as Score02G3
			, sum(case when MomScore >= 25 and DadScore >= 25 then 1 else 0 end) as Score03
			, sum(	case when a.Status = '1' and	MomScore >= 25 and	DadScore >= 25 then 1
					else 0 end
				) as Score03G1
			, sum(	case when a.Status = '2' and	MomScore >= 25 and	DadScore >= 25 then 1
					else 0 end
				) as Score03G2
			, sum(	case when a.Status = '3' and	MomScore >= 25 and	DadScore >= 25 then 1
					else 0 end
				) as Score03G3
		from	#cteMain1 as a
	)
	,	score2
	as (
		select	'Whose Score Qualifies' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '3' as GroupID
		union all
		select	'  Mother' as [title]
			, Score01 as TotalN 
			, Score01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(Score01G1 as float)* 100 / nullif(Score01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, Score01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(Score01G2 as float)* 100 / nullif(Score01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, Score01G3 as Refused
			-- , round(coalesce(cast(Score01G3 as float)* 100 / nullif(Score01, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	score1
		union all
		select	'  Father' as [title]
			, Score02 as TotalN 
			, Score02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(Score02G1 as float)* 100 / nullif(Score02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, Score02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(Score02G2 as float)* 100 / nullif(Score02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, Score02G3 as Refused
			-- , round(coalesce(cast(Score02G3 as float)* 100 / nullif(Score02, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	score1
		union all
		select	'  Mother & Father' as [title]
			, Score03 as TotalN 
			, Score03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(Score03G1 as float)* 100 / nullif(Score03, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, Score03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(Score03G2 as float)* 100 / nullif(Score03, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, Score03G3 as Refused
			-- , round(coalesce(cast(Score03G3 as float)* 100 / nullif(Score03, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	score1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '3' as GroupID
		FROM #cteMain1
	)
	,	issues1
	as (
		select	sum(case when a.Status = '1' then 1 else 0 end) as totalG1
			, sum(case when a.Status = '2' then 1 else 0 end) as totalG2
			, sum(case when a.Status = '3' then 1 else 0 end) as totalG3
			, sum(case when DV = 1 then 1 else 0 end) as issues01
			, sum(case when a.Status = '1' and DV = 1 then 1 else 0 end) as issues01G1
			, sum(case when a.Status = '2' and DV = 1 then 1 else 0 end) as issues01G2
			, sum(case when a.Status = '3' and DV = 1 then 1 else 0 end) as issues01G3
			, sum(case when MH = 1 then 1 else 0 end) as issues02
			, sum(case when a.Status = '1' and MH = 1 then 1 else 0 end) as issues02G1
			, sum(case when a.Status = '2' and MH = 1 then 1 else 0 end) as issues02G2
			, sum(case when a.Status = '3' and MH = 1 then 1 else 0 end) as issues02G3
			, sum(case when SA = 1 then 1 else 0 end) as issues03
			, sum(case when a.Status = '1' and SA = 1 then 1 else 0 end) as issues03G1
			, sum(case when a.Status = '2' and SA = 1 then 1 else 0 end) as issues03G2
			, sum(case when a.Status = '3' and SA = 1 then 1 else 0 end) as issues03G3
		from	#cteMain1 as a
	)
	,	issues2
	as (
		select	'PC1 Issues at Parent Survey' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '3' as GroupID
		union all
		select	'  DV' as [title]
			, issues01 as TotalN 
			, issues01G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(issues01G1 as float)* 100 / nullif(issues01, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, issues01G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(issues01G2 as float)* 100 / nullif(issues01, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, issues01G3 as Refused
			-- , round(coalesce(cast(issues01G3 as float)* 100 / nullif(issues01, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	issues1
		union all
		select	'  MH' as [title]
			, issues02 as TotalN 
			, issues02G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(issues02G1 as float)* 100 / nullif(issues02, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, issues02G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(issues02G2 as float)* 100 / nullif(issues02, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, issues02G3 as Refused
			-- , round(coalesce(cast(issues02G3 as float)* 100 / nullif(issues02, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	issues1
		union all
		select	'  SA' as [title]
			, issues03 as TotalN 
			, issues03G1 as AcceptedFirstVisitEnrolled
			-- , round(coalesce(cast(issues03G1 as float)* 100 / nullif(issues03, 0), 0), 0) as AcceptedFirstVisitEnrolledPercent
			, issues03G2 as AcceptedFirstVisitNotEnrolled
			-- , round(coalesce(cast(issues03G2 as float)* 100 / nullif(issues03, 0), 0), 0) as AcceptedFirstVisitNotEnrolledPercent
			, issues03G3 as Refused
			-- , round(coalesce(cast(issues03G3 as float)* 100 / nullif(issues03, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	issues1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '3' as GroupID
	)
	,	refused1
	as (
		select	count(*) as totalG3
			, sum(case when DischargeReason = '36' then 1 else 0 end) [Refused]
			, sum(case when DischargeReason = '12' then 1 else 0 end) [UnableToLocate]
			, sum(case when DischargeReason = '19' then 1 else 0 end) [TCAgedOut]
			, sum(case when DischargeReason = '07' then 1 else 0 end) [OutOfTargetArea]
			, sum(case when DischargeReason in ('25') then 1 else 0 end) [Transfered]
			, sum(	case when DischargeReason not in ('36', '12', '19', '07', '25') then 1
					else 0 end
				) [AllOthers]
		from	#cteMain1 as a
		where	a.Status = '3'
	)
	,	refused2
	as (
		select	'Reason for Refusal' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, null as Refused
			, '3' as GroupID
		union all
		select	'  Refused' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, Refused as Refused
			-- , round(coalesce(cast(Refused as float)* 100 / nullif(totalG3, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	refused1
		union all
		select	'  Unable To Locate' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, UnableToLocate as Refused
			-- , round(coalesce(cast(UnableToLocate as float)* 100 / nullif(totalG3, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	refused1
		union all
		select	'  TC Aged Out' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, TCAgedOut as Refused
			-- , round(coalesce(cast(TCAgedOut as float)* 100 / nullif(totalG3, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	refused1
		union all
		select	'  Out of Target Area' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, OutOfTargetArea as Refused
			-- , round(coalesce(cast(OutOfTargetArea as float)* 100 / nullif(totalG3, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	refused1
		union all
		select	'  Transfered' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, Transfered as Refused
			-- , round(coalesce(cast(Transfered as float)* 100 / nullif(totalG3, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	refused1
		union all
		select	'  All Others' as [title]
			, null as TotalN
			, null as AcceptedFirstVisitEnrolled
			, null as AcceptedFirstVisitNotEnrolled
			, AllOthers as Refused
			-- , round(coalesce(cast(AllOthers as float)* 100 / nullif(totalG3, 0), 0), 0) as RefusedPercent
			, '3' as GroupID
		from	refused1
		union all
		select null as [title]
				, null as TotalN
				, null as AcceptedFirstVisitEnrolled
				, null as AcceptedFirstVisitNotEnrolled
				, null as Refused
				, '3' as GroupID
	)
	,	rpt1
	as (
		select * from total2
		union all
		select * from total3
		union all
		select * from age2
		union all
		select * from edu2
		union all
		select * from employed2
		union all
		select * from marital2
		union all
		select * from parity2
		union all
		select * from primarylanguage2
		union all
		select * from race2
		union all
		select * from referralsource2
		union all
		select * from daysbetween2
		union all
		select * from trimester2
		union all
		select * from kempescore2
		union all
		select * from score2
		union all
		select * from issues2
		union all
		select * from refused2
	)

	-- listing records
	--SELECT * 
	--FROM main1 AS a
	--WHERE a.Status = 3

	select	title
			, TotalN
			, case when rpt1.TotalN is null 
					then null 
					else round(coalesce(cast(TotalN as float) / nullif(@GrandTotalN, 0), 0), 2) 					
				end as TotalNPercent
			, @TotalRefused as TotalRefused
			, AcceptedFirstVisitEnrolled
			, case when rpt1.TotalN is null then null 
					else round(coalesce(cast(AcceptedFirstVisitEnrolled  as float) / nullif(TotalN, 0), 0), 2)
				end as AcceptedFirstVisitEnrolledPercent
			--, cast(AcceptedFirstVisitEnrolled as float)  / nullif(TotalN, 0) as AcceptedFirstVisitEnrolledPercent
			, AcceptedFirstVisitNotEnrolled
			, case when rpt1.TotalN is null then null 
					else round(coalesce(cast(AcceptedFirstVisitNotEnrolled  as float) / nullif(TotalN, 0), 0), 2) 
				end as AcceptedFirstVisitNotEnrolledPercent
			--, cast(AcceptedFirstVisitNotEnrolled as float) / nullif(TotalN, 0) as AcceptedFirstVisitNotEnrolledPercent
			, Refused
			, case when rpt1.TotalN is null 
					then case when Refused is not null and TotalN is null and GroupID <> '0'
							then round(coalesce(cast(Refused as float) / nullif(@TotalRefused, 0), 0), 2) 
							else null 
						end
					else round(coalesce(cast(Refused as float) / nullif(TotalN, 0), 0), 2) 
				end as RefusedPercent
			--, cast(Refused as float) / TotalN as RefusedPercent
			, GroupID
			, case groupID when '0' then 'Summary'
					when '1' then 'Demographic Factors at Intake' 
					when '2' then 'Programmatic Factors'
					else 'Social Factors at Intake'
				end
				as FactorType
	from	rpt1 ;

	drop table #cteMain ;
	drop table #cteMain1 ;

end
GO
