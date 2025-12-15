USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/09/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE prs.RptVacationMins
	@ExtraParams		NVarChar(Max) = ''
	
WITH ENCRYPTION
AS

BEGIN 

declare 
	@ProcessID			int,
	@MonthCode			int,
	@FromPersonnelID	VARCHAR(20),
	@ToPersonnelID		VARCHAR(20),
	@Daily				int,
	@CountQuitDate		TinyInt = 0
	
	DECLARE @SQLString NVarChar(4000);
	DECLARE @StrWhere  NVarChar(4000);
	
	SET @ProcessID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @MonthCode			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @FromPersonnelID	    = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @ToPersonnelID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @CountQuitDate		    = LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
	
	if @ProcessID=0
	set @ProcessID=330
	
	if @FromPersonnelID is null
	set @FromPersonnelID=''
	if @ToPersonnelID is null
	set @ToPersonnelID=''

set @StrWhere = ' where  a.MonthCode=' + LTrim(RTrim(str(@MonthCode)))

if @FromPersonnelID<>''
set @StrWhere = @StrWhere+' and  a.PersonnelID>='''+ LTrim(RTrim(@FromPersonnelID)) +''' ' 

if @ToPersonnelID<>''
set @StrWhere =@StrWhere+ ' and a.PersonnelID<='''+ LTrim(RTrim(@ToPersonnelID)) +''' '

Declare @DailyMin  int ;
Declare  @RedeemedVacation as int
  
select @DailyMin  = prs.funGetMinutes(SettingValue) from pub.tblSettings
 where SettingKey='DailyLeaveHours'

 select @RedeemedVacation  = SettingValue from pub.tblSettings
 where SettingKey='RedeemedVacation'

	if @DailyMin  =0
		set @DailyMin=440
	
--drop table  #tblPrsVacation
SELECT     PersonnelID, LeaveDay,  LeaveTime  ,  MonthCode  , LeaveDay MonthlyFunction, LeaveDay InsuranceFunction
	into #tblPrsVacation
FROM prs.tblFunctionsDtl where 1=0

SELECT     PersonnelID, LeaveDay,  LeaveTime  ,  MonthCode
	into #tblPrsVacation2
FROM prs.tblFunctionsDtl where 1=0

SELECT     PersonnelID, LeaveDay,  LeaveTime  ,  MonthCode
	into #tblPrsVacationMax
FROM prs.tblFunctionsDtl where 1=0
	
insert into #tblPrsVacation2
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 1 MonthCode
FROM prs.tblFunctionsDtl where MonthCode=1  group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 2 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=2   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 3 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=3   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  ,4 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=4   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 5 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=5   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 6 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=6   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 7 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=7   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 8 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=8   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 9 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=9   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 10 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=10   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 11 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=11   group by PersonnelID
union all
SELECT     PersonnelID, SUM(RedeemedVacationDays) AS LeaveDay,  SUM(prs.funGetMinutes(RedeemedVacationTime)) as LeaveTime  , 12 MonthCode
FROM prs.tblFunctionsDtl where MonthCode<=12   group by PersonnelID


insert into #tblPrsVacation
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 1 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode=1   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 2 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=2   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 3 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=3   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  ,4 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=4   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 5 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=5   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 6 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=6   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 7 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=7   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 8 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=8   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 9 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=9   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 10 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=10   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 11 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=11   group by PersonnelID
union all
SELECT     PersonnelID, SUM(LeaveDay) AS LeaveDay,  SUM(prs.funGetMinutes(LeaveTime)) as LeaveTime  , 12 MonthCode, Sum(MonthlyFunction) MonthlyFunction, Sum(InsuranceFunction) InsuranceFunction
FROM prs.tblFunctionsDtl where MonthCode<=12   group by PersonnelID

if @CountQuitDate = 0
begin
insert into #tblPrsVacationMax
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))	LeaveTime, 1 MonthCode
FROM         emp.tblVacationMaxDtl 	
Group by PersonnelID 
union all
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))	LeaveTime, 2 MonthCode
	FROM         emp.tblVacationMaxDtl	
	Group by PersonnelID
union all	
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))
	LeaveTime, 3 MonthCode
	FROM         emp.tblVacationMaxDtl	
	Group by PersonnelID
union all	
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))
+SUM(prs.funGetMinutes(MonthT4))	LeaveTime, 4 MonthCode
	FROM         emp.tblVacationMaxDtl	
	Group by PersonnelID
union all
	
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))+SUM(prs.funGetMinutes(MonthT4))
+SUM(prs.funGetMinutes(MonthT5)) 	LeaveTime, 5 MonthCode
	FROM         emp.tblVacationMaxDtl
	Group by PersonnelID
union all
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5)+sum( Month6)LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))
+SUM(prs.funGetMinutes(MonthT4))+SUM(prs.funGetMinutes(MonthT5))+SUM(prs.funGetMinutes(MonthT6))	LeaveTime, 6 MonthCode
	FROM         emp.tblVacationMaxDtl	
	Group by PersonnelID
union all	
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5)+sum( Month6)+sum( Month7) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))
+SUM(prs.funGetMinutes(MonthT4))+SUM(prs.funGetMinutes(MonthT5))+SUM(prs.funGetMinutes(MonthT6))+SUM(prs.funGetMinutes(MonthT7))	LeaveTime, 7 MonthCode
	FROM         emp.tblVacationMaxDtl
	Group by PersonnelID
union all	
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5)+sum( Month6)+sum( Month7)+sum( Month8)
LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))
+SUM(prs.funGetMinutes(MonthT4))+SUM(prs.funGetMinutes(MonthT5))+SUM(prs.funGetMinutes(MonthT6))+SUM(prs.funGetMinutes(MonthT7))
+SUM(prs.funGetMinutes(MonthT8))	LeaveTime, 8 MonthCode
	FROM         emp.tblVacationMaxDtl
	Group by PersonnelID
union all	
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5)+sum( Month6)+sum( Month7)+sum( Month8)
+sum( Month9) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))+SUM(prs.funGetMinutes(MonthT4))+SUM(prs.funGetMinutes(MonthT5))+SUM(prs.funGetMinutes(MonthT6))+SUM(prs.funGetMinutes(MonthT7))+SUM(prs.funGetMinutes(MonthT8))
+SUM(prs.funGetMinutes(MonthT9))	LeaveTime, 9 MonthCode
	FROM         emp.tblVacationMaxDtl
	Group by PersonnelID
union all
SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5)+sum( Month6)+sum( Month7)+sum( Month8)
+sum( Month9)+sum( Month10) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))+SUM(prs.funGetMinutes(MonthT4))+SUM(prs.funGetMinutes(MonthT5))+SUM(prs.funGetMinutes(MonthT6))+SUM(prs.funGetMinutes(MonthT7))+SUM(prs.funGetMinutes(MonthT8))
+SUM(prs.funGetMinutes(MonthT9))+SUM(prs.funGetMinutes(MonthT10))
	LeaveTime, 10 MonthCode
	FROM         emp.tblVacationMaxDtl
	Group by PersonnelID
union all
	SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5)+sum( Month6)+sum( Month7)+sum( Month8)
+sum( Month9)+sum( Month10)+sum( Month11) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))+SUM(prs.funGetMinutes(MonthT4))+SUM(prs.funGetMinutes(MonthT5))+SUM(prs.funGetMinutes(MonthT6))+SUM(prs.funGetMinutes(MonthT7))+SUM(prs.funGetMinutes(MonthT8))
+SUM(prs.funGetMinutes(MonthT9))+SUM(prs.funGetMinutes(MonthT10))+SUM(prs.funGetMinutes(MonthT11))
	LeaveTime, 11 MonthCode
	FROM         emp.tblVacationMaxDtl
	Group by PersonnelID
union all
	SELECT      PersonnelID,sum(LastYearRemain)+sum( Month1)+sum( Month2)+sum( Month3)+sum( Month4)+sum( Month5)+sum( Month6)+sum( Month7)+sum( Month8)
+sum( Month9)+sum( Month10)+sum( Month11)+sum( Month12) LeaveDay
,sum(prs.funGetMinutes(LastYearRemainT))+SUM(prs.funGetMinutes(MonthT1))+SUM(prs.funGetMinutes(MonthT2))+SUM(prs.funGetMinutes(MonthT3))+SUM(prs.funGetMinutes(MonthT4))+SUM(prs.funGetMinutes(MonthT5))+SUM(prs.funGetMinutes(MonthT6))+SUM(prs.funGetMinutes(MonthT7))+SUM(prs.funGetMinutes(MonthT8))
+SUM(prs.funGetMinutes(MonthT9))+SUM(prs.funGetMinutes(MonthT10))+SUM(prs.funGetMinutes(MonthT11))+SUM(prs.funGetMinutes(MonthT12))	LeaveTime, 12 MonthCode
	FROM         emp.tblVacationMaxDtl
		Group by PersonnelID
end
if @CountQuitDate = 1
begin
insert into #tblPrsVacationMax
SELECT      VM.PersonnelID,
	sum(LastYearRemain) + Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '01' then sum( Month1) else 0 end as LeaveDay
	,sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '01' then SUM(prs.funGetMinutes(MonthT1)) else 0 end as LeaveTime,
	1 MonthCode
FROM         emp.tblVacationMaxDtl  VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
Group by VM.PersonnelID , QuitJobDate
union all
SELECT     VM.PersonnelID, 
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02')  then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '02' then sum( Month2) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT)) + Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											  Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '02' then SUM(prs.funGetMinutes(MonthT2)) else 0 end as LeaveTime,
	2 MonthCode
	FROM         emp.tblVacationMaxDtl	VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all	
SELECT      VM.PersonnelID, 
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '03' then sum( Month3) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '03' then SUM(prs.funGetMinutes(MonthT3)) else 0 end  as LeaveTime,
	3 MonthCode
	FROM         emp.tblVacationMaxDtl	VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all	
SELECT      VM.PersonnelID,
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '04' then sum( Month4) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '04' then SUM(prs.funGetMinutes(MonthT4)) else 0 end as LeaveTime,
	4 MonthCode
	FROM         emp.tblVacationMaxDtl	VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all
	
SELECT      VM.PersonnelID,
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '05' then sum( Month5) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '05' then SUM(prs.funGetMinutes(MonthT5)) else 0 end as	LeaveTime, 
	5 MonthCode
	FROM         emp.tblVacationMaxDtl VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all
SELECT     VM. PersonnelID, 
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05','06') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05','06') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05','06') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('05','06') then sum( Month5) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '06' then sum( Month6) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05','06') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05','06') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05','06') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('05','06') then SUM(prs.funGetMinutes(MonthT5)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '06' then SUM(prs.funGetMinutes(MonthT6)) else 0 end as	LeaveTime, 
	6 MonthCode
	FROM         emp.tblVacationMaxDtl	VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all	
SELECT     VM.PersonnelID,
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05','06','07') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05','06','07') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('05','06','07') then sum( Month5) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('06','07') then sum( Month6) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '07' then sum( Month7) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05','06','07') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05','06','07') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('05','06','07') then SUM(prs.funGetMinutes(MonthT5)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('06','07') then SUM(prs.funGetMinutes(MonthT6)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '07' then SUM(prs.funGetMinutes(MonthT7)) else 0 end as	LeaveTime, 
	7 MonthCode
	FROM         emp.tblVacationMaxDtl VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all	
SELECT      VM.PersonnelID, 
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05','06','07','08') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('05','06','07','08') then sum( Month5) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('06','07','08') then sum( Month6) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('07','08') then sum( Month7) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '08' then sum( Month8) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05','06','07','08') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('05','06','07','08') then SUM(prs.funGetMinutes(MonthT5)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('06','07','08') then SUM(prs.funGetMinutes(MonthT6)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('07','08') then SUM(prs.funGetMinutes(MonthT7)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '08' then SUM(prs.funGetMinutes(MonthT8)) else 0 end as	LeaveTime, 
	8 MonthCode
	FROM         emp.tblVacationMaxDtl VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all	
SELECT      VM.PersonnelID,
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('05','06','07','08','09') then sum( Month5) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('06','07','08','09') then sum( Month6) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('07','08','09') then sum( Month7) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('08','09') then sum( Month8) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '09' then sum( Month9) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('05','06','07','08','09') then SUM(prs.funGetMinutes(MonthT5)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('06','07','08','09') then SUM(prs.funGetMinutes(MonthT6)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('07','08','09') then SUM(prs.funGetMinutes(MonthT7)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('08','09') then SUM(prs.funGetMinutes(MonthT8)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '09' then SUM(prs.funGetMinutes(MonthT9)) else 0 end as	LeaveTime, 9 MonthCode
	FROM         emp.tblVacationMaxDtl VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all
SELECT      VM.PersonnelID,
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09','10') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09','10') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09','10') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09','10') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('05','06','07','08','09','10') then sum( Month5) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('06','07','08','09','10') then sum( Month6) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('07','08','09','10') then sum( Month7) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('08','09','10') then sum( Month8) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('09','10') then sum( Month9) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '10' then sum( Month10) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09','10') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09','10') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09','10') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09','10') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('05','06','07','08','09','10') then SUM(prs.funGetMinutes(MonthT5)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('06','07','08','09','10') then SUM(prs.funGetMinutes(MonthT6)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('07','08','09','10') then SUM(prs.funGetMinutes(MonthT7)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('08','09','10') then SUM(prs.funGetMinutes(MonthT8)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('09','10') then SUM(prs.funGetMinutes(MonthT9)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '10' then SUM(prs.funGetMinutes(MonthT10))else 0 end as	LeaveTime,
	10 MonthCode
	FROM         emp.tblVacationMaxDtl VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all
SELECT      VM.PersonnelID,
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09','10','11') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09','10','11') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09','10','11') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09','10','11') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('05','06','07','08','09','10','11') then sum( Month5) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('06','07','08','09','10','11') then sum( Month6) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('07','08','09','10','11') then sum( Month7) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('08','09','10','11') then sum( Month8) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('09','10','11') then sum( Month9) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('10','11') then sum( Month10) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '11' then sum( Month11) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09','10','11') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09','10','11') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09','10','11') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09','10','11') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('05','06','07','08','09','10','11') then SUM(prs.funGetMinutes(MonthT5)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('06','07','08','09','10','11') then SUM(prs.funGetMinutes(MonthT6)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('07','08','09','10','11') then SUM(prs.funGetMinutes(MonthT7)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('08','09','10','11') then SUM(prs.funGetMinutes(MonthT8)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('09','10','11') then SUM(prs.funGetMinutes(MonthT9)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('10','11') then SUM(prs.funGetMinutes(MonthT10))else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '11' then SUM(prs.funGetMinutes(MonthT11)) else 0 end as LeaveTime, 
	11 MonthCode
	FROM         emp.tblVacationMaxDtl VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
	Group by VM.PersonnelID, QuitJobDate
union all
SELECT      VM.PersonnelID,
	sum(LastYearRemain)+ Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09','10','11','12') then sum( Month1) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09','10','11','12') then sum( Month2) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09','10','11','12') then sum( Month3) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09','10','11','12') then sum( Month4) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('05','06','07','08','09','10','11','12') then sum( Month5) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('06','07','08','09','10','11','12') then sum( Month6) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('07','08','09','10','11','12') then sum( Month7) else 0 end + 
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('08','09','10','11','12') then sum( Month8) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('09','10','11','12') then sum( Month9) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('10','11','12') then sum( Month10) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) in ('11','12') then sum( Month11) else 0 end +
						 Case when subString(QuitJobDate,6,2) = '' or subString(QuitJobDate,6,2) = '12' then sum( Month12) else 0 end as LeaveDay,
	sum(prs.funGetMinutes(LastYearRemainT))+ Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('01','02','03','04','05','06','07','08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT1)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('02','03','04','05','06','07','08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT2)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('03','04','05','06','07','08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT3)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('04','05','06','07','08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT4)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('05','06','07','08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT5)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('06','07','08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT6)) else 0 end + 
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('07','08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT7)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('08','09','10','11','12') then SUM(prs.funGetMinutes(MonthT8)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('09','10','11','12') then SUM(prs.funGetMinutes(MonthT9)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('10','11','12') then SUM(prs.funGetMinutes(MonthT10))else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) in ('11','12') then SUM(prs.funGetMinutes(MonthT11)) else 0 end +
											 Case when subString(QuitJobDate,6,2) = 0 or subString(QuitJobDate,6,2) = '12' then SUM(prs.funGetMinutes(MonthT12)) else 0 end as LeaveTime, 
	12 MonthCode
	FROM         emp.tblVacationMaxDtl VM
	Left join prs.tblPersonnels P On P.PersonnelID = VM.PersonnelID		
		Group by VM.PersonnelID, QuitJobDate
end
				
set @SQLString='
select a.PersonnelID
,isnull(a.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + a.LeaveTime ,0 ) Leave
,isnull(b.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + b.LeaveTime ,0 )  MaxLeave
,isnull(c.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + c.LeaveTime ,0 )  CeleLeave
,isnull((b.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + b.LeaveTime ) ,0 ) -isnull((a.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + a.LeaveTime) ,0 ) -isnull((c.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + c.LeaveTime) ,0 )  RemainLeave 
,MonthlyFunction,InsuranceFunction
from #tblPrsVacation a
inner join #tblPrsVacationMax b on a.PersonnelID= b.PersonnelID and a.MonthCode=b.MonthCode
left Join  #tblPrsVacation2 c on a.PersonnelID= c.PersonnelID and a.MonthCode=c.MonthCode
'+@StrWhere
	
	print @SQLString
	EXECUTE sp_executesql @SQLString
	
end
GO
