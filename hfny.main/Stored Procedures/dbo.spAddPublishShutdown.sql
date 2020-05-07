SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPublishShutdown](@PublishShutdownCreator varchar(max)=NULL,
@PublishShutdownStart datetime=NULL,
@PublishShutdownEnd datetime=NULL,
@PublishShutdownMessage varchar(max)=NULL)
AS
INSERT INTO PublishShutdown(
PublishShutdownCreator,
PublishShutdownStart,
PublishShutdownEnd,
PublishShutdownMessage
)
VALUES(
@PublishShutdownCreator,
@PublishShutdownStart,
@PublishShutdownEnd,
@PublishShutdownMessage
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
