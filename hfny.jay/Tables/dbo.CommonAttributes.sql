CREATE TABLE [dbo].[CommonAttributes]
(
[CommonAttributesPK] [int] NOT NULL IDENTITY(1, 1),
[AvailableMonthlyIncome] [numeric] (4, 0) NULL,
[CommonAttributesCreateDate] [datetime] NOT NULL CONSTRAINT [DF_CommonAttributes_CommonAttributesCreateDate] DEFAULT (getdate()),
[CommonAttributesCreator] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CommonAttributesEditDate] [datetime] NULL,
[CommonAttributesEditor] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EducationalEnrollment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FormDate] [datetime] NOT NULL,
[FormFK] [int] NULL,
[FormInterval] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FormType] [char] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Gravida] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIFamilyChildHealthPlus] [bit] NULL,
[HighestGrade] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIMedicaidCaseNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIOther] [bit] NULL,
[HIOtherSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIPCAP] [bit] NULL,
[HIPCAPCaseNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HIPrivate] [bit] NULL,
[HIUnknown] [bit] NULL,
[HoursPerMonth] [int] NULL,
[HVCaseFK] [int] NOT NULL,
[IsCurrentlyEmployed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LanguageSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Looked4Employment] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MaritalStatus] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MonthlyIncomeUnknown] [bit] NULL,
[NumberEmployed] [int] NULL,
[NumberInHouse] [int] NULL,
[OBPInHome] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBPInvolvement] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[OBPInvolvementSpecify] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Parity] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBEmergencyAssistance] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBEmergencyAssistanceAmount] [numeric] (4, 0) NULL,
[PBEmergencyAssistanceAtFollowUp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBFoodStamps] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBFoodStampsAmount] [numeric] (4, 0) NULL,
[PBFoodStampsAtFollowUp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBSSI] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBSSIAmount] [numeric] (4, 0) NULL,
[PBSSIAtFollowUp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBTANF] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBTANFAmount] [numeric] (4, 0) NULL,
[PBTANFAtFollowUp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBWIC] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PBWICAmount] [numeric] (4, 0) NULL,
[PBWICAtFollowUp] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1HasMedicalProvider] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PC1MedicalFacilityFK] [int] NULL,
[PC1MedicalProviderFK] [int] NULL,
[PC1ReceivingMedicaid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCFK] [int] NULL,
[PreviouslyEmployed] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PrimaryLanguage] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramFK] [int] NOT NULL,
[ReceivingPreNatalCare] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ReceivingPublicBenefits] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SIDomesticViolence] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SICPSACS] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SIMentalHealth] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SISubstanceAbuse] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TANFServices] [bit] NULL,
[TANFServicesNo] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TANFServicesNoSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCHasMedicalProvider] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCHIFamilyChildHealthPlus] [bit] NULL,
[TCHIPrivateInsurance] [bit] NULL,
[TCHIOther] [bit] NULL,
[TCHIOtherSpecify] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TCHIUninsured] [bit] NULL,
[TCHIUnknown] [bit] NULL,
[TCMedicalFacilityFK] [int] NULL,
[TCMedicalProviderFK] [int] NULL,
[TCReceivingMedicaid] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TimeBreastFed] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WasBreastFed] [bit] NULL,
[WhyNotBreastFed] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[fr_Delete_TIPS] ON [dbo].[CommonAttributes] AFTER DELETE
AS
	DECLARE @oldFormType char(2), @PK int ;

		Select @oldFormType = FormType,
			   @PK = CommonAttributesPK			  
		From deleted 

	IF @oldFormType='TP'
			BEGIN
				EXEC spDeleteFormReview_Trigger @FormFK=@PK, @FormTypeValue='TP'
			END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE trigger [dbo].[fr_TIPS] ON [dbo].[CommonAttributes] AFTER INSERT
AS
	DECLARE @newFormType char(2), @PK int ;

		Select @newFormType = FormType,
			   @PK = CommonAttributesPK			  
		From inserted 

	IF @newFormType='TP'
			BEGIN
				EXEC spAddFormReview_userTrigger @FormFK=@PK, @FormTypeValue='TP'
			END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/18/2010
-- Description:	Updates FormReview Table with form date on Supervisor Review of Form
-- =============================================
CREATE TRIGGER [dbo].[fr_TIPS_Edit]
on [dbo].[CommonAttributes]
AFTER UPDATE

AS

Declare @PK int
Declare @UpdatedFormDate datetime 
Declare @FormTypeValue varchar(2)

select @PK = CommonAttributesPK FROM inserted
select @UpdatedFormDate = FormDate FROM inserted
set @FormTypeValue = 'TP'

BEGIN
	UPDATE FormReview
	SET 
	FormDate=@UpdatedFormDate
	WHERE FormFK=@PK 
	AND FormType=@FormTypeValue

END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- create trigger TR_CommonAttributesEditDate ON CommonAttributes
-- -- -- -- -- -- -- -- -- -- -- -- -- -- --
CREATE TRIGGER [dbo].[TR_CommonAttributesEditDate] ON [dbo].[CommonAttributes]
For Update 
AS
Update CommonAttributes Set CommonAttributes.CommonAttributesEditDate= getdate()
From [CommonAttributes] INNER JOIN Inserted ON [CommonAttributes].[CommonAttributesPK]= Inserted.[CommonAttributesPK]
GO
ALTER TABLE [dbo].[CommonAttributes] ADD CONSTRAINT [PK__CommonAt__14761E7359FA5E80] PRIMARY KEY CLUSTERED  ([CommonAttributesPK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CommonAttributes] WITH NOCHECK ADD CONSTRAINT [FK_CommonAttributes_HVCaseFK] FOREIGN KEY ([HVCaseFK]) REFERENCES [dbo].[HVCase] ([HVCasePK])
GO
ALTER TABLE [dbo].[CommonAttributes] WITH NOCHECK ADD CONSTRAINT [FK_CommonAttributes_PC1MedicalFacilityFK] FOREIGN KEY ([PC1MedicalFacilityFK]) REFERENCES [dbo].[listMedicalFacility] ([listMedicalFacilityPK])
GO
ALTER TABLE [dbo].[CommonAttributes] WITH NOCHECK ADD CONSTRAINT [FK_CommonAttributes_PC1MedicalProviderFK] FOREIGN KEY ([PC1MedicalProviderFK]) REFERENCES [dbo].[listMedicalProvider] ([listMedicalProviderPK])
GO
ALTER TABLE [dbo].[CommonAttributes] WITH NOCHECK ADD CONSTRAINT [FK_CommonAttributes_PCFK] FOREIGN KEY ([PCFK]) REFERENCES [dbo].[PC] ([PCPK])
GO
ALTER TABLE [dbo].[CommonAttributes] WITH NOCHECK ADD CONSTRAINT [FK_CommonAttributes_ProgramFK] FOREIGN KEY ([ProgramFK]) REFERENCES [dbo].[HVProgram] ([HVProgramPK])
GO
ALTER TABLE [dbo].[CommonAttributes] WITH NOCHECK ADD CONSTRAINT [FK_CommonAttributes_TCMedicalFacilityFK] FOREIGN KEY ([TCMedicalFacilityFK]) REFERENCES [dbo].[listMedicalFacility] ([listMedicalFacilityPK])
GO
ALTER TABLE [dbo].[CommonAttributes] WITH NOCHECK ADD CONSTRAINT [FK_CommonAttributes_TCMedicalProviderFK] FOREIGN KEY ([TCMedicalProviderFK]) REFERENCES [dbo].[listMedicalProvider] ([listMedicalProviderPK])
GO
