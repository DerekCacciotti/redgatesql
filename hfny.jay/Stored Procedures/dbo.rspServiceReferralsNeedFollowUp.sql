
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Report - Service Referrals Needing Followup>
-- =============================================

CREATE procedure [dbo].[rspServiceReferralsNeedFollowUp](@programfk    varchar(max)    = null,
                                                        @supervisorfk int             = null,
                                                        @workerfk     int             = null,
                                                        @pc1id        varchar(13)     = null
                                                        )
as

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	select PC1ID
		  ,pcfirstname+' '+pclastname as PC1
		  ,ServiceReferralType as Referral
		  ,AppCodeText as FamilyMemberReferred
		  ,ReferralDate
		  ,currentfswfk
		  ,rtrim(fsw.FirstName)+' '+rtrim(fsw.LastName) as fsw
		  ,supervisorfk
		  ,rtrim(supervisor.FirstName)+' '+rtrim(supervisor.LastName) as supervisor
		  ,CaseProgram.ProgramFK
		from dbo.ServiceReferral
			inner join dbo.codeServiceReferral on ServiceReferralCode = ServiceCode
			inner join dbo.codeApp on FamilyCode = codeApp.AppCode
					  and codeApp.AppCodeGroup = 'FamilyMemberReferred'
			inner join CaseProgram on ServiceReferral.HVCaseFK = CaseProgram.HVCaseFK
					  and ServiceReferral.ProgramFK = CaseProgram.ProgramFK
			inner join HVCase on CaseProgram.HVCaseFK = HVCasePK
			inner join PC on HVCase.PC1FK = PCPK
			inner join worker fsw on CurrentFSWFK = fsw.workerpk
			inner join workerprogram on workerprogram.workerfk = fsw.workerpk
			inner join worker supervisor on supervisorfk = supervisor.workerpk
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where (ServiceReceived is null
				 or ServiceReceived = 0
				 or ServiceReceived = RTRIM(''))
			 and (ReasonNoService = rtrim(''))
			 and DischargeDate is null
			 and currentFSWFK = isnull(@workerfk,currentFSWFK)
			 and supervisorfk = isnull(@supervisorfk,supervisorfk)
			 and PC1ID = isnull(@pc1id,PC1ID)
		order by PC1ID
				,ReferralDate
GO
