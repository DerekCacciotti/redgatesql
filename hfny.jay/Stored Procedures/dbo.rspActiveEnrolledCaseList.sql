
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/11/2012
-- Description:	Active Enrolled Case List
-- mod 2013Jun24 jrobohn reformat and add case filter criteria
-- =============================================
CREATE procedure [dbo].[rspActiveEnrolledCaseList]-- Add the parameters for the stored procedure here
    @programfk           varchar(max)    = null,
    @StartDt             datetime,
    @EndDt               datetime,
    @SiteFK              int             = 0,
    @casefilterspositive varchar(200)
as

	--DECLARE @StartDt DATE = '01/01/2011'
	--DECLARE @EndDt DATE = '05/31/2011'
	--DECLARE @programfk VARCHAR(MAX) = '1'
	--DECLARE @SiteFK INT = -1

	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @programfk = replace(@programfk,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end;

	select rtrim(PC.PCLastName)+cast(PC.PCPK as varchar(10)) [key01]
		  ,a.PC1ID
		  ,rtrim(PC.PCLastName)+', '+rtrim(PC.PCFirstName) [Name]
		  ,convert(varchar(12),PC.PCDOB,101) [DOB]
		  ,PC.SSNo [SSNo]
		  ,convert(varchar(12),Kempe.KempeDate,101) [KemptDate]
		  ,convert(varchar(12),HVScreen.ScreenDate,101) [ScreenDate]
		  ,rtrim(Worker.LastName)+', '+rtrim(Worker.FirstName) [FSW]
		  ,convert(varchar(12),Intake.IntakeDate,101) [IntakeDate]
		  ,CAST(DATEDIFF(year,PC.PCDOB,Intake.IntakeDate) as varchar(10))+' y' [AgeAtIntake]
		  ,case when a.DischargeDate is null then '' else convert(varchar(12),a.DischargeDate,101) end [CloseDate]
		  ,case when a.DischargeDate is null then 'Case Open' else rtrim(codeDischarge.DischargeReason) end [CloseReason]

		  --, CAST(DATEDIFF(month, Intake.IntakeDate, @EndDt) AS VARCHAR(10)) + ' m' [LengthInProgram]

		  ,case when a.DischargeDate is null or a.DischargeDate > @EndDt
				   then CAST(DATEDIFF(month,Intake.IntakeDate,@EndDt) as varchar(10))+' m' else
				   CAST(DATEDIFF(month,Intake.IntakeDate,a.DischargeDate) as varchar(10))+' m' end [LengthInProgram]

		  ,case when ca.TANFServices = 1 then 'Yes' else 'No' end [TANF]
		  ,case when ca.FormType = 'IN' then 'Intake' 
					else (select top 1 codeApp.AppCodeText
								from codeApp
								where ca.FormInterval = codeApp.AppCode
										and
										codeApp.AppCodeUsedWhere like '%FU%'
										and codeApp.AppCodeGroup = 'TCAge'
							) end [TANFServiceAt]
		  ,convert(varchar(12),ca.FormDate,101) [Eligible]
		  ,(select count(*)
				from HVLog
				where VisitType <> '0001'
					 and cast(VisitStartTime as date) <= @EndDt
					 and cast(VisitStartTime as date) >= b.IntakeDate
					 and HVCaseFK = b.HVCasePK
		   ) [HomeVisits]
		  -- folling fields are used for validating (to be removed)
		  ,(select top 1 ca.CommonAttributesPK
				from CommonAttributes ca
				where ca.HVCaseFK = b.HVCasePK
					 and ca.FormDate <= @EndDt
					 and ca.FormType in ('FU','IN')
				order by ca.FormDate desc
		   ) [CommonAttributesPKID]
		  ,ca.FormDate
		  ,ca.TANFServices
		  ,ca.FormType
		  ,ca.FormInterval
		  ,rtrim(T.TCLastName)+', '+rtrim(T.TCFirstName) [tcName]
		  ,convert(varchar(12),T.TCDOB,101) [tcDOB]
		  ,case when ls.SiteCode is null then '' else ls.SiteCode end SiteCode

		from CaseProgram as a
			join HVCase as b on a.HVCaseFK = b.HVCasePK
			inner join dbo.SplitString(@programfk,',') on a.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = a.HVCaseFK
			-- pc1 name, dob, and SS# = b.PC1FK <-> PC.PCPK -> PC.PCLastName + PC.PCFirstName, PC.PCDOB, PC.SSNo
			join PC on PC.PCPK = b.PC1FK
			-- screen date = a.HVCaseFK <-> Kempe.HVCaseFK -> Kempe.KempeDate
			join Kempe on Kempe.HVCaseFK = b.HVCasePK
			--
			-- kempe date = a.HVCaseFK <-> HVScreen.HVCaseFK -> HVScreen.ScreenDate
			join HVScreen on HVScreen.HVCaseFK = b.HVCasePK
			--
			-- FSW & site = a.CurrentFSWFK <-> Worker.WorkerPK -> Worker.LastName + Worker.FirstName ?? site ??
			left outer join Worker on Worker.WorkerPK = a.CurrentFSWFK
			join Workerprogram as wp on wp.WorkerFK = Worker.WorkerPK and wp.ProgramFK = @programfk
			left outer join listSite as ls on wp.SiteFK = ls.listSitePK
			--
			-- intake date & age at intake = a.HVCaseFK <-> Intake.HVCaseFK -> Intake.IntakeDate -> (PCDOB - IntakeDate)
			join Intake on Intake.HVCaseFK = b.HVCasePK
			--
			-- closed date & close reason = a.DischargeDate, a.DischargeReason <-> codeDischarge.DischargeCode 
			--                              -> codeDischarge.DischargeReason
			left outer join codeDischarge on a.DischargeReason = codeDischarge.DischargeCode
			--
			-- length in program = @EndDt - IntakeDate

			-- TANFservices, &  eligible = CA (CommonAttributes) : a.HVCaseFK <-> CA.HVCaseFK and CA.FormType IN ('FU', 'IN')
			-- , CA.FormDate <= @EndDt and CA.TANFServices = 1 
			-- if CA.FormType = 'IN' then FormInterval = 'In Take' else CA.FormInterval <-> codeApp.AppCode and
			-- codeApp.AppCodeUsedWhere LIKE '%FU%' and AppCodeGroup = 'TCAge' -> codeApp.AppCodeText
			-- CA.FormDate = Eligible date
			-- CA.TANFServices = TANF
			-- ON ca.HVCaseFK = b.HVCasePK AND ca.FormDate <= @EndDt AND ca.FormType IN ('FU', 'IN')
			left outer join CommonAttributes ca
						   on ca.CommonAttributesPK = (select top 1 CommonAttributesPK
														   from CommonAttributes
														   where HVCaseFK = b.HVCasePK
																and FormDate <= @EndDt
																and FormType in ('FU','IN')
														   order by FormDate desc)

			-- # of actual home visits since intake = a.HVCaseFK <-> HVLog.HVCaseFK, ProgramFK, 
			-- VisitType <> '0001', VisitStartTime < @EndDt and VisitStartTime >= b.IntakeDate

			left outer join TCID T on T.HVCaseFK = b.HVCasePK and T.TCDOD is null

		where b.IntakeDate < @EndDt
			 and (a.DischargeDate is null
			 or a.DischargeDate > @StartDt)
			 --AND a.ProgramFK = @programfk
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		--AND (@SiteFK = -1 OR (ISNULL(wp.SiteFK, -1) = @SiteFK))
		order by [key01]
GO
