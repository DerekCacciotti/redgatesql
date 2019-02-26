SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddWorker](@Apt char(10)=NULL,
@ASQTrainingDate datetime=NULL,
@CellPhone char(12)=NULL,
@Children bit=NULL,
@City char(20)=NULL,
@EducationLevel char(2)=NULL,
@FAWCoreDate datetime=NULL,
@FAWInitialStart datetime=NULL,
@FirstName char(20)=NULL,
@FSWCoreDate datetime=NULL,
@FSWInitialStart datetime=NULL,
@FTE char(2)=NULL,
@FTEFullTime bit=NULL,
@Gender char(2)=NULL,
@HomePhone char(12)=NULL,
@LanguageSpecify varchar(100)=NULL,
@LastName char(30)=NULL,
@OtherLanguage bit=NULL,
@PreviousName char(51)=NULL,
@Race char(2)=NULL,
@RaceSpecify varchar(500)=NULL,
@State char(2)=NULL,
@Street char(30)=NULL,
@SupervisorCoreDate datetime=NULL,
@SupervisorFirstEvent datetime=NULL,
@SupervisorInitialStart datetime=NULL,
@WorkerCreator char(10)=NULL,
@WorkerDOB datetime=NULL,
@WorkerPK_old int=NULL,
@YoungestChild int=NULL,
@Zip char(10)=NULL,
@LoginCreated bit=NULL,
@YearsHVExperience int=NULL,
@YearsEarlyChildhoodExperience int=NULL,
@YearsChildAbuseClasses int=NULL,
@SupervisionScheduledDay int=NULL,
@UserName varchar(256)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) WorkerPK
FROM Worker lastRow
WHERE 
@Apt = lastRow.Apt AND
@ASQTrainingDate = lastRow.ASQTrainingDate AND
@CellPhone = lastRow.CellPhone AND
@Children = lastRow.Children AND
@City = lastRow.City AND
@EducationLevel = lastRow.EducationLevel AND
@FAWCoreDate = lastRow.FAWCoreDate AND
@FAWInitialStart = lastRow.FAWInitialStart AND
@FirstName = lastRow.FirstName AND
@FSWCoreDate = lastRow.FSWCoreDate AND
@FSWInitialStart = lastRow.FSWInitialStart AND
@FTE = lastRow.FTE AND
@FTEFullTime = lastRow.FTEFullTime AND
@Gender = lastRow.Gender AND
@HomePhone = lastRow.HomePhone AND
@LanguageSpecify = lastRow.LanguageSpecify AND
@LastName = lastRow.LastName AND
@OtherLanguage = lastRow.OtherLanguage AND
@PreviousName = lastRow.PreviousName AND
@Race = lastRow.Race AND
@RaceSpecify = lastRow.RaceSpecify AND
@State = lastRow.State AND
@Street = lastRow.Street AND
@SupervisorCoreDate = lastRow.SupervisorCoreDate AND
@SupervisorFirstEvent = lastRow.SupervisorFirstEvent AND
@SupervisorInitialStart = lastRow.SupervisorInitialStart AND
@WorkerCreator = lastRow.WorkerCreator AND
@WorkerDOB = lastRow.WorkerDOB AND
@WorkerPK_old = lastRow.WorkerPK_old AND
@YoungestChild = lastRow.YoungestChild AND
@Zip = lastRow.Zip AND
@LoginCreated = lastRow.LoginCreated AND
@YearsHVExperience = lastRow.YearsHVExperience AND
@YearsEarlyChildhoodExperience = lastRow.YearsEarlyChildhoodExperience AND
@YearsChildAbuseClasses = lastRow.YearsChildAbuseClasses AND
@SupervisionScheduledDay = lastRow.SupervisionScheduledDay AND
@UserName = lastRow.UserName
ORDER BY WorkerPK DESC) 
BEGIN
INSERT INTO Worker(
Apt,
ASQTrainingDate,
CellPhone,
Children,
City,
EducationLevel,
FAWCoreDate,
FAWInitialStart,
FirstName,
FSWCoreDate,
FSWInitialStart,
FTE,
FTEFullTime,
Gender,
HomePhone,
LanguageSpecify,
LastName,
OtherLanguage,
PreviousName,
Race,
RaceSpecify,
State,
Street,
SupervisorCoreDate,
SupervisorFirstEvent,
SupervisorInitialStart,
WorkerCreator,
WorkerDOB,
WorkerPK_old,
YoungestChild,
Zip,
LoginCreated,
YearsHVExperience,
YearsEarlyChildhoodExperience,
YearsChildAbuseClasses,
SupervisionScheduledDay,
UserName
)
VALUES(
@Apt,
@ASQTrainingDate,
@CellPhone,
@Children,
@City,
@EducationLevel,
@FAWCoreDate,
@FAWInitialStart,
@FirstName,
@FSWCoreDate,
@FSWInitialStart,
@FTE,
@FTEFullTime,
@Gender,
@HomePhone,
@LanguageSpecify,
@LastName,
@OtherLanguage,
@PreviousName,
@Race,
@RaceSpecify,
@State,
@Street,
@SupervisorCoreDate,
@SupervisorFirstEvent,
@SupervisorInitialStart,
@WorkerCreator,
@WorkerDOB,
@WorkerPK_old,
@YoungestChild,
@Zip,
@LoginCreated,
@YearsHVExperience,
@YearsEarlyChildhoodExperience,
@YearsChildAbuseClasses,
@SupervisionScheduledDay,
@UserName
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
