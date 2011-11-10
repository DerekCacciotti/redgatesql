SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddIntake](@FSWFK int=NULL,
@HVCaseFK int=NULL,
@IntakeCreator char(10)=NULL,
@IntakeDate datetime=NULL,
@IntakeEditdate datetime=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO Intake(
FSWFK,
HVCaseFK,
IntakeCreator,
IntakeDate,
IntakeEditdate,
ProgramFK
)
VALUES(
@FSWFK,
@HVCaseFK,
@IntakeCreator,
@IntakeDate,
@IntakeEditdate,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
