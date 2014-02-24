
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Chris Papas
-- Create date: 12/19/2012
-- Description:	Get the most recent medical provider/facility for PC/TC for use on CaseHome Page
-- =============================================
CREATE PROCEDURE [dbo].[spGetCaseHomeMedicalInfo](@HVCaseFK int)  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
	; WITH cteFUP AS (
		--Step 1 : Get most recent followup data
	 SELECT TOP 1 FormDate AS FUDate, FormInterval AS FUFormInterval, PC1HasMedicalProvider, @hvcasefk AS HVCaseFK
	 , CommonAttributesPK
	 FROM CommonAttributes ca 
	 WHERE HVCaseFK=@hvcasefk
	 AND FormType LIKE 'FU'
	 ORDER BY FormDate DESC, CommonAttributesPK DESC
	)

	, ctePC AS (
		--Step 2: Get most recent medical / facility data from PC
		 SELECT TOP 1 FormDate AS PCDate, FormType AS PCFormType, FormInterval AS PCFormInterval, PC1MedicalProviderFK, PC1MedicalFacilityFK
		 , @hvcasefk AS HVCaseFK
		 , CommonAttributesPK
		 FROM CommonAttributes ca 
		 WHERE HVCaseFK=@hvcasefk
		 AND FormType IN ('CH', 'IN')
		 ORDER BY FormDate DESC, CommonAttributesPK DESC
	 )
	
	, cteTCFU as (
		--Step 3 : Get TC Has medical provider
	 SELECT TOP 1 TCHasMedicalProvider, @hvcasefk AS HVCaseFK
	 , CommonAttributesPK
	 FROM CommonAttributes ca 
	 WHERE HVCaseFK=@hvcasefk
	 AND FormType = 'FU'
	 ORDER BY FormDate DESC, CommonAttributesPK DESC
	)
	 
	, cteTC AS (
		--Step 4: Get most recent medical / facility data from PC
		 SELECT TOP 1 FormDate AS TCDate, FormType AS TCFormType, FormInterval AS TCFormInterval, TCMedicalProviderFK, TCMedicalFacilityFK
		 , @hvcasefk AS HVCaseFK
		 , CommonAttributesPK
		 FROM CommonAttributes ca 
		 WHERE HVCaseFK=@hvcasefk
		 AND FormType IN ('CH', 'IN', 'TC')
		 ORDER BY FormDate DESC, CommonAttributesPK DESC
	 )
		

SELECT * FROM ctepc
LEFT JOIN cteTC ON cteTC.HVCaseFK = ctePC.HVCaseFK
left join cteTCFU on cteTCFU.HVCaseFK = cteTC.HVCaseFK
LEFT JOIN cteFUP ON cteFUP.HVCaseFK = ctePC.HVCaseFK

END
GO