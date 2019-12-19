SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddState](@Abbreviation varchar(2)=NULL,
@Name varchar(250)=NULL)
AS
INSERT INTO State(
Abbreviation,
Name
)
VALUES(
@Abbreviation,
@Name
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
