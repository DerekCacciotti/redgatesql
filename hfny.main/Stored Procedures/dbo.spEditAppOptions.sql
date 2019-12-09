SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAppOptions](@AppOptionsPK int=NULL,
@AppName varchar(100)=NULL,
@OptionDataType varchar(20)=NULL,
@OptionDescription varchar(250)=NULL,
@OptionEditor varchar(max)=NULL,
@OptionEnd datetime=NULL,
@OptionItem varchar(50)=NULL,
@OptionStart datetime=NULL,
@OptionValue varchar(250)=NULL,
@ProgramFK int=NULL)
AS
UPDATE AppOptions
SET 
AppName = @AppName, 
OptionDataType = @OptionDataType, 
OptionDescription = @OptionDescription, 
OptionEditor = @OptionEditor, 
OptionEnd = @OptionEnd, 
OptionItem = @OptionItem, 
OptionStart = @OptionStart, 
OptionValue = @OptionValue, 
ProgramFK = @ProgramFK
WHERE AppOptionsPK = @AppOptionsPK
GO
