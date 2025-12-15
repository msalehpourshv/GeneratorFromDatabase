USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/11/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [prs].[SpCelebration]
	@ProcessID			int,
	@ToMonthCode		TinyInt,
	@FromPersonnelID	VARCHAR(20),
	@ToPersonnelID		VARCHAR(20),
	@ToDate				VARCHAR(20),
	@ExtraParams		VARCHAR(200)
	
WITH ENCRYPTION
AS
BEGIN 

	declare @Year as int ;
	declare @EndMonthDays as int ;
	
	SET @EndMonthDays    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	if @EndMonthDays=1
		select @EndMonthDays=[pub].[FunGetMonthDay](Substring(@ToDate,1,4),12)
	
	select  @Year= substring(@ToDate,1,4)
	
	DECLARE @prs_UseInsuranceFunctionIFMonthlyFunctionZero bit
	SET @prs_UseInsuranceFunctionIFMonthlyFunctionZero  = 'False'	
	SELECT @prs_UseInsuranceFunctionIFMonthlyFunctionZero = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'prs_UseInsuranceFunctionIFMonthlyFunctionZero'

	DECLARE @HistoryCalcWithHireDate bit
	SET @HistoryCalcWithHireDate  = 'False'	
		
	SELECT @HistoryCalcWithHireDate = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'HistoryCalcWithHireDate'

	
	DECLARE @prs_HistoryCalcWithHireDateSumAllMonthlyFunction bit
	SET @prs_HistoryCalcWithHireDateSumAllMonthlyFunction  = 'False'	
		
	SELECT @prs_HistoryCalcWithHireDateSumAllMonthlyFunction = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'prs_HistoryCalcWithHireDateSumAllMonthlyFunction'

	DECLARE @prsVacationSubFromCelebrationHistoryCalcDays bit
	SET @prsVacationSubFromCelebrationHistoryCalcDays= 'False'	

	SELECT @prsVacationSubFromCelebrationHistoryCalcDays = SettingValue	FROM pub.tblSettings WHERE SettingKey = 'prsVacationSubFromCelebrationHistoryCalcDays'
	
	select  MonthCode ,MonthCode DayCount into #MonthDayCount from prs.tblCelebrationDtl where 1=0
	
	insert into  #MonthDayCount	select 1,[pub].[FunGetMonthDay](@Year,1)
	insert into  #MonthDayCount	select 2,[pub].[FunGetMonthDay](@Year,2)
	insert into  #MonthDayCount	select 3,[pub].[FunGetMonthDay](@Year,3)
	insert into  #MonthDayCount	select 4,[pub].[FunGetMonthDay](@Year,4)
	insert into  #MonthDayCount	select 5,[pub].[FunGetMonthDay](@Year,5)
	insert into  #MonthDayCount	select 6,[pub].[FunGetMonthDay](@Year,6)
	insert into  #MonthDayCount	select 7,[pub].[FunGetMonthDay](@Year,7)
	insert into  #MonthDayCount	select 8,[pub].[FunGetMonthDay](@Year,8)
	insert into  #MonthDayCount	select 9,[pub].[FunGetMonthDay](@Year,9)
	insert into  #MonthDayCount	select 10,[pub].[FunGetMonthDay](@Year,10)
	insert into  #MonthDayCount	select 11,[pub].[FunGetMonthDay](@Year,11)
	insert into  #MonthDayCount	select 12,[pub].[FunGetMonthDay](@Year,12)
		
	SELECT PersonnelID,cast(0 as Float )  SumMonthlyFunction ,cast(0 as int )  SumLeaveWithoutPay,cast(0 as int )  SumAbsence , cast(0 as int )  SumSickLeave
					, cast(0 as float ) SumCost , cast(0 as int ) SumMaxDays,cast(0 as int )  VacationRedemption
					------- جهت محاسبه و اضافه کردن مابه التفاوت محاسبه پایانکار در صورت تغییر مبلغ پایه حکم--------------
					,cast(0 as float )  SumCostNoPay,cast(0 as int )  SumMonthlyFunctionNoPay, Cast('' as Varchar (20)) AcntHistoryCalcDaysReserve
					 into #tblTmp 
			 FROM prs.tblFunctionsDtl ff WHERE 1=0					
	
	IF @ProcessID = 325 and @HistoryCalcWithHireDate = 'True'
		begin
		
		delete From prs.tblCelebrationLastDate
		delete From prs.tblAllFunctionsDtl

		DECLARE @StrTemp				NVARCHAR(2000)		
		Declare @DBName			VARCHAR(100)
		DECLARE	@DBYear			NVarChar(4);
		Select @DBName=DB_NAME();	 
		
		while @DBName<>''
		begin
			 
			set @DBYear=  SUBSTRING(@DBName,len(@DBName)-3,4)
			SET @StrTemp = '  insert into prs.tblCelebrationLastDate(PersonnelID,MonthCode,FiscalYear,LastDate325,MonthlyFunction)
								select PersonnelID ,Max(MonthCode),'+@DBYear+','''',0 from '+@DBName+'.prs.tblCelebrationDtl
								where ProcessID=325 and Payable=1 and PersonnelID not in ( select PersonnelID from prs.tblCelebrationLastDate )
								group by PersonnelID'
			print @StrTemp
			Exec sp_executesql @StrTemp; 
			SET @StrTemp = '  insert into prs.tblAllFunctionsDtl(PersonnelID,MonthCode,FiscalYear,MonthlyFunction)
								select PersonnelID ,MonthCode,'+@DBYear+',MonthlyFunction from '+@DBName+'.prs.tblFunctionsDtl '
			print @StrTemp
			Exec sp_executesql @StrTemp; 

			set @DBName=  SUBSTRING(@DBName,1,len(@DBName)-4)+ cast( ( cast( @DBYear as int) -1) as char(4))

			if (SELECT COUNT(*) FROM sys.databases WHERE name = @DBName)<=0
				set @DBName=''
		end

	update prs.tblCelebrationLastDate
	set LastDate325=case when MonthCode =12 then  cast(FiscalYear+1 as char(4)) else  cast(FiscalYear as char(4))	end 
						+'/'+ Case when MonthCode<9 then '0'+cast(MonthCode+1 as char(1)) else Case when  MonthCode=12 then  '01' else cast(MonthCode+1 as char(2)) end end  +'/01'
  
	update prs.tblCelebrationLastDate
	set  MonthlyFunction=isnull((  select Sum(b.MonthlyFunction) 
				from prs.tblAllFunctionsDtl  b 
				where a.PersonnelID=b.PersonnelID	and (b.FiscalYear>a.FiscalYear or( b.FiscalYear=a.FiscalYear and b.MonthCode>a.MonthCode and b.MonthCode<=@ToMonthCode)) ),0)
	from prs.tblCelebrationLastDate a
	
	SELECT ff.PersonnelID,cast(0 as int) MonthlyFunction ,cast(0 as int) SumLeaveWithoutPay,cast(0 as int) SumAbsence,cast(0 as int) SumSickLeave 
		into #tblPersonnels
	FROM prs.tblPersonnels ff
	where 1=0

	if @prs_HistoryCalcWithHireDateSumAllMonthlyFunction='false'
		insert   into #tblPersonnels
		SELECT ff.PersonnelID,pub.funFarsiDateDiff('Day',isnull(LastDate325,HireDate),@ToDate)+1+ Case when isnull(LastDate325,'')='' then isnull(CelebrationDayRemain,0) else 0 end    MonthlyFunction ,0 SumLeaveWithoutPay,
					 0 SumAbsence, 0 SumSickLeave 
			  FROM prs.tblPersonnels ff
			  Left join prs.tblCelebrationLastDate L on ff.PersonnelID=L.PersonnelID
			  WHERE LTRIM(RTRIM(HireDate))<>'' AND (@FromPersonnelID ='' OR ff.PersonnelID>=@FromPersonnelID) 
				AND (@ToPersonnelID ='' OR ff.PersonnelID<=@ToPersonnelID)
				AND ( ((SELECT LTRIM(RTRIM(QuitJobDate))	FROM prs.tblPersonnels p WHERE p.PersonnelID=ff.PersonnelID)>=@ToDate )
					or ((SELECT LTRIM(RTRIM(QuitJobDate))	FROM prs.tblPersonnels p WHERE p.PersonnelID=ff.PersonnelID)='' ) )  	
	ELSE
	BEGIN

		insert into #tblPersonnels
		SELECT ff.PersonnelID, CASE WHEN ISNULL(MonthlyFunction,0)=0 THEN 
						isnull((  select Sum(b.MonthlyFunction) 
						from prs.tblAllFunctionsDtl  b 
						where ff.PersonnelID=b.PersonnelID	and (b.FiscalYear<@Year or( b.FiscalYear=@Year and b.MonthCode<=@ToMonthCode))) ,0)+CelebrationDayRemain ELSE  L.MonthlyFunction END 
				,0 SumLeaveWithoutPay,0 SumAbsence, 0 SumSickLeave 
			  FROM prs.tblPersonnels ff
			  Left join prs.tblCelebrationLastDate L on ff.PersonnelID=L.PersonnelID
			  WHERE LTRIM(RTRIM(HireDate))<>'' AND (@FromPersonnelID ='' OR ff.PersonnelID>=@FromPersonnelID) 
				AND (@ToPersonnelID ='' OR ff.PersonnelID<=@ToPersonnelID)
				AND ( ((SELECT LTRIM(RTRIM(QuitJobDate))	FROM prs.tblPersonnels p WHERE p.PersonnelID=ff.PersonnelID)>=@ToDate )
					or ((SELECT LTRIM(RTRIM(QuitJobDate))	FROM prs.tblPersonnels p WHERE p.PersonnelID=ff.PersonnelID)='' )	)  	

	END 

		--select * from #tblPersonnels
		insert into #tblTmp 		
		SELECT F.PersonnelID, case when F.MonthlyFunction >0 then F.MonthlyFunction else 0 end 		
		--+(ISNULL((SELECT Case when MonthlyFunction=0 and @prs_UseInsuranceFunctionIFMonthlyFunctionZero='True' then InsuranceFunction else MonthlyFunction end  FROM prs.tblFunctionsDtl WHERE PersonnelID=F.PersonnelID AND  MonthCode = @ToMonthCode),0)))
		---ISNULL((SELECT  SUM(TotalDays) FROM  prs.tblCelebrationDtl WHERE ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=F.PersonnelID 
		--and ( Payable=1 or (Payable=0 and MonthCode<isnull( (SELECT Max(MonthCode) FROM  prs.tblCelebrationDtl
		--								WHERE Payable=1 and ProcessID=325 AND MonthCode<11 AND prs.tblCelebrationDtl.PersonnelID='100757'),0)))),0) 
		SumMonthlyFunction 
		, SumLeaveWithoutPay,SumAbsence,SumSickLeave,ISNULL((SELECT  SUM(Cost)
														FROM  prs.tblCelebrationDtl
														WHERE ProcessID=@ProcessID AND MonthCode<=@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=F.PersonnelID ),0) SumCost
		,F.MonthlyFunction SumMaxDays		
		,isnull((Select ManualTotalDays from   prs.tblCelebrationDtl d 
				 where d.PersonnelID=F.PersonnelID and d.MonthCode=@ToMonthCode and d.ProcessID=330) ,0) VacationRedemption	
		,ISNULL((SELECT  SUM(Cost) FROM  prs.tblCelebrationDtl
									WHERE Payable=0 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=F.PersonnelID 
									And MonthCode>isnull( (SELECT Max(MonthCode) FROM  prs.tblCelebrationDtl
									WHERE Payable=1 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=F.PersonnelID),0) ),0) SumCostNoPay
		,ISNULL((SELECT  SUM(TotalDays) FROM  prs.tblCelebrationDtl
									WHERE Payable=0 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=F.PersonnelID 
									And MonthCode>isnull( (SELECT Max(MonthCode) FROM  prs.tblCelebrationDtl
									WHERE Payable=1 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=F.PersonnelID),0)),0) SumMonthlyFunctionNoPay,''
		FROM #tblPersonnels F
		LEFT JOIN prs.tblCelebrationDtl C
		ON F.PersonnelID=C.PersonnelID AND C.ProcessID = @ProcessID
		GROUP BY F.PersonnelID,F.MonthlyFunction,SumLeaveWithoutPay,SumAbsence,SumSickLeave
	--select * from #tblTmp
		Update #tblTmp
			set AcntHistoryCalcDaysReserve= acc.funMergAcntCode(t.AcntHistoryCalcDaysReserve,AcntSalary)			
		from #tblTmp tp 
		INNER JOIN prs.tblDecreeHdr C ON   C.PersonnelID=tp.PersonnelID  and  C.SerialNo=(select max(SerialNo) from prs.tblDecreeHdr D where D.PersonnelID=C.PersonnelID )
		INNER JOIN prs.tblDepartments t ON t.DepartmentID=C.DepartmentID
			
		update 	 #tblTmp 	
			set SumCostNoPay=tp.SumCostNoPay+Credit-Debit
		from #tblTmp tp 
		inner join acc.tblVoucherDtl v on v.AcntCode=AcntHistoryCalcDaysReserve and VchKind=2 
										 
		end 
	ELSE	
	begin
	---  محاسبه مجموع کارکرد مرخصی ،بدون حقوق ، غیبت و مرخصی بیماری
		insert into #tblTmp 
		SELECT PersonnelID,SUM(Case when MonthlyFunction=0 and @prs_UseInsuranceFunctionIFMonthlyFunctionZero='True' then InsuranceFunction else MonthlyFunction end ) SumMonthlyFunction ,SUM(LeaveWithoutPay) SumLeaveWithoutPay,
					 SUM(Absence) SumAbsence , SUM(SickLeave) SumSickLeave
					, cast(0 as float ) SumCost , cast(0 as int ) SumMaxDays
					,isnull((Select ManualTotalDays from   prs.tblCelebrationDtl d 
					 where d.PersonnelID=ff.PersonnelID and d.MonthCode=@ToMonthCode and d.ProcessID=330) ,0) VacationRedemption
					 , cast(0 as float ) SumCostNoPay
					 , cast(0 as float ) SumMonthlyFunctionNoPay,''
			 FROM prs.tblFunctionsDtl ff
			  WHERE MonthCode <= @ToMonthCode
			  and  MonthCode>(	Select isnull(Max(MonthCode),0) 
															from  prs.tblCelebrationDtl 
																where Payable=1 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode 
																and prs.tblCelebrationDtl.PersonnelID = ff.PersonnelID )
		  		AND (@FromPersonnelID ='' OR PersonnelID>=@FromPersonnelID) 
				AND (@ToPersonnelID ='' OR PersonnelID<=@ToPersonnelID)
				AND ( ((SELECT LTRIM(RTRIM(QuitJobDate))	FROM prs.tblPersonnels p WHERE p.PersonnelID=ff.PersonnelID)>=@ToDate )
					or ((SELECT LTRIM(RTRIM(QuitJobDate))	FROM prs.tblPersonnels p WHERE p.PersonnelID=ff.PersonnelID)='' )
				) Group by PersonnelID
	--------------------------------------------------------------------------------------------------------------------------							
				-- اضافه کردن مانده از سال قبل
			--select * from  #tblTmp 
			update 	 #tblTmp 	
			set SumMonthlyFunction=SumMonthlyFunction+ISNULL((SELECT  SUM(TotalDays)
									FROM  prs.tblCelebrationDtl
									WHERE ProcessID=@ProcessID AND MonthCode=0 AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID
									),0)
			--select * from  #tblTmp 	
							-----  محاسبه مبلغ محاسبه
			update 	 #tblTmp 	
			set SumCost= ISNULL((SELECT  SUM(Cost)
									FROM  prs.tblCelebrationDtl
									WHERE ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID ),0) 
			update 	 #tblTmp 	
			set SumCostNoPay= ISNULL((SELECT  SUM(Cost)
									FROM  prs.tblCelebrationDtl
									WHERE Payable=0 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID 
									And MonthCode>isnull( (SELECT Max(MonthCode) FROM  prs.tblCelebrationDtl
									WHERE Payable=1 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID ),0) ),0) 			
			update 	 #tblTmp 	
			set SumMonthlyFunctionNoPay= ISNULL((SELECT  SUM(TotalDays)
									FROM  prs.tblCelebrationDtl
									WHERE Payable=0 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID
									And MonthCode>isnull( (SELECT Max(MonthCode) FROM  prs.tblCelebrationDtl
										WHERE Payable=1 and ProcessID=@ProcessID AND MonthCode<@ToMonthCode AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID  ),0) ),0) 
			-------  محاسبه حداکثر روزهای مجاز اینسال و مانده از سال قبلی
		
		-----------------تعداد = مجموع کارکرد ماههای مانده محاسبه نشده--------------------------------------			 							
		-----------------ماکزیمم = مجموع روز های سال منهای پرداخت شده دستی--------------------------------------			 							
			IF @ProcessID = 325													
				update 	 #tblTmp 	
				set SumMaxDays=0
			IF @ProcessID = 320													
				update 	 #tblTmp 	
				set SumMaxDays= @EndMonthDays+ ISNULL((select Sum(DayCount) from #MonthDayCount
										where MonthCode<=@ToMonthCode
											),0) 
					+ISNULL((SELECT  SUM(ManualTotalDays)
										FROM  prs.tblCelebrationDtl
										WHERE ProcessID=@ProcessID AND MonthCode=0 AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID
										and  (	Select isnull(Max(MonthCode),0) 
																from  prs.tblCelebrationDtl 
																	where ProcessID=@ProcessID AND MonthCode<@ToMonthCode 
																and prs.tblCelebrationDtl.PersonnelID = #tblTmp.PersonnelID )=0
										 ),0)
		
					-ISNULL((SELECT  SUM(ManualTotalDays)
										FROM  prs.tblCelebrationDtl
										WHERE ProcessID=@ProcessID  AND prs.tblCelebrationDtl.PersonnelID=#tblTmp.PersonnelID
									and   MonthCode<@ToMonthCode 
										 ),0)									 
			
END
		if 	@prsVacationSubFromCelebrationHistoryCalcDays	='True'	
			update 	 #tblTmp 	
				set SumMonthlyFunction=SumMonthlyFunction+VacationRedemption
				where VacationRedemption<0
 
			select * from  #tblTmp 	
	
END	
GO
