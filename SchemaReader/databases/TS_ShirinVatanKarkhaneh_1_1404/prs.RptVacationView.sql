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
Create PROCEDURE prs.RptVacationView
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS

BEGIN 

DECLARE @ProcessID			int
DECLARE @FromMonthCode		TinyInt
DECLARE @ToMonthCode		TinyInt	
DECLARE @FromPersonnelID	VARCHAR(20)
DECLARE @ToPersonnelID		VARCHAR(20)
DECLARE @Daily				TinyInt	
DECLARE @SQLString			NVarChar(4000)
DECLARE @StrWhere			NVarChar(4000)
DECLARE @DailyMin			int 
DECLARE @DailyRVMin			int 
DECLARE @RedeemedVacation	int
DECLARE @StrSort			NVarChar(4000)
DECLARE @TimeFr				VARCHAR(7)
DECLARE @TimeTo				VARCHAR(7)
DECLARE @FromTime			int
DECLARE @ToTime				int
DECLARE @FromDay			Int
DECLARE @ToDay				int
DECLARE @TimeMines			bit
DECLARE @DayMines			bit
DECLARE @Mines				bit
DECLARE @Plus				bit
DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int; 
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		bit;
DECLARE	@CountQuitDate		TinyInt;
	
	SET @ProcessID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @FromMonthCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @ToMonthCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @FromPersonnelID	    = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @ToPersonnelID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @StrSort				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
	SET @TimeFr					= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @TimeTo					= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @TimeMines				= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 
	SET @FromDay				= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
	SET @ToDay					= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
	SET @DayMines				= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
	SET @Mines					= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
	SET @Plus					= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
	SET @CountQuitDate			= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
	
--	SET @Daily		    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		= pub.funSplitString(@RepInfo, '@', 5); 

	set @FromTime=prs.funGetMinutes(@TimeFr)
	set @ToTime=prs.funGetMinutes(@TimeTo)
	if @TimeMines='true'
	  begin
		set @FromTime=@FromTime*-1
		set @ToTime=@ToTime*-1
	end 
	if @DayMines='true'
	  begin
		set @FromDay=@FromDay*-1
		set @ToDay=@ToDay*-1
	end 

	set @StrWhere=''

	if @FromTime>0
		set @StrWhere+=' and minRemainLeave>=' + str(@FromTime)
	if @ToTime>0
		set @StrWhere+=' and minRemainLeave<=' + str(@ToTime)

	if @FromDay>0
		set @StrWhere+=' and DaysRemainLeave>=' + str(@FromDay)
	if @ToDay>0
		set @StrWhere+=' and DaysRemainLeave<=' + str(@ToDay)


	if @FromTime<0
		set @StrWhere+=' and minRemainLeave<=' + str(@FromTime)
	if @ToTime<0
		set @StrWhere+=' and minRemainLeave>=' + str(@ToTime)

	if @FromDay<0
		set @StrWhere+=' and DaysRemainLeave<=' + str(@FromDay)
	if @ToDay<0
		set @StrWhere+=' and DaysRemainLeave>=' + str(@ToDay)

		
	if @Mines='true'
		set @StrWhere+=' and (DaysRemainLeave<0 or minRemainLeave<0)'
	if @Plus='true'
		set @StrWhere+=' and (DaysRemainLeave>0 or minRemainLeave>0)'
		
---------------------------------------
	if @UserIsAdmin=0 and (select count(*) from prs.tblPersonnelsRng) >0
	begin
		--If (@ExternalCall = 0) 
		begin
			BEGIN TRY
				DROP TABLE #Personnel
			END TRY
			BEGIN CATCH
			END CATCH
		END
		CREATE TABLE #Personnel
		(
			PersonnelID 			Varchar(20)collate arabic_cs_as null
		)
	
		Insert into  #Personnel (PersonnelID)	SELECT Distinct PersonnelID from prs.tblPersonnels
	 
		exec pub.SpFilterByPermission2 '#Personnel@1', 'PersonnelID', 'prs.tblPersonnels', @UserID;
		
		SET @StrWhere =   @StrWhere +' and a.PersonnelID in (SELECT PersonnelID FROM  #Personnel ) '

	END
	-----------------------------------------

--select @TimeFr,@TimeTo,@FromDay,@ToDay
--select @FromTime,@ToTime,@FromDay,@ToDay
--select @StrWhere

	if @ProcessID=0
		set @ProcessID=330
	
	if @FromMonthCode=0
		set @FromMonthCode=1	
	
	if @FromPersonnelID is null
		set @FromPersonnelID=''
	if @ToPersonnelID is null
		set @ToPersonnelID=''
	--- ایجاد جداول  temp
	SELECT     PersonnelID, LeaveDay  Leave, LeaveDay  MaxLeave,LeaveDay  CeleLeave , LeaveDay  RemainLeave , LeaveDay MonthlyFunction, LeaveDay InsuranceFunction
		into  #tblPrsFrom
	FROM prs.tblFunctionsDtl where 1=0

	SELECT     PersonnelID, LeaveDay  Leave, LeaveDay  MaxLeave,LeaveDay  CeleLeave , LeaveDay  RemainLeave , LeaveDay MonthlyFunction, LeaveDay InsuranceFunction
	into  #tblPrsFromTo
	FROM prs.tblFunctionsDtl where 1=0

	SELECT     PersonnelID, LeaveDay  Leave, LeaveDay  MaxLeave,LeaveDay  CeleLeave , LeaveDay  RemainLeave , LeaveDay MonthlyFunction, LeaveDay InsuranceFunction
		into  #tblPrsTo
	FROM prs.tblFunctionsDtl where 1=0

---   دریافت اطلاعات مرخصی ها به دقیقه برای از ماه  تا ماه 
	set @SQLString='330@ ' + str(@FromMonthCode-1) + '@'+ @FromPersonnelID +'@'+ @ToPersonnelID +'@1'+'@'+LTrim(RTrim(str(@CountQuitDate)))

	insert into #tblPrsFrom
	exec prs.RptVacationMins  @SQLString
--select @SQLString
	set @SQLString='330@ ' + str(@ToMonthCode) + '@'+ @FromPersonnelID +'@'+ @ToPersonnelID +'@1'+'@'+LTrim(RTrim(str(@CountQuitDate)))

	insert into #tblPrsTo
	exec prs.RptVacationMins  @SQLString
--select @SQLString
---  تفاضل اطلاعات از ماه تا ماه
	insert into #tblPrsFromTo
	select 	a.PersonnelID, isnull(a.Leave,0)-isnull(b.Leave,0), isnull(a.MaxLeave,0)-isnull(b.MaxLeave,0), isnull(a.CeleLeave,0)-isnull(b.CeleLeave,0)
	, isnull(a.RemainLeave,0)-isnull(b.RemainLeave,0), isnull(a.MonthlyFunction,0)-isnull(b.MonthlyFunction,0), isnull(a.InsuranceFunction,0)-isnull(b.InsuranceFunction,0)	
	from #tblPrsTo  a left join  #tblPrsFrom  b
	on a.PersonnelID=b.PersonnelID
  
	select @DailyMin  = prs.funGetMinutes(SettingValue) from pub.tblSettings
	where SettingKey='DailyLeaveHours'
	
	select @DailyRVMin  = prs.funGetMinutes(SettingValue) from pub.tblSettings
	where SettingKey='DailyRedeemedVacationHours'
	if @DailyRVMin=0
	set @DailyRVMin=@DailyMin

	select @RedeemedVacation  = SettingValue from pub.tblSettings
	where SettingKey='RedeemedVacation'

	if @DailyMin  =0
		set @DailyMin=440
	--ایجاد جداول نهایی
--drop table  #tblPrsVacation
	SELECT     PersonnelID, LeaveDay,  LeaveTime  ,  MonthCode FromMonthCode, MonthCode   , LeaveDay MonthlyFunction, LeaveDay InsuranceFunction
		into #tblPrsVacation
	FROM prs.tblFunctionsDtl where 1=0

	SELECT     PersonnelID, LeaveDay,  LeaveTime  ,  MonthCode FromMonthCode, MonthCode  MonthCode,PeriodWork001 RedeemedVacationAmount
		into #tblPrsVacation2
	FROM prs.tblFunctionsDtl where 1=0

	SELECT     PersonnelID, LeaveDay,  LeaveTime  ,  MonthCode FromMonthCode, MonthCode
		into #tblPrsVacationMax
	FROM prs.tblFunctionsDtl where 1=0

--SELECT     PersonnelID, LeaveDay  Leave, LeaveDay  MaxLeave,LeaveDay  CeleLeave , LeaveDay  RemainLeave 

---ورود اطلاعات از جدول temp 
	insert into #tblPrsVacationMax
	select 	PersonnelID, floor(MaxLeave/@DailyMin), MaxLeave- (floor(MaxLeave/@DailyMin)*@DailyMin),@FromMonthCode,@ToMonthCode
	from #tblPrsFromTo  	
	
	insert into #tblPrsVacation
	select PersonnelID, floor(Leave/@DailyMin), Leave- (floor(Leave/@DailyMin)*@DailyMin),@FromMonthCode,@ToMonthCode,MonthlyFunction	,InsuranceFunction
	from #tblPrsFromTo  
	
	insert into #tblPrsVacation2
	select PersonnelID, floor(CeleLeave/@DailyMin), CeleLeave- (floor(CeleLeave/@DailyMin)*@DailyMin),@FromMonthCode,@ToMonthCode,0
	from #tblPrsFromTo  
	
	update 		 #tblPrsVacation2
	set RedeemedVacationAmount =isnull((
		select  sum(RedeemedVacationAmount) from  prs.tblSalaryCalculation
		where #tblPrsVacation2.PersonnelID = prs.tblSalaryCalculation.PersonnelID
			and prs.tblSalaryCalculation.MonthCode between @FromMonthCode and @ToMonthCode),0)
	
	--select * from #tblPrsFromTo
	--select * from #tblPrsVacationMax
	--select * from #tblPrsVacation
	--select * from #tblPrsVacation2
 -----------------------------------------
 Declare @Name as Varchar(200)=''
 Declare @Benefits as Varchar(200)='0+'
 
	DECLARE CSR_B1 CURSOR FOR
	select   'Benefit'+BenefitID from  prs.tblBenefits1  where  IsVacationRedemption=1
	
	OPEN CSR_B1
	FETCH NEXT FROM CSR_B1 INTO  @Name

	WHILE @@fetch_status = 0
	BEGIN	
		set @Benefits=@Benefits+@Name+'+'
		FETCH NEXT FROM CSR_B1 INTO @Name
	END
	CLOSE CSR_B1
	DEALLOCATE CSR_B1
 
	set @Benefits=substring(@Benefits,1,len(@Benefits)-1)
 --Select @Benefits 
	
	set @SQLString='
	Select prs.funGetPersonnelName(a.PersonnelID,1) PersonnelName  ,  a.* 
	,Case When   RemainLeave>=0   then 
	Floor(LeavePayBenefits*  DaysRemainLeave )+ Floor(LeavePayBenefits*  minRemainLeave/'+LTrim(RTrim(str(@DailyRVMin)))+' ) else 
	case '+LTrim(RTrim(str(@RedeemedVacation)))+' 
		when 0 then 0
		when 1 then Floor(Basepay * RemainLeave /'+LTrim(RTrim(str(@DailyMin)))+'  )
		when 2 then Floor(LeavePayBenefits * RemainLeave /'+LTrim(RTrim(str(@DailyMin)))+'  )
		when 3 then Floor(AbsenceBase * RemainLeave /'+LTrim(RTrim(str(@DailyMin)))+'  )
	end 
	end  Pay
	,prs.funGetHourMinutesStandard(minRemainLeave) minRemainLeaveH 
	from (
	Select a.*, Floor(RemainLeave/'+LTrim(RTrim(str(@DailyMin)))+') DaysRemainLeave  ,RemainLeave -( Floor(RemainLeave/'+LTrim(RTrim(str(@DailyMin)))+') *'+LTrim(RTrim(str(@DailyMin)))+')  minRemainLeave 
	, D.Basepay,D.LeavePay,D.AbsenceBase,'+LTrim(RTrim(str(@RedeemedVacation)))+'  RedeemedVacation
	,D.LeavePay + (' +LTrim(RTrim(@Benefits))+ ')/30  as LeavePayBenefits
	from (
	select a.PersonnelID, a.LeaveDay LeaveDayL , a.LeaveTime  LeaveTimeL ,prs.funGetHourMinutesStandard(a.LeaveTime) LeaveTimeLH
	,a.MonthCode ,a.MonthlyFunction, a.InsuranceFunction  
	, b.LeaveDay , b.LeaveTime ,prs.funGetHourMinutesStandard(b.LeaveTime) LeaveTimeH
	,a.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + a.LeaveTime Leave
	,b.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + b.LeaveTime MaxLeave 
	,c.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + c.LeaveTime CeleLeave 
	,c.LeaveDay CeleLeaveDay, c.LeaveTime  CeleLeaveTime ,prs.funGetHourMinutesStandard(c.LeaveTime) CeleLeaveTimeLH,c.RedeemedVacationAmount
	,(b.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + b.LeaveTime )-(a.LeaveDay* '+LTrim(RTrim(str(@DailyMin)))+' + a.LeaveTime )-(isnull(c.LeaveDay,0)* '+LTrim(RTrim(str(@DailyMin)))+' +isnull(c.LeaveTime ,0))  RemainLeave 
	from #tblPrsVacation a
	inner join #tblPrsVacationMax b on a.PersonnelID= b.PersonnelID and a.MonthCode=b.MonthCode
	left Join #tblPrsVacation2 c on a.PersonnelID= c.PersonnelID and a.MonthCode=c.MonthCode
	) a
	inner join 	
	(select PersonnelID, Max(SerialNo) SerialNo
		from prs.tblDecreeHdr
		group by PersonnelID
				) s on s.PersonnelID = a.PersonnelID 
			INNER JOIN prs.tblDecreeHdr D ON D.PersonnelID = s.PersonnelID AND D.SerialNo = s.SerialNo
	) a	
	where  1=1 '+ @StrWhere +'
	 order by   '+@StrSort
print @SQLString
EXECUTE sp_executesql @SQLString
	
end
GO
