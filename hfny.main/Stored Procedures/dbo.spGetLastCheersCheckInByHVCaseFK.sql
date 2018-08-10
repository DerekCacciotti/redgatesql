SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--===========================================
-- Author: Ben Simmons
-- Create Date: 08/10/18
-- Description: This stored procedure retrieves the first CheersCheckIn
-- record from the database for a specific case.
--===========================================
CREATE PROCEDURE [dbo].[spGetLastCheersCheckInByHVCaseFK]
	@HVCaseFK INT,
	@ProgramFK INT

AS

SELECT TOP 1 *
FROM dbo.CheersCheckIn cci
WHERE cci.HVCaseFK = @HVCaseFK
AND cci.ProgramFK = @ProgramFK
ORDER BY cci.ObservationDate DESC

GO
