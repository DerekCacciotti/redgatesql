
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Chris Papas
-- Create date: 08/25/2010
-- Description:	Get everyone who's CASE has EVER been in the program for > 3 years (1095 days)
--				Moved from FamSys - 02/05/12 jrobohn
-- =============================================
CREATE procedure [dbo].[rsp3YearsInProgram]
(@programfk varchar(max)    = NULL,
 @SiteFK INT = 0)
as
begin

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set nocount on;

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+ltrim(rtrim(str(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end

	set @programfk = replace(@programfk,'"','')


	select
		  PC1ID
		 ,convert(VARCHAR(10), HVCase.IntakeDate, 101) [IntakeDate]
		 ,CASE when DischargeDate is null THEN  ''
		  ELSE  convert(VARCHAR(10), DischargeDate, 101) end [DISDate]
		 ,datediff(month,IntakeDate,CASE when DischargeDate is null THEN getdate()
		  ELSE DischargeDate end) [MonthsInProgram]
		 ,HVPROGRAM.ProgramName as Program_Name
		 ,case when DischargeDate is null THEN 'Case Open, ' + rtrim(LevelName)
		  else rtrim(codeDischarge.DischargeReason) END [Outcome]
		from
			CaseProgram
			INNER JOIN worker fsw ON CurrentFSWFK = fsw.workerpk
		    INNER JOIN workerprogram ON workerprogram.workerfk = fsw.workerpk
			left join HVCase on HVCase.HVCasePK = CaseProgram.HVCaseFK
			left join codeDischarge on CaseProgram.DischargeReason = codeDischarge.DischargeCode
			left join codeLevel on CaseProgram.CurrentLevelFK = codeLevel.codeLevelPK
			left join HVProgram on CaseProgram.ProgramFK = HVProgram.HVProgramPK
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where HVCase.IntakeDate is not null
			 and datediff(day,IntakeDate,CASE when DischargeDate is null THEN getdate()
			 else DischargeDate end) > 1095 
			 AND (CASE WHEN @SiteFK = 0 THEN 1 WHEN workerprogram.SiteFK = @SiteFK THEN 1 ELSE 0 END = 1)
end
GO
