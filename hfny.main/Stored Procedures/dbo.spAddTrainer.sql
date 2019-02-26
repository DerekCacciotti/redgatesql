SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddTrainer](@ProgramFK int=NULL,
@TrainerCreator char(10)=NULL,
@TrainerFirstName char(20)=NULL,
@TrainerLastName char(30)=NULL,
@TrainerOrganization char(30)=NULL,
@TrainerPK_old int=NULL,
@TrainerDescription varchar(50)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) TrainerPK
FROM Trainer lastRow
WHERE 
@ProgramFK = lastRow.ProgramFK AND
@TrainerCreator = lastRow.TrainerCreator AND
@TrainerFirstName = lastRow.TrainerFirstName AND
@TrainerLastName = lastRow.TrainerLastName AND
@TrainerOrganization = lastRow.TrainerOrganization AND
@TrainerPK_old = lastRow.TrainerPK_old AND
@TrainerDescription = lastRow.TrainerDescription
ORDER BY TrainerPK DESC) 
BEGIN
INSERT INTO Trainer(
ProgramFK,
TrainerCreator,
TrainerFirstName,
TrainerLastName,
TrainerOrganization,
TrainerPK_old,
TrainerDescription
)
VALUES(
@ProgramFK,
@TrainerCreator,
@TrainerFirstName,
@TrainerLastName,
@TrainerOrganization,
@TrainerPK_old,
@TrainerDescription
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
