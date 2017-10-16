SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:	  <jrobohn>
-- Create date: <Feb. 17, 2016>
-- Description: <report: Credentialing 7-5 B. Administration of the Depression Screen (PHQ-2/9)>
-- Edit date: 
-- exec rspDepressionScreening_Details 1, '2014-07-01', null, null, null, null, ''
-- =============================================
CREATE procedure [dbo].[rspDepressionScreeningDetails] (@ProgramFK varchar(max) = null
									, @CutoffDate date = null
									, @SupervisorFK int = null
									, @WorkerFK int = null
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
set @PC1ID = isnull(@PC1ID, '');
set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
								else @CaseFiltersPositive
						   end;

if object_id('tempdb..#tmpDepressionScreeningDetailsCohort') is not null drop table #tmpDepressionScreeningDetailsCohort

select	cp.HVCaseFK
					  , cp.PC1ID
					  , cp.CaseStartDate
					  , supervisor.FirstName as SupervisorFirstName
					  , supervisor.LastName as SupervisorLastName
					  , fsw.FirstName as WorkerFirstName
					  , fsw.LastName as WorkerLastname
					  , ltrim(rtrim(tc.TCFirstName)) + ' ' + ltrim(rtrim(tc.TCLastName)) as TCName
					  , tc.GestationalAge
					  , hc.KempeDate
					  , hc.IntakeDate
					  , hc.TCDOB
					  , hc.EDC
					  , case when hc.TCDOB > hc.IntakeDate then 'Pre-natal'
							 else 'Post-natal'
						end as CaseTiming
			  into #tmpDepressionScreeningDetailsCohort
			  from		CaseProgram cp
			  inner join HVCase hc on hc.HVCasePK = cp.HVCaseFK
			  inner join dbo.SplitString(@ProgramFK, ',') on cp.ProgramFK = ListItem
			  inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @ProgramFK) cf on cf.HVCaseFK = cp.HVCaseFK
			  inner join Worker fsw on cp.CurrentFSWFK = fsw.WorkerPK
			  inner join WorkerProgram wp on wp.WorkerFK = fsw.WorkerPK
											 and wp.ProgramFK = ListItem
			  inner join Worker supervisor on wp.SupervisorFK = supervisor.WorkerPK
			  inner join TCID tc on tc.HVCaseFK = cp.HVCaseFK
			  where		cp.DischargeDate is null
						and hc.IntakeDate >= @CutoffDate
						--and cp.ProgramFK = @ProgramFK
						and datediff(month, hc.TCDOB, current_timestamp) >= 3 
					    and datediff(month, hc.TCDOB, hc.IntakeDate) <= 3 
						and cp.CurrentFSWFK = isnull(@WorkerFK, cp.CurrentFSWFK)
						and wp.SupervisorFK = isnull(@SupervisorFK, wp.SupervisorFK)
						and cp.PC1ID = case	when @PC1ID = '' then cp.PC1ID
											else @PC1ID
									   end
						and (case when @SiteFK = 0 then 1
								  when wp.SiteFK = @SiteFK then 1
								  else 0
							 end = 1);
-- select * from cteMain
		with ctePHQ
		  as (select distinct	
						tdsc.PC1ID
					  , convert(varchar(12), p.DateAdministered, 101) as DateAdministered
					  , p.ParticipantRefused
					  , p.DepressionReferralMade
					  , p.Positive
					  , CaseTiming
					  , p.FormInterval
					  , p.FormType
					  , case when p.Invalid = 1 then 'Invalid'
							 when p.Invalid = 0 then 'Valid'
							 else 'Unknown'
						end Validity
					  , case when tdsc.TCDOB > p.DateAdministered then 'Prenatal Screen'
							 else 'Postnatal Screen'
						end as VisitTiming
			  from		#tmpDepressionScreeningDetailsCohort tdsc
			  left outer join PHQ9 p on p.HVCaseFK = tdsc.HVCaseFK
			  where	p.Invalid = 0
					and p.DateAdministered <= dateadd(month, 3, TCDOB)
			 ) 

		--select * from ctePHQ

		, ctePHQFinal
		  as (select distinct
						tdsc.WorkerFirstName
					  , tdsc.WorkerLastname
					  , tdsc.SupervisorFirstName
					  , tdsc.SupervisorLastName
					  , tdsc.PC1ID
					  , tdsc.TCDOB
					  , tdsc.IntakeDate
					  , tdsc.CaseTiming as 'Status at Enrollment'
					  , case when pre.DateAdministered is not null
								  and pre.ParticipantRefused = 1 then 'Refused'
							 else pre.DateAdministered
						end as 'Date of Prenatal Screen'
					  , case when post.DateAdministered is not null
								  and post.ParticipantRefused = 1 then 'Refused'
							 else post.DateAdministered
						end as 'Date of Postnatal Screen'
					  , pre.FormType as [Prenatal FormType]
					  , post.FormType as [Postnatal FormType]
					  , pre.ParticipantRefused as ParticipantRefusedPrenatal
					  , post.ParticipantRefused as ParticipantRefusedPostnatal
			  from #tmpDepressionScreeningDetailsCohort tdsc
			  inner join ctePHQ p on tdsc.PC1ID = p.PC1ID
			  --left outer join ctePHQ pre on pre.PC1ID = p.PC1ID and pre.VisitTiming = 'Prenatal Screen'
			  --left outer join ctePHQ post on post.PC1ID = p.PC1ID and post.VisitTiming = 'Prenatal Screen'
			  outer apply (select top 1
									DateAdministered
								  , b.ParticipantRefused
								  , b.FormType
						   from		ctePHQ as b
						   where	p.PC1ID = b.PC1ID
									and b.VisitTiming = 'Prenatal Screen'
						   order by	b.DateAdministered
						  ) as pre
			  outer apply (select top 1
									DateAdministered
								  , c.ParticipantRefused
								  , c.FormType
						   from		ctePHQ as c
						   where	p.PC1ID = c.PC1ID
									and c.VisitTiming = 'Postnatal Screen'
						   order by	c.DateAdministered
						  ) as post
			 )
		
		--select * from ctePHQFinal

	select	ltrim(rtrim(WorkerLastName)) + ', ' + ltrim(rtrim(WorkerFirstName)) as WorkerName
          , ltrim(rtrim(SupervisorLastName)) + ', ' + ltrim(rtrim(SupervisorFirstName)) as SupervisorName
		  , PC1ID
		  , convert(date, TCDOB) as TCDOB
		  , convert(date, IntakeDate) as IntakeDate
		  , @CutoffDate as CutoffDate
		  , [Status at Enrollment]
		  , case when [Status at Enrollment] = 'Post-natal' then 'N/A'
				 when ParticipantRefusedPrenatal = 1 then 'Refused'
				 else [Date of Prenatal Screen]
			end as [Date of Prenatal Screen]
		  , [Prenatal FormType]
		  , case when ParticipantRefusedPostnatal = 1 then 'Refused'
					else [Date of Postnatal Screen]
			end as 'Date of Postnatal Screen'
		  , [Postnatal FormType]
		  , case when [Date of Postnatal Screen] is not null and [Date of Postnatal Screen] not in ('N/A', 'Refused')
					then datediff(month, TCDOB, [Date of Postnatal Screen])
					else -1
				end [Month Old for Postnatal Screen]
		  , case when [Date of Prenatal Screen] is not null and [Date of Prenatal Screen] not in ('N/A', 'Refused')
					then datediff(month, [Date of Prenatal Screen], TCDOB)
					else -1
				end [Month Old for Prenatal Screen]
		  , case when [Status at Enrollment] = 'Pre-natal' and (ParticipantRefusedPrenatal = 1 
																or ([Date of Prenatal Screen] is not null 
																	and [Date of Postnatal Screen] is not null))
					then 'Y'
				when [Status at Enrollment] = 'Post-natal' and (ParticipantRefusedPostnatal = 1 
																or [Date of Postnatal Screen] is not null)
					then 'Y'
				else 'N'
			end as MeetsStandard
	from	ctePHQFinal
	order by WorkerName
		  , PC1ID

GO
