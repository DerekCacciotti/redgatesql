SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		jayrobot 
-- Create date: 09/21/18
-- Description:	This stored procedure obtains the last 20 Home Visit Logs
--				associated with the passed Worker FK.
-- =============================================
CREATE procedure [dbo].[spGetHomeVisitInfoForSupervision]
				(
					@ProgramFK int
					, @WorkerFK int
				)
as begin
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	set noCount on ;

	select top 20 hl.HVLogPK
		 , cp.PC1ID
		 , hl.FormComplete
		 , hl.FSWFK
		 , cp.CurrentFSWFK
		 , cp.CurrentLevelFK
		 , cl.LevelName as CurrentLevel
		 , hl.HVCaseFK
		 , hl.HVLogCreateDate
		 , hl.HVLogCreator
		 , hl.HVLogEditDate
		 , hl.HVLogEditor
		 , hl.HVSupervisorParticipated
		 , hl.NextScheduledVisit
		 , hl.NextVisitNotes
		 , hl.VisitLengthHour
		 , hl.VisitLengthMinute
		 , hl.VisitLocation
		 , hl.VisitStartTime
		 , hl.VisitType
		 , hl.VisitTypeComments
		 , case when hl.VisitType = '100000' then 'In-house' else 'Not' end +
			format(hl.VisitStartTime, 'mm/dd/yy hh:mi') + 
			-- char(16), hl.VisitStartTime, 'mm/dd/yy hh:mi') + 
			'Activities' as HVLogSummary
		 , hl.AdditionalComments
		 , hl.CAAdvocacy
		 , hl.CAChildSupport
		 , hl.CAComments
		 , hl.CAGoods
		 , hl.CAHousing
		 , hl.CALaborSupport
		 , hl.CALegal
		 , hl.CAOther
		 , hl.CAParentRights
		 , hl.CASpecify
		 , hl.CATranslation
		 , hl.CATransportation
		 , hl.CAVisitation
		 , hl.CDChildDevelopment
		 , hl.CDComments
		 , hl.CDFollowUpEIServices
		 , hl.CDOther
		 , hl.CDParentConcerned
		 , hl.CDSocialEmotionalDevelopment
		 , hl.CDSpecify
		 , hl.CDToys
		 , hl.CHEERSCues
		 , hl.CHEERSHolding
		 , hl.CHEERSExpression
		 , hl.CHEERSEmpathy
		 , hl.CHEERSRhythmReciprocity
		 , hl.CHEERSSmiles
		 , hl.CHEERSOverallStrengths
		 , hl.CHEERSAreasToFocus
		 , hl.CIComments
		 , hl.CIProblems
		 , hl.CIOther
		 , hl.CIOtherSpecify
		 , hl.Curriculum247Dads
		 , hl.CurriculumBoyz2Dads
		 , hl.CurriculumComments
		 , hl.CurriculumGreatBeginnings
		 , hl.CurriculumGrowingGreatKids
		 , hl.CurriculumHelpingBabiesLearn
		 , hl.CurriculumInsideOutDads
		 , hl.CurriculumMomGateway
		 , hl.CurriculumOtherSupplementalInformation
		 , hl.CurriculumOtherSupplementalInformationComments
		 , hl.CurriculumOther
		 , hl.CurriculumOtherSpecify
		 , hl.CurriculumParentsForLearning
		 , hl.CurriculumPartnersHealthyBaby
		 , hl.CurriculumPAT
		 , hl.CurriculumPATFocusFathers
		 , hl.CurriculumSanAngelo
		 , hl.FamilyMemberReads
		 , hl.FatherAdvocateFK
		 , hl.FatherAdvocateParticipated
		 , hl.FatherFigureParticipated
		 , hl.FFChildProtectiveIssues
		 , hl.FFComments
		 , hl.FFCommunication
		 , hl.FFDevelopmentalDisabilities
		 , hl.FFDomesticViolence
		 , hl.FFFamilyRelations
		 , hl.FFImmigration
		 , hl.FFMentalHealth
		 , hl.FFOther
		 , hl.FFSpecify
		 , hl.FFSubstanceAbuse
		 , hl.FGPComments
		 , hl.FGPDevelopActivities
		 , hl.FGPDiscuss
		 , hl.FGPGoalsCompleted
		 , hl.FGPNewGoal
		 , hl.FGPNoDiscussion
		 , hl.FGPProgress
		 , hl.FGPRevisions
		 , hl.GrandParentParticipated
		 , hl.HCBreastFeeding
		 , hl.HCChild
		 , hl.HCComments
		 , hl.HCDental
		 , hl.HCFamilyPlanning
		 , hl.HCFASD
		 , hl.HCFeeding
		 , hl.HCGeneral
		 , hl.HCLaborDelivery
		 , hl.HCMedicalAdvocacy
		 , hl.HCNutrition
		 , hl.HCOther
		 , hl.HCPrenatalCare
		 , hl.HCProviders
		 , hl.HCSafety
		 , hl.HCSexEducation
		 , hl.HCSIDS
		 , hl.HCSmoking
		 , hl.HCSpecify
		 , hl.HealthPC1AppearsHealthy
		 , hl.HealthPC1Asleep
		 , hl.HealthPC1CommentsGeneral
		 , hl.HealthPC1CommentsMedical
		 , hl.HealthPC1ERVisits
		 , hl.HealthPC1HealthConcern
		 , hl.HealthPC1MedicalPrenatalAppointments
		 , hl.HealthPC1PhysicalNeedsAppearUnmet
		 , hl.HealthPC1TiredIrritable
		 , hl.HealthPC1WithdrawnUnresponsive
		 , hl.HealthTCAppearsHealthy
		 , hl.HealthTCAsleep
		 , hl.HealthTCCommentsGeneral
		 , hl.HealthTCCommentsMedical
		 , hl.HealthTCERVisits
		 , hl.HealthTCHealthConcern
		 , hl.HealthTCImmunizations
		 , hl.HealthTCMedicalWellBabyAppointments
		 , hl.HealthTCPhysicalNeedsAppearUnmet
		 , hl.HealthTCTiredIrritable
		 , hl.HealthTCWithdrawnUnresponsive
		 , hl.HouseholdChangesComments
		 , hl.HouseholdChangesLeft
		 , hl.HouseholdChangesNew
		 , hl.NonPrimaryFSWParticipated
		 , hl.NonPrimaryFSWFK
		 , hl.OBPParticipated
		 , hl.OtherLocationSpecify
		 , hl.OtherParticipated
		 , hl.PAAssessmentIssues
		 , hl.PAComments
		 , hl.PAForms
		 , hl.PAGroups
		 , hl.PAIFSP
		 , hl.PAIntroduceProgram
		 , hl.PALevelChange
		 , hl.PAOther
		 , hl.PARecreation
		 , hl.PASpecify
		 , hl.PAVideo
		 , hl.ParentCompletedActivity
		 , hl.ParentObservationsDiscussed
		 , hl.ParticipatedSpecify
		 , hl.PC1Participated
		 , hl.PC2Participated
		 , hl.PCBasicNeeds
		 , hl.PCChildInteraction
		 , hl.PCChildManagement
		 , hl.PCComments
		 , hl.PCFeelings
		 , hl.PCOther
		 , hl.PCShakenBaby
		 , hl.PCShakenBabyVideo
		 , hl.PCSpecify
		 , hl.PCStress
		 , hl.PCTechnologyEffects
		 , hl.POCRAskedQuestions
		 , hl.POCRComments
		 , hl.POCRContributed
		 , hl.POCRInterested
		 , hl.POCRNotInterested
		 , hl.POCRWantedInformation
		 , hl.ProgramFK
		 , hl.PSCComments
		 , hl.PSCEmergingIssues
		 , hl.PSCInitialDiscussion
		 , hl.PSCImplement
		 , hl.PSCOngoingDiscussion
		 , hl.ReferralsComments
		 , hl.ReferralsFollowUp
		 , hl.ReferralsMade
		 , hl.ReviewAssessmentIssues
		 , hl.RSATP
		 , hl.RSATPComments
		 , hl.RSSATP
		 , hl.RSSATPComments
		 , hl.RSFFF
		 , hl.RSFFFComments
		 , hl.RSEW
		 , hl.RSEWComments
		 , hl.RSNormalizing
		 , hl.RSNormalizingComments
		 , hl.RSSFT
		 , hl.RSSFTComments
		 , hl.SiblingParticipated
		 , hl.SiblingsObservation
		 , hl.SSCalendar
		 , hl.SSChildCare
		 , hl.SSChildWelfareServices
		 , hl.SSComments
		 , hl.SSEducation
		 , hl.SSEmployment
		 , hl.SSHomeEnvironment
		 , hl.SSHousekeeping
		 , hl.SSJob
		 , hl.SSMoneyManagement
		 , hl.SSOther
		 , hl.SSProblemSolving
		 , hl.SSSpecify
		 , hl.SSTransportation
		 , hl.STASQ
		 , hl.STASQSE
		 , hl.STComments
		 , hl.STPHQ9
		 , hl.STPSI
		 , hl.STOther
		 , hl.SupervisorObservation
		 , hl.TCAlwaysOnBack
		 , hl.TCAlwaysWithoutSharing
		 , hl.TCParticipated
		 , hl.TotalPercentageSpent
		 , hl.TPComments
		 , hl.TPDateInitiated
		 , hl.TPInitiated
		 , hl.TPNotApplicable
		 , hl.TPOngoingDiscussion
		 , hl.TPParentDeclined
		 , hl.TPPlanFinalized
		 , hl.TPTransitionCompleted
		 , hl.UpcomingProgramEvents
	from HVLog hl
	inner join CaseProgram cp on cp.HVCaseFK = hl.HVCaseFK
	inner join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
	where hl.FSWFK = @WorkerFK
			and hl.ProgramFK = @ProgramFK
	order by hl.VisitStartTime desc
end ;
GO
