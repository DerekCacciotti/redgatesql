
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 28, 2012>
-- Description:	<gets you data for quarterly service referrals>
-- exec [rspQuarterlyServiceReferrals] 1,'01/01/2011','12/31/2011'
-- =============================================
CREATE procedure [dbo].[rspQuarterlyServiceReferrals](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,
                                                        @sitefk int             = null                                                        
                                                        )

as
BEGIN

DECLARE @countMainTotal INT 
DECLARE @countServicesStarted INT
DECLARE @countServicesPending INT
DECLARE @countServiceNotReceived INT
;

	with cteMain
			as (
				SELECT 
				sr1.ServiceReferralCategory, sr1.ServiceReferralType
				,sr.ServiceReceived,sr.StartDate,sr.ReasonNoService
				FROM HVCase h 
				INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
				INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
				INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
				INNER JOIN ServiceReferral sr ON sr.HVCaseFK = h.HVCasePK 
				INNER JOIN codeServiceReferral sr1 ON sr1.codeServiceReferralPK = sr.ServiceCode
				WHERE 				
				sr.ReferralDate BETWEEN @sdate AND @edate
				AND
				NatureOfReferral = 1 -- arranged referrals
				AND 
				cp.ProgramFK = @programfk
				--AND 
				--wp.SiteFK = @sitefk
	)
	,
	cteTotals
			as (
	SELECT ServiceReferralCategory, count(ServiceReferralCategory) Total
			,sum(case
			   when (ServiceReceived = 1 AND (StartDate IS NOT NULL AND (StartDate <= @edate))) then
				   1
				   else
					   0
			   end) as ServicesStarted
			,sum(case
			   when ((StartDate IS NULL OR (StartDate > @edate)) AND (ReasonNoService IS NULL)) then
				   1
				   else
					   0
			   end) as ServicesPending
			,sum(case
			   when (ReasonNoService IS NOT NULL) then
				   1
				   else
					   0
			   end) as ServiceNotReceived



	 FROM cteMain
	GROUP BY ServiceReferralCategory 
	--order by ServiceReferralType
	)


SELECT * INTO #MyTempTable FROM cteTotals

--calculate the totals that will we use to caclualte percentages
Set @countMainTotal = (SELECT sum(Total) FROM #MyTempTable)
Set @countServicesStarted = (SELECT sum(ServicesStarted) FROM #MyTempTable)
Set @countServicesPending = (SELECT sum(ServicesPending) FROM #MyTempTable)
Set @countServiceNotReceived = (SELECT sum(ServiceNotReceived) FROM #MyTempTable)

--SELECT @countMainTotal,@countServicesStarted, @countServicesPending , @countServiceNotReceived

-- Avoid divide by zero i.e.
-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
-- for every divisor that is zero, you will get a zero in the result set  
-- ... Devinder Singh Khalsa

	SELECT
		case
			when (ServiceReferralCategory = 'HC') then 'Health Care'
			when (ServiceReferralCategory = 'ETE') then 'Employment, Training and Education'
	   		when (ServiceReferralCategory = 'OTH') then 'Other Services'
	   		when (ServiceReferralCategory = 'DSS') then 'DSS / HRA'
	   		when (ServiceReferralCategory = 'NUT') then 'Nutrition'
	   		when (ServiceReferralCategory = 'CON') then 'Concrete Services'
	   		when (ServiceReferralCategory = 'CSS') then 'Counseling / Support Services'
	   		when (ServiceReferralCategory = 'FSS') then 'Family/Social Support Services'   	   

		END AS ServiceReferralCategoryDescription

		 , CONVERT(VARCHAR,Total) + ' (' + CONVERT(VARCHAR, round(COALESCE (cast(Total AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServiceReferrals
		 , CONVERT(VARCHAR,ServicesStarted) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ServicesStarted AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServicesStarted
		 , CONVERT(VARCHAR,ServicesPending) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ServicesPending AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServicesPending
		 , CONVERT(VARCHAR,ServiceNotReceived) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(ServiceNotReceived AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServiceNotReceived

	  FROM #MyTempTable

UNION 

SELECT 
'Total Referrals' AS ServiceReferralCategoryDescription
		 , CONVERT(VARCHAR,@countMainTotal) + ' (' + CONVERT(VARCHAR, round(COALESCE (cast(@countMainTotal AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServiceReferrals
		 , CONVERT(VARCHAR,@countServicesStarted) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@countServicesStarted AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServicesStarted
		 , CONVERT(VARCHAR,@countServicesPending) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@countServicesPending AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServicesPending
		 , CONVERT(VARCHAR,@countServiceNotReceived) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@countServiceNotReceived AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServiceNotReceived

end
GO
