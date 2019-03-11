CREATE TABLE [dbo].[CheersCheckIn]
(
[CheersCheckInPK] [int] NOT NULL IDENTITY(1, 1),
[AverageCuesScore] [numeric] (5, 2) NOT NULL,
[AverageEmpathyScore] [numeric] (5, 2) NOT NULL,
[AverageExpressionScore] [numeric] (5, 2) NOT NULL,
[AverageHoldingScore] [numeric] (5, 2) NOT NULL,
[AverageRhythmScore] [numeric] (5, 2) NOT NULL,
[AverageSmilesScore] [numeric] (5, 2) NOT NULL,
[CheersCheckInCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CheersCheckIn_CheersCheckInCreateDate] DEFAULT (getdate()),
[CheersCheckInCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CheersCheckInEditDate] [datetime] NULL,
[CheersCheckInEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Cues1Score] [int] NOT NULL,
[Cues2Score] [int] NOT NULL,
[Empathy1Score] [int] NOT NULL,
[Empathy2Score] [int] NOT NULL,
[Empathy3Score] [int] NOT NULL,
[Expression1Score] [int] NOT NULL,
[Expression2Score] [int] NOT NULL,
[Expression3Score] [int] NOT NULL,
[FSWFK] [int] NOT NULL,
[Holding1Score] [int] NOT NULL,
[Holding2Score] [int] NOT NULL,
[Holding3Score] [int] NOT NULL,
[HVCaseFK] [int] NOT NULL,
[ObservationDate] [datetime] NOT NULL,
[ProgramFK] [int] NOT NULL,
[Rhythm1Score] [int] NOT NULL,
[Rhythm2Score] [int] NOT NULL,
[Smiles1Score] [int] NOT NULL,
[Smiles2Score] [int] NOT NULL,
[Smiles3Score] [int] NOT NULL,
[TotalScore] [numeric] (5, 2) NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/09/18
-- Description:	Creates FormReview row when form is added to database
-- =============================================
CREATE	TRIGGER [dbo].[fr_CheersCheckIn]
ON [dbo].[CheersCheckIn]
AFTER INSERT

AS

DECLARE @PK INT;

SET @PK =
(
	SELECT Inserted.CheersCheckInPK FROM inserted
);

BEGIN
	EXEC spAddFormReview_userTRIGGER @FormFK = @PK, @FormTypeValue = 'CC';
END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/09/18
-- Description:	Updates FormReview Table with form date on submission of form
-- =============================================
CREATE TRIGGER [dbo].[fr_CheersCheckIn_Edit]
ON [dbo].[CheersCheckIn]
AFTER UPDATE

AS

DECLARE @PK INT;
DECLARE @UpdatedFormDate DATETIME;
DECLARE @FormTypeValue CHAR(2);

SELECT	@PK = Inserted.CheersCheckInPK
FROM	inserted;
SELECT	@UpdatedFormDate = Inserted.ObservationDate
FROM	inserted;
SET @FormTypeValue = 'CC';

BEGIN
	UPDATE	FormReview
	SET FormDate = @UpdatedFormDate
	WHERE FormFK = @PK
		AND FormType = @FormTypeValue;

END;
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ben Simmons
-- Create date: 08/09/18
-- Description:	Updates the edit date on form edit
-- =============================================
CREATE TRIGGER [dbo].[TR_CheersCheckInEditDate]
ON [dbo].[CheersCheckIn]
FOR UPDATE
AS
UPDATE	dbo.CheersCheckIn
SET CheersCheckInEditDate = GETDATE()
FROM	dbo.CheersCheckIn cci
	INNER JOIN Inserted i
		ON cci.CheersCheckInPK = i.CheersCheckInPK;
GO
ALTER TABLE [dbo].[CheersCheckIn] ADD CONSTRAINT [PK_CheersCheckIn] PRIMARY KEY CLUSTERED  ([CheersCheckInPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CheersCheckIn] ADD CONSTRAINT [FK_CheersCheckIn_HVCase] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CheersCheckIn] ADD CONSTRAINT [FK_CheersCheckIn_HVProgram] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
