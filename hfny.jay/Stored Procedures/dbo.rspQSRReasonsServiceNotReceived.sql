
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 28, 2012>
-- Description:	<gets you data for quarterly service referrals>
-- exec [rspQSRReasonsServiceNotReceived] 6,'01/01/2011','12/31/2012','01'
-- =============================================
CREATE procedure [dbo].[rspQSRReasonsServiceNotReceived](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,                                                       
                                                        @NatureOfReferral  char(2), 
                                                        @sitefk int             = NULL                                                                                                               
                                                        )

as
BEGIN

	-- Insert statements for procedure here
	if @ProgramFK is null
	begin
		select @ProgramFK =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @ProgramFK = REPLACE(@ProgramFK,'"','')



DECLARE @countServiceNotReceived INT

declare @tblResults table (
 AppCodeText varchar(500) NULL 
, ServiceReferralPK varchar(10) NULL
)


;
	with cteMain 
			as (	
				SELECT sr.ReasonNoService,sr.ServiceReferralPK,wp.SiteFK AS SiteFK
				FROM HVCase h 
				INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
				INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
				INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
				INNER JOIN ServiceReferral sr ON sr.HVCaseFK = h.HVCasePK 
				INNER JOIN codeServiceReferral sr1 ON sr1.codeServiceReferralPK = sr.ServiceCode
				inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
				WHERE 				
				sr.ReferralDate BETWEEN @sdate AND @edate
				AND
				NatureOfReferral = @NatureOfReferral -- @NatureOfReferral = 1arranged referrals
				AND
				ServiceReceived = 0 
				AND 
				ReasonNoService IS NOT NULL	
				AND 
				ReasonNoService <> ''				
	)
	,
	cteServicesNotReceived
	AS
	(
	
				SELECT 	AppCodeText,ServiceReferralPK,				
				CASE WHEN SiteFK IS NULL THEN 0 ELSE SiteFK END AS SiteFK
				FROM codeApp a 
				LEFT JOIN cteMain st ON a.AppCode = st.ReasonNoService
						WHERE 
						AppCodeGroup = 'ReasonCode'
						AND AppCodeUsedWhere like '%SR%' 	
					

	)
		

INSERT INTO @tblResults SELECT AppCodeText, ServiceReferralPK FROM cteServicesNotReceived WHERE SiteFK = isnull(@sitefk,SiteFK)

--calculate the totals that will we use to caclualte percentages
Set @countServiceNotReceived = (SELECT count(ServiceReferralPK) FROM @tblResults )		

				
SELECT AppCodeText
 ,CONVERT(VARCHAR,count(ServiceReferralPK)) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(count(ServiceReferralPK) AS FLOAT) * 100/ NULLIF(@countServiceNotReceived,0), 0), 0))  + '%)' AS TotalServiceNotReceived
 FROM @tblResults 	nrc		
GROUP BY nrc.AppCodeText
						
UNION 

SELECT ' Total Service not received'	AS AppCodeText, CONVERT(VARCHAR, round(COALESCE(NULLIF(@countServiceNotReceived,0), 0), 0))+ ' (100%))' AS TotalServiceNotReceived	


end
GO
