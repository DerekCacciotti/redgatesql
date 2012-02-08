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
(@programfk varchar(max)    = null)
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
		 ,HVCase.IntakeDate
		 ,case
			  when DischargeDate is null then
				  convert(varchar(10),getdate(),101)
			  else
				  DischargeDate
		  end as DISDate
		 ,datediff(month,IntakeDate,case
										when DischargeDate is null then
											getdate()
										else
											DischargeDate
									end) as MonthsInProgram
		 ,HVPROGRAM.ProgramName as Program_Name
		 ,'Outcome' = case
						  when DischargeDate is null then
							  convert(varchar(75),LevelName)
						  else
							  convert(varchar(75),codeDischarge.DischargeReason)
					  end
		from
			CaseProgram
			left join HVCase on HVCase.HVCasePK = CaseProgram.HVCaseFK
			left join codeDischarge on CaseProgram.DischargeReason = codeDischarge.DischargeCode
			left join codeLevel on CaseProgram.CurrentLevelFK = codeLevel.codeLevelPK
			left join HVProgram on CaseProgram.ProgramFK = HVProgram.HVProgramPK
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
		where HVCase.IntakeDate is not null
			 and datediff(day,IntakeDate,case
											 when DischargeDate is null then
												 getdate()
											 else
												 DischargeDate
										 end) > 1095
end
GO
