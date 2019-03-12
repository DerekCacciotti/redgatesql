SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVGroupParticipants](@HVGroupFK int=NULL,
@GroupFatherFigureFK int=NULL,
@HVCaseFK int=NULL,
@HVGroupParticipantsCreator varchar(max)=NULL,
@ProgramFK int=NULL,
@PCFK int=NULL,
@RoleType char(3)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HVGroupParticipantsPK
FROM HVGroupParticipants lastRow
WHERE 
@HVGroupFK = lastRow.HVGroupFK AND
@GroupFatherFigureFK = lastRow.GroupFatherFigureFK AND
@HVCaseFK = lastRow.HVCaseFK AND
@HVGroupParticipantsCreator = lastRow.HVGroupParticipantsCreator AND
@ProgramFK = lastRow.ProgramFK AND
@PCFK = lastRow.PCFK AND
@RoleType = lastRow.RoleType
ORDER BY HVGroupParticipantsPK DESC) 
BEGIN
INSERT INTO HVGroupParticipants(
HVGroupFK,
GroupFatherFigureFK,
HVCaseFK,
HVGroupParticipantsCreator,
ProgramFK,
PCFK,
RoleType
)
VALUES(
@HVGroupFK,
@GroupFatherFigureFK,
@HVCaseFK,
@HVGroupParticipantsCreator,
@ProgramFK,
@PCFK,
@RoleType
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
