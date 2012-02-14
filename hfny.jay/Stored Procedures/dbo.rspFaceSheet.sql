
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jay Robohn>
-- Create date: <Jan 25, 2012>
-- Description:	<Face Sheet report>
-- =============================================
CREATE procedure [dbo].[rspFaceSheet](@programfk    varchar(max)    = null,
                                                        @pc1id		char(13)
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

	if @pc1id=''
	begin
		set @pc1id=null
	end;
	
	with cteMain
	as
	(select HVCasePK
			,PC1ID
			,CurrentFSWFK
			,CurrentLevelFK
			,LevelName
			,CurrentLevelDate
			,case when IntakeDate is null then 0
					else
					case when DischargeDate is null 
						then datediff(day,CurrentLevelDate,getdate())
						else datediff(day,CurrentLevelDate,DischargeDate)
					end
			end as DaysOnCurrentLevel 
			,isnull(datediff(month,IntakeDate,getdate()),000) as MonthsInProgram
			,ScreenDate
			,c.KempeDate
			,IntakeDate
			,DischargeDate
			,cd.DischargeReason as DischargeReasonName
			,CaseProgress
			,PC1FK
			,OBPFK
			,OBPinHomeIntake
			,PC2FK
			,PC2inHomeIntake
			,CPFK
			,rtrim(PC1.PCFirstName)+' '+rtrim(PC1.PCLastName) as PC1FullName
			,rtrim(PC1.PCStreet) + case when PC1.PCApt is null or PC1.PCApt = '' then ''
										else ' (Apt. '+replace(replace(PC1.PCApt,'Apt.',''),'Apt','')+')'
									end as PC1Street
			,rtrim(PC1.PCCity)+', '+isnull(PC1.PCState,'NY')+'  '+rtrim(PC1.PCZip) as PC1CSZ
			,PC1.PCPhone
			,PC1.PCCellPhone
			,case when PC1.SSNo is null
					then 'Not on file'
					else 'On file'
					end
			as SocialSecurityNumberOnFile
			,PC1.PCDOB
			,datediff(year,PC1.PCDOB,getdate()) as CurrentAge
			,datediff(year,PC1.PCDOB,IntakeDate) as AgeAtIntake
			,rtrim(w.FirstName) + ' ' + rtrim(w.LastName) as WorkerName
			,w.FirstName
			,w.LastName
			,rtrim(sup.FirstName) + ' ' + rtrim(sup.LastName) as SupervisorName
			,MomScore
			,DadScore
			,k.FAWFK
			,rtrim(PCOBP.PCFirstName)+' '+rtrim(PCOBP.PCLastName) as OBPFullName
			,PCOBP.PCDOB as OBPDOB
			,rtrim(PCPC2.PCFirstName)+' '+rtrim(PCPC2.PCLastName) as PC2FullName
			,PCPC2.PCDOB as PC2DOB
			,rtrim(PCCP.PCFirstName)+' '+rtrim(PCCP.PCLastName) as CPFullName
			,rtrim(PCCP.PCStreet) + case when PCCP.PCApt is null or PCCP.PCApt = '' then ''
										else ' (Apt. '+replace(replace(PCCP.PCApt,'Apt.',''),'Apt','')+')'
									end as CPStreet
			,rtrim(PCCP.PCCity)+', '+isnull(PCCP.PCState,'NY')+'  '+rtrim(PCCP.PCZip) as CPCSZ
			,PCCP.PCDOB as CPDOB
			,PCCP.PCPhone as CPPhone
			,TCIDPK
			,rtrim(TCFirstName)+' '+rtrim(TCLastName) as TCFullName
			,t.TCDOB
			,case when TCGender ='1' then 'Female'
					when TCGender='2' then 'Male'
			 end as TCGender
			,(datediff(day,t.TCDOB,getdate()))/30.44 as TCChronologicalAge
			,GestationalAge
			,((datediff(day,t.TCDOB,getdate()))-((40-GestationalAge)*7))/30.44 as TCDevelopmentalAge
			,NumberOfChildren
			--,IIF(!EMPTY(tc_ssn) and !ISNULL(tc_ssn),"On file    ","Not on file") as tcss_of, ;
			,case when t.TCDOD is null then 0 else 1 end as TCDeceased
		from HVCase c
		inner join CaseProgram cp on cp.HVCaseFK = c.HVCasePK
		inner join PC PC1 on PC1.PCPK = c.PC1FK
		inner join dbo.SplitString(@programfk,',') on cp.programfk = listitem
		left outer join PC PCOBP on PCOBP.PCPK = c.OBPFK
		left outer join PC PCPC2 on PCPC2.PCPK = c.PC2FK
		left outer join PC PCCP on PCCP.PCPK = c.CPFK
		left outer join Kempe k on k.HVCaseFK = c.HVCasePK
		left outer join Worker w on w.WorkerPK = cp.CurrentFSWFK
		left outer join WorkerProgram wp on wp.WorkerFK = w.WorkerPK
		left outer join Worker sup on sup.WorkerPK = wp.SupervisorFK
		left outer join TCID t on t.HVCaseFK = c.HVCasePK
		left outer join codeLevel cl on cl.codeLevelPK = cp.CurrentLevelFK
		left outer join codeDischarge cd on cd.DischargeReason = cp.DischargeReason
		where PC1ID=isnull(@pc1id,PC1ID)
				and caseprogress >= 6
				-- and PC1ID='SP80040113929'
	)
	,
	cteFSWAssignDate
	as
	(select HVCaseFK
			,max(WorkerAssignmentDate) as FSWAssignDate
		from WorkerAssignment wa
		inner join cteMain on HVCaseFK=HVCasePK
		where WorkerFK=CurrentFSWFK
		group by HVCaseFK
	)	
	--,
	--cteLevelChanges
	--as
	--(select casefk
	--	   ,count(casefk)-1 as LevelChanges
	--	 from cteHVRecords
	--	 group by casefk
	--)
	--,
	--cteSummary
	--as
	--(select distinct workername
	--				,workerfk
	--				,pc1id
	--				,casecount
	--				,sum(visitlengthminute) over (partition by pc1wrkfk) as 'Minutes'
	--				,sum(expvisitcount) over (partition by pc1wrkfk) as expvisitcount
	--				,min(startdate) over (partition by pc1wrkfk) as 'startdate'
	--				,max(enddate) over (partition by pc1wrkfk) as 'enddate'
	--				,levelname
	--				,max(levelstart) over (partition by pc1wrkfk) as 'levelstart'
	--				,sum(actvisitcount) over (partition by pc1wrkfk) as actvisitcount
	--				,sum(inhomevisitcount) over (partition by pc1wrkfk) as inhomevisitcount
	--				,sum(attvisitcount) over (partition by pc1wrkfk) as attvisitcount
	--				,max(dischargedate) over (partition by pc1wrkfk) as 'dischargedate'
	--				,LevelChanges
	--	 from cteMain
	--		 inner join cteLevelChanges on cteLevelChanges.casefk = cteHVRecords.casefk
	--)
	select Main.*
			,FSWAssignDate
		from cteMain Main
		inner join cteFSWAssignDate on HVCaseFK=HVCasePK
		order by LastName, FirstName
				,PC1ID
		--order by WorkerName
		--		,pc1id

end

				
--hvcase5.pc1_fk=pc5.pc_pk AND ("Level" $ cur_level OR "Preintake" $ cur_level);		

--Medical Provider FK (PC1)
--Medical Provider FK (TC)
  --,mppc1_fk,mptc_fk,;

/*
  IIF(PC1MA='1','MA','  ') as ma,;
  IIF(CA_PC1PCAP='1','PCAP','    ') as pcap,;
  IIF(CA_PC1CHIH='1','CHP',SPACE(3)) as chp,;
  IIF(ca_pc1priv='1','Priv',SPACE(4)) as priv,;
  IIF(ca_pc1hiot='1','Other',SPACE(5)) as other,;
  IIF(ca_pc1none='1',"None",SPACE(4)) as none,;
  IIF(pc1ma='1',IIF(!EMPTY(cpc1macase),"On file   ","Not on file"),SPACE(11)) as ma_of,;
  IIF(ca_pc1pcap='1',IIF(!EMPTY(pc1pcapno),"On file    ","Not on file"),SPACE(11)) as pcap_of,;
  IIF(tcMA='1','MA','  ') as Tcma,;
  IIF(CA_tcCHIH='1','CHP',SPACE(3)) as tcchp,;
  IIF(ca_tcpriv='1','Priv',SPACE(4)) as tcpriv,;
  IIF(ca_tcother='1','Other',SPACE(5)) as tcother,;
  IIF(ca_tcnone='1',"None",SPACE(4)) as tcnone,;
  IIF(tcma='1',IIF(!EMPTY(ctcmacase),"On file   ","Not on file"),SPACE(11)) as tcma_of,;
  pc1_inhome, pc2_inhome, cur_pc2ih, ;

INTO CURSOR fs1    

**Add preasses info (date worker assigned)
SELECT fs4.*, datefswass FROM fs4 LEFT OUTER JOIN preasse5 ;
   ON fs4.case_pk=preasse5.case_fk AND pa_castat='2' INTO CURSOR FS5 
  
***Add the closed reason
SELECT fs5.*, reason FROM fs5 ;
  LEFT OUTER JOIN clsdcode5 ON why_notc=cl_code INTO CURSOR fs6
  
***Add pc2 info
SELECT fs6.*, ALLTRIM(pcfname)+SPACE(1)+ALLTRIM(pclname) as pc2name,;
pc5.pcdob as pc2dob, pcsex as pc2sex  FROM fs6 LEFT OUTER JOIN pc5 ON ;
  fs6.pc2_fk=pc5.pc_pk INTO CURSOR FS7

***Add cp info
SELECT fs7.*, ALLTRIM(pcfname)+SPACE(1)+ALLTRIM(pclname) as cpname,;
  ALLTRIM(PCSTREET)+ IIF(!EMPTY(PCAPT),", "," ")+ALLTRIM(PCAPT) AS cp_STREET,;
  ALLTRIM(pccity)+IIF(!EMPTY(pccity),", NY ","NY ")+ LEFT(ALLTRIM(pczipcod),5) as cp_city,;
  pcphone as cp_phone,pc5.pcdob as cp_dob ;
FROM fs7 LEFT OUTER JOIN pc5 ON fs7.cp_fk=pc5.pc_pk INTO CURSOR FS8

***add medprov5
SELECT FS9.*,;
   "Dr. "+alltrim(mpa.mpfname)+space(1)+alltrim(mpa.mplname)+iif(!empty(mpa.mplname),';','')+alltrim(mpa.mpfacility) as pc1dr,;
   mpa.mpphone as pc1mpphone;  
FROM fs9 LEFT OUTER JOIN medprov5 mpa  ON ;
mpa.mp_pk=fs9.mppc1_fk into cursor fs9a

SELECT FS9a.*,;
   "Dr. "+alltrim(mpb.mpfname)+space(1)+alltrim(mpb.mplname)+iif(!empty(mpb.mplname),';','')+alltrim(mpb.mpfacility) as tcdr,;
   mpb.mpphone as tcmpphone ;   
FROM fs9a LEFT OUTER JOIN medprov5 mpb ON ;
mpb.mp_pk=fs9a.mptc_fk into cursor fs10

***make cursor with asq's under cutoff
SELECT tc_age, iif(fmot_under,"FM","  ") as fmot,iif(gmot_under,"GM","  ") as gmot,;
IIF(COMM_UNDER,"COM","   ") AS com, IIF(psolv_unde,"PROB","   ") AS psolv,;
IIF(psoc_under,"SOC","   ") as psoc, ;
max(aq_datcomp) as asq_datcomp, aq_tc_fk from hvasq5 ;
where fmot_under or gmot_under;
    OR comm_under OR psolv_unde;
    OR psoc_under ;
group by aq_tc_fk ;
INTO CURSOR fs11

***add asq's to file

SELECT fs10.*, tc_age, fs11.asq_datcomp,;
  alltrim(com)+iif(!emptY(com)," ","")+;
  alltrim(gmot)+iif(!empty(gmot)," ","")+;
  ALLTRIM(fmot)+IIF(!EMPTY(fmot)," ","")+;
  ALLTRIM(psolv)+IIF(!EMPTY(psolv)," ","")+;
  ALLTRIM(psoc) as last_uasq;
FROM fs10 LEFT OUTER JOIN fs11 ON fs10.tcid_pk=fs11.aq_tc_fk;
INTO CURSOR fs12

sele * from all_code5 where a_group="Tc_age" into cursor ages

sele fs12.*,alltrim(code_txt) as tcage from fs12 LEFT OUTER JOIN ages ;
  ON VAL(fs12.tc_age)=VAL(ages.a_code);
  INTO CURSOR fs13

****add the intake or latest fup
sele fs13.*, IIF(xtra_fld6='3' or xtra_fld6='4','Intake'+SPACE(14), ;
 IIF(VAL(xtra_fld6)>4,all_code5.code_txt,SPACE(20))) as info_from from fs13;
LEFT OUTER JOIN all_code5 ON VAL(fs13.xtra_fld6)= VAL(all_code5.a_code) ;
WHERE a_group="Xtra_fld6" INTO CURSOR fs14

***add the benefits
***make cursor with intake info

SELECT iif(CR_AFDC_HR,"TANF","    ") AS TANF,;
       IIF(cr_foodstm,"FS","  ") as fs,;
       IIF(cr_emer_as,"EA","  ") as ea,;
       IIF(cr_wic,"WIC","   ") as wic,;
       IIF(cr_ssi_ssd,"SSI/SSD","       ") AS ssi,;
       meettanf,;
       case_fk,in_dointak FROM intake25 INTO CURSOR fs15

*ADD INTAKE INFO TO TABLE
SELECT fs14.*,;
  IIF(info_from="Intake", ;
  ALLTRIM(tanf)+IIF(!EMPTY(tanf)," ","") + ;
  ALLTRIM(fs)+ IIF(!EMPTY(fs)," ","") + ;
  ALLTRIM(ea)+ IIF(!EMPTY(ea)," ","") + ;
  ALLTRIM(wic)+ IIF(!EMPTY(wic)," ","") + ;
  ALLTRIM(ssi), space(18)) as BENES, in_dointak as from_date,;
   IIF(EMPTY(meettanf),"   ",IIF(meettanf=.t.,"Yes",IIF(meettanf=.f.,"No","   "))) as meettanf ;
FROM fs14 LEFT OUTER JOIN fs15 ON FS14.case_pk=fs15.case_fk ;
INTO CURSOR FS16 readwrite

***make the fup benefits table &&& group by cursor corrected 11/20/03

SELECT MAX(f2_datcomp) as from_date,case_fk FROM hvfup25 GROUP BY case_fk INTO CURSOR fup25s

SELECT iif(AFDC_HR='1',"TANF","    ") AS TANF,;
       IIF(fOOD_STMP='1',"FS","  ") as fs,;
       IIF(emer_asS='1',"EA","  ") as ea,;
       IIF(wic='1',"WIC","   ") as wic,;
       IIF(ssi_ssd='1',"SSI/SSD","       ") AS ssi,;
       case_fk, meet_tanf, f2_datcomp FROM HVFUP25 INTO CURSOR fs17;
       where STR(CASE_FK)+TRANSFORM(f2_datcomp) in ;
       (select STR(CASE_FK)+TRANSFORM(from_date) FROM fup25s) 
       
SELECT fs17
SCAN
	SELECT fs16
	REPLACE benes with ALLTRIM(fs17.tanf)+IIF(!EMPTY(fs17.tanf)," ","") + ;
  				       ALLTRIM(fs17.fs)+ IIF(!EMPTY(fs17.fs)," ","") + ;
                       ALLTRIM(fs17.ea)+ IIF(!EMPTY(fs17.ea)," ","") + ;
				  	   ALLTRIM(fs17.wic)+ IIF(!EMPTY(fs17.wic)," ","") + ;
				       ALLTRIM(fs17.ssi), from_date with fs17.f2_datcomp, ;
				MEETTANF WITH IIF(EMPTY(fs17.meet_tanf),"   ",IIF(fs17.meet_tanf=.t.,"Yes","No")) ;
   FOR case_pk=fs17.case_fk
ENDSCAN       
***ADD FAW NAME    
SELECT fs16.*, ALLTRIM(HV_FNAME)+SPACE(1)+ALLTRIM(hv_lname) as faw_name ;
FROM fs16 LEFT OUTER JOIN hvwrkr5 ON k_faw_fk=wrkr_pk INTO CURSOR FS18

***GET ALL PC2 INTAKE RECORDS
SELECT * FROM intake5 WHERE in_ptype="PC2" INTO CURSOR pc2rel
***GET ALL_CODE RECORDS FOR REL_TC
SELECT code_Txt,a_code FROM all_code5 WHERE a_group="rel_tc" INTO CURSOR code1
***ADD REL_TC TXT TO THE INTAKE RECORDS (PC2)        
SELECT pc2rel.*, code_txt as pc2reltc FROM pc2rel LEFT OUTER JOIN code1;
     ON pc2rel.pcreltc=code1.a_code INTO CURSOR FS21

SELECT FS18.*,FS21.pc2reltc FROM fs18 LEFT OUTER JOIN FS21 ON fs18.case_pk=fs21.case_fk;
INTO CURSOR FS19

sele *, ;
 ALLTRIM(MA)+IIF(EMPTY(MA),""," ") +;
 ALLTRIM(pcap)+IIF(EMPTY(pcap),""," ") +;
 ALLTRIM(chp)+IIF(EMPTY(chp),""," ") +;
 ALLTRIM(priv)+IIF(EMPTY(priv),""," ") +;
 ALLTRIM(other)+IIF(EMPTY(other),""," ") +;
 ALLTRIM(none) as pc1hi, ;
 ALLTRIM(tcma)+IIF(EMPTY(tcma),""," ") +;
 ALLTRIM(tcchp)+IIF(EMPTY(tcchp),""," ") +;
 ALLTRIM(tcpriv)+IIF(EMPTY(tcpriv),""," ") +;
 ALLTRIM(tcother)+IIF(EMPTY(tcother),""," ") +;
 ALLTRIM(tcnone) as tchi ;
FROM fs19 ORDER BY sup_fk, cur_wkr_fk,ca_pc1_id INTO CURSOR facesheet      
       
*/
GO
