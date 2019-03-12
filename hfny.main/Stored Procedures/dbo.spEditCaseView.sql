SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditCaseView](@CaseViewPK int=NULL,
@PC1ID nchar(13)=NULL,
@UserName varchar(50)=NULL,
@ViewDate datetime=NULL)
AS
UPDATE CaseView
SET 
PC1ID = @PC1ID, 
UserName = @UserName, 
ViewDate = @ViewDate
WHERE CaseViewPK = @CaseViewPK
GO
