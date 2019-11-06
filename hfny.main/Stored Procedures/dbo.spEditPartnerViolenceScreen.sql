SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spEditPartnerViolenceScreen](@PartnerViolenceScreenPK int=NULL,
@ProgramFK int=NULL,
@HVCaseFK int=NULL,
@PVSDate datetime=NULL,
@FeelSafeCurrentRelationship int=NULL,
@FeelSafeExplain varchar(max)=NULL,
@PreviousPartnerUnsafe int=NULL,
@PreviousPartnerExplain varchar(max)=NULL,
@HurtBySomeone int=NULL,
@HurtExplain varchar(max)=NULL,
@PVSEditor varchar(max)=NULL)
AS
UPDATE PartnerViolenceScreen
SET 
ProgramFK = @ProgramFK, 
HVCaseFK = @HVCaseFK, 
PVSDate = @PVSDate, 
FeelSafeCurrentRelationship = @FeelSafeCurrentRelationship, 
FeelSafeExplain = @FeelSafeExplain, 
PreviousPartnerUnsafe = @PreviousPartnerUnsafe, 
PreviousPartnerExplain = @PreviousPartnerExplain, 
HurtBySomeone = @HurtBySomeone, 
HurtExplain = @HurtExplain, 
PVSEditor = @PVSEditor
WHERE PartnerViolenceScreenPK = @PartnerViolenceScreenPK
GO
