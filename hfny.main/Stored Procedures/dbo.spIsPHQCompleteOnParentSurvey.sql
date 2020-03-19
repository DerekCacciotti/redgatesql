SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[spIsPHQCompleteOnParentSurvey] @HVCaseFK int
as

select		top 1 case when p.PHQ9PK is not null then 1 else 0 end as PHQ9Complete
from		Kempe k
inner join	PHQ9 p on p.FormType = 'KE' and p.FormFK = k.KempePK
where		k.HVCaseFK = @HVCaseFK ;
GO
