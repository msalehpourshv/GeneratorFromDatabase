USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 94/04/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [prs].[SpVacation]
	@ProcessID			int,
	@ToMonthCode		TinyInt,
	@FromPersonnelID	VARCHAR(20),
	@ToPersonnelID		VARCHAR(20),
	@Daily				TinyInt,
	@SaveAllVacation	bit	
WITH ENCRYPTION
AS
BEGIN 

	Declare @DailyMin  int ;
	Declare  @prsCalcVacationRedemptionWithMin as  bit
  
 select @DailyMin  = prs.funGetMinutes(SettingValue) from pub.tblSettings
 where SettingKey='DailyLeaveHours'
 
DECLARE @SQLString NVarChar(4000);

SELECT     PersonnelID, LeaveDay  Leave, LeaveDay  MaxLeave,LeaveDay  CeleLeave , LeaveDay  RemainLeave , LeaveDay MonthlyFunction, LeaveDay InsuranceFunction
	into  #tblPrs22
FROM prs.tblFunctionsDtl where 1=0

SELECT     PersonnelID, LeaveDay,  LeaveTime  
	into  #tblPrs2
FROM prs.tblFunctionsDtl where 1=0

SELECT     PersonnelID, LeaveDay,  LeaveTime  ,LeaveDay SaveDay ,  LeaveTime SaveTime 
	into  #tblPrs3
FROM prs.tblFunctionsDtl where 1=0


set @SQLString='330@ ' + str(@ToMonthCode) + '@'+ @FromPersonnelID +'@'+ @ToPersonnelID +'@1'

insert into #tblPrs22
exec prs.RptVacationMins  @SQLString

--select * from #tblPrs22

insert into #tblPrs2
Select PersonnelID
 ,  Floor(RemainLeave/@DailyMin)    LeaveDay 
 ,RemainLeave -Floor(RemainLeave/@DailyMin) * @DailyMin    
 from #tblPrs22
 
--Select * ,0 SaveDay,0 SaveTime from #tblPrs2
----------------------------------------------------------------------------
	if @SaveAllVacation='true'
	begin
		if @Daily=0
			insert into #tblPrs3(PersonnelID,LeaveDay,LeaveTime,SaveDay,SaveTime)	
				select PersonnelID
				,case  when  LeaveDay<0 then  LeaveDay else 0  end as LeaveDay
				,case  when  LeaveTime<0 then  LeaveTime else 0 end  LeaveTime		
				,case  when  LeaveDay<0 then  0 else LeaveDay  end as SaveDay
				,case  when  LeaveTime<0 then  0 else LeaveTime end  SaveTime		
				from #tblPrs2
		else
			insert into #tblPrs3(PersonnelID,LeaveDay,LeaveTime,SaveDay,SaveTime)	
			select PersonnelID
				,case  when  LeaveDay<=0 then  LeaveDay else case  when  LeaveDay<@Daily then  0   else case  when  LeaveDay>=@Daily then  LeaveDay-@Daily   else 0 end  end end  as LeaveDay
				,case  when  LeaveDay<=0 then  LeaveTime else case  when  LeaveDay<@Daily then  0 else case  when  LeaveDay>=@Daily then  LeaveTime   else 0 end end end as LeaveTime
				,case  when  LeaveDay<=0 then  0 else case  when  LeaveDay>=@Daily then  @Daily   else LeaveDay end end SaveDay
				,case  when  LeaveTime<=0 then  0 else case  when  LeaveDay<@Daily then  LeaveTime else case  when  LeaveDay>=@Daily then  0   else 0 end end end  as SaveTime
				from #tblPrs2	
	end 
	else --	if @SaveAllVacation='False'
	begin
		if @Daily=0
			insert into #tblPrs3(PersonnelID,LeaveDay,LeaveTime,SaveDay,SaveTime)	
			Select PersonnelID,LeaveDay,LeaveTime ,0,0 from #tblPrs2	
		else
		insert into #tblPrs3(PersonnelID,LeaveDay,LeaveTime,SaveDay,SaveTime)	
			select PersonnelID,  
					case  when  LeaveDay<0 then  LeaveDay else case  when  LeaveDay>=@Daily then  LeaveDay-@Daily   else 0 end end  as LeaveDay
					, LeaveTime
					,case  when  LeaveDay<0 then  0 else case  when  LeaveDay>=@Daily then  @Daily   else LeaveDay end end ,0
				from #tblPrs2			
	end 
	------------------------------------------------------------------------------------------
select @prsCalcVacationRedemptionWithMin   = SettingValue from pub.tblSettings
 where SettingKey='prsCalcVacationRedemptionWithMin'
 
--		Select @prsCalcVacationRedemptionWithMin,@DailyMin
if @prsCalcVacationRedemptionWithMin=1  
	update #tblPrs3 Set LeaveTime=LeaveTime+LeaveDay*@DailyMin  , LeaveDay=0,SaveTime=SaveTime+SaveDay*@DailyMin  , SaveDay=0

	update #tblPrs3 Set SaveDay=0 where SaveDay<0

Select *  from #tblPrs3
end
GO
