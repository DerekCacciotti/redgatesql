SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditState](@StatePK int=NULL,
@Abbreviation varchar(2)=NULL,
@Name varchar(250)=NULL)
AS
UPDATE State
SET 
Abbreviation = @Abbreviation, 
Name = @Name
WHERE StatePK = @StatePK
GO
