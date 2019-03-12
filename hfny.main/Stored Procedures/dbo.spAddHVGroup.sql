SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVGroup](@ActivityTopic varchar(500)=NULL,
@FAModerator1 int=NULL,
@FAModerator2 int=NULL,
@GroupCreator varchar(max)=NULL,
@GroupDate datetime=NULL,
@GroupLengthHours int=NULL,
@GroupLengthMinutes int=NULL,
@GroupTime datetime=NULL,
@GroupTitle varchar(500)=NULL,
@HVGroupPK_old int=NULL,
@NumberParticipating int=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HVGroupPK
FROM HVGroup lastRow
WHERE 
@ActivityTopic = lastRow.ActivityTopic AND
@FAModerator1 = lastRow.FAModerator1 AND
@FAModerator2 = lastRow.FAModerator2 AND
@GroupCreator = lastRow.GroupCreator AND
@GroupDate = lastRow.GroupDate AND
@GroupLengthHours = lastRow.GroupLengthHours AND
@GroupLengthMinutes = lastRow.GroupLengthMinutes AND
@GroupTime = lastRow.GroupTime AND
@GroupTitle = lastRow.GroupTitle AND
@HVGroupPK_old = lastRow.HVGroupPK_old AND
@NumberParticipating = lastRow.NumberParticipating AND
@ProgramFK = lastRow.ProgramFK
ORDER BY HVGroupPK DESC) 
BEGIN
INSERT INTO HVGroup(
ActivityTopic,
FAModerator1,
FAModerator2,
GroupCreator,
GroupDate,
GroupLengthHours,
GroupLengthMinutes,
GroupTime,
GroupTitle,
HVGroupPK_old,
NumberParticipating,
ProgramFK
)
VALUES(
@ActivityTopic,
@FAModerator1,
@FAModerator2,
@GroupCreator,
@GroupDate,
@GroupLengthHours,
@GroupLengthMinutes,
@GroupTime,
@GroupTitle,
@HVGroupPK_old,
@NumberParticipating,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
