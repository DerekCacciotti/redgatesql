SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Feb 5, 2012>
-- Description:	<report: Use of Creative Outreach - Detail>
--				Moved from FamSys - 02/05/12 jrobohn
-- =============================================
create procedure [dbo].[rspCreativeOutreach_Detail]
(@programfk varchar(max)    = null,
 @sdate     datetime        = null,
 @edate     datetime        = null
)

as

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+ltrim(rtrim(str(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')


	declare @ClosedOnXLess3NoMove int

	select
		  @ClosedOnXLess3NoMove = count(distinct case
													 when
														 datediff(day,e4.LevelAssignDate,dischargedate) < 92
														 and CurrentLevelFK = 23 -- level X-term
														 and (dischargedate is not null or dischargedate < @edate)
														 and DischargeCode not in (7,11)
														 then
														 PC1ID
												 end)
		from hvcase
			inner join caseprogram
					  on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',')
					  on caseprogram.programfk = listitem
			--left join (select hvlevel.hvlevelpk, hvlevel.hvcasefk, hvlevel.programfk, 
			--hvlevel.levelassigndate, levelname, caseweight, LevelFK
			--	from hvlevel
			--	inner join codelevel
			--	on codelevelpk = levelfk
			--) e3
			--on e3.hvcasefk = caseprogram.hvcasefk
			--and e3.programfk = caseprogram.programfk
			left join (select hvlevel.hvlevelpk
							 ,hvlevel.hvcasefk
							 ,hvlevel.programfk
							 ,hvlevel.levelassigndate
							 ,levelname
							 ,caseweight
						   from hvlevel
							   inner join codelevel
										 on codelevelpk = levelfk
						   where LevelFK = 22
					  ) e4
					 on e4.hvcasefk = caseprogram.hvcasefk
					 and e4.programfk = caseprogram.programfk
			left join codeDischarge
					 on DischargeCode = caseprogram.DischargeReason
		where caseprogress >= 9
			 and intakedate <= @edate
			 and CaseProgram.DischargeDate > @sdate

	-- Length of Service on Level X at DC
	select
		  PC1ID
		 ,'Closed on '+convert(varchar(12),dischargedate,101) as CurrentStatus
		 ,codeDischarge.dischargereason as ReasonClosed
		 ,datediff(day,e3.levelassigndate,dischargedate) as DaysOnLevelX
		 ,rtrim(Worker.FirstName)+' '+rtrim(Worker.LastName) as current_worker
		 ,@ClosedOnXLess3NoMove as ClosedOnXLess3NoMove
		from hvcase
			inner join caseprogram
					  on caseprogram.hvcasefk = hvcasepk
			inner join dbo.SplitString(@programfk,',')
					  on caseprogram.programfk = listitem
			inner join (select hvlevel.hvlevelpk
							  ,hvlevel.hvcasefk
							  ,hvlevel.programfk
							  ,hvlevel.levelassigndate
							  ,levelname
							  ,caseweight
							from hvlevel
								inner join codelevel
										  on codelevelpk = levelfk
							where LevelFK = 22
					   ) e3
					  on e3.hvcasefk = caseprogram.hvcasefk
					  and e3.programfk = caseprogram.programfk
			inner join codeDischarge
					  on DischargeCode = caseprogram.DischargeReason
			inner join Worker
					  on Worker.WorkerPK = CaseProgram.CurrentFSWFK
		where caseprogress >= 9
			 and intakedate <= @edate
			 and datediff(day,e3.LevelAssignDate,dischargedate) < 92
			 and CurrentLevelFK = 23 -- level X-term
			 and (dischargedate is not null
			 or dischargedate < @edate)
			 and DischargeCode not in (7,11)
			 and CaseProgram.DischargeDate > @sdate
		order by PC1ID



GO
