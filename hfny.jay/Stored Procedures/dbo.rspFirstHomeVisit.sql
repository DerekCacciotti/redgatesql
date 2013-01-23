
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 10/19/2010
-- Description:	Report - 1.1.F Timing of First Home Visit
--				Moved from FamSys - 02/05/12 jrobohn
-- =============================================
CREATE procedure [dbo].[rspFirstHomeVisit]
(
    @programfk varchar(max)    = null,
    @Case      varchar(50)     = null,--figure the Case Filters out later
    @STDate    datetime,
    @EndDate   datetime, 
    @SiteFK	   int,
    @posclause varchar(200),
    @negclause varchar(200)
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')
	set @SiteFK = isnull(@SiteFK, 0)
	
	begin
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set nocount on;

		select distinct sum(count(hvcasepk)) over () as Total
					   ,sum(count(case
									  when datediff(day,case tcdob
															when tcdob then
																tcdob
															else
																edc
														end,VisitStartTime) < 0 then
										  'Prenatal'
								  end)) over () as Prenatal
					   ,sum(count(case
									  when datediff(day,case tcdob
															when tcdob then
																tcdob
															else
																edc
														end,VisitStartTime) between 0 and 92 then
										  'Prenatal'
								  end)) over () as Within3Months
					   ,sum(count(case
									  when datediff(day,case tcdob
															when tcdob then
																tcdob
															else
																edc
														end,VisitStartTime) > 92 then
										  'Prenatal'
								  end)) over () as After3Months
					   ,sum(count(case
									  when datediff(day,case tcdob
															when tcdob then
																tcdob
															else
																edc
														end,VisitStartTime) <= 92 then
										  'Prenatal'
								  end)) over () as Prenatal_or_Within3
			from (select min(VisitStartTime) as VisitStartTime
						,hvcasepk
						,tcdob
						,edc
					  from hvlog
						  left join HVCase on HVCase.HVCasePK = hvlog.hvcasefk
						  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
						  inner join WorkerProgram wp on WorkerFK = CurrentFSWFK
						  inner join dbo.SplitString(@programfk,',') on hvlog.programfk = listitem
					  where CaseProgress >= 9
						   and IntakeDate between @STDate and @EndDate
						   and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
					  group by hvcasepk
							  ,tcdob
							  ,edc) as a
				inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = a.HVCasePK
			group by hvcasepk
					,VisitStartTime
					,tcdob
					,edc


	end
GO
