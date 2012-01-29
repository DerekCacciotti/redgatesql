SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 25, 2012>
-- Description:	<Face Sheet report>
-- =============================================
create procedure [dbo].[rspFaceSheet](@programfk    varchar(max)    = null,
                                                        @pc1id		char(13)
                                                        )

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end;

	with cteMain
	as
	(select CaseStartDate
           ,CurrentFAFK
           ,CurrentFAWFK
           ,CurrentFSWFK
           ,CurrentLevelDate
           ,CurrentLevelFK
           ,DischargeDate
           ,DischargeReason
           ,DischargeReasonSpecify
           ,HVCaseFK
           ,PC1ID
           ,ProgramFK
		 from CaseProgram
		 where PC1ID = isnull(@pc1id,PC1ID)
	)
	,
	cteLevelChanges
	as
	(select casefk
		   ,count(casefk)-1 as LevelChanges
		 from cteHVRecords
		 group by casefk
	)
	,
	cteSummary
	as
	(select distinct workername
					,workerfk
					,pc1id
					,casecount
					,sum(visitlengthminute) over (partition by pc1wrkfk) as 'Minutes'
					,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
					,min(startdate) over (partition by pc1wrkfk) as 'startdate'
					,max(enddate) over (partition by pc1wrkfk) as 'enddate'
					,levelname
					,max(levelstart) over (partition by pc1wrkfk) as 'levelstart'
					,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
					,sum(inhomevisitcount) over (partition by pc1wrkfk) as inhomevisitcount
					,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
					,max(dischargedate) over (partition by pc1wrkfk) as 'dischargedate'
					,LevelChanges
		 from cteMain
			 inner join cteLevelChanges on cteLevelChanges.casefk = cteHVRecords.casefk
	)
	select *
		from cteMain
		order by WorkerName
				,pc1id

end
GO
