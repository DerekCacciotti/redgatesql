SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeFormAccess](@AllowedAccess bit=NULL,
@Creator varchar(256)=NULL,
@codeFormFK int=NULL,
@StateFK int=NULL)
AS
INSERT INTO codeFormAccess(
AllowedAccess,
Creator,
codeFormFK,
StateFK
)
VALUES(
@AllowedAccess,
@Creator,
@codeFormFK,
@StateFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
