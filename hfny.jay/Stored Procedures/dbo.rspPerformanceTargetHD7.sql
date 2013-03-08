SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Febu. 28, 2013>
-- Description:	<gets you data for Performance Target report - HD7. Age Appropriate Developmental level >
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'
-- rspPerformanceTargetReportSummary 5 ,'01/01/2012' ,'03/31/2012'

-- =============================================
CREATE procedure [dbo].[rspPerformanceTargetHD7]
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
	select ctc.HVCaseFK
		  , PC1ID
		  , OldID		 
		  , PC1FullName
		  , CurrentWorkerFK
		  , CurrentWorkerFullName
		  , CurrentLevelName
		  , ctc.ProgramFK
		  , ctc.TCIDPK
		  , ctc.TCDOB
		  , DischargeDate
		  , tcAgeDays
		  , lastdate
		from cteTotalCases ctc
		INNER JOIN TCID T ON T.HVCaseFK = ctc.HVCaseFK AND T.TCIDPK = ctc.TCIDPK -- looking at each child individualy i.e. gestationalage
		where  
			case
				when T.GestationalAge is null then
				 dateadd(dd,.33*365.25,(((40-0)*7)+ctc.TCDOB)) 	
				else
				   dateadd(dd,.33*365.25,(((40-gestationalage)*7)+ctc.TCDOB))
			end  <= lastdate -- 4 months 
		
	)	

	
--SELECT * FROM cteCohort
--WHERE hvcasefk = 31718	
--ORDER BY hvcasefk 

		,
		cteASQDueInterval -- age appropriate ASQ Intervals that are expected to be there
		AS 
		(

		SELECT 
				c.HVCaseFK
			  , c.TCIDPK 	 
			  , max(cd.Interval) AS Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
		 
		 FROM cteCohort c
		 inner join codeduebydates cd on scheduledevent = 'ASQ' AND tcAgeDays >= DueBy  
		 GROUP BY HVCaseFK, c.TCIDPK -- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')

		)
		
		,
		cteOneIntervalBeforeASQDueInterval -- age appropriate ASQ Intervals that are expected to be there
		AS 
		(
			SELECT 
				   A.HVCaseFK				 
				 , max(TCAge) AS TCAge
				 , A.TCIDFK			 
			
			 FROM ASQ A
			INNER JOIN cteASQDueInterval cas ON cas.HVCaseFK = A.HVCaseFK AND cas.TCIDPK = A.TCIDFK
			WHERE A.TCAge <= cas.Interval 
			GROUP BY A.HVCaseFK, A.TCIDFK

		)		
		
		
		

-- Get the the last asq (max TCAge) that was done for each tcid
		,
		cteIntervalLastASQDone 
		AS 
		(
			SELECT 
					c.HVCaseFK
				  , c.TCIDPK 	 
				  , max(A.TCAge) AS Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
			 
			 FROM cteCohort c
			 inner join codeduebydates cd on scheduledevent = 'ASQ' AND tcAgeDays < DueBy 
			 LEFT JOIN ASQ A ON c.HVCaseFK = A.HVCaseFK AND A.TCIDFK = c.TCIDPK  
			 
			 GROUP BY c.HVCaseFK,c.TCIDPK 
		)

		,
		cteIntervalLastNonOptionalASQ
		AS 
		(
			SELECT 
					c.HVCaseFK
				  , c.TCIDPK 	 
				  , max(A.TCAge) AS Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
			 
			 FROM cteCohort c
			 inner join codeduebydates cd on scheduledevent = 'ASQ' AND tcAgeDays < DueBy 
			 LEFT JOIN ASQ A ON c.HVCaseFK = A.HVCaseFK AND A.TCIDFK = c.TCIDPK  
			 WHERE charindex('Optional',cd.ScheduledEvent) > 0
			 GROUP BY c.HVCaseFK,c.TCIDPK 
		)



		--,
		--cteMissingAgeAppropriateASQs -- age appropriate ASQ Intervals that are due
		--AS 
		--(

		--SELECT 
		--		c.HVCaseFK
		--	  , c.TCIDPK 	 
		--	  , max(cd.Interval) AS Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
		 
		-- FROM cteCohort c
		-- INNER JOIN cteASQDueInterval ci ON c.HVCaseFK = ci.HVCaseFK AND ci.TCIDFK = c.TCIDPK  
		-- LEFT JOIN ASQ A ON c.HVCaseFK = A.HVCaseFK AND A.TCIDFK = ci.TCIDPK  
		 
		 
		-- GROUP BY HVCaseFK, c.TCIDPK -- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')

		--)


,		
	
	cteExpectedForm
	as
		(
		
			select 'HD7' as PTCode
			  , c.HVCaseFK
			  , PC1ID
			  , OldID		 
			  , PC1FullName
			  , CurrentWorkerFK
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , c.ProgramFK
			  , c.TCIDPK
			  , TCDOB
			  , DischargeDate
			  , tcAgeDays
			  , lastdate
			  , casi.Interval AS intervalASQDone
			  , A1.ASQCommunicationScore
			  , score.CommunicationScore AS cuttoff
			  , A1.VersionNumber  	
			
			  
			 , CASE 
					WHEN 
						--a
						(A1.ASQCommunicationScore >= score.CommunicationScore AND A1.ASQFineMotorScore >= score.FineMotorScore AND  
						A1.ASQGrossMotorScore >= score.GrossMotorScore AND A1.ASQPersonalSocialScore >= score.PersonalScore AND  
						A1.ASQProblemSolvingScore >= score.ProblemSolvingScore)
						 
						----b 
						--OR (A1.ASQCommunicationScore < score.CommunicationScore OR A1.ASQFineMotorScore < score.FineMotorScore OR  
						--A1.ASQGrossMotorScore < score.GrossMotorScore OR A1.ASQPersonalSocialScore < score.PersonalScore OR  
						--A1.ASQProblemSolvingScore < score.ProblemSolvingScore) AND A1.TCReferred = '1'
						
						----c
						--OR A3.ASQTCReceiving = '1'
						----d
						--OR A2.ASQInWindow = 1 AND A2.ReviewCDS = 1
							
							
						THEN 1 
						
						ELSE   
						
						0
						 					
					END AS FormMeetsStandard 			  
			  
			  
			   FROM cteCohort c
			   
			   INNER JOIN cteASQDueInterval casi ON casi.hvcasefk = c.hvcasefk AND casi.tcidpk = c.tcidpk 
			   LEFT JOIN ASQ A1 ON A1.hvcasefk = c.hvcasefk AND casi.tcidpk = A1.tcidfk AND A1.TCAge = casi.Interval
			   LEFT JOIN scoreASQ score ON score.TCAge = casi.Interval AND score.ASQVersion = A1.VersionNumber  -- bring in age approp cutt off dates
			   
			   
			    --LEFT JOIN cteIntervalLastNonOptionalASQ cin ON cin.hvcasefk = c.hvcasefk AND cin.tcidpk = c.tcidpk
			    --LEFT JOIN ASQ A2 ON A2.hvcasefk = c.hvcasefk AND cin.tcidpk = A2.tcidfk AND A2.TCAge = cin.Interval

			    --LEFT JOIN cteIntervalLastASQDone cil ON cil.hvcasefk = c.hvcasefk AND cil.tcidpk = c.tcidpk
			    --LEFT JOIN ASQ A3 ON A3.hvcasefk = c.hvcasefk AND cil.tcidpk = A3.tcidfk AND A3.TCAge = cil.Interval
			    
			    
			    
			   
			   --INNER JOIN cteIntervalLastASQDone i ON i.hvcasefk = c.hvcasefk AND i.tcidpk = c.tcidpk -- age appropriate asq last completed
			   --LEFT JOIN ASQ A ON i.hvcasefk = A.hvcasefk AND i.tcidpk = A.tcidfk AND TCAge = i.Interval  -- bring in each tcidfk's asq record containing their scores
			   --LEFT JOIN scoreASQ score ON score.TCAge = i.Interval AND score.ASQVersion = A.VersionNumber  -- bring in age approp cutt off dates
		
		
		

		)





--SELECT * FROM cteCohort
SELECT * FROM cteExpectedForm
--WHERE hvcasefk = 31718
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'


end
GO
