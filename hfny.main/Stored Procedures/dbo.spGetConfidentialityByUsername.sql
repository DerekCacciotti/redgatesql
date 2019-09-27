SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spGetConfidentialityByUsername](@Username varchar(max))
AS
SET NOCOUNT ON;

SELECT top 1 *  
FROM Confidentiality c
WHERE c.Username = @username order by AcceptDate desc
GO
