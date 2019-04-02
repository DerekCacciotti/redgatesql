SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spDoesTCMedicalExist] @TCItemdate VARCHAR(max), @itemcode CHAR(2), @TCIDFK int AS

SELECT TOP 1 * FROM dbo.TCMedical WHERE TCItemDate = @TCItemdate AND TCMedicalItem = @itemcode AND TCIDFK = @TCIDFK
GO
