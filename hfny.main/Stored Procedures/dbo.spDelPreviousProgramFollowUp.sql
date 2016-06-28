SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 06/22/16
-- Description:	Deletes the follow-up and all related forms 
--				from the previous program when a program 
--				accepts a transfer case.
-- =============================================
CREATE procedure [dbo].[spDelPreviousProgramFollowUp]
	-- Add the parameters for the stored procedure here
	@HVCaseFK int
	, @ProgramFK int
	, @FollowUpFK int
	, @ok as varchar(200) output
as
begin
	begin try
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set nocount on;

		declare @PC1IssuesFK int
		declare @ReturnValue bit

		select @FollowUpFK = FollowUpPK
				, @PC1IssuesFK = PC1IssuesFK
		from FollowUp fu 
		where HVCaseFK = @HVCaseFK
				and FollowUpInterval = '99'

		if @@ROWCOUNT = 0
			return
			
		begin transaction

			delete from FollowUp 
			where HVCaseFK = @HVCaseFK 
					and FollowUpInterval = '99'

			delete from PC1Issues
			where PC1IssuesPK = 138052

			delete from Employment
			where FormFK = @FollowUpFK
					and FormType = 'FU'
					and Interval = '99'

			delete from Education
			where FormFK = @FollowUpFK
					and FormType = 'FU'
					and Interval = '99'

			delete from PHQ9
			where FormFK = @FollowUpFK
					and FormType = 'FU'
					and FormInterval = '99'

			delete from CommonAttributes
			where HVCaseFK = @HVCaseFK 
					and FormType like 'FU%' 
					and FormInterval = '99'

		-- Successfully deleted 
		set @ok = 'good'
		commit
	end try
	begin catch
		if @@TRANCOUNT > 0
			rollback
	end	catch

end
GO
