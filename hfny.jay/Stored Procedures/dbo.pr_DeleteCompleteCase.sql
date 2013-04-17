
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jay Robohn
-- Create date: old
-- Description:	Adapted from FamSys on Feb 13, 2013
-- exec pr_DeleteCompleteCase 8088, 1
-- =============================================
CREATE procedure [dbo].[pr_DeleteCompleteCase]
(
    @hvcasefk          int,
    @programfk         int,
    @ok as             varchar(200)    output
)
as
begin try
	begin transaction
	declare @pk int
	-- delete the records from the tables that are not dependent on other records
	--ASQ--possible multi-records
	declare del_cursor cursor for
	select asqpk
		from ASQ
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelASQ @ASQPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--ASQSE
	declare del_cursor cursor for
	select asqsepk
		from ASQSE
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelASQSE @ASQSEPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--CaseFilter--
	declare del_cursor cursor for
	select caseFilterPK
		from CaseFilter
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelCaseFilter @CaseFilterPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--Education
	declare del_cursor cursor for
	select Educationpk
		from Education
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelEducation @EducationPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--Employment
	declare del_cursor cursor for
	select Employmentpk
		from Employment
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelEmployment @EmploymentPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--HVLog
	declare del_cursor cursor for
	select HVLOGpk
		from HVLog
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelHVLog @HVLogPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--OtherChild
	declare del_cursor cursor for
	select otherchildpk
		from OtherChild
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelOtherChild @OtherChildPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--PC1Medical
	declare del_cursor cursor for
	select PC1Medicalpk
		from PC1Medical
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelPC1Medical @PC1MedicalPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--ServiceReferral
	declare del_cursor cursor for
	select ServiceReferralpk
		from ServiceReferral
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelServiceReferral @ServiceReferralPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--TCMEDICAL
	declare del_cursor cursor for
	select TCMedicalpk
		from TCMedical
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelTCMedical @TCMedicalPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;
	--end

	--PHQ9
	declare del_cursor cursor for
	select PHQ9PK
		from PHQ9 P
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelPHQ9 @PHQ9PK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--TCID
	declare del_cursor cursor for
	select TCIDpk
		from TCID
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelTCID @TCIDPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--HVLEVEL
	declare del_cursor cursor for
	select HVLevelpk
		from HVLevel
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelHVLevel @HVLevelPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--FollowUp
	declare del_cursor cursor for
	select FollowUppk
		from FollowUp
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelFollowUp @FollowUpPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--CommonAttributes
	declare del_cursor cursor for
	select CommonAttributespk
		from CommonAttributes
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelCommonAttributes @CommonAttributesPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--Intake
	declare del_cursor cursor for
	select Intakepk
		from Intake
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelIntake @IntakePK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--Preintake
	declare del_cursor cursor for
	select Preintakepk
		from Preintake
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelPreintake @PreintakePK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--AuditC
	declare del_cursor cursor for
	select AuditCPK
		from AuditC
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelAuditC @AuditCPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--HITS
	declare del_cursor cursor for
	select HITSPK
		from HITS H
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelHITS @HITSPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--Kempe
	declare del_cursor cursor for
	select Kempepk
		from Kempe
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelKempe @KempePK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--PC1Issues
	declare del_cursor cursor for
	select PC1Issuespk
		from PC1Issues
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelPC1Issues @PC1IssuesPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--Preassessment
	declare del_cursor cursor for
	select Preassessmentpk
		from Preassessment
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelPreassessment @PreassessmentPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--WorkerAssignment
	declare del_cursor cursor for
	select WorkerAssignmentpk
		from WorkerAssignment
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelWorkerAssignment @WorkerAssignmentPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--HVSCREEN
	declare del_cursor cursor for
	select HVScreenpk
		from HVScreen
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelHVScreen @HVScreenPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--CaseProgram
	declare del_cursor cursor for
	select CaseProgrampk
		from CaseProgram
		where hvcasefk = @hvcasefk
			 and ProgramFK = @ProgramFK;
	open del_cursor

	fetch next from del_cursor into @PK

	while @@FETCH_STATUS = 0
	begin
		exec spDelCaseProgram @CaseProgramPK = @PK

		fetch next from del_cursor into @PK

	end
	close del_cursor;
	deallocate del_cursor;

	--HVCase
	--remove the formreview records first for ID contact
	delete
		from FormReview
		where hvcasefk = @hvcasefk and
			 programFK = @ProgramFK and
			 (FormType = 'ID' or
			 FormType = 'DS')

	-- only delete hvcase record if not used for other programs
	delete
		from HVCase
		where hvcasepk = @hvcasefk and
			 HVCasePK not in (select HVCaseFK
								  from CaseProgram
								  where HVCaseFK = @hvcasefk
									   and
									   ProgramFK <> @ProgramFK);

	-- Successfully deleted 
	set @ok = 'good'
	commit
end try
begin catch
	if @@TRANCOUNT > 0
		rollback

	-- DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
	select @ok = error_message()

end catch
GO
