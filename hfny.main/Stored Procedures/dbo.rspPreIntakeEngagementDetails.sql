
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- Stored Procedure

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <Jyly 16th, 2012>
-- Description:	<gets you data for Pre-Intake Engagement in Detail>
-- exec [rspPreIntakeEngagementDetails] ',1,','09/01/2010','11/30/2010',null,0
-- exec [rspPreIntakeEngagementDetails] ',1,','09/01/2010','11/30/2010',null,1
-- exec [rspPreIntakeEngagementDetails] '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39','07/01/2014','09/30/2014',null,1
-- exec [rspPreIntakeEngagement] '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39','07/01/2014','09/30/2014',null,1

-- =============================================
CREATE procedure [dbo].[rspPreIntakeEngagementDetails] (@programfk varchar(max) = null
													 , @sdate datetime
													 , @edate datetime
													 , @sitefk int = null
													 , @CustomQuarterlyDates bit                                                         
													  )
as
	begin

		-- if user picks up custom dates ( not specific quarter dates) then Don't show ContractPeriod Column
		--DECLARE @bDontShowContractPeriod BIT
		-- we will be receiving the value of @bDontShowContractPeriod from UI. 
		-- so time being, let us do the following
		--SET @bDontShowContractPeriod = 0

		declare	@ContractStartDate date
		declare	@ContractEndDate date

		if ((@ProgramFK is not null)
			and (@CustomQuarterlyDates = 0)
		   )
			begin 
				set @ProgramFK = replace(@ProgramFK, ',', '') -- remove comma's
				set @ContractStartDate = (select	ContractStartDate
										  from		HVProgram P
										  where		HVProgramPK = @ProgramFK
										 )
				set @ContractEndDate = (select	ContractEndDate
										from	HVProgram P
										where	HVProgramPK = @ProgramFK
									   )
			end 

		--SELECT @ContractStartDate, @ContractEndDate

		-- Let us declare few table variables so that we can manipulate the rows at our will
		-- Note: Table variables are a superior alternative to using temporary tables 

		---------------------------------------------
		-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
		-- table variable for holding Init Required Data
		declare	@tblInitRequiredData table ([HVCasePK] [int]
										  , [IntakeDate] [datetime]
										  , [DischargeDate] [datetime]
										  , [KempeDate] [datetime]
										  , [KempeResult] [bit]
										  , [CaseStartDate] [datetime]
										  , [SiteFK] [int]
										  , [PC1ID] [char](13)
										  , [OldID] [char](23)
										  , [FSWWorkerName] [char](100)
										   )


		declare	@tblInitRequiredDataTemp table ([HVCasePK] [int]
											  , [IntakeDate] [datetime]
											  , [DischargeDate] [datetime]
											  , [KempeDate] [datetime]
											  , [KempeResult] [bit]
											  , [CaseStartDate] [datetime]
											  , [SiteFK] [int]
											  , [PC1ID] [char](13)
											  , [OldID] [char](23)
											  , [FSWWorkerName] [char](100)
											   )

		-- Fill this table i.e. @tblInitRequiredData as below
		insert	into @tblInitRequiredDataTemp
				([HVCasePK]
			   , [IntakeDate]
			   , [DischargeDate]
			   , [KempeDate]
			   , [KempeResult]
			   , [CaseStartDate]
			   , [SiteFK]
			   , [PC1ID]
			   , [OldID]
			   , [FSWWorkerName]	
				)
				select	h.HVCasePK
					  , h.IntakeDate
					  , cp.DischargeDate
					  , k.KempeDate
					  , k.KempeResult
					  , cp.CaseStartDate
					  , case when wp.SiteFK is null then 0
							 else wp.SiteFK
						end as SiteFK
					  , cp.PC1ID
					  , cp.OldID
					  , ltrim(rtrim(w.FirstName)) + ' ' + ltrim(rtrim(w.LastName)) as FSWWorkerName
				from	HVCase h
				inner join Kempe k on k.HVCaseFK = h.HVCasePK
				inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
				inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
				inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK -- get SiteFK
				inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem

		-- SiteFK = isnull(@sitefk,SiteFK) does not work because column SiteFK may be null itself 
		-- so to solve this problem we make use of @tblInitRequiredDataTemp
		insert	into @tblInitRequiredData
				([HVCasePK]
			   , [IntakeDate]
			   , [DischargeDate]
			   , [KempeDate]
			   , [KempeResult]
			   , [CaseStartDate]
			   , [PC1ID]
			   , [OldID]
			   , [FSWWorkerName]		
				)
				select	[HVCasePK]
					  , [IntakeDate]
					  , [DischargeDate]
					  , [KempeDate]
					  , [KempeResult]
					  , [CaseStartDate]
					  , [PC1ID]
					  , [OldID]
					  , [FSWWorkerName]
				from	@tblInitRequiredDataTemp
				where	SiteFK = isnull(@sitefk, SiteFK)

		-- exec [rspPreIntakeEngagementDetails] ',1,','09/01/2010','11/30/2010',null,0

		declare	@tblEngageAll table ([HVCasePK] [int]
								   , [IntakeDate] [datetime]
								   , [DischargeDate] [datetime]
								   , [KempeDate] [datetime]
								   , [KempeResult] [bit]
								   , [CaseStartDate] [datetime]
								   , [FSWAssignDate] [datetime]
								   , [PC1ID] [char](13)
								   , [OldID] [char](23)
								   , [FSWWorkerName] [char](100)
								   , [CaseStatus] [char](2)
									)

		insert	into @tblEngageAll
				([HVCasePK]
			   , [IntakeDate]
			   , [DischargeDate]
			   , [KempeDate]
			   , [KempeResult]
			   , [CaseStartDate]
			   , [FSWAssignDate]
			   , [PC1ID]
			   , [OldID]
			   , [FSWWorkerName]
			   , [CaseStatus]
				)
				(--Pre-Intakes
				select	irq.[HVCasePK]
					  , irq.[IntakeDate]
					  , irq.[DischargeDate]
					  , irq.[KempeDate]
					  , irq.[KempeResult]
					  , irq.[CaseStartDate]
					  , p.[FSWAssignDate]
					  , irq.[PC1ID]
					  , irq.[OldID]
					  , irq.[FSWWorkerName]
					  , p.[CaseStatus]
				 from	@tblInitRequiredData irq
				 inner join Preassessment p on irq.HVCasePK = p.HVCaseFK
				 where	CaseStartDate <= @edate
						and p.FSWAssignDate < @sDate
						and p.CaseStatus = '02'
						and irq.KempeResult = '1'
						and (IntakeDate is null
							 or IntakeDate > @sDate
							)
						and (DischargeDate is null
							 or DischargeDate > @sDate
							)
				 union all

				-- kempes
				select	irq.[HVCasePK]
					  , irq.[IntakeDate]
					  , irq.[DischargeDate]
					  , irq.[KempeDate]
					  , irq.[KempeResult]
					  , irq.[CaseStartDate]
					  , p.[FSWAssignDate]
					  , irq.[PC1ID]
					  , irq.[OldID]
					  , irq.[FSWWorkerName]
					  , p.[CaseStatus]
				 from	@tblInitRequiredData irq
				 inner join Preassessment p on irq.HVCasePK = p.HVCaseFK
				 left join Kempe k on k.HVCaseFK = irq.HVCasePK
				 where	irq.KempeDate between @sDate and @edate
						and p.CaseStatus = '02'
						and k.KempeResult = 1
						and p.FSWAssignDate between @sDate and @edate
				 union all

				--Previous Kempes
				select	irq.[HVCasePK]
					  , irq.[IntakeDate]
					  , irq.[DischargeDate]
					  , irq.[KempeDate]
					  , irq.[KempeResult]
					  , irq.[CaseStartDate]
					  , p.[FSWAssignDate]
					  , irq.[PC1ID]
					  , irq.[OldID]
					  , irq.[FSWWorkerName]
					  , p.[CaseStatus]
				 from	@tblInitRequiredData irq
				 inner join Preassessment p on irq.HVCasePK = p.HVCaseFK
				 where	(irq.KempeDate < @sDate
						 and irq.KempeDate is not null
						)
						and (p.FSWAssignDate is not null
							 and p.FSWAssignDate >= @sDate
							)
				)


		--#01: Get the cases where PIDate BETWEEN @sDate AND @edate
		declare	@tblLastPa1 table ([HVCasePK] [int]
								 , [PIDate] [datetime]
								  )

		insert	into @tblLastPa1
				([HVCasePK]
			   , [PIDate]
				)
				(select	p.HVCaseFK
					  , max(p.PIDate)
				 from	@tblEngageAll e
				 left join Preintake p on e.HVCasePK = p.HVCaseFK
				 where	PIDate between @sDate and @edate
				 group by p.HVCaseFK
				)


		--#02: Get the ODD cases WHERE la.PIDate IS NULL AND e1.HVCasePK = pre.HVCaseFK AND pre.PIDate > @edate
		declare	@tblLastPa2 table ([HVCasePK] [int]
								 , [PIDate] [datetime]
								  )

		insert	into @tblLastPa2
				([HVCasePK]
			   , [PIDate]
				)
				(select	pre.HVCaseFK
					  , max(pre.PIDate)
				 from	@tblLastPa1 la
				 right join @tblEngageAll e1 on e1.HVCasePK = la.HVCasePK
				 left join Preintake pre on e1.HVCasePK = pre.HVCaseFK
				 where	la.PIDate is null
						and e1.HVCasePK = pre.HVCaseFK
						and pre.PIDate > @edate
				 group by pre.HVCaseFK
				)

		--#03: Get the cases where la.PIDate is not null and e1.HVCasePK = pre.HVCaseFK and there are no preintakes prior to end of period
		declare	@tblLastPa3 table ([HVCasePK] [int]
								 , [PIDate] [datetime]
								  )

		insert	into @tblLastPa3
				([HVCasePK]
			   , [PIDate]
				)
				(select	pre.HVCaseFK
					  , min(pre.PIDate)
				 from	@tblLastPa1 la
				 right join @tblEngageAll e1 on e1.HVCasePK = la.HVCasePK
				 left join Preintake pre on e1.HVCasePK = pre.HVCaseFK
				 where	la.PIDate > @edate
						and e1.HVCasePK = pre.HVCaseFK
						and pre.PIDate > @edate
				 group by pre.HVCaseFK
				 having min(pre.PIDate) > @edate
				)

select * from @tblLastPa3 tlp

end
	
--		-- Combine all of the above 
--		select	ea.[PC1ID]
--			  , ea.[FSWAssignDate]
--			  , case when pre.[CaseStatus] in ('02', '03') then datediff(day, ea.[FSWAssignDate], lp.PIDate)
--					 else datediff(day, ea.[FSWAssignDate], @edate)
--				end PreIntakeDays
--			  , ea.[FSWWorkerName]
--			  , lp.PIDate
--			  , Status = case pre.[CaseStatus]
--						   when '01' then 'Engagement Continues'
--						   when '02' then 'Enrolled'
--						   when '03' then 'Terminated'
--						   else ''
--						 end
--		from	@tblEngageAll ea
--		inner join @tblLastPa1 lp on lp.HVCasePK = ea.HVCasePK
--		left join Preintake pre on ea.HVCasePK = pre.HVCaseFK
--		where	lp.PIDate = pre.PIDate
--		union all
--		select	ea.[PC1ID]
--			  , ea.[FSWAssignDate]
--			  , datediff(day, ea.[FSWAssignDate], @edate) PreIntakeDays
--			  , ea.[FSWWorkerName]
--			  , null as PIDate
--			  , 'No Status' Status
--		from	@tblEngageAll ea
--		inner join @tblLastPa2 lp on lp.HVCasePK = ea.HVCasePK
--		left join Preintake pre on ea.HVCasePK = pre.HVCaseFK
--		where	lp.PIDate = pre.PIDate
--		order by [FSWWorkerName]


--	end


--select KempePK
--	  , k.HVCaseFK
--	  , KempeResult
--	  , PIDate
--	from Kempe k
--	left outer join 
--			(select HVCaseFK, max(PIDate) as PIDate
--				from Preintake 
--				where ProgramFK = '37' and PIDate <= '20140630'
--				group by HVCaseFK)
--			p on p.HVCaseFK = k.HVCaseFK
--	where k.ProgramFK = 37
--	and KempeDate between '20140401' and '20140630'
	
--select PreintakePK
--	  , CaseStatus
--	  , HVCaseFK
--	  , KempeFK
--	  , PIDate
--	  , ProgramFK
--from Preintake p
--where HVCaseFK in (224053, 223753, 223751, 224292)
GO
