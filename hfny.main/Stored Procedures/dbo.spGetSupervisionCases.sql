SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 09/11/18
-- Description:	This stored procedure obtains the Supervision Cases 
--				associated with the passed FK.
-- =============================================
CREATE procedure [dbo].[spGetSupervisionCases] 
				(
					@SupervisionFK int
					, @ProgramFK int
				)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	with cteCases as
	(	
		select sc.SupervisionCasePK
			 , sc.HVCaseFK
			 , sc.ProgramFK
			 , sc.SupervisionFK
			 , sc.CaseComments
			 , left(sc.CaseComments, 30) + '...' as CaseCommentsExtract
			 , s.SupervisionDate
		from SupervisionCase sc
		inner join Supervision s on s.SupervisionPK = sc.SupervisionFK
		where sc.SupervisionFK = @SupervisionFK
				and sc.ProgramFK = @ProgramFK				
	)
	, ctePreviousCases as
	(
		select sc.HVCaseFK
				, sc.SupervisionCasePK
				, s.SupervisionDate
		from SupervisionCase sc
		inner join Supervision s on s.SupervisionPK = sc.SupervisionFK
		inner join cteCases c on c.HVCaseFK = sc.HVCaseFK
		where s.SupervisionDate < c.SupervisionDate
	)
	
	select c.SupervisionCasePK
		 , c.HVCaseFK
		 , c.ProgramFK
		 , c.SupervisionFK
		 , c.CaseComments
		 , c.CaseCommentsExtract
		 , pc.SupervisionDate as PreviousDiscussion
	from cteCases c
	left outer join ctePreviousCases pc on pc.HVCaseFK = c.HVCaseFK
	
end ;
GO
