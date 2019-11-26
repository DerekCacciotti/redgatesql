SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spAddPartnerViolenceScreen](@ProgramFK int=NULL,
@HVCaseFK int=NULL,
@PVSDate datetime=NULL,
@FeelSafeCurrentRelationship int=NULL,
@FeelSafeExplain varchar(max)=NULL,
@PreviousPartnerUnsafe int=NULL,
@PreviousPartnerExplain varchar(max)=NULL,
@HurtBySomeone int=NULL,
@HurtExplain varchar(max)=NULL,
@PVSCreator varchar(max)=NULL)
AS
INSERT INTO PartnerViolenceScreen(
ProgramFK,
HVCaseFK,
PVSDate,
FeelSafeCurrentRelationship,
FeelSafeExplain,
PreviousPartnerUnsafe,
PreviousPartnerExplain,
HurtBySomeone,
HurtExplain,
PVSCreator
)
VALUES(
@ProgramFK,
@HVCaseFK,
@PVSDate,
@FeelSafeCurrentRelationship,
@FeelSafeExplain,
@PreviousPartnerUnsafe,
@PreviousPartnerExplain,
@HurtBySomeone,
@HurtExplain,
@PVSCreator
)

SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]
GO
