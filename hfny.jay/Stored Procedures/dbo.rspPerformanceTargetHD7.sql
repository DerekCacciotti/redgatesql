
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
    @StartDate  datetime,
    @EndDate    datetime,
    @tblPTCases PTCases readonly
)

as
begin

	;
	with cteTotalCases
	as
	(
		select
			  ptc.HVCaseFK
			 ,ptc.PC1ID
			 ,ptc.OldID
			 ,ptc.PC1FullName
			 ,ptc.CurrentWorkerFK
			 ,ptc.CurrentWorkerFullName
			 ,ptc.CurrentLevelName
			 ,ptc.ProgramFK
			 ,ptc.TCIDPK
			 ,ptc.TCDOB
			 ,cp.DischargeDate
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
			  ,PC1ID
			  ,OldID
			  ,PC1FullName
			  ,CurrentWorkerFK
			  ,CurrentWorkerFullName
			  ,CurrentLevelName
			  ,ctc.ProgramFK
			  ,ctc.TCIDPK
			  ,ctc.TCDOB
			  ,DischargeDate
			  ,tcAgeDays
			  ,lastdate
			from cteTotalCases ctc
				inner join TCID T on T.HVCaseFK = ctc.HVCaseFK and T.TCIDPK = ctc.TCIDPK 
					-- looking at each child individualy i.e. gestationalage
			where
				 case
					 when T.GestationalAge is null then
						 dateadd(dd,.33*365.25,(((40-0)*7)+ctc.TCDOB))
					 else
						 dateadd(dd,.33*365.25,(((40-gestationalage)*7)+ctc.TCDOB))
				 end <= lastdate -- 4 months 
	)
	,
	cteASQDueInterval -- age appropriate ASQ Intervals that are expected to be there
	as
	(
		select
			  c.HVCaseFK
			 ,c.TCIDPK
			 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

			from cteCohort c
				inner join codeduebydates cd on scheduledevent = 'ASQ' and tcAgeDays >= DueBy
			group by HVCaseFK
					,c.TCIDPK 
						-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
	)
	,
	cteASQDueIntervalOneBefore -- age appropriate ASQ Intervals that are expected to be there
	as
	(
		select
			  c.HVCaseFK
			 ,c.TCIDPK
			 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

			from cteCohort c
				inner join cteASQDueInterval i on i.HVCaseFK = c.HVCaseFK and i.TCIDPK = c.TCIDPK
				inner join codeduebydates cd on scheduledevent = 'ASQ' and tcAgeDays >= DueBy
			where cd.Interval < i.Interval
			group by c.HVCaseFK
					,c.TCIDPK 
						-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
	)
	,
	cteASQDueIntervalTwoBefore -- age appropriate ASQ Intervals that are expected to be there
	as
	(
		select
			  c.HVCaseFK
			 ,c.TCIDPK
			 ,max(cd.Interval) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB

			from cteCohort c
				inner join cteASQDueIntervalOneBefore i on i.HVCaseFK = c.HVCaseFK and i.TCIDPK = c.TCIDPK
				inner join codeduebydates cd on scheduledevent = 'ASQ' and tcAgeDays >= DueBy
			where cd.Interval < i.Interval
			group by c.HVCaseFK
					,c.TCIDPK 
						-- Must 'group by HVCasePK, TCIDPK' to bring in twins etc (twins have same hvcasepks) (not just 'group by HVCasePK')
	)
    
	--Last ASQ Done prior to expected for each tcid
    ,
    cteLastASQDone 
    as 
    (
      select 
          c.HVCaseFK
          , c.TCIDPK   
          , max(A.TCAge) as Interval -- given child age, this is the interval that one expect to find ASQ record in the DB
       
       from cteCohort c
       inner join codeduebydates cd on scheduledevent = 'ASQ' and tcAgeDays < DueBy 
       inner join ASQ A on c.HVCaseFK = A.HVCaseFK and A.TCIDFK = c.TCIDPK  
       group by c.HVCaseFK,c.TCIDPK 
    )
	,
	cteExpectedForm
	as
	(
		select 'HD7' as PTCode
			  ,c.HVCaseFK
			  ,PC1ID
			  ,OldID
			  ,TCDOB
			  ,c.TCIDPK
			  ,PC1FullName
			  ,CurrentWorkerFullName
			  ,CurrentLevelName
			  , case when a1.ASQPK is not null and dbo.IsFormReviewed(a1.DateCompleted,'AQ',a1.ASQPK) = 1 then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  			 		a2.ASQPK is not null and dbo.IsFormReviewed(a2.DateCompleted,'AQ',a2.ASQPK) = 1 then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is not null and dbo.IsFormReviewed(a3.DateCompleted,'AQ',a3.ASQPK) = 1 then 1
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is null and charindex('(optional)',capp3.AppCodeText) > 0 and 
		  					a4.ASQPK is not null and dbo.IsFormReviewed(a4.DateCompleted,'AQ',a4.ASQPK) = 1 then 1
		  		else 0
		  		end
		  		as FormReviewed
			  , case when a1.ASQPK is not null and a1.ASQInWindow = 1 then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  			 		a2.ASQPK is not null and a2.ASQInWindow = 1 then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is not null and a3.ASQInWindow = 1 then 0
		  			 --when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  				--	a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  				--	a3.ASQPK is null then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is null and charindex('(optional)',capp3.AppCodeText) > 0 and 
		  					a4.ASQPK is not null and a4.ASQInWindow = 1 then 0
		  		else 1
		  		end
		  		as FormOutOfWindow
			  , case when a1.ASQPK is not null then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  			 		a2.ASQPK is not null then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is not null then 0
		  			 when a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
		  					a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
		  					a3.ASQPK is null and charindex('(optional)',capp3.AppCodeText) > 0 and 
		  					a4.ASQPK is not null then 1
		  		else 1
		  		end
		  		as FormMissing
			from cteCohort c
				left outer join cteASQDueInterval casi on casi.hvcasefk = c.hvcasefk and casi.tcidpk = c.tcidpk
				left outer join ASQ a1 on a1.hvcasefk = c.hvcasefk and casi.tcidpk = a1.tcidfk and a1.TCAge = casi.Interval
				left outer join scoreASQ score1 on score1.TCAge = casi.Interval and score1.ASQVersion = a1.VersionNumber 
				left outer join codeApp capp1 on a1.TCAge = capp1.AppCode and capp1.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp1.AppCodeUsedWhere)>0
				--One interval before due Interval			   
				left outer join cteASQDueIntervalOneBefore casi2 on casi2.hvcasefk = c.hvcasefk and casi2.tcidpk = c.tcidpk
				left outer join ASQ a2 on a2.hvcasefk = c.hvcasefk and casi2.tcidpk = a2.tcidfk and a2.TCAge = casi2.Interval
				left outer join scoreASQ score2 on score2.TCAge = casi2.Interval and score2.ASQVersion = a2.VersionNumber 
				left outer join codeApp capp2 on a2.TCAge = capp2.AppCode and capp2.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp2.AppCodeUsedWhere)>0
				--Two interval before due Interval			   
				left outer join cteASQDueIntervalTwoBefore casi3 on casi3.hvcasefk = c.hvcasefk and casi3.tcidpk = c.tcidpk
				left outer join ASQ a3 on a3.hvcasefk = c.hvcasefk and casi3.tcidpk = a3.tcidfk and a3.TCAge = casi3.Interval
				left outer join scoreASQ score3 on score3.TCAge = casi3.Interval and score3.ASQVersion = a3.VersionNumber 
				left outer join codeApp capp3 on a1.TCAge = capp3.AppCode and capp3.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp3.AppCodeUsedWhere)>0
				--Last ASQ Done prior to expected
				left outer join cteLastASQDone lasq on lasq.hvcasefk = c.hvcasefk and lasq.tcidpk = c.tcidpk
				left outer join ASQ a4 on a4.hvcasefk = c.hvcasefk and lasq.tcidpk = a4.tcidfk and a4.TCAge = lasq.Interval
				left outer join scoreASQ score4 on score4.TCAge = lasq.Interval and score4.ASQVersion = a4.VersionNumber 
				left outer join codeApp capp4 on a4.TCAge = capp4.AppCode and capp4.AppCodeGroup = 'TCAge' and 
													charindex('AQ',capp4.AppCodeUsedWhere) > 0
	)
	,
	cteMain
	as
	(	
		select PTCode
			  ,ef.HVCaseFK
			  ,PC1ID
			  ,OldID
			  ,TCDOB
			  
			  , ef.TCIDPK	
			  
			  ,PC1FullName
			  ,CurrentWorkerFullName
			  ,CurrentLevelName
			  ,case when a1.ASQPK is not null then a1.DateCompleted
					when a1.ASQPK is null and a2.ASQPK is not null then a2.DateCompleted
					when a1.ASQPK is null and a2.ASQPK is null and a3.ASQPK is not null then a3.DateCompleted
				end as FormDate
			  ,FormMissing
			  ,FormOutOfWindow
			  ,FormReviewed
			  -- see if we found the expected ASQ - first check condition a. age appropriate ASQ has all scores >= cutoff
			  ,case when (a1.ASQPK is not null and
						   (((a1.ASQCommunicationScore >= score1.CommunicationScore and 
						   		a1.ASQFineMotorScore >= score1.FineMotorScore and
								a1.ASQGrossMotorScore >= score1.GrossMotorScore and 
								a1.ASQPersonalSocialScore >= score1.PersonalScore and
								a1.ASQProblemSolvingScore >= score1.ProblemSolvingScore) 
					   		 and FormMissing = 0 and FormReviewed = 1 and FormOutOfWindow = 0))
						   -- condition b. at least one below cutoff score and TC Referred = Yes 
							   or ((a1.ASQCommunicationScore < score1.CommunicationScore or 
							   		a1.ASQFineMotorScore < score1.FineMotorScore or
								   	a1.ASQGrossMotorScore < score1.GrossMotorScore or 
								   	a1.ASQPersonalSocialScore < score1.PersonalScore or
								   	a1.ASQProblemSolvingScore < score1.ProblemSolvingScore) and 
								   (a1.TCReferred = '1' or 
									--  condition c. age appropriate ASQ missing, last recorded ASQ has TC Receiving = Yes
									(a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and 
										a2.ASQPK is not null and a2.ASQTCReceiving = '1') or 
									(a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
										a3.ASQTCReceiving = '1'))
			   			   		 	and FormMissing = 0 and FormReviewed = 1 and FormOutOfWindow = 0))
					-- condition d. if expected form is optional, check on last filled out form, 
					-- and don't forget we may need to skip back 2 for intervals 9 and 10
   			   		or (a1.ASQPK is null and charindex('(optional)',capp1.AppCodeText) > 0 and a2.ASQPK is not null and
						((a2.ASQCommunicationScore >= score2.CommunicationScore and 
							a2.ASQFineMotorScore >= score2.FineMotorScore and
							a2.ASQGrossMotorScore >= score2.GrossMotorScore and 
							a2.ASQPersonalSocialScore >= score2.PersonalScore and
							a2.ASQProblemSolvingScore >= score2.ProblemSolvingScore) 
		   					and FormMissing = 0 and FormReviewed = 1 and FormOutOfWindow = 0)
					   	-- condition d-b. at least one below cutoff score and TC Referred = Yes for last form completed
					   	or ((a2.ASQCommunicationScore < score2.CommunicationScore or 
								a2.ASQFineMotorScore < score2.FineMotorScore or
								a2.ASQGrossMotorScore < score2.GrossMotorScore or 
								a2.ASQPersonalSocialScore < score2.PersonalScore or
								a2.ASQProblemSolvingScore < score2.ProblemSolvingScore) and 
							(a2.TCReferred = '1' or 
							--  condition c. age appropriate ASQ missing, last recorded ASQ has TC Receiving = Yes
							(a4.ASQPK is null and a4.ASQTCReceiving = '1') or 
							(a2.ASQPK is null and charindex('(optional)',capp2.AppCodeText) > 0 and 
								a3.ASQTCReceiving = '1'))
								 	and FormMissing = 0 and FormReviewed = 1 and FormOutOfWindow = 0))
				then 1
		      	else 0
		      end as FormMeetsStandard
		from cteExpectedForm ef
			left outer join cteASQDueInterval casi on casi.hvcasefk = ef.hvcasefk and casi.tcidpk = ef.tcidpk
			left outer join ASQ a1 on a1.hvcasefk = ef.hvcasefk and casi.tcidpk = a1.tcidfk and a1.TCAge = casi.Interval
			left outer join scoreASQ score1 on score1.TCAge = casi.Interval and score1.ASQVersion = a1.VersionNumber 
			left outer join codeApp capp1 on a1.TCAge = capp1.AppCode and capp1.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp1.AppCodeUsedWhere) > 0
			--One interval before due Interval			   
			left outer join cteASQDueIntervalOneBefore casi2 on casi2.hvcasefk = ef.hvcasefk and casi2.tcidpk = ef.tcidpk
			left outer join ASQ a2 on a2.hvcasefk = ef.hvcasefk and casi2.tcidpk = a2.tcidfk and a2.TCAge = casi2.Interval
			left outer join scoreASQ score2 on score2.TCAge = casi2.Interval and score2.ASQVersion = a2.VersionNumber 
			left outer join codeApp capp2 on a2.TCAge = capp2.AppCode and capp2.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp2.AppCodeUsedWhere) > 0
			--Two interval before due Interval			   
			left outer join cteASQDueIntervalTwoBefore casi3 on casi3.hvcasefk = ef.hvcasefk and casi3.tcidpk = ef.tcidpk
			left outer join ASQ a3 on a3.hvcasefk = ef.hvcasefk and casi3.tcidpk = a3.tcidfk and a3.TCAge = casi3.Interval
			left outer join scoreASQ score3 on score3.TCAge = casi3.Interval and score3.ASQVersion = a3.VersionNumber 
			left outer join codeApp capp3 on a3.TCAge = capp3.AppCode and capp3.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp3.AppCodeUsedWhere) > 0
			--Last ASQ Done prior to expected
			left outer join cteLastASQDone lasq on lasq.hvcasefk = ef.hvcasefk and lasq.tcidpk = ef.tcidpk
			left outer join ASQ a4 on a4.hvcasefk = ef.hvcasefk and lasq.tcidpk = a4.tcidfk and a4.TCAge = lasq.Interval
			left outer join scoreASQ score4 on score4.TCAge = lasq.Interval and score4.ASQVersion = a4.VersionNumber 
			left outer join codeApp capp4 on a4.TCAge = capp4.AppCode and capp4.AppCodeGroup = 'TCAge' and 
												charindex('AQ',capp4.AppCodeUsedWhere) > 0
	)

	select PTCode
		  ,m.HVCaseFK
		  ,PC1ID
		  ,OldID
		  ,TCDOB
		  ,PC1FullName
		  ,CurrentWorkerFullName
		  ,CurrentLevelName
		  ,FormDate
		  ,FormReviewed
		  ,FormOutOfWindow
		  ,FormMissing
		  ,FormMeetsStandard
	  from cteMain m

	--select *
	--	from cteCohort
	--select *
	--	from cteExpectedForm
--WHERE hvcasefk = 31718
-- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'

	--SELECT * FROM cteASQDueInterval	
	--WHERE hvcasefk = 32508  -- interval due = 10

	--SELECT * FROM cteASQDueIntervalOneBefore	
	--WHERE hvcasefk = 32508  -- interval due one before = 09

	--SELECT * FROM cteASQDueIntervalTwoBefore	
	--WHERE hvcasefk = 32508  -- interval due one before = 08


	---------- rspPerformanceTargetReportSummary 5 ,'10/01/2012' ,'12/31/2012'


end
GO
