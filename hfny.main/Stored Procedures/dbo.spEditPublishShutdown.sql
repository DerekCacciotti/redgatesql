SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPublishShutdown](@PublishShutdownPK int=NULL,
@PublishShutdownStartDateTime datetime=NULL,
@PublishShutdownEndDateTime datetime=NULL,
@PublishShutdownStartDate varchar(max)=NULL,
@PublishShutdownEndDate varchar(max)=NULL,
@PublishShutdownEditor varchar(max)=NULL,
@PublishShutdownMessage varchar(max)=NULL)
AS
UPDATE PublishShutdown
SET 
PublishShutdownStartDateTime = @PublishShutdownStartDateTime, 
PublishShutdownEndDateTime = @PublishShutdownEndDateTime, 
PublishShutdownStartDate = @PublishShutdownStartDate, 
PublishShutdownEndDate = @PublishShutdownEndDate, 
PublishShutdownEditor = @PublishShutdownEditor, 
PublishShutdownMessage = @PublishShutdownMessage
WHERE PublishShutdownPK = @PublishShutdownPK
GO
