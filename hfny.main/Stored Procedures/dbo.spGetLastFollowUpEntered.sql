SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetLastFollowUpEntered] @interval INT, @HVCaseFK INT as
--SELECT TOP 1 * FROM dbo.codeDueByDates cbd INNER JOIN dbo.FollowUp fu ON fu.FollowUpInterval = cbd.Interval 
--WHERE cbd.ScheduledEvent = 'Follow Up' AND fu.HVCaseFK = @HVCaseFK ORDER BY fu.FollowUpDate DESC


SELECT TOP 1* FROM dbo.codeDueByDates cbd INNER JOIN dbo.FollowUp fu ON fu.FollowUpInterval = cbd.Interval 
WHERE cbd.ScheduledEvent = 'Follow Up' AND fu.HVCaseFK = @HVCaseFK AND fu.FollowUpInterval = @interval






GO
