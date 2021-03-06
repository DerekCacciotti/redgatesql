SET IDENTITY_INSERT [dbo].[codeAuditC] ON
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (1, 'HowOften            ', 0, 'Never                    ', '01')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (2, 'HowOften            ', 1, 'Monthly or less          ', '02')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (3, 'HowOften            ', 2, '2-4 times a month        ', '03')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (4, 'HowOften            ', 3, '2-3 times a week         ', '04')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (5, 'HowOften            ', 4, '4 or more times a week   ', '05')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (6, 'DailyDrinks         ', 0, '1 or 2                   ', '01')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (7, 'DailyDrinks         ', 1, '3 or 4                   ', '02')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (8, 'DailyDrinks         ', 2, '5 or 6                   ', '03')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (9, 'DailyDrinks         ', 3, '7 to 9                   ', '04')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (10, 'DailyDrinks         ', 4, '10 or more               ', '05')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (11, 'MoreThanSix         ', 0, 'Never                    ', '01')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (12, 'MoreThanSix         ', 1, 'Less than monthly        ', '02')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (13, 'MoreThanSix         ', 2, 'Monthly                  ', '03')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (14, 'MoreThanSix         ', 3, 'Weekly                   ', '04')
INSERT INTO [dbo].[codeAuditC] ([codeAuditCPK], [codeGroup], [codeScore], [codeText], [codeValue]) VALUES (15, 'MoreThanSix         ', 4, 'Daily or almost daily    ', '05')
SET IDENTITY_INSERT [dbo].[codeAuditC] OFF
