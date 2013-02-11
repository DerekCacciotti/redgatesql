SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: old
-- Description:	Moved from FamSys on Feb 11, 2013
-- =============================================
create procedure [dbo].[spSearchMedicalFacilities]
(
    @MFName     varchar(50)    = null,
    @MFAddress  varchar(40)    = null,
    @MFCity     varchar(20)    = null,
    @MFState    varchar(2)     = null,
    @MFZip      varchar(10)    = null,
    @MFPhone    varchar(12)    = null,
    @MFIsActive bit            = null,
    @ProgramFK  int            = null
)

as

	set nocount on;

	select *
		from listMedicalFacility mf
		where (MFName like '%'+@MFName+'%'
			 or MFAddress like '%'+@MFAddress+'%'
			 or MFCity like '%'+@MFCity+'%'
			 or MFState = @MFState
			 or MFZip like @MFZip+'%'
			 or MFPhone like '%'+@MFPhone+'%')
			 and MFIsActive = ISNULL(@MFIsActive,mf.MFIsActive)
			 and mf.ProgramFK = ISNULL(@ProgramFK,mf.ProgramFK)
		order by
				case when mf.MFName like '%'+@MFName+'%' then 1 else 0 end+
				case when mf.MFAddress like '%'+@MFAddress+'%' then 1 else 0 end+
				case when mf.MFCity like '%'+@MFCity+'%' then 1 else 0 end+
				case when mf.MFState = @MFState then 1 else 0 end+
				case when mf.MFZip like @MFZip+'%' then 1 else 0 end+
				case when mf.MFIsActive = @MFIsActive then 1 else 0 end
GO
