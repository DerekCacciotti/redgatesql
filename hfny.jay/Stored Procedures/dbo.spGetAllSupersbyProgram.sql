SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:    <Chris Papas
-- Create date: <02/09/2010>
-- Description: <Get list of all Supervisors by Program>
-- =============================================
CREATE PROCEDURE [dbo].[spGetAllSupersbyProgram] 
  @ProgramFK int = NULL,
  @Supervisor bit = false
AS
BEGIN
  -- SET NOCOUNT ON added to prevent extra result sets from
  -- interfering with SELECT statements.
  SET NOCOUNT ON;

    -- Insert statements for procedure here
  SELECT FirstName, LastName, WorkerPK 
  From Worker 
  LEFT JOIN WorkerProgram ON WorkerProgram.WorkerFK=Worker.WorkerPK
  WHERE WorkerProgram.Supervisor='TRUE' AND WorkerProgram.ProgramFK=@ProgramFK
END
GO
