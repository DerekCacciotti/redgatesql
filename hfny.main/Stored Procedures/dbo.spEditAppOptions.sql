SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditAppOptions](@AppOptionsPK int=NULL,
@OptionDataType varchar(20)=NULL,
@OptionDescription varchar(250)=NULL,
@OptionEnd datetime=NULL,
@OptionItem varchar(50)=NULL,
@OptionStart datetime=NULL,
@OptionValue varchar(250)=NULL,
@ProgramFK int=NULL,
@AppName varchar(100)=NULL,
@OptionEditor varchar(max)=NULL)
AS
UPDATE AppOptions
SET 
OptionDataType = @OptionDataType, 
OptionDescription = @OptionDescription, 
OptionEnd = @OptionEnd, 
OptionItem = @OptionItem, 
OptionStart = @OptionStart, 
OptionValue = @OptionValue, 
ProgramFK = @ProgramFK, 
AppName = @AppName, 
OptionEditor = @OptionEditor
WHERE AppOptionsPK = @AppOptionsPK
GO
