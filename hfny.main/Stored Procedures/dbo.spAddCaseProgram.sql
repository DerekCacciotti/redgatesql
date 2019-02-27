SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddCaseProgram](@CaseProgramCreator char(10)=NULL,
@CaseStartDate datetime=NULL,
@CurrentFAFK int=NULL,
@CurrentFAWFK int=NULL,
@CurrentFSWFK int=NULL,
@CurrentLevelDate datetime=NULL,
@CurrentLevelFK int=NULL,
@DischargeDate datetime=NULL,
@DischargeReason char(2)=NULL,
@DischargeReasonSpecify varchar(500)=NULL,
@ExtraField1 char(30)=NULL,
@ExtraField2 char(30)=NULL,
@ExtraField3 char(30)=NULL,
@ExtraField4 char(30)=NULL,
@ExtraField5 char(30)=NULL,
@ExtraField6 char(30)=NULL,
@ExtraField7 char(30)=NULL,
@ExtraField8 char(30)=NULL,
@ExtraField9 char(30)=NULL,
@HVCaseFK int=NULL,
@HVCaseFK_old int=NULL,
@OldID char(23)=NULL,
@PC1ID char(13)=NULL,
@ProgramFK int=NULL,
@TransferredtoProgram varchar(50)=NULL,
@TransferredtoProgramFK int=NULL,
@TransferredStatus int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) CaseProgramPK
FROM CaseProgram lastRow
WHERE 
@CaseProgramCreator = lastRow.CaseProgramCreator AND
@CaseStartDate = lastRow.CaseStartDate AND
@CurrentFAFK = lastRow.CurrentFAFK AND
@CurrentFAWFK = lastRow.CurrentFAWFK AND
@CurrentFSWFK = lastRow.CurrentFSWFK AND
@CurrentLevelDate = lastRow.CurrentLevelDate AND
@CurrentLevelFK = lastRow.CurrentLevelFK AND
@DischargeDate = lastRow.DischargeDate AND
@DischargeReason = lastRow.DischargeReason AND
@DischargeReasonSpecify = lastRow.DischargeReasonSpecify AND
@ExtraField1 = lastRow.ExtraField1 AND
@ExtraField2 = lastRow.ExtraField2 AND
@ExtraField3 = lastRow.ExtraField3 AND
@ExtraField4 = lastRow.ExtraField4 AND
@ExtraField5 = lastRow.ExtraField5 AND
@ExtraField6 = lastRow.ExtraField6 AND
@ExtraField7 = lastRow.ExtraField7 AND
@ExtraField8 = lastRow.ExtraField8 AND
@ExtraField9 = lastRow.ExtraField9 AND
@HVCaseFK = lastRow.HVCaseFK AND
@HVCaseFK_old = lastRow.HVCaseFK_old AND
@OldID = lastRow.OldID AND
@PC1ID = lastRow.PC1ID AND
@ProgramFK = lastRow.ProgramFK AND
@TransferredtoProgram = lastRow.TransferredtoProgram AND
@TransferredtoProgramFK = lastRow.TransferredtoProgramFK AND
@TransferredStatus = lastRow.TransferredStatus
ORDER BY CaseProgramPK DESC) 
BEGIN
INSERT INTO CaseProgram(
CaseProgramCreator,
CaseStartDate,
CurrentFAFK,
CurrentFAWFK,
CurrentFSWFK,
CurrentLevelDate,
CurrentLevelFK,
DischargeDate,
DischargeReason,
DischargeReasonSpecify,
ExtraField1,
ExtraField2,
ExtraField3,
ExtraField4,
ExtraField5,
ExtraField6,
ExtraField7,
ExtraField8,
ExtraField9,
HVCaseFK,
HVCaseFK_old,
OldID,
PC1ID,
ProgramFK,
TransferredtoProgram,
TransferredtoProgramFK,
TransferredStatus
)
VALUES(
@CaseProgramCreator,
@CaseStartDate,
@CurrentFAFK,
@CurrentFAWFK,
@CurrentFSWFK,
@CurrentLevelDate,
@CurrentLevelFK,
@DischargeDate,
@DischargeReason,
@DischargeReasonSpecify,
@ExtraField1,
@ExtraField2,
@ExtraField3,
@ExtraField4,
@ExtraField5,
@ExtraField6,
@ExtraField7,
@ExtraField8,
@ExtraField9,
@HVCaseFK,
@HVCaseFK_old,
@OldID,
@PC1ID,
@ProgramFK,
@TransferredtoProgram,
@TransferredtoProgramFK,
@TransferredStatus
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
