SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistCaseCriteria](@FieldTitle varchar(50)=NULL,
@Hint varchar(100)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO listCaseCriteria(
FieldTitle,
Hint,
ProgramFK
)
VALUES(
@FieldTitle,
@Hint,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
