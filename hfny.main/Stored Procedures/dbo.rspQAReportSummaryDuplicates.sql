SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<jayrobot>
-- Create date: <June 22nd, 2018>
-- Description:	<This QA report gets you 'Summary for all QA Duplicate reports'>
-- rspQAReportSummaryOther 31				--- for summary report - location = 2

-- =============================================

CREATE procedure [dbo].[rspQAReportSummaryDuplicates] (@programfk varchar(max) = null)

as
	begin
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		set noCount on ;

		declare @tbl4QAReportSummaryDuplicates table (
												[SummaryId] int
												, [FormType] [varchar](30)
												, [SummaryTotal] [varchar](100)
												) ;

		insert into @tbl4QAReportSummaryDuplicates
			exec rspQAReport20 @programfk, 'summary', null ; --- for summary page

		select SummaryId
				, FormType
				, SummaryTotal
		from @tbl4QAReportSummaryDuplicates tqrsd ;
	end ;
GO
