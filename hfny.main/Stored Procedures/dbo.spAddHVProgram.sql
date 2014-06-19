
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
@HVProgramCreator char(10)=NULL,
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

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
