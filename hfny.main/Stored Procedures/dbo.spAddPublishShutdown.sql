SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPublishShutdown](@PublishShutdownCreator varchar(max)=NULL,
@PublishShutdownStartDate datetime=NULL,
@PublishShutdownEndDate datetime=NULL,
@PublishShutdownMessage varchar(max)=NULL)
AS
INSERT INTO PublishShutdown(
PublishShutdownCreator,
PublishShutdownStartDate,
PublishShutdownEndDate,
PublishShutdownMessage
)
VALUES(
@PublishShutdownCreator,
@PublishShutdownStartDate,
@PublishShutdownEndDate,
@PublishShutdownMessage
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
