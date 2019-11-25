SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAppOptions](@OptionDataType varchar(20)=NULL,
@OptionDescription varchar(250)=NULL,
@OptionEnd datetime=NULL,
@OptionItem varchar(50)=NULL,
@OptionStart datetime=NULL,
@OptionValue varchar(250)=NULL,
@ProgramFK int=NULL,
@AppName varchar(100)=NULL)
AS
INSERT INTO AppOptions(
OptionDataType,
OptionDescription,
OptionEnd,
OptionItem,
OptionStart,
OptionValue,
ProgramFK,
AppName
)
VALUES(
@OptionDataType,
@OptionDescription,
@OptionEnd,
@OptionItem,
@OptionStart,
@OptionValue,
@ProgramFK,
@AppName
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
