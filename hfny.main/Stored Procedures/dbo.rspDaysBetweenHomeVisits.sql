SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 2016-06-14
-- Description:	List cases and length of time between home visits
--exec rspDaysBetweenHomeVisits 20
--exec rspDaysBetweenHomeVisits 1
-- =============================================
CREATE procedure [dbo].[rspDaysBetweenHomeVisits]
	(
		@programfk as int		
	)

as
	begin

		if object_id('tempdb..#cteMAIN') is not null
			drop table #cteMAIN;

		create table #cteMAIN
			(
				CurrentLevelFK int ,
				LevelName varchar(50) ,
				PC1ID char(13) ,
				HVCaseFK int
			);

		insert into #cteMAIN
					select	   CurrentLevelFK ,
							   cl.LevelName ,
							   PC1ID ,
							   HVCaseFK
					from	   CaseProgram cp
					inner join HVCase hc on cp.HVCaseFK = hc.HVCasePK
					inner join codeLevel cl on cp.CurrentLevelFK = codeLevelPK
					where	   cp.ProgramFK = @programfk
							   and CaseProgress >= 9
							   and CaseStartDate <= getdate()
							   and DischargeDate is null

		--get the most recent HV Visit from cohort above
		create table #cteLastVisit
			(
				HVCaseFK int, 
				HVDate2 datetime
			)
		
		insert into #cteLastVisit (HVCaseFK, HVDate2)
			select	   distinct m.HVCaseFK ,
							   max(VisitStartTime) over ( partition by m.HVCaseFK ) as HVDATE2
					from	   HVLog hl
					inner join #cteMAIN m on hl.HVCaseFK = m.HVCaseFK
					where	   left(VisitType, 1) = '1' or
								substring(VisitType, 2, 1) = '1' or
								substring(VisitType, 3, 1) = '1' 
		;
		with
		cteLastVisitPlusHVLOGPK
			as
				(
					select	   distinct lv.HVCaseFK ,
							   row_number() over ( partition by lv.HVCaseFK
												   order by hl.HVLogCreateDate desc ) as RowNum ,
							   HVDATE2 ,
							   HVLogPK
					from	   HVLog hl
					inner join #cteLastVisit lv on hl.HVCaseFK = lv.HVCaseFK
											   and hl.VisitStartTime = lv.HVDATE2
					--where	   left(VisitType, 1) = '1' or
					--			substring(VisitType, 2, 1) = '1' or
					--			substring(VisitType, 3, 1) = '1' 
				) ,
		cteSecondToLastVisit
			as
				(
					select	   max(VisitStartTime) as HVDATE1 ,
							   hl.HVCaseFK
					from	   HVLog hl
					inner join cteLastVisitPlusHVLOGPK lvp on lvp.HVLogPK <> hl.HVLogPK
															  and lvp.HVCaseFK = hl.HVCaseFK
					where	   left(VisitType, 1) = '1' or
								substring(VisitType, 2, 1) = '1' or
								substring(VisitType, 3, 1) = '1' 
					group by   hl.HVCaseFK
				) ,
		cteDatesBetween
			as
				(
					select	   stlv.HVCaseFK ,
							   m.PC1ID ,
							   m.LevelName ,
							   m.CurrentLevelFK ,
							   HVDATE1 ,
							   HVDATE2 ,
							   datediff(dd, HVDATE1, HVDATE2) as DaysBetweenHomeVisits
					from	   cteSecondToLastVisit stlv
					inner join cteLastVisitPlusHVLOGPK lvp on lvp.HVCaseFK = stlv.HVCaseFK
					inner join #cteMAIN m on m.HVCaseFK = stlv.HVCaseFK
					where	   lvp.RowNum = 1
				) ,
		cteAverageDays
			as
				(
					select sum(DaysBetweenHomeVisits)
						   / count(DaysBetweenHomeVisits) as AverageDays
					from   cteDatesBetween
				) ,
		ctePutTheTwoTogether
			as
				(
					select PC1ID as 'Case #' ,
						   LevelName as 'Level' ,
						   CurrentLevelFK , 
						   convert(date, HVDATE2, 101) as 'Most Recent Home Visit' ,
						   convert(date, HVDATE1, 101) as 'Previous Home Visit' ,
						   DaysBetweenHomeVisits as 'Days Between Visits' ,
						   AverageDays as 'Avg Days Calculated'
					from   cteDatesBetween ,
						   cteAverageDays
				) ,
		cteLevelCodes
			as
				(
					select codeLevelPK ,
						   LevelName ,
						   MinimumVisit ,
						   case when MinimumVisit = 0 then null
								else ( 1 / MinimumVisit ) * 7
						   end as 'MinDays'
					from   dbo.codeLevel cl
					where  codeLevelPK >= 9
						   and MinimumVisit is not null
				)
		select	   [Case #] ,
				   substring([Level], 7, len([Level]) - 5) as 'Level' , --remove word "Level" from value
				   [Most Recent Home Visit] ,
				   [Previous Home Visit] ,
				   [Days Between Visits] ,
				   [MinDays] ,
				   [Days Between Visits] - [MinDays] as 'Difference' ,
				   [Avg Days Calculated] ,
				   rtrim(FirstName) + ' ' + rtrim(LastName) as 'Worker Name'
		from	   ctePutTheTwoTogether pttt
		inner join CaseProgram on pttt.[Case #] = CaseProgram.PC1ID
		inner join Worker on WorkerPK = CaseProgram.CurrentFSWFK
		inner join HVCase on HVCase.HVCasePK = CaseProgram.HVCaseFK
		inner join cteLevelCodes lc on pttt.CurrentLevelFK = lc.codeLevelPK
		order by   lc.codeLevelPK ,
				   Difference desc;

		drop table #cteMAIN;
	end;

GO
