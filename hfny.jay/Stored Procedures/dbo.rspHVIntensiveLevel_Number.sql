
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <copied from FamSys - see header below>
-- exec rspHVIntensiveLevel_Number '1','20111101','20121031',null,null,null
-- =============================================
CREATE procedure [dbo].[rspHVIntensiveLevel_Number]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime,
    @sitefk		 int			 = null,
    @posclause	 varchar(200), 
    @negclause	 varchar(200)
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	set @sitefk = case when dbo.IsNullOrEmpty(@sitefk) = 1 then 0 else @sitefk end
	set @posclause = case when @posclause = '' then null else @posclause end

	--SET @sdate='09/20/2010'
	--SET @edate='12/01/2010'

	declare @total_n int;
	declare @level1_183days int;
	declare @diff_n int;

	select @total_n = count(distinct hvcasefk)
		from (
			  -- cases with level 2 to 4
			  select distinct d.hvcasefk
				  from hvcase as a
					  inner join caseprogram as b on b.hvcasefk = a.hvcasepk
					  inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
					  join HVLevelDetail as d on a.hvcasepk = d.hvcasefk and b.programfk = d.programfk and d.StartLevelDate <= @edate
					  inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = a.HVCasePK
					  inner join WorkerProgram wp on wp.WorkerFK = CurrentFSWFK
				  where a.caseprogress >= 9
					   and a.intakedate <= @edate
					   and (b.dischargedate is null
					   or b.dischargedate >= @sdate)
					   and d.Levelfk in (16,18,20)
					   and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)

			  -- union 2 groups then count the distinct
			  union

			  -- cases with level 1 > 183 days
			  select distinct x.hvcasefk
				  from (select q.hvcasefk
							  ,sum(q.[days_length]) [days_length_total]
							from (select p.hvcasefk
										,p.Levelfk
										,p.levelname
										,p.StartLevelDate
										,p.EndLevelDate
										,p.FinalEndLevelDate
										,(datediff(dd,p.StartLevelDate,p.FinalEndLevelDate)+1) [days_length]
									  from (select d.hvcasefk
												  ,d.Levelfk
												  ,d.levelname
												  ,d.StartLevelDate
												  ,d.EndLevelDate
												  ,case
													   when d.EndLevelDate is null then
														   @edate
													   when d.EndLevelDate > @edate then
														   @edate
													   else
														   d.EndLevelDate
												   end [FinalEndLevelDate]
												from hvcase as a
													inner join caseprogram as b on b.hvcasefk = a.hvcasepk
													inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
													join HVLevelDetail as d on a.hvcasepk = d.hvcasefk and b.programfk = d.programfk and d.StartLevelDate <= @edate
													inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = a.HVCasePK
													inner join WorkerProgram wp on wp.WorkerFK = CurrentFSWFK
												where a.caseprogress >= 9
													 and a.intakedate <= @edate
													 and (b.dischargedate is null
													 or b.dischargedate >= @sdate)
													 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
											) as p
									) as q
							where q.Levelfk in (14,27,24)
							group by q.hvcasefk) as x
				  where x.[days_length_total] >= 183) as xx

	-- 183 days
	select @level1_183days = count(distinct x.hvcasefk)
		from (select q.hvcasefk
					,sum(q.[days_length]) [days_length_total]
				  from (select p.hvcasefk
							  ,p.Levelfk
							  ,p.levelname
							  ,p.StartLevelDate
							  ,p.EndLevelDate
							  ,p.FinalEndLevelDate
							  ,(datediff(dd,p.StartLevelDate,p.FinalEndLevelDate)+1) [days_length]
							from (select d.hvcasefk
										,d.Levelfk
										,d.levelname
										,d.StartLevelDate
										,d.EndLevelDate
										,case
											 when d.EndLevelDate is null then
												 @edate
											 when d.EndLevelDate > @edate then
												 @edate
											 else
												 d.EndLevelDate
										 end [FinalEndLevelDate]

									  from hvcase as a
										  inner join caseprogram as b on b.hvcasefk = a.hvcasepk
										  inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
										  join HVLevelDetail as d on a.hvcasepk = d.hvcasefk and b.programfk = d.programfk and d.StartLevelDate <= @edate
										  inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = a.HVCasePK
										  inner join WorkerProgram wp on wp.WorkerFK = CurrentFSWFK
									  where a.caseprogress >= 9
										   and a.intakedate <= @edate
										   and (b.dischargedate is null
										   or b.dischargedate >= @sdate)
										   and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
								) as p
						) as q
				  where q.Levelfk in (14,27,24)
				  group by q.hvcasefk) as x
		where x.[days_length_total] >= 183

	set @diff_n = @total_n-@level1_183days

	select @total_n [Total_N]
		  ,@level1_183days [Level1_183days]
		  ,@diff_n [Diff_N]
GO
