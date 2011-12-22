SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistCaseFilterNameOption](@listCaseFilterNameOptionPK int=NULL,
@CaseFilterNameFK int=NULL,
@FilterOption varchar(50)=NULL)
AS
UPDATE listCaseFilterNameOption
SET 
CaseFilterNameFK = @CaseFilterNameFK, 
FilterOption = @FilterOption
WHERE listCaseFilterNameOptionPK = @listCaseFilterNameOptionPK
GO
