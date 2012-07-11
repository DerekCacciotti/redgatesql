
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 28, 2012>
-- Description:	<gets you data for quarterly service referrals>
-- exec [rspQuarterlyServiceReferrals3] 1,'01/01/2011','12/31/2012','01'
-- =============================================
CREATE procedure [dbo].[rspQuarterlyServiceReferrals](@programfk    varchar(max)    = null,
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



DECLARE @countMainTotal INT 
DECLARE @countServicesStarted INT
DECLARE @countServicesPending INT
DECLARE @countServiceNotReceived INT

declare @tblResults table (
 ServiceReferralCategory varchar(500) NULL 
, Total varchar(10) NULL 
, ServicesStarted  varchar(10) NULL 
, ServicesPending  varchar(10) NULL 
, ServiceNotReceived  varchar(10) NULL
) 

;
	-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
	with cteGetInitRequiredData
			as (
				
				SELECT 
				h.HVCasePK,wp.SiteFK 
				FROM HVCase h 
				INNER JOIN CaseProgram cp ON h.HVCasePK = cp.HVCaseFK 
				INNER JOIN Worker w ON w.WorkerPK = cp.CurrentFSWFK
				INNER JOIN WorkerProgram wp ON wp.WorkerFK = w.WorkerPK -- get SiteFK
				inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
				WHERE 
				wp.SiteFK = isnull(@sitefk,wp.SiteFK)				
				
			)
			,
	cteMain
			as (
				SELECT 
				sr1.ServiceReferralCategory, sr1.ServiceReferralType
				,sr.ServiceReceived,sr.StartDate,sr.ReasonNoService
				FROM cteGetInitRequiredData gir
				INNER JOIN ServiceReferral sr ON sr.HVCaseFK = gir.HVCasePK 
				INNER JOIN codeServiceReferral sr1 ON sr1.codeServiceReferralPK = sr.ServiceCode
				WHERE 				
				sr.ReferralDate BETWEEN @sdate AND @edate
				AND
				NatureOfReferral = @NatureOfReferral -- @NatureOfReferral = 1arranged referrals
	)
	,
	cteTotals
			as (
	SELECT ServiceReferralCategory, count(ServiceReferralCategory) Total
			,sum(case
			   when (ServiceReceived = '1' AND (StartDate IS NOT NULL AND (StartDate <= @edate))) then
				   1
				   else
					   0
			   end) as ServicesStarted
			,sum(case
			   when ((StartDate IS NULL OR (StartDate > @edate)) AND (ReasonNoService IS NULL OR ReasonNoService = '')) then
				   1
				   else
					   0
			   end) as ServicesPending
			,sum(case
			   WHEN (ServiceReceived = '0' AND (ReasonNoService IS NOT NULL AND ReasonNoService <> '')) then
				   1
				   else
					   0
			   end) as ServiceNotReceived



	 FROM cteMain
	GROUP BY ServiceReferralCategory 
	--order by ServiceReferralType
	)

--SELECT ServiceReferralCategory, Total, ServicesStarted, ServicesPending, ServiceNotReceived  INTO #MyTempTable FROM cteTotals
--SELECT ServiceReferralCategory, Total, ServicesStarted, ServicesPending, ServiceNotReceived  INTO #MyTempTable FROM cteTotals
INSERT INTO @tblResults SELECT ServiceReferralCategory, Total, ServicesStarted, ServicesPending, ServiceNotReceived FROM cteTotals
--calculate the totals that will we use to caclualte percentages
Set @countMainTotal = (SELECT sum(convert(INT,Total)) FROM @tblResults)
Set @countServicesStarted = (SELECT sum(convert(INT,ServicesStarted)) FROM @tblResults)
Set @countServicesPending = (SELECT sum(convert(INT,ServicesPending)) FROM @tblResults)
Set @countServiceNotReceived = (SELECT sum(convert(INT,ServiceNotReceived)) FROM @tblResults)

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

	  FROM @tblResults

UNION 

SELECT 
'Total Referrals' AS ServiceReferralCategoryDescription
		 , CONVERT(VARCHAR,@countMainTotal) + ' (' + CONVERT(VARCHAR, round(COALESCE (cast(@countMainTotal AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServiceReferrals
		 , CONVERT(VARCHAR,@countServicesStarted) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@countServicesStarted AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServicesStarted
		 , CONVERT(VARCHAR,@countServicesPending) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@countServicesPending AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServicesPending
		 , CONVERT(VARCHAR,@countServiceNotReceived) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@countServiceNotReceived AS FLOAT) * 100/ NULLIF(@countMainTotal,0), 0), 0))  + '%)' AS TotalServiceNotReceived




end
GO
