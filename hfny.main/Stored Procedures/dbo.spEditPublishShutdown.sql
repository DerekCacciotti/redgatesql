SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPublishShutdown](@PublishShutdownPK int=NULL,
@PublishShutdownStart datetime=NULL,
@PublishShutdownEnd datetime=NULL,
@PublishShutdownEditor varchar(max)=NULL,
@PublishShutdownMessage varchar(max)=NULL)
AS
UPDATE PublishShutdown
SET 
PublishShutdownStart = @PublishShutdownStart, 
PublishShutdownEnd = @PublishShutdownEnd, 
PublishShutdownEditor = @PublishShutdownEditor, 
PublishShutdownMessage = @PublishShutdownMessage
WHERE PublishShutdownPK = @PublishShutdownPK
GO
