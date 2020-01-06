SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[spReassignAttachmentCategories] @categorytobereplaced INT, @newvalue INT AS

UPDATE AttachmentCategory SET AttachmentCategoryFK = @newvalue WHERE AttachmentCategoryFK = @categorytobereplaced
GO
