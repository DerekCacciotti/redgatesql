SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 10/19/2010
-- Description:	Report - 1.1.F Timing of First Home Visit
--				Moved from FamSys - 02/05/12 jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
--			2017-12-20 jr Cleaned up and streamlined whole procedure - functionally the same
-- =============================================
CREATE procedure [dbo].[rspFirstHomeVisit]
(
    @ProgramFK varchar(max)    = null,
    @StartDate datetime,
    @EndDate   datetime, 
    @SiteFK	   int,
    @posclause varchar(200),
    @negclause varchar(200)
)
as
	begin
		if @ProgramFK is null
		begin
			select @ProgramFK = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
											   from HVProgram
											   for xml path ('')),2,8000)
		end

		set @ProgramFK = replace(@ProgramFK, '"', '')
		set @SiteFK = isnull(@SiteFK, 0)
	
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			set nocount on;

			with cteCohort as 
			(
				select min(VisitStartTime) as VisitStartTime
							,HVCasePK
							,case when tcdob is not null then tcdob else edc end as TCDOB
					from HVLog hl
					left join HVCase on HVCase.HVCasePK = hl.hvcasefk
					inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK						  
					-- hvlog not limited to current programfk (for transfer cases)
					inner join dbo.SplitString(@ProgramFK, ',') ss on 1 = 1 --hvlog.programfk = listitem						  
					inner join WorkerProgram wp on WorkerFK = CurrentFSWFK AND wp.ProgramFK = ss.ListItem
				where CaseProgress >= 9
						and IntakeDate between @StartDate and @EndDate
						and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
				group by HVCasePK
						,TCDOB
						,EDC
			)

			select distinct sum(count(c.HVCasePK)) over () as Total
						   ,sum(count(case
										  when c.TCDOB > cast(c.VisitStartTime AS DATE) then
											  'Prenatal'
									  end)) over () as Prenatal
						   ,sum(count(case
										  when datediff(day, c.TCDOB, cast(c.VisitStartTime AS DATE)) between 0 and 92 then
											  'Prenatal'
									  end)) over () as Within3Months
						   ,sum(count(case
										  when datediff(day, c.TCDOB, cast(c.VisitStartTime AS DATE)) > 92 then
											  'Prenatal'
									  end)) over () as After3Months
						   ,sum(count(case
										  when datediff(day, c.TCDOB, cast(c.VisitStartTime AS DATE)) <= 92 then
											  'Prenatal'
									  end)) over () as Prenatal_or_Within3
				from cteCohort c
					inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = c.HVCasePK
				group by c.HVCasePK
						,c.VisitStartTime
						,c.TCDOB
	end
GO
