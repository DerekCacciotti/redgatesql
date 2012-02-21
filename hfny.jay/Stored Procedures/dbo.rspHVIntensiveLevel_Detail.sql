SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Feb 20, 2012>
-- Description: <4-1B. Intensive Home Visitation Level after Target Child is Born>
-- =============================================
create procedure [dbo].[rspHVIntensiveLevel_Detail]
(
    @programfk varchar(max)    = null,
    @sdate     datetime,
    @edate     datetime
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

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
													where a.caseprogress >= 9
														 and a.intakedate <= @edate
														 and (b.dischargedate is null
														 or b.dischargedate > @edate)) as p) as q
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
													where a.caseprogress >= 9
														 and a.intakedate <= @edate
														 and (b.dischargedate is null
														 or b.dischargedate > @edate)) as p) as q
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
									  or b.dischargedate > @edate)
									  and d.Levelfk in (16,18,20))

GO
