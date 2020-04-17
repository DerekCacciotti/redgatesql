SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPublishShutdown](@PublishShutdownPK int=NULL,
@PublishShutdownStartDate datetime=NULL,
@PublishShutdownEndDate datetime=NULL,
@PublishShutdownEditor varchar(max)=NULL,
@PublishShutdownMessage varchar(max)=NULL)
AS
UPDATE PublishShutdown
SET 
PublishShutdownStartDate = @PublishShutdownStartDate, 
PublishShutdownEndDate = @PublishShutdownEndDate, 
PublishShutdownEditor = @PublishShutdownEditor, 
PublishShutdownMessage = @PublishShutdownMessage
WHERE PublishShutdownPK = @PublishShutdownPK
GO
