SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelcodeTCMedical](@codeTCMedicalPK int)

AS


DELETE 
FROM codeTCMedical
WHERE codeTCMedicalPK = @codeTCMedicalPK
GO
