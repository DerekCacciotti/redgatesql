SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 6th, 2013>
-- Description:	The FSW Tickler provides the program staff with both a schedule of upcoming events and a form history of the case.
-- Be patient when running this report as it may take a few seconds. This report should be run monthly.

-- rspFSWEnrolledCaseTickler 5, '12/31/2012'

-- =============================================


create procedure [dbo].[rspFSWEnrolledCaseTickler](
	@programfk    varchar(max)    = NULL,
    @edate     datetime,
    @supervisorfk int             = null,
    @workerfk     int             = null,
    @pc1id        varchar(13)     = null
)
as

	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	
	-- First day of the Current Month
	declare @FirstDayOfCurrentMonth datetime
	set @FirstDayOfCurrentMonth = DATEADD(DAY, -(DAY(@edate) - 1), @edate)
	
		
	-- Last Month's Home Visits
	
	-- Last day of Previous Month
	declare @lastDayOfPreviousMonth datetime
	set @lastDayOfPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@edate),0))  

	-- 1st day of previous month
	declare @firstDayOfPreviousMonth datetime
	set @firstDayOfPreviousMonth = DATEADD(DD, -DAY(DATEADD(DD, -DAY(@edate),@edate))+1,DATEADD(DD, -DAY(@edate),@edate))  
	
	
	-- Last 3 Month's Home Visits

	-- 1st day of 3rd previous month
	declare @firstDayOfThirdPreviousMonth datetime	
	declare @TwoMonthsBack datetime
	set @TwoMonthsBack = DATEADD(m, -2,@edate) -- it helps to figure out firstDayOfThirdPreviousMonth
	
	set @firstDayOfThirdPreviousMonth = DATEADD(DD, -DAY(DATEADD(DD, -DAY(@TwoMonthsBack),@TwoMonthsBack))+1, DATEADD(DD, -DAY(@TwoMonthsBack),@TwoMonthsBack))  
	

	
	DECLARE @tblCommonCohort TABLE(
				[HVCasePK] [int],
				[TCIDPK] [int],
				[tcname]  [varchar](200) NULL,								
				[ProgramFK] [int] NULL,	
				[OldID] [char](23) NULL,
				[PC1ID] [char](13) NULL,
				[tcdob] [datetime] NULL,		
				[SupervisorName]  [varchar](200) NULL,
				[SupervisorFK] int,
				[FSWName]  [varchar](200) NULL,
				[FSWFK] int,
				[PCName]  [varchar](200) NULL,	
				[IntakeDate] [datetime] NULL,
				[DischargeDate] [datetime] NULL,
				[CaseProgress] [numeric](3, 1) NULL,
				[TCNumber] [int] NULL,
				[MultipleBirth] char (3) null,
				[Intakedd] varchar(20),
				[tcid_dd] varchar(50),				
				XDateAge int,
				CurrentLevelFK int,
				TCAgeDays int
	)

	INSERT INTO @tblCommonCohort
	select distinct
		h.HVCasePK,
		t.TCIDPK, 
		T.TCFirstName + ' ' + t.TCLastName as tcname,
		cp.programfk,
		cp.OldID,
		cp.PC1ID,
		case
		   when h.tcdob is not null then
			   h.tcdob
		   else
			   h.edc
		end as tcdob,
		LTRIM(RTRIM(supervisor.firstname)) + ' ' + LTRIM(RTRIM(supervisor.lastname)) supervisor,
		supervisor.WorkerPK as SupervisorFK,	
		LTRIM(RTRIM(fsw.firstname)) + ' ' + LTRIM(RTRIM(fsw.lastname)) fswworker,
		fsw.WorkerPK as fswFK,	
		LTRIM(RTRIM(pc.pcfirstname))+' '+LTRIM(RTRIM(pc.pclastname)) as pcname,
		h.IntakeDate,
		cp.DischargeDate,
		h.CaseProgress,
		h.TCNumber,
		CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
		as [MultipleBirth],
		case when CaseProgress >= 10 then 'Complete' else convert(VARCHAR(20), dateadd(dd,30,IntakeDate), 101) end as  intakedd,	 
		case when CaseProgress >= 11 then 'Complete' else '' end as  tcid_dd,	 
		 
		case
		   when h.tcdob is not null then
			 datediff(dd, h.tcdob,  @edate)
		   else
			   datediff(dd, h.edc, @edate)
		end as XDateAge,
		cp.CurrentLevelFK,
		''

		
		
		from HVCase h
		inner join CaseProgram cp on cp.hvcasefk = h.hvcasePk	
		inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
		inner join pc on pc.pcpk = pc1fk
		left join worker fsw on cp.CurrentFSWFK = fsw.workerpk
		INNER JOIN workerprogram wp ON wp.workerfk = fsw.workerpk
		left JOIN worker supervisor ON wp.supervisorfk = supervisor.workerpk
		left join TCID T on T.HVCaseFK = h.HVCasePK 		
		
	-- when you go alive with this, uncomment the following lines and use them	... Khalsa
	where
	(h.IntakeDate IS NOT null)	  
				AND 
				(cp.DischargeDate IS null)  --- case not closed. This is enough because we are dealing with either current month or next month
	and cp.CaseStartDate <= @edate
	 and currentFSWFK = isnull(@workerfk,currentFSWFK)
	 and supervisorfk = isnull(@supervisorfk,supervisorfk)
	 and PC1ID = isnull(@pc1id,PC1ID)	

		
	-- The following where clause is temporary. This enables me to sync with FoxPro data (remove this Where clause when you go alive) ... Khalsa	
	--where   
	--(h.IntakeDate IS NOT null and h.IntakeDate <=  @edate)	  
	--			AND 
	--			(cp.DischargeDate IS null or cp.DischargeDate > @edate)  
	--and cp.CaseStartDate <= @edate
	-- and currentFSWFK = isnull(@workerfk,currentFSWFK)
	-- and supervisorfk = isnull(@supervisorfk,supervisorfk)
	-- and PC1ID = isnull(@pc1id,PC1ID)


-- add tcagedays. we need it in when we count shots later
update @tblCommonCohort 
set TCAgeDays = (case when (DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate) then datediff(day,tcdob,DischargeDate) else  datediff(day,tcdob,@eDate)  end )


-- rspFSWEnrolledCaseTickler 5, '12/31/2012' 

------- start - getting ready for code that will handle Last ASQ for tc ----- 
-- Note: This almost exact same as code performance target HD7 
	
	declare @tblPTDetails table
		(
		PTCode				char(5)
		, HVCaseFK			int
		, TCIDPK			int
		, PC1ID				varchar(20)
		, OldID				varchar(30)
		, TCDOB				datetime
		, PC1Fullname		varchar(50)
		, WorkerFullName	varchar(50)
		, CurrentLevelName	varchar(30)
		, FormName			varchar(50)
		, FormDate			datetime
		, FormReviewed		int
		, FormOutOfWindow	int
		, FormMissing		int
		, FormMeetsTarget	int
		, ReasonNotMeeting	varchar(50)
		, TCReceiving1 bit
		, TCReceiving2 bit
		, TCReceiving3 bit
		, TCReceiving4 bit
		
		)
	



	declare @tblPTCohort as PTCases; -- PTCases is a user defined type

	/* Add data to the table variable. */
	insert into @tblPTCohort (HVCaseFK
 							 , PC1ID
							 , OldID
							 , PC1FullName
							 , CurrentWorkerFK
							 , CurrentWorkerFullName
							 , CurrentLevelName
							 , ProgramFK
							 , TCIDPK
							 , TCDOB
							)
						SELECT HVCasePK
						,PC1ID
						,OldID
						,PCName
						,FSWFK
						,FSWName
						,''
						,cc.ProgramFK
						, TCIDPK
						, TCDOB
							 FROM @tblCommonCohort cc
						





	insert into @tblPTDetails
			exec rspFSWEnrolledCaseTicklerASQSummary null,@eDate,@tblPTCohort

------- end - getting ready for code that will handle Last ASQ for tc ----- 
			
		

;
-- missing psi due
with ctePSIIntervalAlreadyShouldHaveBeenDone
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval 

 		from @tblCommonCohort cc			
			--left join tcid on tcid.hvcasefk = cc.hvcasepk and tcid.programfk = cc.ProgramFK -- you don't need it because psi test is for parent only (not for child) ( or per case)
			left join codeduebydates on scheduledevent = 'PSI' AND cc.XDateAge >= DueBy -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)
,
ctePSIFormDueDates
as
(
SELECT m.HVCasePK, m.TCIDPK
--, P.PSIInterval as PSIInterval, psim.Interval as psim_Interval,  PSIPK , tcdob
	 	  ,case when psim.Interval is null and PSIPK is null then ' Intake/Birth due after baby''s birth'
	 	  --,case when psim.Interval is null and PSIPK is null then ' Intake/Birth due by ' + convert(varchar(12), dateadd(dd,31, m.IntakeDate), 101)
			when  PSIPK is null then cd.EventDescription + ' due  between ' + convert(varchar(20), dateadd(dd,cd.MinimumDue ,tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd,cd.MaximumDue ,tcdob), 101)
			else ''
			end as PSIDue				
				
	 
 from @tblCommonCohort m
left join ctePSIIntervalAlreadyShouldHaveBeenDone psim on psim.hvcasepk = m.hvcasepk and m.TCIDPK = psim.TCIDPK 
left join codeduebydates cd on scheduledevent = 'PSI' AND psim.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
 -- The following line gets those tcid's with PSI's that are due for the Interval
 left join PSI P on P.HVCaseFK = m.HVCasePK and P.PSIInterval= psim.Interval 

)

-- last psi that was completed
,
cteLastPSI
as
(
SELECT cc.HVCasePK ,cc.TCIDPK
	  ,max(PSIDateComplete) AS PSIMaxDate -- We mean really the last date in the database
	  ,max(PSIInterval) as psiinterval
 FROM @tblCommonCohort cc
 left join PSI P on P.HVCaseFK = cc.HVCasePK  -- it is case based because it is for parent only
GROUP BY cc.HVCasePK,cc.TCIDPK

)
,
cteLastPSIGetOtherNeededFields
as
( -- to get other fields like P.PSIInterval, P.PSIInWindow,P.PSIPK 
SELECT ls.HVCasePK ,ls.TCIDPK,ls.PSIMaxDate,P.PSIInterval, P.PSIInWindow,P.PSIPK 
 FROM cteLastPSI ls
 left join PSI P on P.HVCaseFK = ls.HVCasePK and P.PSIDateComplete = ls.PSIMaxDate and P.PSIInterval = ls.psiinterval -- adding interval eliminates if there are two psi on the same date
)
,
cteLastPSIForm
as
(
SELECT cc.HVCasePK ,cc.TCIDPK,
--oldid,PSIPK, 

    
    case 
    when PSIPK is null then ' Missing'	
	when PSIMaxDate is not null then	
		'Last PSI: ' + cd.EventDescription +
		
			case when lpsi.PSIInWindow = 1 then ' In Window on ' else ' Out of Window on ' end 
		
		   + convert(varchar(20), PSIMaxDate, 101)	
	
	
	else ''
	end  as lastpsi

 FROM @tblCommonCohort cc 
 left join cteLastPSIGetOtherNeededFields lpsi on lpsi.hvcasePK = cc.hvcasePK and cc.tcidpk = lpsi.tcidpk
 left join codeduebydates cd on scheduledevent = 'PSI' AND lpsi.psiinterval = cd.Interval -- to get dueby, max, min (given interval)
)


--- Follow Up forms

-- missing Follow Up due
,cteFollowUpIntervalAlreadyShouldHaveBeenDone
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , max(Interval) AS Interval -- for tc less than 6 month olds, interval will be null

 		from @tblCommonCohort cc
 		left join codeduebydates on scheduledevent = 'Follow Up' AND cc.XDateAge >= DueBy -- minimum interval

 GROUP BY HVCasePK, TCIDPK

)

,
cteFollowUpFormDueDates
as
(
SELECT m.HVCasePK, m.TCIDPK, OldID 
--, P.PSIInterval as PSIInterval, psim.Interval as psim_Interval,  PSIPK , tcdob
	 	  ,case when fui.Interval is null then ''
	 	  --,case when psim.Interval is null and PSIPK is null then ' Intake/Birth due by ' + convert(varchar(12), dateadd(dd,31, m.IntakeDate), 101)
			when  FollowUpPK is null then cd.EventDescription + ' due  between ' + convert(varchar(20), dateadd(dd,cd.MinimumDue ,tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd,cd.MaximumDue ,tcdob), 101)
			else ''
			end as FollowUpDue				
				
	 
 from @tblCommonCohort m
left join cteFollowUpIntervalAlreadyShouldHaveBeenDone fui on fui.hvcasepk = m.hvcasepk and m.TCIDPK = fui.TCIDPK 
left join codeduebydates cd on scheduledevent = 'Follow Up' AND fui.[Interval] = cd.Interval -- to get dueby, max, min (given interval)
left join FollowUp fu on fu.HVCaseFK = m.HVCasePK and fu.FollowUpInterval = fui.Interval  


)


-- last FollowUp that was completed
,
cteLastFollowUp
as
(
SELECT cc.HVCasePK ,cc.TCIDPK
	  ,max(FollowUpDate) AS FollowUpMaxDate -- We mean really the last date in the database
 FROM @tblCommonCohort cc
 left join FollowUp fu on fu.HVCaseFK = cc.HVCasePK 
GROUP BY cc.HVCasePK,cc.TCIDPK

)
 
,
cteLastFollowUpGetOtherNeededFields
as
( -- to get other fields like fu.FollowUpInterval,fu.FUPInWindow, fu.FollowUpPK
SELECT lf.HVCasePK ,lf.TCIDPK,lf.FollowUpMaxDate,fu.FollowUpInterval,fu.FUPInWindow, fu.FollowUpPK
 FROM cteLastFollowUp lf
 left join FollowUp fu on fu.HVCaseFK = lf.HVCasePK and fu.FollowUpDate = lf.FollowUpMaxDate 
)
,
cteLastFollowUpForm
as
(
SELECT cc.HVCasePK ,cc.TCIDPK,oldid,
--oldid,PSIPK, 

    
    case 
    when FollowUpPK is null then ' Missing'	
	when FollowUpMaxDate is not null then	
		'Last PSI: ' + cd.EventDescription +
		
			case when lfu.FUPInWindow = 1 then ' In Window on ' else ' Out of Window on ' end 
		
		   + convert(varchar(20), FollowUpMaxDate, 101)	
	
	
	else ''
	end  as lastFollowUp

 FROM @tblCommonCohort cc 
 left join cteLastFollowUpGetOtherNeededFields lfu on lfu.hvcasePK = cc.hvcasePK and cc.tcidpk = lfu.tcidpk
 left join codeduebydates cd on scheduledevent = 'Follow Up' AND lfu.FollowUpInterval = cd.Interval -- to get dueby, max, min (given interval)
)



-- rspFSWEnrolledCaseTickler 5, '12/31/2012' 
--where HVCasePK = 32950

,cteReferrals
as
(
SELECT 
		cc.HVCasePK	
		,count(cc.HVCasePK) as ref_enr
		,sum(case when (startdate is null and ReasonNoService is null) then 1 else 0 end) as ref_fup
	  , max(sr.ReferralDate) AS ref_last
 
 FROM @tblCommonCohort cc 
	inner join ServiceReferral sr on sr.HVCaseFK = cc.HVCasePK 
	where sr.ReferralDate >= cc.IntakeDate  and sr.ReferralDate <= @edate
 GROUP BY HVCasePK 
)
,
cteTCIDFormDone
as
(
SELECT 
 HVCasePK
  ,	case when CaseProgress >= 11 then 'Complete' else 		
	
	case when IntakeDate >= tcdob then 'due by ' + convert(VARCHAR(20), dateadd(dd,30,IntakeDate), 101)
		else 'due 30 days after baby''s birth'
	 end 
	 
	 end as  tcid_dd -- dd = done

 
 FROM @tblCommonCohort cc 
)

-- Last Months Home Visits
,
cteExpectedMonthlyHomeVisits
as
(

	SELECT HVCasePK
	,sum(minimumvisit * datediff(week,@firstDayOfPreviousMonth,@lastDayOfPreviousMonth)) as expectedvisitcount
	
	FROM @tblCommonCohort cc 
	inner join [HVLevelDetail] hld on hld.hvcasefk = cc.HVCasePK 
	where (StartLevelDate <= @lastDayOfPreviousMonth)
	and (EndLevelDate >= @firstDayOfPreviousMonth or EndLevelDate is null)	

	group by HVCasePK
	)

,
cteAttemptedAndActualMonthlyHomeVisits
as
(

	SELECT cc.HVCasePK	
	
	,sum(case
			 when visittype <> '0001' then
				 1
			 else
				 0
		 end) as actualvisitcount
	,sum(case
			 when visittype = '1000' then
				 1
			 else
				 0
		 end) as inhomevisitcount
	,sum(case
			 when visittype = '0001' then
				 1
			 else
				 0
		 end) as attemptedvisitcount

	,sum(visitlengthminute)+sum(visitlengthhour)*60  as VisitLengthInminutesMOnthly
	
	FROM @tblCommonCohort cc 	
	left outer join hvlog on cc.hvcasepk = hvlog.hvcasefk
							   and cast(VisitStartTime AS DATE) between @firstDayOfPreviousMonth and @lastDayOfPreviousMonth
							   
	group by cc.HVCasePK 

	)

-- Last 3 Months Home Visits
,
cteExpected3MonthsHomeVisits
as
(

	SELECT HVCasePK
	,sum(minimumvisit * datediff(week,@firstDayOfThirdPreviousMonth,@lastDayOfPreviousMonth)) as expected3Monthsvisitcount
	
	FROM @tblCommonCohort cc 
	inner join [HVLevelDetail] hld on hld.hvcasefk = cc.HVCasePK 
	where (StartLevelDate <= @lastDayOfPreviousMonth)
	and (EndLevelDate >= @firstDayOfThirdPreviousMonth or EndLevelDate is null)	

	group by HVCasePK
	)

,
cteAttemptedAndActual3MonthsHomeVisits
as
(

	SELECT cc.HVCasePK	
	
	,sum(case
			 when visittype <> '0001' then
				 1
			 else
				 0
		 end) as actual3Monthsvisitcount
	,sum(case
			 when visittype = '1000' then
				 1
			 else
				 0
		 end) as inhome3Monthsvisitcount
	,sum(case
			 when visittype = '0001' then
				 1
			 else
				 0
		 end) as attempted3Monthsvisitcount
	,sum(visitlengthminute)+sum(visitlengthhour)*60 as VisitLengthInminutes3MOnthly
	
	FROM @tblCommonCohort cc 	
	left outer join hvlog on cc.hvcasepk = hvlog.hvcasefk
							   and cast(VisitStartTime AS DATE) between @firstDayOfThirdPreviousMonth and @lastDayOfPreviousMonth
							   
	group by cc.HVCasePK 

	)

,cteLast5Visits
as
(
select  HVCasePK
		 ,case
			 when visittype = '0001' then
				 Convert(VARCHAR(12), VisitStartTime, 101) + 'a'  -- attempted visits
			 else
				 Convert(VARCHAR(12), VisitStartTime, 101)
		 end
	   as VisitStartTime
	  ,VisitType
	  ,RowNumber = row_number() over (partition by h.HVCaseFK order by VisitStartTime desc)
	   FROM @tblCommonCohort cc
inner join HVLog h on h.HVCaseFK = cc.HVCasePK and cast(VisitStartTime AS DATE) between @firstDayOfThirdPreviousMonth and @edate
)
,cteLast5VisitsConcatenated
as
(-- Problem: How to concatenate VisitStartTime? Here is a solution ... khalsa
select  cc.HVCasePK,
		(
			select top 5 VisitStartTime + ', '  -- last 5 home visits only please
			from cteLast5Visits ls
			where ls.HVCasePK = cc.HVCasePK 
			order by VisitStartTime desc
			for xml path('')  
		
		) as Last5Visits

	   FROM @tblCommonCohort cc	  
	   group by cc.HVCasePK 

)
,cteLevel
as
(  -- Problem: There may be two levels in a given month. one level ending and other starting. How do we pick up the last one? .. khalsa
	select HVCasePK
	,levelname, StartLevelDate 
	,RowNumber = row_number() over (partition by hld.HVCaseFK order by StartLevelDate desc)
	FROM @tblCommonCohort cc 
	inner join [HVLevelDetail] hld on hld.hvcasefk = cc.HVCasePK 
	where (StartLevelDate <= @edate)  -- just within the given month only
	and (EndLevelDate >= @FirstDayOfCurrentMonth or EndLevelDate is null)	

)

,cteCurrentLevel
as
( -- This will help us to pick the latest (last) level if there are two levels in a given month .. khalsa
	select HVCasePK,
		(
			select top 1 levelname  
			from cteLevel ls
			where ls.HVCasePK = cc.HVCasePK 
			order by StartLevelDate desc
			
		
		) as levelname,
		(
			select top 1 StartLevelDate  
			from cteLevel ls
			where ls.HVCasePK = cc.HVCasePK 
			order by StartLevelDate desc
			
		
		) as StartLevelDate
		
	   FROM @tblCommonCohort cc	  
	   group by cc.HVCasePK 


)
,
cteTCID
as
(
	select  
	cc.HVCasePK
			,T.HVCaseFK as tcidHVCaseFK
		   ,T.TCIDPK,
		   --T.TCFirstName + ' ' + t.TCLastName as tcname,
		   --cc.TCDOB,
		   case when T.TCDOD < @edate and T.TCDOD is not null then T.TCDOD else null end as tcdod,
		  dateadd(dd, (40 -T.GestationalAge)*7, T.TCDOB) as dev_bdate,
		  case when T.tcidPK is not null then 'Complete' else '' end as tciddone
	 FROM @tblCommonCohort cc
	left join TCID T on t.HVCaseFK = cc.HVCasePK and T.TCIDPK = cc.TCIDPK 	  
)
,
cteTCMedical
as
(
SELECT cc.HVCasePK ,cc.TCIDPK
	  ,max(TCItemDate) AS TCMedicalMaxDate -- We mean really the last date in the database as per JR
 FROM @tblCommonCohort cc
 LEFT JOIN TCMedical t ON cc.HVCasePK = t.HVCaseFK and cc.TCIDPK = t.TCIDFK
GROUP BY cc.HVCasePK,cc.TCIDPK

)
,
cteLastDateOnMedicalForm
as
(
SELECT cc.HVCasePK ,cc.TCIDPK,oldid,

	case when cc.tcidpk is null 
	 and datediff( d, tcdob, intakedate) >= 0
	 and datediff( d, @edate, dateadd(dd, 30,tcdob)) >= 0 	
	 then 'Missing'
	 when cc.tcidpk is null 
	 and datediff( d, tcdob, intakedate) < 0
	 and datediff( d, @edate, dateadd(dd, 30, intakedate)) < 0 	
     then 'due by ' + convert(varchar(20), dateadd(dd, 30,intakedate), 101)	
     	
	when TCMedicalMaxDate is not null then	
		'Last date entered on Medical Form: ' + convert(varchar(20), TCMedicalMaxDate, 101)	
	
	
	else ''
	end  as lastdate

 FROM @tblCommonCohort cc 
 left join cteTCMedical tcm on tcm.hvcasePK = cc.hvcasePK and cc.tcidpk = tcm.tcidpk
)

 -- rspFSWEnrolledCaseTickler 5, '12/31/2012'


,cteTCIDCohort
as
(
SELECT cc.HVCasePK,
		T.TCIDPK,
		 case
				  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
					  DischargeDate
				  else
					  @eDate
			  end as lastdate,
		case
		  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @eDate then
			  datediff(day,cc.tcdob,DischargeDate)
		  else
			  datediff(day,cc.tcdob,@eDate)
	  end as tcAgeDays,
	  GestationalAge,
	  cc.TCDOB	  		
		
 FROM @tblCommonCohort cc
left join TCID T on T.HVCaseFK = cc.HVCasePK 		

)
,
cteTCIDCohort2
as
(
	select HVCasePK
		  
		  , TCIDPK
		  
		  , case when datediff(month,TCDOB,lastdate) >= 24 or GestationalAge = 40
					then tcAgeDays
				when datediff(month,TCDOB,lastdate) < 24 and GestationalAge < 40
					then tcAgeDays - ((40-GestationalAge) * 7)
			end as tcASQAgeDays
		  	  
		from cteTCIDCohort ca
	)

,
cteASQDueInterval -- age appropriate ASQ Intervals that are expected to be there
as
(
	select
		  cc.HVCasePK
		 ,cc.TCIDPK
		 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

		from cteTCIDCohort2 cc
			left join codeDueByDates cd on scheduledevent = 'ASQ' and tcASQAgeDays >= DueBy			
		group by cc.HVCasePK
		 ,cc.TCIDPK
					-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
)




-- Shots


   
	,
	cteImmunizationsPolio
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountPolio
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountPolio
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			left join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate 
				and MedicalItemTitle = 'Polio'
		group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)

	,
	cteImmunizationsDTaP
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountDTaP
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountDTaP
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle = 'DTaP'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
	
	,
	cteImmunizationsMMR
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountMMR
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountMMR
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle = 'MMR'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)	
	,
	cteImmunizationsHIB
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountHIB
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHIB
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle = 'HIB'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)			
	,
	cteImmunizationsHEP
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountHEP
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'HEP-B'
				--and MedicalItemTitle like 'HEP-%'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)		
	,
	cteImmunizationsVZ  -- Chicken Pox
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountVZ
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'VZ'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)		
	,
	cteImmunizationsWBV -- Well Baby Visits
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountWBV
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'WBV'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)		

	,
	cteImmunizationsLeadScreening -- Lead screening
	as
	(
	select coh.HVCasePK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCountLeadScreening
			, count(case when dbo.IsFormReviewed(TCItemDate,'TM',TCMedicalPK) = 1 
					then 1 
					else 0 
					end) as FormReviewedCountHEP
		from @tblCommonCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.HVCasePK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and @edate
				and MedicalItemTitle like 'Lead'
				 group by coh.HVCasePK
				, coh.TCIDPK
				, MedicalItemTitle
				
	)		
	
	
--- intervals	
	
,cteDTPInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'DTaP' AND DueBy > cc.TCAgeDays -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)
,cteHEPBInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'HEP-B' AND DueBy > cc.TCAgeDays -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)	
,cteHIBInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'HIB' AND DueBy > cc.TCAgeDays -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)		
,cteLeadInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'Lead' AND DueBy > cc.TCAgeDays -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)		
,cteMMRInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'MMR' AND DueBy > cc.TCAgeDays -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)		
,ctePolioInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'Polio' AND DueBy > cc.TCAgeDays  -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)		
,cteVZInterval -- Chicken Pox
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'VZ' AND DueBy > cc.TCAgeDays -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)	
,cteWBVInterval
as
(
SELECT 
		cc.HVCasePK,
		cc.TCIDPK	
	  , min(Interval) AS Interval 
	  , min(DueBy) as DueBy
	  , min(MaximumDue) as MaximumDue	  
	  , min(Frequency) as Frequency
	  
 		from @tblCommonCohort cc			
			left join codeduebydates on scheduledevent = 'WBV' AND DueBy > cc.TCAgeDays -- minimum interval
	 
 GROUP BY HVCasePK, TCIDPK
 
)	


SELECT distinct cc.HVCasePK
	  ,cc.ProgramFK
	  ,cc.OldID
	  ,cc.PC1ID
	  ,cc.tcdob
	  ,TCAgeDays
	  ,SupervisorName
	  ,SupervisorFK
	  ,FSWName
	  ,cc.FSWFK
	  ,PCName
	  ,cc.TCIDPK 
	  ,tcname
	  ,IntakeDate
	  ,DischargeDate
	  ,CaseProgress
	  ,TCNumber
	  ,MultipleBirth
	  ,cl.LevelName
	  ,cl.StartLevelDate 
	  ,Intakedd   
	  ,tcid_dd

	  ,cpsid.PSIDue 
	  ,cpsiu.lastpsi
	  
	  ,clfd.FollowUpDue
	  ,clfu.lastFollowUp
	  
	  
	  
	  ,XDateAge
	  ,ref.HVCasePK
	  ,ref_enr
	  ,ref_fup
	  ,ref_last
	  ,expectedvisitcount
	  ,actualvisitcount
	  ,attemptedvisitcount
	  ,inhomevisitcount
	  ,CONVERT(VARCHAR, round(COALESCE(cast(actualvisitcount AS FLOAT) * 100/ NULLIF(expectedvisitcount,0), 0), 0))   + '%'   as NYSAchievementMonthlyRate 
	  ,CONVERT(VARCHAR, round(COALESCE(cast(inhomevisitcount AS FLOAT) * 100/ NULLIF(actualvisitcount,0), 0), 0))   + '%'   as InHomeVisitMonthlyRate 

	  ,CAST((VisitLengthInminutesMOnthly / 60) AS VARCHAR(8)) + ':' + 
       RIGHT('0' + CAST((VisitLengthInminutesMOnthly % 60) AS VARCHAR(2)), 2) as VisitLengthInOneMonth
	  
	  
	  ,expected3Monthsvisitcount
	  ,actual3Monthsvisitcount
	  ,attempted3Monthsvisitcount
	  ,inhome3Monthsvisitcount
	  ,CONVERT(VARCHAR, round(COALESCE(cast(actual3Monthsvisitcount AS FLOAT) * 100/ NULLIF(expected3Monthsvisitcount,0), 0), 0))   + '%'   as NYSAchievement3MonthlyRate 
	  ,CONVERT(VARCHAR, round(COALESCE(cast(inhome3Monthsvisitcount AS FLOAT) * 100/ NULLIF(actual3Monthsvisitcount,0), 0), 0))   + '%'   as InHomeVisit3MonthlyRate 
	  
	  ,CAST((VisitLengthInminutes3MOnthly / 60) AS VARCHAR(8)) + ':' + 
       RIGHT('0' + CAST((VisitLengthInminutes3MOnthly % 60) AS VARCHAR(2)), 2) as VisitLengthInThreeMonth
	  
      ,case when ls.Last5Visits is not null then left(ls.Last5Visits,len(ls.Last5Visits)-1) else '' end as Last5Visits
      
	  ,case 
			when TCReceiving1 = 1 or TCReceiving2 = 1 or TCReceiving3 = 1 or TCReceiving4 = 1 then ' Child receiving EIP ' 
	        when casq.Interval is null or casq.Interval = '00' then ' due by ' + case when IntakeDate < dev_bdate then 
					convert(varchar(20), dev_bdate, 101) else convert(varchar(20), IntakeDate, 101) end
			else cdasq.EventDescription + ' due  between ' + convert(varchar(20), dateadd(dd,cdasq.MinimumDue ,dev_bdate), 101) + ' and ' + convert(varchar(20), dateadd(dd,cdasq.MaximumDue ,dev_bdate), 101)
			--else cdasq.EventDescription + ' due  between ' + convert(varchar(20), dateadd(dd,cdasq.MinimumDue ,tcdob), 101) + ' and ' + convert(varchar(20), dateadd(dd,cdasq.MaximumDue ,tcdob), 101)
			end as ASQDue   
     
		--, hvl.levelname as CurrentLevelName
		--, convert(varchar(12), hvl.levelassigndate , 101) as levelassigndate		
		, case 
			 when TCReceiving1 = 1 or TCReceiving2 = 1 or TCReceiving3 = 1 or TCReceiving4 = 1 then ' Child receiving EIP ' 
		
			 when lastASQ.FormOutOfWindow = 0 and lastASQ.FormName is not null then lastASQ.FormName + ' In Window On ' + convert(varchar(12), lastASQ.FormDate , 101)
			 when lastASQ.FormOutOfWindow = 1 and lastASQ.FormName is not null  then lastASQ.FormName + ' Out of Window On ' + convert(varchar(12), lastASQ.FormDate , 101)
			 when lastASQ.FormMissing = 1 and lastASQ.FormName is not null  then lastASQ.FormName + ' Missing ' 
			 
			 when lastASQ.FormName is null then '' end
			 
			 
			 as formname
			 
			, case when cc.TCIDPK is not null then ld.lastdate else '' end as lastdateOnMedicalForm	
		
		
		,case when ctePolio.Frequency is  null then '0' else cast(ctePolio.Frequency as varchar(2)) + 
		
		case when polio.ImmunizationCountPolio is null or  ctePolio.Frequency > polio.ImmunizationCountPolio then ' due by ' + convert(varchar(12), dateadd(dd,ctePolio.MaximumDue, cc.tcdob ), 101) + '; ' 
		else
		'  due; ' 
		end
				
		 +
		case when polio.ImmunizationCountPolio is null then ' 0 completed' else cast(polio.ImmunizationCountPolio as varchar(2)) + ' completed' end 		
		end as PolioCount
		
		
		, case when cteDTP.Frequency is  null then '0' else cast(cteDTP.Frequency as varchar(2)) + 
		
		case when DTap.ImmunizationCountDTaP is null or  cteDTP.Frequency > DTap.ImmunizationCountDTaP then ' due by ' + convert(varchar(12), dateadd(dd,cteDTP.MaximumDue, cc.tcdob ), 101) + '; ' 
		else
		'  due; ' 
		end
		
		+ 
		case when DTap.ImmunizationCountDTaP is null then ' 0 completed' else cast(DTap.ImmunizationCountDTaP as varchar(2)) + ' completed' end 		
		end as DTaPCount		
	
	
		, case when cteMMR.Frequency is  null then '0' else cast(cteMMR.Frequency as varchar(2)) + 
		
		case when MMR.ImmunizationCountMMR is null or  cteMMR.Frequency > MMR.ImmunizationCountMMR then ' due by ' + convert(varchar(12), dateadd(dd,cteMMR.MaximumDue, cc.tcdob ), 101) + '; ' 
		else
		'  due; ' 
		end
		
		 + 		
		case when MMR.ImmunizationCountMMR is null then ' 0 completed' else cast(MMR.ImmunizationCountMMR as varchar(2)) + ' completed' end 		
		end as MMRCount
		
		, case when cteHIB.Frequency is  null then '0' else cast(cteHIB.Frequency as varchar(2)) + 
		
		case when HIB.ImmunizationCountHIB is null or  cteHIB.Frequency > HIB.ImmunizationCountHIB then ' due by ' + convert(varchar(12), dateadd(dd,cteHIB.MaximumDue, cc.tcdob ), 101) + '; ' 
		else
		'  due; ' 
		end		
		
		+ 
		case when HIB.ImmunizationCountHIB is null then ' 0 completed' else cast(HIB.ImmunizationCountHIB as varchar(2)) + ' completed' end 		
		end as HIBCount		
		
		
		
		
		
		
		
		, case when cteHEPB.Frequency is  null then '0' else cast(cteHEPB.Frequency as varchar(2)) + 
		
			case when HEP.ImmunizationCountHEP is null or  cteHEPB.Frequency > HEP.ImmunizationCountHEP then ' due by ' + convert(varchar(12), dateadd(dd,cteHEPB.MaximumDue, cc.tcdob ), 101) + '; ' 
			else
			'  due; ' 
			end	
		
		+ 
		case when HEP.ImmunizationCountHEP is null then ' 0 completed' else cast(HEP.ImmunizationCountHEP as varchar(2)) + ' completed' end 		
		end as HEPCount	
		
		, case when cteChickenPox.Frequency is  null then '0' else cast(cteChickenPox.Frequency as varchar(2)) +
		
			case when ChickenPox.ImmunizationCountVZ is null or  cteChickenPox.Frequency > ChickenPox.ImmunizationCountVZ then ' due by ' + convert(varchar(12), dateadd(dd,cteChickenPox.MaximumDue, cc.tcdob ), 101) + '; ' 
			else
			'  due; ' 
			end	
		 
		 
		 + 
		case when ChickenPox.ImmunizationCountVZ is null then ' 0 completed' else cast(ChickenPox.ImmunizationCountVZ as varchar(2)) + ' completed' end 		
		end as ChickenPoxCount	
		
		, case when cteWBV.Frequency is  null then '0' else cast(cteWBV.Frequency as varchar(2)) + 
		
			case when WBV.ImmunizationCountWBV is null or  cteWBV.Frequency > WBV.ImmunizationCountWBV then ' due by ' + convert(varchar(12), dateadd(dd,cteWBV.MaximumDue, cc.tcdob ), 101) + '; ' 
			else
			'  due; ' 
			end	
		
		+ 
		case when WBV.ImmunizationCountWBV is null then ' 0 completed' else cast(WBV.ImmunizationCountWBV as varchar(2)) + ' completed' end 		
		end as WBVCount	

		, case when cteWBV.Frequency is  null then '0' else cast(cteWBV.Frequency as varchar(2)) + 
		
		case when WBV.ImmunizationCountWBV is null or cteWBV.Frequency > WBV.ImmunizationCountWBV then ' due by ' + convert(varchar(12), dateadd(dd,cteWBV.MaximumDue, cc.tcdob ), 101) + '; ' 
		else
		'  due; ' 
		end
		
		+ 
		case when WBV.ImmunizationCountWBV is null then ' 0 completed' else cast(WBV.ImmunizationCountWBV as varchar(2)) + ' completed' end 		
		end as WBVCount			

		, case when cteLead.Frequency is  null then '0' else cast(cteLead.Frequency as varchar(2)) + 
		
			case when LeadScreen.ImmunizationCountLeadScreening is null or  cteLead.Frequency > LeadScreen.ImmunizationCountLeadScreening then ' due by ' + convert(varchar(12), dateadd(dd,cteLead.MaximumDue, cc.tcdob ), 101) + '; ' 
			else
			'  due; ' 
			end	
		
		+ 
		case when LeadScreen.ImmunizationCountLeadScreening is null then ' 0 completed' else cast(LeadScreen.ImmunizationCountLeadScreening as varchar(2)) + ' completed' end 		
		end as LeadScreen	
		
	  
	   FROM @tblCommonCohort cc
	   
		left join ctePSIFormDueDates psiIntervalDue on psiIntervalDue.hvcasepk = cc.HVCasePK  and cc.TCIDPK = psiIntervalDue.TCIDPK 

	   
	  --inner join cteTCIDFormDone tcidform on tcidform.HVCasePK = cc.HVCasePK
	  left join cteReferrals ref on ref.HVCasePK = cc.HVCasePK
	  left join cteExpectedMonthlyHomeVisits expvisits on expvisits.HVCasePK = cc.HVCasePK 
	  left join cteAttemptedAndActualMonthlyHomeVisits othervisits on othervisits.HVCasePK = cc.HVCasePK

	  left join cteExpected3MonthsHomeVisits exp3Monthsvisits on exp3Monthsvisits.HVCasePK = cc.HVCasePK 
	  left join cteAttemptedAndActual3MonthsHomeVisits other3Monthsvisits on other3Monthsvisits.HVCasePK = cc.HVCasePK
	  
	  inner join cteLast5VisitsConcatenated ls on ls.HVCasePK = cc.HVCasePK 
	  inner join cteCurrentLevel cl on cl.HVCasePK = cc.HVCasePK 
	  
	  left join cteTCID tc on tc.HVCasePK = cc.HVCasePK and tc.TCIDPK = cc.TCIDPK 
	  left join cteASQDueInterval casq on casq.HVCasePK = cc.HVCasePK and casq.TCIDPK = cc.TCIDPK 
	  left join codeDueByDates cdasq on scheduledevent = 'ASQ' and cdasq.Interval = casq.Interval  
	  
	  left join @tblPTDetails lastASQ on lastASQ.HVCaseFK = cc.HVCasePK and lastASQ.TCIDPK = cc.TCIDPK 
	  left join cteLastDateOnMedicalForm ld on ld.HVCasePK = cc.HVCasePK and ld.TCIDPK = cc.TCIDPK
	  
	  inner join dbo.udfHVLevel(@programfk, @edate) hvl on hvl.hvcasefk = cc.HVCasePK  -- to get CurrentLevelName, CurrentLevelDate

	  -- shots count
	  left join cteImmunizationsPolio polio on polio.HVCasePK = cc.HVCasePK and polio.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsDTaP DTap on DTap.HVCasePK = cc.HVCasePK and DTap.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsMMR MMR on MMR.HVCasePK = cc.HVCasePK and MMR.TCIDPK = cc.TCIDPK	  
	  left join cteImmunizationsHIB HIB on HIB.HVCasePK = cc.HVCasePK and HIB.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsHEP HEP on HEP.HVCasePK = cc.HVCasePK and HEP.TCIDPK = cc.TCIDPK
	  
	  left join cteImmunizationsVZ ChickenPox on ChickenPox.HVCasePK = cc.HVCasePK and ChickenPox.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsWBV WBV on WBV.HVCasePK = cc.HVCasePK and WBV.TCIDPK = cc.TCIDPK
	  left join cteImmunizationsLeadScreening LeadScreen on LeadScreen.HVCasePK = cc.HVCasePK and LeadScreen.TCIDPK = cc.TCIDPK
	  
	  
		left join cteDTPInterval cteDTP on cteDTP.HVCasePK = cc.HVCasePK and cteDTP.TCIDPK = cc.TCIDPK
		left join cteHEPBInterval cteHEPB on cteHEPB.HVCasePK = cc.HVCasePK and cteHEPB.TCIDPK = cc.TCIDPK
		left join cteHIBInterval cteHIB on cteHIB.HVCasePK = cc.HVCasePK and cteHIB.TCIDPK = cc.TCIDPK
		left join cteLeadInterval cteLead on cteLead.HVCasePK = cc.HVCasePK and cteLead.TCIDPK = cc.TCIDPK
		left join cteMMRInterval cteMMR on cteMMR.HVCasePK = cc.HVCasePK and cteMMR.TCIDPK = cc.TCIDPK
		left join ctePolioInterval ctePolio on ctePolio.HVCasePK = cc.HVCasePK and ctePolio.TCIDPK = cc.TCIDPK
		left join cteVZInterval cteChickenPox on cteChickenPox.HVCasePK = cc.HVCasePK and cteChickenPox.TCIDPK = cc.TCIDPK
		left join cteWBVInterval cteWBV on cteWBV.HVCasePK = cc.HVCasePK and cteWBV.TCIDPK = cc.TCIDPK	  
	  
	  
	  
	  
	  left join ctePSIFormDueDates cpsid on cpsid.HVCasePK = cc.HVCasePK and cpsid.TCIDPK = cc.TCIDPK
	  left join cteLastPSIForm cpsiu on cpsiu.HVCasePK = cc.HVCasePK and cpsiu.TCIDPK = cc.TCIDPK
	  
	  
	  
	  left join cteFollowUpFormDueDates clfd on clfd.HVCasePK = cc.HVCasePK and clfd.TCIDPK = cc.TCIDPK
	  left join cteLastFollowUpForm clfu on clfu.HVCasePK = cc.HVCasePK and clfu.TCIDPK = cc.TCIDPK
	  
  
order by OldID



 -- rspFSWEnrolledCaseTickler 5, '12/31/2012'
GO
