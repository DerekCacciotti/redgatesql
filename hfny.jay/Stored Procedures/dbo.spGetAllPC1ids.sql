SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Jay Robohn>
-- Create date: <Jan. 18, 2012>
-- Description: <copied frmo FamSys - see header below>
-- =============================================
-- =============================================
-- Author:    <Dorothy Baum>
-- Create date: <June 28, 2010>
-- Description: <list of all pc1ids per program>
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllPC1ids] 
  -- Add the parameters for the stored procedure here
  (@Programfks varchar(100), @includeClosed bit)
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

    -- Insert statements for procedure here
  if @includeClosed = 1
  select pc1id, hvcasefk, programfk
    from caseprogram
    where @ProgramFKs  Like('%,'+ Cast(ProgramFK as varchar(100))+',%')   
    order by pc1id
  else
  select pc1id, hvcasefk, programfk
    from caseprogram
    where dischargedate is null and 
    @ProgramFKs  Like('%,'+ Cast(ProgramFK as varchar(100))+',%')   
    order by pc1id
END

GO
