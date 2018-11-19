SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Bill O'Brien>
-- Create date: <Nov 13, 2018> 
-- =============================================
CREATE PROCEDURE  [dbo].[spAddMIECHVEligibleByPC1ID](@PC1ID varchar(max))
AS
BEGIN
  SET NOCOUNT ON;
  insert into dbo.MIECHVEligible (
    PC1ID
	,HVCaseFK
	,ProgramFK
	,CaseStartDate
	,DischargeDate
	)
	select PC1ID
		, HVCaseFK
		, ProgramFK
		, CaseStartDate
		, DischargeDate
	from dbo.CaseProgram
	where PC1ID = @PC1ID
  
	SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
END
GO
