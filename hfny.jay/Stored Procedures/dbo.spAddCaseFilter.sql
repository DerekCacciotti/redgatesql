
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseFilter](@CaseFilterNameFK int=NULL,
@CaseFilterCreator varchar(10)=NULL,
@CaseFilterNameChoice bit=NULL,
@CaseFilterNameOptionFK nchar(10)=NULL,
@CaseFilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO CaseFilter(
CaseFilterNameFK,
CaseFilterCreator,
CaseFilterNameChoice,
CaseFilterNameOptionFK,
CaseFilterValue,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseFilterNameFK,
@CaseFilterCreator,
@CaseFilterNameChoice,
@CaseFilterNameOptionFK,
@CaseFilterValue,
@HVCaseFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
