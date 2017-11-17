SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
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
							   codeLevel.LevelName ,
							   PC1ID ,
							   HVCaseFK
					from	   dbo.CaseProgram
					inner join dbo.HVCase on dbo.CaseProgram.HVCaseFK = dbo.HVCase.HVCasePK
					inner join dbo.codeLevel on CaseProgram.CurrentLevelFK = codeLevelPK
					where	   CaseProgram.ProgramFK = @programfk
							   and CaseProgress >= 9
							   and CaseStartDate <= getdate()
							   and DischargeDate is null

		--get the most recent HV Visit from cohort above
		;
		with
		cteLastVisit
			as
				(
					select	   distinct #cteMAIN.HVCaseFK ,
							   max(VisitStartTime) over ( partition by #cteMAIN.HVCaseFK ) as HVDATE2
					from	   dbo.HVLog
					inner join #cteMAIN on dbo.HVLog.HVCaseFK = #cteMAIN.HVCaseFK
					where	   left(VisitType, 1) = '1'
				) ,
		--now get the most recent HVLOGPK from the list above
		cteLastVisitPlusHVLOGPK
			as
				(
					select	   distinct cteLastVisit.HVCaseFK ,
							   row_number() over ( partition by cteLastVisit.HVCaseFK
												   order by HVLog.HVLogCreateDate desc ) as RowNum ,
							   HVDATE2 ,
							   HVLogPK
					from	   dbo.HVLog
					inner join cteLastVisit on dbo.HVLog.HVCaseFK = cteLastVisit.HVCaseFK
											   and HVLog.VisitStartTime = cteLastVisit.HVDATE2
					where	   left(VisitType, 1) = '1'
				) ,
		cteSecondToLastVisit
			as
				(
					select	   max(VisitStartTime) as HVDATE1 ,
							   HVLog.HVCaseFK
					from	   dbo.HVLog
					inner join cteLastVisitPlusHVLOGPK CLV on CLV.HVLogPK <> HVLog.HVLogPK
															  and CLV.HVCaseFK = HVLog.HVCaseFK
					where	   left(VisitType, 1) = '1'
					group by   HVLog.HVCaseFK
				) ,
		cteDatesBetween
			as
				(
					select	   cteSecondToLastVisit.HVCaseFK ,
							   #cteMAIN.PC1ID ,
							   #cteMAIN.LevelName ,
							   HVDATE1 ,
							   HVDATE2 ,
							   datediff(dd, HVDATE1, HVDATE2) as DaysBetweenHomeVisits
					from	   cteSecondToLastVisit
					inner join cteLastVisitPlusHVLOGPK CLV on CLV.HVCaseFK = cteSecondToLastVisit.HVCaseFK
					inner join #cteMAIN on #cteMAIN.HVCaseFK = cteSecondToLastVisit.HVCaseFK
					where	   CLV.RowNum = 1
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
					from   dbo.codeLevel
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
		from	   ctePutTheTwoTogether
		inner join CaseProgram on ctePutTheTwoTogether.[Case #] = CaseProgram.PC1ID
		inner join Worker on WorkerPK = CaseProgram.CurrentFSWFK
		inner join HVCase on HVCase.HVCasePK = CaseProgram.HVCaseFK
		inner join cteLevelCodes on ctePutTheTwoTogether.Level = cteLevelCodes.LevelName
		order by   cteLevelCodes.codeLevelPK ,
				   Difference desc;

		drop table #cteMAIN;
	end;

GO
