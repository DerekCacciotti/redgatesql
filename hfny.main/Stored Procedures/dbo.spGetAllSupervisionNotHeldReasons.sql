SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 2018-09-20
-- Edit date: 
-- Edited by: 
-- Edit Reason: 
-- Description:	Get all reasons supervision was not held for a specific supervision session
-- =============================================
CREATE procedure [dbo].[spGetAllSupervisionNotHeldReasons]
	-- Add the parameters for the stored procedure here
	@SupervisionFK as int
as
	begin
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set noCount on ;
		
		declare @listStr varchar(max) ;
		
		select	@listStr = '' + case when SupervisorIll = 1 then ',1' else '' end +
								case when SupervisorForgot = 1 then ',2' else '' end +
								case when SupervisorTraining = 1 then ',3' else '' end +
								case when SupervisorVacation = 1 then ',4' else '' end +
								case when SupervisorHoliday = 1 then ',5' else '' end +
								case when SupervisorFamilyEmergency = 1 then ',6' else '' end +
								case when StaffIll = 1 then ',7' else '' end +
								case when StaffForgot = 1 then ',8' else '' end +
								case when StaffTraining = 1 then ',9' else '' end +
								case when StaffVacation = 1 then ',10' else '' end +
								case when StaffFamilyEmergency = 1 then ',11' else '' end +
								case when StaffCourt = 1 then ',12' else '' end +
								case when StaffOutAllWeek = 1 then ',13' else '' end +
								case when StaffOnLeave = 1 then ',14' else '' end +
								case when ShortWeek = 1 then ',15' else '' end +
								case when Weather = 1 then ',16' else '' end +
								case when ParticipantEmergency = 1 then ',17' else '' end +
								case when ReasonOther = 1 then ',18' else '' end 
		from Supervision s
		where	SupervisionPK = @SupervisionFK
		
		select @listStr + case when @listStr != '' then ',' else '' end ;

	end ;

GO
