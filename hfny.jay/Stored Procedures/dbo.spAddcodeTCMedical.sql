SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeTCMedical](@TCMedicalCategory char(30)=NULL,
@TCMedicalReason char(3)=NULL,
@TCMedicalReasonText char(65)=NULL)
AS
INSERT INTO codeTCMedical(
TCMedicalCategory,
TCMedicalReason,
TCMedicalReasonText
)
VALUES(
@TCMedicalCategory,
@TCMedicalReason,
@TCMedicalReasonText
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
