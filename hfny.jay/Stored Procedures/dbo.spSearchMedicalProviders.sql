SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[spSearchMedicalProviders] (@MPFirstName VARCHAR(200) = NULL,
@MPLastName VARCHAR(200) = NULL, @MPAddress VARCHAR(40)= NULL, @MPCity VARCHAR(20)=NULL, @MPState VARCHAR(2)=NULL,
@MPZip VARCHAR(10)=NULL, @MPPhone VARCHAR(12)=NULL, @MPIsActive BIT = NULL,
@ProgramFK INT = NULL)

AS

SET NOCOUNT ON;

SELECT *,
	MPFirstName+' '+MPLastName as MPName	
	FROM listMedicalProvider mp
	WHERE (MPFirstName LIKE '%' + @MPFirstName + '%'
	OR MPLastName LIKE '%' + @MPLastName + '%'
	OR MPAddress  LIKE '%' + @MPAddress+ '%'
	OR MPCity     LIKE '%' + @MPCity + '%'
	OR MPState  = @MPState 
	OR MPZip LIKE @MPZip + '%'
	OR MPPhone LIKE '%' + @MPPhone + '%')
	AND MPIsActive = ISNULL(@MPIsActive,mp.MPIsActive)
	AND mp.ProgramFK = ISNULL(@ProgramFK, mp.ProgramFK)
	ORDER BY 
	CASE WHEN mp.MPFirstName LIKE '%'+ @MPFirstName + '%' THEN 1 ELSE 0 END +
	CASE WHEN mp.MPLastName LIKE '%' + @MPLastName + '%' THEN 1 ELSE 0 END +
	CASE WHEN mp.MPAddress LIKE '%'+ @MPAddress + '%' THEN 1 ELSE 0 END +
	CASE WHEN mp.MPCity LIKE '%' + @MPCity + '%' THEN 1 ELSE 0 END +
	CASE WHEN mp.MPState = @MPState THEN 1 ELSE 0 END +
	CASE WHEN mp.MPZip LIKE @MPZip + '%' THEN 1 ELSE 0 END +
	CASE WHEN mp.MPIsActive = @MPIsActive THEN 1 ELSE 0 END
	




GO
