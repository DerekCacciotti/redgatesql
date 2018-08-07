/*
This migration script replaces uncommitted changes made to these objects:
ASQSE
scoreASQSE
spGetOptionItem

Use this script to make necessary schema and data changes for these objects only. Schema changes to any other objects won't be deployed.

Schema changes and migration scripts are deployed in the order they're committed.

Migration scripts must not reference static data. When you deploy migration scripts alongside static data 
changes, the migration scripts will run first. This can cause the deployment to fail. 
Read more at https://documentation.red-gate.com/display/SOC6/Static+data+and+migrations.
*/

SET NUMERIC_ROUNDABORT OFF
GO
SET ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, ARITHABORT, QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
PRINT N'Altering [dbo].[scoreASQSE]'
GO
ALTER TABLE [dbo].[scoreASQSE] ALTER COLUMN [SocialEmotionalScore] [numeric] (3, 0) NOT NULL
GO
PRINT N'Retrofitting data for [dbo].[ASQSE]'
GO
update ASQSE
set ASQSETotalScore = ASQSETotalScore * 10
where ASQSETotalScore in (0.1, 0.5, 1.0, 3.0, 10.5)
PRINT N'Altering [dbo].[ASQSE]'
GO
alter TABLE [dbo].[ASQSE] ALTER COLUMN [ASQSETotalScore] [numeric] (3, 0) NOT NULL
GO
PRINT N'Altering [dbo].[spGetOptionItem]'
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 19,2009>
-- Description:	<Return the OptionValue for OptionItem, ProgramCode, for specify date>
-- mod: <Jay Robohn> <Aug 06,2018> <Make ProgramFK optional>
-- =============================================
ALTER procedure [dbo].[spGetOptionItem] (@OptionItem varchar(50)
								, @ProgramFK int
								, @CompareDate datetime
								, @OptionValue varchar(200) output)
as
	begin
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set noCount on ;

		-- Insert statements for procedure here
		select	@OptionValue = OptionValue
		from	AppOptions
		where	OptionItem = @OptionItem 
				and case when @ProgramFK is null then 1
						when ProgramFK = @ProgramFK then 1
						else 0
					end = 1
				and @CompareDate between OptionStart and isnull(OptionEnd, getdate())

	end ;

GO

