
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[spGetCasesEligibleForTransfer] (@ProgramFK int)

AS
BEGIN
  SET NOCOUNT ON;


;
with cteLastDischargeCases as
( -- get the last transfer case
SELECT max(CaseProgramEditDate) CaseProgramEditDate, HVCaseFK
from CaseProgram
where TransferredToProgramFK = @programfk
group by HVCaseFK 
)



SELECT  cp.PC1ID, cp.DischargeDate, PC.PCDOB, PC.PCFirstName, PC.PCLastName, 
		cp.HVCaseFK, cp.ProgramFK, cp.CaseProgramPK
FROM    CaseProgram cp
		inner join cteLastDischargeCases ldc on ldc.HVCaseFK = cp.HVCaseFK and cp.CaseProgramEditDate = ldc.CaseProgramEditDate 
        INNER JOIN HVCase c ON cp.HVCaseFK = c.HVCasePK 
        INNER JOIN PC ON c.PC1FK = PC.PCPK
WHERE   (cp.DischargeReason = '37') AND 
        (cp.DischargeDate IS NOT NULL) AND 
        cp.TransferredToProgramFK = @ProgramFK AND 
		cp.HVCaseFK not in 
		(select cp2.HVCaseFK 
		 from   CaseProgram cp2 
		 where  cp2.HVCaseFK= cp.HVCaseFK and 
				cp2.TransferredToProgramFK is null)
ORDER BY DischargeDate 

/* AND CaseProgram.HVCaseFK NOT IN */
/* (SELECT HVCaseFK FROM CaseProgram WHERE ProgramFK = @ProgramFK) */
/* SET NOCOUNT ON */ 

END
GO
