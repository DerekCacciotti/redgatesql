
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 13, 2013>
-- Description:	<gets you data for Performance Target report - HD1. Immunizations at one year>
-- exec [rspPerformanceTargetHD1] '07/01/2012','09/30/2012','01',null,null
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- testing siteFK below
-- rspPerformanceTargetReportSummary 1 ,'10/01/2012' ,'12/31/2012', null,1
-- mods by jrobohn 20130222 - clean up names, code and layout
-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD1]
(
    @StartDate      datetime,
    @EndDate      datetime,
    @tblPTCases  PTCases                           readonly,
    @ReportType char(7)    = null
)

as
begin

	;
	with cteTotalCases
	as
	(
	select
		  ptc.HVCaseFK
		 , ptc.PC1ID
		 , ptc.PC1FullName
		 , ptc.CurrentWorkerFK
		 , ptc.CurrentWorkerFullName
		 , ptc.CurrentLevelName
		 , ptc.ProgramFK
		 , ptc.TCIDPK
		 , ptc.TCDOB
		 , cp.DischargeDate
		 ,case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  datediff(day,ptc.tcdob,DischargeDate)
			  else
				  datediff(day,ptc.tcdob,@EndDate)
		  end as tcAgeDays
		 ,case
			  when DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  DischargeDate
			  else
				  @EndDate
		  end as lastdate
		from @tblPTCases ptc
			inner join HVCase h on ptc.hvcaseFK = h.HVCasePK
			inner join CaseProgram cp on h.hvcasePK = cp.HVCaseFK -- AND cp.DischargeDate IS NULL
	)
	,
	-- Report: HD1. Immunization at one year
	cteCohort
	as
	(
	select HVCaseFK
		  ,PC1ID
		  ,PC1FullName
		  ,CurrentWorkerFK
		  ,CurrentWorkerFullName
		  ,CurrentLevelName
		  ,ProgramFK
		  ,TCIDPK
		  ,TCDOB
		  ,DischargeDate
		  ,tcAgeDays
		  ,lastdate
		from cteTotalCases
		where datediff(day,tcdob,@StartDate) <= 548
			 and datediff(day,tcdob,lastdate) >= 365
	)
	,
	cteImmunizations
	as
	(
	select coh.HVCaseFK
			, coh.TCIDPK
			, MedicalItemTitle
			, count(coh.TCIDPK) as ImmunizationCount
			--, count(TCIDPK) over (partition by convert(varchar(10),coh.HVCaseFK)+convert(varchar(10),TCIDPK)+MedicalItemTitle) as ImmunizationCount
		from cteCohort coh
			left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
			inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem
		where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
				and MedicalItemTitle in ('DTaP', 'Polio')
		group by coh.HVCaseFK
				, coh.TCIDPK
				, MedicalItemTitle
	)
	,
	cteMain
	as
	(
	select DISTINCT 
		  
		   PC1ID
		 , PC1FullName
		 , CurrentWorkerFK
		 , CurrentWorkerFullName
		 , CurrentLevelName
		 , ProgramFK		 
		 , TCDOB
		 , DischargeDate
		 , tcAgeDays
		 , lastdate
		 , imm.HVCaseFK
		 , imm.TCIDPK
		 , MedicalItemTitle
		 , ImmunizationCount	
			, 1 as FormReviewed
			, 1 as FormOutOfWindow
			, case when imm.HVCaseFK is null then 1 else 0 end as FormMissing
			, case when MedicalItemTitle = 'DTaP' and ImmunizationCount >= 3 and 
						MedicalItemTitle = 'Polio' and ImmunizationCount >= 2 then 1 else 0 end as MeetsStandard
	 from cteCohort coh
	 inner join cteImmunizations imm on imm.HVCaseFK = coh.HVCaseFK
	
	)
	
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'	
	
	
	 SELECT * FROM cteMain
	--select * from cteImmunizations
	--,
	--cteValid
	--as
	--(
	--select distinct
	--			   coh.HVCaseFK
	--			  ,coh.TCIDPK
	--			  ,case when count(TCMedical.TCIDFK) > 0 then 1 else 0 end as valid
	--	from cteCohort coh
	--		left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
	--	where TCItemDate between coh.TCDOB and dateadd(dd,365,coh.TCDOB)
	--	group by coh.HVCaseFK
	--			,coh.TCIDPK
	--)
	--,
	----HD1: Meet 1 - count DTaP i.e. Diptheria Tetanus Pertussis shots for each child                              
	--cteHD1DTaP_1YCount
	--as
	--(
	--select distinct
	--			   coh.HVCaseFK
	--			  ,coh.TCIDPK
	--			  ,count(coh.TCIDPK) as 'DTaP_1Y'
	--	from cteCohort coh
	--		left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
	--		inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem and cmi.MedicalItemTitle = 'DTaP'
	--	where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
	--	group by coh.HVCaseFK
	--			,coh.TCIDPK
	--)

	----HD1: Meet 2 - count Polio i.e. Polio Immunization  shots for each child      
	--,
	--cteHD1Polio_1YCount
	--as
	--(
	--select distinct
	--			   coh.HVCaseFK
	--			  ,coh.TCIDPK
	--			  ,count(coh.TCIDPK) as 'Polio_1Y'
	--	from cteHD1TotalCases coh
	--		left join TCMedical on TCMedical.hvcasefk = coh.hvcaseFK and TCMedical.TCIDFK = coh.TCIDPK
	--		inner join codeMedicalItem cmi on cmi.MedicalItemCode = TCMedical.TCMedicalItem and cmi.MedicalItemTitle = 'Polio'
	--	where TCItemDate between TCDOB and dateadd(dd,365,TCDOB)
	--	group by coh.HVCaseFK
	--			,coh.TCIDPK
	--)
	--,
	--cteHD1Meet
	--as (
	---- HD1: number who meet Performance Target
	---- Inner join HD1: Meet 1 and HD1: Meet 2
	--select dtap.HVCaseFK
	--	  ,dtap.TCIDPK
	--	  ,DTaP_1Y
	--	  ,Polio_1Y
	--	from cteHD1DTaP_1YCount dtap
	--		inner join cteHD1Polio_1YCount polio on dtap.hvcasefk = polio.hvcasefk and dtap.TCIDPK = polio.TCIDPK
	--	where DTaP_1Y >= 3
	--		 and Polio_1Y >= 2
	--)
	--,
	--cteHD1NotMeetingPT
	--as (
	--select
	--	  'HD1. Immunizations at one year  At least 90% of target children will be up to date on immunizations as of first birthday. Cohort: Target children 1 to 1.5 years of age' 
	--		  as ReportTitleText
	--	 ,PC1ID
	--	 ,TCDOB
	--	 ,'Missing Shots or Not on Time' as Reason
	--	 ,CurrentWorkerFullName
	--	 ,CurrentLevelName
	--	 ,'' as Explanation

	--	from cteHD1TotalCases cht
	--	where cht.HVCaseFK not in (select HVCaseFK
	--								   from cteHD1Meet)
	--)

	--SELECT * FROM cteHD1NotMeetingPT

	-- add all these into a row in a table
	--insert into @tblPTReportHD1TotalCases
	--		   (
	--		   NumberMeetingPT
	--		  ,TotalValidCases
	--		  ,TotalCases

	--		   )
	--	select
	--		  (select count(HVCaseFK)
	--			   from cteHD1TotalCases) as NumberMeetingPT
	--		 ,(select count(HVCaseFK)
	--			   from cteHD1Valid) as TotalValidCases
	--		 ,(select count(HVCaseFK)
	--			   from cteHD1Meet) as TotalCases



	--INSERT INTO @tblPTReportHD1NotMeetingPT
	--(
	--			ReportTitleText,
	--			PC1ID,					
	--			TCDOB,
	--			Reason,
	--			CurrentWorker,
	--			LevelAtEndOfReport,
	--			Explanation
	--) 
	-- SELECT * FROM cteHD1NotMeetingPT









	----SELECT * FROM cteHD1Polio_1YCount
	----ORDER BY HVCaseFK 

	----SELECT * FROM cteHD1DTaP_1YCount
	----ORDER BY HVCaseFK 

	----SELECT * FROM cteHD1Meet
	----ORDER BY HVCaseFK 

	-- --  rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'


	--if @ReportType = 'summary'

	--begin


	--	declare @NumberMeetingPT int = 0
	--	declare @TotalValidCases int = 0
	--	declare @TotalCases int = 0

	--	set @TotalCases = (select NumberMeetingPT
	--						  from @tblPTReportHD1TotalCases)
	--	set @TotalValidCases = (select TotalValidCases
	--								from @tblPTReportHD1TotalCases)
	--	set @NumberMeetingPT = (select TotalCases
	--								from @tblPTReportHD1TotalCases)

	--	if @TotalCases is null
	--		set @TotalCases = 0

	--	if @TotalValidCases is null
	--		set @TotalValidCases = 0

	--	if @NumberMeetingPT is null
	--		set @NumberMeetingPT = 0


	--	declare @tblPTReportHD1Summary table(
	--		ReportTitleText [varchar](max),
	--		PercentageMeetingPT [varchar](200),
	--		NumberMeetingPT int,
	--		TotalValidCases int,
	--		TotalCases int
	--	)





	--	insert into @tblPTReportHD1Summary ([ReportTitleText]
	--										,[PercentageMeetingPT]
	--										,[NumberMeetingPT]
	--										,[TotalValidCases]
	--										,[TotalCases])
	--		values (
	--			'HD1. Immunizations at one year  At least 90% of target children will be up to date on immunizations as of first birthday. Cohort: Target children 1 to 1.5 years of age'
	--			   ,' ('+CONVERT(varchar,round(COALESCE(cast(@NumberMeetingPT as float)*100/NULLIF(@TotalCases,0),0),0))+'%)'
	--			   ,CONVERT(varchar,@NumberMeetingPT)
	--			   ,CONVERT(varchar,@TotalValidCases)
	--			   ,CONVERT(varchar,@TotalCases)
	--			   )

	--	select *
	--		from @tblPTReportHD1Summary

	--end


--	ELSE
--		BEGIN

--			SELECT ReportTitleText
--				 , PC1ID
--				 , TCDOB
--				 , Reason
--				 , CurrentWorker
--				 , LevelAtEndOfReport
--				 , Explanation FROM @tblPTReportHD1NotMeetingPT
--					ORDER BY CurrentWorker, PC1ID 	


--		END	

end
GO
