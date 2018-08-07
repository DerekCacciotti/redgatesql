CREATE TABLE [dbo].[CheersCheckIn]
(
[CheersCheckInPK] [int] NOT NULL IDENTITY(1, 1),
[AvereageCuesScore] [numeric] (5, 2) NOT NULL,
[AverageEmpathyScore] [numeric] (5, 2) NOT NULL,
[AverageExpressionScore] [numeric] (5, 2) NOT NULL,
[AverageHoldingScore] [numeric] (5, 2) NOT NULL,
[AverageRhythmScore] [numeric] (5, 2) NOT NULL,
[AverageSmilesScore] [numeric] (5, 2) NOT NULL,
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
ALTER TABLE [dbo].[CheersCheckIn] ADD CONSTRAINT [PK_CheersCheckIn] PRIMARY KEY CLUSTERED  ([CheersCheckInPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CheersCheckIn] ADD CONSTRAINT [FK_CheersCheckIn_HVCase] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CheersCheckIn] ADD CONSTRAINT [FK_CheersCheckIn_HVProgram] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
