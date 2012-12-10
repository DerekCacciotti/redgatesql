
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <4-1B. Intensive Home Visitation Level after Target Child is Born>
-- =============================================
CREATE procedure [dbo].[rspHVIntensiveLevel_Detail]
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

	select 2 [level1_less_183]
		  ,b.PC1ID
		  ,RTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
		  ,isnull(a.tcdob,a.edc) [edc_dob]
		  ,a.IntakeDate
		  ,yy.days_length_total
		  ,rtrim(w.FirstName)+' '+w.LastName [WorkerName]
		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join pc as c on c.PCPK = a.PC1FK
			inner join Worker w on b.CurrentFSWFK = w.WorkerPK
			join (select distinct x.hvcasefk [hvcasefk]
								 ,[days_length_total]
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
					  where x.[days_length_total] >= 183) as yy on yy.hvcasefk = a.HVCasePK

	union
	select 1 [level1_less_183]
		  ,b.PC1ID
		  ,RTRIM(c.PCFirstName)+' '+c.PCLastName [Name]
		  ,isnull(a.tcdob,a.edc) [edc_dob]
		  ,a.IntakeDate
		  ,yy.days_length_total
		  ,rtrim(w.FirstName)+' '+w.LastName [WorkerName]
		from hvcase as a
			inner join caseprogram as b on b.hvcasefk = a.hvcasepk
			inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join pc as c on c.PCPK = a.PC1FK
			inner join Worker w on b.CurrentFSWFK = w.WorkerPK
			inner join WorkerProgram wp on CurrentFSWFK = WorkerFK
			join (select distinct x.hvcasefk [hvcasefk]
								 ,[days_length_total]
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
					  where x.[days_length_total] < 183) as yy on yy.hvcasefk = a.HVCasePK
		where a.HVCasePK in (select distinct d.hvcasefk
								 from hvcase as a
									 inner join caseprogram as b on b.hvcasefk = a.hvcasepk
									 inner join dbo.SplitString(@programfk,',') on b.programfk = listitem
									 join HVLevelDetail as d on a.hvcasepk = d.hvcasefk
										 and b.programfk = d.programfk
										 and d.StartLevelDate <= @edate
								 where a.caseprogress >= 9
									  and a.intakedate <= @edate
									  and (b.dischargedate is null
									  or b.dischargedate >= @sdate)
									  and d.Levelfk in (16,18,20))

GO
