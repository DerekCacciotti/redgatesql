SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditSupervisionCase](@SupervisionCasePK int=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL,
@SupervisionFK int=NULL,
@CaseComments varchar(max)=NULL)
AS
UPDATE SupervisionCase
SET 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK, 
SupervisionFK = @SupervisionFK, 
CaseComments = @CaseComments
WHERE SupervisionCasePK = @SupervisionCasePK
GO
