SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAppOptions](@OptionDataType char(20)=NULL,
@OptionDescription char(250)=NULL,
@OptionEnd datetime=NULL,
@OptionItem char(50)=NULL,
@OptionStart datetime=NULL,
@OptionValue char(200)=NULL,
@ProgramFK int=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) AppOptionsPK
FROM AppOptions lastRow
WHERE 
@OptionDataType = lastRow.OptionDataType AND
@OptionDescription = lastRow.OptionDescription AND
@OptionEnd = lastRow.OptionEnd AND
@OptionItem = lastRow.OptionItem AND
@OptionStart = lastRow.OptionStart AND
@OptionValue = lastRow.OptionValue AND
@ProgramFK = lastRow.ProgramFK
ORDER BY AppOptionsPK DESC) 
BEGIN
INSERT INTO AppOptions(
OptionDataType,
OptionDescription,
OptionEnd,
OptionItem,
OptionStart,
OptionValue,
ProgramFK
)
VALUES(
@OptionDataType,
@OptionDescription,
@OptionEnd,
@OptionItem,
@OptionStart,
@OptionValue,
@ProgramFK
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
