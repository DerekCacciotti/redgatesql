SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditcodeMedicalItem](@codeMedicalItemPK int=NULL,
@MedicalItemCode char(2)=NULL,
@MedicalItemGroup varchar(20)=NULL,
@MedicalItemText char(60)=NULL,
@MedicalItemTitle char(20)=NULL,
@MedicalItemUsedWhere varchar(50)=NULL)
AS
UPDATE codeMedicalItem
SET 
MedicalItemCode = @MedicalItemCode, 
MedicalItemGroup = @MedicalItemGroup, 
MedicalItemText = @MedicalItemText, 
MedicalItemTitle = @MedicalItemTitle, 
MedicalItemUsedWhere = @MedicalItemUsedWhere
WHERE codeMedicalItemPK = @codeMedicalItemPK
GO
