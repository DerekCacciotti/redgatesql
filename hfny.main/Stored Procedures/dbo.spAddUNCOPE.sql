SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddUNCOPE](@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@FSWFK int=NULL,
@UNCOPEDate datetime=NULL,
@Used int=NULL,
@Neglected int=NULL,
@CutDown int=NULL,
@Objected int=NULL,
@Preoccupied int=NULL,
@EmotionalDiscomfort int=NULL,
@Score int=NULL,
@UNCOPECreator varchar(max)=NULL)
AS
INSERT INTO UNCOPE(
HVCaseFK,
ProgramFK,
FSWFK,
UNCOPEDate,
Used,
Neglected,
CutDown,
Objected,
Preoccupied,
EmotionalDiscomfort,
Score,
UNCOPECreator
)
VALUES(
@HVCaseFK,
@ProgramFK,
@FSWFK,
@UNCOPEDate,
@Used,
@Neglected,
@CutDown,
@Objected,
@Preoccupied,
@EmotionalDiscomfort,
@Score,
@UNCOPECreator
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
