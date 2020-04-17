SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPublishShutdown](@PublishShutdownCreator varchar(max)=NULL,
@PublishShutdownStartDateTime datetime=NULL,
@PublishShutdownEndDateTime datetime=NULL,
@PublishShutdownStartDate varchar(max)=NULL,
@PublishShutdownEndDate varchar(max)=NULL,
@PublishShutdownMessage varchar(max)=NULL)
AS
INSERT INTO PublishShutdown(
PublishShutdownCreator,
PublishShutdownStartDateTime,
PublishShutdownEndDateTime,
PublishShutdownStartDate,
PublishShutdownEndDate,
PublishShutdownMessage
)
VALUES(
@PublishShutdownCreator,
@PublishShutdownStartDateTime,
@PublishShutdownEndDateTime,
@PublishShutdownStartDate,
@PublishShutdownEndDate,
@PublishShutdownMessage
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
