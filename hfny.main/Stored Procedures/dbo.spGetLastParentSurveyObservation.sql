SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 11/09/18
-- Description:	This stored procedure gets the information
--				about the last observed parent survey for the passed Worker FK.
-- =============================================
CREATE procedure [dbo].[spGetLastParentSurveyObservation] (@WorkerFK int, @ProgramFK int)
as begin

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on;

	with cteMain as 
	(	select	top 1 KempePK
					, HVCaseFK
					, KempeDate
					, case when MOBPresent = 1
							then 'MOB,'
							else ''
					end +
					case when FOBPresent = 1
							then 'FOB,'
							else ''
					end +
					case when MOBPartnerPresent = 1
							then 'pMOB,'
							else ''
					end +
					case when FOBPartnerPresent = 1
							then 'pFOB,'
							else ''
					end +
					case when GrandParentPresent = 1
							then 'GP,'
							else ''
					end +
					case when k.OtherPresent = 1
							then k.PresentSpecify + ','
							else ''
					end as ParentSurveyParticipants
					, 'Mother-' + rtrim(ltrim(MomScore)) + '/' +
						'Father-' + rtrim(ltrim(k.DadScore)) + '/' +
						'Partner-' + rtrim(ltrim(k.PartnerScore))
						as ParentSurveyScores
					, case when k.KempeResult = 1
							then 'Positive'
							else 'Negative'
						end as ParentSurveyResult
						
			from Kempe k
			where FAWFK = @WorkerFK
					and ProgramFK = @ProgramFK
					and SupervisorObservation = 1
			order by KempeDate desc
	)
			
	select	KempePK
			, PC1ID
			, convert(varchar(10), KempeDate, 101) as KempeDate
			, substring(ParentSurveyParticipants, 1, 
						(select top 1 
								len(ParentSurveyParticipants) - 1 
						from cteMain))
				as ParentSurveyParticipants
			, ParentSurveyScores
			, ParentSurveyResult
	from	cteMain m
	inner join CaseProgram cp on cp.HVCaseFK = m.HVCaseFK;
end ;
GO
