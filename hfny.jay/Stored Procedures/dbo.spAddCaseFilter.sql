
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseFilter](@CaseFilterNameFK int=NULL,
@CaseFilterCreator varchar(10)=NULL,
@FilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO CaseFilter(
CaseFilterNameFK,
CaseFilterCreator,
FilterValue,
HVCaseFK,
ProgramFK
)
VALUES(
@CaseFilterNameFK,
@CaseFilterCreator,
@FilterValue,
@HVCaseFK,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
