
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 14, 2010>
-- Description:	<report: Supervisor Case List>
-- =============================================
CREATE procedure [dbo].[rspSupervisorCaseList]
(
    @programfk int,
    @SupPK     int = null
)
-- Add the parameters for the stored procedure here
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	-- Insert statements for procedure here
	select pc1id
		  ,levelname
		  ,caseweight
		  ,supfname
		  ,suplname
		  ,worker.firstname as wfname
		  ,worker.lastname as wlname
		  ,case when levelname in ('Preintake','Preintake-enroll') then 1 else 0 end as PreintakeCount
		  ,case when levelname='Level 1' then 1 else 0 end as Level1Count
		  ,case when levelname='Level 2' then 1 else 0 end as Level2Count
		  ,case when levelname='Level 3' then 1 else 0 end as Level3Count
		  ,case when levelname='Level 4' then 1 else 0 end as Level4Count
		  ,case when levelname='Level 1-SS' then 1 else 0 end as Level1SSCount
		  ,case when levelname='Level 1-Prenatal' then 1 else 0 end as Level1PrenatalCount
		  ,case when levelname='Level X' then 1 else 0 end as LevelXCount
		from
			(select *
				 from codeLevel
				 where caseweight is not null) cl
			left outer join caseprogram
						   on caseprogram.currentLevelFK = cl.codeLevelPK
			inner join worker
					  on caseprogram.currentFSWFK = worker.workerpk
			inner join workerprogram wp
					  on wp.workerfk = worker.workerpk and wp.programfk = @programfk
			left outer join (select workerpk
								  ,firstName as supfname
								  ,LastName as suplname
								from worker) sw
						   on wp.supervisorfk = sw.workerpk
		where
			 dischargedate is null
			 and caseprogram.programfk = @programfk
			 and sw.workerpk = isnull(@SupPK,sw.workerpk)
		order by suplname
				,supfname
				,wlname
				,wfname

end
GO
