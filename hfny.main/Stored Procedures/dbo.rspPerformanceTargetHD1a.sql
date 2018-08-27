SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
exec alter-procedure-rspPerformanceTargetHD1
*/
-- =============================================
-- Author:		Ben Simmons
-- Create Date: 07/24/18
-- Description: This stored procedure is essentially the same as the HD1 stored procedure, but
-- it uses the updated best practice immunization standards
-- =============================================
CREATE PROC [dbo].[rspPerformanceTargetHD1a]
(
    @StartDate	DATETIME,
    @EndDate	DATETIME,
    @tblPTCases	PTCases	READONLY
)

AS
BEGIN

	;
	with cteTotalCases
	AS
	(
	SELECT
		  ptc.HVCaseFK
		 , ptc.PC1ID
		 , ptc.OldID	
		 , ptc.PC1FullName
		 , ptc.CurrentWorkerFK
		 , ptc.CurrentWorkerFullName
		 , ptc.CurrentLevelName
		 , ptc.ProgramFK
		 , ptc.TCIDPK
		 , ptc.TCDOB
		 , cp.DischargeDate
		 ,CASE
			  WHEN DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  DATEDIFF(DAY,ptc.tcdob,DischargeDate)
			  ELSE
				  DATEDIFF(DAY,ptc.tcdob,@EndDate)
		  END AS tcAgeDays
		 ,CASE
			  WHEN DischargeDate is not null and DischargeDate <> '' and DischargeDate <= @EndDate then
				  DischargeDate
			  ELSE
				  @EndDate
		  END AS lastdate
		FROM @tblPTCases ptc
			INNER JOIN HVCase h WITH (NOLOCK) ON ptc.hvcaseFK = h.HVCasePK
			INNER JOIN CaseProgram cp WITH (NOLOCK) ON cp.CaseProgramPK = ptc.CaseProgramPK
			INNER JOIN TCID t WITH (NOLOCK) ON t.HVCaseFK = h.HVCasePK and t.TCIDPK = ptc.TCIDPK
			-- h.hvcasePK = cp.HVCaseFK and cp.ProgramFK = ptc.ProgramFK -- AND cp.DischargeDate IS NULL
		WHERE t.NoImmunization IS NULL OR t.NoImmunization <> 1
	)
	,
	-- Report: HD1a. Immunization at one year
	cteCohort
	AS
	(
	SELECT HVCaseFK
		  , PC1ID
		  , OldID		 
		  , PC1FullName
		  , CurrentWorkerFK
		  , CurrentWorkerFullName
		  , CurrentLevelName
		  , ProgramFK
		  , TCIDPK
		  , TCDOB
		  , DischargeDate
		  , tcAgeDays
		  , lastdate
		FROM cteTotalCases
		WHERE DATEDIFF(DAY,tcdob,@StartDate) <= 729
			 and DATEDIFF(DAY, tcdob,lastdate) >= 365
	)
	,
	cteImmunizations
	AS
	(
	SELECT 
		tm.HVCaseFK, 
		tm.TCIDFK,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'DTaP' THEN 1 ELSE 0 END) AS DTAPCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'HIB' THEN 1 ELSE 0 END) AS HIBCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'PCV' THEN 1 ELSE 0 END) AS PCVCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'Polio' THEN 1 ELSE 0 END) AS PolioCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'MMR' THEN 1 ELSE 0 END) AS MMRCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'HEP-B' THEN 1 ELSE 0 END) AS HEPBCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'VZ' THEN 1 ELSE 0 END) AS VZCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'Flu' THEN 1 ELSE 0 END) AS FluCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'Roto' THEN 1 ELSE 0 END) AS RotoCount,
		SUM(CASE WHEN cmi.MedicalItemTitle = 'HEP-A' THEN 1 ELSE 0 END) AS HEPACount,
		COUNT(tm.TCMedicalItem) AS TotalImmunizations,
		SUM(CASE WHEN fr.ReviewedBy IS NOT NULL
				THEN 1
				WHEN fr.ReviewedBy IS NULL AND fro.FormReviewOptionsPK IS NULL
				THEN 1
				ELSE 0 
				END) AS FormReviewedCount
	FROM cteCohort 
	LEFT JOIN dbo.TCMedical tm WITH (NOLOCK) ON tm.HVCaseFK = cteCohort.HVCaseFK 
		AND tm.TCIDFK = cteCohort.TCIDPK
	INNER JOIN dbo.codeMedicalItem cmi ON tm.TCMedicalItem = cmi.MedicalItemCode
		AND cmi.MedicalItemGroup = 'Immunization'
	LEFT JOIN dbo.FormReview fr ON fr.HVCaseFK = tm.HVCaseFK 
		AND fr.FormType = 'TM'
		AND fr.FormFK = tm.TCMedicalPK
	LEFT JOIN dbo.FormReviewOptions fro ON fro.FormType = 'TM' 
		AND fro.ProgramFK = tm.ProgramFK 
		AND tm.TCItemDate BETWEEN fro.FormReviewStartDate AND ISNULL(fro.FormReviewEndDate, tm.TCItemDate)
	WHERE TCItemDate between TCDOB and dateadd(MONTH,12,TCDOB) 
	GROUP BY tm.HVCaseFK, tm.TCIDFK
				
	)
	,
	cteImmunizationCounts
	AS
	(
		SELECT 'HD1a' AS PTCode
			  , coh.HVCaseFK
			  , PC1ID
			  , OldID
			  , TCDOB
			  , PC1FullName
			  , CurrentWorkerFullName
			  , CurrentLevelName
			  , 'TC Medical' AS FormName
			  , NULL AS FormDate	
			  -- check that # of shots = # of forms reviewed
			  , CASE WHEN (imm.TotalImmunizations = imm.FormReviewedCount)
					THEN 1 
					ELSE 0 
					END AS FormReviewed				
			, 0 AS FormOutOfWindow -- not out of window
			, 0 AS FormMissing
			, CASE WHEN ((imm.DTAPCount >= 3) AND (imm.HIBCount >= 3) AND (imm.PCVCount >= 3) 
					AND (imm.PolioCount >= 2) AND (imm.MMRCount >= 0) AND (imm.HEPBCount >= 2)
					AND (imm.VZCount >= 0) AND (imm.FluCount >= 0) AND (imm.RotoCount >= 3) AND (imm.HEPACount >= 0))
					AND (imm.TotalImmunizations = imm.FormReviewedCount) THEN 1 
					ELSE 0 END AS FormMeetsTarget
			, CASE WHEN NOT ((imm.DTAPCount >= 3) AND (imm.HIBCount >= 3) AND (imm.PCVCount >= 3) 
					AND (imm.PolioCount >= 2) AND (imm.MMRCount >= 0) AND (imm.HEPBCount >= 2)
					AND (imm.VZCount >= 0) AND (imm.FluCount >= 0) AND (imm.RotoCount >= 3) AND (imm.HEPACount >= 0)) THEN 'Missing Shots or Not on Time' 
					WHEN (imm.TotalImmunizations <> imm.FormReviewedCount) THEN 'Immunization form(s) not reviewed'
					ELSE '' END AS NotMeetingReason
	 FROM cteCohort coh
	 LEFT JOIN cteImmunizations imm ON imm.HVCaseFK = coh.HVCaseFK AND coh.TCIDPK = imm.TCIDFK
	)

	SELECT * FROM cteImmunizationCounts 
	
	OPTION (OPTIMIZE FOR (@StartDate UNKNOWN, @EndDate UNKNOWN))
end
GO
