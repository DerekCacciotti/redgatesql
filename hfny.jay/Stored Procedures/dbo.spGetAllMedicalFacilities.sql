SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[spGetAllMedicalFacilities]
@ProgramFK as int = NULL, @ActiveFilter as bit= NULL

as
select *
from dbo.listMedicalFacility
where ProgramFK=isnull(@ProgramFK, ProgramFK) and 
MFIsActive=isnull(@ActiveFilter,MFIsActive)
order by mfname

GO
