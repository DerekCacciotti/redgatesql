SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spDelMIECHVEligible](@MIECHVEligiblePK int)

AS


DELETE 
FROM MIECHVEligible
WHERE MIECHVEligiblePK = @MIECHVEligiblePK
GO
