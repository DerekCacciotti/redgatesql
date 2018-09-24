SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddSupervisionCase](@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@SupervisionFK int=NULL,
@CaseComments varchar(max)=NULL)
AS
INSERT INTO SupervisionCase(
HVCaseFK,
ProgramFK,
SupervisionFK,
CaseComments
)
VALUES(
@HVCaseFK,
@ProgramFK,
@SupervisionFK,
@CaseComments
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
