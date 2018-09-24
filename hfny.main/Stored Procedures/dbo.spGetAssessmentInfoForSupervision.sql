SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 09/21/18
-- Description:	This stored procedure obtains the last 10 Parent Survey (Kempe) forms
--				associated with the passed Worker FK.
-- =============================================
CREATE procedure [dbo].[spGetAssessmentInfoForSupervision]
				(
					@ProgramFK int
					, @WorkerFK int
				)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	select top 10 k.KempePK
		 , cp.PC1ID
		 , cp.CurrentLevelFK
		 , cl.LevelName as CurrentLevel
		 , k.HVCaseFK
		 , k.FAWFK
		 , k.DadScore
		 , k.KempeCreateDate
		 , k.KempeCreator
		 , k.KempeDate
		 , k.KempeEditDate
		 , k.KempeEditor
		 , k.KempeResult
		 , k.MomScore
		 , k.PartnerScore
		 , k.SupervisorObservation
		 , a.AttachmentPK
		 , a.AttachmentFilePath
		 , convert(char(10), k.KempeDate, 1) + 
		   'Mom: ' + convert(char(3), k.MomScore) + 
		   'Dad: ' + convert(char(3), k.DadScore) + 
		   'Partner: ' + convert(char(3), k.PartnerScore) + 
		   'Result: ' + case when k.KempeResult = 1 then 'Positive' else 'Negative' end
			as AssessmentSummary
		 , case when a.AttachmentPK is not null then 'Yes' else 'No' end as Attachment
	from Kempe k
	inner join CaseProgram cp on cp.HVCaseFK = k.HVCaseFK
	inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
	left outer join Attachment a on a.HVCaseFK = cp.HVCaseFK 
									and a.FormFK = k.KempePK 
									and a.FormType = 'KE'
	where k.FAWFK = @WorkerFK
			and k.ProgramFK = @ProgramFK
	order by k.KempeDate desc
end ;
GO
