SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetTCMedicalsForApporval] @date VARCHAR(120), @HVCaseFK int AS

SELECT * FROM dbo.FormReview WHERE FormDate = @date AND HVCaseFK = @HVCaseFK AND FormType = 'TM'

GO
