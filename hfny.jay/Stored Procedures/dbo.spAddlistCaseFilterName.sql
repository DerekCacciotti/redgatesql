SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistCaseFilterName](@FieldTitle varchar(50)=NULL,
@FilterType int=NULL,
@Hint varchar(100)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO listCaseFilterName(
FieldTitle,
FilterType,
Hint,
ProgramFK
)
VALUES(
@FieldTitle,
@FilterType,
@Hint,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
