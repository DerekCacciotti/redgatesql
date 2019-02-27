SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddlistMedicalFacility](@MFAddress char(40)=NULL,
@MFCity char(20)=NULL,
@MFCreator char(10)=NULL,
@MFIsActive bit=NULL,
@MFName char(50)=NULL,
@MFPhone char(12)=NULL,
@MFState char(2)=NULL,
@MFZip char(10)=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) listMedicalFacilityPK
FROM listMedicalFacility lastRow
WHERE 
@MFAddress = lastRow.MFAddress AND
@MFCity = lastRow.MFCity AND
@MFCreator = lastRow.MFCreator AND
@MFIsActive = lastRow.MFIsActive AND
@MFName = lastRow.MFName AND
@MFPhone = lastRow.MFPhone AND
@MFState = lastRow.MFState AND
@MFZip = lastRow.MFZip AND
@ProgramFK = lastRow.ProgramFK
ORDER BY listMedicalFacilityPK DESC) 
BEGIN
INSERT INTO listMedicalFacility(
MFAddress,
MFCity,
MFCreator,
MFIsActive,
MFName,
MFPhone,
MFState,
MFZip,
ProgramFK
)
VALUES(
@MFAddress,
@MFCity,
@MFCreator,
@MFIsActive,
@MFName,
@MFPhone,
@MFState,
@MFZip,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
