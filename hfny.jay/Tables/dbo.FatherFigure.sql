CREATE TABLE [dbo].[FatherFigure]
(
[FatherFigurePK] [int] NOT NULL IDENTITY(1, 1),
[DateAcceptService] [datetime] NOT NULL,
[DateInactive] [datetime] NULL,
[FatherAdvocateFK] [int] NOT NULL,
[FatherFigureCreateDate] [datetime] NOT NULL CONSTRAINT [DF_FatherFigure_FatherFigureCreateDate] DEFAULT (getdate()),
[FatherFigureCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FatherFigureEditDate] [datetime] NULL,
[FatherFigureEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[IsOBP] [bit] NOT NULL,
[IsPC2] [bit] NOT NULL,
[LiveInPC1Home] [bit] NOT NULL,
[MarriedToPC1] [bit] NOT NULL,
[PC2InPC1Home] [bit] NOT NULL,
[PCFK] [int] NOT NULL,
[ProgramFK] [int] NULL,
[RelationToTargetChild] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RelationToTargetChildOther] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_FatherFigureEditDate ON FatherFigure
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_FatherFigureEditDate] ON dbo.FatherFigure
For Update 
AS
Update FatherFigure Set FatherFigure.FatherFigureEditDate= getdate()
From [FatherFigure] INNER JOIN Inserted ON [FatherFigure].[FatherFigurePK]= Inserted.[FatherFigurePK]
GO
ALTER TABLE [dbo].[FatherFigure] ADD CONSTRAINT [PK__FatherFi__BBD3B90B6D0D32F4] PRIMARY KEY CLUSTERED  ([FatherFigurePK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FatherFigure] WITH NOCHECK ADD CONSTRAINT [FK_FatherFigure_FatherAdvocateFK] FOREIGN KEY ([FatherAdvocateFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[FatherFigure] WITH NOCHECK ADD CONSTRAINT [FK_FatherFigure_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[FatherFigure] WITH NOCHECK ADD CONSTRAINT [FK_FatherFigure_PCFK] FOREIGN KEY ([PCFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[FatherFigure] WITH NOCHECK ADD CONSTRAINT [FK_FatherFigure_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
