SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 14, 2010>
-- Description:	<report: Supervisor Case List>
-- =============================================
create PROCEDURE [dbo].[rspSupervisorCaseList] (@programfk int,@SupPK int = NULL)
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
select pc1id,levelname,caseweight,supfname,suplname,worker.firstname as wfname,worker.lastname as wlname from 
(select * from codeLevel where caseweight is not null) cl
left outer join
caseprogram
on caseprogram.currentLevelFK=cl.codeLevelPK
inner join worker
on  caseprogram.currentFSWFK=worker.workerpk
inner join workerprogram wp
on wp.workerfk=worker.workerpk and wp.programfk=@programfk
left outer join 
(select workerpk, firstName as supfname,LastName as suplname from worker) sw
on wp.supervisorfk= sw.workerpk
where
dischargedate is null and caseprogram.programfk=@programfk
and sw.workerpk= isnull(@SupPK,sw.workerpk) 
order by suplname,supfname,wlname,wfname
         
END








GO
