
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: 2012-09-20
-- Description:	Gets a list of all forms to be reviewed that haven't been reviewed yet and
--				fall within the range of dates for that form's review option row.
-- exec spGetAllFormsForSupervisorReview 1,120,null
-- =============================================
CREATE procedure [dbo].[spGetAllFormsForSupervisorReview]
	(
	@ProgramFK int
	, @DaysToLoad int=30
	, @SupervisorFK int=null
	)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	with cteSupervisors	as 
	(
		select ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as WorkerName
				, TerminationDate
				, WorkerPK
				, 'SUP' as workertype
		from Worker w
		inner join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		where programfk = @ProgramFK 
				and current_timestamp between SupervisorStartDate AND isnull(SupervisorEndDate,dateadd(dd,1,datediff(dd,0,getdate())))

		--declare @Sups table
		--@Sups = spGetAllWorkersByProgram @ProgramFK = 1 
		--								, @EventDate = null
		--								, @WorkerType = 'SUP'
		--								, @AllWorkers = 0
	)
	--,
	--cteHomeVisitLogRow
	
	select FormReviewPK
		  ,PC1ID
		  ,codeFormName
		  ,convert(varchar(10),FormDate,101) as FormDate
		  ,FormFK
		  ,FormReviewCreateDate
		  ,FormReviewCreator
		  ,FormReviewEditDate
		  ,FormReviewEditor
		  ,fr.FormType
		  ,fr.HVCaseFK
		  ,fr.ProgramFK
		  ,ReviewDateTime
		  ,ReviewedBy
		  ,FormReviewStartDate
		  ,FormReviewEndDate
		  ,'CaseHome.aspx?pc1id='+PC1ID as CaseHomeLink
		  ,ltrim(rtrim(replace(replace(codeFormName,'-',''),' ','')))+'.aspx?pc1id='+PC1ID as FormLink
		  ,isnull(FormReviewEndDate, current_timestamp) as EffectiveEndDate
		  ,dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) as EffectiveStartDate
		  ,ltrim(rtrim(LastName)) + ', ' + ltrim(rtrim(FirstName)) as WorkerName
		  ,sup.WorkerName as SupervisorName
	from FormReview fr
	inner join FormReviewOptions fro on fro.FormType = fr.FormType and fro.ProgramFK = isnull(@ProgramFK,fro.ProgramFK)
	inner join codeForm f on codeFormAbbreviation = fr.FormType
	inner join CaseProgram cp on cp.HVCaseFK = fr.HVCaseFK
								and cp.ProgramFK = fr.ProgramFK
	inner join WorkerProgram wp on wp.WorkerFK = cp.CurrentFSWFK
	inner join Worker w on w.WorkerPK = wp.WorkerFK
	inner join cteSupervisors sup on wp.SupervisorFK = sup.WorkerPK
	where fr.ProgramFK = isnull(@ProgramFK, fr.ProgramFK)	
			and ReviewedBy is null
			and FormDate between FormReviewStartDate and isnull(FormReviewEndDate, current_timestamp)
			and FormDate between dateadd(day, @DaysToLoad*-1, isnull(FormReviewEndDate, current_timestamp)) and isnull(FormReviewEndDate, current_timestamp) 
	order by case when fr.FormType='SC' then 1 
				  when fr.FormType='PA' then 2
				  when fr.FormType='KE' then 3
				  when fr.FormType='PI' then 4
				  when fr.FormType='SR' then 5
				  when fr.FormType='ID' then 6
				  when fr.FormType='VL' then 7
				  when fr.FormType='IN' then 8
				  when fr.FormType='LV' then 9
				  when fr.FormType='TC' then 10
				  when fr.FormType='PM' then 11
				  when fr.FormType='DS' then 12
				  when fr.FormType='FF' then 13
				  when fr.FormType='TM' then 14
				  when fr.FormType='AQ' then 15
				  when fr.FormType='AS' then 16
				  when fr.FormType='PS' then 17
				  when fr.FormType='FU' then 18
				  when fr.FormType='SU' then 19
				  when fr.FormType='TR' then 20
				  when fr.FormType='GR' then 21
			end
			,PC1ID
			,FormDate
				  --when fr.FormType='AQ' then 15
				  --when fr.FormType='AS' then 16
				  --when fr.FormType='DS' then 12
				  --when fr.FormType='FF' then 13
				  --when fr.FormType='FU' then 18
				  --when fr.FormType='GR' then 21
				  --when fr.FormType='ID' then 6
				  --when fr.FormType='IN' then 8
				  --when fr.FormType='KE' then 3
				  --when fr.FormType='LV' then 9
				  --when fr.FormType='PA' then 2
				  --when fr.FormType='PI' then 4
				  --when fr.FormType='PM' then 11
				  --when fr.FormType='PS' then 17
				  --when fr.FormType='SC' then 1 
				  --when fr.FormType='SR' then 5
				  --when fr.FormType='SU' then 19
				  --when fr.FormType='TC' then 10
				  --when fr.FormType='TM' then 14
				  --when fr.FormType='TR' then 20
				  --when fr.FormType='VL' then 7	
END
GO
