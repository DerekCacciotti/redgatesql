SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 28, 2012>
-- Description:	<gets you data for quarterly service referrals>
-- exec [rspQSRReasonsServiceNotReceived] 1,'01/01/2011','12/31/2011'
-- =============================================
CREATE procedure [dbo].[rspQSRReasonsServiceNotReceived](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,
                                                        @sitefk int             = null                                                        
                                                        )

as
BEGIN

DECLARE @countServiceNotReceived INT
;
	with cteMain 
			as (	
				SELECT sr.ReasonNoService,sr.ServiceReferralPK
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
				AND ReasonNoService IS NOT NULL
				
	)
	,
	cteServicesNotReceived
	AS
	(
	
				SELECT 
						AppCodeText,ServiceReferralPK						
						FROM codeApp a 
				LEFT JOIN cteMain st ON a.AppCode = st.ReasonNoService
						WHERE AppCodeGroup = 'ReasonCode' and
						AppCodeUsedWhere like '%SR%' 	

	)
		
		
SELECT * INTO #MyTempTable2 FROM cteServicesNotReceived

------calculate the totals that will we use to caclualte percentages
Set @countServiceNotReceived = (SELECT count(ServiceReferralPK) FROM #MyTempTable2)		
				
SELECT AppCodeText
 ,CONVERT(VARCHAR,count(ServiceReferralPK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(count(ServiceReferralPK) AS FLOAT) * 100/ NULLIF(@countServiceNotReceived,0), 0), 0))  + '%)' AS TotalServiceNotReceived
 FROM #MyTempTable2	nrc		
GROUP BY nrc.AppCodeText
						


end
GO
