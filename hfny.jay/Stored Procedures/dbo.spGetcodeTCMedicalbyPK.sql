SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetcodeTCMedicalbyPK]

(@codeTCMedicalPK int)
AS
SET NOCOUNT ON;

SELECT * 
FROM codeTCMedical
WHERE codeTCMedicalPK = @codeTCMedicalPK
GO
