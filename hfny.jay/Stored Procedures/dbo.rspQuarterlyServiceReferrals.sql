
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 28, 2012>
-- Description:	<gets you data for quarterly service referrals>
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

	with cteSubTotals
			as (
				SELECT RTRIM(w.LastName)+', '+RTRIM(w.FirstName) as WorkerName, wp.SiteFK 
				,sr1.ServiceReferralCategory, sr1.ServiceReferralType
				,h.HVCasePK,sr.*
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
				cp.ProgramFK = 1
				
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



	 FROM cteSubTotals
	GROUP BY ServiceReferralCategory 
	--order by ServiceReferralType
	)



--SELECT ServiceReferralCategory
--	 , Total
--	 , ServicesStarted
--	 , ServicesPending
--	 , ServiceNotReceived
	 
--	  FROM cteTotals

--SELECT @countMainTotal = (SELECT sum(Total) FROM cteTotals)
--SELECT @countServicesStarted = (SELECT sum(ServicesStarted) FROM cteTotals)
--SELECT @countServicesPending = (SELECT sum(ServicesPending) FROM cteTotals)
--SELECT @countServiceNotReceived = (SELECT sum(ServiceNotReceived) FROM cteTotals)



SELECT * FROM cteTotals

end
GO
