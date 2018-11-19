SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Bill O'Brien>
-- Create date: <Nov 13, 2018> 
-- =============================================
CREATE PROCEDURE  [dbo].[spGetAllMIECHVCases]
AS
BEGIN
  SET NOCOUNT ON;
  SELECT 
	MIECHVEligiblePK
	, PC1ID
	, HVCaseFK
	, ProgramFK
	, hv.LeadAgencyName
	, CaseStartDate
	, DischargeDate FROM dbo.MIECHVEligible me
	inner join hvprogram hv on me.ProgramFK = hv.HVProgramPK 
END
GO
