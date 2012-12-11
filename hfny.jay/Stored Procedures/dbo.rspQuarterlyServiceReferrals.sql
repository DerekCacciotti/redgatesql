
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <June 28, 2012>
-- Description:	<gets you data for quarterly service referrals>
--exec [rspQuarterlyServiceReferrals] 1,'07/01/2012','09/30/2012','01',null,null
--exec [rspQuarterlyServiceReferrals] 5,'07/01/2012','09/30/2012','02',null,null
-- =============================================
CREATE procedure [dbo].[rspQuarterlyServiceReferrals]
(
    @programfk           varchar(max)    = null,
    @sdate               datetime,
    @edate               datetime,
    @NatureOfReferral    char(2),
    @sitefk              int             = null,
    @casefilterspositive varchar(200)
)

as
begin

	-- Insert statements for procedure here
	if @ProgramFK is null
	begin
		select @ProgramFK =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @ProgramFK = REPLACE(@ProgramFK,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	declare @countMainTotal int
	declare @countServicesStarted int
	declare @countServicesPending int
	declare @countServiceNotReceived int

	declare @tblResults table(
		ServiceReferralCategory varchar(500) null
		,Total varchar(10) null
		,ServicesStarted varchar(10) null
		,ServicesPending varchar(10) null
		,ServiceNotReceived varchar(10) null
	);
	-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 


	with cteGetInitRequiredData
	as (select
		  h.HVCasePK
		 ,cp.PC1ID
		 ,P.PCFirstName+''+P.PCLastName as pcname

		 ,case when wp.SiteFK is null then 0 else wp.SiteFK end as SiteFK
		 ,rtrim(w.FirstName)+' '+rtrim(w.LastName) as WorkerName
		 ,case
			  when h.tcdob is not null then
				  h.tcdob
			  else
				  h.edc
		  end as tcdob
		from HVCase h
			inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
			inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
			inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK -- get SiteFK
			inner join PC P on P.PCPK = h.CPFK
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
	)
	,
	cteMain
	as (select sr1.ServiceReferralCategory
		 ,sr1.ServiceReferralType
		 ,sr.ServiceReceived
		 ,sr.StartDate
		 ,sr.ReasonNoService
		from cteGetInitRequiredData gir
			inner join ServiceReferral sr on sr.HVCaseFK = gir.HVCasePK
			inner join codeServiceReferral sr1 on sr1.codeServiceReferralPK = sr.ServiceCode
		where
			 sr.ReferralDate between @sdate and @edate
			 and NatureOfReferral = @NatureOfReferral -- @NatureOfReferral = 1arranged referrals
			 and (case when @SiteFK = 0 then 1 when SiteFK = @SiteFK then 1 else 0 end = 1)
	)
	,
	cteTotals
	as (select ServiceReferralCategory
		  ,count(ServiceReferralCategory) Total
		  ,sum(case
			   when (ServiceReceived = '1' and (StartDate is not null and (StartDate <= @edate))) then
				   1
			   else
				   0
		   end) as ServicesStarted
		  ,sum(case
			   when ((StartDate is null or (StartDate > @edate)) and (ReasonNoService is null or ReasonNoService = '')) then
				   1
			   else
				   0
		   end) as ServicesPending
		  ,sum(case
			   when (ServiceReceived = '0' and (ReasonNoService is not null and ReasonNoService <> '')) then
				   1
			   else
				   0
		   end) as ServiceNotReceived



		from cteMain
		group by ServiceReferralCategory
	--order by ServiceReferralType
	)

	--SELECT ServiceReferralCategory, Total, ServicesStarted, ServicesPending, ServiceNotReceived  INTO #MyTempTable FROM cteTotals
	--SELECT ServiceReferralCategory, Total, ServicesStarted, ServicesPending, ServiceNotReceived  INTO #MyTempTable FROM cteTotals
	insert into @tblResults
		select ServiceReferralCategory
			  ,Total
			  ,ServicesStarted
			  ,ServicesPending
			  ,ServiceNotReceived
			from cteTotals

	declare @tblFinalResults table(
		ServiceReferralCategory varchar(500) null
		,
		Total varchar(10) null
		,
		ServicesStarted varchar(10) null
		,
		ServicesPending varchar(10) null
		,
		ServiceNotReceived varchar(10) null
	)


	;
	with cteServiceCodes
	as
	(
	select distinct
				   [ServiceReferralCategory]
		from [codeServiceReferral]
	)


	insert into @tblFinalResults
		select sc.ServiceReferralCategory
			  ,isnull(Total,0) as Total
			  ,isnull(ServicesStarted,0) as ServicesStarted
			  ,isnull(ServicesPending,0) as ServicesPending
			  ,isnull(ServiceNotReceived,0) as ServiceNotReceived
			from @tblResults rs
				right join cteServiceCodes sc on rs.ServiceReferralCategory = sc.ServiceReferralCategory


	--SELECT * FROM @tblFinalResults

	--exec [rspQuarterlyServiceReferrals] 5,'07/01/2012','09/30/2012','01'

	--calculate the totals that will we use to caclualte percentages
	set @countMainTotal = (select sum(convert(int,Total))
							   from @tblResults)
	set @countServicesStarted = (select sum(convert(int,ServicesStarted))
									 from @tblResults)
	set @countServicesPending = (select sum(convert(int,ServicesPending))
									 from @tblResults)
	set @countServiceNotReceived = (select sum(convert(int,ServiceNotReceived))
										from @tblResults)

	--SELECT @countMainTotal,@countServicesStarted, @countServicesPending , @countServiceNotReceived

	-- Avoid divide by zero i.e.
	-- Use Coalesce as in example: SELECT COALESCE(dividend / NULLIF(divisor,0), 0) FROM sometable 
	-- for every divisor that is zero, you will get a zero in the result set  
	-- ... Devinder Singh Khalsa

	select
		  case
			  when (ServiceReferralCategory = 'HC') then 'Health Care'
			  when (ServiceReferralCategory = 'ETE') then 'Employment, Training and Education'
			  when (ServiceReferralCategory = 'OTH') then 'Other Services'
			  when (ServiceReferralCategory = 'DSS') then 'DSS / HRA'
			  when (ServiceReferralCategory = 'NUT') then 'Nutrition'
			  when (ServiceReferralCategory = 'CON') then 'Concrete Services'
			  when (ServiceReferralCategory = 'CSS') then 'Counseling / Support Services'
			  when (ServiceReferralCategory = 'FSS') then 'Family/Social Support Services'

		  end as ServiceReferralCategoryDescription

		 ,CONVERT(varchar,Total)+' ('+CONVERT(varchar,round(COALESCE(cast(Total as float)*100/NULLIF(@countMainTotal,0),0),0))+
			 '%)' as TotalServiceReferrals
		 ,CONVERT(varchar,ServicesStarted)+' ('+CONVERT(varchar,round(COALESCE(cast(ServicesStarted as float)*100/NULLIF(
			 @countMainTotal,0),0),0))+'%)' as TotalServicesStarted
		 ,CONVERT(varchar,ServicesPending)+' ('+CONVERT(varchar,round(COALESCE(cast(ServicesPending as float)*100/NULLIF(
			 @countMainTotal,0),0),0))+'%)' as TotalServicesPending
		 ,CONVERT(varchar,ServiceNotReceived)+' ('+CONVERT(varchar,round(COALESCE(cast(ServiceNotReceived as float)*100/NULLIF(
			 @countMainTotal,0),0),0))+'%)' as TotalServiceNotReceived

		from @tblFinalResults

	union

	select
		  'Total Referrals' as ServiceReferralCategoryDescription
		 ,CONVERT(varchar,@countMainTotal)+' ('+CONVERT(varchar,round(COALESCE(cast(@countMainTotal as float)*100/NULLIF(
			 @countMainTotal,0),0),0))+'%)' as TotalServiceReferrals
		 ,CONVERT(varchar,@countServicesStarted)+' ('+CONVERT(varchar,round(COALESCE(cast(@countServicesStarted as float)*100/
			 NULLIF(@countMainTotal,0),0),0))+'%)' as TotalServicesStarted
		 ,CONVERT(varchar,@countServicesPending)+' ('+CONVERT(varchar,round(COALESCE(cast(@countServicesPending as float)*100/
			 NULLIF(@countMainTotal,0),0),0))+'%)' as TotalServicesPending
		 ,CONVERT(varchar,@countServiceNotReceived)+' ('+CONVERT(varchar,round(COALESCE(cast(@countServiceNotReceived as float)*
			 100/NULLIF(@countMainTotal,0),0),0))+'%)' as TotalServiceNotReceived

end
GO
