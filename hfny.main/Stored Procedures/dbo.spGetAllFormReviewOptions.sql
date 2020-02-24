SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dorothy>
-- Create date: <5/5/10>
-- Editor: Ben Simmons
-- Edit date: 02/19/2020
-- Description:	<get all the forms that can be reviewed add a list of all matching records by ProgramFK
-- indicate the last record per formtype as it is the only one editable.>
-- =============================================
CREATE PROC [dbo].[spGetAllFormReviewOptions] @ProgramFK INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --To hold the state FK
    DECLARE @StateFK INT = NULL;

    --Get the state FK
    SELECT @StateFK = hp.StateFK
    FROM dbo.HVProgram hp
    WHERE hp.HVProgramPK = @ProgramFK;

    --To hold the latest review start dates
    DECLARE @tblLastReviewDate TABLE
    (
        LastDate DATETIME NOT NULL,
        FormType CHAR(2) NOT NULL
    );

    --Get the latest review start dates
    INSERT INTO @tblLastReviewDate
    (
        LastDate,
        FormType
    )
    SELECT MAX(fro.FormReviewStartDate) AS LastDate,
           fro.FormType
    FROM FormReviewOptions fro
    WHERE fro.ProgramFK = @ProgramFK
    GROUP BY fro.FormType;

    --Final select
    SELECT cf.codeFormAbbreviation,
           cf.codeFormName,
           fro.FormReviewOptionsPK,
           fro.FormReviewStartDate,
           fro.FormReviewEndDate,
           tlrd.LastDate
    FROM dbo.codeForm cf
        INNER JOIN dbo.codeFormAccess cfa
            ON cfa.codeFormFK = cf.codeFormPK
               AND cfa.StateFK = @StateFK
        LEFT JOIN dbo.FormReviewOptions fro
            ON cf.codeFormAbbreviation = fro.FormType
				AND fro.ProgramFK = @ProgramFK
        LEFT JOIN @tblLastReviewDate tlrd
            ON tlrd.FormType = fro.FormType
               AND fro.FormReviewStartDate = tlrd.LastDate
    WHERE cf.canBeReviewed = 1
		  AND cfa.AllowedAccess = 1
    ORDER BY cf.codeFormPK,
             fro.FormReviewStartDate;

END;
GO
