SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 10/22/2010
-- Description:	Report - 1.1.F Timing of First Home Visit
-- moved from FamSys Feb 20, 2012 by jrobohn
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
--			2017-12-20 jr Cleaned up and streamlined whole procedure - functionally the same
-- =============================================
CREATE procedure [dbo].[rspFirstHomeVisit_Detail]
(
    @ProgramFK varchar(max)    = null,
    @StartDate    datetime,
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
						,case when TCDOB is not null then TCDOB else EDC end as TCDOB
					from HVLog hl
					left join HVCase hc on hc.HVCasePK = hl.HVCaseFK
					inner join CaseProgram cp on cp.HVCaseFK = hc.HVCasePK						  
					-- hvlog not limited to current programfk (for transfer cases)
					inner join dbo.SplitString(@ProgramFK, ',') ss on 1 = 1 --hvlog.programfk = listitem						  
					inner join WorkerProgram wp on WorkerFK = CurrentFSWFK AND wp.ProgramFK = ss.ListItem
					inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = HVCasePK
				where CaseProgress >= 9
						and IntakeDate between @StartDate and @EndDate
						and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
				group by HVCasePK
						,TCDOB
						,EDC
			)

			select IntakeDate
						,PC1ID
						,ProgramFK 
						,c.HVCasePK
						,rtrim(FirstName) as FirstName
						,rtrim(Lastname) as Lastname
						,c.VisitStartTime
						,c.TCDOB
						,datediff(day,c.TCDOB,c.VisitStartTime) as numdays
					  from CaseProgram
						  right join cteCohort c on CaseProgram.HVCaseFK = c.HVCasePK
						  inner join dbo.SplitString(@programfk,',') on CaseProgram.programfk = listitem -- needed again for transfer cases					  
						  left join HVCase on HVCase.HVCasePK = CaseProgram.HVCaseFK
						  left join Worker on Worker.WorkerPK = CaseProgram.CurrentFSWFK
			where datediff(day,c.TCDOB,c.VisitStartTime) > 92
			order by numdays desc
			
	end
GO
