SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Report - Service Referrals Needing Followup>
-- =============================================

CREATE procedure [dbo].[rspServiceReferralsNeedFollowUp] (@programfk VARCHAR(MAX)=NULL
															,@supervisorfk INT = NULL
															,@workerfk INT = NULL
															,@pc1id varchar(13) = NULL)
AS

IF @programfk IS NULL BEGIN
	SELECT @programfk = 
		SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK))) 
					FROM HVProgram
					FOR XML PATH('')),2,8000)
END

SET @programfk = REPLACE(@programfk,'"','')

select PC1ID
		,pcfirstname + ' ' + pclastname as PC1
		,ServiceReferralType as Referral
		,AppCodeText as FamilyMemberReferred
		,ReferralDate
		,currentfswfk
		,rtrim(fsw.FirstName) + ' ' + rtrim(fsw.LastName) as fsw
		,supervisorfk
		,rtrim(supervisor.FirstName) + ' ' + rtrim(supervisor.LastName) as supervisor
		,CaseProgram.ProgramFK
from dbo.ServiceReferral
inner join dbo.codeServiceReferral on ServiceReferralCode = ServiceCode
inner join dbo.codeApp on FamilyCode = codeApp.AppCode
							and codeApp.AppCodeGroup = 'FamilyMemberReferred'
inner join CaseProgram on ServiceReferral.HVCaseFK = CaseProgram.HVCaseFK
							and ServiceReferral.ProgramFK = CaseProgram.ProgramFK
inner join HVCase on CaseProgram.HVCaseFK = HVCasePK
inner join PC on HVCase.PC1FK = PCPK
inner join worker fsw ON CurrentFSWFK = fsw.workerpk
inner join workerprogram ON workerprogram.workerfk = fsw.workerpk
inner join worker supervisor ON supervisorfk = supervisor.workerpk
inner join dbo.SplitString(@programfk,',') ON caseprogram.programfk  = listitem
where (ServiceReceived IS null or ServiceReceived = 0 or ServiceReceived = RTRIM(''))
		and DischargeDate is null
		and currentFSWFK = ISNULL(@workerfk, currentFSWFK)
		and supervisorfk = ISNULL(@supervisorfk, supervisorfk)
		and PC1ID = ISNULL(@pc1id, PC1ID)
order by PC1ID, ReferralDate

GO
