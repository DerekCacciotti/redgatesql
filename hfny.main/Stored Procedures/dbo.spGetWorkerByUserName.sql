SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Rick Jordan
-- Create date: August 2017
-- Description:	spGetWorkerByUserName
-- =============================================
CREATE PROCEDURE [dbo].[spGetWorkerByUserName]
	@username VARCHAR(256),
	@programFK INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT w.*
	FROM dbo.Worker w
	INNER JOIN dbo.WorkerProgram wp ON wp.WorkerFK = w.WorkerPK
	WHERE w.UserName = @username AND wp.ProgramFK = @programFK
END
GO
