SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<jrobohn>
-- Create date: <Feb. 17, 2016>
-- Description:	<report: Credentialing 7-5 B. ASQ>
-- Edit date: 
-- exec rspCredentialingPHQ9 1
-- =============================================
CREATE procedure [dbo].[rspCredentialingPHQ9] (@ProgramFK varchar(max) = null
									, @SupervisorFK int = null
									, @WorkerFK int = null
									, @UnderCutoffOnly char(1) = 'N'
									, @PC1ID varchar(13) = ''
									, @SiteFK int = null
									, @CaseFiltersPositive varchar(100) = ''
									 )
as
	if @ProgramFK is null
		begin
			select	@ProgramFK = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
											from	HVProgram
										   for
											xml	path('')
										   ), 2, 8000);
		end;
	set @ProgramFK = replace(@ProgramFK, '"', '');
	set @SiteFK = isnull(@SiteFK, 0);
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;

	declare	@n int = 0;
	select	@n = case when @UnderCutoffOnly = 'Y' then 1
					  else 0
				 end;
	
	with cteMain
		 as (select	cp.HVCaseFK
					, cp.PC1ID
					, supervisor.FirstName as SupervisorFirstName
					, supervisor.LastName as SupervisorLastName
					, fsw.FirstName as WorkerFirstName
					, fsw.LastName as WorkerLastname
					, cp.CaseStartDate
					, hc.KempeDate
					, hc.IntakeDate
					, hc.TCDOB
					, hc.EDC
					, case when hc.TCDOB > hc.IntakeDate then 'Pre-natal'
							else 'Post-natal'
						end as CaseTiming
			  from	CaseProgram cp
			  inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			  inner join dbo.SplitString(@ProgramFK, ',') on cp.ProgramFK = ListItem
			  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
			  inner join Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK
			  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK
											 and wp.ProgramFK = ListItem
			  inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			  where		cp.DischargeDate is null
						and datediff(month, hc.TCDOB, current_timestamp) >= 3 
					    --and datediff(month, hc.IntakeDate, hc.TCDOB) >= 3 
						and cp.CurrentFSWFK = isnull(@WorkerFK, cp.CurrentFSWFK)
						and wp.SupervisorFK = isnull(@SupervisorFK, wp.SupervisorFK)
						and cp.PC1ID = case	when @PC1ID = '' then cp.PC1ID
											else @PC1ID
										   end
							and (case when @SiteFK = 0 then 1
									  when wp.SiteFK = @SiteFK then 1
									  else 0
								 end = 1)
			)
	, ctePHQPrenatal
		as (select  m.PC1ID
						  , ltrim(rtrim(tc.TCFirstName)) + ' ' + ltrim(rtrim(tc.TCLastName)) as TCName
						  , convert(varchar(12), tc.TCDOB, 101) as TCDOB
						  , tc.GestationalAge
						  --,ltrim(rtrim(replace(ca.[AppCodeText],'(optional)',''))) TCAge
						  , convert(varchar(12), p.DateAdministered, 101) as DateAdministered
						  , p.ParticipantRefused
						  , p.DepressionReferralMade
						  , p.Positive
						  , case when p.Invalid = 1 then 'Invalid'
								 when p.Invalid = 0 then 'Valid'
								 else 'Unknown'
							end Validity
						  , CaseTiming
						  , p.FormInterval
						  , p.FormType
				  from	cteMain m
				  inner join PHQ9 p on p.HVCaseFK = m.HVCaseFK
				  -- inner join codeApp ca on a.TCAge = ca.AppCode and ca.AppCodeGroup = 'TCAge' and ca.AppCodeUsedWhere like '%AQ%'
				  inner join TCID tc on tc.HVCaseFK = p.HVCaseFK
				  -- inner join CaseProgram cp on cp.HVCaseFK = p.HVCaseFK
				  -- inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
				  -- inner join dbo.SplitString(@ProgramFK, ',') on cp.ProgramFK = ListItem
				  -- inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = p.HVCaseFK
				  -- inner join Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK
				  -- inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK
				  -- 								 and wp.ProgramFK = ListItem
				  -- inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
				  where	Invalid = 0
						and m.CaseTiming = 'Pre-natal'
			)
	, ctePHQPostnatal
		as (select  m.PC1ID
						  , ltrim(rtrim(tc.TCFirstName)) + ' ' + ltrim(rtrim(tc.TCLastName)) as TCName
						  , convert(varchar(12), tc.TCDOB, 101) as TCDOB
						  , tc.GestationalAge
						  --,ltrim(rtrim(replace(ca.[AppCodeText],'(optional)',''))) TCAge
						  , convert(varchar(12), p.DateAdministered, 101) as DateAdministered
						  , p.ParticipantRefused
						  , p.DepressionReferralMade
						  , p.Positive
						  , case when p.Invalid = 1 then 'Invalid'
								 when p.Invalid = 0 then 'Valid'
								 else 'Unknown'
							end Validity
						  , CaseTiming
						  , p.FormInterval
						  , p.FormType
				  from	cteMain m
				  inner join PHQ9 p on p.HVCaseFK = m.HVCaseFK
				  -- inner join codeApp ca on a.TCAge = ca.AppCode and ca.AppCodeGroup = 'TCAge' and ca.AppCodeUsedWhere like '%AQ%'
				  inner join TCID tc on tc.HVCaseFK = p.HVCaseFK
				  -- inner join CaseProgram cp on cp.HVCaseFK = p.HVCaseFK
				  -- inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
				  -- inner join dbo.SplitString(@ProgramFK, ',') on cp.ProgramFK = ListItem
				  -- inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = p.HVCaseFK
				  -- inner join Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK
				  -- inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK
				  -- 								 and wp.ProgramFK = ListItem
				  -- inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
				  where	Invalid = 0
						and m.CaseTiming = 'Post-natal'
			)	
	select ltrim(rtrim(WorkerFirstName)) + ' ' + ltrim(rtrim(WorkerLastName)) as Worker
			, ltrim(rtrim(SupervisorFirstName)) + ' ' + ltrim(rtrim(SupervisorLastName)) as Supervisor
			, m.PC1ID
			, m.CaseStartDate
			, m.KempeDate
			, m.IntakeDate
			, TCName
			, m.TCDOB
			, DateAdministered
			, ppre.FormType
			, ppre.FormInterval
			, Validity
			, m.CaseTiming			 
	from	cteMain m
	left outer join ctePHQPrenatal ppre on ppre.PC1ID = m.PC1ID
	order by WorkerLastName, WorkerFirstName, PC1ID
GO
