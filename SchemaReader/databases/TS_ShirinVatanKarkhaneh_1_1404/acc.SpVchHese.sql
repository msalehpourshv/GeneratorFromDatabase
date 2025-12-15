USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1401/08/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--[acc].[SpVchHese] 4458,'1401/01/01','1401/12/29',1401,15200
Create PROCEDURE [acc].[SpVchHese]
	@intVchNo				Int,
	@StartDate				varchar(10)='',
	@EndDate				varchar(10)='',
	@FiscalYear				Int,
	@SessionNo				Int,
	@ProcessNo				Int
	WITH ENCRYPTION
AS

BEGIN
	-----
	Declare @strMsgText	NVarChar(2044)
	Declare @PayTypeID	Tinyint
	Declare @BankState	Tinyint
	Declare @SumAmount	float
	Declare @Amount		float
	Declare @RowDesc	Nvarchar(1000)	
	Declare @CreditCode	Varchar(20)
	Declare @ChequeNo	Bigint
	Declare @ChequeDate	Char(10)
	Declare @AcntCode2	Varchar(20)
	Declare @AcntCode5	Varchar(20)
	Declare @strRecDesc NVarChar(1000)
	Declare @AcntCode	Varchar(20)
	Declare @CollectorAcntCode	Varchar(20)
	DECLARE @AcntName NVarchar(1000)
	Declare @CurrencyAmount	Float
	Declare @SumCurrencyAmount	float
	Declare @strSourceProcessNo NVARCHAR(100)
	Declare @BaseID Int
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)
	DECLARE @BankCodeReplaceWithCustomerCodeInReceive BIT
	Declare @start int 

	Declare @intMaxRowNo	Int
	Declare @intMaxDocRowNo Int
		
	declare @LoanCost varchar(20)
	declare @LoanSavedCost varchar(20)

	SELECT @LoanCost=SettingValue from pub.tblSettings where SettingKey ='LoanCost'
	SELECT @LoanSavedCost=SettingValue from pub.tblSettings where SettingKey ='LoanSavedCost'

	set @LoanCost=ltrim(rtrim(isnull(@LoanCost,'')))
	set @LoanSavedCost=ltrim(rtrim(isnull(@LoanSavedCost,'')))

	SELECT	@intMaxRowNo=MAX(RowNo),@intMaxDocRowNo=MAX(DocRowNo)
	FROM	acc.tblVoucherDtl 
	WHERE	SerialNo = @intVchNo

	SET @intMaxRowNo    = ISNULL(@intMaxRowNo,0)
	SET @intMaxDocRowNo = ISNULL(@intMaxDocRowNo,0)

	IF (SELECT COUNT(*) FROM acc.tblVoucherHdr WHERE SerialNo=@intVchNo) = 0
			
	BEGIN	
		Declare @MainSerialNo int

		SELECT @MainSerialNo = ISNULL(MAX(OldSerialNo),0)+1
		FROM acc.tblVoucherHdr
																		
		INSERT INTO acc.tblVoucherHdr
				(SerialNo  , DocDate    , DocRegisterState, DocDesc, DocDesc2,  RecID, SessionNo , VchKind,OldSerialNo,RowNo,BaseDistributionSerialNo,Tax_Type) 
		VALUES	(@intVchNo , @EndDate, 1               , ''     , ''      ,  0    , @SessionNo, 1,@MainSerialNo,0,0,0)
					
	END

	--------------------------------------------------------------------------------------------------------
	SELECT * ,ROUND(InstallmentCost*PeridoDay/CurrentFiscalYearDay,0) Hese, @LoanCost +  SUBSTRING(LoanAcntCode,LEN(@LoanCost)+1,20) LoanCost,'                    ' LoanSavedCost 
	       INTO #tblSese
	FROM (
		SELECT *,pub.funFarsiDateDiff('Day',case when BeforeDate<@StartDate then @StartDate else BeforeDate end,@EndDate) PeridoDay,
			   pub.funFarsiDateDiff('Day',BeforeDate,InstallmentDate)CurrentFiscalYearDay,case when BeforeDate<@StartDate then @StartDate else BeforeDate end MainBeforeDate
		FROM (SELECT a.DocDate,InstallmentDate
					  ,ISNULL((SELECT top 1 InstallmentDate 
							  FROM  trs.tblLoanDtl l 
							  WHERE l.ProcessID=b.ProcessID and l.ProcessNo=b.ProcessNo and l.FiscalYear=b.FiscalYear and l.SerialNo=b.SerialNo AND l.InstallmentNo<b.InstallmentNo ORDER BY InstallmentNo DESC),a.DocDate) BeforeDate
					   ,a.LoanAcntCode,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,InstallmentNo,InstallmentCost
				FROM trs.tblLoanHdr a
				INNER JOIN (SELECT  ROW_NUMBER()OVER(PARTITION BY ProcessID,ProcessNo,FiscalYear,SerialNo ORDER BY InstallmentDate ) R  ,* 
							FROM trs.tblLoanDtl WHERE  ProcessNo = @ProcessNo AND ProcessID=7 AND InstallmentDate>@EndDate) b
				ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
				WHERE R=1 AND InstallmentCost>0 
				 AND(select count(*)  FROM trs.tblLoanDtl c WHERE  c.ProcessID=8 and c.BaseProcessID=b.ProcessID and c.BaseProcessNo=b.ProcessNo and c.BaseFiscalYear=b.FiscalYear and c.BaseSerialNo=b.SerialNo AND c.InstallmentNo=b.InstallmentNo  )=0
			 ) a
	    ) a
	WHERE PeridoDay>0 


    UPDATE trs.tblLoanDtl
    SET HeseYear=@FiscalYear,HeseAmount=Hese
    FROM trs.tblLoanDtl a
    INNER JOIN #tblSese b
    ON a.ProcessID=b.ProcessID AND  a.ProcessNo=b.ProcessNo AND a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo AND a.InstallmentNo=b.InstallmentNo

	INSERT INTO #tblSese
	SELECT * ,ROUND(InstallmentCost*PeridoDay/CurrentFiscalYearDay,0) Hese,'                    ' LoanCost, @LoanSavedCost +  SUBSTRING(LoanAcntCode,LEN(@LoanSavedCost)+1,20) LoanSavedCost 
	FROM (
		SELECT *,pub.funFarsiDateDiff('Day',case when BeforeDate<@StartDate then @StartDate else BeforeDate end,@EndDate) PeridoDay,
				pub.funFarsiDateDiff('Day',BeforeDate,InstallmentDate)CurrentFiscalYearDay,case when BeforeDate<@StartDate then @StartDate else BeforeDate end MainBeforeDate
		FROM (SELECT a.DocDate,InstallmentDate
						,ISNULL((SELECT top 1 InstallmentDate 
								FROM  trs.tblLoanDtl l 
								WHERE l.ProcessID=b.ProcessID and l.ProcessNo=b.ProcessNo and l.FiscalYear=b.FiscalYear and l.SerialNo=b.SerialNo AND l.InstallmentNo<b.InstallmentNo ORDER BY InstallmentNo DESC),a.DocDate) BeforeDate
						,a.LoanAcntCode,a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,InstallmentNo,InstallmentCost
				FROM trs.tblLoanHdr a
				INNER JOIN (SELECT  ROW_NUMBER()OVER(PARTITION BY ProcessID,ProcessNo,FiscalYear,SerialNo ORDER BY InstallmentDate ) R  ,* 
							FROM trs.tblLoanDtl WHERE  ProcessNo = @ProcessNo AND  ProcessID=7 AND InstallmentDate>@EndDate) b
				ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
				WHERE R=1 AND InstallmentCost>0
				 AND(select count(*)  FROM trs.tblLoanDtl c WHERE  c.ProcessID=8 and c.BaseProcessID=b.ProcessID and c.BaseProcessNo=b.ProcessNo and c.BaseFiscalYear=b.FiscalYear and c.BaseSerialNo=b.SerialNo AND c.InstallmentNo=b.InstallmentNo  )=0
			) a
	   ) a
	WHERE PeridoDay>0 

	SET @strRecDesc = N'حصه وام برگه '
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,
				RecDesc,RecDesc2,SourceDocType,CurrencyAmount,BaseID) 
	SELECT @intVchNo,9,ProcessNo,FiscalYear,SerialNo,@EndDate,1,@SessionNo,1,ROW_NUMBER()over(order by  ProcessID,ProcessNo,FiscalYear,SerialNo,LoanSavedCost) + @intMaxRowNo,ROW_NUMBER()over(order by  ProcessID,ProcessNo,FiscalYear,SerialNo,LoanSavedCost) + @intMaxDocRowNo,
		   CASE WHEN RTRIM(LTRIM(LoanCost))<>'' THEN LoanCost ELSE LoanSavedCost END,CASE WHEN RTRIM(LTRIM(LoanCost))<>'' THEN Hese ELSE 0 END,CASE WHEN RTRIM(LTRIM(LoanCost))<>'' THEN 0 ELSE Hese END,
		   TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal( @strRecDesc + LTRIM(STR(FiscalYear)) + '/' + LTRIM(STR(SerialNo)))),'',10,0,0
	FROM #tblSese
	ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,LoanSavedCost
		
	IF (SELECT COUNT(*) from acc.tblVoucherDtl where SerialNo =@intVchNo )=0
		DELETE FROM acc.tblVoucherHdr WHERE SerialNo = @intVchNo
END
GO
