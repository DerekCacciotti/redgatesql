SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 11/09/18
-- Description:	This stored procedure gets the information
--				about the last observed home visit for the passed Worker FK.
-- =============================================
CREATE procedure [dbo].[spGetLastHomeVisitObservation] (@WorkerFK int, @ProgramFK int)
as begin

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on;

	with cteMain as 
	(	select	top 1 HVLogPK
					, HVCaseFK
					, VisitStartTime
					, case when PC1Participated = 1
							then 'PC1,'
							else ''
					end +
					case when PC2Participated = 1
							then 'PC2,'
							else ''
					end +
					case when OBPParticipated = 1
							then 'OBP,'
							else ''
					end +
					case when FatherFigureParticipated = 1
							then 'FF,'
							else ''
					end +
					case when TCParticipated = 1
							then 'TC,'
							else ''
					end +
					case when GrandParentParticipated = 1
							then 'GP,'
							else ''
					end +
					case when SiblingParticipated = 1
							then 'Sibling(s),'
							else ''
					end +
					case when HVSupervisorParticipated = 1
							then 'Sup,'
							else ''
					end +
					case when NonPrimaryFSWParticipated = 1
							then 'FSS,'
							else ''
					end +
					case when FatherAdvocateParticipated = 1
							then 'FA,'
							else ''
					end + 
					case when OtherParticipated = 1 and ParticipatedSpecify is not null
							then ParticipatedSpecify + ','
							else ''
					end as VisitParticipants
					, case when substring(VisitType, 1, 1) = '1'
							then 'PC1 Home,'
							else ''
					end + 
					case when substring(VisitType, 2, 1) = '1'
							then 'FF/OBP Home,'
							else ''
					end + 
					case when substring(VisitType, 3, 1) = '1'
							then 'Other (TC Resides),'
							else ''
					end + 
					case when substring(VisitType, 5, 1) = '1'
							then 'Outside Home - ' +
									case when substring(VisitLocation, 1, 1) = '1'
											then 'Medical office,'
											else ''
									end + 
									case when substring(VisitLocation, 2, 1) = '1'
											then 'Other provider,'
											else ''
									end + 
									case when substring(VisitLocation, 3, 1) = '1'
											then 'HV office,'
											else ''
									end + 
									case when substring(VisitLocation, 4, 1) = '1'
											then 'Hospital,'
											else ''
									end + 
									case when substring(VisitLocation, 5, 1) = '1'
											then rtrim(OtherLocationSpecify) + ','
											else ''
									end
							else ''
					end + 
					case when substring(VisitType, 6, 1) = '1'
							then 'Group visit,'
							else ''
					end as VisitLocation
				from	HVLog hl 
				where		hl.FSWFK = @WorkerFK 
							and hl.ProgramFK = @ProgramFK
							and hl.SupervisorObservation = 1 
				order by hl.HVLogCreateDate desc
	)
			
		select		HVLogPK
					, PC1ID
					, convert(char(10), VisitStartTime, 101) + ' ' + 
						convert(char(5), 
									case when datepart(hour, VisitStartTime) <= 11
											then VisitStartTime
											else dateadd(hour, -12, VisitStartTime)
									end
								, 108) +
						case when datepart(hour, VisitStartTime) <= 11
								then ' AM'
								else ' PM'
						end 
						as VisitStartTime
					, substring(VisitLocation, 1, len(VisitLocation) - 1) 
						as VisitLocation
					, substring(VisitParticipants, 1, len(VisitParticipants) - 1) 
						as VisitParticipants
		from		cteMain m
		inner join CaseProgram cp on cp.HVCaseFK = m.HVCaseFK;
end ;
GO
