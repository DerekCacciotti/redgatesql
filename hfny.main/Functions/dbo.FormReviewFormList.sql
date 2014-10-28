SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- select * from FormReviewedTableList('SC', 1) frtl
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/09/12
-- Description:	Get all Form Reviews by programfk and formtype.
--				This was created because the utility to check formreview goes item by item, and in a large
--				table (like the 1000+ in TrainingHome) it was taking 5 minutes or more to go through the whole list
-- =============================================
create function [dbo].[FormReviewFormList] (@HVCaseFK int)

returns @results table (FormType char(2)
						, FormFK int
						, IsApproved varchar(1)
					   )
as
	begin
		insert @results
				(FormType, FormFK, IsApproved)
			select	fr.FormType
					  , FormFK
					  , case when fr.ReviewedBy is null
						 then case when fro.FormReviewStartDate <= fr.FormDate
								   then case when fro.FormReviewEndDate is null then '0' --reviews have started for training
											 when fro.FormReviewEndDate > fr.FormDate then '0' --reviews have started for training
											 else ''
										end  --review end date is greater than the training date for this training
								   when fro.FormReviewStartDate > fr.FormDate then ''  --reviews have NOT started for training
								   when fro.FormReviewStartDate is null then ''
							  end--reviewing training NOT set
						 else case when fro.FormReviewStartDate <= fr.FormDate then '1' --approved and reviews have started for training
						--don't check end date for an approved training, as the user may wonder why an approval is not approved
								   when fro.FormReviewStartDate > fr.FormDate then ''  --approved but someone changed review date into future
								   when fro.FormReviewStartDate is null then ''
							  end --approved but somehow reviewing training NOT set
					end as 'IsApproved'
				from FormReview fr
				inner join FormReviewOptions fro on fro.ProgramFK = fr.ProgramFK
				where fr.HVCaseFK = @HVCaseFK
		return
	end
GO
