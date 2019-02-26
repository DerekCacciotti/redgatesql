SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddcodeMedicalItem](@MedicalItemCode char(2)=NULL,
@MedicalItemGroup varchar(20)=NULL,
@MedicalItemText char(60)=NULL,
@MedicalItemTitle char(20)=NULL,
@MedicalItemUsedWhere varchar(50)=NULL,
@NeedsDescription bit=NULL,
@Inactive bit=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) codeMedicalItemPK
FROM codeMedicalItem lastRow
WHERE 
@MedicalItemCode = lastRow.MedicalItemCode AND
@MedicalItemGroup = lastRow.MedicalItemGroup AND
@MedicalItemText = lastRow.MedicalItemText AND
@MedicalItemTitle = lastRow.MedicalItemTitle AND
@MedicalItemUsedWhere = lastRow.MedicalItemUsedWhere AND
@NeedsDescription = lastRow.NeedsDescription AND
@Inactive = lastRow.Inactive
ORDER BY codeMedicalItemPK DESC) 
BEGIN
INSERT INTO codeMedicalItem(
MedicalItemCode,
MedicalItemGroup,
MedicalItemText,
MedicalItemTitle,
MedicalItemUsedWhere,
NeedsDescription,
Inactive
)
VALUES(
@MedicalItemCode,
@MedicalItemGroup,
@MedicalItemText,
@MedicalItemTitle,
@MedicalItemUsedWhere,
@NeedsDescription,
@Inactive
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
