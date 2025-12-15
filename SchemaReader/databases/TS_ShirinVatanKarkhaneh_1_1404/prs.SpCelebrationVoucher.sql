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
Create PROCEDURE [prs].[SpCelebrationVoucher]
	@SerialNo		INT,
	@DocDate		CHAR(10),
	@ProcessID		INT,
	@MonthCode		INT,
	@Desc			NVARCHAR(100),
	@SourceDocType	TINYINT,
	@RecID			Bigint
WITH ENCRYPTION
AS

BEGIN 

DECLARE @PersonnelID varchar(20)
Declare @strMsgText	 NVarChar(2044)

	DECLARE @HistoryCalcWithHireDate bit
	SET @HistoryCalcWithHireDate  = 'False'	

---  در حالت معمولی برای عیدی و پایانکار مبلغ محاسبه شده سند زده میشود  ولی برای حالت تیک تاریخ شروع استخدام برای پایانکار از مبلغ قبلی کسر میشود
	
	IF @ProcessID = 325 
		SELECT @HistoryCalcWithHireDate = SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'HistoryCalcWithHireDate'
	--به خاطر مشکل ثبت سند حسابداری که براساس مانده معین سند زده میشد در حالی که باید مبلغ محاسبه شده سند زده شود
	set  @HistoryCalcWithHireDate = 'False'
	IF @HistoryCalcWithHireDate = 'True'
		begin
			SELECT * 
			INTO #tblCDD
			FROM prs.tblCelebrationDtl C
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode =@MonthCode
			and (Cost>0  or @MonthCode=13)
		 if (select isnull(count(*),0) from #tblCDD)=0  
			return
		end 
	ELSE
		begin
			SELECT *
			INTO #tblCDD1
			FROM prs.tblCelebrationDtl C
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode
			and (Cost>0  or @MonthCode=13)	
		if (select isnull(count(*),0) from #tblCDD1)=0  
			return
	end 

	IF (SELECT ISNULL(COUNT(*),0) FROM acc.tblVoucherHdr WHERE SerialNo=@SerialNo)=0
	BEGIN
		DECLARE @MainSerialNo as int
		SELECT @MainSerialNo = ISNULL(MAX(OldSerialNo),0)+1
		FROM acc.tblVoucherHdr
				
		INSERT INTO acc.tblVoucherHdr(SerialNo, DocDate,DocRegisterState, DocDesc, DocDesc2, 
			VchKind, RecID, SessionNo, OldSerialNo, CurrencyTypeID, CurrencyRate, RowNo)
		VALUES	(@SerialNo,@DocDate,1,@Desc,'',1,@RecID,0,@MainSerialNo,'',0,0)
	
	END

	DECLARE @MaxROwNo AS INT

	SELECT @MaxROwNo=ISNULL(MAX(RowNo),0) FROM acc.tblVoucherDtl WHERE SerialNo=@SerialNo
		
	IF @HistoryCalcWithHireDate = 'True'
	BEGIN		
		UPDATE #tblCDD	SET OldCost = Cost
		UPDATE #tblCDD
		SET Cost = Cost + ([acc].[funAccountRemain]([pub].[funMergCode](CASE @ProcessID WHEN 320 THEN  
			(case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) 
			WHEN @ProcessID THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END ,
			D.AcntSalary),@DocDate))
		FROM 	#tblCDD C
		INNER JOIN prs.tblDecreeHdr D
		ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
		INNER JOIN prs.tblDepartments t
		ON t.DepartmentID=D.DepartmentID

		UPDATE #tblCDD 	SET OldCost = Cost-OldCost 

		update  prs.tblCelebrationDtl 
			set  OldCost = b.OldCost 
		from prs.tblCelebrationDtl a
		inner join #tblCDD b on a.ProcessID=b.ProcessID	and  a.MonthCode=b.MonthCode and  a.PersonnelID=b.PersonnelID

		delete  FROM #tblCDD 
		where Cost=0 
		----------Debit----------------------------------------------------------------------------	
		IF (SELECT Count(*)
		FROM (
			SELECT D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode,SUM(Cost) Cost
			FROM #tblCDD C
			INNER JOIN prs.tblDecreeHdr D		ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t		ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td	ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=0			
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
		) G
		where  Cost<0 )>0
			BEGIN
				SELECT  top 1 @PersonnelID=PersonnelID
				FROM (
			SELECT  C.PersonnelID, D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode,SUM(Cost) Cost
			FROM #tblCDD C
			INNER JOIN prs.tblDecreeHdr D		ON C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t		ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=0			
			GROUP BY C.PersonnelID,D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
		) G
		where   Cost<0 
				SET @strMsgText=N'  مشکل منفی شدن مبلغ برای پرسنل ' + @PersonnelID +' '
				Raiserror (@strMsgText ,16,1)
				Return
			END

		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,AcntCode,Cost,0,@Desc + ' ' + DepartmentName,'','True', 0,1,row_number() over (order by DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM (
			SELECT D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode,SUM(Cost) Cost
			FROM #tblCDD C
			INNER JOIN prs.tblDecreeHdr D		ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t		ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td	ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=0			
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
		) G
		where  Cost>0 
		----------Credit----------------------------------------------------------------------------	

		SELECT @MaxROwNo=ISNULL(MAX(RowNo),0) FROM acc.tblVoucherDtl WHERE SerialNo=@SerialNo
		
		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by D.DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,[pub].[funMergCode](CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END ,D.AcntSalary)
		,CASE WHEN Cost<0 THEN -Cost ELSE 0 END  ,CASE WHEN Cost>0 THEN Cost ELSE 0 END  ,@Desc ,'','True', 0,1,row_number() over (order by D.DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM #tblCDD C
		INNER JOIN prs.tblDecreeHdr D	ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
		INNER JOIN prs.tblDepartments t	ON t.DepartmentID=D.DepartmentID
		Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=0
				
		----------Debit----------------------------------------------------------------------------	
		
		IF (SELECT Count(*)
			FROM (
				SELECT D.DepartmentID,DepartmentName,SUM(Cost) Cost
				FROM #tblCDD C
				INNER JOIN prs.tblDecreeHdr D			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
				INNER JOIN prs.tblDepartments t			ON t.DepartmentID=D.DepartmentID
				INNER JOIN prs.tblDepartmentsDtl td		ON td.DepartmentID=D.DepartmentID
				Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=1			
				GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END  
				) G
			where  Cost<0 )>0
			BEGIN
				SELECT  top 1 @PersonnelID=PersonnelID
				FROM (
					SELECT C.PersonnelID,D.DepartmentID,DepartmentName	,SUM(Cost) Cost
					FROM #tblCDD C
					INNER JOIN prs.tblDecreeHdr D		ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
					INNER JOIN prs.tblDepartments t		ON t.DepartmentID=D.DepartmentID
					INNER JOIN prs.tblDepartmentsDtl td	ON td.DepartmentID=D.DepartmentID
				Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=1			
				GROUP BY C.PersonnelID,D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END  
				) G
				where  Cost<0 
				SET @strMsgText=N'  مشکل منفی شدن مبلغ برای پرسنل ' + @PersonnelID +' '
				Raiserror (@strMsgText ,16,1)
				Return
			END
			
		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,AcntCode,Cost,0,@Desc + ' ' + DepartmentName,'','True', 0,1,row_number() over (order by DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM (
			SELECT D.DepartmentID,DepartmentName
			,CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END AcntCode
			,SUM(Cost) Cost
			FROM #tblCDD C
			INNER JOIN prs.tblDecreeHdr D			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t			ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td		ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=1			
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END  
		) G
		where  Cost>0 

		----------Credit----------------------------------------------------------------------------	
	IF (SELECT Count(*)
		FROM (
			SELECT D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode,SUM(Cost) Cost
			FROM #tblCDD C
			INNER JOIN prs.tblDecreeHdr D			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t			ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td		ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=1			
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
		) G
		where  Cost<0 )>0
			BEGIN
				SELECT  top 1 @PersonnelID=PersonnelID
				FROM (
					SELECT C.PersonnelID,D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode,SUM(Cost) Cost
					FROM #tblCDD C
					INNER JOIN prs.tblDecreeHdr D			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
					INNER JOIN prs.tblDepartments t			ON t.DepartmentID=D.DepartmentID
					INNER JOIN prs.tblDepartmentsDtl td		ON td.DepartmentID=D.DepartmentID
					Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=1			
					GROUP BY C.PersonnelID,D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
					) G
				where  Cost<0 
				SET @strMsgText=N'  مشکل منفی شدن مبلغ برای پرسنل ' + @PersonnelID +' '
				Raiserror (@strMsgText ,16,1)
				Return
			END

		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,AcntCode,Cost,0,@Desc + ' ' + DepartmentName,'','True', 0,1,row_number() over (order by DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM (
			SELECT D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode,SUM(Cost) Cost
			FROM #tblCDD C
			INNER JOIN prs.tblDecreeHdr D			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t			ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td		ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode and D.RegSumSalaryUnit=1			
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
		) G
		where  Cost>0 
		
	END	
	ELSE
	BEGIN
		----------Debit----------------------------------------------------------------------------			
		
		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,AcntCode,Cost,0,@Desc + ' ' + DepartmentName,'','True', 0,1,row_number() over (order by DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM (
			SELECT D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode
			,SUM(Cost) Cost
			FROM #tblCDD1 C
			INNER JOIN prs.tblDecreeHdr D
			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t
			ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td
			ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode
			and D.RegSumSalaryUnit=0
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
		) G
		----------Credit----------------------------------------------------------------------------	

		SELECT @MaxROwNo=ISNULL(MAX(RowNo),0) FROM acc.tblVoucherDtl WHERE SerialNo=@SerialNo
		
		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by D.DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,[pub].[funMergCode](CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END ,D.AcntSalary)
		,CASE WHEN Cost<0 THEN -Cost ELSE 0 END  ,CASE WHEN Cost>0 THEN Cost ELSE 0 END  ,@Desc ,'','True', 0,1,row_number() over (order by D.DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM #tblCDD1 C
		INNER JOIN prs.tblDecreeHdr D
		ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
		INNER JOIN prs.tblDepartments t
		ON t.DepartmentID=D.DepartmentID
		Where ProcessID=@ProcessID AND C.VchNo=0 AND C.MonthCode>0  AND C.MonthCode <=@MonthCode
			and D.RegSumSalaryUnit=0	
				
		----------Debit----------------------------------------------------------------------------	
		----------Debit----------------------------------------------------------------------------	
		
		SELECT @MaxROwNo=ISNULL(MAX(RowNo),0) FROM acc.tblVoucherDtl WHERE SerialNo=@SerialNo
	
		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,AcntCode
		,case when Cost>0 then Cost else 0 end ,case when Cost<0 then -Cost else 0 end ,@Desc + ' ' + DepartmentName,'','True', 0,1,row_number() over (order by DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM (
			SELECT D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode
			,SUM(Cost) Cost
			FROM #tblCDD1 C
			INNER JOIN prs.tblDecreeHdr D
			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t
			ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td
			ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode
			and D.RegSumSalaryUnit=1
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  
		) G
		----------Credit----------------------------------------------------------------------------	
		----------Credit----------------------------------------------------------------------------	

		SELECT @MaxROwNo=ISNULL(MAX(RowNo),0) FROM acc.tblVoucherDtl WHERE SerialNo=@SerialNo
	
		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail, CurrencyAmount, Emphasize, CurrencyTypeID, SourceCodeFieldValue, Emphasize2, Emphasize3)
		SELECT @SerialNo,row_number() over (order by DepartmentID) + @MaxROwNo, @ProcessID,1,0,@MonthCode,@DocDate,AcntCode
		 ,case when Cost<0 then -Cost else 0 end,case when Cost>0 then Cost else 0 end ,@Desc + ' ' + DepartmentName,'','True', 0,1,row_number() over (order by DepartmentID) + @MaxROwNo,@SourceDocType,'True',0,'False','','','False','False'
		FROM (
			SELECT D.DepartmentID,DepartmentName
			--,CASE @ProcessID WHEN 320 THEN AcntCelebrationCost WHEN 325 THEN AcntHistoryCalcDaysCost END  AcntCode
			,CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END AcntCode
			
			,SUM(Cost) Cost
			FROM #tblCDD1 C
			INNER JOIN prs.tblDecreeHdr D
			ON   C.PersonnelID=D.PersonnelID  AND C.DecreeSerialNo=D.SerialNo
			INNER JOIN prs.tblDepartments t
			ON t.DepartmentID=D.DepartmentID
			INNER JOIN prs.tblDepartmentsDtl td
			ON td.DepartmentID=D.DepartmentID
			Where ProcessID=@ProcessID AND C.VchNo=0  AND C.MonthCode>0 AND C.MonthCode <=@MonthCode
			and D.RegSumSalaryUnit=1
			GROUP BY D.DepartmentID,DepartmentName,CASE @ProcessID WHEN 320 THEN  (case WHEN Payable='True' THEN AcntCelebrationPayable ELSE AcntCelebrationReserve END) WHEN 325 THEN (case WHEN Payable='True' THEN AcntHistoryCalcDaysPayable ELSE AcntHistoryCalcDaysReserve END) END 
		) G
		
	END	
	---------------------------------------برای اصلاح و جابجایی اسنادی که  اول بستانکار و سپس بدهکار زده شود--------------------------------------------------------------------------------------------------------
		update  acc.tblVoucherDtl
		set RowNo=RowNo+ (select count(*) from  acc.tblVoucherDtl		WHERE SerialNo=@SerialNo	 and SourceProcessID=@ProcessID)
		,DocRowNo=DocRowNo+ (select count(*) from  acc.tblVoucherDtl		WHERE SerialNo=@SerialNo  and SourceProcessID=@ProcessID)
		WHERE SerialNo=@SerialNo and SourceProcessID=@ProcessID
		and  Debit>0
		update  acc.tblVoucherDtl
		set RowNo=RowNo+ (select count(*) from  acc.tblVoucherDtl		WHERE SerialNo=@SerialNo	 and SourceProcessID=@ProcessID)*2
		,DocRowNo=DocRowNo+ (select count(*) from  acc.tblVoucherDtl		WHERE SerialNo=@SerialNo and SourceProcessID=@ProcessID)*2
		WHERE SerialNo=@SerialNo  and SourceProcessID=@ProcessID
		and  Debit=0
		
END
GO
