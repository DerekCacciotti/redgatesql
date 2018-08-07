SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy Baum>
-- Create date: <June 19,2009>
-- Description:	<Return the OptionValue for OptionItem, ProgramCode, for specify date>
-- mod: <Jay Robohn> <Aug 06,2018> <Make ProgramFK optional>
-- =============================================
CREATE procedure [dbo].[spGetOptionItem] (@OptionItem varchar(50)
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
