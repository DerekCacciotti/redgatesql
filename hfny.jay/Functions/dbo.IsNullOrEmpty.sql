SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		IsNullOrEmpty
-- Create date: July 20, 2012
-- Description:	Mimics the VB/.NET function of the same name
-- =============================================
CREATE FUNCTION [dbo].[IsNullOrEmpty]	
(
	-- Add the parameters for the function here
	@VarString varchar(max)
)
returns bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @ReturnValue Bit

	-- Add the T-SQL statements to compute the return value here
	set @ReturnValue = Case when @VarString is null or @VarString = '' then 1 else 0 end

	-- Return the result of the function
	RETURN @ReturnValue

END
GO
