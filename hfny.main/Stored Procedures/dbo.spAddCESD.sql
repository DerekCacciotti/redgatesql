SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCESD](@ProgramFK int=NULL,
@HVCaseFK int=NULL,
@CESDDate datetime=NULL,
@Bothered int=NULL,
@PoorAppetite int=NULL,
@CantShakeBlues int=NULL,
@GoodAsOthers int=NULL,
@TroubleKeepingMind int=NULL,
@Depressed int=NULL,
@EverythingAnEffort int=NULL,
@Hopeful int=NULL,
@Failure int=NULL,
@Fearful int=NULL,
@RestlessSleep int=NULL,
@Happy int=NULL,
@TalkedLess int=NULL,
@Lonely int=NULL,
@UnfriendlyPeople int=NULL,
@EnjoyLife int=NULL,
@Crying int=NULL,
@Sad int=NULL,
@PeopleDislikeMe int=NULL,
@CantGetGoing int=NULL,
@Score int=NULL,
@CESDCreator varchar(max)=NULL)
AS
INSERT INTO CESD(
ProgramFK,
HVCaseFK,
CESDDate,
Bothered,
PoorAppetite,
CantShakeBlues,
GoodAsOthers,
TroubleKeepingMind,
Depressed,
EverythingAnEffort,
Hopeful,
Failure,
Fearful,
RestlessSleep,
Happy,
TalkedLess,
Lonely,
UnfriendlyPeople,
EnjoyLife,
Crying,
Sad,
PeopleDislikeMe,
CantGetGoing,
Score,
CESDCreator
)
VALUES(
@ProgramFK,
@HVCaseFK,
@CESDDate,
@Bothered,
@PoorAppetite,
@CantShakeBlues,
@GoodAsOthers,
@TroubleKeepingMind,
@Depressed,
@EverythingAnEffort,
@Hopeful,
@Failure,
@Fearful,
@RestlessSleep,
@Happy,
@TalkedLess,
@Lonely,
@UnfriendlyPeople,
@EnjoyLife,
@Crying,
@Sad,
@PeopleDislikeMe,
@CantGetGoing,
@Score,
@CESDCreator
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
