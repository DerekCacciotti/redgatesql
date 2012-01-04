SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE view [dbo].[WorkerAssignmentDetail] as
select workerassignmentpk, hvcasefk,programfk,StartAssignmentDate,workerfk,
ISNULL(EndAssignment,DischargeDate) EndAssignmentDate From 
(select DischargeDate, workerassignmentpk, wa1.hvcasefk,wa1.programfk, workerassignmentdate as StartAssignmentDate,workerfk,
dateadd(day,-1,(select top 1 workerassignmentdate 
	from workerassignment wa2 
	where wa2.workerassignmentdate>wa1.workerassignmentdate and wa2.hvcasefk=wa1.hvcasefk
    order by workerassignmentdate)) EndAssignment
from workerassignment wa1
INNER JOIN CaseProgram cp
on wa1.hvcasefk=cp.hvcasefk and wa1.programfk= cp.programfk) a

GO
