CREATE TABLE [dbo].[codeMedicalReasons]
(
[ReasonCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReasonDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReasonGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[codeMedicalReasonsPK] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeMedicalReasons] ADD CONSTRAINT [PK_codeMedicalReasons] PRIMARY KEY CLUSTERED  ([codeMedicalReasonsPK]) ON [PRIMARY]
GO
