
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[spGetAllMedicalProviders]
as
select *
from dbo.listMedicalProvider
WHERE mplastname != ''
order by mplastname
GO
