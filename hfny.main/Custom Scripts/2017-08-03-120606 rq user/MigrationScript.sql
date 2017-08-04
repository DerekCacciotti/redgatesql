/*
exec migration-script-for-new-hvlog
This migration script replaces uncommitted changes made to these objects:
HVLogOld
HVLog
__Temp_RetentionRate_Report
rspActiveEnrolledCaseList
rspAggregateCounts
rspCapacityBuilding
rspClosedEnrolledCaseList
rspHFAHomeVisitCompletionRate_Detail
rspHFAHomeVisitCompletionRate_Summary
rspHomeVisitLogSummaryQuarterly
rspNYSFSWHomeVisitRecord_Detail
rspNYSFSWHomeVisitRecord_Summary
rspProgramInformationFor8Quarters
rspQAReport14
rspQAReport19
rspRetentionRatePercentage
rspRetentionRates_fill_cache
spAddHVLogOld
spAddHVLog
spDelHVLogOld
spEditHVLogOld
spEditHVLog
Use this script to make necessary schema and data changes for these objects only. Schema changes to any other objects won't be deployed.

Schema changes and migration scripts are deployed in the order they're committed.
Migration scripts must not reference static data. When you deploy migration scripts alongside static data 
changes, the migration scripts will run first. This can cause the deployment to fail. 
Read more at https://documentation.red-gate.com/display/SOC5/Static+data+and+migrations.
*/

set numeric_roundabort off;
go
set ansi_padding, ansi_warnings, concat_null_yields_null, arithabort, quoted_identifier, ansi_nulls on;
go
print N'Dropping extended properties';
go
exec sp_dropextendedproperty N'MS_Description'
						   , 'SCHEMA'
						   , N'dbo'
						   , 'TABLE'
						   , N'HVLog'
						   , 'COLUMN'
						   , N'HVLogPK';
go
print N'Dropping foreign keys from [dbo].[HVLog]';
go
alter table [dbo].[HVLog]
drop constraint [FK_HVLog_FSWFK];
go
alter table [dbo].[HVLog]
drop constraint [FK_HVLog_HVCaseFK];
go
alter table [dbo].[HVLog]
drop constraint [FK_HVLog_ProgramFK];
go
print N'Dropping constraints from [dbo].[HVLog]';
go
alter table [dbo].[HVLog]
drop constraint [PK__HVLog__ED876F581332DBDC];
alter table [dbo].[HVLog]
drop constraint [DF_HVLog_HVLogCreateDate];
go
print N'Dropping index [IX_FK_HVLog_FSWFK] from [dbo].[HVLog]';
go
drop index [IX_FK_HVLog_FSWFK]
	on [dbo].[HVLog];
go
print N'Dropping index [IX_FK_HVLog_HVCaseFK] from [dbo].[HVLog]';
go
drop index [IX_FK_HVLog_HVCaseFK]
	on [dbo].[HVLog];
go
print N'Dropping index [HVCase_ProgramFK] from [dbo].[HVLog]';
go
drop index [HVCase_ProgramFK]
	on [dbo].[HVLog];
go
print N'Dropping index [IX_FK_HVLog_ProgramFK] from [dbo].[HVLog]';
go
drop index [IX_FK_HVLog_ProgramFK]
	on [dbo].[HVLog];
go
print N'Dropping index [IX_HVLog_VisitStartTime] from [dbo].[HVLog]';
go
drop index [IX_HVLog_VisitStartTime]
	on [dbo].[HVLog];
go
print N'Dropping index [IX_HVLog_VisitType] from [dbo].[HVLog]';
go
drop index [IX_HVLog_VisitType]
	on [dbo].[HVLog];
go
print N'Dropping trigger [dbo].[fr_delete_hvlog] from [dbo].[HVLog]';
go
drop trigger [dbo].[fr_delete_hvlog];
go
print N'Dropping trigger [dbo].[fr_hvlog] from [dbo].[HVLog]';
go
drop trigger [dbo].[fr_hvlog];
go
print N'Dropping trigger [dbo].[fr_HVLog_Edit] from [dbo].[HVLog]';
go
drop trigger [dbo].[fr_HVLog_Edit];
go
print N'Dropping trigger [dbo].[TR_HVLogEditDate] from [dbo].[HVLog]';
go
drop trigger [dbo].[TR_HVLogEditDate];
go
print N'Creating [dbo].[HVLogOld]';
go
create table [dbo].[HVLogOld] (	  [HVLogOldPK] [int] not null identity(1, 1)
								, [CAAdvocacy] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CAChildSupport] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CAGoods] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CAHousing] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CALaborSupport] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CALegal] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CAOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CAParentRights] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CASpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [CATranslation] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CATransportation] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CAVisitation] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CDChildDevelopment] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CDOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CDParentConcerned] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CDSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [CDToys] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CIProblems] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CIOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [CIOtherSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [Curriculum247Dads] [bit] null
								, [CurriculumBoyz2Dads] [bit] null
								, [CurriculumGrowingGreatKids] [bit] null
								, [CurriculumHelpingBabiesLearn] [bit] null
								, [CurriculumInsideOutDads] [bit] null
								, [CurriculumMomGateway] [bit] null
								, [CurriculumOther] [bit] null
								, [CurriculumOtherSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [CurriculumParentsForLearning] [bit] null
								, [CurriculumPartnersHealthyBaby] [bit] null
								, [CurriculumPAT] [bit] null
								, [CurriculumPATFocusFathers] [bit] null
								, [CurriculumSanAngelo] [bit] null
								, [FamilyMemberReads] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [FatherAdvocateFK] [int] null
								, [FatherAdvocateParticipated] [bit] null
								, [FatherFigureParticipated] [bit] null
								, [FFCommunication] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [FFDomesticViolence] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [FFFamilyRelations] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [FFMentalHealth] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [FFOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [FFSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [FFSubstanceAbuse] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [FSWFK] [int] null
								, [GrandParentParticipated] [bit] null
								, [HCBreastFeeding] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCChild] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCDental] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCFamilyPlanning] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCFASD] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCFeeding] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCGeneral] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCMedicalAdvocacy] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCNutrition] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCPrenatalCare] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCProviders] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCSafety] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCSexEducation] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCSIDS] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCSmoking] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [HCSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [HVCaseFK] [int] not null
								, [HVLogCreateDate] [datetime] not null
									  constraint [DF_HVLogOld_HVLogCreateDate]
									  default (getdate())
								, [HVLogCreator] [char](10) collate SQL_Latin1_General_CP1_CI_AS not null
								, [HVLogEditDate] [datetime] null
								, [HVLogEditor] [char](10) collate SQL_Latin1_General_CP1_CI_AS null
								, [HVSupervisorParticipated] [bit] null
								, [NonPrimaryFSWParticipated] [bit] null
								, [NonPrimaryFSWFK] [int] null
								, [OBPParticipated] [bit] null
								, [OtherLocationSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [OtherParticipated] [bit] null
								, [PAAssessmentIssues] [bit] null
								, [PAForms] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PAGroups] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PAIFSP] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PAOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PARecreation] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PASpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [PAVideo] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [ParentCompletedActivity] [bit] null
								, [ParentObservationsDiscussed] [bit] null
								, [ParticipatedSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [PC1Participated] [bit] null
								, [PC2Participated] [bit] null
								, [PCBasicNeeds] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCChildInteraction] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCChildManagement] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCFeelings] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCShakenBaby] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCShakenBabyVideo] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [PCStress] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [ProgramFK] [int] null
								, [ReviewAssessmentIssues] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [SiblingParticipated] [bit] null
								, [SSCalendar] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSChildCare] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSEducation] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSEmployment] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSHousekeeping] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSJob] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSMoneyManagement] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSOther] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSProblemSolving] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
								, [SSTransportation] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
								, [SupervisorObservation] [bit] null
								, [TCAlwaysOnBack] [bit] null
								, [TCAlwaysWithoutSharing] [bit] null
								, [TCParticipated] [bit] null
								, [TotalPercentageSpent] [int] null
								, [UpcomingProgramEvents] [bit] null
								, [VisitLengthHour] [int] not null
								, [VisitLengthMinute] [int] not null
								, [VisitLocation] [char](5) collate SQL_Latin1_General_CP1_CI_AS not null
								, [VisitStartTime] [datetime] not null
								, [VisitType] [char](4) collate SQL_Latin1_General_CP1_CI_AS not null
							  ) on [PRIMARY];
go
print N'Creating primary key [PK__HVLogOld__ED876F581332DBDC] on [dbo].[HVLogOld]';
go
alter table [dbo].[HVLogOld]
add constraint [PK__HVLogOld__ED876F581332DBDC]
	primary key clustered ([HVLogOldPK]) on [PRIMARY];
go
set identity_insert HVLogOld on;
go
print N'Migrating data to HVLogOld table';
go
insert into HVLogOld (	 HVLogOldPK
					   , CAAdvocacy
					   , CAChildSupport
					   , CAGoods
					   , CAHousing
					   , CALaborSupport
					   , CALegal
					   , CAOther
					   , CAParentRights
					   , CASpecify
					   , CATranslation
					   , CATransportation
					   , CAVisitation
					   , CDChildDevelopment
					   , CDOther
					   , CDParentConcerned
					   , CDSpecify
					   , CDToys
					   , CIProblems
					   , CIOther
					   , CIOtherSpecify
					   , Curriculum247Dads
					   , CurriculumBoyz2Dads
					   , CurriculumGrowingGreatKids
					   , CurriculumHelpingBabiesLearn
					   , CurriculumInsideOutDads
					   , CurriculumMomGateway
					   , CurriculumOther
					   , CurriculumOtherSpecify
					   , CurriculumParentsForLearning
					   , CurriculumPartnersHealthyBaby
					   , CurriculumPAT
					   , CurriculumPATFocusFathers
					   , CurriculumSanAngelo
					   , FamilyMemberReads
					   , FatherAdvocateFK
					   , FatherAdvocateParticipated
					   , FatherFigureParticipated
					   , FFCommunication
					   , FFDomesticViolence
					   , FFFamilyRelations
					   , FFMentalHealth
					   , FFOther
					   , FFSpecify
					   , FFSubstanceAbuse
					   , FSWFK
					   , GrandParentParticipated
					   , HCBreastFeeding
					   , HCChild
					   , HCDental
					   , HCFamilyPlanning
					   , HCFASD
					   , HCFeeding
					   , HCGeneral
					   , HCMedicalAdvocacy
					   , HCNutrition
					   , HCOther
					   , HCPrenatalCare
					   , HCProviders
					   , HCSafety
					   , HCSexEducation
					   , HCSIDS
					   , HCSmoking
					   , HCSpecify
					   , HVCaseFK
					   , HVLogCreateDate
					   , HVLogCreator
					   , HVLogEditDate
					   , HVLogEditor
					   , HVSupervisorParticipated
					   , NonPrimaryFSWParticipated
					   , NonPrimaryFSWFK
					   , OBPParticipated
					   , OtherLocationSpecify
					   , OtherParticipated
					   , PAAssessmentIssues
					   , PAForms
					   , PAGroups
					   , PAIFSP
					   , PAOther
					   , PARecreation
					   , PASpecify
					   , PAVideo
					   , ParentCompletedActivity
					   , ParentObservationsDiscussed
					   , ParticipatedSpecify
					   , PC1Participated
					   , PC2Participated
					   , PCBasicNeeds
					   , PCChildInteraction
					   , PCChildManagement
					   , PCFeelings
					   , PCOther
					   , PCShakenBaby
					   , PCShakenBabyVideo
					   , PCSpecify
					   , PCStress
					   , ProgramFK
					   , ReviewAssessmentIssues
					   , SiblingParticipated
					   , SSCalendar
					   , SSChildCare
					   , SSEducation
					   , SSEmployment
					   , SSHousekeeping
					   , SSJob
					   , SSMoneyManagement
					   , SSOther
					   , SSProblemSolving
					   , SSSpecify
					   , SSTransportation
					   , SupervisorObservation
					   , TCAlwaysOnBack
					   , TCAlwaysWithoutSharing
					   , TCParticipated
					   , TotalPercentageSpent
					   , UpcomingProgramEvents
					   , VisitLengthHour
					   , VisitLengthMinute
					   , VisitLocation
					   , VisitStartTime
					   , VisitType
					 )
			select HVLogPK
				 , CAAdvocacy
				 , CAChildSupport
				 , CAGoods
				 , CAHousing
				 , CALaborSupport
				 , CALegal
				 , CAOther
				 , CAParentRights
				 , CASpecify
				 , CATranslation
				 , CATransportation
				 , CAVisitation
				 , CDChildDevelopment
				 , CDOther
				 , CDParentConcerned
				 , CDSpecify
				 , CDToys
				 , CIProblems
				 , CIOther
				 , CIOtherSpecify
				 , Curriculum247Dads
				 , CurriculumBoyz2Dads
				 , CurriculumGrowingGreatKids
				 , CurriculumHelpingBabiesLearn
				 , CurriculumInsideOutDads
				 , CurriculumMomGateway
				 , CurriculumOther
				 , CurriculumOtherSpecify
				 , CurriculumParentsForLearning
				 , CurriculumPartnersHealthyBaby
				 , CurriculumPAT
				 , CurriculumPATFocusFathers
				 , CurriculumSanAngelo
				 , FamilyMemberReads
				 , FatherAdvocateFK
				 , FatherAdvocateParticipated
				 , FatherFigureParticipated
				 , FFCommunication
				 , FFDomesticViolence
				 , FFFamilyRelations
				 , FFMentalHealth
				 , FFOther
				 , FFSpecify
				 , FFSubstanceAbuse
				 , FSWFK
				 , GrandParentParticipated
				 , HCBreastFeeding
				 , HCChild
				 , HCDental
				 , HCFamilyPlanning
				 , HCFASD
				 , HCFeeding
				 , HCGeneral
				 , HCMedicalAdvocacy
				 , HCNutrition
				 , HCOther
				 , HCPrenatalCare
				 , HCProviders
				 , HCSafety
				 , HCSexEducation
				 , HCSIDS
				 , HCSmoking
				 , HCSpecify
				 , HVCaseFK
				 , HVLogCreateDate
				 , HVLogCreator
				 , HVLogEditDate
				 , HVLogEditor
				 , HVSupervisorParticipated
				 , NonPrimaryFSWParticipated
				 , NonPrimaryFSWFK
				 , OBPParticipated
				 , OtherLocationSpecify
				 , OtherParticipated
				 , PAAssessmentIssues
				 , PAForms
				 , PAGroups
				 , PAIFSP
				 , PAOther
				 , PARecreation
				 , PASpecify
				 , PAVideo
				 , ParentCompletedActivity
				 , ParentObservationsDiscussed
				 , ParticipatedSpecify
				 , PC1Participated
				 , PC2Participated
				 , PCBasicNeeds
				 , PCChildInteraction
				 , PCChildManagement
				 , PCFeelings
				 , PCOther
				 , PCShakenBaby
				 , PCShakenBabyVideo
				 , PCSpecify
				 , PCStress
				 , ProgramFK
				 , ReviewAssessmentIssues
				 , SiblingParticipated
				 , SSCalendar
				 , SSChildCare
				 , SSEducation
				 , SSEmployment
				 , SSHousekeeping
				 , SSJob
				 , SSMoneyManagement
				 , SSOther
				 , SSProblemSolving
				 , SSSpecify
				 , SSTransportation
				 , SupervisorObservation
				 , TCAlwaysOnBack
				 , TCAlwaysWithoutSharing
				 , TCParticipated
				 , TotalPercentageSpent
				 , UpcomingProgramEvents
				 , VisitLengthHour
				 , VisitLengthMinute
				 , VisitLocation
				 , VisitStartTime
				 , VisitType
			from   HVLog hl;

set identity_insert HVLogOld off;
go
print N'Updating old rows in HVLog';
go
update HVLog
set	   CAAdvocacy = case when CAAdvocacy like '%1' then '1'
						 else '0'
					end
	 , CAChildSupport = case when CAChildSupport like '%1' then '1'
							 else '0'
						end
	 , CAGoods = case when CAGoods like '%1' then '1'
					  else '0'
				 end
	 , CAHousing = case when CAHousing like '%1' then '1'
						else '0'
				   end
	 , CALaborSupport = case when CALaborSupport like '%1' then '1'
							 else '0'
						end
	 , CALegal = case when CALegal like '%1' then '1'
					  else '0'
				 end
	 , CAOther = case when CAOther like '%1' then '1'
					  else '0'
				 end
	 , CAParentRights = case when CAParentRights like '%1' then '1'
							 else '0'
						end
	 , CATranslation = case when CATranslation like '%1%' then '1'
							else '0'
					   end
	 , CATransportation = case when CATransportation like '%1%' then '1'
							   else '0'
						  end
	 , CAVisitation = case when CAVisitation like '%1%' then '1'
						   else '0'
					  end
	 , CDChildDevelopment = case when CDChildDevelopment like '%1%' then '1'
								 else '0'
							end
	 , CDOther = case when CDOther like '%1%' then '1'
					  else '0'
				 end
	 , CDParentConcerned = case when CDParentConcerned like '%1%' then '1'
								else '0'
						   end
	 , CDToys = case when CDToys like '%1%' then '1'
					 else '0'
				end
	 , CIProblems = case when CIProblems like '%1%' then '1'
						 else '0'
					end
	 , CIOther = case when CIOther like '%1%' then '1'
					  else '0'
				 end
	 , FFCommunication = case when FFCommunication like '%1%' then '1'
							  else '0'
						 end
	 , FFDomesticViolence = case when FFDomesticViolence like '%1%' then '1'
								 else '0'
							end
	 , FFFamilyRelations = case when FFFamilyRelations like '%1%' then '1'
								else '0'
						   end
	 , FFMentalHealth = case when FFMentalHealth like '%1%' then '1'
							 else '0'
						end
	 , FFOther = case when FFOther like '%1%' then '1'
					  else '0'
				 end
	 , FFSubstanceAbuse = case when FFSubstanceAbuse like '%1%' then '1'
							   else '0'
						  end
	 , HCBreastFeeding = case when HCBreastFeeding like '%1%' then '1'
							  else '0'
						 end
	 , HCChild = case when HCChild like '%1%' then '1'
					  else '0'
				 end
	 , HCDental = case when HCDental like '%1%' then '1'
					   else '0'
				  end
	 , HCFamilyPlanning = case when HCFamilyPlanning like '%1%' then '1'
							   else '0'
						  end
	 , HCFASD = case when HCFASD like '%1%' then '1'
					 else '0'
				end
	 , HCFeeding = case when HCFeeding like '%1%' then '1'
						else '0'
				   end
	 , HCGeneral = case when HCGeneral like '%1%' then '1'
						else '0'
				   end
	 , HCMedicalAdvocacy = case when HCMedicalAdvocacy like '%1%' then '1'
								else '0'
						   end
	 , HCNutrition = case when HCNutrition like '%1%' then '1'
						  else '0'
					 end
	 , HCOther = case when HCOther like '%1%' then '1'
					  else '0'
				 end
	 , HCPrenatalCare = case when HCPrenatalCare like '%1%' then '1'
							 else '0'
						end
	 , HCProviders = case when HCProviders like '%1%' then '1'
						  else '0'
					 end
	 , HCSafety = case when HCSafety like '%1%' then '1'
					   else '0'
				  end
	 , HCSexEducation = case when HCSexEducation like '%1%' then '1'
							 else '0'
						end
	 , HCSIDS = case when HCSIDS like '%1%' then '1'
					 else '0'
				end
	 , HCSmoking = case when HCSmoking like '%1%' then '1'
						else '0'
				   end
	 , PAAssessmentIssues = case when PAAssessmentIssues like '%1%' then '1'
								 else '0'
							end
	 , PAForms = case when PAForms like '%1%' then '1'
					  else '0'
				 end
	 , PAGroups = case when PAGroups like '%1%' then '1'
					   else '0'
				  end
	 , PAIFSP = case when PAIFSP like '%1%' then '1'
					 else '0'
				end
	 , PAOther = case when PAOther like '%1%' then '1'
					  else '0'
				 end
	 , PARecreation = case when PARecreation like '%1%' then '1'
						   else '0'
					  end
	 , PAVideo = case when PAVideo like '%1%' then '1'
					  else '0'
				 end
	 , PCBasicNeeds = case when PCBasicNeeds like '%1%' then '1'
						   else '0'
					  end
	 , PCChildInteraction = case when PCChildInteraction like '%1%' then '1'
								 else '0'
							end
	 , PCChildManagement = case when PCChildManagement like '%1%' then '1'
								else '0'
						   end
	 , PCFeelings = case when PCFeelings like '%1%' then '1'
						 else '0'
					end
	 , PCOther = case when PCOther like '%1%' then '1'
					  else '0'
				 end
	 , PCShakenBaby = case when PCShakenBaby like '%1%' then '1'
						   else '0'
					  end
	 , PCShakenBabyVideo = case when PCShakenBabyVideo like '%1%' then '1'
								else '0'
						   end
	 , PCStress = case when PCStress like '%1%' then '1'
					   else '0'
				  end
	 , SSCalendar = case when SSCalendar like '%1%' then '1'
						 else '0'
					end
	 , SSChildCare = case when SSChildCare like '%1%' then '1'
						  else '0'
					 end
	 , SSEducation = case when SSEducation like '%1%' then '1'
						  else '0'
					 end
	 , SSEmployment = case when SSEmployment like '%1%' then '1'
						   else '0'
					  end
	 , SSHousekeeping = case when SSHousekeeping like '%1%' then '1'
							 else '0'
						end
	 , SSJob = case when SSJob like '%1%' then '1'
					else '0'
			   end
	 , SSMoneyManagement = case when SSMoneyManagement like '%1%' then '1'
								else '0'
						   end
	 , SSOther = case when SSOther like '%1%' then '1'
					  else '0'
				 end
	 , SSProblemSolving = case when SSProblemSolving like '%1%' then '1'
							   else '0'
						  end
	 , SSTransportation = case when SSTransportation like '%1%' then '1'
							   else '0'
						  end;
go
print N'Rebuilding [dbo].[HVLog]';
go
create table [dbo].[RG_Recovery_2_HVLog] (	 [HVLogPK] [int] not null identity(1, 1)
										   , [AdditionalComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CAAdvocacy] [bit] null
										   , [CAChildSupport] [bit] null
										   , [CAComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CAGoods] [bit] null
										   , [CAHousing] [bit] null
										   , [CALaborSupport] [bit] null
										   , [CALegal] [bit] null
										   , [CAOther] [bit] null
										   , [CAParentRights] [bit] null
										   , [CASpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CATranslation] [bit] null
										   , [CATransportation] [bit] null
										   , [CAVisitation] [bit] null
										   , [CDChildDevelopment] [bit] null
										   , [CDComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CDFollowUpEIServices] [bit] null
										   , [CDOther] [bit] null
										   , [CDParentConcerned] [bit] null
										   , [CDSocialEmotionalDevelopment] [bit] null
										   , [CDSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CDToys] [bit] null
										   , [CHEERSCues] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CHEERSHolding] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CHEERSExpression] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CHEERSEmpathy] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CHEERSRhythmReciprocity] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CHEERSSmiles] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CHEERSOverallStrengths] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CHEERSAreasToFocus] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CIComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CIProblems] [bit] null
										   , [CIOther] [bit] null
										   , [CIOtherSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [Curriculum247Dads] [bit] null
										   , [CurriculumBoyz2Dads] [bit] null
										   , [CurriculumComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CurriculumGreatBeginnings] [bit] null
										   , [CurriculumGrowingGreatKids] [bit] null
										   , [CurriculumHelpingBabiesLearn] [bit] null
										   , [CurriculumInsideOutDads] [bit] null
										   , [CurriculumMomGateway] [bit] null
										   , [CurriculumOtherSupplementalInformation] [bit] null
										   , [CurriculumOtherSupplementalInformationComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CurriculumOther] [bit] null
										   , [CurriculumOtherSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [CurriculumParentsForLearning] [bit] null
										   , [CurriculumPartnersHealthyBaby] [bit] null
										   , [CurriculumPAT] [bit] null
										   , [CurriculumPATFocusFathers] [bit] null
										   , [CurriculumSanAngelo] [bit] null
										   , [FamilyMemberReads] [char](2) collate SQL_Latin1_General_CP1_CI_AS null
										   , [FatherAdvocateFK] [int] null
										   , [FatherAdvocateParticipated] [bit] null
										   , [FatherFigureParticipated] [bit] null
										   , [FFChildProtectiveIssues] [bit] null
										   , [FFComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [FFCommunication] [bit] null
										   , [FFDevelopmentalDisabilities] [bit] null
										   , [FFDomesticViolence] [bit] null
										   , [FFFamilyRelations] [bit] null
										   , [FFImmigration] [bit] null
										   , [FFMentalHealth] [bit] null
										   , [FFOther] [bit] null
										   , [FFSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [FFSubstanceAbuse] [bit] null
										   , [FGPComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [FGPDevelopActivities] [bit] null
										   , [FGPDiscuss] [bit] null
										   , [FGPGoalsCompleted] [bit] null
										   , [FGPNewGoal] [bit] null
										   , [FGPNoDiscussion] [bit] null
										   , [FGPProgress] [bit] null
										   , [FGPRevisions] [bit] null
										   , [FormComplete] [bit] null
										   , [FSWFK] [int] null
										   , [GrandParentParticipated] [bit] null
										   , [HCBreastFeeding] [bit] null
										   , [HCChild] [bit] null
										   , [HCComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HCDental] [bit] null
										   , [HCFamilyPlanning] [bit] null
										   , [HCFASD] [bit] null
										   , [HCFeeding] [bit] null
										   , [HCGeneral] [bit] null
										   , [HCLaborDelivery] [bit] null
										   , [HCMedicalAdvocacy] [bit] null
										   , [HCNutrition] [bit] null
										   , [HCOther] [bit] null
										   , [HCPrenatalCare] [bit] null
										   , [HCProviders] [bit] null
										   , [HCSafety] [bit] null
										   , [HCSexEducation] [bit] null
										   , [HCSIDS] [bit] null
										   , [HCSmoking] [bit] null
										   , [HCSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HealthPC1AppearsHealthy] [bit] null
										   , [HealthPC1Asleep] [bit] null
										   , [HealthPC1CommentsGeneral] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HealthPC1CommentsMedical] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HealthPC1ERVisits] [bit] null
										   , [HealthPC1HealthConcern] [bit] null
										   , [HealthPC1MedicalPrenatalAppointments] [bit] null
										   , [HealthPC1PhysicalNeedsAppearUnmet] [bit] null
										   , [HealthPC1TiredIrritable] [bit] null
										   , [HealthPC1WithdrawnUnresponsive] [bit] null
										   , [HealthTCAppearsHealthy] [bit] null
										   , [HealthTCAsleep] [bit] null
										   , [HealthTCCommentsGeneral] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HealthTCCommentsMedical] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HealthTCERVisits] [bit] null
										   , [HealthTCHealthConcern] [bit] null
										   , [HealthTCImmunizations] [bit] null
										   , [HealthTCMedicalWellBabyAppointments] [bit] null
										   , [HealthTCPhysicalNeedsAppearUnmet] [bit] null
										   , [HealthTCTiredIrritable] [bit] null
										   , [HealthTCWithdrawnUnresponsive] [bit] null
										   , [HouseholdChangesComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HouseholdChangesLeft] [bit] null
										   , [HouseholdChangesNew] [bit] null
										   , [HVCaseFK] [int] not null
										   , [HVLogCreateDate] [datetime] not null
												 constraint [DF_HVLog_HVLogCreateDate]
												 default (getdate())
										   , [HVLogCreator] [char](10) collate SQL_Latin1_General_CP1_CI_AS not null
										   , [HVLogEditDate] [datetime] null
										   , [HVLogEditor] [char](10) collate SQL_Latin1_General_CP1_CI_AS null
										   , [HVSupervisorParticipated] [bit] null
										   , [NextScheduledVisit] [datetime] null
                                           , [NextVisitNotes] [varchar](max) null
										   , [NonPrimaryFSWParticipated] [bit] null
										   , [NonPrimaryFSWFK] [int] null
										   , [OBPParticipated] [bit] null
										   , [OtherLocationSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [OtherParticipated] [bit] null
										   , [PAAssessmentIssues] [bit] null
										   , [PAComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [PAForms] [bit] null
										   , [PAGroups] [bit] null
										   , [PAIFSP] [bit] null
										   , [PAIntroduceProgram] [bit] null
										   , [PALevelChange] [bit] null
										   , [PAOther] [bit] null
										   , [PARecreation] [bit] null
										   , [PASpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [PAVideo] [bit] null
										   , [ParentCompletedActivity] [bit] null
										   , [ParentObservationsDiscussed] [bit] null
										   , [ParticipatedSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [PC1Participated] [bit] null
										   , [PC2Participated] [bit] null
										   , [PCBasicNeeds] [bit] null
										   , [PCChildInteraction] [bit] null
										   , [PCChildManagement] [bit] null
										   , [PCComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [PCFeelings] [bit] null
										   , [PCOther] [bit] null
										   , [PCShakenBaby] [bit] null
										   , [PCShakenBabyVideo] [bit] null
										   , [PCSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [PCStress] [bit] null
										   , [PCTechnologyEffects] [bit] null
										   , [POCRAskedQuestions] [bit] null
										   , [POCRComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [POCRContributed] [bit] null
										   , [POCRInterested] [bit] null
										   , [POCRNotInterested] [bit] null
										   , [POCRWantedInformation] [bit] null
										   , [ProgramFK] [int] null
										   , [PSCComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [PSCEmergingIssues] [bit] null
										   , [PSCInitialDiscussion] [bit] null
										   , [PSCImplement] [bit] null
										   , [PSCOngoingDiscussion] [bit] null
										   , [ReferralsComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [ReferralsFollowUp] [bit] null
										   , [ReferralsMade] [bit] null
										   , [ReviewAssessmentIssues] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [RSATP] [bit] null
										   , [RSATPComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [RSSATP] [bit] null
										   , [RSSATPComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [RSFFF] [bit] null
										   , [RSFFFComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [RSEW] [bit] null
										   , [RSEWComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [RSNormalizing] [bit] null
										   , [RSNormalizingComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [RSSFT] [bit] null
										   , [RSSFTComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [SiblingParticipated] [bit] null
										   , [SiblingsObservation] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [SSCalendar] [bit] null
										   , [SSChildCare] [bit] null
										   , [SSChildWelfareServices] [bit] null
										   , [SSComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [SSEducation] [bit] null
										   , [SSEmployment] [bit] null
										   , [SSHomeEnvironment] [bit] null
										   , [SSHousekeeping] [bit] null
										   , [SSJob] [bit] null
										   , [SSMoneyManagement] [bit] null
										   , [SSOther] [bit] null
										   , [SSProblemSolving] [bit] null
										   , [SSSpecify] [varchar](500) collate SQL_Latin1_General_CP1_CI_AS null
										   , [SSTransportation] [bit] null
										   , [STASQ] [bit] null
										   , [STASQSE] [bit] null
										   , [STComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [STPHQ9] [bit] null
										   , [STPSI] [bit] null
										   , [STOther] [bit] null
										   , [SupervisorObservation] [bit] null
										   , [TCAlwaysOnBack] [bit] null
										   , [TCAlwaysWithoutSharing] [bit] null
										   , [TCParticipated] [bit] null
										   , [TotalPercentageSpent] [int] null
										   , [TPComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										   , [TPDateInitiated] [date] null
										   , [TPInitiated] [bit] null
										   , [TPNotApplicable] [int] null
										   , [TPOngoingDiscussion] [bit] null
										   , [TPParentDeclined] [bit] null
										   , [TPPlanFinalized] [bit] null
										   , [TPTransitionCompleted] [bit] null
										   , [UpcomingProgramEvents] [bit] null
										   , [VisitLengthHour] [int] not null
										   , [VisitLengthMinute] [int] not null
										   , [VisitLocation] [char](5) collate SQL_Latin1_General_CP1_CI_AS not null
										   , [VisitStartTime] [datetime] not null
										   , [VisitType] [char](6) collate SQL_Latin1_General_CP1_CI_AS not null
										   , [VisitTypeComments] [varchar](max) collate SQL_Latin1_General_CP1_CI_AS null
										 ) on [PRIMARY] textimage_on [PRIMARY];
go
set identity_insert [dbo].[RG_Recovery_2_HVLog] on;
go
insert into [dbo].[RG_Recovery_2_HVLog] (	[HVLogPK]
										  , [CAAdvocacy]
										  , [CAChildSupport]
										  , [CAGoods]
										  , [CAHousing]
										  , [CALaborSupport]
										  , [CALegal]
										  , [CAOther]
										  , [CAParentRights]
										  , [CASpecify]
										  , [CATranslation]
										  , [CATransportation]
										  , [CAVisitation]
										  , [CDChildDevelopment]
										  , [CDOther]
										  , [CDParentConcerned]
										  , [CDSpecify]
										  , [CDToys]
										  , [CIProblems]
										  , [CIOther]
										  , [CIOtherSpecify]
										  , [Curriculum247Dads]
										  , [CurriculumBoyz2Dads]
										  , [CurriculumGrowingGreatKids]
										  , [CurriculumHelpingBabiesLearn]
										  , [CurriculumInsideOutDads]
										  , [CurriculumMomGateway]
										  , [CurriculumOther]
										  , [CurriculumOtherSpecify]
										  , [CurriculumParentsForLearning]
										  , [CurriculumPartnersHealthyBaby]
										  , [CurriculumPAT]
										  , [CurriculumPATFocusFathers]
										  , [CurriculumSanAngelo]
										  , [FamilyMemberReads]
										  , [FatherAdvocateFK]
										  , [FatherAdvocateParticipated]
										  , [FatherFigureParticipated]
										  , [FFCommunication]
										  , [FFDomesticViolence]
										  , [FFFamilyRelations]
										  , [FFMentalHealth]
										  , [FFOther]
										  , [FFSpecify]
										  , [FFSubstanceAbuse]
										  , [FSWFK]
										  , [GrandParentParticipated]
										  , [HCBreastFeeding]
										  , [HCChild]
										  , [HCDental]
										  , [HCFamilyPlanning]
										  , [HCFASD]
										  , [HCFeeding]
										  , [HCGeneral]
										  , [HCMedicalAdvocacy]
										  , [HCNutrition]
										  , [HCOther]
										  , [HCPrenatalCare]
										  , [HCProviders]
										  , [HCSafety]
										  , [HCSexEducation]
										  , [HCSIDS]
										  , [HCSmoking]
										  , [HCSpecify]
										  , [HVCaseFK]
										  , [HVLogCreateDate]
										  , [HVLogCreator]
										  , [HVLogEditDate]
										  , [HVLogEditor]
										  , [HVSupervisorParticipated]
										  , [NonPrimaryFSWParticipated]
										  , [NonPrimaryFSWFK]
										  , [OBPParticipated]
										  , [OtherLocationSpecify]
										  , [OtherParticipated]
										  , [PAAssessmentIssues]
										  , [PAForms]
										  , [PAGroups]
										  , [PAIFSP]
										  , [PAOther]
										  , [PARecreation]
										  , [PASpecify]
										  , [PAVideo]
										  , [ParentCompletedActivity]
										  , [ParentObservationsDiscussed]
										  , [ParticipatedSpecify]
										  , [PC1Participated]
										  , [PC2Participated]
										  , [PCBasicNeeds]
										  , [PCChildInteraction]
										  , [PCChildManagement]
										  , [PCFeelings]
										  , [PCOther]
										  , [PCShakenBaby]
										  , [PCShakenBabyVideo]
										  , [PCSpecify]
										  , [PCStress]
										  , [ProgramFK]
										  , [ReviewAssessmentIssues]
										  , [SiblingParticipated]
										  , [SSCalendar]
										  , [SSChildCare]
										  , [SSEducation]
										  , [SSEmployment]
										  , [SSHousekeeping]
										  , [SSJob]
										  , [SSMoneyManagement]
										  , [SSOther]
										  , [SSProblemSolving]
										  , [SSSpecify]
										  , [SSTransportation]
										  , [SupervisorObservation]
										  , [TCAlwaysOnBack]
										  , [TCAlwaysWithoutSharing]
										  , [TCParticipated]
										  , [TotalPercentageSpent]
										  , [UpcomingProgramEvents]
										  , [VisitLengthHour]
										  , [VisitLengthMinute]
										  , [VisitLocation]
										  , [VisitStartTime]
										  , [VisitType]
										)
			select [HVLogPK]
				 , [CAAdvocacy]
				 , [CAChildSupport]
				 , [CAGoods]
				 , [CAHousing]
				 , [CALaborSupport]
				 , [CALegal]
				 , [CAOther]
				 , [CAParentRights]
				 , [CASpecify]
				 , [CATranslation]
				 , [CATransportation]
				 , [CAVisitation]
				 , [CDChildDevelopment]
				 , [CDOther]
				 , [CDParentConcerned]
				 , [CDSpecify]
				 , [CDToys]
				 , [CIProblems]
				 , [CIOther]
				 , [CIOtherSpecify]
				 , [Curriculum247Dads]
				 , [CurriculumBoyz2Dads]
				 , [CurriculumGrowingGreatKids]
				 , [CurriculumHelpingBabiesLearn]
				 , [CurriculumInsideOutDads]
				 , [CurriculumMomGateway]
				 , [CurriculumOther]
				 , [CurriculumOtherSpecify]
				 , [CurriculumParentsForLearning]
				 , [CurriculumPartnersHealthyBaby]
				 , [CurriculumPAT]
				 , [CurriculumPATFocusFathers]
				 , [CurriculumSanAngelo]
				 , [FamilyMemberReads]
				 , [FatherAdvocateFK]
				 , [FatherAdvocateParticipated]
				 , [FatherFigureParticipated]
				 , [FFCommunication]
				 , [FFDomesticViolence]
				 , [FFFamilyRelations]
				 , [FFMentalHealth]
				 , [FFOther]
				 , [FFSpecify]
				 , [FFSubstanceAbuse]
				 , [FSWFK]
				 , [GrandParentParticipated]
				 , [HCBreastFeeding]
				 , [HCChild]
				 , [HCDental]
				 , [HCFamilyPlanning]
				 , [HCFASD]
				 , [HCFeeding]
				 , [HCGeneral]
				 , [HCMedicalAdvocacy]
				 , [HCNutrition]
				 , [HCOther]
				 , [HCPrenatalCare]
				 , [HCProviders]
				 , [HCSafety]
				 , [HCSexEducation]
				 , [HCSIDS]
				 , [HCSmoking]
				 , [HCSpecify]
				 , [HVCaseFK]
				 , [HVLogCreateDate]
				 , [HVLogCreator]
				 , [HVLogEditDate]
				 , [HVLogEditor]
				 , [HVSupervisorParticipated]
				 , [NonPrimaryFSWParticipated]
				 , [NonPrimaryFSWFK]
				 , [OBPParticipated]
				 , [OtherLocationSpecify]
				 , [OtherParticipated]
				 , [PAAssessmentIssues]
				 , [PAForms]
				 , [PAGroups]
				 , [PAIFSP]
				 , [PAOther]
				 , [PARecreation]
				 , [PASpecify]
				 , [PAVideo]
				 , [ParentCompletedActivity]
				 , [ParentObservationsDiscussed]
				 , [ParticipatedSpecify]
				 , [PC1Participated]
				 , [PC2Participated]
				 , [PCBasicNeeds]
				 , [PCChildInteraction]
				 , [PCChildManagement]
				 , [PCFeelings]
				 , [PCOther]
				 , [PCShakenBaby]
				 , [PCShakenBabyVideo]
				 , [PCSpecify]
				 , [PCStress]
				 , [ProgramFK]
				 , [ReviewAssessmentIssues]
				 , [SiblingParticipated]
				 , [SSCalendar]
				 , [SSChildCare]
				 , [SSEducation]
				 , [SSEmployment]
				 , [SSHousekeeping]
				 , [SSJob]
				 , [SSMoneyManagement]
				 , [SSOther]
				 , [SSProblemSolving]
				 , [SSSpecify]
				 , [SSTransportation]
				 , [SupervisorObservation]
				 , [TCAlwaysOnBack]
				 , [TCAlwaysWithoutSharing]
				 , [TCParticipated]
				 , [TotalPercentageSpent]
				 , [UpcomingProgramEvents]
				 , [VisitLengthHour]
				 , [VisitLengthMinute]
				 , [VisitLocation]
				 , [VisitStartTime]
				 , [VisitType]
			from   [dbo].[HVLog];
go
set identity_insert [dbo].[RG_Recovery_2_HVLog] off;
go
declare @idVal bigint;
select @idVal = ident_current(N'[dbo].[HVLog]');
if @idVal is not null
	dbcc checkident(N'[dbo].[RG_Recovery_2_HVLog]', reseed, @idVal);
go
drop table [dbo].[HVLog];
go
exec sp_rename N'[dbo].[RG_Recovery_2_HVLog]'
			 , N'HVLog'
			 , N'OBJECT';
go
print N'Creating primary key [PK__HVLog__ED876F581332DBDC] on [dbo].[HVLog]';
go
alter table [dbo].[HVLog]
add constraint [PK__HVLog__ED876F581332DBDC]
	primary key clustered ([HVLogPK]) on [PRIMARY];
go
print N'Creating index [IX_FK_HVLog_FSWFK] on [dbo].[HVLog]';
go
create nonclustered index [IX_FK_HVLog_FSWFK]
	on [dbo].[HVLog] ([FSWFK]) on [PRIMARY];
go
print N'Creating index [IX_FK_HVLog_HVCaseFK] on [dbo].[HVLog]';
go
create nonclustered index [IX_FK_HVLog_HVCaseFK]
	on [dbo].[HVLog] ([HVCaseFK]) on [PRIMARY];
go
print N'Creating index [HVCase_ProgramFK] on [dbo].[HVLog]';
go
create nonclustered index [HVCase_ProgramFK]
	on [dbo].[HVLog]
	(
		[HVCaseFK]
	  , [ProgramFK]
	) on [PRIMARY];
go
print N'Creating index [IX_FK_HVLog_ProgramFK] on [dbo].[HVLog]';
go
create nonclustered index [IX_FK_HVLog_ProgramFK]
	on [dbo].[HVLog] ([ProgramFK]) on [PRIMARY];
go
print N'Creating index [IX_HVLog_VisitStartTime] on [dbo].[HVLog]';
go
create nonclustered index [IX_HVLog_VisitStartTime]
	on [dbo].[HVLog] ([VisitStartTime]) on [PRIMARY];
go
print N'Creating index [IX_HVLog_VisitType] on [dbo].[HVLog]';
go
create nonclustered index [IX_HVLog_VisitType]
	on [dbo].[HVLog] ([VisitType]) on [PRIMARY];
go
print N'Creating index [IX_FK_HVLog_FormComplete] on [dbo].[HVLog]';
go
create nonclustered index [IX_HVLog_FormComplete]
	on [dbo].[HVLog] ([FormComplete]) on [PRIMARY];
go
print N'Refreshing [dbo].[HVLevelDetail]';
go
exec sp_refreshview N'[dbo].[HVLevelDetail]';
go
print N'Refreshing [dbo].[WorkerAssignmentDetail]';
go
exec sp_refreshview N'[dbo].[WorkerAssignmentDetail]';
go
print N'Refreshing [dbo].[vPHQ9]';
go
exec sp_refreshview N'[dbo].[vPHQ9]';
go
print N'Altering [dbo].[spAddHVLog]';
go
alter procedure [dbo].[spAddHVLog] (   @AdditionalComments varchar(max) = null
									 , @CAAdvocacy bit = null
									 , @CAChildSupport bit = null
									 , @CAComments varchar(max) = null
									 , @CAGoods bit = null
									 , @CAHousing bit = null
									 , @CALaborSupport bit = null
									 , @CALegal bit = null
									 , @CAOther bit = null
									 , @CAParentRights bit = null
									 , @CASpecify varchar(500) = null
									 , @CATranslation bit = null
									 , @CATransportation bit = null
									 , @CAVisitation bit = null
									 , @CDChildDevelopment bit = null
									 , @CDComments varchar(max) = null
									 , @CDFollowUpEIServices bit = null
									 , @CDOther bit = null
									 , @CDParentConcerned bit = null
									 , @CDSocialEmotionalDevelopment bit = null
									 , @CDSpecify varchar(500) = null
									 , @CDToys bit = null
									 , @CHEERSCues varchar(max) = null
									 , @CHEERSHolding varchar(max) = null
									 , @CHEERSExpression varchar(max) = null
									 , @CHEERSEmpathy varchar(max) = null
									 , @CHEERSRhythmReciprocity varchar(max) = null
									 , @CHEERSSmiles varchar(max) = null
									 , @CHEERSOverallStrengths varchar(max) = null
									 , @CHEERSAreasToFocus varchar(max) = null
									 , @CIComments varchar(max) = null
									 , @CIProblems bit = null
									 , @CIOther bit = null
									 , @CIOtherSpecify varchar(500) = null
									 , @Curriculum247Dads bit = null
									 , @CurriculumBoyz2Dads bit = null
									 , @CurriculumComments varchar(max) = null
									 , @CurriculumGreatBeginnings bit = null
									 , @CurriculumGrowingGreatKids bit = null
									 , @CurriculumHelpingBabiesLearn bit = null
									 , @CurriculumInsideOutDads bit = null
									 , @CurriculumMomGateway bit = null
									 , @CurriculumOtherSupplementalInformation bit = null
									 , @CurriculumOtherSupplementalInformationComments varchar(max) = null
									 , @CurriculumOther bit = null
									 , @CurriculumOtherSpecify varchar(500) = null
									 , @CurriculumParentsForLearning bit = null
									 , @CurriculumPartnersHealthyBaby bit = null
									 , @CurriculumPAT bit = null
									 , @CurriculumPATFocusFathers bit = null
									 , @CurriculumSanAngelo bit = null
									 , @FamilyMemberReads char(2) = null
									 , @FatherAdvocateFK int = null
									 , @FatherAdvocateParticipated bit = null
									 , @FatherFigureParticipated bit = null
									 , @FFChildProtectiveIssues bit = null
									 , @FFComments varchar(max) = null
									 , @FFCommunication bit = null
									 , @FFDevelopmentalDisabilities bit = null
									 , @FFDomesticViolence bit = null
									 , @FFFamilyRelations bit = null
									 , @FFImmigration bit = null
									 , @FFMentalHealth bit = null
									 , @FFOther bit = null
									 , @FFSpecify varchar(500) = null
									 , @FFSubstanceAbuse bit = null
									 , @FGPComments varchar(max) = null
									 , @FGPDevelopActivities bit = null
									 , @FGPDiscuss bit = null
									 , @FGPGoalsCompleted bit = null
									 , @FGPNewGoal bit = null
									 , @FGPNoDiscussion bit = null
									 , @FGPProgress bit = null
									 , @FGPRevisions bit = null
									 , @FormComplete bit = null
									 , @FSWFK int = null
									 , @GrandParentParticipated bit = null
									 , @HCBreastFeeding bit = null
									 , @HCChild bit = null
									 , @HCComments varchar(max) = null
									 , @HCDental bit = null
									 , @HCFamilyPlanning bit = null
									 , @HCFASD bit = null
									 , @HCFeeding bit = null
									 , @HCGeneral bit = null
									 , @HCLaborDelivery bit = null
									 , @HCMedicalAdvocacy bit = null
									 , @HCNutrition bit = null
									 , @HCOther bit = null
									 , @HCPrenatalCare bit = null
									 , @HCProviders bit = null
									 , @HCSafety bit = null
									 , @HCSexEducation bit = null
									 , @HCSIDS bit = null
									 , @HCSmoking bit = null
									 , @HCSpecify varchar(500) = null
									 , @HealthPC1AppearsHealthy bit = null
									 , @HealthPC1Asleep bit = null
									 , @HealthPC1CommentsGeneral varchar(max) = null
									 , @HealthPC1CommentsMedical varchar(max) = null
									 , @HealthPC1ERVisits bit = null
									 , @HealthPC1HealthConcern bit = null
									 , @HealthPC1MedicalPrenatalAppointments bit = null
									 , @HealthPC1PhysicalNeedsAppearUnmet bit = null
									 , @HealthPC1TiredIrritable bit = null
									 , @HealthPC1WithdrawnUnresponsive bit = null
									 , @HealthTCAppearsHealthy bit = null
									 , @HealthTCAsleep bit = null
									 , @HealthTCCommentsGeneral varchar(max) = null
									 , @HealthTCCommentsMedical varchar(max) = null
									 , @HealthTCERVisits bit = null
									 , @HealthTCHealthConcern bit = null
									 , @HealthTCImmunizations bit = null
									 , @HealthTCMedicalWellBabyAppointments bit = null
									 , @HealthTCPhysicalNeedsAppearUnmet bit = null
									 , @HealthTCTiredIrritable bit = null
									 , @HealthTCWithdrawnUnresponsive bit = null
									 , @HouseholdChangesComments varchar(max) = null
									 , @HouseholdChangesLeft bit = null
									 , @HouseholdChangesNew bit = null
									 , @HVCaseFK int = null
									 , @HVLogCreator char(10) = null
									 , @HVSupervisorParticipated bit = null
									 , @NextScheduledVisit datetime = null
									 , @NextVisitNotes varchar(max) = null
									 , @NonPrimaryFSWParticipated bit = null
									 , @NonPrimaryFSWFK int = null
									 , @OBPParticipated bit = null
									 , @OtherLocationSpecify varchar(500) = null
									 , @OtherParticipated bit = null
									 , @PAAssessmentIssues bit = null
									 , @PAComments varchar(max) = null
									 , @PAForms bit = null
									 , @PAGroups bit = null
									 , @PAIFSP bit = null
									 , @PAIntroduceProgram bit = null
									 , @PALevelChange bit = null
									 , @PAOther bit = null
									 , @PARecreation bit = null
									 , @PASpecify varchar(500) = null
									 , @PAVideo bit = null
									 , @ParentCompletedActivity bit = null
									 , @ParentObservationsDiscussed bit = null
									 , @ParticipatedSpecify varchar(500) = null
									 , @PC1Participated bit = null
									 , @PC2Participated bit = null
									 , @PCBasicNeeds bit = null
									 , @PCChildInteraction bit = null
									 , @PCChildManagement bit = null
									 , @PCComments varchar(max) = null
									 , @PCFeelings bit = null
									 , @PCOther bit = null
									 , @PCShakenBaby bit = null
									 , @PCShakenBabyVideo bit = null
									 , @PCSpecify varchar(500) = null
									 , @PCStress bit = null
									 , @PCTechnologyEffects bit = null
									 , @POCRAskedQuestions bit = null
									 , @POCRComments varchar(max) = null
									 , @POCRContributed bit = null
									 , @POCRInterested bit = null
									 , @POCRNotInterested bit = null
									 , @POCRWantedInformation bit = null
									 , @ProgramFK int = null
									 , @PSCComments varchar(max) = null
									 , @PSCEmergingIssues bit = null
									 , @PSCInitialDiscussion bit = null
									 , @PSCImplement bit = null
									 , @PSCOngoingDiscussion bit = null
									 , @ReferralsComments varchar(max) = null
									 , @ReferralsFollowUp bit = null
									 , @ReferralsMade bit = null
									 , @ReviewAssessmentIssues varchar(500) = null
									 , @RSATP bit = null
									 , @RSATPComments varchar(max) = null
									 , @RSSATP bit = null
									 , @RSSATPComments varchar(max) = null
									 , @RSFFF bit = null
									 , @RSFFFComments varchar(max) = null
									 , @RSEW bit = null
									 , @RSEWComments varchar(max) = null
									 , @RSNormalizing bit = null
									 , @RSNormalizingComments varchar(max) = null
									 , @RSSFT bit = null
									 , @RSSFTComments varchar(max) = null
									 , @SiblingParticipated bit = null
									 , @SiblingsObservation varchar(max) = null
									 , @SSCalendar bit = null
									 , @SSChildCare bit = null
									 , @SSChildWelfareServices bit = null
									 , @SSComments varchar(max) = null
									 , @SSEducation bit = null
									 , @SSEmployment bit = null
									 , @SSHomeEnvironment bit = null
									 , @SSHousekeeping bit = null
									 , @SSJob bit = null
									 , @SSMoneyManagement bit = null
									 , @SSOther bit = null
									 , @SSProblemSolving bit = null
									 , @SSSpecify varchar(500) = null
									 , @SSTransportation bit = null
									 , @STASQ bit = null
									 , @STASQSE bit = null
									 , @STComments varchar(max) = null
									 , @STPHQ9 bit = null
									 , @STPSI bit = null
									 , @STOther bit = null
									 , @SupervisorObservation bit = null
									 , @TCAlwaysOnBack bit = null
									 , @TCAlwaysWithoutSharing bit = null
									 , @TCParticipated bit = null
									 , @TotalPercentageSpent int = null
									 , @TPComments varchar(max) = null
									 , @TPDateInitiated date = null
									 , @TPInitiated bit = null
									 , @TPNotApplicable int = null
									 , @TPOngoingDiscussion bit = null
									 , @TPParentDeclined bit = null
									 , @TPPlanFinalized bit = null
									 , @TPTransitionCompleted bit = null
									 , @UpcomingProgramEvents bit = null
									 , @VisitLengthHour int = null
									 , @VisitLengthMinute int = null
									 , @VisitLocation char(5) = null
									 , @VisitStartTime datetime = null
									 , @VisitType char(5) = null
									 , @VisitTypeComments varchar(max) = null
								   )
as
	insert into HVLog (	  AdditionalComments
						, CAAdvocacy
						, CAChildSupport
						, CAComments
						, CAGoods
						, CAHousing
						, CALaborSupport
						, CALegal
						, CAOther
						, CAParentRights
						, CASpecify
						, CATranslation
						, CATransportation
						, CAVisitation
						, CDChildDevelopment
						, CDComments
						, CDFollowUpEIServices
						, CDOther
						, CDParentConcerned
						, CDSocialEmotionalDevelopment
						, CDSpecify
						, CDToys
						, CHEERSCues
						, CHEERSHolding
						, CHEERSExpression
						, CHEERSEmpathy
						, CHEERSRhythmReciprocity
						, CHEERSSmiles
						, CHEERSOverallStrengths
						, CHEERSAreasToFocus
						, CIComments
						, CIProblems
						, CIOther
						, CIOtherSpecify
						, Curriculum247Dads
						, CurriculumBoyz2Dads
						, CurriculumComments
						, CurriculumGreatBeginnings
						, CurriculumGrowingGreatKids
						, CurriculumHelpingBabiesLearn
						, CurriculumInsideOutDads
						, CurriculumMomGateway
						, CurriculumOtherSupplementalInformation
						, CurriculumOtherSupplementalInformationComments
						, CurriculumOther
						, CurriculumOtherSpecify
						, CurriculumParentsForLearning
						, CurriculumPartnersHealthyBaby
						, CurriculumPAT
						, CurriculumPATFocusFathers
						, CurriculumSanAngelo
						, FamilyMemberReads
						, FatherAdvocateFK
						, FatherAdvocateParticipated
						, FatherFigureParticipated
						, FFChildProtectiveIssues
						, FFComments
						, FFCommunication
						, FFDevelopmentalDisabilities
						, FFDomesticViolence
						, FFFamilyRelations
						, FFImmigration
						, FFMentalHealth
						, FFOther
						, FFSpecify
						, FFSubstanceAbuse
						, FGPComments
						, FGPDevelopActivities
						, FGPDiscuss
						, FGPGoalsCompleted
						, FGPNewGoal
						, FGPNoDiscussion
						, FGPProgress
						, FGPRevisions
						, FormComplete
						, FSWFK
						, GrandParentParticipated
						, HCBreastFeeding
						, HCChild
						, HCComments
						, HCDental
						, HCFamilyPlanning
						, HCFASD
						, HCFeeding
						, HCGeneral
						, HCLaborDelivery
						, HCMedicalAdvocacy
						, HCNutrition
						, HCOther
						, HCPrenatalCare
						, HCProviders
						, HCSafety
						, HCSexEducation
						, HCSIDS
						, HCSmoking
						, HCSpecify
						, HealthPC1AppearsHealthy
						, HealthPC1Asleep
						, HealthPC1CommentsGeneral
						, HealthPC1CommentsMedical
						, HealthPC1ERVisits
						, HealthPC1HealthConcern
						, HealthPC1MedicalPrenatalAppointments
						, HealthPC1PhysicalNeedsAppearUnmet
						, HealthPC1TiredIrritable
						, HealthPC1WithdrawnUnresponsive
						, HealthTCAppearsHealthy
						, HealthTCAsleep
						, HealthTCCommentsGeneral
						, HealthTCCommentsMedical
						, HealthTCERVisits
						, HealthTCHealthConcern
						, HealthTCImmunizations
						, HealthTCMedicalWellBabyAppointments
						, HealthTCPhysicalNeedsAppearUnmet
						, HealthTCTiredIrritable
						, HealthTCWithdrawnUnresponsive
						, HouseholdChangesComments
						, HouseholdChangesLeft
						, HouseholdChangesNew
						, HVCaseFK
						, HVLogCreator
						, HVSupervisorParticipated
						, NextScheduledVisit
						, NextVisitNotes
						, NonPrimaryFSWParticipated
						, NonPrimaryFSWFK
						, OBPParticipated
						, OtherLocationSpecify
						, OtherParticipated
						, PAAssessmentIssues
						, PAComments
						, PAForms
						, PAGroups
						, PAIFSP
						, PAIntroduceProgram
						, PALevelChange
						, PAOther
						, PARecreation
						, PASpecify
						, PAVideo
						, ParentCompletedActivity
						, ParentObservationsDiscussed
						, ParticipatedSpecify
						, PC1Participated
						, PC2Participated
						, PCBasicNeeds
						, PCChildInteraction
						, PCChildManagement
						, PCComments
						, PCFeelings
						, PCOther
						, PCShakenBaby
						, PCShakenBabyVideo
						, PCSpecify
						, PCStress
						, PCTechnologyEffects
						, POCRAskedQuestions
						, POCRComments
						, POCRContributed
						, POCRInterested
						, POCRNotInterested
						, POCRWantedInformation
						, ProgramFK
						, PSCComments
						, PSCEmergingIssues
						, PSCInitialDiscussion
						, PSCImplement
						, PSCOngoingDiscussion
						, ReferralsComments
						, ReferralsFollowUp
						, ReferralsMade
						, ReviewAssessmentIssues
						, RSATP
						, RSATPComments
						, RSSATP
						, RSSATPComments
						, RSFFF
						, RSFFFComments
						, RSEW
						, RSEWComments
						, RSNormalizing
						, RSNormalizingComments
						, RSSFT
						, RSSFTComments
						, SiblingParticipated
						, SiblingsObservation
						, SSCalendar
						, SSChildCare
						, SSChildWelfareServices
						, SSComments
						, SSEducation
						, SSEmployment
						, SSHomeEnvironment
						, SSHousekeeping
						, SSJob
						, SSMoneyManagement
						, SSOther
						, SSProblemSolving
						, SSSpecify
						, SSTransportation
						, STASQ
						, STASQSE
						, STComments
						, STPHQ9
						, STPSI
						, STOther
						, SupervisorObservation
						, TCAlwaysOnBack
						, TCAlwaysWithoutSharing
						, TCParticipated
						, TotalPercentageSpent
						, TPComments
						, TPDateInitiated
						, TPInitiated
						, TPNotApplicable
						, TPOngoingDiscussion
						, TPParentDeclined
						, TPPlanFinalized
						, TPTransitionCompleted
						, UpcomingProgramEvents
						, VisitLengthHour
						, VisitLengthMinute
						, VisitLocation
						, VisitStartTime
						, VisitType
						, VisitTypeComments
					  )
	values (@AdditionalComments
		  , @CAAdvocacy
		  , @CAChildSupport
		  , @CAComments
		  , @CAGoods
		  , @CAHousing
		  , @CALaborSupport
		  , @CALegal
		  , @CAOther
		  , @CAParentRights
		  , @CASpecify
		  , @CATranslation
		  , @CATransportation
		  , @CAVisitation
		  , @CDChildDevelopment
		  , @CDComments
		  , @CDFollowUpEIServices
		  , @CDOther
		  , @CDParentConcerned
		  , @CDSocialEmotionalDevelopment
		  , @CDSpecify
		  , @CDToys
		  , @CHEERSCues
		  , @CHEERSHolding
		  , @CHEERSExpression
		  , @CHEERSEmpathy
		  , @CHEERSRhythmReciprocity
		  , @CHEERSSmiles
		  , @CHEERSOverallStrengths
		  , @CHEERSAreasToFocus
		  , @CIComments
		  , @CIProblems
		  , @CIOther
		  , @CIOtherSpecify
		  , @Curriculum247Dads
		  , @CurriculumBoyz2Dads
		  , @CurriculumComments
		  , @CurriculumGreatBeginnings
		  , @CurriculumGrowingGreatKids
		  , @CurriculumHelpingBabiesLearn
		  , @CurriculumInsideOutDads
		  , @CurriculumMomGateway
		  , @CurriculumOtherSupplementalInformation
		  , @CurriculumOtherSupplementalInformationComments
		  , @CurriculumOther
		  , @CurriculumOtherSpecify
		  , @CurriculumParentsForLearning
		  , @CurriculumPartnersHealthyBaby
		  , @CurriculumPAT
		  , @CurriculumPATFocusFathers
		  , @CurriculumSanAngelo
		  , @FamilyMemberReads
		  , @FatherAdvocateFK
		  , @FatherAdvocateParticipated
		  , @FatherFigureParticipated
		  , @FFChildProtectiveIssues
		  , @FFComments
		  , @FFCommunication
		  , @FFDevelopmentalDisabilities
		  , @FFDomesticViolence
		  , @FFFamilyRelations
		  , @FFImmigration
		  , @FFMentalHealth
		  , @FFOther
		  , @FFSpecify
		  , @FFSubstanceAbuse
		  , @FGPComments
		  , @FGPDevelopActivities
		  , @FGPDiscuss
		  , @FGPGoalsCompleted
		  , @FGPNewGoal
		  , @FGPNoDiscussion
		  , @FGPProgress
		  , @FGPRevisions
		  , @FormComplete
		  , @FSWFK
		  , @GrandParentParticipated
		  , @HCBreastFeeding
		  , @HCChild
		  , @HCComments
		  , @HCDental
		  , @HCFamilyPlanning
		  , @HCFASD
		  , @HCFeeding
		  , @HCGeneral
		  , @HCLaborDelivery
		  , @HCMedicalAdvocacy
		  , @HCNutrition
		  , @HCOther
		  , @HCPrenatalCare
		  , @HCProviders
		  , @HCSafety
		  , @HCSexEducation
		  , @HCSIDS
		  , @HCSmoking
		  , @HCSpecify
		  , @HealthPC1AppearsHealthy
		  , @HealthPC1Asleep
		  , @HealthPC1CommentsGeneral
		  , @HealthPC1CommentsMedical
		  , @HealthPC1ERVisits
		  , @HealthPC1HealthConcern
		  , @HealthPC1MedicalPrenatalAppointments
		  , @HealthPC1PhysicalNeedsAppearUnmet
		  , @HealthPC1TiredIrritable
		  , @HealthPC1WithdrawnUnresponsive
		  , @HealthTCAppearsHealthy
		  , @HealthTCAsleep
		  , @HealthTCCommentsGeneral
		  , @HealthTCCommentsMedical
		  , @HealthTCERVisits
		  , @HealthTCHealthConcern
		  , @HealthTCImmunizations
		  , @HealthTCMedicalWellBabyAppointments
		  , @HealthTCPhysicalNeedsAppearUnmet
		  , @HealthTCTiredIrritable
		  , @HealthTCWithdrawnUnresponsive
		  , @HouseholdChangesComments
		  , @HouseholdChangesLeft
		  , @HouseholdChangesNew
		  , @HVCaseFK
		  , @HVLogCreator
		  , @HVSupervisorParticipated
		  , @NextScheduledVisit
		  , @NextVisitNotes
		  , @NonPrimaryFSWParticipated
		  , @NonPrimaryFSWFK
		  , @OBPParticipated
		  , @OtherLocationSpecify
		  , @OtherParticipated
		  , @PAAssessmentIssues
		  , @PAComments
		  , @PAForms
		  , @PAGroups
		  , @PAIFSP
		  , @PAIntroduceProgram
		  , @PALevelChange
		  , @PAOther
		  , @PARecreation
		  , @PASpecify
		  , @PAVideo
		  , @ParentCompletedActivity
		  , @ParentObservationsDiscussed
		  , @ParticipatedSpecify
		  , @PC1Participated
		  , @PC2Participated
		  , @PCBasicNeeds
		  , @PCChildInteraction
		  , @PCChildManagement
		  , @PCComments
		  , @PCFeelings
		  , @PCOther
		  , @PCShakenBaby
		  , @PCShakenBabyVideo
		  , @PCSpecify
		  , @PCStress
		  , @PCTechnologyEffects
		  , @POCRAskedQuestions
		  , @POCRComments
		  , @POCRContributed
		  , @POCRInterested
		  , @POCRNotInterested
		  , @POCRWantedInformation
		  , @ProgramFK
		  , @PSCComments
		  , @PSCEmergingIssues
		  , @PSCInitialDiscussion
		  , @PSCImplement
		  , @PSCOngoingDiscussion
		  , @ReferralsComments
		  , @ReferralsFollowUp
		  , @ReferralsMade
		  , @ReviewAssessmentIssues
		  , @RSATP
		  , @RSATPComments
		  , @RSSATP
		  , @RSSATPComments
		  , @RSFFF
		  , @RSFFFComments
		  , @RSEW
		  , @RSEWComments
		  , @RSNormalizing
		  , @RSNormalizingComments
		  , @RSSFT
		  , @RSSFTComments
		  , @SiblingParticipated
		  , @SiblingsObservation
		  , @SSCalendar
		  , @SSChildCare
		  , @SSChildWelfareServices
		  , @SSComments
		  , @SSEducation
		  , @SSEmployment
		  , @SSHomeEnvironment
		  , @SSHousekeeping
		  , @SSJob
		  , @SSMoneyManagement
		  , @SSOther
		  , @SSProblemSolving
		  , @SSSpecify
		  , @SSTransportation
		  , @STASQ
		  , @STASQSE
		  , @STComments
		  , @STPHQ9
		  , @STPSI
		  , @STOther
		  , @SupervisorObservation
		  , @TCAlwaysOnBack
		  , @TCAlwaysWithoutSharing
		  , @TCParticipated
		  , @TotalPercentageSpent
		  , @TPComments
		  , @TPDateInitiated
		  , @TPInitiated
		  , @TPNotApplicable
		  , @TPOngoingDiscussion
		  , @TPParentDeclined
		  , @TPPlanFinalized
		  , @TPTransitionCompleted
		  , @UpcomingProgramEvents
		  , @VisitLengthHour
		  , @VisitLengthMinute
		  , @VisitLocation
		  , @VisitStartTime
		  , @VisitType
		  , @VisitTypeComments
		   );

	select scope_identity() as [SCOPE_IDENTITY];
go
print N'Altering [dbo].[spEditHVLog]';
go
alter procedure [dbo].[spEditHVLog] (	@HVLogPK int = null
									  , @AdditionalComments varchar(max) = null
									  , @CAAdvocacy bit = null
									  , @CAChildSupport bit = null
									  , @CAComments varchar(max) = null
									  , @CAGoods bit = null
									  , @CAHousing bit = null
									  , @CALaborSupport bit = null
									  , @CALegal bit = null
									  , @CAOther bit = null
									  , @CAParentRights bit = null
									  , @CASpecify varchar(500) = null
									  , @CATranslation bit = null
									  , @CATransportation bit = null
									  , @CAVisitation bit = null
									  , @CDChildDevelopment bit = null
									  , @CDComments varchar(max) = null
									  , @CDFollowUpEIServices bit = null
									  , @CDOther bit = null
									  , @CDParentConcerned bit = null
									  , @CDSocialEmotionalDevelopment bit = null
									  , @CDSpecify varchar(500) = null
									  , @CDToys bit = null
									  , @CHEERSCues varchar(max) = null
									  , @CHEERSHolding varchar(max) = null
									  , @CHEERSExpression varchar(max) = null
									  , @CHEERSEmpathy varchar(max) = null
									  , @CHEERSRhythmReciprocity varchar(max) = null
									  , @CHEERSSmiles varchar(max) = null
									  , @CHEERSOverallStrengths varchar(max) = null
									  , @CHEERSAreasToFocus varchar(max) = null
									  , @CIComments varchar(max) = null
									  , @CIProblems bit = null
									  , @CIOther bit = null
									  , @CIOtherSpecify varchar(500) = null
									  , @Curriculum247Dads bit = null
									  , @CurriculumBoyz2Dads bit = null
									  , @CurriculumComments varchar(max) = null
									  , @CurriculumGreatBeginnings bit = null
									  , @CurriculumGrowingGreatKids bit = null
									  , @CurriculumHelpingBabiesLearn bit = null
									  , @CurriculumInsideOutDads bit = null
									  , @CurriculumMomGateway bit = null
									  , @CurriculumOtherSupplementalInformation bit = null
									  , @CurriculumOtherSupplementalInformationComments varchar(max) = null
									  , @CurriculumOther bit = null
									  , @CurriculumOtherSpecify varchar(500) = null
									  , @CurriculumParentsForLearning bit = null
									  , @CurriculumPartnersHealthyBaby bit = null
									  , @CurriculumPAT bit = null
									  , @CurriculumPATFocusFathers bit = null
									  , @CurriculumSanAngelo bit = null
									  , @FamilyMemberReads char(2) = null
									  , @FatherAdvocateFK int = null
									  , @FatherAdvocateParticipated bit = null
									  , @FatherFigureParticipated bit = null
									  , @FFChildProtectiveIssues bit = null
									  , @FFComments varchar(max) = null
									  , @FFCommunication bit = null
									  , @FFDevelopmentalDisabilities bit = null
									  , @FFDomesticViolence bit = null
									  , @FFFamilyRelations bit = null
									  , @FFImmigration bit = null
									  , @FFMentalHealth bit = null
									  , @FFOther bit = null
									  , @FFSpecify varchar(500) = null
									  , @FFSubstanceAbuse bit = null
									  , @FGPComments varchar(max) = null
									  , @FGPDevelopActivities bit = null
									  , @FGPDiscuss bit = null
									  , @FGPGoalsCompleted bit = null
									  , @FGPNewGoal bit = null
									  , @FGPNoDiscussion bit = null
									  , @FGPProgress bit = null
									  , @FGPRevisions bit = null
									  , @FormComplete bit = null
									  , @FSWFK int = null
									  , @GrandParentParticipated bit = null
									  , @HCBreastFeeding bit = null
									  , @HCChild bit = null
									  , @HCComments varchar(max) = null
									  , @HCDental bit = null
									  , @HCFamilyPlanning bit = null
									  , @HCFASD bit = null
									  , @HCFeeding bit = null
									  , @HCGeneral bit = null
									  , @HCLaborDelivery bit = null
									  , @HCMedicalAdvocacy bit = null
									  , @HCNutrition bit = null
									  , @HCOther bit = null
									  , @HCPrenatalCare bit = null
									  , @HCProviders bit = null
									  , @HCSafety bit = null
									  , @HCSexEducation bit = null
									  , @HCSIDS bit = null
									  , @HCSmoking bit = null
									  , @HCSpecify varchar(500) = null
									  , @HealthPC1AppearsHealthy bit = null
									  , @HealthPC1Asleep bit = null
									  , @HealthPC1CommentsGeneral varchar(max) = null
									  , @HealthPC1CommentsMedical varchar(max) = null
									  , @HealthPC1ERVisits bit = null
									  , @HealthPC1HealthConcern bit = null
									  , @HealthPC1MedicalPrenatalAppointments bit = null
									  , @HealthPC1PhysicalNeedsAppearUnmet bit = null
									  , @HealthPC1TiredIrritable bit = null
									  , @HealthPC1WithdrawnUnresponsive bit = null
									  , @HealthTCAppearsHealthy bit = null
									  , @HealthTCAsleep bit = null
									  , @HealthTCCommentsGeneral varchar(max) = null
									  , @HealthTCCommentsMedical varchar(max) = null
									  , @HealthTCERVisits bit = null
									  , @HealthTCHealthConcern bit = null
									  , @HealthTCImmunizations bit = null
									  , @HealthTCMedicalWellBabyAppointments bit = null
									  , @HealthTCPhysicalNeedsAppearUnmet bit = null
									  , @HealthTCTiredIrritable bit = null
									  , @HealthTCWithdrawnUnresponsive bit = null
									  , @HouseholdChangesComments varchar(max) = null
									  , @HouseholdChangesLeft bit = null
									  , @HouseholdChangesNew bit = null
									  , @HVCaseFK int = null
									  , @HVLogEditor char(10) = null
									  , @HVSupervisorParticipated bit = null
									  , @NextScheduledVisit datetime = NULL
                                      , @NextVisitNotes varchar(max) = null
									  , @NonPrimaryFSWParticipated bit = null
									  , @NonPrimaryFSWFK int = null
									  , @OBPParticipated bit = null
									  , @OtherLocationSpecify varchar(500) = null
									  , @OtherParticipated bit = null
									  , @PAAssessmentIssues bit = null
									  , @PAComments varchar(max) = null
									  , @PAForms bit = null
									  , @PAGroups bit = null
									  , @PAIFSP bit = null
									  , @PAIntroduceProgram bit = null
									  , @PALevelChange bit = null
									  , @PAOther bit = null
									  , @PARecreation bit = null
									  , @PASpecify varchar(500) = null
									  , @PAVideo bit = null
									  , @ParentCompletedActivity bit = null
									  , @ParentObservationsDiscussed bit = null
									  , @ParticipatedSpecify varchar(500) = null
									  , @PC1Participated bit = null
									  , @PC2Participated bit = null
									  , @PCBasicNeeds bit = null
									  , @PCChildInteraction bit = null
									  , @PCChildManagement bit = null
									  , @PCComments varchar(max) = null
									  , @PCFeelings bit = null
									  , @PCOther bit = null
									  , @PCShakenBaby bit = null
									  , @PCShakenBabyVideo bit = null
									  , @PCSpecify varchar(500) = null
									  , @PCStress bit = null
									  , @PCTechnologyEffects bit = null
									  , @POCRAskedQuestions bit = null
									  , @POCRComments varchar(max) = null
									  , @POCRContributed bit = null
									  , @POCRInterested bit = null
									  , @POCRNotInterested bit = null
									  , @POCRWantedInformation bit = null
									  , @ProgramFK int = null
									  , @PSCComments varchar(max) = null
									  , @PSCEmergingIssues bit = null
									  , @PSCInitialDiscussion bit = null
									  , @PSCImplement bit = null
									  , @PSCOngoingDiscussion bit = null
									  , @ReferralsComments varchar(max) = null
									  , @ReferralsFollowUp bit = null
									  , @ReferralsMade bit = null
									  , @ReviewAssessmentIssues varchar(500) = null
									  , @RSATP bit = null
									  , @RSATPComments varchar(max) = null
									  , @RSSATP bit = null
									  , @RSSATPComments varchar(max) = null
									  , @RSFFF bit = null
									  , @RSFFFComments varchar(max) = null
									  , @RSEW bit = null
									  , @RSEWComments varchar(max) = null
									  , @RSNormalizing bit = null
									  , @RSNormalizingComments varchar(max) = null
									  , @RSSFT bit = null
									  , @RSSFTComments varchar(max) = null
									  , @SiblingParticipated bit = null
									  , @SiblingsObservation varchar(max) = null
									  , @SSCalendar bit = null
									  , @SSChildCare bit = null
									  , @SSChildWelfareServices bit = null
									  , @SSComments varchar(max) = null
									  , @SSEducation bit = null
									  , @SSEmployment bit = null
									  , @SSHomeEnvironment bit = null
									  , @SSHousekeeping bit = null
									  , @SSJob bit = null
									  , @SSMoneyManagement bit = null
									  , @SSOther bit = null
									  , @SSProblemSolving bit = null
									  , @SSSpecify varchar(500) = null
									  , @SSTransportation bit = null
									  , @STASQ bit = null
									  , @STASQSE bit = null
									  , @STComments varchar(max) = null
									  , @STPHQ9 bit = null
									  , @STPSI bit = null
									  , @STOther bit = null
									  , @SupervisorObservation bit = null
									  , @TCAlwaysOnBack bit = null
									  , @TCAlwaysWithoutSharing bit = null
									  , @TCParticipated bit = null
									  , @TotalPercentageSpent int = null
									  , @TPComments varchar(max) = null
									  , @TPDateInitiated date = null
									  , @TPInitiated bit = null
									  , @TPNotApplicable int = null
									  , @TPOngoingDiscussion bit = null
									  , @TPParentDeclined bit = null
									  , @TPPlanFinalized bit = null
									  , @TPTransitionCompleted bit = null
									  , @UpcomingProgramEvents bit = null
									  , @VisitLengthHour int = null
									  , @VisitLengthMinute int = null
									  , @VisitLocation char(5) = null
									  , @VisitStartTime datetime = null
									  , @VisitType char(5) = null
									  , @VisitTypeComments varchar(max) = null
									)
as
	update HVLog
	set	   AdditionalComments = @AdditionalComments
		 , CAAdvocacy = @CAAdvocacy
		 , CAChildSupport = @CAChildSupport
		 , CAComments = @CAComments
		 , CAGoods = @CAGoods
		 , CAHousing = @CAHousing
		 , CALaborSupport = @CALaborSupport
		 , CALegal = @CALegal
		 , CAOther = @CAOther
		 , CAParentRights = @CAParentRights
		 , CASpecify = @CASpecify
		 , CATranslation = @CATranslation
		 , CATransportation = @CATransportation
		 , CAVisitation = @CAVisitation
		 , CDChildDevelopment = @CDChildDevelopment
		 , CDComments = @CDComments
		 , CDFollowUpEIServices = @CDFollowUpEIServices
		 , CDOther = @CDOther
		 , CDParentConcerned = @CDParentConcerned
		 , CDSocialEmotionalDevelopment = @CDSocialEmotionalDevelopment
		 , CDSpecify = @CDSpecify
		 , CDToys = @CDToys
		 , CHEERSCues = @CHEERSCues
		 , CHEERSHolding = @CHEERSHolding
		 , CHEERSExpression = @CHEERSExpression
		 , CHEERSEmpathy = @CHEERSEmpathy
		 , CHEERSRhythmReciprocity = @CHEERSRhythmReciprocity
		 , CHEERSSmiles = @CHEERSSmiles
		 , CHEERSOverallStrengths = @CHEERSOverallStrengths
		 , CHEERSAreasToFocus = @CHEERSAreasToFocus
		 , CIComments = @CIComments
		 , CIProblems = @CIProblems
		 , CIOther = @CIOther
		 , CIOtherSpecify = @CIOtherSpecify
		 , Curriculum247Dads = @Curriculum247Dads
		 , CurriculumBoyz2Dads = @CurriculumBoyz2Dads
		 , CurriculumComments = @CurriculumComments
		 , CurriculumGreatBeginnings = @CurriculumGreatBeginnings
		 , CurriculumGrowingGreatKids = @CurriculumGrowingGreatKids
		 , CurriculumHelpingBabiesLearn = @CurriculumHelpingBabiesLearn
		 , CurriculumInsideOutDads = @CurriculumInsideOutDads
		 , CurriculumMomGateway = @CurriculumMomGateway
		 , CurriculumOtherSupplementalInformation = @CurriculumOtherSupplementalInformation
		 , CurriculumOtherSupplementalInformationComments = @CurriculumOtherSupplementalInformationComments
		 , CurriculumOther = @CurriculumOther
		 , CurriculumOtherSpecify = @CurriculumOtherSpecify
		 , CurriculumParentsForLearning = @CurriculumParentsForLearning
		 , CurriculumPartnersHealthyBaby = @CurriculumPartnersHealthyBaby
		 , CurriculumPAT = @CurriculumPAT
		 , CurriculumPATFocusFathers = @CurriculumPATFocusFathers
		 , CurriculumSanAngelo = @CurriculumSanAngelo
		 , FamilyMemberReads = @FamilyMemberReads
		 , FatherAdvocateFK = @FatherAdvocateFK
		 , FatherAdvocateParticipated = @FatherAdvocateParticipated
		 , FatherFigureParticipated = @FatherFigureParticipated
		 , FFChildProtectiveIssues = @FFChildProtectiveIssues
		 , FFComments = @FFComments
		 , FFCommunication = @FFCommunication
		 , FFDevelopmentalDisabilities = @FFDevelopmentalDisabilities
		 , FFDomesticViolence = @FFDomesticViolence
		 , FFFamilyRelations = @FFFamilyRelations
		 , FFImmigration = @FFImmigration
		 , FFMentalHealth = @FFMentalHealth
		 , FFOther = @FFOther
		 , FFSpecify = @FFSpecify
		 , FFSubstanceAbuse = @FFSubstanceAbuse
		 , FGPComments = @FGPComments
		 , FGPDevelopActivities = @FGPDevelopActivities
		 , FGPDiscuss = @FGPDiscuss
		 , FGPGoalsCompleted = @FGPGoalsCompleted
		 , FGPNewGoal = @FGPNewGoal
		 , FGPNoDiscussion = @FGPNoDiscussion
		 , FGPProgress = @FGPProgress
		 , FGPRevisions = @FGPRevisions
		 , FormComplete = @FormComplete
		 , FSWFK = @FSWFK
		 , GrandParentParticipated = @GrandParentParticipated
		 , HCBreastFeeding = @HCBreastFeeding
		 , HCChild = @HCChild
		 , HCComments = @HCComments
		 , HCDental = @HCDental
		 , HCFamilyPlanning = @HCFamilyPlanning
		 , HCFASD = @HCFASD
		 , HCFeeding = @HCFeeding
		 , HCGeneral = @HCGeneral
		 , HCLaborDelivery = @HCLaborDelivery
		 , HCMedicalAdvocacy = @HCMedicalAdvocacy
		 , HCNutrition = @HCNutrition
		 , HCOther = @HCOther
		 , HCPrenatalCare = @HCPrenatalCare
		 , HCProviders = @HCProviders
		 , HCSafety = @HCSafety
		 , HCSexEducation = @HCSexEducation
		 , HCSIDS = @HCSIDS
		 , HCSmoking = @HCSmoking
		 , HCSpecify = @HCSpecify
		 , HealthPC1AppearsHealthy = @HealthPC1AppearsHealthy
		 , HealthPC1Asleep = @HealthPC1Asleep
		 , HealthPC1CommentsGeneral = @HealthPC1CommentsGeneral
		 , HealthPC1CommentsMedical = @HealthPC1CommentsMedical
		 , HealthPC1ERVisits = @HealthPC1ERVisits
		 , HealthPC1HealthConcern = @HealthPC1HealthConcern
		 , HealthPC1MedicalPrenatalAppointments = @HealthPC1MedicalPrenatalAppointments
		 , HealthPC1PhysicalNeedsAppearUnmet = @HealthPC1PhysicalNeedsAppearUnmet
		 , HealthPC1TiredIrritable = @HealthPC1TiredIrritable
		 , HealthPC1WithdrawnUnresponsive = @HealthPC1WithdrawnUnresponsive
		 , HealthTCAppearsHealthy = @HealthTCAppearsHealthy
		 , HealthTCAsleep = @HealthTCAsleep
		 , HealthTCCommentsGeneral = @HealthTCCommentsGeneral
		 , HealthTCCommentsMedical = @HealthTCCommentsMedical
		 , HealthTCERVisits = @HealthTCERVisits
		 , HealthTCHealthConcern = @HealthTCHealthConcern
		 , HealthTCImmunizations = @HealthTCImmunizations
		 , HealthTCMedicalWellBabyAppointments = @HealthTCMedicalWellBabyAppointments
		 , HealthTCPhysicalNeedsAppearUnmet = @HealthTCPhysicalNeedsAppearUnmet
		 , HealthTCTiredIrritable = @HealthTCTiredIrritable
		 , HealthTCWithdrawnUnresponsive = @HealthTCWithdrawnUnresponsive
		 , HouseholdChangesComments = @HouseholdChangesComments
		 , HouseholdChangesLeft = @HouseholdChangesLeft
		 , HouseholdChangesNew = @HouseholdChangesNew
		 , HVCaseFK = @HVCaseFK
		 , HVLogEditor = @HVLogEditor
		 , HVSupervisorParticipated = @HVSupervisorParticipated
		 , NextScheduledVisit = @NextScheduledVisit
		 , NextVisitNotes = @NextVisitNotes
		 , NonPrimaryFSWParticipated = @NonPrimaryFSWParticipated
		 , NonPrimaryFSWFK = @NonPrimaryFSWFK
		 , OBPParticipated = @OBPParticipated
		 , OtherLocationSpecify = @OtherLocationSpecify
		 , OtherParticipated = @OtherParticipated
		 , PAAssessmentIssues = @PAAssessmentIssues
		 , PAComments = @PAComments
		 , PAForms = @PAForms
		 , PAGroups = @PAGroups
		 , PAIFSP = @PAIFSP
		 , PAIntroduceProgram = @PAIntroduceProgram
		 , PALevelChange = @PALevelChange
		 , PAOther = @PAOther
		 , PARecreation = @PARecreation
		 , PASpecify = @PASpecify
		 , PAVideo = @PAVideo
		 , ParentCompletedActivity = @ParentCompletedActivity
		 , ParentObservationsDiscussed = @ParentObservationsDiscussed
		 , ParticipatedSpecify = @ParticipatedSpecify
		 , PC1Participated = @PC1Participated
		 , PC2Participated = @PC2Participated
		 , PCBasicNeeds = @PCBasicNeeds
		 , PCChildInteraction = @PCChildInteraction
		 , PCChildManagement = @PCChildManagement
		 , PCComments = @PCComments
		 , PCFeelings = @PCFeelings
		 , PCOther = @PCOther
		 , PCShakenBaby = @PCShakenBaby
		 , PCShakenBabyVideo = @PCShakenBabyVideo
		 , PCSpecify = @PCSpecify
		 , PCStress = @PCStress
		 , PCTechnologyEffects = @PCTechnologyEffects
		 , POCRAskedQuestions = @POCRAskedQuestions
		 , POCRComments = @POCRComments
		 , POCRContributed = @POCRContributed
		 , POCRInterested = @POCRInterested
		 , POCRNotInterested = @POCRNotInterested
		 , POCRWantedInformation = @POCRWantedInformation
		 , ProgramFK = @ProgramFK
		 , PSCComments = @PSCComments
		 , PSCEmergingIssues = @PSCEmergingIssues
		 , PSCInitialDiscussion = @PSCInitialDiscussion
		 , PSCImplement = @PSCImplement
		 , PSCOngoingDiscussion = @PSCOngoingDiscussion
		 , ReferralsComments = @ReferralsComments
		 , ReferralsFollowUp = @ReferralsFollowUp
		 , ReferralsMade = @ReferralsMade
		 , ReviewAssessmentIssues = @ReviewAssessmentIssues
		 , RSATP = @RSATP
		 , RSATPComments = @RSATPComments
		 , RSSATP = @RSSATP
		 , RSSATPComments = @RSSATPComments
		 , RSFFF = @RSFFF
		 , RSFFFComments = @RSFFFComments
		 , RSEW = @RSEW
		 , RSEWComments = @RSEWComments
		 , RSNormalizing = @RSNormalizing
		 , RSNormalizingComments = @RSNormalizingComments
		 , RSSFT = @RSSFT
		 , RSSFTComments = @RSSFTComments
		 , SiblingParticipated = @SiblingParticipated
		 , SiblingsObservation = @SiblingsObservation
		 , SSCalendar = @SSCalendar
		 , SSChildCare = @SSChildCare
		 , SSChildWelfareServices = @SSChildWelfareServices
		 , SSComments = @SSComments
		 , SSEducation = @SSEducation
		 , SSEmployment = @SSEmployment
		 , SSHomeEnvironment = @SSHomeEnvironment
		 , SSHousekeeping = @SSHousekeeping
		 , SSJob = @SSJob
		 , SSMoneyManagement = @SSMoneyManagement
		 , SSOther = @SSOther
		 , SSProblemSolving = @SSProblemSolving
		 , SSSpecify = @SSSpecify
		 , SSTransportation = @SSTransportation
		 , STASQ = @STASQ
		 , STASQSE = @STASQSE
		 , STComments = @STComments
		 , STPHQ9 = @STPHQ9
		 , STPSI = @STPSI
		 , STOther = @STOther
		 , SupervisorObservation = @SupervisorObservation
		 , TCAlwaysOnBack = @TCAlwaysOnBack
		 , TCAlwaysWithoutSharing = @TCAlwaysWithoutSharing
		 , TCParticipated = @TCParticipated
		 , TotalPercentageSpent = @TotalPercentageSpent
		 , TPComments = @TPComments
		 , TPDateInitiated = @TPDateInitiated
		 , TPInitiated = @TPInitiated
		 , TPNotApplicable = @TPNotApplicable
		 , TPOngoingDiscussion = @TPOngoingDiscussion
		 , TPParentDeclined = @TPParentDeclined
		 , TPPlanFinalized = @TPPlanFinalized
		 , TPTransitionCompleted = @TPTransitionCompleted
		 , UpcomingProgramEvents = @UpcomingProgramEvents
		 , VisitLengthHour = @VisitLengthHour
		 , VisitLengthMinute = @VisitLengthMinute
		 , VisitLocation = @VisitLocation
		 , VisitStartTime = @VisitStartTime
		 , VisitType = @VisitType
		 , VisitTypeComments = @VisitTypeComments
	where  HVLogPK = @HVLogPK;
go
print N'Creating [dbo].[spGetHVLogOldbyPK]';
go
create procedure [dbo].[spGetHVLogOldbyPK] (@HVLogOldPK int)
as
	set nocount on;

	select *
	from   HVLogOld
	where  HVLogOldPK = @HVLogOldPK;
go
print N'Creating [dbo].[spAddHVLogOld]';
go
create procedure [dbo].[spAddHVLogOld] (   @CAAdvocacy char(2) = null
										 , @CAChildSupport char(2) = null
										 , @CAGoods char(2) = null
										 , @CAHousing char(2) = null
										 , @CALaborSupport char(2) = null
										 , @CALegal char(2) = null
										 , @CAOther char(2) = null
										 , @CAParentRights char(2) = null
										 , @CASpecify varchar(500) = null
										 , @CATranslation char(2) = null
										 , @CATransportation char(2) = null
										 , @CAVisitation char(2) = null
										 , @CDChildDevelopment char(2) = null
										 , @CDOther char(2) = null
										 , @CDParentConcerned char(2) = null
										 , @CDSpecify varchar(500) = null
										 , @CDToys char(2) = null
										 , @CIProblems char(2) = null
										 , @CIOther char(2) = null
										 , @CIOtherSpecify varchar(500) = null
										 , @Curriculum247Dads bit = null
										 , @CurriculumBoyz2Dads bit = null
										 , @CurriculumGrowingGreatKids bit = null
										 , @CurriculumHelpingBabiesLearn bit = null
										 , @CurriculumInsideOutDads bit = null
										 , @CurriculumMomGateway bit = null
										 , @CurriculumOther bit = null
										 , @CurriculumOtherSpecify varchar(500) = null
										 , @CurriculumParentsForLearning bit = null
										 , @CurriculumPartnersHealthyBaby bit = null
										 , @CurriculumPAT bit = null
										 , @CurriculumPATFocusFathers bit = null
										 , @CurriculumSanAngelo bit = null
										 , @FamilyMemberReads char(2) = null
										 , @FatherAdvocateFK int = null
										 , @FatherAdvocateParticipated bit = null
										 , @FatherFigureParticipated bit = null
										 , @FFCommunication char(2) = null
										 , @FFDomesticViolence char(2) = null
										 , @FFFamilyRelations char(2) = null
										 , @FFMentalHealth char(2) = null
										 , @FFOther char(2) = null
										 , @FFSpecify varchar(500) = null
										 , @FFSubstanceAbuse char(2) = null
										 , @FSWFK int = null
										 , @GrandParentParticipated bit = null
										 , @HCBreastFeeding char(2) = null
										 , @HCChild char(2) = null
										 , @HCDental char(2) = null
										 , @HCFamilyPlanning char(2) = null
										 , @HCFASD char(2) = null
										 , @HCFeeding char(2) = null
										 , @HCGeneral char(2) = null
										 , @HCMedicalAdvocacy char(2) = null
										 , @HCNutrition char(2) = null
										 , @HCOther char(2) = null
										 , @HCPrenatalCare char(2) = null
										 , @HCProviders char(2) = null
										 , @HCSafety char(2) = null
										 , @HCSexEducation char(2) = null
										 , @HCSIDS char(2) = null
										 , @HCSmoking char(2) = null
										 , @HCSpecify varchar(500) = null
										 , @HVCaseFK int = null
										 , @HVLogCreator char(10) = null
										 , @HVSupervisorParticipated bit = null
										 , @NonPrimaryFSWParticipated bit = null
										 , @NonPrimaryFSWFK int = null
										 , @OBPParticipated bit = null
										 , @OtherLocationSpecify varchar(500) = null
										 , @OtherParticipated bit = null
										 , @PAAssessmentIssues bit = null
										 , @PAForms char(2) = null
										 , @PAGroups char(2) = null
										 , @PAIFSP char(2) = null
										 , @PAOther char(2) = null
										 , @PARecreation char(2) = null
										 , @PASpecify varchar(500) = null
										 , @PAVideo char(2) = null
										 , @ParentCompletedActivity bit = null
										 , @ParentObservationsDiscussed bit = null
										 , @ParticipatedSpecify varchar(500) = null
										 , @PC1Participated bit = null
										 , @PC2Participated bit = null
										 , @PCBasicNeeds char(2) = null
										 , @PCChildInteraction char(2) = null
										 , @PCChildManagement char(2) = null
										 , @PCFeelings char(2) = null
										 , @PCOther char(2) = null
										 , @PCShakenBaby char(2) = null
										 , @PCShakenBabyVideo char(2) = null
										 , @PCSpecify varchar(500) = null
										 , @PCStress char(2) = null
										 , @ProgramFK int = null
										 , @ReviewAssessmentIssues varchar(500) = null
										 , @SiblingParticipated bit = null
										 , @SSCalendar char(2) = null
										 , @SSChildCare char(2) = null
										 , @SSEducation char(2) = null
										 , @SSEmployment char(2) = null
										 , @SSHousekeeping char(2) = null
										 , @SSJob char(2) = null
										 , @SSMoneyManagement char(2) = null
										 , @SSOther char(2) = null
										 , @SSProblemSolving char(2) = null
										 , @SSSpecify varchar(500) = null
										 , @SSTransportation char(2) = null
										 , @SupervisorObservation bit = null
										 , @TCAlwaysOnBack bit = null
										 , @TCAlwaysWithoutSharing bit = null
										 , @TCParticipated bit = null
										 , @TotalPercentageSpent int = null
										 , @UpcomingProgramEvents bit = null
										 , @VisitLengthHour int = null
										 , @VisitLengthMinute int = null
										 , @VisitLocation char(5) = null
										 , @VisitStartTime datetime = null
										 , @VisitType char(4) = null
									   )
as
	insert into HVLogOld (	 CAAdvocacy
						   , CAChildSupport
						   , CAGoods
						   , CAHousing
						   , CALaborSupport
						   , CALegal
						   , CAOther
						   , CAParentRights
						   , CASpecify
						   , CATranslation
						   , CATransportation
						   , CAVisitation
						   , CDChildDevelopment
						   , CDOther
						   , CDParentConcerned
						   , CDSpecify
						   , CDToys
						   , CIProblems
						   , CIOther
						   , CIOtherSpecify
						   , Curriculum247Dads
						   , CurriculumBoyz2Dads
						   , CurriculumGrowingGreatKids
						   , CurriculumHelpingBabiesLearn
						   , CurriculumInsideOutDads
						   , CurriculumMomGateway
						   , CurriculumOther
						   , CurriculumOtherSpecify
						   , CurriculumParentsForLearning
						   , CurriculumPartnersHealthyBaby
						   , CurriculumPAT
						   , CurriculumPATFocusFathers
						   , CurriculumSanAngelo
						   , FamilyMemberReads
						   , FatherAdvocateFK
						   , FatherAdvocateParticipated
						   , FatherFigureParticipated
						   , FFCommunication
						   , FFDomesticViolence
						   , FFFamilyRelations
						   , FFMentalHealth
						   , FFOther
						   , FFSpecify
						   , FFSubstanceAbuse
						   , FSWFK
						   , GrandParentParticipated
						   , HCBreastFeeding
						   , HCChild
						   , HCDental
						   , HCFamilyPlanning
						   , HCFASD
						   , HCFeeding
						   , HCGeneral
						   , HCMedicalAdvocacy
						   , HCNutrition
						   , HCOther
						   , HCPrenatalCare
						   , HCProviders
						   , HCSafety
						   , HCSexEducation
						   , HCSIDS
						   , HCSmoking
						   , HCSpecify
						   , HVCaseFK
						   , HVLogCreator
						   , HVSupervisorParticipated
						   , NonPrimaryFSWParticipated
						   , NonPrimaryFSWFK
						   , OBPParticipated
						   , OtherLocationSpecify
						   , OtherParticipated
						   , PAAssessmentIssues
						   , PAForms
						   , PAGroups
						   , PAIFSP
						   , PAOther
						   , PARecreation
						   , PASpecify
						   , PAVideo
						   , ParentCompletedActivity
						   , ParentObservationsDiscussed
						   , ParticipatedSpecify
						   , PC1Participated
						   , PC2Participated
						   , PCBasicNeeds
						   , PCChildInteraction
						   , PCChildManagement
						   , PCFeelings
						   , PCOther
						   , PCShakenBaby
						   , PCShakenBabyVideo
						   , PCSpecify
						   , PCStress
						   , ProgramFK
						   , ReviewAssessmentIssues
						   , SiblingParticipated
						   , SSCalendar
						   , SSChildCare
						   , SSEducation
						   , SSEmployment
						   , SSHousekeeping
						   , SSJob
						   , SSMoneyManagement
						   , SSOther
						   , SSProblemSolving
						   , SSSpecify
						   , SSTransportation
						   , SupervisorObservation
						   , TCAlwaysOnBack
						   , TCAlwaysWithoutSharing
						   , TCParticipated
						   , TotalPercentageSpent
						   , UpcomingProgramEvents
						   , VisitLengthHour
						   , VisitLengthMinute
						   , VisitLocation
						   , VisitStartTime
						   , VisitType
						 )
	values (@CAAdvocacy
		  , @CAChildSupport
		  , @CAGoods
		  , @CAHousing
		  , @CALaborSupport
		  , @CALegal
		  , @CAOther
		  , @CAParentRights
		  , @CASpecify
		  , @CATranslation
		  , @CATransportation
		  , @CAVisitation
		  , @CDChildDevelopment
		  , @CDOther
		  , @CDParentConcerned
		  , @CDSpecify
		  , @CDToys
		  , @CIProblems
		  , @CIOther
		  , @CIOtherSpecify
		  , @Curriculum247Dads
		  , @CurriculumBoyz2Dads
		  , @CurriculumGrowingGreatKids
		  , @CurriculumHelpingBabiesLearn
		  , @CurriculumInsideOutDads
		  , @CurriculumMomGateway
		  , @CurriculumOther
		  , @CurriculumOtherSpecify
		  , @CurriculumParentsForLearning
		  , @CurriculumPartnersHealthyBaby
		  , @CurriculumPAT
		  , @CurriculumPATFocusFathers
		  , @CurriculumSanAngelo
		  , @FamilyMemberReads
		  , @FatherAdvocateFK
		  , @FatherAdvocateParticipated
		  , @FatherFigureParticipated
		  , @FFCommunication
		  , @FFDomesticViolence
		  , @FFFamilyRelations
		  , @FFMentalHealth
		  , @FFOther
		  , @FFSpecify
		  , @FFSubstanceAbuse
		  , @FSWFK
		  , @GrandParentParticipated
		  , @HCBreastFeeding
		  , @HCChild
		  , @HCDental
		  , @HCFamilyPlanning
		  , @HCFASD
		  , @HCFeeding
		  , @HCGeneral
		  , @HCMedicalAdvocacy
		  , @HCNutrition
		  , @HCOther
		  , @HCPrenatalCare
		  , @HCProviders
		  , @HCSafety
		  , @HCSexEducation
		  , @HCSIDS
		  , @HCSmoking
		  , @HCSpecify
		  , @HVCaseFK
		  , @HVLogCreator
		  , @HVSupervisorParticipated
		  , @NonPrimaryFSWParticipated
		  , @NonPrimaryFSWFK
		  , @OBPParticipated
		  , @OtherLocationSpecify
		  , @OtherParticipated
		  , @PAAssessmentIssues
		  , @PAForms
		  , @PAGroups
		  , @PAIFSP
		  , @PAOther
		  , @PARecreation
		  , @PASpecify
		  , @PAVideo
		  , @ParentCompletedActivity
		  , @ParentObservationsDiscussed
		  , @ParticipatedSpecify
		  , @PC1Participated
		  , @PC2Participated
		  , @PCBasicNeeds
		  , @PCChildInteraction
		  , @PCChildManagement
		  , @PCFeelings
		  , @PCOther
		  , @PCShakenBaby
		  , @PCShakenBabyVideo
		  , @PCSpecify
		  , @PCStress
		  , @ProgramFK
		  , @ReviewAssessmentIssues
		  , @SiblingParticipated
		  , @SSCalendar
		  , @SSChildCare
		  , @SSEducation
		  , @SSEmployment
		  , @SSHousekeeping
		  , @SSJob
		  , @SSMoneyManagement
		  , @SSOther
		  , @SSProblemSolving
		  , @SSSpecify
		  , @SSTransportation
		  , @SupervisorObservation
		  , @TCAlwaysOnBack
		  , @TCAlwaysWithoutSharing
		  , @TCParticipated
		  , @TotalPercentageSpent
		  , @UpcomingProgramEvents
		  , @VisitLengthHour
		  , @VisitLengthMinute
		  , @VisitLocation
		  , @VisitStartTime
		  , @VisitType
		   );

	select scope_identity() as [SCOPE_IDENTITY];
go
print N'Creating [dbo].[spEditHVLogOld]';
go
create procedure [dbo].[spEditHVLogOld] (	@HVLogOldPK int = null
										  , @CAAdvocacy char(2) = null
										  , @CAChildSupport char(2) = null
										  , @CAGoods char(2) = null
										  , @CAHousing char(2) = null
										  , @CALaborSupport char(2) = null
										  , @CALegal char(2) = null
										  , @CAOther char(2) = null
										  , @CAParentRights char(2) = null
										  , @CASpecify varchar(500) = null
										  , @CATranslation char(2) = null
										  , @CATransportation char(2) = null
										  , @CAVisitation char(2) = null
										  , @CDChildDevelopment char(2) = null
										  , @CDOther char(2) = null
										  , @CDParentConcerned char(2) = null
										  , @CDSpecify varchar(500) = null
										  , @CDToys char(2) = null
										  , @CIProblems char(2) = null
										  , @CIOther char(2) = null
										  , @CIOtherSpecify varchar(500) = null
										  , @Curriculum247Dads bit = null
										  , @CurriculumBoyz2Dads bit = null
										  , @CurriculumGrowingGreatKids bit = null
										  , @CurriculumHelpingBabiesLearn bit = null
										  , @CurriculumInsideOutDads bit = null
										  , @CurriculumMomGateway bit = null
										  , @CurriculumOther bit = null
										  , @CurriculumOtherSpecify varchar(500) = null
										  , @CurriculumParentsForLearning bit = null
										  , @CurriculumPartnersHealthyBaby bit = null
										  , @CurriculumPAT bit = null
										  , @CurriculumPATFocusFathers bit = null
										  , @CurriculumSanAngelo bit = null
										  , @FamilyMemberReads char(2) = null
										  , @FatherAdvocateFK int = null
										  , @FatherAdvocateParticipated bit = null
										  , @FatherFigureParticipated bit = null
										  , @FFCommunication char(2) = null
										  , @FFDomesticViolence char(2) = null
										  , @FFFamilyRelations char(2) = null
										  , @FFMentalHealth char(2) = null
										  , @FFOther char(2) = null
										  , @FFSpecify varchar(500) = null
										  , @FFSubstanceAbuse char(2) = null
										  , @FSWFK int = null
										  , @GrandParentParticipated bit = null
										  , @HCBreastFeeding char(2) = null
										  , @HCChild char(2) = null
										  , @HCDental char(2) = null
										  , @HCFamilyPlanning char(2) = null
										  , @HCFASD char(2) = null
										  , @HCFeeding char(2) = null
										  , @HCGeneral char(2) = null
										  , @HCMedicalAdvocacy char(2) = null
										  , @HCNutrition char(2) = null
										  , @HCOther char(2) = null
										  , @HCPrenatalCare char(2) = null
										  , @HCProviders char(2) = null
										  , @HCSafety char(2) = null
										  , @HCSexEducation char(2) = null
										  , @HCSIDS char(2) = null
										  , @HCSmoking char(2) = null
										  , @HCSpecify varchar(500) = null
										  , @HVCaseFK int = null
										  , @HVLogEditor char(10) = null
										  , @HVSupervisorParticipated bit = null
										  , @NonPrimaryFSWParticipated bit = null
										  , @NonPrimaryFSWFK int = null
										  , @OBPParticipated bit = null
										  , @OtherLocationSpecify varchar(500) = null
										  , @OtherParticipated bit = null
										  , @PAAssessmentIssues bit = null
										  , @PAForms char(2) = null
										  , @PAGroups char(2) = null
										  , @PAIFSP char(2) = null
										  , @PAOther char(2) = null
										  , @PARecreation char(2) = null
										  , @PASpecify varchar(500) = null
										  , @PAVideo char(2) = null
										  , @ParentCompletedActivity bit = null
										  , @ParentObservationsDiscussed bit = null
										  , @ParticipatedSpecify varchar(500) = null
										  , @PC1Participated bit = null
										  , @PC2Participated bit = null
										  , @PCBasicNeeds char(2) = null
										  , @PCChildInteraction char(2) = null
										  , @PCChildManagement char(2) = null
										  , @PCFeelings char(2) = null
										  , @PCOther char(2) = null
										  , @PCShakenBaby char(2) = null
										  , @PCShakenBabyVideo char(2) = null
										  , @PCSpecify varchar(500) = null
										  , @PCStress char(2) = null
										  , @ProgramFK int = null
										  , @ReviewAssessmentIssues varchar(500) = null
										  , @SiblingParticipated bit = null
										  , @SSCalendar char(2) = null
										  , @SSChildCare char(2) = null
										  , @SSEducation char(2) = null
										  , @SSEmployment char(2) = null
										  , @SSHousekeeping char(2) = null
										  , @SSJob char(2) = null
										  , @SSMoneyManagement char(2) = null
										  , @SSOther char(2) = null
										  , @SSProblemSolving char(2) = null
										  , @SSSpecify varchar(500) = null
										  , @SSTransportation char(2) = null
										  , @SupervisorObservation bit = null
										  , @TCAlwaysOnBack bit = null
										  , @TCAlwaysWithoutSharing bit = null
										  , @TCParticipated bit = null
										  , @TotalPercentageSpent int = null
										  , @UpcomingProgramEvents bit = null
										  , @VisitLengthHour int = null
										  , @VisitLengthMinute int = null
										  , @VisitLocation char(5) = null
										  , @VisitStartTime datetime = null
										  , @VisitType char(4) = null
										)
as
	update HVLogOld
	set	   CAAdvocacy = @CAAdvocacy
		 , CAChildSupport = @CAChildSupport
		 , CAGoods = @CAGoods
		 , CAHousing = @CAHousing
		 , CALaborSupport = @CALaborSupport
		 , CALegal = @CALegal
		 , CAOther = @CAOther
		 , CAParentRights = @CAParentRights
		 , CASpecify = @CASpecify
		 , CATranslation = @CATranslation
		 , CATransportation = @CATransportation
		 , CAVisitation = @CAVisitation
		 , CDChildDevelopment = @CDChildDevelopment
		 , CDOther = @CDOther
		 , CDParentConcerned = @CDParentConcerned
		 , CDSpecify = @CDSpecify
		 , CDToys = @CDToys
		 , CIProblems = @CIProblems
		 , CIOther = @CIOther
		 , CIOtherSpecify = @CIOtherSpecify
		 , Curriculum247Dads = @Curriculum247Dads
		 , CurriculumBoyz2Dads = @CurriculumBoyz2Dads
		 , CurriculumGrowingGreatKids = @CurriculumGrowingGreatKids
		 , CurriculumHelpingBabiesLearn = @CurriculumHelpingBabiesLearn
		 , CurriculumInsideOutDads = @CurriculumInsideOutDads
		 , CurriculumMomGateway = @CurriculumMomGateway
		 , CurriculumOther = @CurriculumOther
		 , CurriculumOtherSpecify = @CurriculumOtherSpecify
		 , CurriculumParentsForLearning = @CurriculumParentsForLearning
		 , CurriculumPartnersHealthyBaby = @CurriculumPartnersHealthyBaby
		 , CurriculumPAT = @CurriculumPAT
		 , CurriculumPATFocusFathers = @CurriculumPATFocusFathers
		 , CurriculumSanAngelo = @CurriculumSanAngelo
		 , FamilyMemberReads = @FamilyMemberReads
		 , FatherAdvocateFK = @FatherAdvocateFK
		 , FatherAdvocateParticipated = @FatherAdvocateParticipated
		 , FatherFigureParticipated = @FatherFigureParticipated
		 , FFCommunication = @FFCommunication
		 , FFDomesticViolence = @FFDomesticViolence
		 , FFFamilyRelations = @FFFamilyRelations
		 , FFMentalHealth = @FFMentalHealth
		 , FFOther = @FFOther
		 , FFSpecify = @FFSpecify
		 , FFSubstanceAbuse = @FFSubstanceAbuse
		 , FSWFK = @FSWFK
		 , GrandParentParticipated = @GrandParentParticipated
		 , HCBreastFeeding = @HCBreastFeeding
		 , HCChild = @HCChild
		 , HCDental = @HCDental
		 , HCFamilyPlanning = @HCFamilyPlanning
		 , HCFASD = @HCFASD
		 , HCFeeding = @HCFeeding
		 , HCGeneral = @HCGeneral
		 , HCMedicalAdvocacy = @HCMedicalAdvocacy
		 , HCNutrition = @HCNutrition
		 , HCOther = @HCOther
		 , HCPrenatalCare = @HCPrenatalCare
		 , HCProviders = @HCProviders
		 , HCSafety = @HCSafety
		 , HCSexEducation = @HCSexEducation
		 , HCSIDS = @HCSIDS
		 , HCSmoking = @HCSmoking
		 , HCSpecify = @HCSpecify
		 , HVCaseFK = @HVCaseFK
		 , HVLogEditor = @HVLogEditor
		 , HVSupervisorParticipated = @HVSupervisorParticipated
		 , NonPrimaryFSWParticipated = @NonPrimaryFSWParticipated
		 , NonPrimaryFSWFK = @NonPrimaryFSWFK
		 , OBPParticipated = @OBPParticipated
		 , OtherLocationSpecify = @OtherLocationSpecify
		 , OtherParticipated = @OtherParticipated
		 , PAAssessmentIssues = @PAAssessmentIssues
		 , PAForms = @PAForms
		 , PAGroups = @PAGroups
		 , PAIFSP = @PAIFSP
		 , PAOther = @PAOther
		 , PARecreation = @PARecreation
		 , PASpecify = @PASpecify
		 , PAVideo = @PAVideo
		 , ParentCompletedActivity = @ParentCompletedActivity
		 , ParentObservationsDiscussed = @ParentObservationsDiscussed
		 , ParticipatedSpecify = @ParticipatedSpecify
		 , PC1Participated = @PC1Participated
		 , PC2Participated = @PC2Participated
		 , PCBasicNeeds = @PCBasicNeeds
		 , PCChildInteraction = @PCChildInteraction
		 , PCChildManagement = @PCChildManagement
		 , PCFeelings = @PCFeelings
		 , PCOther = @PCOther
		 , PCShakenBaby = @PCShakenBaby
		 , PCShakenBabyVideo = @PCShakenBabyVideo
		 , PCSpecify = @PCSpecify
		 , PCStress = @PCStress
		 , ProgramFK = @ProgramFK
		 , ReviewAssessmentIssues = @ReviewAssessmentIssues
		 , SiblingParticipated = @SiblingParticipated
		 , SSCalendar = @SSCalendar
		 , SSChildCare = @SSChildCare
		 , SSEducation = @SSEducation
		 , SSEmployment = @SSEmployment
		 , SSHousekeeping = @SSHousekeeping
		 , SSJob = @SSJob
		 , SSMoneyManagement = @SSMoneyManagement
		 , SSOther = @SSOther
		 , SSProblemSolving = @SSProblemSolving
		 , SSSpecify = @SSSpecify
		 , SSTransportation = @SSTransportation
		 , SupervisorObservation = @SupervisorObservation
		 , TCAlwaysOnBack = @TCAlwaysOnBack
		 , TCAlwaysWithoutSharing = @TCAlwaysWithoutSharing
		 , TCParticipated = @TCParticipated
		 , TotalPercentageSpent = @TotalPercentageSpent
		 , UpcomingProgramEvents = @UpcomingProgramEvents
		 , VisitLengthHour = @VisitLengthHour
		 , VisitLengthMinute = @VisitLengthMinute
		 , VisitLocation = @VisitLocation
		 , VisitStartTime = @VisitStartTime
		 , VisitType = @VisitType
	where  HVLogOldPK = @HVLogOldPK;
go
print N'Creating [dbo].[spDelHVLogOld]';
go
create procedure [dbo].[spDelHVLogOld] (@HVLogOldPK int)
as
	delete from HVLogOld
	where HVLogOldPK = @HVLogOldPK;
go
print N'Creating trigger [dbo].[fr_delete_hvlog] on [dbo].[HVLog]';
go
create trigger [dbo].[fr_delete_hvlog]
on [dbo].[HVLog]
after delete
as
declare @PK int;

set @PK = (	  select HVLogPK
			  from	 deleted
		  );

	begin
		exec spDeleteFormReview_Trigger @FormFK = @PK
									  , @FormTypeValue = 'VL';
	end;
go
print N'Creating trigger [dbo].[fr_hvlog] on [dbo].[HVLog]';
go
create trigger [dbo].[fr_hvlog]
on [dbo].[HVLog]
after insert
as
declare @PK int;

set @PK = (	  select HVLogPK
			  from	 inserted
		  );

	begin
		exec spAddFormReview_userTRIGGER @FormFK = @PK
									   , @FormTypeValue = 'VL';
	end;
go
print N'Creating trigger [dbo].[fr_HVLog_Edit] on [dbo].[HVLog]';
go
-- =============================================
-- Author:		Chris Papas
-- Create date: 08/18/2010
-- Description:	Updates FormReview Table with form date on Supervisor Review of Form
-- =============================================
create trigger [dbo].[fr_HVLog_Edit]
on [dbo].[HVLog]
after update
as
declare @PK int;
declare @UpdatedFormDate datetime;
declare @FormTypeValue varchar(2);

select @PK = HVLogPK
from   inserted;
select @UpdatedFormDate = VisitStartTime
from   inserted;
set @FormTypeValue = 'VL';

	begin
		update FormReview
		set	   FormDate = @UpdatedFormDate
		where  FormFK = @PK
			   and FormType = @FormTypeValue;

	end;
go
print N'Creating trigger [dbo].[TR_HVLogEditDate] on [dbo].[HVLog]';
go
create trigger [dbo].[TR_HVLogEditDate]
on [dbo].[HVLog]
for update
as
update HVLog
set	   HVLog.HVLogEditDate = getdate()
from   [HVLog]
inner join Inserted on [HVLog].[HVLogPK] = Inserted.[HVLogPK];
go
print N'Adding foreign keys to [dbo].[HVLogOld]';
go
alter table [dbo].[HVLogOld] with nocheck
add constraint [FK_HVLogOld_FSWFK]
	foreign key ([FSWFK])
	references [dbo].[Worker] ([WorkerPK]);
go
alter table [dbo].[HVLogOld] with nocheck
add constraint [FK_HVLogOld_HVCaseFK]
	foreign key ([HVCaseFK])
	references [dbo].[HVCase] ([HVCasePK]);
go
alter table [dbo].[HVLogOld] with nocheck
add constraint [FK_HVLogOld_ProgramFK]
	foreign key ([ProgramFK])
	references [dbo].[HVProgram] ([HVProgramPK]);
go
print N'Adding foreign keys to [dbo].[HVLog]';
go
alter table [dbo].[HVLog] with nocheck
add constraint [FK_HVLog_FSWFK]
	foreign key ([FSWFK])
	references [dbo].[Worker] ([WorkerPK]);
go
alter table [dbo].[HVLog] with nocheck
add constraint [FK_HVLog_HVCaseFK]
	foreign key ([HVCaseFK])
	references [dbo].[HVCase] ([HVCasePK]);
go
alter table [dbo].[HVLog] with nocheck
add constraint [FK_HVLog_ProgramFK]
	foreign key ([ProgramFK])
	references [dbo].[HVProgram] ([HVProgramPK]);
go
print N'Creating extended properties';
go
exec sp_addextendedproperty N'MS_Description'
						  , N'Do not accept SVN changes'
						  , 'SCHEMA'
						  , N'dbo'
						  , 'TABLE'
						  , N'HVLogOld'
						  , 'COLUMN'
						  , N'HVLogOldPK';
go
exec sp_addextendedproperty N'MS_Description'
						  , N'Do not accept SVN changes'
						  , 'SCHEMA'
						  , N'dbo'
						  , 'TABLE'
						  , N'HVLog'
						  , 'COLUMN'
						  , N'HVLogPK';
go
EXEC pr_Disable_Triggers @disable = 1 , -- bit
                         @tableNames = N'HVLog' -- nvarchar(max)
go
UPDATE HVLog 
set VisitType = substring(VisitType, 1, 2) + '0' + substring(VisitType, 4, 1) + substring(VisitType, 3, 1) + '0', 
	FormComplete = 1
GO
EXEC pr_Disable_Triggers @disable = 0 , -- bit
                         @tableNames = N'HVLog' -- nvarchar(max)
GO
UPDATE AppOptions
SET OptionStart = '2017-09-02', OptionValue = '2017-09-02'
WHERE OptionItem = 'HVLogCutoffDate'
GO
PRINT N'Altering [dbo].[rspActiveEnrolledCaseList]'
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/11/2012
-- Description:	Active Enrolled Case List
-- mod 2013Jun24 jrobohn reformat and add case filter criteria
-- =============================================
ALTER procedure [dbo].[rspActiveEnrolledCaseList]-- Add the parameters for the stored procedure here
    @ProgramFK           varchar(max)    = null,
    @StartDt             datetime,
    @EndDt               datetime,
	@WorkerFK            int = NULL,
    @SiteFK              int = 0,
    @CaseFiltersPositive varchar(200),
    @CaseFiltersNegative varchar(200)
as

	--DECLARE @StartDt DATE = '01/01/2014'
	--DECLARE @EndDt DATE = '05/31/2015'
	--DECLARE @ProgramFK VARCHAR(MAX) = '1'
	--DECLARE @SiteFK INT = 0
	--DECLARE @CaseFiltersPositive varchar(200) = ''
	--DECLARE @WorkerFK int = NULL
    
	if @ProgramFK is null
	begin
		select @ProgramFK = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end
	set @ProgramFK = replace(@ProgramFK,'"','')
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end;
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;

	set @CaseFiltersNegative = case	when @CaseFiltersNegative = '' then null
									else @CaseFiltersNegative
							   end;

	select rtrim(PC.PCLastName)+cast(PC.PCPK as varchar(10)) [key01]
		  ,a.PC1ID
		  ,rtrim(PC.PCLastName)+', '+rtrim(PC.PCFirstName) [Name]
		  ,convert(varchar(12),PC.PCDOB,101) [DOB]
		  ,PC.SSNo [SSNo]
		  ,convert(varchar(12),Kempe.KempeDate,101) [KemptDate]
		  ,convert(varchar(12),HVScreen.ScreenDate,101) [ScreenDate]
		  ,rtrim(Worker.LastName)+', '+rtrim(Worker.FirstName) [FSW]
		  ,convert(varchar(12),Intake.IntakeDate,101) [IntakeDate]
		  ,CAST(DATEDIFF(year,PC.PCDOB,Intake.IntakeDate) as varchar(10))+' y' [AgeAtIntake]
		  ,case when a.DischargeDate is null then '' else convert(varchar(12),a.DischargeDate,101) end [CloseDate]
		  ,case when a.DischargeDate is null then 'Case Open' else rtrim(codeDischarge.DischargeReason) end [CloseReason]

		  --, CAST(DATEDIFF(month, Intake.IntakeDate, @EndDt) AS VARCHAR(10)) + ' m' [LengthInProgram]

		  ,case when a.DischargeDate is null or a.DischargeDate > @EndDt
				   then CAST(DATEDIFF(month,Intake.IntakeDate,@EndDt) as varchar(10))+' m' else
				   CAST(DATEDIFF(month,Intake.IntakeDate,a.DischargeDate) as varchar(10))+' m' end [LengthInProgram]

		  ,case when ca.TANFServices = 1 then 'Yes' else 'No' end [TANF]
		  ,case when ca.FormType = 'IN' then 'Intake' 
					else (select top 1 codeApp.AppCodeText
								from codeApp
								where ca.FormInterval = codeApp.AppCode
										and
										codeApp.AppCodeUsedWhere like '%FU%'
										and codeApp.AppCodeGroup = 'TCAge'
							) end [TANFServiceAt]
		  ,convert(varchar(12),ca.FormDate,101) [Eligible]
		  ,(select count(*)
				from HVLog
				where VisitType <> '00010'
					 and cast(VisitStartTime as date) <= @EndDt
					 and cast(VisitStartTime as date) >= b.IntakeDate
					 and HVCaseFK = b.HVCasePK
		   ) [HomeVisits]
		  -- folling fields are used for validating (to be removed)
		  ,(select top 1 ca.CommonAttributesPK
				from CommonAttributes ca
				where ca.HVCaseFK = b.HVCasePK
					 and ca.FormDate <= @EndDt
					 and ca.FormType in ('FU','IN')
				order by ca.FormDate desc
		   ) [CommonAttributesPKID]
		  ,ca.FormDate
		  ,ca.TANFServices
		  ,ca.FormType
		  ,ca.FormInterval
		  ,rtrim(T.TCLastName)+', '+rtrim(T.TCFirstName) [tcName]
		  ,convert(varchar(12),T.TCDOB,101) [tcDOB]
		  ,case when ls.SiteName is null then '' else ls.SiteName end as SiteCode

		from CaseProgram as a
			join HVCase as b on a.HVCaseFK = b.HVCasePK
			inner join dbo.SplitString(@ProgramFK,',') on a.ProgramFK = listitem
			inner join dbo.udfCaseFilters(@CaseFiltersPositive,@CaseFiltersNegative, @ProgramFK) cf on cf.HVCaseFK = a.HVCaseFK
			-- pc1 name, dob, and SS# = b.PC1FK <-> PC.PCPK -> PC.PCLastName + PC.PCFirstName, PC.PCDOB, PC.SSNo
			join PC on PC.PCPK = b.PC1FK
			-- screen date = a.HVCaseFK <-> Kempe.HVCaseFK -> Kempe.KempeDate
			join Kempe on Kempe.HVCaseFK = b.HVCasePK
			--
			-- kempe date = a.HVCaseFK <-> HVScreen.HVCaseFK -> HVScreen.ScreenDate
			join HVScreen on HVScreen.HVCaseFK = b.HVCasePK
			--
			-- FSW & site = a.CurrentFSWFK <-> Worker.WorkerPK -> Worker.LastName + Worker.FirstName ?? site ??
			left outer join Worker on Worker.WorkerPK = a.CurrentFSWFK and  Worker.WorkerPK = isnull(@WorkerFK, Worker.WorkerPK)
			join Workerprogram as wp on wp.WorkerFK = Worker.WorkerPK and wp.ProgramFK = @ProgramFK
			left outer join listSite as ls on wp.SiteFK = ls.listSitePK
			--
			-- intake date & age at intake = a.HVCaseFK <-> Intake.HVCaseFK -> Intake.IntakeDate -> (PCDOB - IntakeDate)
			join Intake on Intake.HVCaseFK = b.HVCasePK
			--
			-- closed date & close reason = a.DischargeDate, a.DischargeReason <-> codeDischarge.DischargeCode 
			--                              -> codeDischarge.DischargeReason
			left outer join codeDischarge on a.DischargeReason = codeDischarge.DischargeCode
			--
			-- length in program = @EndDt - IntakeDate

			-- TANFservices, &  eligible = CA (CommonAttributes) : a.HVCaseFK <-> CA.HVCaseFK and CA.FormType IN ('FU', 'IN')
			-- , CA.FormDate <= @EndDt and CA.TANFServices = 1 
			-- if CA.FormType = 'IN' then FormInterval = 'In Take' else CA.FormInterval <-> codeApp.AppCode and
			-- codeApp.AppCodeUsedWhere LIKE '%FU%' and AppCodeGroup = 'TCAge' -> codeApp.AppCodeText
			-- CA.FormDate = Eligible date
			-- CA.TANFServices = TANF
			-- ON ca.HVCaseFK = b.HVCasePK AND ca.FormDate <= @EndDt AND ca.FormType IN ('FU', 'IN')
			left outer join CommonAttributes ca
						   on ca.CommonAttributesPK = (select top 1 CommonAttributesPK
														   from CommonAttributes
														   where HVCaseFK = b.HVCasePK
																and FormDate <= @EndDt
																and FormType in ('FU','IN')
														   order by FormDate desc)

			-- # of actual home visits since intake = a.HVCaseFK <-> HVLog.HVCaseFK, ProgramFK, 
			-- VisitType <> '0001', VisitStartTime < @EndDt and VisitStartTime >= b.IntakeDate

			left outer join TCID T on T.HVCaseFK = b.HVCasePK and T.TCDOD is null

		where b.IntakeDate <= @EndDt
			 and (a.DischargeDate is null
			 or a.DischargeDate > @StartDt)
			 --AND a.ProgramFK = @ProgramFK
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
			 --and  Worker.WorkerPK = isnull(@WorkerFK, Worker.WorkerPK)
		--AND (@SiteFK = -1 OR (ISNULL(wp.SiteFK, -1) = @SiteFK))
		order by [key01]
GO
PRINT N'Altering [dbo].[rspAggregateCounts]'
GO
-- =============================================
-- Author:		jrobohn
-- Create date: <June 17, 2014>
-- Description:	<Aggregate Counts report aka Joy Count aka the OCFS Counts>
-- rspDataReport 22, '03/01/2013', '05/31/2013'		
-- exec [rspAggregateCounts] ',8,','10/01/2013' , '12/31/2013'
-- exec [rspAggregateCounts] ',16,','09/01/2013' , '5/31/2014'
-- exec [rspAggregateCounts] '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39','09/01/2013' , '5/31/2014'
-- =============================================
ALTER procedure [dbo].[rspAggregateCounts]
(
    @ProgramFKs				varchar(max)    = null,
    @StartDate				datetime,
    @EndDate				DATETIME 
)
as
begin

	/* 
		all screens used in this report
	*/  
	with cteAllScreens
	as
		(select HVScreenPK, ScreenDate, ScreenResult 
		  from HVScreen s
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where ScreenDate <= @EndDate 
		)
	,	  
	/*
		count of screens completed since beginning of program
	*/  
	cteScreensCompletedSinceBeginning
	as	
		(select count(HVScreenPK) as countOfScreensCompletedSinceBeginning
		  from cteAllScreens
		)
	,
	/* 
		count of screens completed in reporting period
	*/  
	cteScreensCompletedInPeriod
	as
		(select count(HVScreenPK) as countOfScreensCompletedInPeriod
		  from cteAllScreens
		  where ScreenDate between @StartDate and @EndDate 
		)
	,

	/* ---------------------------------------------- */

	/* 
		all preintake home visit counts in this report
	*/  
	cteAllPreintakeHomeVisit
	as
		(select a.PreintakePK, PIDate, ISNULL(PIVisitMade,0) VisitMode, 
		CASE WHEN (CaseStatus = '02' AND ISNULL(PIVisitMade, 0) > 0) THEN 1 ELSE 0 END Enrolled
		  from Preintake AS a
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where PIDate <= @EndDate 
		)
	,	  
	/*
		count of preintake home visit since beginning of program
	*/  
	ctePreintakeHomeVisitSinceBeginning
	as	
		(select (SUM(VisitMode) - SUM(Enrolled)) as countOfPreintakeHomeVisitSinceBeginning
		  from cteAllPreintakeHomeVisit
		)
	,
	/* 
		count of preintake home visit in reporting period
	*/  
	ctePreintakeHomeVisitInPeriod
	as
		(select (SUM(VisitMode) - SUM(Enrolled)) countOfPreintakeHomeVisitInPeriod
		  from cteAllPreintakeHomeVisit
		  where PIDate between @StartDate and @EndDate 
		)
	,

	/* ---------------------------------------------- */


	/* 
		count of positive screens since beginning of program
	*/  
	ctePositiveScreensSinceBeginning
	as
		(select count(HVScreenPK) as countOfPositiveScreensSinceBeginning
		  from cteAllScreens
		  where ScreenResult = '1'
		)
	,
	/* 
		count of negative screens since beginning of program
	*/  
	cteNegativeScreensSinceBeginning
	as
		(select count(HVScreenPK) as countOfNegativeScreensSinceBeginning
		  from cteAllScreens
		  where ScreenResult = '0'
		)
	,
	/* 
		count of positive screens completed in reporting period
	*/  
	ctePositiveScreensInPeriod
	as
		(select count(HVScreenPK) as countOfPositiveScreensInPeriod
		  from cteAllScreens
		  where ScreenDate between @StartDate and @EndDate and
				ScreenResult = '1'
		)
	,
	/* 
		count of negative screens completed in reporting period
	*/  
	cteNegativeScreensInPeriod
	as
		(select count(HVScreenPK) as countOfNegativeScreensInPeriod
	  		  from cteAllScreens
		  where ScreenDate between @StartDate and @EndDate and
				ScreenResult = '0'
		)
	,
	/* 
		count of Kempes completed since beginning of program
	*/  
	cteAllKempes
	as	
		(select KempePK, KempeDate, KempeResult, FOBPresent
		  from Kempe k
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where KempeDate <= @EndDate 
		)
	,
	/* 
		count of Kempes completed since beginning of program
	*/  
	cteKempesCompletedSinceBeginning
	as	
		(select count(KempePK) as countOfKempesCompletedSinceBeginning
		  from cteAllKempes
		)
	,
	/* 
		count of Kempes completed in reporting period
	*/  
	cteKempesCompletedInPeriod
	as
		(select count(KempePK) as countOfKempesCompletedInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate 
		)
	,
	/* 
		count of positive Kempes since beginning of program
	*/  
	ctePositiveKempesSinceBeginning
	as
		(select count(KempePK) as countOfPositiveKempesSinceBeginning
		  from cteAllKempes
		  where KempeResult = 1
		)
	,
	/* 
		count of negative Kempes since beginning of program
	*/  
	cteNegativeKempesSinceBeginning
	as
		(select count(KempePK) as countOfNegativeKempesSinceBeginning
		  from cteAllKempes
		  where KempeResult = 0
		)
	,

	/* 
		count of FOB present Kempes since beginning of program
	*/  
	cteFOBPresentKempesSinceBeginning
	as
		(select count(KempePK) as countOfFOBPresentKempesSinceBeginning
		  from cteAllKempes
		  where FOBPresent = 1
		)
	,


	/* 
		count of positive Kempes completed in reporting period
	*/  
	ctePositiveKempesInPeriod
	as
		(select count(KempePK) as countOfPositiveKempesInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate and
				KempeResult = 1
		)
	,
	/* 
		count of negative Kempes completed in reporting period
	*/  
	cteNegativeKempesInPeriod
	as
		(select count(KempePK) as countOfNegativeKempesInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate and
				KempeResult = 0
		)
	,

	/* 
		count of FOB present Kempes completed in reporting period
	*/  
	cteFOBPresentKempesInPeriod
	as
		(select count(KempePK) as countOfFOBPresentKempesInPeriod
		  from cteAllKempes
		  where KempeDate between @StartDate and @EndDate and
				FOBPresent = 1
		)
	,

	/* 
		count of familes enrolled since beginning of program
	*/  
	cteFamiliesEnrolledSinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledSinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate
		)
	,
	/* 
		count of familes enrolled prenatally since beginning of program
	*/  
	cteFamiliesEnrolledPrenatallySinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPrenatallySinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate and
				isnull(TCDOB, EDC) > IntakeDate
		)
	,
	/* 
		count of familes enrolled postnatally since beginning of program
	*/  
	cteFamiliesEnrolledPostnatallySinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPostnatallySinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate and
				isnull(TCDOB, EDC) <= IntakeDate
		)
	,
	/* 
		count of familes enrolled in reporting period
	*/  
	cteFamiliesEnrolledInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate between @StartDate and @EndDate
		)
	,
	/* 
		count of familes enrolled prenatally in reporting period
	*/  
	cteFamiliesEnrolledPrenatallyInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPrenatallyInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate between @StartDate and @EndDate and
				isnull(TCDOB, EDC) > IntakeDate
		)
	,
	/* 
		count of familes enrolled postnatally in reporting period
	*/  
	cteFamiliesEnrolledPostnatallyInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledPostnatallyInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate between @StartDate and @EndDate and
				isnull(TCDOB, EDC) <= IntakeDate
		)
	,
	/* 
		count of familes served since beginning of program
	*/  
	cteFamiliesServedSinceBeginning
	as	
		(select count(HVCasePK) as countOfFamiliesServedSinceBeginning
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate 
		)
	,
	/* 
		count of familes served in reporting period
	*/  
	cteFamiliesServedInPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesServedInPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate 
				and (DischargeDate is null or DischargeDate >= @StartDate)
		)
	,
	/* 
		count of familes enrolled at end of reporting period
	*/  
	cteFamiliesEnrolledAtEndOfPeriod
	as	
		(select count(HVCasePK) as countOfFamiliesEnrolledAtEndOfPeriod
		  from HVCase c
		  inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where IntakeDate <= @EndDate and 
				(DischargeDate is null or DischargeDate > @EndDate)
		)
	,
	/* 
		count of target children born since beginning of program
	*/  
	cteTargetChildrenBornSinceBeginning
	as
		(select count(TCIDPK) as countOfTargetChildrenBornSinceBeginning 
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and T.TCDOB <= @EndDate
		)
	,
	/* 
		count of target children born in reporting period
	*/  
	cteTargetChildrenBornInPeriod
	as
		(select count(TCIDPK) as countOfTargetChildrenBornInPeriod 
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and T.TCDOB between @StartDate and @EndDate
		)
	--,
	--/* 
	--	count of other target children served since beginning of program
	--*/  
	--cteOtherTargetChildrenServedSinceBeginning
	--as
	--	(select count(TCIDPK) as countOfOtherTargetChildrenServedSinceBeginning
	--	  from HVCase
	--	  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
	--	  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
	--	  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
	--	  where IntakeDate <= @EndDate 
	--			and T.TCDOB < @StartDate
	--	)
	,
	/* 
		count of other target children served since beginning of program
	*/  
	cteOtherTargetChildrenServedInPeriod
	as
		(select count(TCIDPK) as countOfOtherTargetChildrenServedInPeriod 
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and (DischargeDate is null or DischargeDate >= @StartDate)
				and T.TCDOB < @StartDate
		)
	,
	/* 
		count of other children served since beginning of program
	*/  
	cteOtherChildrenServedSinceBeginning
	as
		(select count(OtherChildPK) as countOfOtherChildrenServedSinceBeginning
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  --inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join OtherChild oc on oc.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				-- and (DischargeDate is null or DischargeDate >= @StartDate)
		  --and T.TCDOB<='09/30/13'
		  and oc.LivingArrangement='01'
		)
	,
	/* 
		count of other children served in reporting period
	*/  
	cteOtherChildrenServedInPeriod
	as
		(select count(OtherChildPK) as countOfOtherChildrenServedInPeriod
		  from HVCase
		  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
		  --inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
		  inner join OtherChild oc on oc.HVCaseFK = HVCase.HVCasePK
		  inner join dbo.SplitString(@ProgramFKs, ',') ss on ListItem = cp.ProgramFK
		  where IntakeDate <= @EndDate 
				and (DischargeDate is null or DischargeDate >= @StartDate)
		  --and T.TCDOB<='09/30/13'
		  and oc.LivingArrangement='01'
		)
	,
	/* 
		count of home visit logs since beginning of program
	*/ 
	cteHomeVisitLogsSinceBeginning
	as
		(select count(HVLogPK) as countOfHomeVisitLogsSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
		)
	,
	/* 
		count of completed home visit logs since beginning of program
	*/ 
	cteCompletedHomeVisitLogsSinceBeginning
	as
		(select count(HVLogPK) as countOfCompletedHomeVisitLogsSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
				and VisitType <> '00010'
		)
	,
	/* 
		count of attempted home visit logs since beginning of program
	*/ 
	cteAttemptedHomeVisitLogsSinceBeginning
	as
		(select count(HVLogPK) as countOfAttemptedHomeVisitLogsSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
				and VisitType = '00010'
		)
	,
	/* 
		count of home visit logs in reporting period
	*/ 
	cteHomeVisitLogsInPeriod
	as
		(select count(HVLogPK) as countOfHomeVisitLogsInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate
		)
	,
	/* 
		count of completed home visit logs in reporting period
	*/ 
	cteCompletedHomeVisitLogsInPeriod
	as
		(select count(HVLogPK) as countOfCompletedHomeVisitLogsInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate
				and VisitType <> '00010'
		)
	,
	/* 
		count of attempted home visit logs in reporting period
	*/ 
	cteAttemptedHomeVisitLogsInPeriod
	as
		(select count(HVLogPK) as countOfAttemptedHomeVisitLogsInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate and 
				VisitType = '00010'
		)
	,
	/* 
		count of families with at least one home visit log since beginning of program
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitSinceBeginning
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate
		)
	,
	/* 
		count of families with at least one home visit log in reporting period
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitInPeriod
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate
		)
	,
	/* 
		count of families with at least one home visit log since beginning of program
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) <= @EndDate and
				(OBPParticipated = 1 or FatherFigureParticipated = 1)
		)
	,
	/* 
		count of families with at least one home visit log in reporting period
	*/ 
	cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
	as
		(select count(distinct HVCaseFK) as countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
		  from HVLog
		  inner join SplitString(@ProgramFKs, ',') ss on ListItem = ProgramFK
		  where convert(date, VisitStartTime) between @StartDate and @EndDate and
				(OBPParticipated = 1 or FatherFigureParticipated = 1)
		)
	, 
	cteFinal 
	as
		(select /* Screens completed */
				countOfScreensCompletedSinceBeginning
				, 1 as pctOfScreensCompletedSinceBeginning
				, countOfScreensCompletedInPeriod
				, 1  as pctOfScreensCompletedInPeriod
				, countOfPositiveScreensSinceBeginning
				, case when countOfScreensCompletedSinceBeginning is null or countOfScreensCompletedSinceBeginning = 0 then 0 
						else round(countOfPositiveScreensSinceBeginning / (countOfScreensCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfPositiveScreensSinceBeginning
				, countOfNegativeScreensSinceBeginning
				, case when countOfScreensCompletedSinceBeginning is null or countOfScreensCompletedSinceBeginning = 0 then 0
						else round(countOfNegativeScreensSinceBeginning / (countOfScreensCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfNegativeScreensSinceBeginning
				
				/* Positive screens */
				, countOfPositiveScreensInPeriod
				, case when countOfScreensCompletedInPeriod is null or countOfScreensCompletedInPeriod = 0 then 0
						else round(countOfPositiveScreensInPeriod / (countOfScreensCompletedInPeriod * 1.0000), 2) 
					end as pctOfPositiveScreensInPeriod

				/* Negative screens */
				, countOfNegativeScreensInPeriod
				, case when countOfScreensCompletedInPeriod is null or countOfScreensCompletedInPeriod = 0 then 0
						else round(countOfNegativeScreensInPeriod / (countOfScreensCompletedInPeriod * 1.0000), 2) 
					end as pctOfNegativeScreensInPeriod
				
				/* Kempes completed */
				, countOfKempesCompletedSinceBeginning
				, 1 as pctOfKempesCompletedSinceBeginning
				, countOfKempesCompletedInPeriod
				, 1 as pctOfKempesCompletedInPeriod
				
				/* Positive Kempes */
				, countOfPositiveKempesSinceBeginning
				, case when countOfKempesCompletedSinceBeginning is null or countOfKempesCompletedSinceBeginning = 0 then 0
						else round(countOfPositiveKempesSinceBeginning / (countOfKempesCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfPositiveKempesSinceBeginning
				, countOfPositiveKempesInPeriod
				, case when countOfKempesCompletedInPeriod is null or countOfKempesCompletedInPeriod = 0 then 0
						else round(countOfPositiveKempesInPeriod / (countOfKempesCompletedInPeriod * 1.0000), 2) 
					end as pctOfPositiveKempesInPeriod

				/* Negative Kempes */
				, countOfNegativeKempesSinceBeginning
				, case when countOfKempesCompletedSinceBeginning is null or countOfKempesCompletedSinceBeginning = 0 then 0
						else round(countOfNegativeKempesSinceBeginning / (countOfKempesCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfNegativeKempesSinceBeginning
				, countOfNegativeKempesInPeriod
				, case when countOfKempesCompletedInPeriod is null or countOfKempesCompletedInPeriod = 0 then 0
						else round(countOfNegativeKempesInPeriod / (countOfKempesCompletedInPeriod * 1.0000), 2) 
					end as pctOfNegativeKempesInPeriod

				/* Father of Baby Present Kempes */
				, countOfFOBPresentKempesSinceBeginning
				, case when countOfKempesCompletedSinceBeginning is null or countOfKempesCompletedSinceBeginning = 0 then 0
						else round(countOfFOBPresentKempesSinceBeginning / (countOfKempesCompletedSinceBeginning * 1.0000), 2) 
					end as pctOfFOBPresentKempesSinceBeginning

				, countOfFOBPresentKempesInPeriod
				, case when countOfKempesCompletedInPeriod is null or countOfKempesCompletedInPeriod = 0 then 0
						else round(countOfFOBPresentKempesInPeriod / (countOfKempesCompletedInPeriod * 1.0000), 2) 
					end as pctOfFOBPresentKempesInPeriod

				, countOfPreintakeHomeVisitInPeriod
				, countOfPreintakeHomeVisitSinceBeginning

				/* Enrolled Families */
				/* Since Beginning */
				, countOfFamiliesEnrolledSinceBeginning
				, 1 as pctOfFamiliesEnrolledSinceBeginning
				/* Prenatally */
				, countOfFamiliesEnrolledPrenatallySinceBeginning
				, case when countOfFamiliesEnrolledSinceBeginning is null or countOfFamiliesEnrolledSinceBeginning = 0 then 0
						else round(countOfFamiliesEnrolledPrenatallySinceBeginning / (countOfFamiliesEnrolledSinceBeginning * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPrenatallySinceBeginning
				/* Postnatally */
				, countOfFamiliesEnrolledPostnatallySinceBeginning
				, case when countOfFamiliesEnrolledSinceBeginning is null or countOfFamiliesEnrolledSinceBeginning = 0 then 0
						else round(countOfFamiliesEnrolledPostnatallySinceBeginning / (countOfFamiliesEnrolledSinceBeginning * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPostnatallySinceBeginning
				/* In Period */
				, countOfFamiliesEnrolledInPeriod
				, 1 as pctOfFamiliesEnrolledInPeriod
				/* Prenatally */
				, countOfFamiliesEnrolledPrenatallyInPeriod
				, case when countOfFamiliesEnrolledInPeriod is null or countOfFamiliesEnrolledInPeriod = 0 then 0
						else round(countOfFamiliesEnrolledPrenatallyInPeriod / (countOfFamiliesEnrolledInPeriod * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPrenatallyInPeriod
				/* Postnatally */
				, countOfFamiliesEnrolledPostnatallyInPeriod
				, case when countOfFamiliesEnrolledInPeriod is null or countOfFamiliesEnrolledInPeriod = 0 then 0
						else round(countOfFamiliesEnrolledPostnatallyInPeriod / (countOfFamiliesEnrolledInPeriod * 1.0000), 2) 
					end as pctOfFamiliesEnrolledPostnatallyInPeriod
			
				/* Families Served */
				, countOfFamiliesServedSinceBeginning
				, countOfFamiliesServedInPeriod
				, countOfFamiliesEnrolledAtEndOfPeriod
	
				/* Target Children born and served */
				, countOfTargetChildrenBornSinceBeginning
				, countOfTargetChildrenBornInPeriod
				, 0 as countOfOtherTargetChildrenServedSinceBeginning
				--, replace(convert(varchar(20), (cast(countOfOtherTargetChildrenServedSinceBeginning as money)), 1), '.00', '') as countOfOtherTargetChildrenServedSinceBeginning
				, countOfOtherTargetChildrenServedInPeriod
				, countOfOtherChildrenServedSinceBeginning
				, countOfOtherChildrenServedInPeriod

				/* Home Visit Logs*/
				/* Since Beginning */
				, countOfHomeVisitLogsSinceBeginning
				, 1 as pctOfHomeVisitLogsSinceBeginning
				/* Completed */
				, countOfCompletedHomeVisitLogsSinceBeginning
				, case when countOfHomeVisitLogsSinceBeginning is null or countOfHomeVisitLogsSinceBeginning = 0 then 0
						else round(countOfCompletedHomeVisitLogsSinceBeginning / (countOfHomeVisitLogsSinceBeginning * 1.0000), 2) 
					end as pctOfCompletedHomeVisitLogsSinceBeginning
				/* Attempted */
				, countOfAttemptedHomeVisitLogsSinceBeginning
				, case when countOfHomeVisitLogsSinceBeginning is null or countOfHomeVisitLogsSinceBeginning = 0 then 0
						else round(countOfAttemptedHomeVisitLogsSinceBeginning / (countOfHomeVisitLogsSinceBeginning * 1.0000), 2) 
					end as pctOfAttemptedHomeVisitLogsSinceBeginning
				/* In Period */
				, countOfHomeVisitLogsInPeriod
				, 1 as pctOfHomeVisitLogsInPeriod
				/* Completed */
				, countOfCompletedHomeVisitLogsInPeriod
				, case when countOfHomeVisitLogsInPeriod is null or countOfHomeVisitLogsInPeriod = 0 then 0
						else round(countOfCompletedHomeVisitLogsInPeriod / (countOfHomeVisitLogsInPeriod * 1.0000), 2) 
					end as pctOfCompletedHomeVisitLogsInPeriod
				/* Attempted */
				, countOfAttemptedHomeVisitLogsInPeriod
				, case when countOfHomeVisitLogsInPeriod is null or countOfHomeVisitLogsInPeriod = 0 then 0
						else round(countOfAttemptedHomeVisitLogsInPeriod / (countOfHomeVisitLogsInPeriod * 1.0000), 2) 
					end as pctOfAttemptedHomeVisitLogsInPeriod

				/* Families with at least one */
				, countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
				, countOfFamiliesWithAtLeastOneHomeVisitInPeriod
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitInPeriod
				
				/* At least one with OBP or father/father figure */
				, countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
				/* ('+replace(convert(varchar(20), cast(round(countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning / 
																(countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning * 1.0000) * 100, 0) 
														as money)), '.00', '') + '%)' as pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning */
				, countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
				--, 0 as pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
		from cteScreensCompletedSinceBeginning
		inner join cteScreensCompletedInPeriod on 1=1
		inner join ctePositiveScreensSinceBeginning on 1=1
		inner join cteNegativeScreensSinceBeginning on 1=1
		inner join ctePositiveScreensInPeriod on 1=1
		inner join cteNegativeScreensInPeriod on 1=1
		inner join cteKempesCompletedSinceBeginning on 1=1
		inner join cteKempesCompletedInPeriod on 1=1

		inner join ctePreintakeHomeVisitInPeriod on 1=1
		inner join ctePreintakeHomeVisitSinceBeginning on 1=1

		inner join ctePositiveKempesSinceBeginning on 1=1
		inner join cteNegativeKempesSinceBeginning on 1=1
		inner join cteFOBPresentKempesSinceBeginning on 1=1

		inner join ctePositiveKempesInPeriod on 1=1
		inner join cteNegativeKempesInPeriod on 1=1
		inner join cteFOBPresentKempesInPeriod on 1=1

		inner join cteFamiliesEnrolledSinceBeginning on 1=1
		inner join cteFamiliesEnrolledPrenatallySinceBeginning on 1=1
		inner join cteFamiliesEnrolledPostnatallySinceBeginning on 1=1
		inner join cteFamiliesEnrolledInPeriod on 1=1
		inner join cteFamiliesEnrolledPrenatallyInPeriod on 1=1
		inner join cteFamiliesEnrolledPostnatallyInPeriod on 1=1
		inner join cteFamiliesServedSinceBeginning on 1=1
		inner join cteFamiliesServedInPeriod on 1=1
		inner join cteFamiliesEnrolledAtEndOfPeriod on 1=1
		inner join cteTargetChildrenBornSinceBeginning on 1=1
		inner join cteTargetChildrenBornInPeriod on 1=1
		--inner join cteOtherTargetChildrenServedSinceBeginning on 1=1
		inner join cteOtherTargetChildrenServedInPeriod on 1=1
		inner join cteOtherChildrenServedSinceBeginning on 1=1
		inner join cteOtherChildrenServedInPeriod on 1=1
		inner join cteHomeVisitLogsSinceBeginning on 1=1
		inner join cteCompletedHomeVisitLogsSinceBeginning on 1=1
		inner join cteAttemptedHomeVisitLogsSinceBeginning on 1=1
		inner join cteHomeVisitLogsInPeriod on 1=1
		inner join cteCompletedHomeVisitLogsInPeriod on 1=1
		inner join cteAttemptedHomeVisitLogsInPeriod on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitSinceBeginning on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitInPeriod on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning on 1=1
		inner join cteFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod on 1=1
	)

	select countOfScreensCompletedSinceBeginning
		 , pctOfScreensCompletedSinceBeginning
		 , countOfScreensCompletedInPeriod
		 , pctOfScreensCompletedInPeriod
		 , countOfPositiveScreensSinceBeginning
		 , pctOfPositiveScreensSinceBeginning
		 , countOfNegativeScreensSinceBeginning
		 , pctOfNegativeScreensSinceBeginning
		 , countOfPositiveScreensInPeriod
		 , pctOfPositiveScreensInPeriod
		 , countOfNegativeScreensInPeriod
		 , pctOfNegativeScreensInPeriod
		 , countOfKempesCompletedSinceBeginning
		 , pctOfKempesCompletedSinceBeginning
		 , countOfKempesCompletedInPeriod
		 , pctOfKempesCompletedInPeriod
		 , countOfPositiveKempesSinceBeginning
		 , pctOfPositiveKempesSinceBeginning
		 , countOfPositiveKempesInPeriod
		 , pctOfPositiveKempesInPeriod
		 , countOfNegativeKempesSinceBeginning
		 , pctOfNegativeKempesSinceBeginning
		 , countOfNegativeKempesInPeriod
		 , pctOfNegativeKempesInPeriod
		 , countOfFOBPresentKempesSinceBeginning
		 , pctOfFOBPresentKempesSinceBeginning
		 , countOfFOBPresentKempesInPeriod
		 , pctOfFOBPresentKempesInPeriod
		 , countOfPreintakeHomeVisitInPeriod
		 , countOfPreintakeHomeVisitSinceBeginning
		 , countOfFamiliesEnrolledSinceBeginning
		 , pctOfFamiliesEnrolledSinceBeginning
		 , countOfFamiliesEnrolledPrenatallySinceBeginning
		 , pctOfFamiliesEnrolledPrenatallySinceBeginning
		 , countOfFamiliesEnrolledPostnatallySinceBeginning
		 , pctOfFamiliesEnrolledPostnatallySinceBeginning
		 , countOfFamiliesEnrolledInPeriod
		 , pctOfFamiliesEnrolledInPeriod
		 , countOfFamiliesEnrolledPrenatallyInPeriod
		 , pctOfFamiliesEnrolledPrenatallyInPeriod
		 , countOfFamiliesEnrolledPostnatallyInPeriod
		 , pctOfFamiliesEnrolledPostnatallyInPeriod
		 , countOfFamiliesServedSinceBeginning
		 , countOfFamiliesServedInPeriod
		 , countOfFamiliesEnrolledAtEndOfPeriod
		 , countOfTargetChildrenBornSinceBeginning
		 , countOfTargetChildrenBornInPeriod
		 , countOfOtherTargetChildrenServedSinceBeginning
		 , countOfOtherTargetChildrenServedInPeriod
		 , countOfOtherChildrenServedSinceBeginning
		 , countOfOtherChildrenServedInPeriod
		 , countOfHomeVisitLogsSinceBeginning
		 , pctOfHomeVisitLogsSinceBeginning
		 , countOfCompletedHomeVisitLogsSinceBeginning
		 , pctOfCompletedHomeVisitLogsSinceBeginning
		 , countOfAttemptedHomeVisitLogsSinceBeginning
		 , pctOfAttemptedHomeVisitLogsSinceBeginning
		 , countOfHomeVisitLogsInPeriod
		 , pctOfHomeVisitLogsInPeriod
		 , countOfCompletedHomeVisitLogsInPeriod
		 , pctOfCompletedHomeVisitLogsInPeriod
		 , countOfAttemptedHomeVisitLogsInPeriod
		 , pctOfAttemptedHomeVisitLogsInPeriod
		 , countOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
		 --, pctOfFamiliesWithAtLeastOneHomeVisitSinceBeginning
		 , countOfFamiliesWithAtLeastOneHomeVisitInPeriod
		 --, pctOfFamiliesWithAtLeastOneHomeVisitInPeriod
		 , countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
		 --, pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherSinceBeginning
		 , countOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod
		 --, pctOfFamiliesWithAtLeastOneHomeVisitIncludingOBPOrFatherInPeriod 
	from cteFinal

end

/*
	exec Data-Request-From-OCFS
*/
/*
FW: data request

At some point, could you check my numbers. Bernadette doesnt need this until the tenth.
Here are my numbers and my code:
Served:5600
Tcs:5009
Otherchild:2545

<snip>
------
For 10/1/2012-9/30/2013 can I have:
 
number of families served
number of target children
and number of other children in the household who received services.
I need this data by Friday  January 10th, 2014.
 
Thanks!
Bernadette
*/

/*
SELECT count(HVCasePK) 
		--,[HVCasePK]
		--,[CaseProgress]
		--,[Confidentiality]
		--,[CPFK]
		--,[DateOBPAdded]
		--,[EDC]
		--,[FFFK]
		--,[FirstChildDOB]
		--,[FirstPrenatalCareVisit]
		--,[FirstPrenatalCareVisitUnknown]
		--,[HVCaseCreateDate]
		--,[HVCaseCreator]
		--,[HVCaseEditDate]
		--,[HVCaseEditor]
		--,[InitialZip]
		--,[IntakeDate]
		--,[IntakeLevel]
		--,[IntakeWorkerFK]
		--,[KempeDate]
		--,[OBPInformationAvailable]
		--,[OBPFK]
		--,[OBPinHomeIntake]
		--,[OBPRelation2TC]
		--,[PC1FK]
		--,[PC1Relation2TC]
		--,[PC1Relation2TCSpecify]
		--,[PC2FK]
		--,[PC2inHomeIntake]
		--,[PC2Relation2TC]
		--,[PC2Relation2TCSpecify]
		--,[PrenatalCheckupsB4]
		--,[ScreenDate]
		--,t.TCDOB
		--,[TCNumber]
		--,oc.LivingArrangement
  FROM HVCase
  inner join CaseProgram cp on cp.HVCaseFK = HVCase.HVCasePK
  inner join TCID T on T.HVCaseFK = HVCase.HVCasePK
  --inner join OtherChild oc on oc.HVCaseFK = HVCase.HVCasePK
  where IntakeDate<='09/30/13' and (DischargeDate is null or DischargeDate>='10/01/12')
  --and T.TCDOB<='09/30/13'
  --and oc.LivingArrangement='01'
*/
--use HFNY
--go

--declare @StartDate datetime
--declare @EndDate datetime
--declare @ProgramFKs varchar(200)

--set @StartDate = '20130101'
--set @EndDate = '20131231'
--set @ProgramFKs = '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39';

--select convert(varchar(12), @StartDate, 101) as StartDate
--		, convert(varchar(12), @EndDate, 101) as EndDate;
GO
PRINT N'Altering [dbo].[rspCapacityBuilding]'
GO
-- =============================================
-- Author:    dar chen
-- Create date: Feb/25/2015
-- Description: <Report: Capacity Building>
-- =============================================
ALTER procedure [dbo].[rspCapacityBuilding]
(
    @startDt    DATE,
    @endDT      DATE,
    @ProgramFK varchar(max) = null
)
as

--DECLARE @startDT DATE = '02/25/2014'
--DECLARE @endDT DATE = '08/25/2014'
--DECLARE @ProgramFK varchar(max) = '1'

DECLARE @defaultDT DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @startDT) , 0)))

SET @endDT = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 2 , 0)))
SET @startDT = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 14 , 0)))

DECLARE @endDTRetention DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 11 , 0)))
DECLARE @startDTRetention DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 23 , 0)))

DECLARE @endDT3 DATE = @defaultDT
DECLARE @startDT3 DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @endDT3) , 0)))

DECLARE @endDT2 DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 0 , 0)))
DECLARE @startDT2 DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 1 , 0)))

DECLARE @endDT1 DATE = CONVERT(DATE,DATEADD(MS, -3, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 1 , 0)))
DECLARE @startDT1 DATE = CONVERT(DATE,DATEADD(MS, 0, DATEADD(MM, DATEDIFF(MM, 0, @defaultDT) - 2 , 0)))


	set nocount on;

	-- Insert statements for procedure here
	if @ProgramFK is null
	begin
		select @ProgramFK =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
						from HVProgram for xml path ('')),2,8000)
	end
	set @ProgramFK = REPLACE(@ProgramFK,'"','')
	
	;
	with 

	ctemainAgain
	as
	(
	select pc1id
		  ,case when levelname in ('Preintake','Preintake-enroll') then 1 else 0 end as PreintakeCount
		  ,CaseProgram.ProgramFK
		  ,ProgramCapacity
		from
			(select * from codeLevel where caseweight is not null) cl
			left outer join caseprogram on caseprogram.currentLevelFK = cl.codeLevelPK
			inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			inner join worker on caseprogram.currentFSWFK = worker.workerpk
			inner join workerprogram wp on wp.workerfk = worker.workerpk AND wp.programfk = listitem
			left outer join (select workerpk ,firstName as supfname
							,LastName as suplname from worker) sw on wp.supervisorfk = sw.workerpk
			left outer join HVProgram h on h.HVProgramPK = CaseProgram.ProgramFK			   
		where
			 dischargedate is null --and sw.workerpk = isnull(@SupPK,sw.workerpk)
		)	
	,
	
	cteProgramCapacityX
	as
	( 
		select ProgramCapacity, ProgramFK,
			count(PC1ID) - sum(PreintakeCount) AS CurrentCapacity
			--,case when ProgramCapacity is null then 'Program capacity blank on Program Information Form.' 
			--ELSE CONVERT(VARCHAR, round(COALESCE(cast((count(PC1ID) - sum(PreintakeCount)) AS FLOAT) * 100 / 
			--NULLIF(ProgramCapacity,0), 0), 0))  + '%' end AS PerctOfProgramCapacity
		FROM ctemainAgain
		group by ProgramCapacity, ProgramFK
	)	 
	
	,
	cteProgramCapacity
	AS (
	
	select  sum(ProgramCapacity) AS ProgramCapacity,
			sum(CurrentCapacity) AS CurrentCapacity,
			case when sum(ProgramCapacity) is null then 'Program capacity blank on Program Information Form.' 
			ELSE CONVERT(VARCHAR, round(COALESCE(cast(sum(CurrentCapacity) AS FLOAT) * 100 / 
			NULLIF(sum(ProgramCapacity),0), 0), 0))  + '%' end AS PerctOfProgramCapacity
		FROM cteProgramCapacityX
	)
	
	-- C and D
	, cteScreen as
	(
		SELECT count(*) AS TotalScreens,
		sum(CASE WHEN a.ReferralMade = 1 THEN 1 ELSE 0 END) AS PositiveScreens,
		CONVERT(VARCHAR, round(COALESCE(cast((sum(CASE WHEN a.ReferralMade = 1 THEN 1 ELSE 0 END)) AS FLOAT) * 100 / 
		NULLIF(count(*),0), 0), 0))  + '%'
		AS PercentScreen
		FROM HVScreen AS a
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.ScreenDate BETWEEN @startDT AND @endDT
	)
	
	, cteKempe AS
	(
		SELECT 
		sum(CASE WHEN a.CaseStatus IN ('02', '04') THEN 1 ELSE 0 END) AS TotalKempe
		, sum(CASE WHEN a.CaseStatus IN ('02') AND a.FSWAssignDate IS NOT NULL THEN 1 ELSE 0 END) AS PositiveReferredKempe
		, CONVERT(VARCHAR, round(COALESCE(cast((sum(CASE WHEN a.CaseStatus IN ('02') AND 
		a.FSWAssignDate IS NOT NULL THEN 1 ELSE 0 END)) AS FLOAT) * 100 / 
		NULLIF(sum(CASE WHEN a.CaseStatus IN ('02', '04') THEN 1 ELSE 0 END),0), 0), 0))  + '%'
		AS PercentKempe
		FROM Preassessment AS a
		JOIN Kempe AS b ON a.HVCaseFK = b.HVCaseFK  -- new
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.KempeDate BETWEEN @startDT AND @endDT
	)
	
	-- G (acceptance rate)
	,
	cteAcceptanceRateX AS 
	(
	SELECT HVCasePK ,DischargeDate, IntakeDate, k.KempeDate, KempeResult
		 FROM HVCase h
			INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
			inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
			INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
			INNER JOIN PC P ON P.PCPK = h.PC1FK
			LEFT JOIN CommonAttributes ca ON ca.hvcasefk = h.hvcasepk AND ca.formtype = 'KE'
		WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL)
		AND k.KempeResult = 1
		AND k.KempeDate BETWEEN @startDT AND @endDT
	)

	, cteAcceptanceRate AS 
	(SELECT 
	 CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(sum(Case WHEN IntakeDate IS NOT NULL 
    OR (KempeResult = 1 AND IntakeDate IS NULL AND DischargeDate IS NOT NULL 
	AND (PIVisitMade > 0 AND PIVisitMade IS NOT NULL)) THEN 1 ELSE 0 END) AS FLOAT) 
	* 100/ NULLIF(count(*),0), 0), 0))  + '%') AS AcceptanceRate	

	FROM HVCase h
	INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
	inner join dbo.SplitString(@ProgramFK, ',') on cp.programfk = listitem
	INNER JOIN Kempe k ON k.HVCaseFK = h.HVCasePK
	INNER JOIN PC P ON P.PCPK = h.PC1FK
	LEFT OUTER JOIN 
	(SELECT KempeFK, sum(CASE WHEN PIVisitMade > 0 THEN 1 ELSE 0 END) PIVisitMade
		FROM Preintake AS a
		INNER JOIN CaseProgram cp ON cp.HVCaseFK = a.HVCaseFK
	    INNER join dbo.SplitString(@ProgramFK, ',') on cp.programfk = listitem
		--WHERE ProgramFK = @ProgramFK
		GROUP BY kempeFK) AS x ON x.KempeFK = k.KempePK
	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL) AND k.KempeResult = 1 
	AND k.KempeDate BETWEEN @startDt AND @endDT
	)
	--(SELECT
	--    count(*) AS Totals
	--	, sum(Case WHEN IntakeDate IS NOT NULL THEN 1 ELSE 0 END) TotalEnrolled
	--	--, sum(Case WHEN DischargeDate IS NOT NULL AND IntakeDate IS NULL THEN 1 ELSE 0 END) TotalNotEnrolled
	--	,CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(sum(Case WHEN IntakeDate IS NOT NULL THEN 1 ELSE 0 END) AS FLOAT) 
	--	* 100/ NULLIF(count(*),0), 0), 0))  + '%') AS AcceptanceRate	 
	-- FROM cteAcceptanceRateX
	--)
	
	-- retention rate
	,
	cteCaseLastHomeVisit AS
	(select HVCaseFK
		   ,max(vl.VisitStartTime) as LastHomeVisit
		   ,count(vl.VisitStartTime) as CountOfHomeVisits
		from HVLog vl
		inner join hvcase c on c.HVCasePK = vl.HVCaseFK
		inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = vl.ProgramFK
		where VisitType <> '00010' and (IntakeDate is not null and 
		IntakeDate between @startDTRetention and @endDTRetention)
		group by HVCaseFK
	)

	, cteMain as
	(select PC1ID
		   ,IntakeDate
		   ,LastHomeVisit
		   ,DischargeDate
		   ,cp.DischargeReason as DischargeReasonCode
		   ,cd.ReportDischargeText
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 182.125 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 182.125 then 1
				else 0
			end as ActiveAt6Months
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 365.25 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 365.25 then 1
				else 0
			end as ActiveAt12Months
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 547.375 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 547.375 then 1
				else 0
			end as ActiveAt18Months
		   ,case
				when dischargedate is null and current_timestamp-IntakeDate > 730.50 then 1
				when dischargedate is not null and LastHomeVisit-IntakeDate > 730.50 then 1
				else 0
			end as ActiveAt24Months
	 from HVCase c
		inner join cteCaseLastHomeVisit lhv on lhv.HVCaseFK = c.HVCasePK
		inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
		 left outer join dbo.codeDischarge cd on cd.DischargeCode = cp.DischargeReason and DischargeUsedWhere like '%DS%'
	 where (IntakeDate is not NULL and IntakeDate between @startDTRetention and @endDTRetention)
	)
	
	, cteRetentionX AS
	(
		select distinct pc1id, IntakeDate, DischargeDate, d.ReportDischargeText, LastHomeVisit
					   ,case when DischargeDate is not null then 
							datediff(mm,IntakeDate,LastHomeVisit)
						else
							datediff(mm,IntakeDate,current_timestamp)
						end as RetentionMonths
					   ,ActiveAt6Months
					   ,ActiveAt12Months
					   ,ActiveAt18Months
					   ,ActiveAt24Months
			from cteMain
				left outer join codeDischarge d on cteMain.DischargeReasonCode = DischargeCode
			where DischargeReasonCode is null
				 or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
	)
	
	,
	cteRetention AS 
	(SELECT
	count(*) AS TotalEnrolledParticipants
	, sum(case when ActiveAt12Months=1 then 1 else 0 end) as TwelveMonthsTotal
	,CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(sum(case when ActiveAt12Months=1 then 1 else 0 end) AS FLOAT) 
			* 100/ NULLIF(count(*),0), 0), 0))  + '%') AS RetentionRateOneYear	 
	FROM cteRetentionX
	)

	, cteCombined AS
	(
		SELECT *
		FROM cteProgramCapacity
		LEFT OUTER JOIN cteScreen ON 1 = 1
		LEFT OUTER JOIN cteKempe ON 1 = 1
		LEFT OUTER JOIN cteAcceptanceRate ON 1 = 1
		LEFT OUTER JOIN cteRetention ON 1 = 1
	)
	,
	cteRptX AS
	(
	  SELECT ProgramCapacity AS A
	        ,CurrentCapacity AS	B
	        ,PerctOfProgramCapacity AS [B/A]
	        ,TotalScreens AS C
	        ,PositiveScreens AS D
	        ,PercentScreen AS [D/C]
	        ,TotalKempe AS E
	        ,PositiveReferredKempe AS F
	        ,CONVERT(VARCHAR, CONVERT(VARCHAR, round(COALESCE(cast(PositiveReferredKempe AS FLOAT) 
			 * 100/ NULLIF(PositiveScreens,0), 0), 0))  + '%') AS [F/D]
			,ProgramCapacity - CurrentCapacity AS [A-B]
			,AcceptanceRate AS G
			,RetentionRateOneYear AS H
	  FROM cteCombined
	)
	,
	
	cteRpt AS 
	(
	select *
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/3, 0) AS EN3
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/6, 0) AS EN6
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/12, 0) AS EN12
	
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/3/(convert(FLOAT, replace(G,'%','') / 100.0)), 0) AS K3
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/6/(convert(FLOAT, replace(G,'%','') / 100.0)), 0) AS K6
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/12/(convert(FLOAT, replace(G,'%','') / 100.0)), 0) AS K12
	
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/3/(convert(FLOAT, replace(G,'%','') / 100.0))/(convert(FLOAT, replace([F/D],'%','') / 100.0)), 0) AS S3
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/6/(convert(FLOAT, replace(G,'%','') / 100.0))/(convert(FLOAT, replace([F/D],'%','') / 100.0)), 0) AS S6
	, round((A - (convert(FLOAT, replace(H,'%','') / 100.0) * A) + (A - B))/12/(convert(FLOAT, replace(G,'%','') / 100.0))/(convert(FLOAT, replace([F/D],'%','') / 100.0)), 0) AS S12
	
	from cteRptX
	)
    
    -- d1, d2, and d3
    
    , cteD as
	(
		SELECT 
		isnull(sum(CASE WHEN a.ReferralMade = 1 
		AND a.ScreenDate BETWEEN @startDT1 AND @endDT1
		THEN 1 ELSE 0 END), 0) AS D1
		, isnull(sum(CASE WHEN a.ReferralMade = 1 
		AND a.ScreenDate BETWEEN @startDT2 AND @endDT2
		THEN 1 ELSE 0 END), 0) AS D2
		, isnull(sum(CASE WHEN a.ReferralMade = 1 
		AND a.ScreenDate BETWEEN @startDT3 AND @endDT3
		THEN 1 ELSE 0 END), 0) AS D3
		FROM HVScreen AS a
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.ScreenDate BETWEEN @startDT1 AND @endDT3
	)
    
    ,
    cteF AS
	(
		SELECT 
		isnull(sum(CASE WHEN a.CaseStatus IN ('02') 
		AND a.FSWAssignDate IS NOT NULL 
		AND a.KempeDate BETWEEN @startDT1 AND @endDT1
		THEN 1 ELSE 0 END), 0) AS F1
		, isnull(sum(CASE WHEN a.CaseStatus IN ('02') 
		AND a.FSWAssignDate IS NOT NULL 
		AND a.KempeDate BETWEEN @startDT2 AND @endDT2
		THEN 1 ELSE 0 END), 0) AS F2
		, isnull(sum(CASE WHEN a.CaseStatus IN ('02') 
		AND a.FSWAssignDate IS NOT NULL 
		AND a.KempeDate BETWEEN @startDT3 AND @endDT3
		THEN 1 ELSE 0 END), 0) AS F3
		FROM Preassessment AS a
		inner join dbo.SplitString(@programfk,',') on a.ProgramFK = listitem
		WHERE a.KempeDate BETWEEN @startDT1 AND @endDT3
	)
	
	,
	cteX AS 
	(
	SELECT 
	isnull(sum(CASE WHEN h.IntakeDate BETWEEN @startDT1 AND @endDT1
		THEN 1 ELSE 0 END), 0) AS X1
	, isnull(sum(CASE WHEN h.IntakeDate BETWEEN @startDT2 AND @endDT2
		THEN 1 ELSE 0 END), 0) AS X2
	, isnull(sum(CASE WHEN h.IntakeDate BETWEEN @startDT3 AND @endDT3
		THEN 1 ELSE 0 END), 0) AS X3
	FROM HVCase h
		INNER JOIN CaseProgram cp ON cp.HVCaseFK = h.HVCasePK
		inner join dbo.SplitString(@ProgramFK,',') on cp.programfk = listitem
	WHERE (h.IntakeDate IS NOT NULL OR cp.DischargeDate IS NOT NULL)
	AND h.IntakeDate BETWEEN @startDT1 AND @endDT3
	)
	
	, 
	cteDateName AS
	(
	  SELECT 
	  DATENAME(month ,@startDT1) + ' ' + convert(varchar(4), datepart(yyyy, @startDT1)) [d1_name]
	, DATENAME(month ,@startDT2) + ' ' + convert(varchar(4), datepart(yyyy, @startDT2)) [d2_name]
	, DATENAME(month ,@startDT3) + ' ' + convert(varchar(4), datepart(yyyy, @startDT3)) [d3_name]
	
	)
	
	, 
	cteStartEndDate AS
	(
	  SELECT 
	  convert(VARCHAR(10), @startDT, 101) + ' - ' + convert(VARCHAR(10), @endDT, 101) AS [start_end]
	  , convert(VARCHAR(10), @startDTRetention, 101) + ' - ' + convert(VARCHAR(10), @endDTRetention, 101) AS [start_end_retention]
	
	)
	
    -- test A/B
	--SELECT * FROM cteProgramCapacity
	
	-- test C/D
	--SELECT * FROM cteScreen
	
	-- test E/F
	--SELECT * FROM cteKempe
	
	-- test G
    --SELECT * FROM cteAcceptanceRate
    
    -- test H
    --select * FROM cteRetention 
    
  -- SELECT * FROM cteCombined


  
   SELECT * 
   FROM cteRpt
   LEFT	OUTER JOIN cteD ON 1 = 1
   LEFT	OUTER JOIN cteF ON 1 = 1
   LEFT	OUTER JOIN cteX ON 1 = 1
   LEFT	OUTER JOIN cteDateName ON 1 = 1
   LEFT	OUTER JOIN cteStartEndDate ON 1 = 1
GO
PRINT N'Altering [dbo].[rspClosedEnrolledCaseList]'
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: 06/12/2012
-- Description:	Closed Enrolled Case List
-- exec rspClosedEnrolledCaseList 1,'20120701','20120731',null 1
-- exec rspClosedEnrolledCaseList_original 1,'20120701','20120731'
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
--            added this code to the workerprogram join condition: AND wp.programfk = listitem
-- =============================================
ALTER procedure [dbo].[rspClosedEnrolledCaseList]-- Add the parameters for the stored procedure here
    @programfk VARCHAR(MAX) = null,
    @StartDt   datetime,
    @EndDt     datetime,
	@WorkerFK  int = NULL,
    @SiteFK    int = 0,
    @CaseFiltersPositive varchar(100) = ''
AS

if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	END
set @programfk = REPLACE(@programfk,'"','')

	--DECLARE @StartDt DATE = '01/01/2011'
	--DECLARE @EndDt DATE = '05/31/2011'
	--DECLARE @programfk INT = 17
	set @SiteFK = isnull(@SiteFK, 0)
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;
	
	select rtrim(PC.PCLastName)+cast(PC.PCPK as varchar(10)) [key01]
	      , cp.PC1ID
		  ,rtrim(PC.PCLastName)+', '+rtrim(PC.PCFirstName) [Name]
		  ,convert(varchar(12),PC.PCDOB,101) [DOB]
		  ,PC.SSNo [SSNo]
		  ,convert(varchar(12),Kempe.KempeDate,101) [KemptDate]
		  ,convert(varchar(12),HVScreen.ScreenDate,101) [ScreenDate]
		  ,rtrim(w.LastName)+', '+rtrim(w.FirstName) [FSW]
		  ,convert(varchar(12),Intake.IntakeDate,101) [IntakeDate]
		  ,CAST(DATEDIFF(year,PC.PCDOB,Intake.IntakeDate) as varchar(10))+' y' [AgeAtIntake]
		  ,case when cp.DischargeDate is null then '' else convert(varchar(12),cp.DischargeDate,101) end [CloseDate]
		  ,case when cp.DischargeDate is null then 'Case Open' else rtrim(codeDischarge.DischargeReason) end [CloseReason]
		  
		  --,CAST(DATEDIFF(month,Intake.IntakeDate,@EndDt) as varchar(10))+' m' [LengthInProgram]
		  ,CASE WHEN cp.DischargeDate is NOT NULL THEN CAST(DATEDIFF(month,Intake.IntakeDate,cp.DischargeDate) as varchar(10))+' m' ELSE 
		   CAST(DATEDIFF(month,Intake.IntakeDate,@EndDt) as varchar(10))+' m' END [LengthInProgram]
		  
		  ,case when ca.TANFServices = 1 then 'Yes' else 'No' end [TANF]
		  ,case when ca.FormType = 'IN' then 'Intake' else (select top 1 codeApp.AppCodeText
																from codeApp
																where ca.FormInterval = codeApp.AppCode
																	 and codeApp.AppCodeUsedWhere like '%FU%'
																	 and codeApp.AppCodeGroup = 'TCAge'
														   ) end [TANFServiceAt]
		  ,convert(varchar(12),ca.FormDate,101) [Eligible]
		  ,(select count(*)
				from HVLog
				inner join CaseProgram cp1 on cp1.HVCaseFK = HVLog.HVCaseFK
				join dbo.SplitString(@programfk,',') on cp1.programfk = listitem
				inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = cp1.HVCaseFK
				inner join WorkerProgram wp1 on wp1.WorkerFK = cp1.CurrentFSWFK AND wp1.programfk = listitem
				where VisitType <> '00010'
					 and cast(VisitStartTime AS DATE) <= @EndDt
					 and cast(VisitStartTime AS DATE) >= c.IntakeDate
					 and HVLog.HVCaseFK = c.HVCasePK
					 --and HVLog.ProgramFK = @programfk
					 and (case when @SiteFK = 0 then 1 when wp1.SiteFK = @SiteFK then 1 else 0 end = 1)) [HomeVisits]
		  -- following fields are used for validating (to be removed)
		  ,(select top 1 ca1.CommonAttributesPK
				from CommonAttributes ca1
				where ca1.HVCaseFK = c.HVCasePK
					 and ca1.FormDate <= @EndDt
					 and ca1.FormType in ('FU','IN')
				order by ca1.FormDate desc
		   ) [CommonAttributesPKID]
		  ,ca.FormDate
		  ,ca.TANFServices
		  ,ca.FormType
		  ,ca.FormInterval
		  ,rtrim(T.TCLastName)+', '+rtrim(T.TCFirstName) [tcName]
		  ,convert(varchar(12),T.TCDOB,101) [tcDOB]

		from CaseProgram cp
		    join dbo.SplitString(@programfk,',') on cp.programfk = listitem
			join HVCase c on cp.HVCaseFK = c.HVCasePK
			-- pc1 name, dob, and SS# =  c.PC1FK <-> PC.PCPK -> PC.PCLastName + PC.PCFirstName, PC.PCDOB, PC.SSNo
			join PC on PC.PCPK = c.PC1FK
			-- screen date = cp.HVCaseFK <-> Kempe.HVCaseFK -> Kempe.KempeDate
			join Kempe on Kempe.HVCaseFK = c.HVCasePK
			-- kempe date = cp.HVCaseFK <-> HVScreen.HVCaseFK -> HVScreen.ScreenDate
			join HVScreen on HVScreen.HVCaseFK = c.HVCasePK
			-- FSW & site = cp.CurrentFSWFK <-> Worker.WorkerPK -> Worker.LastName + Worker.FirstName ?? site ??
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK and w.WorkerPK = isnull(@WorkerFK, w.WorkerPK)
			join Workerprogram as wp on wp.WorkerFK = w.WorkerPK AND wp.programfk = @programfk
			-- intake date & age at intake = cp.HVCaseFK <-> Intake.HVCaseFK -> Intake.IntakeDate -> (PCDOB - IntakeDate)
			join Intake on Intake.HVCaseFK = c.HVCasePK
			-- closed date & close reason = cp.DischargeDate, cp.DischargeReason <-> codeDischarge.DischargeCode 
			--                              -> codeDischarge.DischargeReason
			left outer join codeDischarge on cp.DischargeReason = codeDischarge.DischargeCode
			-- length in program = @EndDt - IntakeDate

			-- TANFservices, &  eligible = CA (CommonAttributes) : cp.HVCaseFK <-> CA.HVCaseFK and CA.FormType IN ('FU', 'IN')
			-- , CA.FormDate <= @EndDt and CA.TANFServices = 1 
			-- if CA.FormType = 'IN' then FormInterval = 'In Take' else CA.FormInterval <-> codeApp.AppCode and
			-- codeApp.AppCodeUsedWhere LIKE '%FU%' and AppCodeGroup = 'TCAge' -> codeApp.AppCodeText
			-- CA.FormDate = Eligible date
			-- CA.TANFServices = TANF
			-- ON ca.HVCaseFK =  c.HVCasePK AND ca.FormDate <= @EndDt AND ca.FormType IN ('FU', 'IN')
			left outer join CommonAttributes ca
						   on ca.CommonAttributesPK = (select top 1 CommonAttributesPK
														   from CommonAttributes
														   where HVCaseFK = c.HVCasePK
																and FormDate <= @EndDt
																and FormType in ('FU','IN')
														   order by FormDate desc)

			-- # of actual home visits since intake = cp.HVCaseFK <-> HVLog.HVCaseFK, ProgramFK, 
			-- VisitType <> '0001', VisitStartTime < @EndDt and VisitStartTime >=  c.IntakeDate

			left outer join TCID T on T.HVCaseFK = c.HVCasePK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = c.HVCasePK

		where cp.DischargeDate between @StartDt and @EndDt
			 --and cp.ProgramFK = @programfk
			 and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		order by [key01]
GO
PRINT N'Altering [dbo].[rspHFAHomeVisitCompletionRate_Detail]'
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
-- [rspHFAHomeVisitCompletionRate_Detail] 9
-- =============================================
ALTER procedure [dbo].[rspHFAHomeVisitCompletionRate_Detail](@programfk    varchar(max)    = null,
                                                        @sdate        datetime,
                                                        @edate        datetime,
                                                        @supervisorfk int             = null,
                                                        @workerfk     int             = null,
														@sitefk		 int			 = null,
														@posclause	 varchar(200), 
														@negclause	 varchar(200)
                                                        )

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end;

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @posclause = case when @posclause = '' then null else @posclause end;
	set @negclause = case when @negclause = '' then null else @negclause end;

	with cteHVRecords
	as
	(select distinct rtrim(firstname)+' '+rtrim(lastname) as workername
					,hvr.workerfk
					,count(distinct casefk) as casecount
					,pc1id
					, hvlevelpk
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk) as levelstart
					,floor(reqvisit) as expvisitcount
					,sum(case
							 when visittype <> '00010' then
								 1
							 else
								 0
						 end) as actvisitcount
					,sum(case
							 when substring(visittype,1,1) = '1' or substring(visittype,2,1) = '1' then
								 1
							 else
								 0
						 end) as inhomevisitcount
					,sum(case
							 when visittype = '00010' then
								 1
							 else
								 0
						 end) as attvisitcount
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001'))) DirectServiceTime
					,sum(visitlengthminute)+sum(visitlengthhour)*60 as visitlengthminute
					,sum(visitlengthhour) as visitlengthhour
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
					,hvr.casefk
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			 inner join worker on workerpk = hvr.workerfk
			 inner join workerprogram wp on wp.workerfk = workerpk
			 inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			 inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = hvr.casefk
		 where workerpk = isnull(@workerfk,workerpk)
			  and supervisorfk = isnull(@supervisorfk,supervisorfk)
			  and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
			  and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		 group by firstname
				 ,lastname
				 ,hvr.workerfk
				 ,pc1id
				 ,startdate
				 ,enddate
				 ,hvr.levelname
				 ,reqvisit
				 ,dischargedate
				 ,hvr.casefk
				 ,hvr.programfk
				, hvlevelpk
	)
	,
	cteLevelChanges
	as
	(select casefk
		   ,count(casefk)-1 as LevelChanges
		 from cteHVRecords
		 group by casefk
	)
	,
	cteSummary
	as
	(select distinct workername
					,workerfk
					,pc1id
					,casecount
					--EDIT: Chris Papas 10/11/2013
					--removed max(hvlevelpk) bringing in wrong pk when someone inserts a previous level (e.g. hvlevelpk is larger, but levelstart is not)
					--, max(hvlevelpk) over (partition by pc1id ) as  'UseThisLevelPK'
					--END 10/11/2013 EDIT
					
					
					,(select top 1 levelname
						  from hvleveldetail hld
						  where hld.hvcasefk = hvr.casefk
							   and hld.StartLevelDate = hvr.levelstart
							   ) as levelname
							   		   
					,sum(visitlengthminute) over (partition by pc1wrkfk ) as 'Minutes'
					,sum(expvisitcount) over (partition by pc1wrkfk ) as expvisitcount
					,min(startdate) over (partition by pc1wrkfk ) as 'startdate'
					,max(enddate) over (partition by pc1wrkfk ) as 'enddate'
					--,levelname
					,max(levelstart) over (partition by pc1wrkfk ) as 'levelstart'
					,sum(actvisitcount) over (partition by pc1wrkfk ) as actvisitcount
					,sum(inhomevisitcount) over (partition by pc1wrkfk ) as inhomevisitcount
					,sum(attvisitcount) over (partition by pc1wrkfk ) as attvisitcount
					,max(dischargedate) over (partition by pc1wrkfk ) as 'dischargedate'
					,IntakeDate
					,case when TCDOB is null
							then EDC
						  else TCDOB
					end as TCDOB
					,LevelChanges
		 from cteHVRecords hvr
			 inner join cteLevelChanges on cteLevelChanges.casefk = hvr.casefk
			 inner join HVCase c on hvr.casefk = c.HVCasePK
	)
	,
	cteMain
	as
	-- make the aggregate table
	(select distinct workername
					,workerfk
					,pc1id
					,casecount
					,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) as DirectServiceTime
					,expvisitcount
					,startdate
					,enddate
					,levelname
					--, (select levelname  from HVLevel inner join codeLevel l on l.codeLevelPK = HVLevel.LevelFK
					--		where HVLevel.HVLevelPK=UseThisLevelPK) as levelname
					--CHRIS PAPAS - below line was bringing in duplicates (ex. AL8713016704 for July 2010 - June 2011)
					 --, (SELECT TOP 1 levelname ORDER BY enddate) AS levelname
					 ,levelstart
					,actvisitcount
					,inhomevisitcount
					,attvisitcount
					,case
						 when actvisitcount is null or actvisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (actvisitcount/(expvisitcount*1.000)) > 1
									 then
									 1
								 else
									 actvisitcount/(expvisitcount*1.000)
							 end
					 end as VisitRate
					,case
						 when inhomevisitcount is null or inhomevisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)) > 1
									 then
									 1
								 else
									 inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)
							 end
					 end as InHomeRate
					,dischargedate
					,IntakeDate
					,TCDOB
					,LevelChanges
		 from cteSummary
	)
	select *
		  ,case
			   when expvisitcount = 0
				   then
				   0
			   when VisitRate >= .9 and InHomeRate >= .75
				   then
				   3
			   when VisitRate >= .75 and InHomeRate >= .75
				   then
				   2
			   else
				   1
		   end as ScoreForCase
		from cteMain
		where isnull(dischargedate, getdate()) > @sdate
		order by WorkerName
				,pc1id

end
GO
PRINT N'Altering [dbo].[rspHFAHomeVisitCompletionRate_Summary]'
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating transferred workers - YEAH!

-- =============================================
ALTER procedure [dbo].[rspHFAHomeVisitCompletionRate_Summary](@programfk    varchar(max)    = null,
                                                       @sdate        datetime,
                                                       @edate        datetime,
                                                       @supervisorfk int             = null,
                                                       @workerfk     int             = null,
                                                       @sitefk		 int			 = null,
                                                       @posclause	 varchar(200), 
                                                       @negclause	 varchar(200)
                                                       )

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end;

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @posclause = case when @posclause = '' then null else @posclause end;
	set @negclause = case when @negclause = '' then null else @negclause end;

	with cteHVRecords
	as
	(select distinct rtrim(firstname)+' '+rtrim(lastname) as workername
					,hvr.workerfk
					,count(distinct casefk) as casecount
					,pc1id
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk) as levelstart
					,floor(reqvisit) as expvisitcount
					,sum(case
							 when visittype <> '00010' then
								 1
							 else
								 0
						 end) as actvisitcount
					,sum(case
							 when substring(visittype,1,1) = '1' or substring(visittype,2,1) = '1' then
								 1
							 else
								 0
						 end) as inhomevisitcount
					,sum(case
							 when visittype = '00010' then
								 1
							 else
								 0
						 end) as attvisitcount
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001'))) DirectServiceTime
					,sum(visitlengthminute)+sum(visitlengthhour)*60 as visitlengthminute
					,sum(visitlengthhour) as visitlengthhour
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
					 ,hvr.casefk
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			 inner join worker on workerpk = hvr.workerfk
			 inner join workerprogram wp on wp.workerfk = workerpk
			 inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			 inner join dbo.udfCaseFilters(@posclause, @negclause, @programfk) cf on cf.HVCaseFK = hvr.casefk
		 where workerpk = isnull(@workerfk,workerpk)
			  and supervisorfk = isnull(@supervisorfk,supervisorfk)
			  and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
			  and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
		 group by firstname
				 ,lastname
				 ,hvr.workerfk
				 ,pc1id
				 ,startdate
				 ,enddate
				 ,hvr.levelname
				 ,reqvisit
				 ,dischargedate
				 ,hvr.casefk
				 ,hvr.programfk --,hld.StartLevelDate
	)
	,
	cteLevelChanges
	as
	(select casefk
		   ,count(casefk)-1 as LevelChanges
		 from cteHVRecords
		 group by casefk
	)
	,
	cteSummary
	as
	(select distinct workername
					,workerfk
					,pc1id
					,casecount
					,sum(visitlengthminute) over (partition by pc1wrkfk) as 'Minutes'
					,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
					,min(startdate) over (partition by pc1wrkfk) as 'startdate'
					,max(enddate) over (partition by pc1wrkfk) as 'enddate'
					,levelname
					,max(levelstart) over (partition by pc1wrkfk) as 'levelstart'
					,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
					,sum(inhomevisitcount) over (partition by pc1wrkfk) as inhomevisitcount
					,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
					,max(dischargedate) over (partition by pc1wrkfk) as 'dischargedate'
					,IntakeDate
					,case when TCDOB is null
							then EDC
						  else TCDOB
					end as TCDOB
					,LevelChanges
		 from cteHVRecords hvr
			 inner join cteLevelChanges on cteLevelChanges.casefk = hvr.casefk
			 inner join HVCase c on hvr.casefk = c.HVCasePK
	)
	,
	cteMain
	as
	-- make the aggregate table
	(select distinct workername
					,workerfk
					,pc1id
					,casecount
					,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) as DirectServiceTime
					,expvisitcount
					,startdate
					,enddate
					,max(levelname) over (partition by pc1id) as levelname
					--CHRIS PAPAS - below line was bringing in duplicates (ex. AL8713016704 for July 2010 - June 2011)
					 --, (SELECT TOP 1 levelname ORDER BY enddate) AS levelname
					 ,levelstart
					,actvisitcount
					,inhomevisitcount
					,attvisitcount
					,case
						 when actvisitcount is null or actvisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (actvisitcount/(expvisitcount*1.000)) > 1
									 then
									 1
								 else
									 actvisitcount/(expvisitcount*1.000)
							 end
					 end as VisitRate
					,case
						 when inhomevisitcount is null or inhomevisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)) > 1
									 then
									 1
								 else
									 inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)
							 end
					 end as InHomeRate
					,dischargedate
					,IntakeDate
					,TCDOB
					,LevelChanges
		 from cteSummary
	), 
	cteMainWithScores as 
	(select *
		  ,case
			   when expvisitcount = 0
				   then
				   0
			   when VisitRate >= .9 and InHomeRate >= .75
				   then
				   3
			   when VisitRate >= .75 and InHomeRate >= .75
				   then
				   2
			   else
				   1
		   end as ScoreForCase
		from cteMain
	)
	select *
			,case when ScoreForCase=1 then 1 else 0 end as ScoreForCase1
			,case when ScoreForCase=2 then 1 else 0 end as ScoreForCase2
			,case when ScoreForCase=3 then 1 else 0 end as ScoreForCase3
		from cteMainWithScores
		where expvisitcount > 0
				and not (levelname = 'Level X' and levelstart < @sdate)
		order by WorkerName
				,pc1id

end
GO
PRINT N'Altering [dbo].[rspHomeVisitLogSummaryQuarterly]'
GO
-- =============================================
-- Author:		Dar Chen
-- Create date: Jul/23/2012
-- Description:	Home Visit Log Summary Quarterly
-- Edit date: 10/11/2013 CP - workerprogram was duplicating cases when worker transferred
-- =============================================
ALTER procedure [dbo].[rspHomeVisitLogSummaryQuarterly]
    @programfk VARCHAR(MAX) = null,
    @StartDt   datetime,
    @EndDt     datetime,
    @StartDtX    datetime,
    @EndDtX     datetime,
    @SiteFK	   int = null,
    @casefilterspositive varchar(200)
as

--DECLARE	@programfk int = 4
--DECLARE @StartDt   DATETIME = '09/01/2012'
--DECLARE @EndDt     DATETIME = '11/30/2012'
--DECLARE @SiteFK	   int = null
--DECLARE @casefilterspositive varchar(200) = null
--DECLARE @StartDtX   DATETIME = '09/01/2012'
--DECLARE @EndDtX     DATETIME = '11/30/2012'

if @programfk is null
  begin
	select @programfk = substring((select ','+ltrim(rtrim(str(HVProgramPK)))
									   from HVProgram
									   for xml path ('')),2,8000)
  end
set @programfk = replace(@programfk,'"','')

	--declare @xDate datetime = '07/01/'+str(year(@StartDt))
	--declare @StartDtX datetime = case when @xDate > @StartDt then '07/01/'+str(year(@StartDt)-1) else @xDate end
	--declare @EndDtX datetime = @EndDt

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0 else @SiteFK end
	set @casefilterspositive = case when @casefilterspositive = '' then null else @casefilterspositive end

	declare @x int = 0
	declare @y int = 0
	declare @OutOfHome int = 0
	select
		  @y = count(*)
		 ,@x = sum(case when substring(a.VisitType,4,1) = '1' then 0 else 1 end)
		 ,@OutOfHome = sum(case when substring(a.VisitType,4,1) != '1' and substring(a.VisitType,3,1) = '1' then 1 else 0 end)
		from HVLog as a
			join CaseProgram as b on b.HVCaseFK = a.HVCaseFK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = b.HVCaseFK
		where 
		--b.ProgramFK = @programfk and 
		cast(a.VisitStartTime as date)  between @StartDt and @EndDt --jh fix
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDt)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	if @x = 0
	begin
		set @x = 1
	end
	if @y = 0
	begin
		set @y = 1
	end
	if @OutOfHome = 0
	begin
		set @OutOfHome = 1
	end

	--SELECT @StartDt, @StartDtX
--cast(VisitStartTime as date) 
	declare @xX int = 0
	declare @yX int = 0
	declare @OutOfHomeX int = 0
	select
		  @yX = count(*)
		 ,@xX = sum(case when substring(a.VisitType,4,1) = '1' then 0 else 1 end)
		 ,@OutOfHomeX = sum(case when substring(a.VisitType,4,1) != '1' and substring(a.VisitType,3,1) = '1' then 1 else 0 end)
		from HVLog as a
			join CaseProgram as b on b.HVCaseFK = a.HVCaseFK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = b.HVCaseFK
		where 
		--b.ProgramFK = @programfk and 
		cast(a.VisitStartTime as date)  between @StartDtX and @EndDtX
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDtX)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	if @xX = 0
	begin
		set @xX = 1
	end
	if @yX = 0
	begin
		set @yX = 1
	end
	if @OutOfHomeX = 0
	begin
		set @OutOfHomeX = 1
	end

	;
	with q1
	as
	(
	select
		  sum(case when substring(c.VisitType,4,1) <> '1' then 1 else 0 end) as [n]
		 ,sum(case when substring(c.VisitType,4,1) = '1' then 1 else 0 end) [Attemped]
		 ,avg(case when substring(c.VisitType,4,1) != '1' 
		 then (c.VisitLengthHour * 60 + c.VisitLengthMinute) else null end) [AverageLength]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) >= cast(c.VisitStartTime as date)  then 1 else 0 end)*100.0/@y,10,0)+'%' [Prenatal]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) < cast(c.VisitStartTime as date) then 1 else 0 end)*100.0/@y,10,0)+'%' [Postnatal]
		 
		 -- type of visit
		 ,str(sum(case when c.VisitType = '10000' then 1 else 0 end)*100.0/@x,10,0)+'%' [InPC1HomeOnly]
		 ,str(sum(case when c.VisitType = '01000' then 1 else 0 end)*100.0/@x,10,0)+'%' [InFatherFigureOBPHomeOnly]
		 ,str(sum(case when c.VisitType = '10100' then 1 else 0 end)*100.0/@x,10,0)+'%' [InOutOfPC1Home]
		 ,str(sum(case when c.VisitType = '01100' then 1 else 0 end)*100.0/@x,10,0)+'%' [InOutOfFatherFigureOBPHome]
		 ,str(sum(case when c.VisitType = '11000' then 1 else 0 end)*100.0/@x,10,0)+'%' [InBothPC1FatherFigureOBPHome]
		 ,str(sum(case when c.VisitType = '00100' then 1 else 0 end)*100.0/@x,10,0)+'%' [OutOfBothPC1FatherFigureOBPHome]
		 ,str(sum(case when c.VisitType = '11100' then 1 else 0 end)*100.0/@x,10,0)+'%' [InBothPC1FatherFigureOBPHomeAndOutBoth]
		 -- new type of visit
		 
		 
		 ,str(sum(case when substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1' then 1 else 0 end)
		  *100.0/@x,10,0)+'%' [InParticipantHome]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitType,1,1) != '1'
				  and substring(c.VisitType,2,1) != '1' then 1 else 0 end)*100.0/@x,10,0)+'%' [OutParticipantHome]
		 ,str(sum(case when (substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1')
				  and substring(c.VisitType,3,1) = '1'
				  then 1 else 0 end)*100.0/@x,10,0)+'%' [InOutParticipantHome]

		 ,sum(case when substring(c.VisitType,4,1) != '1' and substring(c.VisitType,3,1) = '1' then 1 else 0 end) [OutOfHome]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,1,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [MedicalProviderOffice]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,2,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [OtherProviderOffice]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,3,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [HomeVisitOffice]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,4,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [Hospital]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,5,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHome,10,0)+'%' [OtherLocation]

		 ,str(sum(case when c.PC1Participated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [PC1Participated]
		 ,str(sum(case when c.PC2Participated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [PC2Participated]
		 ,str(sum(case when c.OBPParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [OBPParticipated]
		 ,str(sum(case when c.FatherFigureParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [FatherFigureParticipated]
		 ,str(sum(case when c.TCParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [TCParticipated]
		 ,str(sum(case when c.GrandParentParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [GrandParentParticipated]
		 ,str(sum(case when c.SiblingParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [SiblingParticipated]
		 ,str(sum(case when c.NonPrimaryFSWParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [NonPrimaryFSWParticipated]
		 -- new 
		 ,str(sum(case when c.FatherAdvocateParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [FatherAdvocateParticipated]
		 ,str(sum(case when c.HVSupervisorParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [HVSupervisorParticipated]
		 ,str(sum(case when c.SupervisorObservation = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [SupervisorObservation]
		 ,str(sum(case when c.OtherParticipated = 1 then 1 else 0 end)*100.0/@x,10,0)+'%' [OtherParticipated]

/*
	.PC1Participated = chkPC1Participated.Checked
	.PC2Participated = chkPC2Participated.Checked
	.OBPParticipated = chkOBPParticipated.Checked
	.FatherFigureParticipated = chkFatherFigureParticipated.Checked	 ' new
	.TCParticipated = chkTCParticipated.Checked
	.GrandParentParticipated = chkGrandParentParticipated.Checked
	.SiblingParticipated = chkSiblingParticipated.Checked
	.NonPrimaryFSWParticipated = chkNonPrimaryFSWParticipated.Checked	 ' new
	
	.FatherAdvocateParticipated = chkFatherAdvocateParticipated.Checked	 ' new
	.HVSupervisorParticipated = chkHVSupervisorParticipated.Checked
	.SupervisorObservation = chkSupervisorObservation.Checked
	.OtherParticipated = chkOtherParticipated.Checked
*/



		 ,str(sum(case when (isnull(c.CDChildDevelopment,'00') = '00' and isnull(c.CDToys,'00') = '00'
				  and isnull(c.CDOther,'00') = '00') or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [ChildDevelopment]

		 ,str(sum(case when (isnull(c.PCChildInteraction,'00') = '00' and isnull(c.PCChildManagement,'00') = '00'
				  and isnull(c.PCFeelings,'00') = '00' and isnull(c.PCStress,'00') = '00'
				  and isnull(c.PCBasicNeeds,'00') = '00' and isnull(c.PCShakenBaby,'00') = '00' and isnull(c.PCShakenBabyVideo,
					  '00') = '00'
				  and isnull(c.PCOther,'00') = '00') or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@x,10,0)+'%' 
					  [PCInteraction]

		 ,str(sum(case when (isnull(c.HCGeneral,'00') = '00' and isnull(c.HCChild,'00') = '00' and isnull(c.HCDental,'00') = '00'
				  and isnull(c.HCFeeding,'00') = '00' and isnull(c.HCBreastFeeding,'00') = '00'
				  and isnull(c.HCNutrition,'00') = '00' and isnull(c.HCFamilyPlanning,'00') = '00' and isnull(c.HCProviders,'00') 
					  = '00'
				  and isnull(c.HCFASD,'00') = '00' and isnull(c.HCSexEducation,'00') = '00'
				  and isnull(c.HCPrenatalCare,'00') = '00' and isnull(c.HCMedicalAdvocacy,'00') = '00' and isnull(c.HCSafety,'00') 
					  = '00'
				  and isnull(c.HCSmoking,'00') = '00' and isnull(c.HCSIDS,'00') = '00'
				  and isnull(c.HCOther,'00') = '00') or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@x,10,0)+'%' 
					  [HealthCare]

		 ,str(sum(case when (isnull(c.FFDomesticViolence,'00') = '00' and isnull(c.FFFamilyRelations,'00') = '00'
				  and isnull(c.FFSubstanceAbuse,'00') = '00'
				  and isnull(c.FFMentalHealth,'00') = '00' and isnull(c.FFCommunication,'00') = '00'
				  and isnull(c.FFOther,'00') = '00') or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [FamilyFunction]

		 ,str(sum(case when (isnull(c.SSCalendar,'00') = '00' and isnull(c.SSHousekeeping,'00') = '00'
				  and isnull(c.SSTransportation,'00') = '00' and isnull(c.SSEmployment,'00') = '00'
				  and isnull(c.SSMoneyManagement,'00') = '00' and isnull(c.SSChildCare,'00') = '00'
				  and isnull(c.SSProblemSolving,'00') = '00' and isnull(c.SSEducation,'00') = '00' and isnull(c.SSJob,'00') = '00'
				  and isnull(c.SSOther,'00') = '00') or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [SelfSufficincy]

		 ,str(sum(case when (isnull(c.CIProblems,'00') = '00' and isnull(c.CIOther,'00') = '00') or substring(c.VisitType,4,1) = 
			 '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [CrisisIntervention]

		 ,str(sum(case when (isnull(c.PAForms,'00') = '00' and isnull(c.PAVideo,'00') = '00'
				  and isnull(c.PAGroups,'00') = '00' and isnull(c.PAIFSP,'00') = '00'
				  and isnull(c.PARecreation,'00') = '00' and isnull(c.PAOther,'00') = '00'
				  ) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [ProgramActivity]

		 ,str(sum(case when (isnull(c.CATransportation,'00') = '00' and isnull(c.CAGoods,'00') = '00' and isnull(c.CALegal,'00') = 
			 '00'
				  and isnull(c.CAHousing,'00') = '00'
				  and isnull(c.CAAdvocacy,'00') = '00' and isnull(c.CATranslation,'00') = '00' and isnull(c.CALaborSupport,'00') = 
					  '00'
				  and isnull(c.CAChildSupport,'00') = '00'
				  and isnull(c.CAParentRights,'00') = '00' and isnull(c.CAVisitation,'00') = '00' and isnull(c.CAOther,'00') = 
					  '00')
				  or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@x,10,0)+'%' [ConcreteAcivities]

		from HVCase as a
			join CaseProgram as b on b.HVCaseFK = a.HVCasePK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			join HVLog as c on a.HVCasePK = c.HVCaseFK
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = a.HVCasePK
		where 
		--b.ProgramFK = @programfk and 
		cast(c.VisitStartTime as date)  between @StartDt and @EndDt
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDt)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	),

	---------------------------------------------------------------------

	q2
	as (

	select
		  sum(case when substring(c.VisitType,4,1) <> '1' then 1 else 0 end) as [nX]
		 ,sum(case when substring(c.VisitType,4,1) = '1' then 1 else 0 end) [AttempedX]
		 ,avg(case when substring(c.VisitType,4,1) != '1' 
		 then (c.VisitLengthHour * 60 + c.VisitLengthMinute) else null end) [AverageLengthX]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) >= cast(c.VisitStartTime as date) then 1 else 0 end)*100.0/@yX,10,0)+'%' [PrenatalX]
		 ,str(sum(case when isnull(a.TCDOB,a.EDC) < cast(c.VisitStartTime as date) then 1 else 0 end)*100.0/@yX,10,0)+'%' [PostnatalX]

         -- type of visit
		 ,str(sum(case when c.VisitType = '10000' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InPC1HomeOnlyX]
		 ,str(sum(case when c.VisitType = '01000' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InFatherFigureOBPHomeOnlyX]
		 ,str(sum(case when c.VisitType = '10100' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InOutOfPC1HomeX]
		 ,str(sum(case when c.VisitType = '01100' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InOutOfFatherFigureOBPHomeX]
		 ,str(sum(case when c.VisitType = '11000' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InBothPC1FatherFigureOBPHomeX]
		 ,str(sum(case when c.VisitType = '00100' then 1 else 0 end)*100.0/@xX,10,0)+'%' [OutOfBothPC1FatherFigureOBPHomeX]
		 ,str(sum(case when c.VisitType = '11100' then 1 else 0 end)*100.0/@xX,10,0)+'%' [InBothPC1FatherFigureOBPHomeAndOutBothX]
		 -- new type of visit


		 ,str(sum(case when substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1' then 1 else 0 end)
		  *100.0/@xX,10,0)+'%' [InParticipantHomeX]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitType,1,1) != '1'
				  and substring(c.VisitType,2,1) != '1' then 1 else 0 end)*100.0/@xX,10,0)+'%' [OutParticipantHomeX]
		 ,str(sum(case when (substring(c.VisitType,1,1) = '1' or substring(c.VisitType,2,1) = '1')
				  and substring(c.VisitType,3,1) = '1'
				  then 1 else 0 end)*100.0/@xX,10,0)+'%' [InOutParticipantHomeX]

		 ,sum(case when substring(c.VisitType,4,1) != '1' and substring(c.VisitType,3,1) = '1' then 1 else 0 end) [OutOfHomeX]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,1,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [MedicalProviderOfficeX]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,2,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [OtherProviderOfficeX]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,3,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [HomeVisitOfficeX]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,4,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [HospitalX]
		 ,str(sum(case when substring(c.VisitType,3,1) = '1' and substring(c.VisitLocation,5,1) = '1' then 1 else 0 end)*100.0/
			 @OutOfHomeX,10,0)+'%' [OtherLocationX]

		 ,str(sum(case when c.PC1Participated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [PC1ParticipatedX]
		 ,str(sum(case when c.PC2Participated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [PC2ParticipatedX]
		 ,str(sum(case when c.OBPParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [OBPParticipatedX]
		 ,str(sum(case when c.FatherFigureParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [FatherFigureParticipatedX]
		 ,str(sum(case when c.TCParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [TCParticipatedX]
		 ,str(sum(case when c.GrandParentParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [GrandParentParticipatedX]
		 ,str(sum(case when c.SiblingParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [SiblingParticipatedX]
		 ,str(sum(case when c.NonPrimaryFSWParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [NonPrimaryFSWParticipatedX]
		  -- new 
		 ,str(sum(case when c.FatherAdvocateParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [FatherAdvocateParticipatedX]
		 ,str(sum(case when c.HVSupervisorParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [HVSupervisorParticipatedX]
		 ,str(sum(case when c.SupervisorObservation = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [SupervisorObservationX]
		 ,str(sum(case when c.OtherParticipated = 1 then 1 else 0 end)*100.0/@xX,10,0)+'%' [OtherParticipatedX]

		 ,str(sum(case when (isnull(c.CDChildDevelopment,'00') = '00' and isnull(c.CDToys,'00') = '00'
				  and isnull(c.CDOther,'00') = '00') or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [ChildDevelopmentX]

		 ,str(sum(case when (isnull(c.PCChildInteraction,'00') = '00' and isnull(c.PCChildManagement,'00') = '00'
				  and isnull(c.PCFeelings,'00') = '00' and isnull(c.PCStress,'00') = '00'
				  and isnull(c.PCBasicNeeds,'00') = '00' and isnull(c.PCShakenBaby,'00') = '00' and isnull(c.PCShakenBabyVideo,
					  '00') = '00'
				  and isnull(c.PCOther,'00') = '00') or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@xX,10,0)+'%' 
					  [PCInteractionX]

		 ,str(sum(case when (isnull(c.HCGeneral,'00') = '00' and isnull(c.HCChild,'00') = '00' and isnull(c.HCDental,'00') = '00'
				  and isnull(c.HCFeeding,'00') = '00' and isnull(c.HCBreastFeeding,'00') = '00'
				  and isnull(c.HCNutrition,'00') = '00' and isnull(c.HCFamilyPlanning,'00') = '00' and isnull(c.HCProviders,'00') 
					  = '00'
				  and isnull(c.HCFASD,'00') = '00' and isnull(c.HCSexEducation,'00') = '00'
				  and isnull(c.HCPrenatalCare,'00') = '00' and isnull(c.HCMedicalAdvocacy,'00') = '00' and isnull(c.HCSafety,'00') 
					  = '00'
				  and isnull(c.HCSmoking,'00') = '00' and isnull(c.HCSIDS,'00') = '00'
				  and isnull(c.HCOther,'00') = '00') or substring(c.VisitType,4,1) = '1' then 0 else 1 end)*100.0/@xX,10,0)+'%' 
					  [HealthCareX]

		 ,str(sum(case when (isnull(c.FFDomesticViolence,'00') = '00' and isnull(c.FFFamilyRelations,'00') = '00'
				  and isnull(c.FFSubstanceAbuse,'00') = '00'
				  and isnull(c.FFMentalHealth,'00') = '00' and isnull(c.FFCommunication,'00') = '00'
				  and isnull(c.FFOther,'00') = '00') or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [FamilyFunctionX]

		 ,str(sum(case when (isnull(c.SSCalendar,'00') = '00' and isnull(c.SSHousekeeping,'00') = '00'
				  and isnull(c.SSTransportation,'00') = '00' and isnull(c.SSEmployment,'00') = '00'
				  and isnull(c.SSMoneyManagement,'00') = '00' and isnull(c.SSChildCare,'00') = '00'
				  and isnull(c.SSProblemSolving,'00') = '00' and isnull(c.SSEducation,'00') = '00' and isnull(c.SSJob,'00') = '00'
				  and isnull(c.SSOther,'00') = '00') or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [SelfSufficincyX]

		 ,str(sum(case when (isnull(c.CIProblems,'00') = '00' and isnull(c.CIOther,'00') = '00') or substring(c.VisitType,4,1) = 
			 '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [CrisisInterventionX]


		 ,str(sum(case when (isnull(c.PAForms,'00') = '00' and isnull(c.PAVideo,'00') = '00'
				  and isnull(c.PAGroups,'00') = '00' and isnull(c.PAIFSP,'00') = '00'
				  and isnull(c.PARecreation,'00') = '00' and isnull(c.PAOther,'00') = '00'
				  ) or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [ProgramActivityX]

		 ,str(sum(case when (isnull(c.CATransportation,'00') = '00' and isnull(c.CAGoods,'00') = '00' and isnull(c.CALegal,'00') = 
			 '00'
				  and isnull(c.CAHousing,'00') = '00'
				  and isnull(c.CAAdvocacy,'00') = '00' and isnull(c.CATranslation,'00') = '00' and isnull(c.CALaborSupport,'00') = 
					  '00'
				  and isnull(c.CAChildSupport,'00') = '00'
				  and isnull(c.CAParentRights,'00') = '00' and isnull(c.CAVisitation,'00') = '00' and isnull(c.CAOther,'00') = 
					  '00')
				  or substring(c.VisitType,4,1) = '1'
				  then 0 else 1 end)*100.0/@xX,10,0)+'%' [ConcreteAcivitiesX]

		from HVCase as a
			join CaseProgram as b on b.HVCaseFK = a.HVCasePK
			INNER JOIN dbo.SplitString(@programfk,',') on b.programfk = listitem
			join HVLog as c on a.HVCasePK = c.HVCaseFK
			inner join WorkerProgram wp on WorkerFK = FSWFK AND wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive,'', @programfk) cf on cf.HVCaseFK = a.HVCasePK
		where 
		--b.ProgramFK = @programfk and 
		cast(c.VisitStartTime as date)  between @StartDtX and @EndDtX
		--and (b.DischargeDate is null
		--or b.DischargeDate > @EndDtX)
		and (case when @SiteFK = 0 then 1 when wp.SiteFK = @SiteFK then 1 else 0 end = 1)
	)

	select *
		from q1
			join q2 on 1 = 1
GO
PRINT N'Altering [dbo].[rspNYSFSWHomeVisitRecord_Detail]'
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Edit date: 7/10/2013 (Chris Papas) - cteMain levelname fix
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
--				04/29 Changed to NYS FSW Home Visit Record
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
--			  02/24/2015 jr - add support for Site and Case Filter criteria
-- =============================================
ALTER procedure [dbo].[rspNYSFSWHomeVisitRecord_Detail]
				(@programfk    varchar(max)    = null
					, @sdate        datetime
					, @edate        datetime
					, @supervisorfk int             = null
					, @workerfk     int             = null
					, @SiteFK int = null
					, @CaseFiltersPositive varchar(100) = ''
				)

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end
	set @programfk = REPLACE(@programfk,'"','');

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;

	with cteHVRecords
	as
	(select distinct rtrim(firstname)+' '+rtrim(lastname) as workername
					,hvr.workerfk
					,count(distinct casefk) as casecount
					,pc1id
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk) as levelstart
					,(reqvisit) as expvisitcount
					,sum(case
							 when visittype <> '00010' then
								 1
							 else
								 0
						 end) as actvisitcount
					,sum(case
							 when substring(visittype,1,1) = '1' or substring(visittype,2,1) = '1' then
								 1
							 else
								 0
						 end) as inhomevisitcount
					,sum(case
							 when visittype = '00010' then
								 1
							 else
								 0
						 end) as attvisitcount
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001'))) DirectServiceTime
					,sum(visitlengthminute)+sum(visitlengthhour)*60 as visitlengthminute
					,sum(visitlengthhour) as visitlengthhour
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
					 ,hvr.casefk
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			inner join worker on workerpk = hvr.workerfk
			inner join workerprogram wp on wp.workerfk = workerpk
			inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = hvr.casefk
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
					and workerpk = isnull(@workerfk,workerpk)
					and supervisorfk = isnull(@supervisorfk,supervisorfk)
					and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
		 group by firstname
				 ,lastname
				 ,hvr.workerfk
				 ,pc1id
				 ,startdate
				 ,enddate
				 ,hvr.levelname
				 ,reqvisit
				 ,dischargedate
				 ,hvr.casefk
				 ,hvr.programfk --,hld.StartLevelDate
	)
	,
	cteLevelChanges
	as
	(select casefk
		   ,count(casefk)-1 as LevelChanges
		 from cteHVRecords
		 group by casefk
	)
	,
	cteSummary
	as
	(select distinct workername
					,workerfk
					,pc1id
					,hvr.casefk
					,casecount
					,sum(visitlengthminute) over (partition by pc1wrkfk) as 'Minutes'
					,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
					,min(startdate) over (partition by pc1wrkfk) as 'startdate'
					,max(enddate) over (partition by pc1wrkfk) as 'enddate'
					,levelname
					,max(levelstart) over (partition by pc1wrkfk) as 'levelstart'
					,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
					,sum(inhomevisitcount) over (partition by pc1wrkfk) as inhomevisitcount
					,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
					,max(dischargedate) over (partition by pc1wrkfk) as 'dischargedate'
					,IntakeDate
					,case when TCDOB is null
							then EDC
						  else TCDOB
					end as TCDOB
					,LevelChanges
		 from cteHVRecords hvr
			 inner join cteLevelChanges on cteLevelChanges.casefk = hvr.casefk
			 inner join HVCase c on hvr.casefk = c.HVCasePK
)
	--07/10/2013 [Chris Papas], continual errors with getting the correct Level.
	-- both ,max(levelname) over (partition by pc1id) as levelname
	--and (SELECT TOP 1 levelname ORDER BY enddate) AS levelname, were returning the wrong levels in certain circumstances.
	--FIX is below and as follows: Row_Number() OVER (Partition By casefk ORDER BY [levelstart] DESC) as RowNum
	--END 7/10/2013 fix
	
	, cteMain as
	-- make the aggregate table
	(select workername
			,workerfk
			,pc1id
			,casecount
			,DirectServiceTime
			,expvisitcount
			,startdate
			,enddate
			,levelname
			,levelstart
			,actvisitcount
			,inhomevisitcount
			,attvisitcount
			,VisitRate
			,InHomeRate
			,dischargedate
			,IntakeDate
			,TCDOB
			,LevelChanges
			from (
				select distinct workername
					,workerfk
					,pc1id
					,casecount
					,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) as DirectServiceTime
					,FLOOR(expvisitcount) AS expvisitcount
					,startdate
					,enddate
					,(select top 1 levelname
						  from hvleveldetail hld
						  where hld.hvcasefk = cteSummary.casefk
							   and hld.StartLevelDate = cteSummary.levelstart
							   ) as levelname
					,levelstart
					,actvisitcount
					,inhomevisitcount
					,attvisitcount
					,case
						 when actvisitcount is null or actvisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (actvisitcount/(expvisitcount*1.000)) > 1
									 then
									 1
								 else
									 actvisitcount/(expvisitcount*1.000)
							 end
					 end as VisitRate
					,case
						 when inhomevisitcount is null or inhomevisitcount = 0
							 then
							 0
						 when expvisitcount is null or expvisitcount = 0
							 then
							 1
						 else
							 case
								 when (inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)) > 1
									 then
									 1
								 else
									 inhomevisitcount/(case when expvisitcount>=actvisitcount then actvisitcount else expvisitcount end*1.000)
							 end
					 end as InHomeRate
					,dischargedate
					,IntakeDate
					,TCDOB
					,LevelChanges
				from cteSummary
			) a 
	)
	
	
	select *
		  ,case
			   when expvisitcount = 0
				   then
				   0
			   when VisitRate >= .9 and InHomeRate >= .75
				   then
				   3
			   when VisitRate >= .75 and InHomeRate >= .75
				   then
				   2
			   else
				   1
		   end as ScoreForCase
		from cteMain
		where isnull(dischargedate, getdate()) > @sdate
		order by WorkerName
				,pc1id

end
GO
PRINT N'Altering [dbo].[rspNYSFSWHomeVisitRecord_Summary]'
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 4, 2012>
-- Description:	<Converted FamSys report - Home Visit Achievement Rate - Aggregate>
--				04/29 Changed to NYS FSW Home Visit Record
-- Edit date: 10/11/2013 CP - workerprogram was NOT duplicating cases when worker transferred
--			  02/24/2015 jr - add support for Site and Case Filter criteria
-- =============================================
ALTER procedure [dbo].[rspNYSFSWHomeVisitRecord_Summary]
				(@programfk    varchar(max)    = null
					, @sdate        datetime
					, @edate        datetime
					, @supervisorfk int             = null
					, @workerfk     int             = null
					, @SiteFK int = null
					, @CaseFiltersPositive varchar(100) = ''
				)

as
begin

	if @programfk is null
	begin
		select @programfk =
			   substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
							  from HVProgram
							  for xml path ('')),2,8000)
	end
	set @programfk = REPLACE(@programfk,'"','');

	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @CaseFiltersPositive = case	when @CaseFiltersPositive = '' then null
									else @CaseFiltersPositive
							   end;

	with cteHVRecords
	as
	(select rtrim(firstname)+' '+rtrim(lastname) as workername
					,hvr.workerfk
					,hvr.casefk
					,pc1id
					,startdate
					,enddate
					,hvr.levelname
					,(select max(hld.StartLevelDate)
						  from hvleveldetail hld
						  where hvr.casefk = hld.hvcasefk
							   and StartLevelDate <= @edate
							   and hvr.programfk = hld.programfk) as levelstart
					,reqvisit as expvisitcount
					,sum(case
							 when visittype <> '00010' then
								 1
							 else
								 0
						 end) as actvisitcount
					,sum(case
							 when substring(visittype,1,1) = '1' or substring(visittype,2,1) = '1' then
								 1
							 else
								 0
						 end) as inhomevisitcount
					,sum(case
							 when visittype = '00010' then
								 1
							 else
								 0
						 end) as attvisitcount
					,(dateadd(mi,sum(visitlengthminute),dateadd(hh,sum(visitlengthhour),'01/01/2001'))) DirectServiceTime
					,sum(visitlengthminute)+sum(visitlengthhour)*60 as visitlengthminute
					,sum(visitlengthhour) as visitlengthhour
					,dischargedate
					,pc1id+convert(char(10),hvr.workerfk) as pc1wrkfk --use for a distinct unique field for the OVER(PARTITION BY) above	
		 from [dbo].[udfHVRecords](@programfk,@sdate,@edate) hvr
			inner join worker on workerpk = hvr.workerfk
			inner join workerprogram wp on wp.workerfk = workerpk
			inner join dbo.SplitString(@programfk,',') on wp.programfk = listitem
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = hvr.casefk
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
				and workerpk = isnull(@workerfk,workerpk)
				and supervisorfk = isnull(@supervisorfk,supervisorfk)
				and startdate < enddate --Chris Papas 05/25/2011 due to problem with pc1id='IW8601030812'
		 group by rtrim(firstname)+' '+rtrim(lastname)
				 ,hvr.workerfk
				 ,pc1id
				 ,startdate
				 ,enddate
				 ,hvr.levelname
				 ,reqvisit
				 ,dischargedate
				 ,hvr.casefk
				 ,hvr.programfk --,hld.StartLevelDate
	), 
	cteCaseCount 
	as 
	(select count(distinct casefk) as casecount
		from cteHVRecords
	),
	cteMain 
	as 
	(select workername
			 ,workerfk
			 ,pc1id
			 ,sum(visitlengthminute) as Minutes
			 ,sum(expvisitcount) as expvisitcount
			 ,min(startdate) as startdate
			 ,max(enddate) as enddate
			 ,max(levelstart) as levelstart
			 ,sum(actvisitcount) as actvisitcount
			 ,sum(inhomevisitcount) as inhomevisitcount
			 ,sum(attvisitcount) as attvisitcount
			 ,max(dischargedate) as dischargedate

			 --,sum(casecount) over (partition by pc1wrkfk) as CaseCount
			 --,sum(visitlengthminute) over (partition by pc1wrkfk) as Minutes
			 --,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
			 --,min(startdate) over (partition by pc1wrkfk) as startdate
			 --,max(enddate) over (partition by pc1wrkfk) as enddate
			 --,(select top 1 levelname
				--   from cteHVRecords
				--   where enddate <= @edate) as levelname
			 --,max(levelstart) over (partition by pc1wrkfk) as levelstart
			 --,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
			 --,sum(inhomevisitcount) over (partition by pc1wrkfk) as inhomevisitcount
			 --,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
			 --,max(dischargedate) over (partition by pc1wrkfk) as dischargedate

		from cteHVRecords
		group by workername
			,pc1wrkfk
			,workerfk
			,pc1id
	)
	
	-- make the aggregate table
	select workername
		  ,rtrim(LastName)+', '+rtrim(FirstName) as WorkerLastFirst
		  ,workerfk
		  ,pc1id
		  ,CaseCount
		  ,dateadd(yy,(2003-1900),0)+dateadd(mm,11-1,0)+6-1+dateadd(mi,minutes,0) as DirectServiceTime
		  ,floor(expvisitcount) as expvisitcount
		  ,startdate
		  ,enddate
		  ,levelstart
		  ,actvisitcount
		  ,inhomevisitcount
		  ,attvisitcount
		  ,dischargedate
		from cteMain
		inner join Worker w on workerfk=w.WorkerPK
		left outer join cteCaseCount on casecount=casecount
		where isnull(dischargedate, getdate()) > @sdate
		
end
GO
PRINT N'Altering [dbo].[rspProgramInformationFor8Quarters]'
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <January 4th, 2013>
-- Description:	<gets you data for Quarterly report i.e. J. Program Information for 8 Quarters>
-- exec [rspProgramInformationFor8Quarters] '5','03/31/13'
-- exec [rspProgramInformationFor8Quarters] '2','06/30/12'
-- exec [rspProgramInformationFor8Quarters] '5','06/30/12'
-- exec dbo.rspProgramInformationFor8Quarters @programfk=',13,',@edate='2013-03-31 00:00:00',@sitefk=NULL,@casefilterspositive=NULL
-- exec dbo.rspProgramInformationFor8Quarters @programfk=',19,',@edate='2013-03-31 00:00:00',@sitefk=NULL,@casefilterspositive=NULL

-- exec [rspProgramInformationFor8Quarters] '39','12/31/13'
-- exec [rspProgramInformationFor8Quarters] '19','06/30/13'

-- 02/02/2013 
-- handling when there is no data available e.g. for a new program that just joins hfny like Dominican Womens

-- exec [rspProgramInformationFor8Quarters] '31','2012-06-30'
-- =============================================
ALTER procedure [dbo].[rspProgramInformationFor8Quarters] (@programfk varchar(300) = null
														 , @edate datetime
														 , @sitefk int = 0
														 , @casefilterspositive varchar(100) = ''  
														  )
as
	begin




		if @programfk is null
			begin
				select	@programfk = substring((select	',' + ltrim(rtrim(str(HVProgramPK)))
												from	HVProgram
											   for
												xml	path('')
											   ), 2, 8000)
			end
		set @programfk = replace(@programfk, '"', '')	




		set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
						   else @SiteFK
					  end
		set @casefilterspositive = case	when @casefilterspositive = '' then null
										else @casefilterspositive
								   end


---- create a table that will be filled in with data at the end
		create table #tblQ8ReportMain (QuarterNumber [varchar](10)
									 , QuarterEndDate [varchar](200) null
									 , numberOfScreens [varchar](200) null
									 , numberOfKempAssessments [varchar](200) null
									 , KempPositivePercentage [varchar](200) null
									 , KempPositiveEnrolled [varchar](200) null
									 , KempPositivePending [varchar](200) null
									 , KempPositiveTerminated [varchar](200) null
									 , AvgPositiveMotherScore [varchar](200) null
									 , EnrolledAtBeginningOfQrtr [varchar](200) null
									 , NewEnrollmentsThisQuarter [varchar](200) null
									 , NewEnrollmentsPrenatal [varchar](200) null
									 , TANFServicesEligible [varchar](200) null
									 , FamiliesDischargedThisQuarter [varchar](200) null
									 , FamiliesCompletingProgramThisQuarter [varchar](200) null
									 , FamiliesActiveAtEndOfThisQuarter [varchar](200) null
									 , FamiliesActiveAtEndOfThisQuarterOnLevel1 [varchar](200) null
									 , FamiliesActiveAtEndOfThisQuarterOnLevelX [varchar](200) null
									 , FamiliesWithNoServiceReferrals [varchar](200) null
									 , AverageVisitsPerMonthPerCase [varchar](200) null
									 , TotalServedInQuarterIncludesClosedCases [varchar](200) null
									 , AverageVisitsPerFamily [varchar](200) null
									 , TANFServicesEligibleAtEnrollment [varchar](200) null
									 , rowBlankforItem9 [varchar](200) null
									 , LengthInProgramUnder6Months [varchar](200) null
									 , LengthInProgramUnder6MonthsTo1Year [varchar](200) null
									 , LengthInProgramUnder1YearTo2Year [varchar](200) null
									 , LengthInProgramUnder2YearsAndOver [varchar](200) null
									  )	





-- Create 8 quarters given a starting quarter end date
-- 02/02/2013 
-- handling when there is no data available. In order to handle, I added the following columns i.e. col1-col26
		create table #tblMake8Quarter ([QuarterNumber] [int]
									 , [QuarterStartDate] [date]
									 , [QuarterEndDate] [date]
									 , [Col1] [varchar](200) default ' '
									 , [Col2] [varchar](200) default ' '
									 , [Col3] [varchar](200) default ' '
									 , [Col4] [varchar](200) default ' '
									 , [Col5] [varchar](200) default ' '
									 , [Col6] [varchar](200) default ' '
									 , [Col7] [varchar](200) default ' '
									 , [Col8] [varchar](200) default ' '
									 , [Col9] [varchar](200) default ' '
									 , [Col10] [varchar](200) default ' '
									 , [Col11] [varchar](200) default ' '
									 , [Col12] [varchar](200) default ' '
									 , [Col13] [varchar](200) default ' '
									 , [Col14] [varchar](200) default ' '
									 , [Col15] [varchar](200) default ' '
									 , [Col16] [varchar](200) default ' '
									 , [Col17] [varchar](200) default ' '
									 , [Col18] [varchar](200) default ' '
									 , [Col19] [varchar](200) default ' '
									 , [Col20] [varchar](200) default ' '
									 , [Col21] [varchar](200) default ' '
									 , [Col22] [varchar](200) default ' '
									 , [Col23] [varchar](200) default ' '
									 , [Col24] [varchar](200) default ' '
									 , [Col25] [varchar](200) default ' '
									 , [Col26] [varchar](200) default ' '
									  )

		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	8
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -3, @edate)) + 1, 0)))
					  , @edate as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	7
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -6, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -3, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	6
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -9, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -6, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	5
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -12, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -9, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	4
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -15, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -12, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	3
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -18, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -15, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	2
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -21, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -18, @edate)) + 1, 0)) as QuarterEndDate
		insert	into #tblMake8Quarter
				([QuarterNumber]
			   , [QuarterStartDate]
			   , [QuarterEndDate]
				)
				select	1
					  , dateadd(dd, 1, dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -24, @edate)) + 1, 0)))
					  , dateadd(s, -1, dateadd(mm, datediff(m, 0, dateadd(mm, -21, @edate)) + 1, 0)) as QuarterEndDate


-- SELECT * FROM #tblMake8Quarter  -- equivalent to csr8q cursor
-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'


---- ***************** ----
-- Please use Pivot to change columns to rows (hint Pivoted on RowNumber) --- .... khalsa
---- ***************** ----

-- Create a Summary table, where we will store values of all 8 quarters
--create table #tblMain8Quarters(
--	[RowNumber] [int],
--	[Title] VARCHAR(250),
--	[LastDayOfQuarter1] VARCHAR(10),
--	[LastDayOfQuarter2] VARCHAR(10),
--	[LastDayOfQuarter3] VARCHAR(10),
--	[LastDayOfQuarter4] VARCHAR(10),
--	[LastDayOfQuarter5] VARCHAR(10),
--	[LastDayOfQuarter6] VARCHAR(10),
--	[LastDayOfQuarter7] VARCHAR(10),
--	[LastDayOfQuarter8] VARCHAR(10)	
--)


-- Initially, get the subset of data that we are interested in ... Good Practice ... Khalsa 
-- We will use this cohort starting item # 3
		create table #tblInitial_cohort ([HVCasePK] [int]
									   , [CaseProgress] [numeric](3, 1) null
									   , [Confidentiality] [bit] null
									   , [CPFK] [int] null
									   , [DateOBPAdded] [datetime] null
									   , [EDC] [datetime] null
									   , [FFFK] [int] null
									   , [FirstChildDOB] [datetime] null
									   , [FirstPrenatalCareVisit] [datetime] null
									   , [FirstPrenatalCareVisitUnknown] [bit] null
									   , [HVCaseCreateDate] [datetime] not null
									   , [HVCaseCreator] [char](10) not null
									   , [HVCaseEditDate] [datetime] null
									   , [HVCaseEditor] [char](10) null
									   , [InitialZip] [char](10) null
									   , [IntakeDate] [datetime] null
									   , [IntakeLevel] [char](1) null
									   , [IntakeWorkerFK] [int] null
									   , [KempeDate] [datetime] null
									   , [OBPInformationAvailable] [bit] null
									   , [OBPFK] [int] null
									   , [OBPinHomeIntake] [bit] null
									   , [OBPRelation2TC] [char](2) null
									   , [PC1FK] [int] not null
									   , [PC1Relation2TC] [char](2) null
									   , [PC1Relation2TCSpecify] [varchar](30) null
									   , [PC2FK] [int] null
									   , [PC2inHomeIntake] [bit] null
									   , [PC2Relation2TC] [char](2) null
									   , [PC2Relation2TCSpecify] [varchar](30) null
									   , [PrenatalCheckupsB4] [int] null
									   , [ScreenDate] [datetime] not null
									   , [TCDOB] [datetime] null
									   , [TCDOD] [datetime] null
									   , [TCNumber] [int] null
									   , [CaseProgramPK] [int]
									   , [CaseProgramCreateDate] [datetime] not null
									   , [CaseProgramCreator] [char](10) not null
									   , [CaseProgramEditDate] [datetime] null
									   , [CaseProgramEditor] [char](10) null
									   , [CaseStartDate] [datetime] not null
									   , [CurrentFAFK] [int] null
									   , [CurrentFAWFK] [int] null
									   , [CurrentFSWFK] [int] null
									   , [CurrentLevelDate] [datetime] not null
									   , [CurrentLevelFK] [int] not null
									   , [DischargeDate] [datetime] null
									   , [DischargeReason] [char](2) null
									   , [DischargeReasonSpecify] [varchar](500) null
									   , [ExtraField1] [char](30) null
									   , [ExtraField2] [char](30) null
									   , [ExtraField3] [char](30) null
									   , [ExtraField4] [char](30) null
									   , [ExtraField5] [char](30) null
									   , [ExtraField6] [char](30) null
									   , [ExtraField7] [char](30) null
									   , [ExtraField8] [char](30) null
									   , [ExtraField9] [char](30) null
									   , [HVCaseFK] [int] not null
									   , [HVCaseFK_old] [int] not null
									   , [OldID] [char](23) null
									   , [PC1ID] [char](13) not null
									   , [ProgramFK] [int] not null
									   , [TransferredtoProgram] [varchar](50) null
									   , [TransferredtoProgramFK] [int] null
									   , [CalcTCDOB] [datetime] null
										)


		insert	into #tblInitial_cohort
				select	[HVCasePK]
					  , [CaseProgress]
					  , [Confidentiality]
					  , [CPFK]
					  , [DateOBPAdded]
					  , [EDC]
					  , [FFFK]
					  , [FirstChildDOB]
					  , [FirstPrenatalCareVisit]
					  , [FirstPrenatalCareVisitUnknown]
					  , [HVCaseCreateDate]
					  , [HVCaseCreator]
					  , [HVCaseEditDate]
					  , [HVCaseEditor]
					  , [InitialZip]
					  , [IntakeDate]
					  , [IntakeLevel]
					  , [IntakeWorkerFK]
					  , [KempeDate]
					  , [OBPInformationAvailable]
					  , [OBPFK]
					  , [OBPinHomeIntake]
					  , [OBPRelation2TC]
					  , [PC1FK]
					  , [PC1Relation2TC]
					  , [PC1Relation2TCSpecify]
					  , [PC2FK]
					  , [PC2inHomeIntake]
					  , [PC2Relation2TC]
					  , [PC2Relation2TCSpecify]
					  , [PrenatalCheckupsB4]
					  , [ScreenDate]
					  , [TCDOB]
					  , [TCDOD]
					  , [TCNumber]
					  , [CaseProgramPK]
					  , [CaseProgramCreateDate]
					  , [CaseProgramCreator]
					  , [CaseProgramEditDate]
					  , [CaseProgramEditor]
					  , [CaseStartDate]
					  , [CurrentFAFK]
					  , [CurrentFAWFK]
					  , [CurrentFSWFK]
					  , [CurrentLevelDate]
					  , [CurrentLevelFK]
					  , [DischargeDate]
					  , [DischargeReason]
					  , [DischargeReasonSpecify]
					  , [ExtraField1]
					  , [ExtraField2]
					  , [ExtraField3]
					  , [ExtraField4]
					  , [ExtraField5]
					  , [ExtraField6]
					  , [ExtraField7]
					  , [ExtraField8]
					  , [ExtraField9]
					  , cp.[HVCaseFK]
					  , [HVCaseFK_old]
					  , [OldID]
					  , [PC1ID]
					  , cp.[ProgramFK]
					  , [TransferredtoProgram]
					  , [TransferredtoProgramFK]
					  , case when h.tcdob is not null then h.tcdob
							 else h.edc
						end as [CalcTCDOB]
				from	HVCase h
				inner join CaseProgram cp on h.HVCasePK = cp.HVCaseFK
				inner join dbo.SplitString(@programfk, ',') on cp.programfk = listitem
				left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
				left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
				inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
				where	case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
						and cp.CaseStartDate < @edate  -- handling transfer cases
						and (DischargeDate is null
							 or DischargeDate >= dateadd(mm, -27, @edate)
							);
	-- 1
		with	cteScreensFor1Cohort
				  as (	-- "1. Total Screens"
		-- Screens Row 1
					  select distinct
								--Chris Papas
								CONVERT(varchar(10), QuarterNumber) as QuarterNumber
							  , count(*) over (partition by [QuarterNumber]) as 'numberOfScreens'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.screendate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteScreensFor1
				  as (	-- "1. Total Screens"
		-- Screens Row 1
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(numberOfScreens, 0) as numberOfScreens
					  from		cteScreensFor1Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		

	-- 2
				cteKempAssessmentsFor2Cohort
				  as (	-- "2. Total Kempe Assessments"
		-- Kempe Assessment Row 2
					  select distinct
								QuarterNumber
							  , count(*) over (partition by [QuarterNumber]) as 'numberOfKempAssessments'
					  from		#tblInitial_cohort h
					  inner join Kempe k on k.HVCaseFK = h.HVCaseFK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessmentsFor2
				  as (	-- "2. Total Kempe Assessments"
		-- Kempe Assessment Row 2		
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(numberOfKempAssessments, 0) as numberOfKempAssessments
					  from		cteKempAssessmentsFor2Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		

	-- 2a
				cteKempAssessments_For2aCohort
				  as ( 	
	-- Kempe Assessment Percentage
	-- It will be done in two steps i.e. 1. Get numbers like KempPositive and TotalKemp 2. Then calc Percentage from them in cteKempAssessments_For2a_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalKemp'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a
				  as ( 	
	-- Kempe Assessment Percentage
	-- It will be done in two steps i.e. 1. Get numbers like KempPositive and TotalKemp 2. Then calc Percentage from them in cteKempAssessments_For2a_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalKemp, 0) as TotalKemp
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_Calc_Percentage
				  as (	-- "    a. % Positive" 
				-- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositive) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositive as float) * 100 / nullif(TotalKemp,
																										0), 0), 0))
								+ '%)' as KempPositivePercentage
					  from		cteKempAssessments_For2a
					 ) ,		

	-- 2a1
				cteKempAssessments_For2a_1Cohort
				  as ( 
	-- Kempe Assessment Percentage - Positive Enrolled
	-- It will be done in two steps i.e. 1. Get numbers like KempPositiveEnrolled and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_1_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , sum(case when ((k.KempeResult = 1)
											   and (h.IntakeDate is not null
													and h.IntakeDate <> ''
												   )
											  ) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositiveEnrolled'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a_1
				  as ( 
	-- Kempe Assessment Percentage - Positive Enrolled
	-- It will be done in two steps i.e. 1. Get numbers like KempPositiveEnrolled and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_1_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(KempPositiveEnrolled, 0) as KempPositiveEnrolled
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2a_1Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_1_Calc_Percentage
				  as (	-- "        1. % Positive Enrolled" 
				-- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositiveEnrolled) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositiveEnrolled as float) * 100
																  / nullif(KempPositive, 0), 0), 0)) + '%)' as KempPositiveEnrolled
					  from		cteKempAssessments_For2a_1
					 ) ,		

	-- 2a2
				cteKempAssessments_For2a_2Cohort
				  as ( 
	-- Kempe Assessment Percentage - Positive Pending Enrollment
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_2_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , sum(case when ((k.KempeResult = 1)
											   and (h.DischargeDate is null
													and h.IntakeDate is null
												   )
											  ) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositivePending'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a_2
				  as ( 
	-- Kempe Assessment Percentage - Positive Pending Enrollment
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_2_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(KempPositivePending, 0) as KempPositivePending
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2a_2Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_2_Calc_Percentage
				  as (	--	"        2. % Positive Pending Enrollment" 
				-- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositivePending) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositivePending as float) * 100
																  / nullif(KempPositive, 0), 0), 0)) + '%)' as KempPositivePending
					  from		cteKempAssessments_For2a_2
					 ) ,		

	-- 2a3
				cteKempAssessments_For2a_3Cohort
				  as ( 
	-- Kempe Assessment Percentage - Positive Terminated
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_3_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , sum(case when ((k.KempeResult = 1)
											   and (h.DischargeDate is not null
													and h.IntakeDate is null
												   )
											  ) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositiveTerminated'
							  , sum(case when k.KempeResult = 1 then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'KempPositive'
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2a_3
				  as ( 
	-- Kempe Assessment Percentage - Positive Terminated
	-- It will be done in two steps i.e. 1. Get numbers like KempPositivePending and KempPositive 2. Then calc Percentage from them in cteKempAssessments_For2a_3_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(KempPositiveTerminated, 0) as KempPositiveTerminated
							  , isnull(KempPositive, 0) as KempPositive
					  from		cteKempAssessments_For2a_3Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteKempAssessments_For2a_3_Calc_Percentage
				  as ( --"        3. % Positive Terminated"
			  -- Kempe Assessment Percentage Row 3				
					  select	QuarterNumber
							  , convert(varchar, KempPositiveTerminated) + ' ('
								+ convert(varchar, round(coalesce(cast(KempPositiveTerminated as float) * 100
																  / nullif(KempPositive, 0), 0), 0)) + '%)' as KempPositiveTerminated
					  from		cteKempAssessments_For2a_3
					 ) ,		

	-- 2b
				ctePositiveKempeScore
				  as (  -- find max score of mom/father/partner ... khalsa
					  select distinct
								q8.QuarterNumber
							  , (select	max(thisValue)
								 from	(select	isnull(cast(k.MomScore as decimal), 0) as thisValue
										 union all
										 select	isnull(cast(k.DadScore as decimal), 0) as thisValue
										 union all
										 select	isnull(cast(k.PartnerScore as decimal), 0) as thisValue
										) as khalsaTable
								) as KempeScore
					  from		#tblInitial_cohort h
					  left join Kempe k on k.HVCaseFK = h.HVCasePK
										   and k.KempeResult = 1 -- keeping 'k.KempeResult = 1' it here (not as in where clause down), it saved 3 seconds of execution time ... Khalsa
					  inner join #tblMake8Quarter q8 on k.KempeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteKempAssessments_For2bCohort
				  as ( -- "    b. Average Positive Mother Score"
	-- MomScore
					  select distinct
								QuarterNumber
							  , avg(KempeScore) over (partition by [QuarterNumber]) as 'AvgPositiveMotherScore'
					  from		ctePositiveKempeScore
					 ) ,
				cteKempAssessments_For2b
				  as ( -- "    b. Average Positive Mother Score"
	-- MomScore
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(AvgPositiveMotherScore, 0) as AvgPositiveMotherScore
					  from		cteKempAssessments_For2bCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	






	-- 3
				cteEnrolledAtBeginingOfQuarter3Cohort
				  as ( -- 3. Families Enrolled at Beginning of quarter
					  select distinct
								QuarterNumber
							  , count(HVCasePK) over (partition by [QuarterNumber]) as 'EnrolledAtBeginningOfQrtr'
					  from		#tblInitial_cohort ic
					  inner join #tblMake8Quarter q8 on ic.IntakeDate <= [QuarterStartDate]
														and ic.IntakeDate is not null
														and (ic.DischargeDate >= [QuarterStartDate]
															 or ic.DischargeDate is null
															)
					 ) ,
				cteEnrolledAtBeginingOfQuarter3
				  as ( -- 3. Families Enrolled at Beginning of quarter
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(EnrolledAtBeginningOfQrtr, 0) as EnrolledAtBeginningOfQrtr
					  from		cteEnrolledAtBeginingOfQuarter3Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	

	-- 4
				cteNewEnrollmentsThisQuarter4Cohort
				  as ( -- "4. New Enrollments this quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteNewEnrollmentsThisQuarter4
				  as ( -- "4. New Enrollments this quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(NewEnrollmentsThisQuarter, 0) as NewEnrollmentsThisQuarter
					  from		cteNewEnrollmentsThisQuarter4Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	

	--- 4a
				cteNewEnrollmentsThisQuarter4Again
				  as ( -- We will use this one in cteNewEnrollmentsThisQuarter4a. 
	  -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteNewEnrollmentsThisQuarter4aCohort
				  as ( 
	-- "    a. % Prenatal"
	-- It will be done in two steps i.e. 1. Get numbers like cteNewEnrollmentsThisQuarter4 and cteNewEnrollmentsThisQuarter4a 2. Then calc Percentage from them in cteNewEnrollmentsThisQuarter4a_Calc_Percentage ... khalsa
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'NewEnrollmentsPrenatal'
							  , q8Again.NewEnrollmentsThisQuarter as NewEnrollmentsThisQuarter
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					  inner join cteNewEnrollmentsThisQuarter4Again q8Again on q8Again.QuarterNumber = q8.QuarterNumber
					  where		h.[CalcTCDOB] > IntakeDate
					 ) ,
				cteNewEnrollmentsThisQuarter4a
				  as ( 
	-- "    a. % Prenatal"
	-- It will be done in two steps i.e. 1. Get numbers like cteNewEnrollmentsThisQuarter4 and cteNewEnrollmentsThisQuarter4a 2. Then calc Percentage from them in cteNewEnrollmentsThisQuarter4a_Calc_Percentage ... khalsa
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(NewEnrollmentsPrenatal, 0) as NewEnrollmentsPrenatal
							  , isnull(NewEnrollmentsThisQuarter, 0) as NewEnrollmentsThisQuarter
					  from		cteNewEnrollmentsThisQuarter4aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteNewEnrollmentsThisQuarter4a_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, NewEnrollmentsPrenatal) + ' ('
								+ convert(varchar, round(coalesce(cast(NewEnrollmentsPrenatal as float) * 100
																  / nullif(NewEnrollmentsThisQuarter, 0), 0), 0)) + '%)' as NewEnrollmentsPrenatal
					  from		cteNewEnrollmentsThisQuarter4a
					 ) ,	

	--- 4b
				cteNewEnrollmentsThisQuarter4Again2
				  as ( -- We will use this one in cteNewEnrollmentsThisQuarter4b. 
	  -- I am repeating it again here for code clarity. I mean that item 4a have its own code, one can see how I did
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'NewEnrollmentsThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					 ) ,
				cteNewEnrollmentsThisQuarter4bCohort
				  as ( -- "    b. % TANF Services Eligible at Enrollment**"
					  select distinct
								q8.QuarterNumber
							  , count(*) over (partition by q8.[QuarterNumber]) as 'TANFServicesEligible'
							  , q8Again2.NewEnrollmentsThisQuarter
					  from		#tblInitial_cohort h
					  inner join CommonAttributes ca on ca.HVCaseFK = h.HVCaseFK
					  inner join #tblMake8Quarter q8 on h.IntakeDate between [QuarterStartDate] and [QuarterEndDate]
					  inner join cteNewEnrollmentsThisQuarter4Again2 q8Again2 on q8Again2.QuarterNumber = q8.QuarterNumber
					  where		ca.TANFServices = 1
								and ca.FormType = 'IN'  -- only from Intake form here
								
					 ) ,
				cteNewEnrollmentsThisQuarter4b
				  as ( -- "    b. % TANF Services Eligible at Enrollment**"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TANFServicesEligible, 0) as TANFServicesEligible
							  , isnull(NewEnrollmentsThisQuarter, 0) as NewEnrollmentsThisQuarter
					  from		cteNewEnrollmentsThisQuarter4bCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteNewEnrollmentsThisQuarter4b_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, TANFServicesEligible) + ' ('
								+ convert(varchar, round(coalesce(cast(TANFServicesEligible as float) * 100
																  / nullif(NewEnrollmentsThisQuarter, 0), 0), 0)) + '%)' as TANFServicesEligible
					  from		cteNewEnrollmentsThisQuarter4b
					 ) ,	



	-- 5
				cteFamiliesDischargedThisQuarter5Cohort
				  as ( -- "5. Families Discharged this quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesDischargedThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.DischargeDate between [QuarterStartDate] and [QuarterEndDate]
					  where		h.IntakeDate is not null
					 ) ,
				cteFamiliesDischargedThisQuarter5
				  as ( -- "5. Families Discharged this quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesDischargedThisQuarter, 0) as FamiliesDischargedThisQuarter
					  from		cteFamiliesDischargedThisQuarter5Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		


	-- 5a
				cteFamiliesCompletingProgramThisQuarter5aCohort
				  as ( -- "    a. Families completing the program"
		-- Discharged after completing the program through Discharge Form
					  select distinct
								QuarterNumber
							  , sum(case when DischargeReason in (27, 29) then 1
										 else 0
									end) over (partition by [QuarterNumber]) as 'FamiliesCompletingProgramThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.DischargeDate between [QuarterStartDate] and [QuarterEndDate]
					  where		h.IntakeDate is not null
					 ) ,
				cteFamiliesCompletingProgramThisQuarter5a
				  as ( -- "    a. Families completing the program"
		-- Discharged after completing the program through Discharge Form
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesCompletingProgramThisQuarter, 0) as FamiliesCompletingProgramThisQuarter
					  from		cteFamiliesCompletingProgramThisQuarter5aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		

	-- 6
				cteFamiliesActiveAtEndOfThisQuarter6Cohort
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6
				  as ( -- "6. Families Active at end of this Quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
					  from		cteFamiliesActiveAtEndOfThisQuarter6Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,		



	-- 6a
				cteFamiliesActiveAtEndOfThisQuarter6Again
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6aCohort
				  as ( -- "    a. % on Level 1 at end of Quarter"
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
							  , q86a.FamiliesActiveAtEndOfThisQuarter as FamiliesActiveAtEndOfThisQuarter
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  inner join cteFamiliesActiveAtEndOfThisQuarter6Again q86a on q86a.QuarterNumber = q8.QuarterNumber
					  left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
								and ((q8.QuarterEndDate between hd.StartLevelDate and hd.EndLevelDate)
									 or (q8.QuarterEndDate >= hd.StartLevelDate
										 and hd.EndLevelDate is null
										)
									)  -- note: they still may be on level 1
								and LevelName in ('Level 1', 'Level 1-SS')
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6a
				  as ( -- "    a. % on Level 1 at end of Quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) as FamiliesActiveAtEndOfThisQuarterOnLevel1
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
					  from		cteFamiliesActiveAtEndOfThisQuarter6aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6a_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, FamiliesActiveAtEndOfThisQuarterOnLevel1) + ' ('
								+ convert(varchar, round(coalesce(cast(FamiliesActiveAtEndOfThisQuarterOnLevel1 as float)
																  * 100 / nullif(FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as FamiliesActiveAtEndOfThisQuarterOnLevel1
					  from		cteFamiliesActiveAtEndOfThisQuarter6a
					 ) ,	

	-- 6b
				cteFamiliesActiveAtEndOfThisQuarter6Again2
				  as ( -- "    b. % on Level X at end of Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6b
				  as ( -- "    b. % on Level X at end of Quarter"
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevelX'
							  , q86b.FamiliesActiveAtEndOfThisQuarter as FamiliesActiveAtEndOfThisQuarter
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  inner join cteFamiliesActiveAtEndOfThisQuarter6Again2 q86b on q86b.QuarterNumber = q8.QuarterNumber	
			--Note: we are making use of operator i.e. 'Outer Apply'
			-- because a columns values cann't be passed to a function in a join without this operator  ... khalsa
					  outer apply [udfHVLevel](@programfk, q8.QuarterEndDate) e3
					  where		h.IntakeDate is not null
								and h.IntakeDate <= q8.QuarterEndDate
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
								and e3.LevelName like 'Level X'
								and e3.hvcasefk = h.hvcasepk
								and e3.programfk = h.programfk
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters
				  as ( -- "    b. % on Level X at end of Quarter"
					  select	isnull(f6bmissing.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevelX, 0) as FamiliesActiveAtEndOfThisQuarterOnLevelX
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
					  from		cteFamiliesActiveAtEndOfThisQuarter6b f6bmissing
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = f6bmissing.QuarterNumber
					 ) ,
				cteFamiliesActiveAtEndOfThisQuarter6b_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, FamiliesActiveAtEndOfThisQuarterOnLevelX) + ' ('
								+ convert(varchar, round(coalesce(cast(FamiliesActiveAtEndOfThisQuarterOnLevelX as float)
																  * 100 / nullif(FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as FamiliesActiveAtEndOfThisQuarterOnLevelX
					  from		cteFamiliesActiveAtEndOfThisQuarter6bHandlingMissingQuarters
					 ) ,	

	-- 6c
				cteFamiliesActiveAtEndOfThisQuarter6Again3
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > QuarterEndDate
									)
					 ) ,
				cteFamiliesWithNoServiceReferrals6c
				  as ( -- "    c. % Families with no Service Referrals"
	  -- Find those records (hvcasepk) that are in cteFamiliesActiveAtEndOfThisQuarter6 but does not have Service Referral in table i.e.ServiceReferral
					  select distinct
								q8.QuarterNumber
							  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesWithNoServiceReferrals'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  left join ServiceReferral sr on sr.HVCaseFK = h.HVCaseFK
													  and (ReferralDate <= [QuarterEndDate]) -- leave it here the extra condition
					  where		h.IntakeDate is not null
								and h.IntakeDate <= [QuarterEndDate]
								and (h.DischargeDate is null
									 or h.DischargeDate > [QuarterEndDate]
									)
								and ReferralDate is null  -- This is important
								
					 ) ,
				cteFamiliesWithNoServiceReferrals6cMergeCohort
				  as ( -- "    c. % Families with no Service Referrals"
	  -- Note: There are quarters which are missing in cteFamiliesWithNoServiceReferrals6c because all active families have service referrals in those quarters.
	  -- therefore, we need  to merge to bring back missing quarters
					  select	a.QuarterNumber
							  , FamiliesActiveAtEndOfThisQuarter
							  , case when FamiliesWithNoServiceReferrals > 0 then FamiliesWithNoServiceReferrals
									 else 0
								end as FamiliesWithNoServiceReferrals
					  from		cteFamiliesActiveAtEndOfThisQuarter6Again3 a
					  left join cteFamiliesWithNoServiceReferrals6c b on a.QuarterNumber = b.QuarterNumber
					 ) ,
				cteFamiliesWithNoServiceReferrals6cMerge
				  as ( -- "    c. % Families with no Service Referrals"
	  -- Note: There are quarters which are missing in cteFamiliesWithNoServiceReferrals6c because all active families have service referrals in those quarters.
	  -- therefore, we need  to merge to bring back missing quarters
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(FamiliesActiveAtEndOfThisQuarter, 0) as FamiliesActiveAtEndOfThisQuarter
							  , isnull(FamiliesWithNoServiceReferrals, 0) as FamiliesWithNoServiceReferrals
					  from		cteFamiliesWithNoServiceReferrals6cMergeCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteFamiliesWithNoServiceReferrals6c_Calc_Percentage
				  as (select	QuarterNumber
							  , convert(varchar, FamiliesWithNoServiceReferrals) + ' ('
								+ convert(varchar, round(coalesce(cast(FamiliesWithNoServiceReferrals as float) * 100
																  / nullif(FamiliesActiveAtEndOfThisQuarter, 0), 0), 0))
								+ '%)' as FamiliesWithNoServiceReferrals
					  from		cteFamiliesWithNoServiceReferrals6cMerge
					 ) ,	

	-- 7	
				cteFamiliesActiveAtEndOfThisQuarter7LevelRateCohort
				  as -- calculate level for each case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select distinct
			q8.QuarterNumber
		  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
		  , sum(case when hd.StartLevelDate <= q8.QuarterStartDate then 1
					 when hd.StartLevelDate between q8.QuarterStartDate and q8.QuarterEndDate
					 then round(coalesce(cast(datediff(dd, hd.StartLevelDate, q8.QuarterEndDate) as float) * 100
										 / nullif(datediff(dd, q8.QuarterStartDate, q8.QuarterEndDate), 0), 0), 0) / 100
					 else 0
				end) over (partition by q8.[QuarterNumber]) as 'TotalLevelRate'
	 from	#tblInitial_cohort h
	 inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
	 left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
	 where	h.IntakeDate is not null
			and (h.DischargeDate is null
				 or h.DischargeDate > QuarterEndDate
				)
			and ((q8.QuarterEndDate between hd.StartLevelDate and hd.EndLevelDate)
				 or (q8.QuarterEndDate >= hd.StartLevelDate
					 and hd.EndLevelDate is null
					)
				)  -- note: they still may be on level 1
			and LevelName in ('Level 1', 'Level 1-SS')
	) ,			cteFamiliesActiveAtEndOfThisQuarter7LevelRate
				  as -- calculate level for each case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
		  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) as FamiliesActiveAtEndOfThisQuarterOnLevel1
		  , isnull(TotalLevelRate, 0) as TotalLevelRate
	 from	cteFamiliesActiveAtEndOfThisQuarter7LevelRateCohort s1
	 right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
	) ,			cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisitsCohort
				  as -- calculate visits per case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select distinct
			q8.QuarterNumber
		  , count(h.HVCasePK) over (partition by q8.[QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarterOnLevel1'
		  , sum(case when hd.StartLevelDate <= q8.QuarterStartDate then 1    -- count(hvcasepk) over (partition by q8.QuarterNumber) -- count of num of visits for the entire quarter if he was on level 1 before quarterstart
					 when VisitStartTime between hd.StartLevelDate and q8.QuarterEndDate then 1
					 else 0
				end) over (partition by q8.[QuarterNumber]) as 'TotalVisitRate'
	 from	#tblInitial_cohort h
	 left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
	 left outer join hvlog on h.hvcasefk = hvlog.hvcasefk
	 inner join #tblMake8Quarter q8 on hvlog.VisitStartTime between q8.QuarterStartDate and q8.QuarterEndDate
	 where	h.IntakeDate is not null
			and (h.DischargeDate is null
				 or h.DischargeDate > QuarterEndDate
				)
			and ((q8.QuarterEndDate between hd.StartLevelDate and hd.EndLevelDate)
				 or (q8.QuarterEndDate >= hd.StartLevelDate
					 and hd.EndLevelDate is null
					)
				)  -- note: they still may be on level 1
			and LevelName in ('Level 1', 'Level 1-SS')
	) ,			cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisits
				  as -- calculate visits per case
	( -- "7. Average Visits per Month per Case on Level 1"
	 select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
		  , isnull(FamiliesActiveAtEndOfThisQuarterOnLevel1, 0) as FamiliesActiveAtEndOfThisQuarterOnLevel1
		  , isnull(TotalVisitRate, 0) as TotalVisitRate
	 from	cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisitsCohort s1
	 right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
	) ,			cteFamiliesActiveAtEndOfThisQuarter7
				  as -- calculate visits per case
		( -- "7. Average Visits per Month per Case on Level 1"	
		 select	lr.QuarterNumber
			 --, lr.FamiliesActiveAtEndOfThisQuarterOnLevel1
			 --, TotalLevelRate
			 ----, nv.QuarterNumber
			 --, nv.FamiliesActiveAtEndOfThisQuarterOnLevel1
			 --, TotalVisitRate
			 --, ( TotalVisitRate / (3 * TotalLevelRate) ) AS AverageVisitsPerMonthPerCase
			  , round(coalesce(cast(TotalVisitRate as float) * 100 / nullif(3 * TotalLevelRate, 0), 0), 0) / 100 as AverageVisitsPerMonthPerCase
		 from	cteFamiliesActiveAtEndOfThisQuarter7LevelRate lr
		 inner join cteFamiliesActiveAtEndOfThisQuarter7NumberOfVisits nv on nv.QuarterNumber = lr.QuarterNumber
		) ,	

	-- 8
				cteTotalServedInQuarterIncludesClosedCases8Cohort
				  as ( -- "8. Total Served in Quarter(includes closed cases)"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalServedInQuarterIncludesClosedCases'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date		
								
					 ) ,
				cteTotalServedInQuarterIncludesClosedCases8
				  as ( -- "8. Total Served in Quarter(includes closed cases)"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalServedInQuarterIncludesClosedCases, 0) as TotalServedInQuarterIncludesClosedCases
					  from		cteTotalServedInQuarterIncludesClosedCases8Cohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	



	-- 8a
				cteAllFamilies8AgainFor8aCohort
				  as ( -- "8    a. Average Visits per Family"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalFamiliesServed'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date		
								
					 ) ,
				cteAllFamilies8AgainFor8a
				  as ( -- "8    a. Average Visits per Family"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalFamiliesServed, 0) as TotalFamiliesServed
					  from		cteAllFamilies8AgainFor8aCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteAllFamilies8aVisitsCohort
				  as ( -- "8    a. Average Visits per Family"
					  select  distinct
								QuarterNumber
							  , count(HVLog.HVLogPK) over (partition by [QuarterNumber]) as 'TotalHVlogActivities'
					  from		#tblInitial_cohort h
					  left join HVLevelDetail hd on hd.hvcasefk = h.hvcasefk
					  left outer join hvlog on h.hvcasefk = hvlog.hvcasefk
					  inner join #tblMake8Quarter q8 on hvlog.VisitStartTime between q8.QuarterStartDate and q8.QuarterEndDate
					  where		h.IntakeDate is not null
								and h.IntakeDate <= q8.[QuarterEndDate]
								and (h.DischargeDate is null
									 or h.DischargeDate >= [QuarterStartDate]
									) -- not discharged or discharged after the quarter start date	
								and HVLog.VisitType <> '00010'
					 ) ,
				cteAllFamilies8aVisits
				  as ( -- "8    a. Average Visits per Family"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TotalHVlogActivities, 0) as TotalHVlogActivities
					  from		cteAllFamilies8aVisitsCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteAverageVisitsPerFamily8a
				  as (  -- "8    a. Average Visits per Family"
					  select	lr.QuarterNumber
			 --, TotalFamiliesServed
			 ----, nv.QuarterNumber
			 --, TotalHVlogActivities		
							  , round(coalesce(cast(TotalHVlogActivities as float) * 100 / nullif(3
																								  * TotalFamiliesServed,
																								  0), 0), 0) / 100 as AverageVisitsPerFamily
					  from		cteAllFamilies8AgainFor8a lr
					  inner join cteAllFamilies8aVisits nv on nv.QuarterNumber = lr.QuarterNumber
					 ) ,	

	-- 8b	
				cteAllFamilies8AgainFor8b
				  as ( -- "8    a. Average Visits per Family"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'TotalFamiliesServed'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date		
								
					 ) ,	


	-- 8b
				cteAverageVisitsPerFamily8bCohort
				  as (  -- "8    b. % TANF Services Eligible at enrollment**"
					  select distinct
								q8.QuarterNumber
							  , count(*) over (partition by q8.[QuarterNumber]) as 'TANFServicesEligible'
							  , q8b.TotalFamiliesServed
					  from		#tblInitial_cohort h
					  inner join CommonAttributes ca on ca.HVCaseFK = h.HVCaseFK
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  inner join cteAllFamilies8AgainFor8b q8b on q8b.QuarterNumber = q8.QuarterNumber
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterStartDate
									) -- not discharged or discharged after the quarter start date	
								and ca.TANFServices = 1
								and ca.FormType = 'IN'  -- only from Intake form here	
								
					 ) ,
				cteAverageVisitsPerFamily8b
				  as (  -- "8    b. % TANF Services Eligible at enrollment**"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(TANFServicesEligible, 0) as TANFServicesEligible
							  , isnull(TotalFamiliesServed, 0) as TotalFamiliesServed
					  from		cteAverageVisitsPerFamily8bCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,	

	-- 8b
				cteAverageVisitsPerFamily8bFinal
				  as (  -- "8    b. % TANF Services Eligible at enrollment**"
					  select	QuarterNumber
							  , convert(varchar, TANFServicesEligible) + ' ('
								+ convert(varchar, round(coalesce(cast(TANFServicesEligible as float) * 100
																  / nullif(TotalFamiliesServed, 0), 0), 0)) + '%)' as TANFServicesEligibleAtEnrollment
					  from		cteAverageVisitsPerFamily8b
					 ) ,	

	-- 9
				cteLengthInProgram9
				  as ( -- "9. Length in Program for Active at End of Quarter"
					  select	q8.QuarterNumber
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) between 0 and 182) then 1
									 else 0
								end as 'LengthInProgramUnder6Months'
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) between 183 and 365) then 1
									 else 0
								end as 'LengthInProgramUnder6MonthsTo1Year'
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) between 366 and 730) then 1
									 else 0
								end as 'LengthInProgramUnder1YearTo2Year'
							  , case when (datediff(dd, h.IntakeDate, q8.[QuarterEndDate]) > 730) then 1
									 else 0
								end as 'LengthInProgramUnder2YearsAndOver'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate > [QuarterEndDate]
									) -- active cases			
								
					 ) ,
				cteLengthInProgram9SumCohort
				  as ( -- "9. Length in Program for Active at End of Quarter"
					  select distinct
								QuarterNumber
							  , sum(LengthInProgramUnder6Months) over (partition by [QuarterNumber]) as 'LengthInProgramUnder6Months'
							  , sum(LengthInProgramUnder6MonthsTo1Year) over (partition by [QuarterNumber]) as 'LengthInProgramUnder6MonthsTo1Year'
							  , sum(LengthInProgramUnder1YearTo2Year) over (partition by [QuarterNumber]) as 'LengthInProgramUnder1YearTo2Year'
							  , sum(LengthInProgramUnder2YearsAndOver) over (partition by [QuarterNumber]) as 'LengthInProgramUnder2YearsAndOver'
					  from		cteLengthInProgram9
					 ) ,
				cteLengthInProgram9Sum
				  as ( -- "9. Length in Program for Active at End of Quarter"
					  select	isnull(s1.QuarterNumber, q8.QuarterNumber) as QuarterNumber
							  , isnull(LengthInProgramUnder6Months, 0) as LengthInProgramUnder6Months
							  , isnull(LengthInProgramUnder6MonthsTo1Year, 0) as LengthInProgramUnder6MonthsTo1Year
							  , isnull(LengthInProgramUnder1YearTo2Year, 0) as LengthInProgramUnder1YearTo2Year
							  , isnull(LengthInProgramUnder2YearsAndOver, 0) as LengthInProgramUnder2YearsAndOver
					  from		cteLengthInProgram9SumCohort s1
					  right join #tblMake8Quarter q8 on q8.QuarterNumber = s1.QuarterNumber
					 ) ,
				cteLengthInProgramAtEndOfThisQuarter9
				  as ( -- "6. Families Active at end of this Quarter"
					  select distinct
								QuarterNumber
							  , count(h.HVCasePK) over (partition by [QuarterNumber]) as 'FamiliesActiveAtEndOfThisQuarter'
					  from		#tblInitial_cohort h
					  inner join #tblMake8Quarter q8 on h.IntakeDate <= [QuarterEndDate]
					  where		h.IntakeDate is not null
								and (h.DischargeDate is null
									 or h.DischargeDate >= QuarterEndDate
									)
					 ) ,
				cteLengthInProgramFinal
				  as (  -- "9. Length in Program for Active at End of Quarter"
					  select	cl.QuarterNumber
							  , convert(varchar, LengthInProgramUnder6Months) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder6Months as float) * 100
																  / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as LengthInProgramUnder6Months
							  , convert(varchar, LengthInProgramUnder6MonthsTo1Year) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder6MonthsTo1Year as float)
																  * 100 / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0),
																  0), 0)) + '%)' as LengthInProgramUnder6MonthsTo1Year
							  , convert(varchar, LengthInProgramUnder1YearTo2Year) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder1YearTo2Year as float) * 100
																  / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as LengthInProgramUnder1YearTo2Year
							  , convert(varchar, LengthInProgramUnder2YearsAndOver) + ' ('
								+ convert(varchar, round(coalesce(cast(LengthInProgramUnder2YearsAndOver as float) * 100
																  / nullif(ct.FamiliesActiveAtEndOfThisQuarter, 0), 0),
														 0)) + '%)' as LengthInProgramUnder2YearsAndOver
					  from		cteLengthInProgram9Sum cl
					  inner join cteLengthInProgramAtEndOfThisQuarter9 ct on ct.QuarterNumber = cl.QuarterNumber
					 )
			---- exec [rspProgramInformationFor8Quarters] '2','06/30/2012'


--SELECT * FROM cteLengthInProgramFinal


	-- For report Summary - Just add the new row (add another inner join for a newly created cte for the new row in the report summary) ... Khalsa

	insert	into #tblQ8ReportMain
			(QuarterNumber
		   , QuarterEndDate
		   , numberOfScreens
		   , numberOfKempAssessments
		   , KempPositivePercentage
		   , KempPositiveEnrolled
		   , KempPositivePending
		   , KempPositiveTerminated
		   , AvgPositiveMotherScore
		   , EnrolledAtBeginningOfQrtr
		   , NewEnrollmentsThisQuarter
		   , NewEnrollmentsPrenatal
		   , TANFServicesEligible
		   , FamiliesDischargedThisQuarter
		   , FamiliesCompletingProgramThisQuarter
		   , FamiliesActiveAtEndOfThisQuarter
		   , FamiliesActiveAtEndOfThisQuarterOnLevel1
		   , FamiliesActiveAtEndOfThisQuarterOnLevelX
		   , FamiliesWithNoServiceReferrals
		   , AverageVisitsPerMonthPerCase
		   , TotalServedInQuarterIncludesClosedCases
		   , AverageVisitsPerFamily
		   , TANFServicesEligibleAtEnrollment
		   , rowBlankforItem9
		   , LengthInProgramUnder6Months
		   , LengthInProgramUnder6MonthsTo1Year
		   , LengthInProgramUnder1YearTo2Year
		   , LengthInProgramUnder2YearsAndOver	
			)
			select	scrns.QuarterNumber
				  , left(convert(varchar, q8.QuarterEndDate, 120), 10) as QuarterEndDate -- convert into string
				  , numberOfScreens
				  , numberOfKempAssessments
				  , q82a.KempPositivePercentage
				  , q82a1.KempPositiveEnrolled
				  , q82a2.KempPositivePending
				  , q82a3.KempPositiveTerminated
				  , convert(decimal(4, 1), q82b.AvgPositiveMotherScore) as AvgPositiveMotherScore
				  , q83.EnrolledAtBeginningOfQrtr
				  , q84.NewEnrollmentsThisQuarter
				  , q84a.NewEnrollmentsPrenatal
				  , q84b.TANFServicesEligible
				  , q85.FamiliesDischargedThisQuarter
				  , q85a.FamiliesCompletingProgramThisQuarter
				  , q86.FamiliesActiveAtEndOfThisQuarter
				  , q86a.FamiliesActiveAtEndOfThisQuarterOnLevel1
				  , q86b.FamiliesActiveAtEndOfThisQuarterOnLevelX
				  , q86c.FamiliesWithNoServiceReferrals
				  , q87.AverageVisitsPerMonthPerCase
				  , q88.TotalServedInQuarterIncludesClosedCases
				  , q88a.AverageVisitsPerFamily
				  , q88b.TANFServicesEligibleAtEnrollment
				  , '' as rowBlankforItem9
				  , q9.LengthInProgramUnder6Months
				  , q9.LengthInProgramUnder6MonthsTo1Year
				  , q9.LengthInProgramUnder1YearTo2Year
				  , q9.LengthInProgramUnder2YearsAndOver
			from	cteScreensFor1 scrns
			inner join cteKempAssessmentsFor2 ka on ka.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_Calc_Percentage q82a on q82a.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_1_Calc_Percentage q82a1 on q82a1.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_2_Calc_Percentage q82a2 on q82a2.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2a_3_Calc_Percentage q82a3 on q82a3.QuarterNumber = scrns.QuarterNumber
			inner join cteKempAssessments_For2b q82b on q82b.QuarterNumber = scrns.QuarterNumber
			inner join cteEnrolledAtBeginingOfQuarter3 q83 on q83.QuarterNumber = scrns.QuarterNumber
			inner join cteNewEnrollmentsThisQuarter4 q84 on q84.QuarterNumber = scrns.QuarterNumber
			inner join cteNewEnrollmentsThisQuarter4a_Calc_Percentage q84a on q84a.QuarterNumber = scrns.QuarterNumber
			inner join cteNewEnrollmentsThisQuarter4b_Calc_Percentage q84b on q84b.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesDischargedThisQuarter5 q85 on q85.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesCompletingProgramThisQuarter5a q85a on q85a.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter6 q86 on q86.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter6a_Calc_Percentage q86a on q86a.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter6b_Calc_Percentage q86b on q86b.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesWithNoServiceReferrals6c_Calc_Percentage q86c on q86c.QuarterNumber = scrns.QuarterNumber
			inner join cteFamiliesActiveAtEndOfThisQuarter7 q87 on q87.QuarterNumber = scrns.QuarterNumber
			inner join cteTotalServedInQuarterIncludesClosedCases8 q88 on q88.QuarterNumber = scrns.QuarterNumber
			inner join cteAverageVisitsPerFamily8a q88a on q88a.QuarterNumber = scrns.QuarterNumber
			inner join cteAverageVisitsPerFamily8bFinal q88b on q88b.QuarterNumber = scrns.QuarterNumber
			inner join cteLengthInProgramFinal q9 on q9.QuarterNumber = scrns.QuarterNumber
			inner join #tblMake8Quarter q8 on q8.QuarterNumber = scrns.QuarterNumber
			order by scrns.QuarterNumber 



		insert	into #tblQ8ReportMain
				(QuarterNumber
			   , QuarterEndDate
			   , numberOfScreens
			   , numberOfKempAssessments
			   , KempPositivePercentage
			   , KempPositiveEnrolled
			   , KempPositivePending
			   , KempPositiveTerminated
			   , AvgPositiveMotherScore
			   , EnrolledAtBeginningOfQrtr
			   , NewEnrollmentsThisQuarter
			   , NewEnrollmentsPrenatal
			   , TANFServicesEligible
			   , FamiliesDischargedThisQuarter
			   , FamiliesCompletingProgramThisQuarter
			   , FamiliesActiveAtEndOfThisQuarter
			   , FamiliesActiveAtEndOfThisQuarterOnLevel1
			   , FamiliesActiveAtEndOfThisQuarterOnLevelX
			   , FamiliesWithNoServiceReferrals
			   , AverageVisitsPerMonthPerCase
			   , TotalServedInQuarterIncludesClosedCases
			   , AverageVisitsPerFamily
			   , TANFServicesEligibleAtEnrollment
			   , rowBlankforItem9
			   , LengthInProgramUnder6Months
			   , LengthInProgramUnder6MonthsTo1Year
			   , LengthInProgramUnder1YearTo2Year
			   , LengthInProgramUnder2YearsAndOver	

				)
				select	99
					  , 'Last day of Quarter'
					  , '1. Total Screens'
					  , '2. Total Kempe Assessments'
					  , '    a. % Positive'
					  , '        1. % Positive Enrolled'
					  , '        2. % Positive Pending Enrollment'
					  , '        3. % Positive Terminated'
					  , '    b. Average Positive Score'
					  , '3. Families Enrolled at Beginning of quarter'
					  , '4. New Enrollments this quarter'
					  , '    a. % Prenatal'
					  , '    b. % TANF Services Eligible at Enrollment**'
					  , '5. Families Discharged this quarter'
					  , '    a. Families completing the program'
					  , '6. Families Active at end of this Quarter'
					  , '    a. % on Level 1 at end of Quarter'
					  , '    b. % on Level X at end of Quarter'
					  , '    c. % Families with no Service Referrals'
					  , '7. Average Visits per Month per Case on Level 1 or Level 1-SS'
					  , '8. Total Served in Quarter(includes closed cases)'
					  , '    a. Average Visits per Family'
					  , '    b. % TANF Services Eligible at enrollment**'
					  , '9. Length in Program for Active at End of Quarter'
					  , '    a. Under 6 months'
					  , '    b. 6 months up to 1 year'
					  , '    c. 1 year up to 2 years'
					  , '    d. 2 years and Over'			

-- handling when there is no data available e.g. for a new program that just joins hfny like Dominican Womens
-- add quarters with missing data. just add rows for those quarters with placeholders containing fake/imaginery data
				union all
				select	[QuarterNumber]
					  , left(convert(varchar, QuarterEndDate, 120), 10) as QuarterEndDate
					  , [Col1]
					  , [Col2]
					  , [Col3]
					  , [Col4]
					  , [Col5]
					  , [Col6]
					  , [Col7]
					  , [Col8]
					  , [Col9]
					  , [Col10]
					  , [Col11]
					  , [Col12]
					  , [Col13]
					  , [Col14]
					  , [Col15]
					  , [Col16]
					  , [Col17]
					  , [Col18]
					  , [Col19]
					  , [Col20]
					  , [Col21]
					  , [Col22]
					  , [Col23]
					  , [Col24]
					  , [Col25]
					  , [Col26]
				from	#tblMake8Quarter
				where	QuarterNumber not in (select	QuarterNumber
											  from		#tblQ8ReportMain)

---- exec [rspProgramInformationFor8Quarters] '2','06/30/2012'
--SELECT * from #tblQ8ReportMain

-- Objective: Transpose Rows into Columns - what a pain in the ...
-- Idea: Create 9 variable tables and later join them to get our final result
-- Note: in each variable table, we are using UnPivot method  ... Khalsa


		declare	@tblcol99 table ([Q8Columns] varchar(max)
							   , [Q8LeftNavText] varchar(max)
								)

		declare	@tblcol1 table ([Q8Columns] varchar(max)
							  , [Q8Col1] varchar(max)
							   )

		declare	@tblcol2 table ([Q8Columns] varchar(max)
							  , [Q8Col2] varchar(max)
							   )

		declare	@tblcol3 table ([Q8Columns] varchar(max)
							  , [Q8Col3] varchar(max)
							   )

		declare	@tblcol4 table ([Q8Columns] varchar(max)
							  , [Q8Col4] varchar(max)
							   )

		declare	@tblcol5 table ([Q8Columns] varchar(max)
							  , [Q8Col5] varchar(max)
							   )

		declare	@tblcol6 table ([Q8Columns] varchar(max)
							  , [Q8Col6] varchar(max)
							   )

		declare	@tblcol7 table ([Q8Columns] varchar(max)
							  , [Q8Col7] varchar(max)
							   )

		declare	@tblcol8 table ([Q8Columns] varchar(max)
							  , [Q8Col8] varchar(max)
							   );
		with	cteCol99
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 99
					 )
			insert	into @tblcol99
					select	field
						  , value
					from	cteCol99 as col1 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol99


-- column1
;

		with	cteCol1
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 1
					 )
			insert	into @tblcol1
					select	field
						  , value
					from	cteCol1 as col1 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol1


-- column2
;
		with	cteCol2
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 2
					 )
			insert	into @tblcol2
					select	field
						  , value
					from	cteCol2 as col2 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol2

-- column3
;
		with	cteCol3
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 3
					 )
			insert	into @tblcol3
					select	field
						  , value
					from	cteCol3 as col3 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol3

-- column4
;
		with	cteCol4
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 4
					 )
			insert	into @tblcol4
					select	field
						  , value
					from	cteCol4 as col4 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol4

-- column5
;
		with	cteCol5
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 5
					 )
			insert	into @tblcol5
					select	field
						  , value
					from	cteCol5 as col5 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol5

-- column6
;
		with	cteCol6
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 6
					 )
			insert	into @tblcol6
					select	field
						  , value
					from	cteCol6 as col6 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol6

-- column7
;
		with	cteCol7
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 7
					 )
			insert	into @tblcol7
					select	field
						  , value
					from	cteCol7 as col7 unpivot 



( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol7

-- column8
;
		with	cteCol8
				  as (select	*
					  from		#tblQ8ReportMain as Q8Report
					  where		Q8Report.QuarterNumber = 8
					 )
			insert	into @tblcol8
					select	field
						  , value
					from	cteCol8 as col8 unpivot 
( value for field in (QuarterEndDate, numberOfScreens, numberOfKempAssessments, KempPositivePercentage,
					  KempPositiveEnrolled, KempPositivePending, KempPositiveTerminated, AvgPositiveMotherScore,
					  EnrolledAtBeginningOfQrtr, NewEnrollmentsThisQuarter, NewEnrollmentsPrenatal, TANFServicesEligible,
					  FamiliesDischargedThisQuarter, FamiliesCompletingProgramThisQuarter,
					  FamiliesActiveAtEndOfThisQuarter, FamiliesActiveAtEndOfThisQuarterOnLevel1,
					  FamiliesActiveAtEndOfThisQuarterOnLevelX, FamiliesWithNoServiceReferrals,
					  AverageVisitsPerMonthPerCase, TotalServedInQuarterIncludesClosedCases, AverageVisitsPerFamily,
					  TANFServicesEligibleAtEnrollment, rowBlankforItem9, LengthInProgramUnder6Months,
					  LengthInProgramUnder6MonthsTo1Year, LengthInProgramUnder1YearTo2Year,
					  LengthInProgramUnder2YearsAndOver) ) unpvtCol8



-- Now get the desired output ... Khalsa
-- get all the columns and put them together now
		select	Q8LeftNavText
			  , c1.Q8Col1
			  , c2.Q8Col2
			  , c3.Q8Col3
			  , c4.Q8Col4
			  , c5.Q8Col5
			  , c6.Q8Col6
			  , c7.Q8Col7
			  , c8.Q8Col8
		from	@tblcol99 c99
		inner join @tblcol1 c1 on c1.Q8Columns = c99.Q8Columns
		inner join @tblcol2 c2 on c2.Q8Columns = c99.Q8Columns
		inner join @tblcol3 c3 on c3.Q8Columns = c99.Q8Columns
		inner join @tblcol4 c4 on c4.Q8Columns = c99.Q8Columns
		inner join @tblcol5 c5 on c5.Q8Columns = c99.Q8Columns
		inner join @tblcol6 c6 on c6.Q8Columns = c99.Q8Columns
		inner join @tblcol7 c7 on c7.Q8Columns = c99.Q8Columns
		inner join @tblcol8 c8 on c8.Q8Columns = c99.Q8Columns


		drop table #tblQ8ReportMain
		drop table #tblMake8Quarter
		drop table #tblInitial_cohort
-- exec [rspProgramInformationFor8Quarters] '5','06/30/2012'
	end
GO
PRINT N'Altering [dbo].[rspQAReport14]'
GO
-- =============================================
-- Author:		<Devinder Singh Khalsa>
-- Create date: <October 18, 2012>
-- Description:	<This QA report gets you '14. No Home Visits since <xdate-60> for Active Cases Excludes Level X and Level 4 Cases '>
-- Modified: <10-20-15 Fix calc DOB cdc>
-- rspQAReport1-4 31, 'summary'	--- for summary page
-- rspQAReport14 31			--- for main report - location = 2
-- rspQAReport14 null			--- for main report for all locations
-- =============================================


ALTER procedure [dbo].[rspQAReport14](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
AS
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

-- Last Day of Previous Month 
Declare @LastDayofPreviousMonth DateTime 
Set @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point

--Set @LastDayofPreviousMonth = '05/31/2012'

DECLARE @Back2MonthsFromAnalysisPoint DateTime
SET @Back2MonthsFromAnalysisPoint = dateadd(m,-2,@LastDayofPreviousMonth)

--SELECT @Back2MonthsFromAnalysisPoint	

--DECLARE @tbl4QAReport14 TABLE(
--	HVCasePK INT, 
--	[PC1ID] [char](13),
--	LengthInProgress INT,
--	Worker [varchar](200),	
--	currentLevel [varchar](50)	
--	)

	
DECLARE @tbl4QAReport14Final TABLE(	
	HVCasePK INT, 
	[PC1ID] [char](13),		
	LastVisitAttempted [datetime],
	LastVisitActual [datetime],  	
	Worker [varchar](200),
	currentLevel [varchar](50)	
	)

-- table variable for holding Init Required Data
DECLARE @tbl4QAReport14Detail TABLE(
	HVCasePK INT, 
	[PC1ID] [char](13),	
	TCDOB [datetime],
	FormDueDate [datetime],	
	Worker [varchar](200),
	currentLevel [varchar](50),
	IntakeDate [datetime],
	DischargeDate [datetime],
	CaseProgress [NUMERIC] (3),
	IntakeLevel [char](1),
	TCNumber INT,
	MultipleBirth [char](3),
	XDateAge INT,
	TCName [varchar](200),
	DaysSinceLastMedicalFormEdit INT,
	LengthInProgress INT  
	)

INSERT INTO @tbl4QAReport14Detail(
	HVCasePK,
	[PC1ID],
	TCDOB,
	FormDueDate,
	Worker,
	currentLevel,
	IntakeDate,
	DischargeDate,
	CaseProgress,
	IntakeLevel,
	TCNumber,
	MultipleBirth,
	XDateAge,
	TCName,
	DaysSinceLastMedicalFormEdit,
	LengthInProgress	
)
select 
	 h.HVCasePK, 
	cp.PC1ID,
	case
	   when h.tcdob is not null then
		   h.tcdob
	   else
		   h.edc
	end as tcdob,
	
	--	Form due date is 30.44 days after intake if postnatal at intake or 30.44 days after TC DOB if prenatal at intake
	case
	   when (h.tcdob is not NULL AND h.tcdob <= h.IntakeDate) THEN -- postnatal
		   dateadd(mm,1,h.IntakeDate) 
	   when (h.tcdob is not NULL AND h.tcdob > h.IntakeDate) THEN -- pretnatal
					dateadd(mm,1,h.tcdob) 
	   when (h.tcdob is NULL AND h.edc > h.IntakeDate) THEN -- pretnatal
					dateadd(mm,1,h.edc) 					
	end as FormDueDate,
	
	LTRIM(RTRIM(fsw.firstname))+' '+LTRIM(RTRIM(fsw.lastname)) as worker,

	codeLevel.LevelName,
	h.IntakeDate,
	cp.DischargeDate,
	h.CaseProgress,
	h.IntakeLevel,
	h.TCNumber,
	CASE WHEN h.TCNumber > 1 THEN 'Yes' ELSE 'No' End
	as [MultipleBirth],
		case
	   when h.tcdob is not null then
		 datediff(dd, h.tcdob,  @LastDayofPreviousMonth)
	   else
		   datediff(dd, h.edc, @LastDayofPreviousMonth)
	end as XDateAge,
	'' AS TCName,
	''  AS DaysSinceLastMedicalFormEdit,
	datediff(dd, h.IntakeDate,  @LastDayofPreviousMonth)  AS LengthInProgress
		
	from dbo.CaseProgram cp
	inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
	left join codeLevel on cp.CurrentLevelFK = codeLevel.codeLevelPK
	inner join dbo.HVCase h ON cp.HVCaseFK = h.HVCasePK	
	inner join worker fsw on cp.CurrentFSWFK = fsw.workerpk
	
	
	where   ((h.IntakeDate <= dateadd(M, -1, @LastDayofPreviousMonth)) AND (h.IntakeDate IS NOT NULL))	 		  
			AND (cp.DischargeDate IS NULL OR cp.DischargeDate > @LastDayofPreviousMonth)
			AND codeLevel.LevelName NOT IN ('Level 4', 'Level X')
			AND cp.CaseStartDate <= @Back2MonthsFromAnalysisPoint  -- new 			
			order by h.HVCasePK -- h.IntakeDate 

--SELECT * FROM @tbl4QAReport14Detail

;
WITH cteHVLogRegularVisits AS
(

		SELECT HVCaseFK FROM HVLog h 
		inner join dbo.SplitString(@programfk,',') on h.programfk = listitem
		WHERE cast(VisitStartTime AS DATE) BETWEEN @Back2MonthsFromAnalysisPoint AND @LastDayofPreviousMonth
		AND VisitType <> '00010' -- all regular visits
		GROUP BY HVCaseFK
	
)


	SELECT HVCasePK
		 , PC1ID
		 , LengthInProgress
		 , Worker
		 , currentLevel
		INTO #tbl4QAReport14 -- Used temp table, because insert same into a variable table name like @tbl4QAReport14, SQL Server was taking 5 secs to complete ... Khalsa
	 FROM @tbl4QAReport14Detail qa3
	 WHERE HVCasePK NOT IN (SELECT HVCaseFK FROM cteHVLogRegularVisits h)  

 

-- rspQAReport14 31 ,'summary'
---- fill in LastVisit and LastAttempted

;
WITH cteHVLogAttempted AS
(
	SELECT HVCaseFK,max(VisitStartTime) VisitStartTime FROM HVLog h 
	inner join dbo.SplitString(@programfk,',') on h.programfk = listitem
	WHERE VisitType = '00010' -- all attempted visits
	GROUP BY HVCaseFK 
	
)
,
 cteHVLogActualVisits AS
(
	SELECT HVCaseFK,max(VisitStartTime) VisitStartTime FROM HVLog h 
	inner join dbo.SplitString(@programfk,',') on h.programfk = listitem
	WHERE VisitType <> '00010' -- all regular visits
	AND VisitStartTime < @LastDayofPreviousMonth
	GROUP BY HVCaseFK 
	
)

INSERT INTO @tbl4QAReport14Final
(
	   HVCasePK
	 , PC1ID	 
	 , LastVisitAttempted
	 , LastVisitActual
	 , Worker
	 , currentLevel
)
SELECT HVCasePK
	 , PC1ID
	 , att.VisitStartTime AS DateLastAttempted
	 , act.VisitStartTime AS LastHomeVisitDate	 
	 , Worker
	 , currentLevel

 FROM #tbl4QAReport14 qa14
 LEFT JOIN cteHVLogAttempted att ON att.HVCaseFK = qa14.HVCasePK 
 LEFT JOIN cteHVLogActualVisits act ON act.HVCaseFK = qa14.HVCasePK 
 ORDER BY Worker 

DROP TABLE #tbl4QAReport14

-- rspQAReport14 31 ,'summary'

if @ReportType='summary'
BEGIN 

DECLARE @numOfALLScreens INT = 0

-- Note: We using sum on TCNumber to get correct number of cases, as there may be twins etc.
SET @numOfALLScreens = (SELECT count(HVCasePK) FROM @tbl4QAReport14Detail)  

DECLARE @numOfActiveIntakeCases INT = 0
SET @numOfActiveIntakeCases = (SELECT count(HVCasePK) FROM @tbl4QAReport14Final)

-- leave the following here
if @numOfALLScreens is null
SET @numOfALLScreens = 0

if @numOfActiveIntakeCases is null
SET @numOfActiveIntakeCases = 0

DECLARE @tbl4QAReport14Summary TABLE(
	[SummaryId] INT,
	[SummaryText] [varchar](200),
	[SummaryTotal] [varchar](100)
)

INSERT INTO @tbl4QAReport14Summary([SummaryId],[SummaryText],[SummaryTotal])
VALUES(14 ,'No Home Visits since ' + convert(VARCHAR(12),@Back2MonthsFromAnalysisPoint, 101) + ' for Active Cases Excludes Level X and Level 4 Cases (N=' + CONVERT(VARCHAR,@numOfALLScreens) + ')' 
,CONVERT(VARCHAR,@numOfActiveIntakeCases) + ' (' + CONVERT(VARCHAR, round(COALESCE(cast(@numOfActiveIntakeCases AS FLOAT) * 100/ NULLIF(@numOfALLScreens,0), 0), 0))  + '%)'
)

SELECT * FROM @tbl4QAReport14Summary	

END
ELSE
BEGIN

SELECT 	
    PC1ID,
    
		case
		   when LastVisitActual is not null then
			   convert(varchar(10),LastVisitActual,101)
		   else
			   ''
		end as LastVisitActual,    

		case
		   when LastVisitAttempted is not null then
			   convert(varchar(10),LastVisitAttempted,101)
		   else
			   ''
		end as LastVisitAttempted        
    

  , Worker
  , currentLevel
 FROM @tbl4QAReport14Final


--- rspQAReport14 31 ,'summary'

END
GO
PRINT N'Altering [dbo].[rspQAReport19]'
GO
-- =============================================
-- Author:		Dhruv Patel
-- Create date: 2015-08-04
-- Description:	Adds an additional report to the QA report for Home 
--				Visit Logs missing attachments
-- exec rspQAReport19 1, 'summary'
-- exec rspQAReport19 1, 'detail'
-- =============================================
ALTER procedure [dbo].[rspQAReport19](
@programfk    varchar(max)    = NULL,
@ReportType char(7) = NULL 

)
as
declare @CutOffDate date
set @CutOffDate = '2015-05-01'
if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')
	
	-- Last Day of Previous Month 
Declare @LastDayofPreviousMonth DateTime 
Set @LastDayofPreviousMonth = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) -- analysis point


set @CutOffDate = DATEADD(m, -3,  @LastDayofPreviousMonth) + 1


DECLARE @endDt AS DATE 
SET @endDt = DATEADD(dd, DATEDIFF(dd, 0, @LastDayofPreviousMonth), 0)

DECLARE @tbl4QAReportCohort TABLE(
	HVCaseFK int,
	HVLogPK int,
	PC1ID char(13),
	VisitStartTime datetime,
	CurrentLevel varchar(30), 
	CurrentWorker varchar(40)
)

insert into @tbl4QAReportCohort
        ( HVCaseFK ,
		  HVLogPK ,
          PC1ID ,
          VisitStartTime ,
          CurrentLevel ,
          CurrentWorker 
        )
select hv.HVCaseFK
		, hv.HVLogPK
		, PC1ID
		, VisitStartTime
		, CurrentLevel = cl.LevelName
		, CurrentWorker = rtrim(w.FirstName) + ' ' + rtrim(w.LastName)
		from HVLog hv 
		inner join CaseProgram cp on cp.HVCaseFK = hv.HVCaseFK and cp.ProgramFK = hv.ProgramFK
		left join codeLevel cl on cp.CurrentLevelFK = cl.codeLevelPK
		inner join Worker w on w.WorkerPK = cp.CurrentFSWFK
		where cp.ProgramFK = @ProgramFK 
				and hv.VisitType <> '00010'
				and VisitStartTime >= @CutOffDate AND hv.VisitStartTime <=  @endDt
				--and (cp.DischargeDate IS NULL  
				--		or cp.DischargeDate > @LastDayofPreviousMonth)
						
if @ReportType = 'summary'
	begin

		declare @cohortCount int=0
		set @cohortCount= (select count(PC1ID) from @tbl4QAReportCohort)
		
		declare @missingAttachCount int=0
		set @missingAttachCount = (select count(PC1ID) from @tbl4QAReportCohort qarc
									 left outer join Attachment a on a.HVCaseFK = qarc.HVCaseFK and a.FormType = 'VL' and a.FormFK = HVLogPK
									 where a.AttachmentPK is null)
		

		DECLARE @tbl4QAReportMissingAttachHVSummary TABLE(
			[SummaryId] INT,
			[SummaryText] [varchar](200),
			[SummaryTotal] [varchar](100)
		)
		insert into @tbl4QAReportMissingAttachHVSummary
		        ( SummaryId ,
		          SummaryText ,
		          SummaryTotal
		        )
		values  ( 19 , -- SummaryId - int
		          'Number of HV Log forms since ' + CONVERT(VARCHAR(8), @CutOffDate, 1) + ' without an attachment (N=' + CONVERT(varchar,@cohortCount) + ')', -- SummaryText - varchar(200)
		          CONVERT(varchar,@missingAttachCount) + ' (' + 
		          convert(varchar,round(coalesce(cast(@missingAttachCount as float) * 100 / nullif(@cohortCount,0),0),0)) + '%)' -- SummaryTotal - varchar(100)
		        )
		
		select * from @tbl4QAReportMissingAttachHVSummary
		
	end

else
	begin
		select PC1ID ,
               VisitStartTime , 
               CurrentLevel ,
               CurrentWorker ,
               Link = '<a href="/Pages/HomeVisitLog.aspx?pc1id=' + PC1ID + '&hvlogpk=' + rtrim(convert(varchar(12), qarc.HVLogPK)) + '" target="_blank" alt="Home Visit Log">'
		from @tbl4QAReportCohort qarc
		left outer join Attachment a on a.HVCaseFK = qarc.HVCaseFK and a.FormType = 'VL' and a.FormFK = HVLogPK
		where a.AttachmentPK is null
		order by qarc.PC1ID, qarc.VisitStartTime
	end		

GO
PRINT N'Altering [dbo].[rspRetentionRatePercentage]'
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Main storedproc for Retention Rate - Percentage report
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- exec rspRetentionRates 9, '05/01/09', '04/30/11'
-- exec rspRetentionRates 19, '20080101', '20121231'
-- exec rspRetentionRates 37, '20090401', '20110331'
-- exec rspRetentionRates 17, '20090401', '20110331'
-- exec rspRetentionRates 20, '20080401', '20110331'
-- exec rspRetentionRates '15,16', '20091201', '20111130'
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', 85, null, '' 85 = Daisy Flores
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, 1, '' 1 = Children Youth & Families
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- Fixed Bug HW963 - Retention Rage Report ... Khalsa 3/20/2014
-- =============================================
-- =============================================
ALTER procedure [dbo].[rspRetentionRatePercentage]
	-- Add the parameters for the stored procedure here
	@ProgramFK varchar(max)
	, @StartDate datetime
	, @EndDate datetime
    , @WorkerFK int = null
	, @SiteFK int = null
	, @CaseFiltersPositive varchar(100) = ''
as
BEGIN 
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

--#region declarations
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @casefilterspositive = case	when @casefilterspositive = '' then null
									else @casefilterspositive
							   end

	declare @tblResults table (
		LineDescription varchar(50)
		, LineGroupingLevel int
		, DisplayPercentages bit
		, TotalEnrolledParticipants int
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, RetentionRateEighteenMonths decimal(5,3)
		, RetentionRateTwoYears decimal(5,3)
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsOneYear int
		, EnrolledParticipantsEighteenMonths int
		, EnrolledParticipantsTwoYears int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedOneYear int
		, RunningTotalDischargedEighteenMonths int
		, RunningTotalDischargedTwoYears int
		, TotalNSixMonths int
		, TotalNOneYear int
		, TotalNEighteenMonths int
		, TotalNTwoYears int
		, AllParticipants int
		, SixMonthsIntake int
		, SixMonthsDischarge int
		, OneYearIntake int 
		, OneYearDischarge int
		, EighteenMonthsIntake int
		, EighteenMonthsDischarge int
		, TwoYearsIntake int
		, TwoYearsDischarge int);

	declare @tblPC1withStats table (
		PC1ID char(13)
		, IntakeDate datetime
		, DischargeDate datetime
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int);

--#endregion
--#region cteCohort - Get the cohort for the report
	with cteCohort as
	-----------------------
		(select HVCasePK
			from HVCase h 
			inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
				and (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				and  w.WorkerPK = isnull(@WorkerFK, w.WorkerPK)
				-- and cp.ProgramFK=@ProgramFK
		)	

	--select * 
	--from cteCohort
	--order by HVCasePK

	--select HVCasePK, count(HVCasePK)

	--from cteCohort
	--group by HVCasePK
	--having count(HVCasePK) > 1

--#endregion
--#region cteLastFollowUp - Get last follow up completed for all cases in cohort
	, cteLastFollowUp as 
	-----------------------
		(select max(FollowUpPK) as FollowUpPK
			   , max(FollowUpDate) as FollowUpDate
			   , fu.HVCaseFK
			from FollowUp fu
			inner join cteCohort c on c.HVCasePK = fu.HVCaseFK
			group by fu.HVCaseFK
		)

	--select * 
	--from cteLastFollowUp 
	--order by HVCaseFK

--#endregion
--#region cteFollowUp* - get follow up common attribute rows and columns that we need for each person from the last follow up
--#region cteDischargeData - Get all discharge related data
    , cteDischargeData as 
	------------------------
		(select h.HVCasePK as HVCaseFK
			    ,cd.DischargeReason as DischargeReason
		from HVCase h
		inner join CaseProgram cp on cp.HVCaseFK=h.HVCasePK
		inner join Kempe k on k.HVCaseFK=h.HVCasePK
		inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
		inner join codeDischarge cd on cd.DischargeCode=cp.DischargeReason 
		inner join cteCohort c on h.HVCasePK = c.HVCasePK
		)

	--select * from cteDischargeData
	--order by HVCaseFK

--#endregion
--#region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
	, cteCaseLastHomeVisit AS 
	-----------------------------
		(select HVCaseFK
				  , max(vl.VisitStartTime) as LastHomeVisit
				  , count(vl.VisitStartTime) as CountOfHomeVisits
			from HVLog vl
			inner join HVCase c on c.HVCasePK = vl.HVCaseFK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = vl.ProgramFK
			inner join cteCohort co on co.HVCasePK = c.HVCasePK
			where VisitType <> '00010' and 
					(IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
							 -- and vl.ProgramFK = @ProgramFK
			group by HVCaseFK
		)
--#endregion
--#region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	, cteMain as
	------------------------
		(select PC1ID
			   ,IntakeDate
			   ,LastHomeVisit
			   ,DischargeDate
			   ,cp.DischargeReason AS DischargeReasonCode
               ,dd.DischargeReason
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 6 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 6 then 1
					else 0
				end	as ActiveAt6Months
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 12 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 12 then 1
					else 0
				end	as ActiveAt12Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 18 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 18 then 1
					else 0
				end as ActiveAt18Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 24 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 24 then 1
					else 0
				end as ActiveAt24Months
			FROM HVCase c
			inner join CaseProgram cp on cp.HVCaseFK=c.HVCasePK
			inner join PC on PC.PCPK=c.PC1FK
			inner join Kempe k on k.HVCaseFK=c.HVCasePK
			inner join PC1Issues pc1i ON pc1i.HVCaseFK=k.HVCaseFK AND pc1i.PC1IssuesPK=k.PC1IssuesFK
			--inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			inner join cteCaseLastHomeVisit lhv ON lhv.HVCaseFK=c.HVCasePK
			left outer join cteDischargeData dd ON dd.hvcasefk=c.HVCasePK
			where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				  -- and cp.ProgramFK=@ProgramFK
		)

--#endregion

--select *
--from cteDischargeData

--select *
--from cteMain

--where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
--order by DischargeReasonCode, PC1ID

--#region Add rows to @tblPC1withStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1withStats 
		(PC1ID
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		, RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months)
select distinct PC1ID
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
				   ,case when DischargeDate is not null then 
						datediff(mm,IntakeDate,LastHomeVisit)
					else
						datediff(mm,IntakeDate,current_timestamp)
					end as RetentionMonths


		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
from cteMain
-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37')
		-- (DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') or datediff(day,IntakeDate,DischargeDate)>=(4*6*30.44))
order by PC1ID,IntakeDate
--#endregion
--select * from @tblPC1withStats

declare @TotalCohortCount int

-- now we have all the rows from the cohort in @tblPC1withStats
-- get the total count
select @TotalCohortCount = COUNT(*) 
  from @tblPC1withStats

--#region declare vars to collect counts for final stats
declare @LineGroupingLevel int
		, @TotalEnrolledParticipants int
		, @RetentionRateSixMonths decimal(5,3)
		, @RetentionRateOneYear decimal(5,3)
		, @RetentionRateEighteenMonths decimal(5,3)
		, @RetentionRateTwoYears decimal(5,3)
		, @EnrolledParticipantsSixMonths int
		, @EnrolledParticipantsOneYear int
		, @EnrolledParticipantsEighteenMonths int
		, @EnrolledParticipantsTwoYears int
		, @RunningTotalDischargedSixMonths int
		, @RunningTotalDischargedOneYear int
		, @RunningTotalDischargedEighteenMonths int
		, @RunningTotalDischargedTwoYears int
		, @TotalNSixMonths int
		, @TotalNOneYear int
		, @TotalNEighteenMonths int
		, @TotalNTwoYears int

declare @AllEnrolledParticipants int
		, @SixMonthsTotal int
		, @TwelveMonthsTotal int
		, @EighteenMonthsTotal int
		, @TwentyFourMonthsTotal int
		, @SixMonthsAtIntake int
		, @SixMonthsAtDischarge int
		, @TwelveMonthsAtIntake int
		, @TwelveMonthsAtDischarge int
		, @EighteenMonthsAtIntake int
		, @EighteenMonthsAtDischarge int
		, @TwentyFourMonthsAtIntake int
		, @TwentyFourMonthsAtDischarge int
--#endregion
--#region Retention Rate %
select @SixMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt6Months = 1

select @TwelveMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt12Months = 1

select @EighteenMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt18Months = 1

select @TwentyFourMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt24Months = 1

set @RetentionRateSixMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@SixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateOneYear = case when @TotalCohortCount = 0 then 0.0000 else round((@TwelveMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateEighteenMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@EighteenMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateTwoYears = case when @TotalCohortCount = 0 then 0.0000 else round((@TwentyFourMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
--#endregion
--#region Enrolled Participants
select @EnrolledParticipantsSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 

select @EnrolledParticipantsOneYear = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 

select @EnrolledParticipantsEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 

select @EnrolledParticipantsTwoYears = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1
--#endregion
--#region Running Total Discharged
select @RunningTotalDischargedSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
--select @RunningTotalDischargedSixMonths = count(*)
--from @tblPC1withStats
--where ActiveAt6Months = 0 and LastHomeVisit between IntakeDate and dateadd(day, 6*30.44, IntakeDate)
--
--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1withStats
--where ActiveAt12Months = 0 and LastHomeVisit between dateadd(day, (6*30.44)+1, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)
--
--select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
--from @tblPC1withStats
--where ActiveAt18Months = 0 and LastHomeVisit between dateadd(day, (12*30.44)+1, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)
--
--select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
--from @tblPC1withStats
--where ActiveAt24Months = 0 and LastHomeVisit between dateadd(day, (18*30.44)+1, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)
--#endregion
--#region Total (N) - (Discharged)
select @TotalNSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @TotalNOneYear = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @TotalNEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @TotalNTwoYears = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
--#endregion

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Totals'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select LineDescription
	  ,1 as LineGroupingLevel
	  ,DisplayPercentages
	  ,TotalEnrolledParticipants
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then RetentionRateSixMonths else null end as RetentionRateSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then RetentionRateOneYear else null end as RetentionRateOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then RetentionRateEighteenMonths else null end as RetentionRateEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then RetentionRateTwoYears else null end as RetentionRateTwoYears
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then EnrolledParticipantsSixMonths else null end as EnrolledParticipantsSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then EnrolledParticipantsOneYear else null end as EnrolledParticipantsOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then EnrolledParticipantsEighteenMonths else null end as EnrolledParticipantsEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then EnrolledParticipantsTwoYears else null end as EnrolledParticipantsTwoYears
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then RunningTotalDischargedSixMonths else null end as RunningTotalDischargedSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then RunningTotalDischargedOneYear else null end as RunningTotalDischargedOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then RunningTotalDischargedEighteenMonths else null end as RunningTotalDischargedEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then RunningTotalDischargedTwoYears else null end as RunningTotalDischargedTwoYears
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then TotalNSixMonths else null end as TotalNSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then TotalNOneYear else null end as TotalNOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then TotalNEighteenMonths else null end as TotalNEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then TotalNTwoYears else null end as TotalNTwoYears
	  ,AllParticipants
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then SixMonthsIntake else null end as SixMonthsIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then SixMonthsDischarge else null end as SixMonthsDischarge
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then OneYearIntake else null end as OneYearIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then OneYearDischarge else null end as OneYearDischarge
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then EighteenMonthsIntake else null end as EighteenMonthsIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then EighteenMonthsDischarge else null end as EighteenMonthsDischarge
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then TwoYearsIntake else null end as TwoYearsIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then TwoYearsDischarge else null end as TwoYearsDischarge
from @tblResults
--SELECT * from @tblResults

--select VendorID, Employee, Orders
--from
--   (SELECT ActiveAt6Months, ActiveAt12Months, ActiveAt18Months, ActiveAt24Months
--   FROM @tblPC1withStats) p
--UNPIVOT
--   (Orders FOR Employee IN 
--      (Emp1, Emp2, Emp3, Emp4, Emp5)
--)AS unpvt;

end
GO
PRINT N'Creating [dbo].[__Temp_RetentionRate_Report]'
GO
CREATE TABLE [dbo].[__Temp_RetentionRate_Report]
(
[ProgramFK] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineDescription] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LineGroupingLevel] [int] NULL,
[DisplayPercentages] [bit] NULL,
[TotalEnrolledParticipants] [int] NULL,
[RetentionRateSixMonths] [decimal] (5, 3) NULL,
[RetentionRateOneYear] [decimal] (5, 3) NULL,
[RetentionRateEighteenMonths] [decimal] (5, 3) NULL,
[RetentionRateTwoYears] [decimal] (5, 3) NULL,
[EnrolledParticipantsSixMonths] [int] NULL,
[EnrolledParticipantsOneYear] [int] NULL,
[EnrolledParticipantsEighteenMonths] [int] NULL,
[EnrolledParticipantsTwoYears] [int] NULL,
[RunningTotalDischargedSixMonths] [int] NULL,
[RunningTotalDischargedOneYear] [int] NULL,
[RunningTotalDischargedEighteenMonths] [int] NULL,
[RunningTotalDischargedTwoYears] [int] NULL,
[TotalNSixMonths] [int] NULL,
[TotalNOneYear] [int] NULL,
[TotalNEighteenMonths] [int] NULL,
[TotalNTwoYears] [int] NULL,
[AllParticipants] [int] NULL,
[SixMonthsIntake] [int] NULL,
[SixMonthsDischarge] [int] NULL,
[OneYearIntake] [int] NULL,
[OneYearDischarge] [int] NULL,
[EighteenMonthsIntake] [int] NULL,
[EighteenMonthsDischarge] [int] NULL,
[TwoYearsIntake] [int] NULL,
[TwoYearsDischarge] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
PRINT N'Creating [dbo].[rspRetentionRates_fill_cache]'
GO
-- =============================================
-- Author:		jrobohn
-- Create date: 03/31/11
-- Description:	Main storedproc for Retention Rate report
-- Description: <copied from FamSys Feb 20, 2012 - see header below>
-- exec rspRetentionRates 9, '05/01/09', '04/30/11'
-- exec rspRetentionRates 19, '20080101', '20121231'
-- exec rspRetentionRates 37, '20090401', '20110331'
-- exec rspRetentionRates 17, '20090401', '20110331'
-- exec rspRetentionRates 20, '20080401', '20110331'
-- exec rspRetentionRates '15,16', '20091201', '20111130'
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', 85, null, '' 85 = Daisy Flores
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, 1, '' 1 = Children Youth & Families
-- exec rspRetentionRates 1, '03/01/10', '02/29/12', null, null, ''
-- Fixed Bug HW963 - Retention Rage Report ... Khalsa 3/20/2014
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[rspRetentionRates_fill_cache]
	-- Add the parameters for the stored procedure here
	@ProgramFK varchar(max)
	, @StartDate datetime
	, @EndDate datetime
    , @WorkerFK int = null
	, @SiteFK int = null
	, @CaseFiltersPositive varchar(100) = ''
as
BEGIN 
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

--TRUNCATE TABLE dbo.__Temp_RetentionRate_Report

--#region declarations
	set @SiteFK = case when dbo.IsNullOrEmpty(@SiteFK) = 1 then 0
					   else @SiteFK
				  end
	set @casefilterspositive = case	when @casefilterspositive = '' then null
									else @casefilterspositive
							   end

	declare @tblResults table (
		LineDescription varchar(50)
		, LineGroupingLevel int
		, DisplayPercentages bit
		, TotalEnrolledParticipants int
		, RetentionRateSixMonths decimal(5,3)
		, RetentionRateOneYear decimal(5,3)
		, RetentionRateEighteenMonths decimal(5,3)
		, RetentionRateTwoYears decimal(5,3)
		, EnrolledParticipantsSixMonths int
		, EnrolledParticipantsOneYear int
		, EnrolledParticipantsEighteenMonths int
		, EnrolledParticipantsTwoYears int
		, RunningTotalDischargedSixMonths int
		, RunningTotalDischargedOneYear int
		, RunningTotalDischargedEighteenMonths int
		, RunningTotalDischargedTwoYears int
		, TotalNSixMonths int
		, TotalNOneYear int
		, TotalNEighteenMonths int
		, TotalNTwoYears int
		, AllParticipants int
		, SixMonthsIntake int
		, SixMonthsDischarge int
		, OneYearIntake int 
		, OneYearDischarge int
		, EighteenMonthsIntake int
		, EighteenMonthsDischarge int
		, TwoYearsIntake int
		, TwoYearsDischarge int);

	declare @tblPC1withStats table (
		PC1ID char(13)
		, IntakeDate datetime
		, DischargeDate datetime
		, LastHomeVisit datetime
		, RetentionMonths int
		, ActiveAt6Months int
		, ActiveAt12Months int
		, ActiveAt18Months int
		, ActiveAt24Months int
		, AgeAtIntake_Under18 int
		, AgeAtIntake_18UpTo20 int
		, AgeAtIntake_20UpTo30 int
		, AgeAtIntake_Over30 int
		, RaceWhite int
		, RaceBlack int
		, RaceHispanic int
		, RaceOther int
		, RaceUnknownMissing int
		, MarriedAtIntake int
		, MarriedAtDischarge int
		, NeverMarriedAtIntake int
		, NeverMarriedAtDischarge int
		, SeparatedAtIntake int
		, SeparatedAtDischarge int
		, DivorcedAtIntake int
		, DivorcedAtDischarge int
		, WidowedAtIntake int
		, WidowedAtDischarge int
		, MarriedUnknownMissingAtIntake int
		, MarriedUnknownMissingAtDischarge int
		, OtherChildrenInHouseholdAtIntake int
		, OtherChildrenInHouseholdAtDischarge int
		, NoOtherChildrenInHouseholdAtIntake int
		, NoOtherChildrenInHouseholdAtDischarge int
		, ReceivingTANFAtIntake int
		, ReceivingTANFAtDischarge int
		, NotReceivingTANFAtIntake int
		, NotReceivingTANFAtDischarge int
		, MomScore int
		, DadScore int
		, PartnerScore int
		, PC1EducationAtIntakeLessThan12 int
		, PC1EducationAtDischargeLessThan12 int
		, PC1EducationAtIntakeHSGED int
		, PC1EducationAtDischargeHSGED int
		, PC1EducationAtIntakeMoreThan12 int
		, PC1EducationAtDischargeMoreThan12 int
		, PC1EducationAtIntakeUnknownMissing int
		, PC1EducationAtDischargeUnknownMissing int
		, PC1EducationalEnrollmentAtIntakeYes int
		, PC1EducationalEnrollmentAtDischargeYes int
		, PC1EducationalEnrollmentAtIntakeNo int
		, PC1EducationalEnrollmentAtDischargeNo int
		, PC1EducationalEnrollmentAtIntakeUnknownMissing int
		, PC1EducationalEnrollmentAtDischargeUnknownMissing int
		, PC1EmploymentAtIntakeYes int
		, PC1EmploymentAtDischargeYes int
		, PC1EmploymentAtIntakeNo int
		, PC1EmploymentAtDischargeNo int
		, PC1EmploymentAtIntakeUnknownMissing int
		, PC1EmploymentAtDischargeUnknownMissing int
		, OBPInHouseholdAtIntake int
		, OBPInHouseholdAtDischarge int
		, OBPEmploymentAtIntakeYes int
		, OBPEmploymentAtDischargeYes int
		, OBPEmploymentAtIntakeNo int
		, OBPEmploymentAtDischargeNo int
		, OBPEmploymentAtIntakeNoOBP int
		, OBPEmploymentAtDischargeNoOBP int
		, OBPEmploymentAtIntakeUnknownMissing int
		, OBPEmploymentAtDischargeUnknownMissing int
		, PC2InHouseholdAtIntake int
		, PC2InHouseholdAtDischarge int
		, PC2EmploymentAtIntakeYes int
		, PC2EmploymentAtDischargeYes int
		, PC2EmploymentAtIntakeNo int
		, PC2EmploymentAtDischargeNo int
		, PC2EmploymentAtIntakeNoPC2 int
		, PC2EmploymentAtDischargeNoPC2 int
		, PC2EmploymentAtIntakeUnknownMissing int
		, PC2EmploymentAtDischargeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtIntakeYes int
		, PC1OrPC2OrOBPEmployedAtDischargeYes int
		, PC1OrPC2OrOBPEmployedAtIntakeNo int
		, PC1OrPC2OrOBPEmployedAtDischargeNo int
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing int
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing int
		, CountOfHomeVisits int
		, DischargedOnLevelX int
		, PC1DVAtIntake int
		, PC1DVAtDischarge int
		, PC1MHAtIntake int
		, PC1MHAtDischarge int
		, PC1SAAtIntake int
		, PC1SAAtDischarge int
		, PC1PrimaryLanguageAtIntakeEnglish int
		, PC1PrimaryLanguageAtIntakeSpanish int
		, PC1PrimaryLanguageAtIntakeOtherUnknown int
		, TrimesterAtIntakePostnatal int
		, TrimesterAtIntake3rd int
		, TrimesterAtIntake2nd int
		, TrimesterAtIntake1st int
		, CountOfFSWs int);

--#endregion
--#region cteCohort - Get the cohort for the report
	with cteCohort as
	-----------------------
		(select HVCasePK
			from HVCase h 
			inner join CaseProgram cp on cp.HVCaseFK = h.HVCasePK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			inner join dbo.udfCaseFilters(@casefilterspositive, '', @programfk) cf on cf.HVCaseFK = h.HVCasePK
			left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
			left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK and wp.ProgramFK = cp.ProgramFK
			where case when @SiteFK = 0 then 1
							 when wp.SiteFK = @SiteFK then 1
							 else 0
						end = 1
				and (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				and  w.WorkerPK = isnull(@WorkerFK, w.WorkerPK)
				-- and cp.ProgramFK=@ProgramFK
		)	

	--select * 

	--from cteCohort
	--order by HVCasePK

	--select HVCasePK, count(HVCasePK)

	--from cteCohort
	--group by HVCasePK
	--having count(HVCasePK) > 1







--#endregion
--#region cteLastFollowUp - Get last follow up completed for all cases in cohort
	, cteLastFollowUp as 
	-----------------------
		(select max(FollowUpPK) as FollowUpPK
			   , max(FollowUpDate) as FollowUpDate
			   , fu.HVCaseFK
			from FollowUp fu
			inner join cteCohort c on c.HVCasePK = fu.HVCaseFK
			group by fu.HVCaseFK
		)

	--select * 
	--from cteLastFollowUp 
	--order by HVCaseFK

--#endregion
--#region cteFollowUp* - get follow up common attribute rows and columns that we need for each person from the last follow up
	, cteFollowUpPC1 as
	-------------------
		(select MaritalStatus
				, PBTANF as PC1TANFAtDischarge
				, cappmarital.AppCodeText as MaritalStatusAtDischarge
				, cappgrade.AppCodeText as PC1EducationAtDischarge
				, IsCurrentlyEmployed AS PC1EmploymentAtDischarge
				, EducationalEnrollment AS EducationalEnrollmentAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   left outer join codeApp cappmarital ON cappmarital.AppCode=MaritalStatus and cappmarital.AppCodeGroup='MaritalStatus'
		   left outer join codeApp cappgrade ON cappgrade.AppCode=HighestGrade and cappgrade.AppCodeGroup='Education'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-PC1'
		)
	, cteFollowUpOBP as
	-------------------
		(select IsCurrentlyEmployed as OBPEmploymentAtDischarge
				, OBPInHome as OBPInHomeAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   --left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-OBP'
		)
	, cteFollowUpPC2 as
	-------------------
		(select IsCurrentlyEmployed AS PC2EmploymentAtDischarge
				, ca.HVCaseFK 
		   from CommonAttributes ca
		   --left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
		   inner join cteLastFollowUp fu on FollowUpPK = FormFK
		  where FormType='FU-PC2'
		)
--#endregion
--#region cteDischargeData - Get all discharge related data
    , cteDischargeData as 
	------------------------
		(select h.HVCasePK as HVCaseFK
			    ,cd.DischargeReason as DischargeReason
				,PC1TANFAtDischarge
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,EducationalEnrollmentAtDischarge
			   	,case

					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK and 
																						((oc.FormType = 'IN' and oc.LivingArrangement = '01')
																							or oc.FormType = 'FU'))
 						then 1
					else 0
				end as OtherChildrenInHouseholdAtDischarge
				,case 
					when pc1is.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtDischarge
				,case
					when pc1is.SubstanceAbuse = '1' 
						then 1
					else 0
				end as SubstanceAbuseAtDischarge
				,case 
					when pc1is.DomesticViolence = '1' 
						then 1
					else 0
				end as DomesticViolenceAtDischarge
				,case 
					when pc1is.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtDischarge
				,case 
					when pc1is.Depression = '1'
						then 1
					else 0
				end as DepressionAtDischarge
				,OBPInHomeAtDischarge
				,PC2inHome as PC2InHomeAtDischarge
				,PC2EmploymentAtDischarge
				,OBPEmploymentAtDischarge
		from HVCase h
		inner join CaseProgram cp on cp.HVCaseFK=h.HVCasePK
		inner join Kempe k on k.HVCaseFK=h.HVCasePK
		inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
		inner join codeDischarge cd on cd.DischargeCode=cp.DischargeReason 
		inner join cteCohort c on h.HVCasePK = c.HVCasePK
		left outer join cteLastFollowUp lfu on lfu.HVCaseFK = c.HVCasePK
		left outer join FollowUp fu ON fu.FollowUpPK = lfu.FollowUpPK
		left outer join PC1Issues pc1is ON pc1is.PC1IssuesPK=fu.PC1IssuesFK
		left outer join cteFollowUpPC1 pc1fuca ON pc1fuca.HVCaseFK=c.HVCasePK
		left outer join cteFollowUpOBP obpfuca ON obpfuca.HVCaseFK=c.HVCasePK
		left outer join cteFollowUpPC2 pc2fuca ON pc2fuca.HVCaseFK=c.HVCasePK
			  -- and Fu.FollowUpInterval IN (98,99))
		)

	--select * from cteDischargeData
	--order by HVCaseFK

--#endregion
--#region cteCaseLastHomeVisit - get the last home visit for each case in the cohort 
	, cteCaseLastHomeVisit AS 
	-----------------------------
		(select HVCaseFK
				  , max(vl.VisitStartTime) as LastHomeVisit
				  , count(vl.VisitStartTime) as CountOfHomeVisits
			from HVLog vl
			inner join HVCase c on c.HVCasePK = vl.HVCaseFK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = vl.ProgramFK
			inner join cteCohort co on co.HVCasePK = c.HVCasePK
			where VisitType <> '00010' and 
					(IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
							 -- and vl.ProgramFK = @ProgramFK
			group by HVCaseFK
		)
--#endregion
--#region cteCaseFSWCount - get the count of FSWs for each case in the cohort, i.e. how many times it's changed
	, cteCaseFSWCount AS 
	------------------------
		 (select HVCaseFK, count(wa.WorkerAssignmentPK) as CountOfFSWs
		   from dbo.WorkerAssignment wa
			inner join hvcase c on c.HVCasePK=wa.HVCaseFK 
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = wa.ProgramFK
			inner join cteCohort co on co.HVCasePK = c.HVCasePK
			where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				-- and wa.ProgramFK=@ProgramFK
			group by HVCaseFK)
--#endregion
--#region ctePC1AgeAtIntake - get the PC1's age at intake
	, ctePC1AgeAtIntake as
	------------------------
		(select c.HVCasePK as HVCaseFK
				,datediff(year,PCDOB,IntakeDate) as PC1AgeAtIntake
			from PC 
			inner join PCProgram pcp on pcp.PCFK=PCPK
			inner join HVCase c on c.PC1FK=PCPK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = pcp.ProgramFK
			inner join cteCohort co on co.HVCasePK = c.HVCasePK
			WHERE (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				--and pcp.ProgramFK=@ProgramFK
			)
--#endregion
--#region ctePC1AgeAtIntake - get the PC1's age at intake
	, cteTCInformation as
	------------------------
		(select t.HVCaseFK
				, max(t.TCDOB) as TCDOB
				, max(GestationalAge) as GestationalAge
			from TCID t
			inner join HVCase c on c.HVCasePK = t.HVCaseFK
			inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			inner join cteCohort co on co.HVCasePK = c.HVCasePK
			where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
					-- and cp.ProgramFK=@ProgramFK
			group by t.HVCaseFK)
--#endregion
--#region cteMain - main select for the report sproc, gets data at intake and joins to data at discharge
	, cteMain as
	------------------------
		(select PC1ID
			   ,IntakeDate
			   ,LastHomeVisit
			   ,CountOfFSWs
			   ,CountOfHomeVisits
			   ,DischargeDate
			   ,LevelName
			   ,cp.DischargeReason AS DischargeReasonCode
               ,dd.DischargeReason
			   ,PC1AgeAtIntake
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 6 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 6 then 1
					else 0
				end	as ActiveAt6Months
			   ,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 12 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 12 then 1
					else 0
				end	as ActiveAt12Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 18 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 18 then 1
					else 0
				end as ActiveAt18Months
				,case
				when DischargeDate is null and datediff(month, IntakeDate, current_timestamp) > 24 then 1
				when DischargeDate is not null and datediff(month, IntakeDate, LastHomeVisit) > 24 then 1
					else 0
				end as ActiveAt24Months
			   ,Race
			   ,carace.AppCodeText as RaceText
			   ,MaritalStatus
			   ,MaritalStatusAtIntake
			   ,case when MomScore = 'U' then 0 else cast(MomScore as int) end as MomScore
			   ,case when DadScore = 'U' then 0 else cast(DadScore as int) end as DadScore
			   ,case when PartnerScore = 'U' then 0 else cast(PartnerScore as int) end as PartnerScore
			   ,HighestGrade
			   ,PC1EducationAtIntake
			   ,PC1EmploymentAtIntake
			   ,EducationalEnrollment AS EducationalEnrollmentAtIntake
			   ,PrimaryLanguage as PC1PrimaryLanguageAtIntake
			   ,case 
			   		when c.TCDOB is NULL then EDC
					else c.TCDOB
				end as TCDOB
			   ,case 
					when c.TCDOB is null and EDC is not null then 1
					when c.TCDOB is not null and c.TCDOB > IntakeDate then 1
					when c.TCDOB is not null and c.TCDOB <= IntakeDate then 0
				end
				as PrenatalEnrollment
				,case
					when cp.HVCaseFK IN (SELECT oc.HVCaseFK FROM OtherChild oc WHERE oc.HVCaseFK=cp.HVCaseFK AND 
																						oc.FormType='IN' and oc.LivingArrangement = '01') 
 						then 1
					else 0
				end as OtherChildrenInHouseholdAtIntake
				,case 
					when pc1i.AlcoholAbuse = '1'
						then 1
					else 0
				end as AlcoholAbuseAtIntake
				,case 
					when pc1i.SubstanceAbuse = '1'
						then 1
					else 0
				end as SubstanceAbuseAtIntake
				,case 
					when pc1i.DomesticViolence = '1'
						then 1
					else 0
				end as DomesticViolenceAtIntake
				,case 
					when pc1i.MentalIllness = '1'
						then 1
					else 0
				end as MentalIllnessAtIntake
				,case 
					when pc1i.Depression = '1'
						then 1
					else 0
				end as DepressionAtIntake
				,OBPInHomeIntake as OBPInHomeAtIntake
				,PC2InHomeIntake as PC2InHomeAtIntake
				,MaritalStatusAtDischarge
				,PC1EducationAtDischarge
				,PC1EmploymentAtDischarge
				,EducationalEnrollmentAtDischarge
		   		,OtherChildrenInHouseholdAtDischarge
				,AlcoholAbuseAtDischarge
				,SubstanceAbuseAtDischarge
				,DomesticViolenceAtDischarge
				,MentalIllnessAtDischarge
				,DepressionAtDischarge
				,OBPInHomeAtDischarge
				,OBPEmploymentAtDischarge
				,OBPEmploymentAtIntake
				,PC2InHomeAtDischarge
				,PC2EmploymentAtIntake
				,PC2EmploymentAtDischarge
				,PC1TANFAtDischarge
				,PC1TANFAtIntake
				, case when c.TCDOB is null then dateadd(week, -40, c.EDC) 
						when tci.HVCaseFK is null and c.TCDOB is not null
							then dateadd(week, -40, c.TCDOB)
						when tci.HVCaseFK is not NULL and c.TCDOB is not null 
							then dateadd(week, -40, dateadd(week, (40 - isnull(GestationalAge, 40)), c.TCDOB) )
					end as ConceptionDate
			FROM HVCase c
			left outer join cteDischargeData dd ON dd.hvcasefk=c.HVCasePK
			inner join cteCaseLastHomeVisit lhv ON lhv.HVCaseFK=c.HVCasePK
			inner join cteCaseFSWCount fc ON fc.HVCaseFK=c.HVCasePK
			inner join ctePC1AgeAtIntake aai on aai.HVCaseFK=c.HVCasePK
			inner join CaseProgram cp on cp.HVCaseFK=c.HVCasePK
			inner join PC on PC.PCPK=c.PC1FK
			inner join Kempe k on k.HVCaseFK=c.HVCasePK
			inner join PC1Issues pc1i ON pc1i.HVCaseFK=k.HVCaseFK AND pc1i.PC1IssuesPK=k.PC1IssuesFK
			inner join codeLevel cl ON cl.codeLevelPK=CurrentLevelFK
			inner join dbo.SplitString(@ProgramFK, ',') ss on ss.ListItem = cp.ProgramFK
			left outer join cteTCInformation tci on tci.HVCaseFK = c.HVCasePK
			left outer join codeApp carace on carace.AppCode=Race and AppCodeGroup='Race'
			left outer join (select PBTANF as PC1TANFAtIntake
									,HVCaseFK 
							   from CommonAttributes ca
							  where FormType='IN') inca ON inca.HVCaseFK=c.HVCasePK
			left outer join (select MaritalStatus
									,AppCodeText as MaritalStatusAtIntake
									,IsCurrentlyEmployed AS PC1EmploymentAtIntake
									,EducationalEnrollment
									,PrimaryLanguage
									,HVCaseFK 
							   from CommonAttributes ca
							   left outer join codeApp capp ON capp.AppCode=MaritalStatus and AppCodeGroup='MaritalStatus'
							  where FormType='IN-PC1') pc1ca ON pc1ca.HVCaseFK=c.HVCasePK
			left outer join (SELECT IsCurrentlyEmployed AS OBPEmploymentAtIntake
									,HVCaseFK 
							   FROM CommonAttributes ca
							  WHERE FormType='IN-OBP') obpca ON obpca.HVCaseFK=c.HVCasePK
			left outer join (SELECT HVCaseFK
									, IsCurrentlyEmployed AS PC2EmploymentAtIntake
							   FROM CommonAttributes ca
							  WHERE FormType='IN-PC2') pc2ca ON pc2ca.HVCaseFK=c.HVCasePK
			left outer join (SELECT AppCodeText as PC1EducationAtIntake,HighestGrade,HVCaseFK 
							   FROM CommonAttributes ca
							   LEFT OUTER JOIN codeApp capp ON capp.AppCode=HighestGrade and AppCodeGroup='Education'
							  WHERE FormType='IN-PC1') pc1eduai ON pc1eduai.HVCaseFK=c.HVCasePK
			where (IntakeDate is not null and IntakeDate between @StartDate and @EndDate)
				  -- and cp.ProgramFK=@ProgramFK
		)

--#endregion

--select *
--from cteDischargeData

--select *
--from cteMain

--where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') 
--order by DischargeReasonCode, PC1ID

--#region Add rows to @tblPC1withStats for each case/pc1id in the cohort, which will create the basis for the final stats
insert into @tblPC1withStats 
		(PC1ID
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
		, RetentionMonths
		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, AgeAtIntake_Under18
		, AgeAtIntake_18UpTo20
		, AgeAtIntake_20UpTo30
		, AgeAtIntake_Over30
		, RaceWhite
		, RaceBlack
		, RaceHispanic
		, RaceOther
		, RaceUnknownMissing
		, MarriedAtIntake
		, MarriedAtDischarge
		, NeverMarriedAtIntake
		, NeverMarriedAtDischarge
		, SeparatedAtIntake
		, SeparatedAtDischarge
		, DivorcedAtIntake
		, DivorcedAtDischarge
		, WidowedAtIntake
		, WidowedAtDischarge
		, MarriedUnknownMissingAtIntake
		, MarriedUnknownMissingAtDischarge
		, OtherChildrenInHouseholdAtIntake
		, OtherChildrenInHouseholdAtDischarge
		, NoOtherChildrenInHouseholdAtIntake
		, NoOtherChildrenInHouseholdAtDischarge
		, ReceivingTANFAtIntake
		, ReceivingTANFAtDischarge
		, NotReceivingTANFAtIntake
		, NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, PC1EducationAtIntakeLessThan12
		, PC1EducationAtDischargeLessThan12
		, PC1EducationAtIntakeHSGED
		, PC1EducationAtDischargeHSGED
		, PC1EducationAtIntakeMoreThan12
		, PC1EducationAtDischargeMoreThan12
		, PC1EducationAtIntakeUnknownMissing
		, PC1EducationAtDischargeUnknownMissing
		, PC1EducationalEnrollmentAtIntakeYes
		, PC1EducationalEnrollmentAtDischargeYes
		, PC1EducationalEnrollmentAtIntakeNo
		, PC1EducationalEnrollmentAtDischargeNo
		, PC1EducationalEnrollmentAtIntakeUnknownMissing
		, PC1EducationalEnrollmentAtDischargeUnknownMissing
		, PC1EmploymentAtIntakeYes
		, PC1EmploymentAtDischargeYes
		, PC1EmploymentAtIntakeNo
		, PC1EmploymentAtDischargeNo
		, PC1EmploymentAtIntakeUnknownMissing
		, PC1EmploymentAtDischargeUnknownMissing
		, OBPInHouseholdAtIntake
		, OBPInHouseholdAtDischarge
		, OBPEmploymentAtIntakeYes
		, OBPEmploymentAtDischargeYes
		, OBPEmploymentAtIntakeNo
		, OBPEmploymentAtDischargeNo
		, OBPEmploymentAtIntakeNoOBP
		, OBPEmploymentAtDischargeNoOBP
		, OBPEmploymentAtIntakeUnknownMissing
		, OBPEmploymentAtDischargeUnknownMissing
		, PC2InHouseholdAtIntake
		, PC2InHouseholdAtDischarge
		, PC2EmploymentAtIntakeYes
		, PC2EmploymentAtDischargeYes
		, PC2EmploymentAtIntakeNo
		, PC2EmploymentAtDischargeNo
		, PC2EmploymentAtIntakeNoPC2
		, PC2EmploymentAtDischargeNoPC2
		, PC2EmploymentAtIntakeUnknownMissing
		, PC2EmploymentAtDischargeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtIntakeYes
		, PC1OrPC2OrOBPEmployedAtDischargeYes
		, PC1OrPC2OrOBPEmployedAtIntakeNo
		, PC1OrPC2OrOBPEmployedAtDischargeNo
		, PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, DischargedOnLevelX
		, PC1DVAtIntake
		, PC1DVAtDischarge
		, PC1MHAtIntake
		, PC1MHAtDischarge
		, PC1SAAtIntake
		, PC1SAAtDischarge
		, PC1PrimaryLanguageAtIntakeEnglish
		, PC1PrimaryLanguageAtIntakeSpanish
		, PC1PrimaryLanguageAtIntakeOtherUnknown
		, TrimesterAtIntakePostnatal
		, TrimesterAtIntake3rd
		, TrimesterAtIntake2nd
		, TrimesterAtIntake1st
		, CountOfFSWs)
select distinct PC1ID
		, IntakeDate
		, DischargeDate
		, LastHomeVisit
				   ,case when DischargeDate is not null then 
						datediff(mm,IntakeDate,LastHomeVisit)
					else
						datediff(mm,IntakeDate,current_timestamp)
					end as RetentionMonths


		, ActiveAt6Months
		, ActiveAt12Months
		, ActiveAt18Months
		, ActiveAt24Months
		, case when PC1AgeAtIntake < 18 then 1 else 0 end as AgeAtIntake_Under18
		, case when PC1AgeAtIntake between 18 and 19 then 1 else 0 end as AgeAtIntake_18UpTo20
		, case when PC1AgeAtIntake between 20 and 29 then 1 else 0 end as AgeAtIntake_20UpTo30
		, case when PC1AgeAtIntake >= 30 then 1 else 0 end as AgeAtIntake_Over30
		, case when left(RaceText,5)='White' then 1 else 0 end as RaceWhite
		, case when left(RaceText,5)='Black' then 1 else 0 end as RaceBlack
		, case when left(RaceText,8)='Hispanic' then 1 else 0 end as RaceHispanic
		, case when left(RaceText,5) in('Asian','Nativ','Multi','Other') then 1 else 0 end as RaceOther
		, case when RaceText is null or RaceText='' then 1 else 0 end as RaceUnknownMissing
		, case when MaritalStatusAtIntake = 'Married' then 1 else 0 end as MarriedAtIntake
		, case when MaritalStatusAtDischarge = 'Married' then 1 else 0 end as MarriedAtDischarge
		, case when MaritalStatusAtIntake = 'Never married' then 1 else 0 end as NeverMarriedAtIntake
		, case when MaritalStatusAtDischarge = 'Never married' then 1 else 0 end as NeverMarriedAtDischarge
		, case when MaritalStatusAtIntake = 'Separated' then 1 else 0 end as SeparatedAtIntake
		, case when MaritalStatusAtDischarge = 'Separated' then 1 else 0 end as SeparatedAtDischarge
		, case when MaritalStatusAtIntake = 'Divorced' then 1 else 0 end as DivorcedAtIntake
		, case when MaritalStatusAtDischarge= 'Divorced' then 1 else 0 end as DivorcedAtDischarge
		, case when MaritalStatusAtIntake = 'Widowed' then 1 else 0 end as WidowedAtIntake
		, case when MaritalStatusAtDischarge = 'Widowed' then 1 else 0 end as WidowedAtDischarge
		, case when MaritalStatusAtIntake is null or MaritalStatusAtIntake='' or left(MaritalStatusAtIntake,7) = 'Unknown' then 1 else 0 end as MarriedUnknownMissingAtIntake
		, case when MaritalStatusAtDischarge is null or MaritalStatusAtDischarge='' or left(MaritalStatusAtDischarge,7) = 'Unknown' then 1 else 0 end as MarriedUnknownMissingAtDischarge
		, case when OtherChildrenInHouseholdAtIntake > 0 then 1 else 0 end as OtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge > 0 then 1 else 0 end as OtherChildrenInHouseholdAtDischarge
		, case when OtherChildrenInHouseholdAtIntake = 0 or OtherChildrenInHouseholdAtIntake is null then 1 else 0 end as NoOtherChildrenInHouseholdAtIntake
		, case when OtherChildrenInHouseholdAtDischarge = 0 or OtherChildrenInHouseholdAtDischarge is null then 1 else 0 end as NoOtherChildrenInHouseholdAtDischarge
		, case when PC1TANFAtIntake = 1 then 1 else 0 end as ReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 1 then 1 else 0 end as ReceivingTANFAtDischarge
		, case when PC1TANFAtIntake = 0 or PC1TANFAtIntake is null or PC1TANFAtIntake = '' then 1 else 0 end as NotReceivingTANFAtIntake
		, case when PC1TANFAtDischarge = 0 or PC1TANFAtDischarge is null or PC1TANFAtDischarge='' then 1 else 0 end as NotReceivingTANFAtDischarge
		, MomScore
		, DadScore
		, PartnerScore
		, case when PC1EducationAtIntake in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtIntakeLessThan12
		, case when PC1EducationAtDischarge in ('Less than 8','8-11') then 1 else 0 end as PC1EducationAtDischargeLessThan12
		, case when PC1EducationAtIntake in ('High school grad','GED') then 1 else 0 end as PC1EducationAtIntakeHSGED
		, case when PC1EducationAtDischarge in ('High school grad','GED') then 1 else 0 end as PC1EducationAtDischargeHSGED
		, case when PC1EducationAtIntake in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtIntakeMoreThan12
		, case when PC1EducationAtDischarge in ('Vocational school after HS','Some college','Associates Degree','Bachelors degree or higher') then 1 else 0 end as PC1EducationAtDischargeMoreThan12
		, case when PC1EducationAtIntake is null or PC1EducationAtIntake = '' then 1 else 0 end as PC1EducationAtIntakeUnknownMissing
		, case when PC1EducationAtDischarge is null or PC1EducationAtDischarge = '' then 1 else 0 end as PC1EducationAtDischargeUnknownMissing
		, case when EducationalEnrollmentAtIntake = '1' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeYes
		, case when EducationalEnrollmentAtDischarge = '1' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeYes
		, case when EducationalEnrollmentAtIntake = '0' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeNo
		, case when EducationalEnrollmentAtDischarge = '0' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeNo
		, case when EducationalEnrollmentAtIntake is null or EducationalEnrollmentAtIntake = '' then 1 else 0 end as PC1EducationalEnrollmentAtIntakeUnknownMissing
		, case when EducationalEnrollmentAtDischarge is null or EducationalEnrollmentAtDischarge = '' then 1 else 0 end as PC1EducationalEnrollmentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = '1' then 1 else 0 end as PC1EmploymentAtIntakeYes
		, case when PC1EmploymentAtDischarge = '1' then 1 else 0 end as PC1EmploymentAtDischargeYes
		, case when PC1EmploymentAtIntake = '0' then 1 else 0 end as PC1EmploymentAtIntakeNo
		, case when PC1EmploymentAtDischarge = '0' then 1 else 0 end as PC1EmploymentAtDischargeNo
		, case when PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '' then 1 else 0 end as PC1EmploymentAtIntakeUnknownMissing
		, case when PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '' then 1 else 0 end as PC1EmploymentAtDischargeUnknownMissing
		, case when OBPInHomeAtIntake = 1 then 1 else 0 end as OBPInHouseholdAtIntake
		, case when OBPInHomeAtDischarge = 1 then 1 else 0 end as OBPInHouseholdAtDischarge
		, case when OBPEmploymentAtIntake = 1 then 1 else 0 end as OBPEmploymentAtIntakeYes
		, case when OBPEmploymentAtDischarge = 1 then 1 else 0 end as OBPEmploymentAtDischargeYes
		, case when OBPEmploymentAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNo
		, case when OBPEmploymentAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNo
		, case when OBPInHomeAtIntake = 0 then 1 else 0 end as OBPEmploymentAtIntakeNoOBP
		, case when OBPinHomeAtDischarge = 0 then 1 else 0 end as OBPEmploymentAtDischargeNoOBP
		, case when OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is null or OBPEmploymentAtIntake = '') then 1 else 0 end as OBPEmploymentAtIntakeUnknownMissing
		, case when OBPInHomeAtDischarge = 1 and (OBPEmploymentAtDischarge is null or OBPEmploymentAtDischarge = '') then 1 else 0 end as OBPEmploymentAtDischargeUnknownMissing
		, case when PC2InHomeAtIntake = 1 then 1 else 0 end as PC2InHouseholdAtIntake
		, case when PC2InHomeAtDischarge = 1 then 1 else 0 end as PC2InHouseholdAtDischarge
		, case when PC2EmploymentAtIntake = 1 then 1 else 0 end as PC2EmploymentAtIntakeYes
		, case when PC2EmploymentAtDischarge = 1 then 1 else 0 end as PC2EmploymentAtDischargeYes
		, case when PC2EmploymentAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNo
		, case when PC2EmploymentAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNo
		, case when PC2InHomeAtIntake = 0 then 1 else 0 end as PC2EmploymentAtIntakeNoPC2
		, case when PC2inHomeAtDischarge = 0 then 1 else 0 end as PC2EmploymentAtDischargeNoPC2
		, case when PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '') then 1 else 0 end as PC2EmploymentAtIntakeUnknownMissing
		, case when PC2InHomeAtDischarge = 1 and (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = '') then 1 else 0 end as PC2EmploymentAtDischargeUnknownMissing
		, case when PC1EmploymentAtIntake = '1' or PC2EmploymentAtIntake = '1' or OBPEmploymentAtIntake = '1' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeYes
		, case when PC1EmploymentAtDischarge = '1' or PC2EmploymentAtDischarge = '1' or OBPEmploymentAtDischarge = '1' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeYes
		, case when PC1EmploymentAtIntake = '0' and PC2EmploymentAtIntake = '0' and OBPEmploymentAtIntake = '0' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeNo
		, case when PC1EmploymentAtDischarge = '0' and PC2EmploymentAtDischarge = '0' and OBPEmploymentAtDischarge = '0' then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeNo
		, case when (PC1EmploymentAtIntake is null or PC1EmploymentAtIntake = '') 
					and (PC2InHomeAtIntake = 1 and (PC2EmploymentAtIntake is null or PC2EmploymentAtIntake = '')) 
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtIntake is NULL or OBPEmploymentAtIntake = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing
		, case when (PC1EmploymentAtDischarge is null or PC1EmploymentAtDischarge = '') 
					and (PC2InHomeAtIntake = 1 and  (PC2EmploymentAtDischarge is null or PC2EmploymentAtDischarge = ''))
					and (OBPInHomeAtIntake = 1 and (OBPEmploymentAtDischarge is NULL or OBPEmploymentAtDischarge = '')) then 1 else 0 end as PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing
		, CountOfHomeVisits
		, case when left(LevelName,7)='Level X' then 1 else 0 end as DischargedOnLevelX
		, case when DomesticViolenceAtIntake = 1 then 1 else 0 end as PC1DVAtIntake
		, case when DomesticViolenceAtDischarge = 1 then 1 else 0 end as PC1DVAtDischarge
		, case when MentalIllnessAtIntake = 1 or DepressionAtIntake = 1 then 1 else 0 end as PC1MHAtIntake
		, case when MentalIllnessAtDischarge = 1 or DepressionAtDischarge = 1 then 1 else 0 end as PC1MHAtDischarge
		, case when AlcoholAbuseAtIntake = 1 or SubstanceAbuseAtIntake = 1 then 1 else 0 end as PC1SAAtIntake
		, case when AlcoholAbuseAtDischarge = 1 or SubstanceAbuseAtDischarge = 1 then 1 else 0 end as PC1SAAtDischarge
		, case when PC1PrimaryLanguageAtIntake = '01' then 1 else 0 end as PC1PrimaryLanguageAtIntakeEnglish
		, case when PC1PrimaryLanguageAtIntake = '02' then 1 else 0 end as PC1PrimaryLanguageAtIntakeSpanish
		, case when PC1PrimaryLanguageAtIntake = '03' or PC1PrimaryLanguageAtIntake is null or PC1PrimaryLanguageAtIntake = '' then 1 else 0 end as PC1PrimaryLanguageAtIntakeOtherUnknown
		, case when IntakeDate>=TCDOB then 1 else 0 end as TrimesterAtIntakePostnatal
		, case when IntakeDate<TCDOB and datediff(dd, ConceptionDate, IntakeDate) > round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake3rd
		, case when IntakeDate<TCDOB and datediff(dd, ConceptionDate, IntakeDate) between round(30.44*3,0)+1 and round(30.44*6,0) then 1 else 0 end as TrimesterAtIntake2nd
		, case when IntakeDate<TCDOB and datediff(dd, ConceptionDate, IntakeDate) < 3*30.44  then 1 else 0 end as TrimesterAtIntake1st
		, CountOfFSWs
from cteMain
-- where DischargeReason not in ('Out of Geographical Target Area','Miscarriage/Pregnancy Terminated','Target Child Died')
where DischargeReasonCode is NULL or DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37')
		-- (DischargeReasonCode not in ('07', '17', '18', '20', '21', '23', '25', '37') or datediff(day,IntakeDate,DischargeDate)>=(4*6*30.44))
order by PC1ID,IntakeDate
--#endregion
--SELECT * FROM @tblPC1withStats

declare @TotalCohortCount int

-- now we have all the rows from the cohort in @tblPC1withStats
-- get the total count
select @TotalCohortCount = COUNT(*) 
  from @tblPC1withStats

--#region declare vars to collect counts for final stats
declare @LineGroupingLevel int
		, @TotalEnrolledParticipants int
		, @RetentionRateSixMonths decimal(5,3)
		, @RetentionRateOneYear decimal(5,3)
		, @RetentionRateEighteenMonths decimal(5,3)
		, @RetentionRateTwoYears decimal(5,3)
		, @EnrolledParticipantsSixMonths int
		, @EnrolledParticipantsOneYear int
		, @EnrolledParticipantsEighteenMonths int
		, @EnrolledParticipantsTwoYears int
		, @RunningTotalDischargedSixMonths int
		, @RunningTotalDischargedOneYear int
		, @RunningTotalDischargedEighteenMonths int
		, @RunningTotalDischargedTwoYears int
		, @TotalNSixMonths int
		, @TotalNOneYear int
		, @TotalNEighteenMonths int
		, @TotalNTwoYears int

declare @AllEnrolledParticipants int
		, @SixMonthsTotal int
		, @TwelveMonthsTotal int
		, @EighteenMonthsTotal int
		, @TwentyFourMonthsTotal int
		, @SixMonthsAtIntake int
		, @SixMonthsAtDischarge int
		, @TwelveMonthsAtIntake int
		, @TwelveMonthsAtDischarge int
		, @EighteenMonthsAtIntake int
		, @EighteenMonthsAtDischarge int
		, @TwentyFourMonthsAtIntake int
		, @TwentyFourMonthsAtDischarge int
--#endregion
--#region Retention Rate %
select @SixMonthsTotal = count(PC1ID)
from @tblPC1withStats

where ActiveAt6Months = 1

select @TwelveMonthsTotal = count(PC1ID)
from @tblPC1withStats

where ActiveAt12Months = 1

select @EighteenMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt18Months = 1

select @TwentyFourMonthsTotal = count(PC1ID)
from @tblPC1withStats
where ActiveAt24Months = 1

set @RetentionRateSixMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@SixMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateOneYear = case when @TotalCohortCount = 0 then 0.0000 else round((@TwelveMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateEighteenMonths = case when @TotalCohortCount = 0 then 0.0000 else round((@EighteenMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
set @RetentionRateTwoYears = case when @TotalCohortCount = 0 then 0.0000 else round((@TwentyFourMonthsTotal / (@TotalCohortCount * 1.0000)),4) end
--#endregion
--#region Enrolled Participants
select @EnrolledParticipantsSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 

select @EnrolledParticipantsOneYear = count(*)

from @tblPC1withStats
where ActiveAt12Months = 1 

select @EnrolledParticipantsEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 

select @EnrolledParticipantsTwoYears = count(*)
from @tblPC1withStats
where ActiveAt24Months = 1




--#endregion
--#region Running Total Discharged
select @RunningTotalDischargedSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
--select @RunningTotalDischargedSixMonths = count(*)
--from @tblPC1withStats
--where ActiveAt6Months = 0 and LastHomeVisit between IntakeDate and dateadd(day, 6*30.44, IntakeDate)
--
--select @RunningTotalDischargedOneYear = count(*) + @RunningTotalDischargedSixMonths
--from @tblPC1withStats
--where ActiveAt12Months = 0 and LastHomeVisit between dateadd(day, (6*30.44)+1, IntakeDate) and dateadd(day, 12*30.44, IntakeDate)
--
--select @RunningTotalDischargedEighteenMonths = count(*) + @RunningTotalDischargedOneYear
--from @tblPC1withStats
--where ActiveAt18Months = 0 and LastHomeVisit between dateadd(day, (12*30.44)+1, IntakeDate) and dateadd(day, 18*30.44, IntakeDate)
--
--select @RunningTotalDischargedTwoYears = count(*) + @RunningTotalDischargedEighteenMonths
--from @tblPC1withStats
--where ActiveAt24Months = 0 and LastHomeVisit between dateadd(day, (18*30.44)+1, IntakeDate) and dateadd(day, 24*30.44, IntakeDate)
--#endregion
--#region Total (N) - (Discharged)
select @TotalNSixMonths = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and LastHomeVisit is not null

select @TotalNOneYear = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and LastHomeVisit is not null

select @TotalNEighteenMonths = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and LastHomeVisit is not null

select @TotalNTwoYears = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and LastHomeVisit is not null
--#endregion
--#region Age @ Intake
--			Under 18
--			18 up to 20
--			20 up to 30
--			30 and over
set @LineGroupingLevel = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Age @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_Under18 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_Under18 = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_Under18 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_Under18 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_Under18 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Under 18'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_18upto20 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_18upto20 = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_18upto20 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_18upto20 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_18upto20 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    18 up to 20'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_20upto30 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_20upto30 = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_20upto30 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_20upto30 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_20upto30 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    20 up to 30'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where AgeAtIntake_Over30 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and AgeAtIntake_Over30 = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and AgeAtIntake_Over30 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and AgeAtIntake_Over30 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and AgeAtIntake_Over30 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    30 and Over'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)
--#endregion
--#region Race
--			White
--			Black
--			Hispanic
--			Other
--			Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Race'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceWhite = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceWhite = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceWhite = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceWhite = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceWhite = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    White'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceBlack = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceBlack = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceBlack = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceBlack = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceBlack = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Black'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceHispanic = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceHispanic = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceHispanic = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceHispanic = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceHispanic = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Hispanic'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceOther = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceOther = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceOther = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceOther = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceOther = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Other'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where RaceUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and RaceUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and RaceUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and RaceUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and RaceUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Unknown / Missing'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)
--#endregion
--#region Marital Status
--			Married
--			Not Married
--			Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Marital Status'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MarriedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Married'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where NeverMarriedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NeverMarriedAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NeverMarriedAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NeverMarriedAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NeverMarriedAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NeverMarriedAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NeverMarriedAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NeverMarriedAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NeverMarriedAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Never Married'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where SeparatedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and SeparatedAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and SeparatedAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and SeparatedAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and SeparatedAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and SeparatedAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and SeparatedAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and SeparatedAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and SeparatedAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Separated'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)



select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where DivorcedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and DivorcedAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and DivorcedAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DivorcedAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DivorcedAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DivorcedAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DivorcedAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DivorcedAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DivorcedAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Divorced'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where WidowedAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and WidowedAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and WidowedAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and WidowedAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and WidowedAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and WidowedAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and WidowedAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and WidowedAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and WidowedAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Widowed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where MarriedUnknownMissingAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedUnknownMissingAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and MarriedUnknownMissingAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedUnknownMissingAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and MarriedUnknownMissingAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedUnknownMissingAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and MarriedUnknownMissingAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedUnknownMissingAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and MarriedUnknownMissingAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
--#endregion
--#region Other Children in Household
-- Other Children in Household
--		Yes
--		No
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Other Children in Household'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OtherChildrenInHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OtherChildrenInHouseholdAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OtherChildrenInHouseholdAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OtherChildrenInHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OtherChildrenInHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OtherChildrenInHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where NoOtherChildrenInHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NoOtherChildrenInHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NoOtherChildrenInHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge

		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)






































--#endregion
--#region Receiving TANF Services
-- Receiving TANF Services
--		Yes
--		No
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Receiving TANF Services'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where ReceivingTANFAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and ReceivingTANFAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and ReceivingTANFAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and ReceivingTANFAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and ReceivingTANFAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and ReceivingTANFAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and ReceivingTANFAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and ReceivingTANFAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and ReceivingTANFAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where NotReceivingTANFAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NotReceivingTANFAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and NotReceivingTANFAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NotReceivingTANFAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and NotReceivingTANFAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NotReceivingTANFAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and NotReceivingTANFAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NotReceivingTANFAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and NotReceivingTANFAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
--#endregion
--#region Average Kempe Score
-- Average Kempe Score
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = avg(MomScore)
from @tblPC1withStats

select @SixMonthsAtIntake = avg(MomScore)
from @tblPC1withStats
where ActiveAt6Months = 0

select @TwelveMonthsAtIntake = avg(MomScore)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0

select @EighteenMonthsAtIntake = avg(MomScore)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0

select @TwentyFourMonthsAtIntake = avg(MomScore)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('Average Kempe Score'
		, @LineGroupingLevel
		, 0
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)
--#endregion
--#region Education
-- Education
--		Less than 12
--		HS / GED
--		More than 12
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Education'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeLessThan12 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeLessThan12 = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeLessThan12 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeLessThan12 = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeLessThan12 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeLessThan12 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeLessThan12 = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeLessThan12 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Less than 12'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeHSGED = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeHSGED = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeHSGED = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeHSGED = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeHSGED = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeHSGED = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeHSGED = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeHSGED = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeHSGED = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    HS / GED'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeMoreThan12 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeMoreThan12 = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeMoreThan12 = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeMoreThan12 = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeMoreThan12 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    More Than 12'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtIntakeUnknownMissing = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtIntakeUnknownMissing = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
--#endregion
--#region PC1 Enrolled In Education Program
-- PC1 Enrolled In Education Program
--		Yes
--		No
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 Enrolled In Education Program'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationalEnrollmentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationalEnrollmentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EducationalEnrollmentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
--#endregion
--#region PC1 Employed
-- PC1 Employed
--		Yes
--		No
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtIntakeYes = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeYes = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtIntakeNo = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeNo = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1EmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1EmploymentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)
--#endregion        
-- OBP in Household
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPInHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPInHouseholdAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPInHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPInHouseholdAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPInHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPInHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPInHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPInHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPInHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('OBP in Household'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- OBP Employed
--		Yes
--		No
--		No OBP for Case
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('OBP Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeYes = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeYes = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeNo = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeNo = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeNoOBP = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeNoOBP = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeNoOBP = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeNoOBP = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeNoOBP = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeNoOBP = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No OBP for case'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where OBPEmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and OBPEmploymentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- PC2 in Household (can not be OBP)
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2InHouseholdAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2InHouseholdAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2InHouseholdAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2InHouseholdAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2InHouseholdAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2InHouseholdAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2InHouseholdAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2InHouseholdAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2InHouseholdAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('PC2 in Household (can not be OBP)'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- PC2 Employed
--		Yes
--		No
--		No PC2 in Home
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC2 Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeYes = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeYes = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeNo = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeNo = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeNoPC2 = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeNoPC2 = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeNoPC2 = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No PC2 in Home'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC2EmploymentAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC2EmploymentAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- PC1 or PC2 or OBP Employed
--		Yes
--		No
--		Unknown / Missing
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 or PC2 or OBP Employed'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeYes = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeYes = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Yes'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeNo = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeNo = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    No'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtIntakeUnknownMissing = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1OrPC2OrOBPEmployedAtDischargeUnknownMissing = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    Missing / Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- Average # of Actual Home Visits
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = avg(CountOfHomeVisits)
from @tblPC1withStats

select @SixMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt6Months = 0

select @TwelveMonthsAtDischarge = avg(CountOfHomeVisits)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0

select @EighteenMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0

select @TwentyFourMonthsAtDischarge = avg(CountOfHomeVisits)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsDischarge
						, OneYearDischarge
						, EighteenMonthsDischarge
						, TwoYearsDischarge)
values ('Average # of Actual Home Visits'
		, @LineGroupingLevel
		, 0
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtDischarge)

-- Discharged on Level X
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where DischargedOnLevelX = 1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and DischargedOnLevelX = 1

select @TwelveMonthsAtDischarge = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and DischargedOnLevelX = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and DischargedOnLevelX = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and DischargedOnLevelX = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsDischarge
						, OneYearDischarge
						, EighteenMonthsDischarge
						, TwoYearsDischarge)
values ('Discharged on Level X'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtDischarge)

-- PC1 Current Issues
--		DV
--		MH
--		SA
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('PC1 Current Issues'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1DVAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1DVAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1DVAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1DVAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1DVAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1DVAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1DVAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1DVAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1DVAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    DV'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1MHAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1MHAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1MHAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1MHAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1MHAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1MHAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1MHAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1MHAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1MHAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    MH'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1SAAtIntake = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1SAAtIntake = 1



select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1SAAtDischarge = 1

select @TwelveMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1SAAtIntake = 1



select @TwelveMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1SAAtDischarge = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1SAAtIntake = 1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1SAAtDischarge = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1SAAtIntake = 1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1SAAtDischarge = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, SixMonthsDischarge
						, OneYearIntake
						, OneYearDischarge
						, EighteenMonthsIntake
						, EighteenMonthsDischarge
						, TwoYearsIntake
						, TwoYearsDischarge)
values ('    SA'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtIntake
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtIntake
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtIntake
		, @TwentyFourMonthsAtDischarge)

-- Primary Language @ Intake
--		English
--		Spanish
--		Other / Unknown
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Primary Language @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeEnglish = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeEnglish = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    English'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeSpanish = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeSpanish = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Spanish'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and PC1PrimaryLanguageAtIntakeOtherUnknown = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Other/Missing/Unknown'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

-- Trimester @ Intake
--		Postnatal
--		1st
--		2nd
--		3rd
set @LineGroupingLevel = @LineGroupingLevel + 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears)
values ('Trimester @ Intake'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntakePostnatal = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntakePostnatal = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntakePostnatal = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntakePostnatal = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntakePostnatal = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    Postnatal'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake1st = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntake1st = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake1st = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake1st = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake1st = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    1st'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake2nd = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntake2nd = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake2nd = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake2nd = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake2nd = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    2nd'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where TrimesterAtIntake3rd = 1

select @SixMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and TrimesterAtIntake3rd = 1

select @TwelveMonthsAtIntake = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and TrimesterAtIntake3rd = 1

select @EighteenMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and TrimesterAtIntake3rd = 1

select @TwentyFourMonthsAtIntake = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and TrimesterAtIntake3rd = 1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsIntake
						, OneYearIntake
						, EighteenMonthsIntake
						, TwoYearsIntake)
values ('    3rd'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtIntake
		, @TwelveMonthsAtIntake
		, @EighteenMonthsAtIntake
		, @TwentyFourMonthsAtIntake)

-- Cases with More than 1 Home Visitor
set @LineGroupingLevel = @LineGroupingLevel + 1

select @AllEnrolledParticipants = count(*)
from @tblPC1withStats
where CountOfFSWs>1

select @SixMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt6Months = 0 and CountOfFSWs>1

select @TwelveMonthsAtDischarge = count(*)

from @tblPC1withStats
where ActiveAt6Months = 1 and ActiveAt12Months = 0 and CountOfFSWs>1

select @EighteenMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt12Months = 1 and ActiveAt18Months = 0 and CountOfFSWs>1

select @TwentyFourMonthsAtDischarge = count(*)
from @tblPC1withStats
where ActiveAt18Months = 1 and ActiveAt24Months = 0 and CountOfFSWs>1

insert into @tblResults (LineDescription
						, LineGroupingLevel
						, DisplayPercentages
						, TotalEnrolledParticipants
						, RetentionRateSixMonths
						, RetentionRateOneYear
						, RetentionRateEighteenMonths
						, RetentionRateTwoYears
						, EnrolledParticipantsSixMonths
						, EnrolledParticipantsOneYear
						, EnrolledParticipantsEighteenMonths
						, EnrolledParticipantsTwoYears
						, RunningTotalDischargedSixMonths
						, RunningTotalDischargedOneYear
						, RunningTotalDischargedEighteenMonths
						, RunningTotalDischargedTwoYears
						, TotalNSixMonths
						, TotalNOneYear
						, TotalNEighteenMonths
						, TotalNTwoYears
						, AllParticipants
						, SixMonthsDischarge
						, OneYearDischarge
						, EighteenMonthsDischarge
						, TwoYearsDischarge)
values ('Cases With >1 Home Visitor'
		, @LineGroupingLevel
		, 1
        , @TotalCohortCount
		, @RetentionRateSixMonths
		, @RetentionRateOneYear
		, @RetentionRateEighteenMonths
		, @RetentionRateTwoYears
		, @EnrolledParticipantsSixMonths
		, @EnrolledParticipantsOneYear
		, @EnrolledParticipantsEighteenMonths
		, @EnrolledParticipantsTwoYears
		, @RunningTotalDischargedSixMonths
		, @RunningTotalDischargedOneYear
		, @RunningTotalDischargedEighteenMonths
		, @RunningTotalDischargedTwoYears
		, @TotalNSixMonths
		, @TotalNOneYear
		, @TotalNEighteenMonths
		, @TotalNTwoYears
		, @AllEnrolledParticipants
		, @SixMonthsAtDischarge
		, @TwelveMonthsAtDischarge
		, @EighteenMonthsAtDischarge
		, @TwentyFourMonthsAtDischarge)


--select *
--from @tblPC1withStats

--Chris Papas (3/29/2012) Modified this final select to get the proper retention rates for period requested

INSERT INTO [__Temp_RetentionRate_Report]
select @ProgramFK
	  ,LineDescription
	  ,LineGroupingLevel
	  ,DisplayPercentages
	  ,TotalEnrolledParticipants
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then RetentionRateSixMonths else null end as RetentionRateSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then RetentionRateOneYear else null end as RetentionRateOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then RetentionRateEighteenMonths else null end as RetentionRateEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then RetentionRateTwoYears else null end as RetentionRateTwoYears
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then EnrolledParticipantsSixMonths else null end as EnrolledParticipantsSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then EnrolledParticipantsOneYear else null end as EnrolledParticipantsOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then EnrolledParticipantsEighteenMonths else null end as EnrolledParticipantsEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then EnrolledParticipantsTwoYears else null end as EnrolledParticipantsTwoYears
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then RunningTotalDischargedSixMonths else null end as RunningTotalDischargedSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then RunningTotalDischargedOneYear else null end as RunningTotalDischargedOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then RunningTotalDischargedEighteenMonths else null end as RunningTotalDischargedEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then RunningTotalDischargedTwoYears else null end as RunningTotalDischargedTwoYears
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then TotalNSixMonths else null end as TotalNSixMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then TotalNOneYear else null end as TotalNOneYear
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then TotalNEighteenMonths else null end as TotalNEighteenMonths
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then TotalNTwoYears else null end as TotalNTwoYears
	  ,AllParticipants
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then SixMonthsIntake else null end as SixMonthsIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 26 then SixMonthsDischarge else null end as SixMonthsDischarge
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then OneYearIntake else null end as OneYearIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 52 then OneYearDischarge else null end as OneYearDischarge
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then EighteenMonthsIntake else null end as EighteenMonthsIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 78 then EighteenMonthsDischarge else null end as EighteenMonthsDischarge
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then TwoYearsIntake else null end as TwoYearsIntake
	  ,case when datediff(ww,@enddate,getdate()) >= 104 then TwoYearsDischarge else null end as TwoYearsDischarge
from @tblResults
--SELECT * from @tblResults

--select VendorID, Employee, Orders
--from
--   (SELECT ActiveAt6Months, ActiveAt12Months, ActiveAt18Months, ActiveAt24Months
--   FROM @tblPC1withStats) p
--UNPIVOT
--   (Orders FOR Employee IN 
--      (Emp1, Emp2, Emp3, Emp4, Emp5)
--)AS unpvt;

end
GO


