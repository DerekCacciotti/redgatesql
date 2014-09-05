
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 05/22/2010
-- Description:	Home Visit Log Activity Summary Other Specified
-- =============================================
CREATE procedure [dbo].[rspHomeVisitLogActivitySummaryOtherSpecified] 
	-- Add the parameters for the stored procedure here
	(@programfk int = null
   , @StartDt datetime
   , @EndDt datetime
   , @workerfk int = null
   , @pc1id varchar(13) = ''
   , @showWorkerDetail char(1) = 'N'
   , @showPC1IDDetail char(1) = 'N'
	)
as --DECLARE	@programfk INT = 1
--DECLARE @StartDt DATETIME = '04/01/2012'
--DECLARE @EndDt DATETIME = '09/30/2013'
--DECLARE @workerfk INT = NULL
--DECLARE @pc1id VARCHAR(13) = ''
--DECLARE @showWorkerDetail CHAR(1) = 'N'
--DECLARE @showPC1IDDetail CHAR(1) = 'N'


	select --DISTINCT
			case when @showWorkerDetail = 'N' then 0
				 else a.FSWFK
			end FSWFK
		  , case when @showPC1IDDetail = 'N' then ''
				 else cp.PC1ID
			end PC1ID
--, CurriculumOtherSpecify
		  , case when count(*) > 1 then rtrim(CurriculumOtherSpecify) + ' (' + convert(varchar(5), count(*)) + ')'
				 else rtrim(CurriculumOtherSpecify)
			end CurriculumOtherSpecify
	from	HVLog as a
	inner join worker fsw on a.FSWFK = fsw.workerpk
	inner join CaseProgram cp on cp.HVCaseFK = a.HVCaseFK
	inner join HVCase as h on h.HVCasePK = a.HVCaseFK
	where	a.ProgramFK = @programfk
			and cast(VisitStartTime as date) between @StartDt and @EndDt
			and a.FSWFK = isnull(@workerfk, a.FSWFK)
			and cp.PC1ID = case	when @pc1ID = '' then cp.PC1ID
								else @pc1ID
						   end
			and substring(VisitType, 4, 1) <> '1'
			and (CurriculumOtherSpecify is not null
				 and len(rtrim(CurriculumOtherSpecify)) > 0
				)
	group by FSWFK
		  , PC1ID
		  , rtrim(CurriculumOtherSpecify)
	order by FSWFK
		  , PC1ID
		  , CurriculumOtherSpecify
GO
