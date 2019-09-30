SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddConfidentiality](@Username varchar(max)=NULL,
@AcceptDate datetime=NULL)
AS
INSERT INTO Confidentiality(
Username,
AcceptDate
)
VALUES(
@Username,
@AcceptDate
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
