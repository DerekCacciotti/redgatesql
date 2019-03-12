SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistMedicalProvider](@MedicalProviderCreator varchar(max)=NULL,
@MPAddress char(40)=NULL,
@MPCity char(20)=NULL,
@MPFirstName varchar(200)=NULL,
@MPIsActive bit=NULL,
@MPLastName varchar(200)=NULL,
@MPPhone char(12)=NULL,
@MPState char(2)=NULL,
@MPZip char(10)=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listMedicalProviderPK
FROM listMedicalProvider lastRow
WHERE 
@MedicalProviderCreator = lastRow.MedicalProviderCreator AND
@MPAddress = lastRow.MPAddress AND
@MPCity = lastRow.MPCity AND
@MPFirstName = lastRow.MPFirstName AND
@MPIsActive = lastRow.MPIsActive AND
@MPLastName = lastRow.MPLastName AND
@MPPhone = lastRow.MPPhone AND
@MPState = lastRow.MPState AND
@MPZip = lastRow.MPZip AND
@ProgramFK = lastRow.ProgramFK
ORDER BY listMedicalProviderPK DESC) 
BEGIN
INSERT INTO listMedicalProvider(
MedicalProviderCreator,
MPAddress,
MPCity,
MPFirstName,
MPIsActive,
MPLastName,
MPPhone,
MPState,
MPZip,
ProgramFK
)
VALUES(
@MedicalProviderCreator,
@MPAddress,
@MPCity,
@MPFirstName,
@MPIsActive,
@MPLastName,
@MPPhone,
@MPState,
@MPZip,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
