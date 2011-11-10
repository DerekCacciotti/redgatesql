SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseFilter](@CaseFilterPK int=NULL,
@CaseCriteriaFK int=NULL,
@CaseFilterEditor varchar(10)=NULL,
@FilterValue varchar(50)=NULL,
@HVCaseFK int=NULL,
@ProgramFK int=NULL)
AS
UPDATE CaseFilter
SET 
CaseCriteriaFK = @CaseCriteriaFK, 
CaseFilterEditor = @CaseFilterEditor, 
FilterValue = @FilterValue, 
HVCaseFK = @HVCaseFK, 
ProgramFK = @ProgramFK
WHERE CaseFilterPK = @CaseFilterPK
GO
