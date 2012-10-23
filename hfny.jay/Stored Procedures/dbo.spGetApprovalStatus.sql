
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[spGetApprovalStatus]
	(
	@FormType varchar(2),
	@FormFK int,
	@HVCaseFK int,
	@ProgramFK int,
	@isApproved bit OUTPUT
	)

AS
	SET NOCOUNT ON
	BEGIN TRANSACTION
	
	SET TRANSACTION ISOLATION LEVEL Read uncommitted;
	
	SELECT @isApproved = CASE WHEN ReviewedBy IS NOT NULL THEN 1 ELSE 0 END
	FROM FormReview
	INNER JOIN FormReviewOptions
	ON FormReviewOptions.programfk = FormReview.ProgramFK
	AND FormReviewOptions.FormType = FormReview.FormType 
	WHERE FormReview.FormType = @FormType
	AND FormFK = @FormFK
	AND HVCaseFK = @HVCaseFK
	AND FormReview.ProgramFK = @ProgramFK

	SET @isApproved = ISNULL(@isApproved, 0)
	
	
	RETURN

	COMMIT TRANSACTION
GO
