SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditlistCaseCriteria](@listCaseCriteriaPK int=NULL,
@FieldTitle varchar(50)=NULL,
@Hint varchar(100)=NULL,
@ProgramFK int=NULL)
AS
UPDATE listCaseCriteria
SET 
FieldTitle = @FieldTitle, 
Hint = @Hint, 
ProgramFK = @ProgramFK
WHERE listCaseCriteriaPK = @listCaseCriteriaPK
GO
