
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE procedure [dbo].[spGetAllMedicalFacilities]
@ProgramFK as int = NULL, @ActiveFilter as bit= NULL

as
select *
from dbo.listMedicalFacility
where ProgramFK=isnull(@ProgramFK, ProgramFK) and 
MFIsActive=isnull(@ActiveFilter,MFIsActive)
AND  MFName != ''
order by mfname

GO
