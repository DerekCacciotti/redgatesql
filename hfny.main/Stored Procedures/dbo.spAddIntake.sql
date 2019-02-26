SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddIntake](@FSWFK int=NULL,
@HVCaseFK int=NULL,
@IntakeCreator char(10)=NULL,
@IntakeDate datetime=NULL,
@IntakeEditdate datetime=NULL,
@ProgramFK int=NULL,
@MIECHV_Race_AmericanIndian bit=NULL,
@MIECHV_Race_Asian bit=NULL,
@MIECHV_Race_Black bit=NULL,
@MIECHV_Race_Hawaiian bit=NULL,
@MIECHV_Race_White bit=NULL,
@MIECHV_Hispanic nvarchar(1)=NULL,
@OtherChildrenDevelopmentalDelays char(1)=NULL,
@PC1SelfLowStudentAchievement char(1)=NULL,
@PC1ChildrenLowStudentAchievement char(1)=NULL,
@PC1FamilyArmedForces char(1)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) IntakePK
FROM Intake lastRow
WHERE 
@FSWFK = lastRow.FSWFK AND
@HVCaseFK = lastRow.HVCaseFK AND
@IntakeCreator = lastRow.IntakeCreator AND
@IntakeDate = lastRow.IntakeDate AND
@IntakeEditdate = lastRow.IntakeEditdate AND
@ProgramFK = lastRow.ProgramFK AND
@MIECHV_Race_AmericanIndian = lastRow.MIECHV_Race_AmericanIndian AND
@MIECHV_Race_Asian = lastRow.MIECHV_Race_Asian AND
@MIECHV_Race_Black = lastRow.MIECHV_Race_Black AND
@MIECHV_Race_Hawaiian = lastRow.MIECHV_Race_Hawaiian AND
@MIECHV_Race_White = lastRow.MIECHV_Race_White AND
@MIECHV_Hispanic = lastRow.MIECHV_Hispanic AND
@OtherChildrenDevelopmentalDelays = lastRow.OtherChildrenDevelopmentalDelays AND
@PC1SelfLowStudentAchievement = lastRow.PC1SelfLowStudentAchievement AND
@PC1ChildrenLowStudentAchievement = lastRow.PC1ChildrenLowStudentAchievement AND
@PC1FamilyArmedForces = lastRow.PC1FamilyArmedForces
ORDER BY IntakePK DESC) 
BEGIN
INSERT INTO Intake(
FSWFK,
HVCaseFK,
IntakeCreator,
IntakeDate,
IntakeEditdate,
ProgramFK,
MIECHV_Race_AmericanIndian,
MIECHV_Race_Asian,
MIECHV_Race_Black,
MIECHV_Race_Hawaiian,
MIECHV_Race_White,
MIECHV_Hispanic,
OtherChildrenDevelopmentalDelays,
PC1SelfLowStudentAchievement,
PC1ChildrenLowStudentAchievement,
PC1FamilyArmedForces
)
VALUES(
@FSWFK,
@HVCaseFK,
@IntakeCreator,
@IntakeDate,
@IntakeEditdate,
@ProgramFK,
@MIECHV_Race_AmericanIndian,
@MIECHV_Race_Asian,
@MIECHV_Race_Black,
@MIECHV_Race_Hawaiian,
@MIECHV_Race_White,
@MIECHV_Hispanic,
@OtherChildrenDevelopmentalDelays,
@PC1SelfLowStudentAchievement,
@PC1ChildrenLowStudentAchievement,
@PC1FamilyArmedForces
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
