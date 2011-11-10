SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeTCMedical](@codeTCMedicalPK int=NULL,
@TCMedicalCategory char(30)=NULL,
@TCMedicalReason char(3)=NULL,
@TCMedicalReasonText char(65)=NULL)
AS
UPDATE codeTCMedical
SET 
TCMedicalCategory = @TCMedicalCategory, 
TCMedicalReason = @TCMedicalReason, 
TCMedicalReasonText = @TCMedicalReasonText
WHERE codeTCMedicalPK = @codeTCMedicalPK
GO
