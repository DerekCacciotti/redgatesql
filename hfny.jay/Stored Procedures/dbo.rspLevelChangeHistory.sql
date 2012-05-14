
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 18, 2012>
-- Description:	<HFNY MIS report - Level Change History>
-- =============================================
CREATE procedure [dbo].[rspLevelChangeHistory](@programfk varchar(max)    = null,
                                               @pc1id     varchar(13)     = null, 
                                               @WorkerFK int = null,
                                               @SupervisorFK int = null
                                               )

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end;

	if @pc1id = ''
	begin
		set @pc1id = nullif(@pc1id,'')
	end;
	
	select PC1ID
		  ,levelname
		  ,StartLevelDate
		  ,isnull(EndLevelDate,current_timestamp) as EndLevelDate
		  ,datediff(day,StartLevelDate,isnull(EndLevelDate+1,current_timestamp)) as DaysOnLevel
		  ,DischargeDate
		from HVLevelDetail hld
			inner join CaseProgram cp on cp.HVCaseFK = hld.hvcasefk
			inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK
			inner join dbo.SplitString(@programfk,',') on hld.programfk = listitem
		where PC1ID = isnull(@PC1ID,pc1id)
				and CurrentFSWFK = isnull(@WorkerFK, CurrentFSWFK)
				and SupervisorFK = isnull(@SupervisorFK, SupervisorFK)
		order by PC1ID
				,StartLevelDate desc

end
GO
