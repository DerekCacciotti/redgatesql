SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddAppOptions](@AppName varchar(100)=NULL,
@OptionCreator varchar(max)=NULL,
@OptionDataType varchar(20)=NULL,
@OptionDescription varchar(250)=NULL,
@OptionEnd datetime=NULL,
@OptionItem varchar(50)=NULL,
@OptionStart datetime=NULL,
@OptionValue varchar(250)=NULL,
@ProgramFK int=NULL)
AS
INSERT INTO AppOptions(
AppName,
OptionCreator,
OptionDataType,
OptionDescription,
OptionEnd,
OptionItem,
OptionStart,
OptionValue,
ProgramFK
)
VALUES(
@AppName,
@OptionCreator,
@OptionDataType,
@OptionDescription,
@OptionEnd,
@OptionItem,
@OptionStart,
@OptionValue,
@ProgramFK
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
