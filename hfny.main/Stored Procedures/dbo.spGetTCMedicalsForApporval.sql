SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetTCMedicalsForApporval] @date VARCHAR(120), @TCIDFK INT AS 

--SELECT * FROM dbo.FormReview WHERE FormDate = @date AND HVCaseFK = @HVCaseFK AND FormType = 'TM'


SELECT TCMedicalPK FROM TCMedical tm WHERE tm.TCItemDate = @date AND tm.TCIDFK = @TCIDFK
GO
