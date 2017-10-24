SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <04/15/2013>
-- Description:	<This Credentialing report gets you 'Details for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Details 2, '01/01/2011', '12/31/2011'
-- rspCredentialingKempeAnalysis_Details 4, '04/01/2012', '03/31/2013'

-- =============================================
CREATE procedure [dbo].[rspCredentialingKempeAnalysis_Details]
	(
		@programfk varchar(max) = null ,
		@StartDate datetime ,
		@EndDate datetime ,
		@SiteFK int = null
	)
with recompile
as
	if @programfk is null
		begin
			select @programfk = substring(
								(	select ','
										   + ltrim(rtrim(str(HVProgramPK)))
									from   HVProgram
									for xml path('')) ,
								2 ,
								8000);
		end;

	set @programfk = replace(@programfk, '"', '')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end;

	with
	ctePIVisits
		as
			(
				select	 KempeFK ,
						 sum(case when PIVisitMade > 0 then 1
								  else 0
							 end) PIVisitMade
				from	 Preintake pi
						 inner join dbo.SplitString(@programfk, ',') on pi.ProgramFK = ListItem
				group by KempeFK
			) ,
	cteCohort
		as
			(
				select cp.ProgramFK ,
					   HVCasePK ,
					   case when h.TCDOB is not null then h.TCDOB
							else h.EDC
					   end as tcdob ,
					   DischargeDate ,
					   IntakeDate ,
					   k.KempeDate ,
					   PC1FK ,
					   cp.DischargeReason ,
					   isnull(cp.DischargeReasonSpecify, '') DischargeReasonSpecify ,
					   OldID ,
					   PC1ID ,
					   KempeResult ,
					   cp.CurrentFSWFK ,
					   cp.CurrentFAWFK ,
					   case when h.TCDOB is not null then h.TCDOB
							else h.EDC
					   end as babydate ,
					   case when h.IntakeDate is not null then h.IntakeDate
							else cp.DischargeDate
					   end as testdate ,
					   P.PCDOB ,
					   P.Race ,
					   ca.MaritalStatus ,
					   ca.HighestGrade ,
					   ca.IsCurrentlyEmployed ,
					   ca.OBPInHome ,
					   case when MomScore = 'U' then 0
							else cast(MomScore as int)
					   end as MomScore ,
					   case when DadScore = 'U' then 0
							else cast(DadScore as int)
					   end as DadScore ,
					   FOBPresent ,
					   MOBPresent ,
					   MOBPartnerPresent ,
					   OtherPresent ,
					   MOBPartnerPresent as MOBPartner ,
					   FOBPartnerPresent as FOBPartner ,
					   GrandParentPresent as MOBGrandmother ,
					   PIVisitMade
				from   HVCase h
					   inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
					   inner join dbo.SplitString(@programfk, ',') on cp.ProgramFK = ListItem
					   inner join Kempe k on k.HVCaseFK = h.HVCasePK
					   inner join PC P on P.PCPK = h.PC1FK
					   left outer join ctePIVisits piv on piv.KempeFK = k.KempePK
					   left join CommonAttributes ca on ca.HVCaseFK = h.HVCasePK
														and ca.FormType = 'KE'
				where  (   h.IntakeDate is not null
						   or cp.DischargeDate is not null ) -- only include kempes that are positive and where there is a clos_date or an intake date.
					   and k.KempeResult = 1
					   and k.KempeDate
					   between @StartDate and @EndDate
			)
	select	 ( case when IntakeDate is not null then ''					--'AcceptedFirstVisitEnrolled' 
					when KempeResult = 1
						 and IntakeDate is null
						 and DischargeDate is not null
						 and (	 PIVisitMade > 0
								 and PIVisitMade is not null ) then '*' -- 'AcceptedFirstVisitNotEnrolled'
					else ''												-- 'Refused' 
			   end ) + PC1ID as PC1ID ,
			 ltrim(rtrim(faw.FirstName)) + ' ' + ltrim(rtrim(faw.LastName)) as FAW ,
			 convert(varchar(10), KempeDate, 101) as KempeDate ,
			 ltrim(rtrim(fsw.FirstName)) + ' ' + ltrim(rtrim(fsw.LastName)) as FSW ,
			 convert(varchar(10), h.DischargeDate, 101) as DischargeDate ,
			 --,cd.ReportDischargeText
			 case when h.DischargeReason = '99' then h.DischargeReasonSpecify
				  else cd.ReportDischargeText
			 end ReportDischargeText ,
			 case when h.DischargeReason = '36' then 1
				  when h.DischargeReason = '12' then 2
				  when h.DischargeReason = '19' then 3
				  when h.DischargeReason = '07' then 4
				  when h.DischargeReason = '25' then 5
				  else 6
			 end as DischargeSortCode ,
			 ( case when IntakeDate is not null then '1'				--'AcceptedFirstVisitEnrolled' 
					when KempeResult = 1
						 and IntakeDate is null
						 and DischargeDate is not null
						 and (	 PIVisitMade > 0
								 and PIVisitMade is not null ) then '2' -- 'AcceptedFirstVisitNotEnrolled'
					else '3'											-- 'Refused' 
			   end ) mainsortkey
	from	 cteCohort h
			 left join Worker faw on CurrentFAWFK = faw.WorkerPK -- faw
			 left join WorkerProgram wpfaw on wpfaw.WorkerFK = faw.WorkerPK and wpfaw.ProgramFK = h.ProgramFK
			 left join Worker fsw on CurrentFSWFK = fsw.WorkerPK -- fsw	 
			 left join WorkerProgram wpfsw on wpfsw.WorkerFK = fsw.WorkerPK and wpfsw.ProgramFK = h.ProgramFK
			 left join codeDischarge cd on h.DischargeReason = cd.DischargeCode
	where --DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
			 ( case when IntakeDate is not null then '1'				--'AcceptedFirstVisitEnrolled' 
					when KempeResult = 1
						 and IntakeDate is null
						 and DischargeDate is not null
						 and (	 PIVisitMade > 0
								 and PIVisitMade is not null ) then '2' -- 'AcceptedFirstVisitNotEnrolled'
					else '3'											-- 'Refused' 
			   end ) in ( '2', '3' )
			 and (case when @SiteFK = 0 then 1 when wpfaw.SiteFK = @SiteFK then 1 else 0 end = 1)
			 and (case when @SiteFK = 0 then 1 when wpfsw.SiteFK = @SiteFK then 1 else 0 end = 1)

	order by mainsortkey ,
			 DischargeSortCode ,
			 PC1ID; -- ReportDischargeText, PC1ID

-- rspCredentialingKempeAnalysis_Details 2, '01/01/2011', '12/31/2011'



GO
