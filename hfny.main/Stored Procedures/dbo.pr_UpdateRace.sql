SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Bill O'Brien
-- Create date: 3-30-2020
-- Description:	Update new Race fields with existing data
-- =============================================
CREATE procedure [dbo].[pr_UpdateRace]

as

update PC
--pattern repeats for each field
--if all miechv race fields are 0 or this particular miechv race field is null, then check PC.Race
--otherwise copy the corresponding miechv race field value
set Race_AmericanIndian = Case When (i.MIECHV_Hispanic = 0 and i.MIECHV_Race_AmericanIndian = 0 and i.MIECHV_Race_Asian = 0 and
									i.MIECHV_Race_Black = 0 and i.MIECHV_Race_Hawaiian = 0 and i.MIECHV_Race_White = 0) 
									Or i.MIECHV_Race_AmericanIndian is null
							   Then Case When Race = '05' Then 1 Else 0 End

							   When i.MIECHV_Race_AmericanIndian is not null Then i.MIECHV_Race_AmericanIndian
						  End,

    Race_Asian = Case When (i.MIECHV_Hispanic = 0 and i.MIECHV_Race_AmericanIndian = 0 and i.MIECHV_Race_Asian = 0 and
							i.MIECHV_Race_Black = 0 and i.MIECHV_Race_Hawaiian = 0 and i.MIECHV_Race_White = 0) 
							Or i.MIECHV_Race_Asian is null
							Then Case When Race = '04' Then 1 Else 0 End

					  When i.MIECHV_Race_Asian is not null Then i.MIECHV_Race_Asian
				 End,

	Race_Black = Case When (i.MIECHV_Hispanic = 0 and i.MIECHV_Race_AmericanIndian = 0 and i.MIECHV_Race_Asian = 0 and
							i.MIECHV_Race_Black = 0 and i.MIECHV_Race_Hawaiian = 0 and i.MIECHV_Race_White = 0)
							Or i.MIECHV_Race_Black is null 
							Then Case When Race = '02' Then 1 Else 0 End

					  When i.MIECHV_Race_Black is not null Then i.MIECHV_Race_Black
				 End,

	--No PC.Race value for hawaii so just grab MIECHV
	Race_Hawaiian = i.MIECHV_Race_Hawaiian,

	Race_Hispanic = Case When (i.MIECHV_Hispanic = 0 and i.MIECHV_Race_AmericanIndian = 0 and i.MIECHV_Race_Asian = 0 and
							i.MIECHV_Race_Black = 0 and i.MIECHV_Race_Hawaiian = 0 and i.MIECHV_Race_White = 0)
							Or i.MIECHV_Hispanic is null 
							Then Case When Race = '03' Then 1 Else 0 End

						 When i.MIECHV_Hispanic is not null Then
								Case When i.MIECHV_Hispanic = '1' Then 1
									 When i.MIECHV_Hispanic = '0' Then 0
						 End						
					End,

	Race_White = Case When (i.MIECHV_Hispanic = 0 and i.MIECHV_Race_AmericanIndian = 0 and i.MIECHV_Race_Asian = 0 and
							i.MIECHV_Race_Black = 0 and i.MIECHV_Race_Hawaiian = 0 and i.MIECHV_Race_White = 0)
						    Or i.MIECHV_Race_White is null Then
							Case When Race = '01' Then 1 Else 0 End

				      When i.MIECHV_Race_White is not null Then i.MIECHV_Race_White
				 End,

	Race_Other = Case When Race = '06' Or Race = '07' Then 1 Else 0 End

from PC
inner join HVCase hc on hc.PC1FK = pc.PCPK
inner join Intake i on  i.HVCaseFK = hc.HVCasePK


update TCID
set Race_AmericanIndian = Case When (MIECHV_Hispanic = 0 and MIECHV_Race_AmericanIndian = 0 and MIECHV_Race_Asian = 0 and
									MIECHV_Race_Black = 0 and MIECHV_Race_Hawaiian = 0 and MIECHV_Race_White = 0) 
									Or MIECHV_Race_AmericanIndian is null
							   Then Case When Race = '05' Then 1 Else 0 End

							   When MIECHV_Race_AmericanIndian is not null Then MIECHV_Race_AmericanIndian
						  End,

	Race_Asian = Case When (MIECHV_Hispanic = 0 and MIECHV_Race_AmericanIndian = 0 and MIECHV_Race_Asian = 0 and
							MIECHV_Race_Black = 0 and MIECHV_Race_Hawaiian = 0 and MIECHV_Race_White = 0) 
							Or MIECHV_Race_Asian is null
					  Then Case When Race = '04' Then 1 Else 0 End

					  When MIECHV_Race_Asian is not null Then MIECHV_Race_Asian
				 End,

	Race_Black = Case When (MIECHV_Hispanic = 0 and MIECHV_Race_AmericanIndian = 0 and MIECHV_Race_Asian = 0 and
							MIECHV_Race_Black = 0 and MIECHV_Race_Hawaiian = 0 and MIECHV_Race_White = 0)
							Or MIECHV_Race_Black is null 
							Then Case When Race = '02' Then 1 Else 0 End

					  When MIECHV_Race_Black is not null Then MIECHV_Race_Black
				 End,

	Race_Hawaiian = MIECHV_Race_Hawaiian,

	Race_White = Case When (MIECHV_Hispanic = 0 and MIECHV_Race_AmericanIndian = 0 and MIECHV_Race_Asian = 0 and
							MIECHV_Race_Black = 0 and MIECHV_Race_Hawaiian = 0 and MIECHV_Race_White = 0)
						    Or MIECHV_Race_White is null Then
							Case When Race = '01' Then 1 Else 0 End

				      When MIECHV_Race_White is not null Then MIECHV_Race_White
				 End,

	Race_Hispanic = Case When (MIECHV_Hispanic = 0 and MIECHV_Race_AmericanIndian = 0 and MIECHV_Race_Asian = 0 and
							MIECHV_Race_Black = 0 and MIECHV_Race_Hawaiian = 0 and MIECHV_Race_White = 0)
							Or MIECHV_Hispanic is null 
							Then Case When Race = '03' Then 1 Else 0 End

						 When MIECHV_Hispanic is not null Then
								Case When MIECHV_Hispanic = '1' Then 1
									 When MIECHV_Hispanic = '0' Then 0
						 End						
					End,

	Race_Other = Case When Race = '06' Or Race = '07' Then 1 Else 0 End
GO
