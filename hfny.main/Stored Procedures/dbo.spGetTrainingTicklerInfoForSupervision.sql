SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 09/21/18
-- Description:	This stored procedure gets the rough equivalent
--				of the Training Required Topics report for the passed Worker FK.
-- =============================================
CREATE procedure [dbo].[spGetTrainingTicklerInfoForSupervision]
				(
					@ProgramFK int
					, @WorkerFK int
					, @SupervisorFK int
				)
as begin

declare @tblTickler table (
							WorkerPK int
							, WorkerName char(30)
							, HireDate datetime
							, FirstKempeDate datetime
							, FirstHomeVisitDate datetime
							, SupervisorInitialStart datetime
							, FAWInitialStart datetime
							, FSWInitialStart datetime
							, TopicName char(150)
							, TopicCode numeric(4,1)
							, SubTopicCode char(1)
							, CSST char(10)
							, SubTopicName char(100)
							, TrainingDate datetime
							, ReportGrouping char(60)
							, DateDue char(30)
							)

insert into @tblTickler (
							WorkerPK
							, WorkerName
							, HireDate
							, FirstKempeDate
							, FirstHomeVisitDate
							, SupervisorInitialStart
							, FAWInitialStart
							, FSWInitialStart
							, TopicName
							, TopicCode
							, SubTopicCode
							, CSST
							, SubTopicName
							, TrainingDate
							, ReportGrouping
							, DateDue
						)
	exec rspTrainingTickler @progfk = @ProgramFK -- int
					, @workerfk = @WorkerFK -- int
					, @supervisorfk = @SupervisorFK -- int


select tt.TopicName
	 , tt.TopicCode
	 , tt.SubTopicCode
	 , tt.CSST
	 , convert(char(10), tt.TrainingDate, 101) as TrainingDate
	 , tt.DateDue 
from @tblTickler tt 

end ;

GO
