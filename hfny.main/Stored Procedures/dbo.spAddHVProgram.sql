SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddHVProgram](@ContractEndDate datetime=NULL,
@ContractManager char(30)=NULL,
@ContractNumber char(10)=NULL,
@ContractStartDate datetime=NULL,
@CountyFK int=NULL,
@ExtraField1Description char(30)=NULL,
@ExtraField2Description char(30)=NULL,
@ExtraField3Description char(30)=NULL,
@ExtraField4Description char(30)=NULL,
@ExtraField5Description char(30)=NULL,
@ExtraField7Description char(30)=NULL,
@ExtraField8Description char(30)=NULL,
@ExtraField9Description char(30)=NULL,
@GrantAmount numeric(10, 2)=NULL,
@HVProgramCreator varchar(max)=NULL,
@LeadAgencyCity char(20)=NULL,
@LeadAgencyDirector char(40)=NULL,
@LeadAgencyName char(70)=NULL,
@LeadAgencyStreet char(40)=NULL,
@LeadAgencyZip char(10)=NULL,
@ModemNumber char(12)=NULL,
@ProgramCapacity int=NULL,
@ProgramCity char(20)=NULL,
@ProgramCode char(3)=NULL,
@ProgramFaxNumber char(12)=NULL,
@ProgramManager char(30)=NULL,
@ProgramName char(60)=NULL,
@ProgramPhone char(12)=NULL,
@ProgramStreet char(40)=NULL,
@ProgramZip char(10)=NULL,
@RegionFK int=NULL,
@TargetZip nvarchar(500)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) HVProgramPK
FROM HVProgram lastRow
WHERE 
@ContractEndDate = lastRow.ContractEndDate AND
@ContractManager = lastRow.ContractManager AND
@ContractNumber = lastRow.ContractNumber AND
@ContractStartDate = lastRow.ContractStartDate AND
@CountyFK = lastRow.CountyFK AND
@ExtraField1Description = lastRow.ExtraField1Description AND
@ExtraField2Description = lastRow.ExtraField2Description AND
@ExtraField3Description = lastRow.ExtraField3Description AND
@ExtraField4Description = lastRow.ExtraField4Description AND
@ExtraField5Description = lastRow.ExtraField5Description AND
@ExtraField7Description = lastRow.ExtraField7Description AND
@ExtraField8Description = lastRow.ExtraField8Description AND
@ExtraField9Description = lastRow.ExtraField9Description AND
@GrantAmount = lastRow.GrantAmount AND
@HVProgramCreator = lastRow.HVProgramCreator AND
@LeadAgencyCity = lastRow.LeadAgencyCity AND
@LeadAgencyDirector = lastRow.LeadAgencyDirector AND
@LeadAgencyName = lastRow.LeadAgencyName AND
@LeadAgencyStreet = lastRow.LeadAgencyStreet AND
@LeadAgencyZip = lastRow.LeadAgencyZip AND
@ModemNumber = lastRow.ModemNumber AND
@ProgramCapacity = lastRow.ProgramCapacity AND
@ProgramCity = lastRow.ProgramCity AND
@ProgramCode = lastRow.ProgramCode AND
@ProgramFaxNumber = lastRow.ProgramFaxNumber AND
@ProgramManager = lastRow.ProgramManager AND
@ProgramName = lastRow.ProgramName AND
@ProgramPhone = lastRow.ProgramPhone AND
@ProgramStreet = lastRow.ProgramStreet AND
@ProgramZip = lastRow.ProgramZip AND
@RegionFK = lastRow.RegionFK AND
@TargetZip = lastRow.TargetZip
ORDER BY HVProgramPK DESC) 
BEGIN
INSERT INTO HVProgram(
ContractEndDate,
ContractManager,
ContractNumber,
ContractStartDate,
CountyFK,
ExtraField1Description,
ExtraField2Description,
ExtraField3Description,
ExtraField4Description,
ExtraField5Description,
ExtraField7Description,
ExtraField8Description,
ExtraField9Description,
GrantAmount,
HVProgramCreator,
LeadAgencyCity,
LeadAgencyDirector,
LeadAgencyName,
LeadAgencyStreet,
LeadAgencyZip,
ModemNumber,
ProgramCapacity,
ProgramCity,
ProgramCode,
ProgramFaxNumber,
ProgramManager,
ProgramName,
ProgramPhone,
ProgramStreet,
ProgramZip,
RegionFK,
TargetZip
)
VALUES(
@ContractEndDate,
@ContractManager,
@ContractNumber,
@ContractStartDate,
@CountyFK,
@ExtraField1Description,
@ExtraField2Description,
@ExtraField3Description,
@ExtraField4Description,
@ExtraField5Description,
@ExtraField7Description,
@ExtraField8Description,
@ExtraField9Description,
@GrantAmount,
@HVProgramCreator,
@LeadAgencyCity,
@LeadAgencyDirector,
@LeadAgencyName,
@LeadAgencyStreet,
@LeadAgencyZip,
@ModemNumber,
@ProgramCapacity,
@ProgramCity,
@ProgramCode,
@ProgramFaxNumber,
@ProgramManager,
@ProgramName,
@ProgramPhone,
@ProgramStreet,
@ProgramZip,
@RegionFK,
@TargetZip
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
