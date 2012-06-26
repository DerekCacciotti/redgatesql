SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[rspQuarterlyServiceReferrals]
	-- Add the parameters for the stored procedure here
	(@ProgramFK int = null, 
	@StartDate datetime, 
	@EndDate datetime,
	@SiteFK int = null)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

    -- Insert statements for procedure here

--SELECT *
--		, SiteFK
--		, RTRIM(hv_lname)+', '+RTRIM(hv_fname) as WorkerName 
--		, RTRIM(pcfname)+' '+RTRIM(pclname) as PCFullName 
--		, case when TCDOB is null then edc else TCDOB end as edc_dob
--		, ServiceReferral.* 
--		, ServiceReferralCategory 
--		, 1 as TotalCount
--		, case when StartDate is NOT null then 1 else 0 end as ServiceStarted
--		, case when (StartDate is null or StartDate > @EndDate) and ReasonNoService is null then 1 else 0 end as Pending
--		, case when ReasonNoService is not null then 1 else 0 end as DidNotReceive
--from hvcase 
--inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
--inner join Worker w ON CurrentFSWFK = w.WorkerPK
--inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
--inner join PC ON PCPK=PC1FK
--inner join ServiceReferral sr ON sr.HVCaseFK=HVCasePK 
--inner join codeServiceReferral csr ON csr.ServiceReferralCode=sr.ServiceCode
--where ReferralDate between @StartDate and @EndDate AND 
--		NatureOfReferral='01' AND -- arranged
--		SiteFK=ISNULL(SiteFK, @SiteFK) 
--group by ServiceReferralCategory

END
GO
