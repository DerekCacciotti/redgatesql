CREATE TABLE [dbo].[codeTCMedical]
(
[codeTCMedicalPK] [int] NOT NULL IDENTITY(1, 1),
[TCMedicalCategory] [char] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCMedicalReason] [char] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TCMedicalReasonText] [char] (65) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeTCMedical] ADD CONSTRAINT [PK__codeTCMe__A11582CB52593CB8] PRIMARY KEY CLUSTERED  ([codeTCMedicalPK]) ON [PRIMARY]
GO
