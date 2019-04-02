SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spGetTCMedicalPK] @TCItemdate VARCHAR(max), @itemcode CHAR(2), @TCIDFK int AS

SELECT TOP 1 TCMedicalPK FROM dbo.TCMedical WHERE TCItemDate = @TCItemdate AND TCMedicalItem = @itemcode AND TCIDFK = @TCIDFK
GO
