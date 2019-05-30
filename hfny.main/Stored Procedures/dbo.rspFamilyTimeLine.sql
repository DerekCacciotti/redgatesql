SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jay Robohn
-- Create date: 
-- Description:	<report: Family Time Line>
--				moved from FamSys Feb 20, 2012 by jrobohn
--mod by dar
--exec rspFamilyTimeline null,1
-- =============================================
CREATE PROC [dbo].[rspFamilyTimeLine]
(
    @pc1id     varchar(13),
    @programfk varchar(max)
)
as
	if @programfk is null
	begin
		select @programfk = substring((select ','+LTRIM(RTRIM(STR(HVProgramPK)))
										   from HVProgram
										   for xml path ('')),2,8000)
	end

	set @programfk = REPLACE(@programfk,'"','')

	-- TimeLine
	declare @timeline table(
		recid int identity (1,1),
		eventDescription varchar(200),
		DueDate datetime
	)

	-- ASQ
	insert into @timeline
		select eventDescription
			  ,case
				   when interval < 24 then
					   dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
				   else
					   dateadd(dd,dueby,hvcase.tcdob)
			   end DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				--inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asq version'
				inner join codeduebydates on scheduledevent = 'ASQ'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- ASQ-SE
		select eventDescription
			  ,case
				   when interval < 24 then
					   dateadd(dd,dueby,(((40-gestationalage)*7)+hvcase.tcdob))
				   else
					   dateadd(dd,dueby,hvcase.tcdob)
			   end DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				--inner join appoptions on caseprogram.programfk = appoptions.programfk and optionitem = 'asqse version'
				inner join codeduebydates on scheduledevent = 'ASQSE-2'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
					-- PC1ID = isnull(@pc1id, PC1ID)
					and caseprogress >= 11

        union

		-- FOLLOW UP
		select eventDescription
			  ,dateadd(dd,dueby,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'Follow Up'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		UNION
        
		--CHEERS Check-In
		select IIF(DATEADD(dd,dueby,hvcase.tcdob) < '02/01/2019', (EventDescription + ' (N/A)'), EventDescription) eventDescription
			  ,dateadd(dd,dueby,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'CHEERS'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- TCMedical
		-- DTaP
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'DTaP'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- HIB
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'HIB' AND codeDueByDates.optional IS NULL

				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- PCV
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'PCV'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- Polio
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'Polio'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- MMR
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'MMR'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- HEP-B
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'HEP-B'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- VZ
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'VZ'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- Flu
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'Flu'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- Roto
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'Roto' AND codeDueByDates.optional IS NULL
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- HEP-A
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'HEP-A'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- WBV
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'WBV'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

		union

		-- Lead
		select eventDescription
			  ,dateadd(dd,MinimumDue,hvcase.tcdob) DueDate
			from caseprogram
				inner join hvcase on hvcasepk = caseprogram.hvcasefk
				inner join tcid on tcid.hvcasefk = hvcasepk --and tcid.programfk = caseprogram.programfk
				inner join codeduebydates on scheduledevent = 'Lead'
				inner join dbo.SplitString(@programfk,',') on caseprogram.programfk = listitem
			where PC1ID = @pc1id
				 and caseprogress >= 11

	-- FINAL TIMELINE
	select eventDescription as AppCodeText
		  ,DueDate as DateCompleted
		from @timeline
		order by DueDate
GO
