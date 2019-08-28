SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		William O'Brien
-- Create date: 06/18/18
-- Description:	returns distinct list of families who have a FU in period, value of HOMECompleted
-- Edit on 04/30/2019 by Ben Simmons: Fixed duplicating PC1IDs #6857
-- Edit on 98/28/2019 by Ben Simmons: Fixed transfer cases showing up
-- =============================================

CREATE PROC [dbo].[rspUseOfPCI_6-3D] 
	-- Add the parameters for the stored procedure here
	@ProgramFK	varchar(max) = NULL,
	@StartDate datetime,
	@EndDate datetime,
	@SiteFK int = null, 
    @CaseFiltersPositive varchar(200) = ''
as
begin
	  if @ProgramFK IS NULL
	begin
		select @ProgramFK = SUBSTRING((SELECT ',' + LTRIM(RTRIM(STR(HVProgramPK)))
											FROM HVProgram
											FOR XML PATH ('')),2,8000);
	end
	set @ProgramFK = REPLACE(@ProgramFK,'"','');

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null else @CaseFiltersPositive end;
		
	select distinct fu.hvcasefk, cp.PC1ID, ISNULL(fu.HOMECompleted, 0) AS HOMECompleted from HVCase hv
	inner join dbo.FollowUp fu on fu.HVCaseFK = hv.HVCasePK
	inner join dbo.CaseProgram cp on cp.HVCaseFK = hv.HVCasePK
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	inner join worker fsw ON cp.CurrentFSWFK = fsw.workerpk
	inner join workerprogram wp ON wp.workerfk = fsw.workerpk AND wp.ProgramFK=listitem
	inner join dbo.udfCaseFilters(@CaseFiltersPositive, '', @programfk) cf on cf.HVCaseFK = cp.HVCaseFK
	WHERE fu.FollowUpDate between @StartDate and @EndDate
	AND case when @SiteFK = 0 then 1
		 when wp.SiteFK = @SiteFK then 1
		 else 0
	end = 1
	AND (cp.DischargeDate IS NULL OR cp.DischargeDate >= fu.FollowUpDate)
	ORDER BY HOMECompleted DESC, cp.PC1ID ASC

END
GO
