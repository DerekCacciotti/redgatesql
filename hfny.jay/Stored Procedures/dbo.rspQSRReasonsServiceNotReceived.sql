
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
CREATE procedure [dbo].[rspQSRReasonsServiceNotReceived]
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

	declare @countServiceNotReceived int

	declare @tblResults table(
		AppCodeText varchar(500) null
		,ServiceReferralPK varchar(10) null
	);

	with cteMain
	as (
	select sr.ReasonNoService
		  ,sr.ServiceReferralPK
		  ,wp.SiteFK as SiteFK
		from HVCase h
			inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
			inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
			inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK -- get SiteFK
			inner join ServiceReferral sr on sr.HVCaseFK = h.HVCasePK
			inner join codeServiceReferral sr1 on sr1.codeServiceReferralPK = sr.ServiceCode
			inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
		where
			 sr.ReferralDate between @sdate and @edate
			 and NatureOfReferral = @NatureOfReferral -- @NatureOfReferral = 1arranged referrals
			 and ServiceReceived = 0
			 and ReasonNoService is not null
			 and ReasonNoService <> ''
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	)
	,
	cteServicesNotReceived
	as
	(select AppCodeText
		  ,ServiceReferralPK
		from codeApp a
			left join cteMain st on a.AppCode = st.ReasonNoService
		where AppCodeGroup = 'ReasonCode'
			 and AppCodeUsedWhere like '%SR%'
	)

	insert into @tblResults
		select AppCodeText
			  ,ServiceReferralPK
			from cteServicesNotReceived

	--calculate the totals that will we use to calculate percentages
	set @countServiceNotReceived = (select count(ServiceReferralPK)
										from @tblResults)

	select AppCodeText
		  ,CONVERT(varchar,count(ServiceReferralPK))+' ('+CONVERT(varchar,round(COALESCE(cast(count(ServiceReferralPK) as float)*
			  100/NULLIF(@countServiceNotReceived,0),0),0))+'%)' as TotalServiceNotReceived
		from @tblResults nrc
		group by nrc.AppCodeText

	union

	select ' Total Service not received' as AppCodeText
		  ,CONVERT(varchar,round(COALESCE(NULLIF(@countServiceNotReceived,0),0),0))+' (100%))' as TotalServiceNotReceived


end
GO
