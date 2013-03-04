SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD4. Medical Provider for target children>
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 5 ,'01/01/2012' ,'03/31/2012'

-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD4]
(
    @StartDate      datetime,
    @EndDate      datetime,
    @tblPTCases  PTCases                           readonly
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
		 , ptc.OldID		
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
		  ,h.IntakeDate 
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
		  , PC1ID
		  , OldID		 
		  , PC1FullName
		  , CurrentWorkerFK
		  , CurrentWorkerFullName
		  , CurrentLevelName
		  , ProgramFK
		  , TCIDPK
		  , TCDOB
		  , DischargeDate
		  , tcAgeDays
		  , lastdate
		from cteTotalCases
		where ((TCDOB > IntakeDate AND tcAgeDays > 30 ) OR (TCDOB <= IntakeDate AND DATEADD(dd,30,IntakeDate)  <= lastdate )) -- Target children 30 days and older
	)	

	--SELECT * FROM cteCohort
	--ORDER BY OldID 
	---- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'	

	,
	cteInterval
	as
		(
			select HVCaseFK, TCIDPK					
					, max(Interval) as Interval
			from cteCohort
				LEFT join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays >= MaximumDue
				--WHERE Interval <> (SELECT dbd.Interval FROM codeDueByDates dbd WHERE dbd.EventDescription = '18 month Follow Up') -- there are no 18 months follow up in foxpro, but it is there in new HFNY. So need discussion w/JH. ... khalsa
			group by HVCaseFK, TCIDPK	
		)

	,
	cteIntervalNextFollowUp
	as
		(
			select HVCaseFK, TCIDPK, DueBy					
					, min(Interval) as Interval
			from cteCohort
				LEFT join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays < DueBy 
				--WHERE Interval <> (SELECT dbd.Interval FROM codeDueByDates dbd WHERE dbd.EventDescription = '18 month Follow Up') -- there are no 18 months follow up in foxpro, but it is there in new HFNY. So need discussion w/JH. ... khalsa
			group by HVCaseFK, TCIDPK, DueBy	
		)

	,
	

	cteChangeFormLessThanSixMonths
	as
		(

			SELECT c.HVCaseFK
			,  cach.TCHasMedicalProvider, max(FormDate) AS FormDate
			from cteCohort c	
			left join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType='CH' 
			WHERE FormDate < DATEADD(dd,183,tcdob)
			GROUP BY c.HVCaseFK, cach.TCHasMedicalProvider

		)

	,
	cteChangeFormBeforeNextFollowUp
	as
		(

			SELECT c.HVCaseFK
			,  cach.TCHasMedicalProvider, max(FormDate) AS FormDate
			from cteCohort c	
			left join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType='CH' 
			INNER JOIN cteIntervalNextFollowUp ctf ON ctf.HVCaseFK = c.HVCaseFK
			WHERE FormDate < DATEADD(dd,DueBy,tcdob)
			GROUP BY c.HVCaseFK, cach.TCHasMedicalProvider

		)

	,		
	
	cteExpectedForm
	as
		(
		select 'HD4' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , c.TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , FollowUpDate as FormDate
			  , case 
				when dbo.IsFormReviewed(fu.FollowUpDate,'FU',fu.FollowUpPK) = 1 then 1 
				when dbo.IsFormReviewed(T.TCIDCreateDate,'TC',T.TCIDPK) = 1 then 1 
				--when dbo.IsFormReviewed(cafu.FollowUpDate,'FU',cafu.FollowUpPK) = 1 then 1 
				--when dbo.IsFormReviewed(cachnf.FollowUpDate,'FU',cachnf.FollowUpPK) = 1 then 1 
				
				
				else 0 end 			  
			  as FormReviewed
			  , 0 as FormOutOfWindow -- not out of window
			  , 0 as FormMissing
			  , case 
					when (tcAgeDays < 183 AND catc.TCHasMedicalProvider = '1')
					  OR (cachl6.CommonAttributesPK IS NOT NULL AND cachl6.TCHasMedicalProvider IS NOT NULL AND cachl6.TCHasMedicalProvider = '1')
					  OR (cafu.CommonAttributesPK IS NOT NULL AND cafu.TCHasMedicalProvider IS NOT NULL AND cafu.TCHasMedicalProvider = '1')
					  OR (cachnf.CommonAttributesPK IS NOT NULL AND cachnf.TCHasMedicalProvider IS NOT NULL AND cachnf.TCHasMedicalProvider = '1')					
					 then 1 else 0 end as FormMeetsStandard

			from cteCohort c
			
			INNER JOIN TCID T ON T.HVCaseFK = c.HVCaseFK AND T.TCIDPK = c.TCIDPK  --- used in IsFormReviewed
			INNER join cteInterval i on c.HVCaseFK = i.HVCaseFK AND i.TCIDPK = c.TCIDPK  
			
			left join FollowUp fu on fu.HVCaseFK = c.HVCaseFK and fu.FollowUpInterval = i.Interval
			left join CommonAttributes cafu on cafu.HVCaseFK = fu.HVCaseFK and cafu.FormType='FU' and fu.FollowUpInterval = cafu.FormInterval 
			left join CommonAttributes catc on cafu.HVCaseFK = fu.HVCaseFK and cafu.FormType='TC' 
			
			

			LEFT JOIN cteChangeFormLessThanSixMonths cs ON cs.HVCaseFK = c.HVCaseFK			
			LEFT JOIN cteChangeFormBeforeNextFollowUp cf ON cf.HVCaseFK = c.HVCaseFK 			
			
			
			left join CommonAttributes cachl6 on cachl6.HVCaseFK = fu.HVCaseFK and cachl6.FormType='CH' AND cachl6.FormDate = cs.FormDate
			left join CommonAttributes cachnf on cachnf.HVCaseFK = fu.HVCaseFK and cachnf.FormType='CH' AND cachnf.FormDate = cs.FormDate
		)

	
	
	
	--SELECT * FROM cteInterval
	
	SELECT * FROM cteExpectedForm
	-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'	

end
GO
