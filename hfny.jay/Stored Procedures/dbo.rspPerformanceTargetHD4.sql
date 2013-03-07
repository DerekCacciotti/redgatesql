
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

-- TC less than 6 months old (while doing TCID, a row is inserted into CommonAttribute table). There are no followups for tc < 6 mos
-- There may be one or more CH Forms for TC < 6 months
-- Question: Is a one Medical Provider per case - Yes (so twins etc have only one doc)
, cteTCLessThan6MonthsTCForm 
AS
(
			select c.HVCaseFK
				 , cach.TCHasMedicalProvider
				 , FormDate

			from cteCohort c
			LEFT join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType='TC' 
			WHERE c.tcAgeDays < 183
			AND 
			FormDate <= @EndDate
			

)

, cteTCLessThan6MonthsCHForm 
AS
(
			select c.HVCaseFK
				 ,cach.TCHasMedicalProvider
				 ,max(FormDate) AS FormDate  -- get the latest CH

			from cteCohort c
			LEFT join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType='CH' 
			WHERE c.tcAgeDays < 183
			AND 
			FormDate <= @EndDate	
			group by c.HVCaseFK, cach.TCHasMedicalProvider

)

,
cteExpectedForm4TCLessThan6Months
	as
		(
		
		SELECT 'HD4' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName	
			  
			 , CASE 
					WHEN (chl6.TCHasMedicalProvider IS NOT NULL AND chl6.FormDate > tcl6.FormDate AND chl6.FormDate > '01/01/13' AND chl6.TCHasMedicalProvider = 1 ) -- latest of either TC or CH
							THEN chl6.FormDate -- note: preference is given to the latest CH record first, if there is one
							
							ELSE   -- note: otherwise we will use tcid record's info
							
							(CASE WHEN (tcl6.TCHasMedicalProvider IS NOT NULL AND tcl6.TCHasMedicalProvider = 1) THEN tcl6.FormDate ELSE NULL END )
						 					
					END AS FormDate 			  
			  

			  , case 
					when tcl6.FormDate IS NOT NULL then 1  -- there is no formreview for formtype = CH
					ELSE
					0
					end 			  
			  as FormReviewed			 
		 
			  , case -- Here FormOutOfWindow means that there must be an tcid record in CommonAttribute table for tc < 6 months
					when chl6.FormDate IS NOT NULL OR tcl6.FormDate IS NOT NULL then 0				  
					ELSE
					1
			    end as FormOutOfWindow				 
			 
			  , case -- there is atleast we one of either TC or CH record in CommonAttribute table (FormDate belongs to CommonAttribute table)
					when chl6.FormDate IS NOT NULL OR tcl6.FormDate IS NOT NULL then 0				  
					ELSE
					1
			    end as FormMissing	 
			 
			 , CASE 
					WHEN (chl6.TCHasMedicalProvider IS NOT NULL AND chl6.FormDate > tcl6.FormDate AND chl6.FormDate > '01/01/13' AND chl6.TCHasMedicalProvider = 1 ) -- latest of either TC or CH
							THEN 1 -- note: preference is given to the latest CH record first, if there is one
							
							ELSE   -- note: otherwise we will use tcid record's info
							
							(CASE WHEN (tcl6.TCHasMedicalProvider IS NOT NULL AND tcl6.TCHasMedicalProvider = 1) THEN 1 ELSE 0 END )
						 					
					END AS FormMeetsStandard 

			 
			 		 
			 FROM cteCohort c
			 INNER JOIN cteTCLessThan6MonthsTCForm tcl6 ON tcl6.HVCaseFK = c.HVCaseFK
			 LEFT JOIN cteTCLessThan6MonthsCHForm chl6 ON chl6.hvcasefk = tcl6.hvcasefk
		

		)


-- TC 6 months or older
, cteIntervals4TC6MonthsOrOlderTCForm  -- age appropriate follow up that is due for the TC
AS
(

		select HVCaseFK, TCIDPK					
					, max(Interval) as Interval
			from cteCohort c
				LEFT join codeDueByDates on ScheduledEvent = 'Follow Up' and c.tcAgeDays >= DueBy 
				WHERE c.tcAgeDays >= 183
				AND 
				Interval <> (SELECT dbd.Interval FROM codeDueByDates dbd WHERE dbd.EventDescription = '18 month Follow Up') -- there are no 18 months follow up in foxpro, but it is there in new HFNY. So need discussion w/JH. ... khalsa
				group by HVCaseFK, TCIDPK	

)

, cteLatestCHForm4TC6MonthsOrOlder -- latest CH form for the TC
AS
(

			select c.HVCaseFK
				 ,cach.TCHasMedicalProvider
				 ,max(FormDate) AS FormDate  -- get the latest CH

			from cteCohort c
			LEFT join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType='CH' 
			WHERE c.tcAgeDays >= 183
			AND 
			FormDate <= @EndDate
			group by c.HVCaseFK, cach.TCHasMedicalProvider

)

-- the following are not used. left it here for future look up
--	,
--	cteIntervalNextFollowUp
--	as
--		(
--			select HVCaseFK, TCIDPK				
--					, min(Interval) as Interval
--			from cteCohort
--				LEFT join codeDueByDates on ScheduledEvent = 'Follow Up' and tcAgeDays < DueBy 
--				WHERE Interval <> (SELECT dbd.Interval FROM codeDueByDates dbd WHERE dbd.EventDescription = '18 month Follow Up') -- there are no 18 months follow up in foxpro, but it is there in new HFNY. So need discussion w/JH. ... khalsa
--			group by HVCaseFK, TCIDPK
--		)

--,
--	cteChangeFormBeforeNextFollowUp
--	as
--		(

--			SELECT c.HVCaseFK
--			,  cach.TCHasMedicalProvider, max(FormDate) AS FormDate
--			from cteCohort c	
--			left join CommonAttributes cach on cach.HVCaseFK = c.HVCaseFK and cach.FormType='CH' 
--			INNER JOIN cteIntervalNextFollowUp ctf ON ctf.HVCaseFK = c.HVCaseFK
--			LEFT join codeDueByDates cd on ScheduledEvent = 'Follow Up' and cd.Interval = ctf.Interval  
--			WHERE c.tcAgeDays >= 183
--			AND 
--			FormDate < DATEADD(dd,cd.DueBy,tcdob)
--			GROUP BY c.HVCaseFK, cach.TCHasMedicalProvider

--		)



,
cteExpectedForm4TC6MonthsOrOlder
	as
		(
		
		SELECT 'HD4' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName			 				 
			 , CASE 
					WHEN (cach.TCHasMedicalProvider IS NOT NULL AND cach.FormDate > cafu.FormDate AND cach.FormDate > '01/01/13' AND cach.TCHasMedicalProvider = 1 ) -- latest CH first preferred
							THEN cach.FormDate -- note: preference is given to the latest CH record first, if there is one
							
							ELSE   -- note: otherwise we will use tcid record's info
							
							(CASE WHEN (cafu.TCHasMedicalProvider IS NOT NULL AND cafu.TCHasMedicalProvider = 1) THEN cafu.FormDate ELSE NULL END )
						 					
					END AS FormDate 			 


			  , case 
					when (cach.FormDate IS NOT NULL AND cach.TCHasMedicalProvider IS NOT NULL) OR (cafu.FormDate IS NOT NULL AND cafu.TCHasMedicalProvider IS NOT NULL) then 1  
					ELSE
					0
					end 			  
			  as FormReviewed			 
		 
			  , case -- Here FormOutOfWindow means that there must be either FU (Due now) or latest CH record in CommonAttribute table for tc >= 6 months
					when (cach.FormDate IS NOT NULL AND cach.TCHasMedicalProvider IS NOT NULL) OR (cafu.FormDate IS NOT NULL AND cafu.TCHasMedicalProvider IS NOT NULL) then 0				  
					ELSE
					1
			    end as FormOutOfWindow				 
			 
			  , case -- there is atleast we one of either FU (Due now) or latest CH record in CommonAttribute table (FormDate belongs to CommonAttribute table)
					when (cach.FormDate IS NOT NULL AND cach.TCHasMedicalProvider IS NOT NULL) OR (cafu.FormDate IS NOT NULL AND cafu.TCHasMedicalProvider IS NOT NULL) then 0				  
					ELSE
					1
			    end as FormMissing	 
			 
			 , CASE 
					WHEN (cach.TCHasMedicalProvider IS NOT NULL AND cach.FormDate > cafu.FormDate AND cach.FormDate > '01/01/13' AND cach.TCHasMedicalProvider = 1 ) -- latest CH first preferred
							THEN 1 -- note: preference is given to the latest CH record first, if there is one
							
							ELSE   -- note: otherwise we will use tcid record's info
							
							(CASE WHEN (cafu.TCHasMedicalProvider IS NOT NULL AND cafu.TCHasMedicalProvider = 1) THEN 1 ELSE 0 END )
						 					
					END AS FormMeetsStandard 


			 
			 		 
			 FROM cteCohort c
			 INNER join cteIntervals4TC6MonthsOrOlderTCForm tcGE6FUInterval on c.HVCaseFK = tcGE6FUInterval.HVCaseFK AND tcGE6FUInterval.TCIDPK = c.TCIDPK  -- GE = Greater or Equal
			 left join CommonAttributes cafu on cafu.HVCaseFK = c.HVCaseFK and cafu.FormType='FU' and tcGE6FUInterval.Interval = cafu.FormInterval 	-- get the FU row
			 
			 LEFT JOIN cteLatestCHForm4TC6MonthsOrOlder ch ON ch.HVCaseFK = c.HVCaseFK 
			 LEFT join CommonAttributes cach on cach.HVCaseFK = ch.HVCaseFK and cach.FormType='CH' and cach.FormDate = ch.FormDate  	-- get the latest CH row	
	

		)


		-- let us put the above two disconnected tables (one for tc < 6 and other for TC >= 6)

		SELECT * FROM cteExpectedForm4TCLessThan6Months
		UNION
		SELECT * FROM cteExpectedForm4TC6MonthsOrOlder 

	---- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'	



end
GO
