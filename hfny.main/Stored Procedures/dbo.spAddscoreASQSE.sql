SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddscoreASQSE](@ASQSEVersion varchar(10)=NULL,
@MaximumASQSEScore numeric(3, 0)=NULL,
@SocialEmotionalScore numeric(3, 0)=NULL,
@TCAge char(4)=NULL)
AS
IF NOT EXISTS (SELECT TOP(1) scoreASQSEPK
FROM scoreASQSE lastRow
WHERE 
@ASQSEVersion = lastRow.ASQSEVersion AND
@MaximumASQSEScore = lastRow.MaximumASQSEScore AND
@SocialEmotionalScore = lastRow.SocialEmotionalScore AND
@TCAge = lastRow.TCAge
ORDER BY scoreASQSEPK DESC) 
BEGIN
INSERT INTO scoreASQSE(
ASQSEVersion,
MaximumASQSEScore,
SocialEmotionalScore,
TCAge
)
VALUES(
@ASQSEVersion,
@MaximumASQSEScore,
@SocialEmotionalScore,
@TCAge
)

END
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
