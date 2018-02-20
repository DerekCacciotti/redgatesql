SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Benjamin Simmons
-- Create date: 2/14/18>
-- Description:	Returns a bit value that is true if the PC1ID relates to
-- an accepted transfer case
-- =============================================
CREATE PROCEDURE [dbo].[spIsTransferredCase](@HVCaseFK INT, @PC1ID VARCHAR(23))  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @Count INT = 0, @IsTransferredCase BIT = 0
    -- Insert statements for procedure here

	DECLARE @TempTable TABLE 
	(
		CaseProgramPK INT NOT NULL,
		HVCaseFK INT NOT NULL,
		PC1ID VARCHAR(23) NOT NULL,
		TransferredToProgramFK INT NULL
	)

	--Get the relevant CaseProgram information
	INSERT INTO @TempTable
		SELECT CaseProgramPK, HVCaseFK, PC1ID, TransferredToProgramFK FROM CaseProgram
		WHERE HVCaseFK = @HVCaseFK

	--Get the count of CaseProgram rows that match the HVCaseFK and have been transferred
	SET @Count = (SELECT COUNT(CaseProgramPK)
	  FROM @TempTable)

	  --If the count is over 1, it may be a transfer case, otherwise it isn't
	IF(@Count > 1)
		--Check to see if the PC1ID belongs to an accepted transfer case
		SET @IsTransferredCase = (SELECT CASE WHEN TransferredtoProgramFK IS NULL THEN 1 ELSE 0  END FROM @TempTable WHERE PC1ID = @PC1ID)
	ELSE
        RETURN 0

		--Return a bit value indicating if the case is a transfer case
		RETURN @IsTransferredCase
	END

GO
