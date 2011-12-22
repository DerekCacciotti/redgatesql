SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistCaseFilterName](@listCaseFilterNamePK int=NULL,
@FieldTitle varchar(50)=NULL,
@FilterType int=NULL,
@Hint varchar(100)=NULL,
@ProgramFK int=NULL)
AS
UPDATE listCaseFilterName
SET 
FieldTitle = @FieldTitle, 
FilterType = @FilterType, 
Hint = @Hint, 
ProgramFK = @ProgramFK
WHERE listCaseFilterNamePK = @listCaseFilterNamePK
GO
