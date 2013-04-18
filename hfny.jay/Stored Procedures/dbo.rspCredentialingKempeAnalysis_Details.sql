SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <04/15/2013>
-- Description:	<This Credentialing report gets you 'Details for 1-2.A Acceptance Rates and 1-2.B Refusal Rates Analysis'>
-- rspCredentialingKempeAnalysis_Details 2, '01/01/2011', '12/31/2011'

-- =============================================


CREATE procedure [dbo].[rspCredentialingKempeAnalysis_Details](
	@programfk    varchar(max)    = NULL,	
	@StartDate DATETIME,
	@EndDate DATETIME

)
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

;
with cteCohert
as
(
	SELECT HVCasePK
		 , 	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as tcdob
		 , DischargeDate
		 , IntakeDate
		 , k.KempeDate
		 , PC1FK
		 , cp.DischargeReason
		 , OldID
		 , PC1ID		 
		 , KempeResult
		 , cp.CurrentFSWFK
		 , cp.CurrentFAWFK	
		 ,	case
			   when h.tcdob is not null then
				   h.tcdob
			   else
				   h.edc
			end as babydate	
		 ,	case
			   when h.IntakeDate is not null then
				   h.IntakeDate
			   else
				   cp.DischargeDate 
			end as testdate	
		  , P.PCDOB 
		  , P.Race 
		  ,ca.MaritalStatus
		  ,ca.HighestGrade 
		  ,ca.IsCurrentlyEmployed
		  ,ca.OBPInHome  		
		  ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
		  ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore 
		  ,FOBPresent
		  ,MOBPresent 
		  ,MOBPartnerPresent
		  ,OtherPresent 
		  ,MOBPartnerPresent as MOBPartner 
		  ,FOBPartnerPresent as FOBPartner
		  ,GrandParentPresent as MOBGrandmother
	

	 FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
	INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	INNER JOIN PC P ON P.PCPK = h.PC1FK
	LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'KE'

	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL) -- only include kempes that are positive and where there is a clos_date or an intake date.
	AND k.KempeResult = 1
	AND k.KempeDate BETWEEN @StartDate AND @EndDate
	
)	
	
	 SELECT  
			 PC1ID
			, LTRIM(RTRIM(faw.firstname))+' '+LTRIM(RTRIM(faw.lastname)) as FAW			
			,convert(varchar(10),KempeDate,101)  as KempeDate
			,LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as FSW
			,convert(varchar(10),h.DischargeDate,101)  as DischargeDate
			,cd.ReportDischargeText
	 FROM cteCohert h
	left  join worker faw on CurrentFAWFK = faw.workerpk  -- faw
	left  join worker fsw on CurrentFSWFK = fsw.workerpk   -- fsw	 
	left join codeDischarge cd on h.DischargeReason = cd.DischargeCode

	 
	 WHERE DischargeDate IS NOT NULL AND  IntakeDate  IS  NULL  
	 ORDER BY ReportDischargeText, OldID

-- rspCredentialingKempeAnalysis_Details 2, '01/01/2011', '12/31/2011'



GO
