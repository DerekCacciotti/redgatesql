CREATE TABLE [dbo].[listContractManager]
(
[listContractManagerPK] [int] NOT NULL IDENTITY(1, 1),
[ContractManagerName] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[listContractManagerCreator] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[listContractManagerCreateDate] [datetime] NOT NULL,
[listContractManagerEditor] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ListContractManagerEditDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[listContractManager] ADD CONSTRAINT [PK_listContractManager] PRIMARY KEY CLUSTERED  ([listContractManagerPK]) ON [PRIMARY]
GO
