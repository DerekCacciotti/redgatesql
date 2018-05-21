CREATE TABLE [dbo].[CaseProgram]
(
[CaseProgramPK] [int] NOT NULL IDENTITY(1, 1),
[CaseProgramCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CaseProgram_CaseProgramCreateDate] DEFAULT (getdate()),
[CaseProgramCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CaseProgramEditDate] [datetime] NULL,
[CaseProgramEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CaseStartDate] [datetime] NOT NULL,
[CurrentFAFK] [int] NULL,
[CurrentFAWFK] [int] NULL,
[CurrentFSWFK] [int] NULL,
[CurrentLevelDate] [datetime] NOT NULL,
[CurrentLevelFK] [int] NOT NULL,
[DischargeDate] [datetime] NULL,
[DischargeReason] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DischargeReasonSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField1] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField2] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField3] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField4] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField5] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField6] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField7] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField8] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExtraField9] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HVCaseFK] [int] NOT NULL,
[HVCaseFK_old] [int] NOT NULL,
[OldID] [char] (23) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1ID] [char] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProgramFK] [int] NOT NULL,
[TransferredtoProgram] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TransferredtoProgramFK] [int] NULL,
[TransferredStatus] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[fr_discharge] on [dbo].[CaseProgram] AFTER UPDATE
AS

	DECLARE @oldDischargeDate datetime, 
		    @newDischargeDate datetime,
			@newLevelFK int, @PK int;

	SELECT @oldDischargeDate=d.DischargeDate,
		   @newDischargeDate=i.DischargeDate,
		   @newLevelFK = i.currentLevelFK,
		   @PK = i.CaseProgramPK
    FROM inserted i 
	Inner Join deleted d on i.CaseProgramPK = d.CaseProgramPK

	IF (@oldDischargeDate IS NULL and @newDischargeDate IS NOT NULL and @newLevelFK > 9)
		Begin
			EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='DS';
		End
	ELSE IF (@oldDischargeDate IS NOT NULL and @newDischargeDAte IS NULL and @newLevelFK > 9)
		Begin
			EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='DS';
		End
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CaseProgramEditDate ON CaseProgram
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CaseProgramEditDate] ON [dbo].[CaseProgram]
For Update 
AS
Update CaseProgram Set CaseProgram.CaseProgramEditDate= getdate()
From [CaseProgram] INNER JOIN Inserted ON [CaseProgram].[CaseProgramPK]= Inserted.[CaseProgramPK]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot
-- Create date: 2018-05-03
-- Description:	Writes a row to the CaseProgramDeleted 
--				when a Caseprogram, row was deleted	
-- =============================================
create trigger [dbo].[tr_delete_caseprogram]
   on [dbo].[CaseProgram]
   after delete 
as
begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for trigger here
	Declare @PC1ID varchar(13)

	set @PC1ID = (SELECT PC1ID from deleted)

	begin

		INSERT INTO	CaseProgramDeleted
			(
				CaseProgramCreateDate
			, CaseProgramCreator
			, CaseProgramEditDate
			, CaseProgramEditor
			, CaseStartDate
			, CurrentFAFK
			, CurrentFAWFK
			, CurrentFSWFK
			, CurrentLevelDate
			, CurrentLevelFK
			, DischargeDate
			, DischargeReason
			, DischargeReasonSpecify
			, ExtraField1
			, ExtraField2
			, ExtraField3
			, ExtraField4
			, ExtraField5
			, ExtraField6
			, ExtraField7
			, ExtraField8
			, ExtraField9
			, HVCaseFK
			, HVCaseFK_old
			, OldID
			, PC1ID
			, ProgramFK
			, TransferredtoProgram
			, TransferredtoProgramFK
			, TransferredStatus
			)
			select Deleted.CaseProgramCreateDate
			, Deleted.CaseProgramCreator
			, Deleted.CaseProgramEditDate
			, Deleted.CaseProgramEditor
			, Deleted.CaseStartDate
			, Deleted.CurrentFAFK
			, Deleted.CurrentFAWFK
			, Deleted.CurrentFSWFK
			, Deleted.CurrentLevelDate
			, Deleted.CurrentLevelFK
			, Deleted.DischargeDate
			, Deleted.DischargeReason
			, Deleted.DischargeReasonSpecify
			, Deleted.ExtraField1
			, Deleted.ExtraField2
			, Deleted.ExtraField3
			, Deleted.ExtraField4
			, Deleted.ExtraField5
			, Deleted.ExtraField6
			, Deleted.ExtraField7
			, Deleted.ExtraField8
			, Deleted.ExtraField9
			, Deleted.HVCaseFK
			, Deleted.HVCaseFK_old
			, Deleted.OldID
			, Deleted.PC1ID
			, Deleted.ProgramFK
			, Deleted.TransferredtoProgram
			, Deleted.TransferredtoProgramFK
			, Deleted.TransferredStatus
		from Deleted WHERE Deleted.PC1ID = @PC1ID
	end
end
GO
ALTER TABLE [dbo].[CaseProgram] ADD CONSTRAINT [PK_CaseProgram] PRIMARY KEY CLUSTERED  ([CaseProgramPK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_CurrentFAFK] ON [dbo].[CaseProgram] ([CurrentFAFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_CurrentFAWFK] ON [dbo].[CaseProgram] ([CurrentFAWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_CurrentFSWFK] ON [dbo].[CaseProgram] ([CurrentFSWFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_CurrentLevelFK] ON [dbo].[CaseProgram] ([CurrentLevelFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_DischargeDate] ON [dbo].[CaseProgram] ([DischargeDate]) INCLUDE ([HVCaseFK], [ProgramFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_HVCaseFK] ON [dbo].[CaseProgram] ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [nci_wi_CaseProgram_10DDC32CB7FBC483EA60D57385553998] ON [dbo].[CaseProgram] ([PC1ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_ProgramFK] ON [dbo].[CaseProgram] ([ProgramFK], [DischargeDate]) INCLUDE ([HVCaseFK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_FK_CaseProgram_TransferredtoProgramFK] ON [dbo].[CaseProgram] ([TransferredtoProgramFK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CaseProgram] WITH NOCHECK ADD CONSTRAINT [FK_CaseProgram_CurrentFAFK] FOREIGN KEY ([CurrentFAFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[CaseProgram] WITH NOCHECK ADD CONSTRAINT [FK_CaseProgram_CurrentFAWFK] FOREIGN KEY ([CurrentFAWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[CaseProgram] WITH NOCHECK ADD CONSTRAINT [FK_CaseProgram_CurrentFSWFK] FOREIGN KEY ([CurrentFSWFK]) REFERENCES [dbo].[Worker] ([WorkerPK])
GO
ALTER TABLE [dbo].[CaseProgram] WITH NOCHECK ADD CONSTRAINT [FK_CaseProgram_CurrentLevelFK] FOREIGN KEY ([CurrentLevelFK]) REFERENCES [dbo].[codeLevel] ([codeLevelPK])
GO
ALTER TABLE [dbo].[CaseProgram] WITH NOCHECK ADD CONSTRAINT [FK_CaseProgram_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CaseProgram] WITH NOCHECK ADD CONSTRAINT [FK_CaseProgram_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[CaseProgram] WITH NOCHECK ADD CONSTRAINT [FK_CaseProgram_TransferredtoProgramFK] FOREIGN KEY ([TransferredtoProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
EXEC sp_addextendedproperty N'MS_Description', N'Do not accept SVN changes', 'SCHEMA', N'dbo', 'TABLE', N'CaseProgram', 'COLUMN', N'CaseProgramPK'
GO
