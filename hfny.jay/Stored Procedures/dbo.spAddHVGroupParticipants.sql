SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVGroupParticipants](@HVGroupFK int=NULL,
@GroupFatherFigureFK int=NULL,
@HVGroupParticipantsCreator char(10)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO HVGroupParticipants(
HVGroupFK,
GroupFatherFigureFK,
HVGroupParticipantsCreator,
ProgramFK
)
VALUES(
@HVGroupFK,
@GroupFatherFigureFK,
@HVGroupParticipantsCreator,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
