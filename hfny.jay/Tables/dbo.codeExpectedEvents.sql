CREATE TABLE [dbo].[codeExpectedEvents]
(
[codeExpectedEventsPK] [int] NOT NULL IDENTITY(1, 1),
[TCAgeInDays] [int] NULL,
[ASQInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowUpInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PSIInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadAssessmentInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LeadScreeningCount] [int] NULL,
[DTaPCount] [int] NULL,
[HIBCount] [int] NULL,
[MMRCount] [int] NULL,
[WellBabyVisitCount] [int] NULL,
[PolioCount] [int] NULL,
[HEPBCount] [int] NULL,
[VZCount] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[codeExpectedEvents] ADD CONSTRAINT [PK_codeExpectedEvents] PRIMARY KEY CLUSTERED  ([codeExpectedEventsPK]) ON [PRIMARY]
GO
