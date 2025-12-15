USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/06/04
-- Viewed By	 : 
-- Last Modified : 1389/02/20
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : گزارش دریافتها و پرداختها
-- =============================================
Create PROCEDURE [trs].[RptPayReceiptDocs_Detailed]
	@ProcessID			Int = 1, /* 1 = Receipt; 2 = Payment; 3 = ReceiptMisc; 4 = PayMisc; */
	@ProcessNo			Int = 1,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DateFr				Char(10) = Null,
	@DateTo				Char(10) = Null,
	@DebitCode1			Int = 0, -- بدهکار
	@DebitCode2			Int = 0,
	@DebitCode3			Int = 0,
	@DebitCode4			Int = 0,
	@CreditCode1		Int = 0, -- بستانکار
	@CreditCode2		Int = 0,
	@CreditCode3		Int = 0,
	@CreditCode4		Int = 0,
	@VisitorCode1		Int = 0, -- بازاریاب
	@VisitorCode2		Int = 0, 
	@VisitorCode3		Int = 0, 
	@VisitorCode4		Int = 0, 
	@CollectorCode1		Int = 0, -- کد تحصیلدار
	@CollectorCode2		Int = 0, 
	@CollectorCode3		Int = 0, 
	@CollectorCode4		Int = 0, 
	@UsanceDateFr		Char(10) = Null, -- از تاریخ سررسید
	@UsanceDateTo		Char(10) = Null, -- تا تاریخ سررسید
	@AmountFr			BigInt = Null,      -- از مبلغ 
	@AmountTo			BigInt = Null,      -- تا مبلغ 
	@ChequeNoFr			VarChar(20) = Null, -- از شماره چک
	@ChequeNoTo			VarChar(20) = Null, -- تا شماره چک
	@PayTypeID			TinyInt = Null, -- نوع دریافت/پرداخت
	@DescMask			NVarChar(100)= Null, -- قسمتی از شرح
	@SortFields			NVarChar(100)= Null, -- لیست فیلدها برای مرتب سازی
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(100) = '1@1'
  
WITH ENCRYPTION
As
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrSelect1	NVarChar(max)
DECLARE @StrWhere	NVarChar(3000)
DECLARE @StrWhere2	NVarChar(3000)
DECLARE @StrFrom	NVarChar(1000)
DECLARE @BaseDate	NVarChar(10)
DECLARE @LangID		Char(1)
DECLARE @SessionNo  VarChar(10)
DECLARE @ReportID   VarChar(10)
DECLARE @year		Char(4)
DECLARE @SelectPayTypeID int
DECLARE @PayTypeIDS  VarChar(100)
DECLARE @DescMaskDtl  NVarChar(200)

DECLARE @BehalfID  NVarChar(50)


Begin -- ======================= S T A R T   C O D E =========================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	-- Init -----------------------------------------------------------------------------------
	Set NoCount On;

	If (@RepInfo	Is Null)		SET @RepInfo    = '1@1@1'
	If (@ProcessID  Is Null)		SET @ProcessID  = 1
	If (@ProcessNo  Is Null)		SET @ProcessNo  = 1
	If (@SortFields Is Null)		SET @SortFields = 'FiscalYear, SerialNo, ProcessID'
	IF (@DebitCode1 Is Null)		SET @DebitCode1 = 0
	IF (@DebitCode2 Is Null)		SET @DebitCode2 = 0
	IF (@DebitCode3 Is Null)		SET @DebitCode3 = 0
	IF (@DebitCode4 Is Null)		SET @DebitCode4 = 0

	IF (@CreditCode1 Is Null)		SET @CreditCode1 = 0
	IF (@CreditCode2 Is Null)		SET @CreditCode2 = 0
	IF (@CreditCode3 Is Null)		SET @CreditCode3 = 0
	IF (@CreditCode4 Is Null)		SET @CreditCode4 = 0

	IF (@VisitorCode1 Is Null)		SET @VisitorCode1 = 0
	IF (@VisitorCode2 Is Null)		SET @VisitorCode2 = 0
	IF (@VisitorCode3 Is Null)		SET @VisitorCode3 = 0
	IF (@VisitorCode4 Is Null)		SET @VisitorCode4 = 0

	IF (@CollectorCode1 Is Null)	SET @CollectorCode1 = 0
	IF (@CollectorCode2 Is Null)	SET @CollectorCode2 = 0
	IF (@CollectorCode3 Is Null)	SET @CollectorCode3 = 0
	IF (@CollectorCode4 Is Null)	SET @CollectorCode4 = 0

	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null
	IF (@SerialNoFr Is Null)		SET @FiscalYearFr = Null
	IF (@SerialNoTo Is Null)		SET @FiscalYearTo = Null

	SELECT @BaseDate = LEFT([pub].[funFarsiDate](GetDate()), 10)
	SET @LangID		 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	 = pub.funSplitString(@RepInfo, '@', 3);
	SET @year		 = RIGHT(db_name(),4) 
	
	SET @SelectPayTypeID = Cast(pub.funSplitString(@ExtraParams, '@', 3) As Int);
	SET @PayTypeIDS		 = Cast(pub.funSplitString(@ExtraParams, '@', 4) As Varchar(100));
	SET @DescMaskDtl	 = Cast(pub.funSplitString(@ExtraParams, '@', 5) As NVarChar(200));
	SET @BehalfID		 = Cast(pub.funSplitString(@ExtraParams, '@', 6) As NVarChar(50));

	
	declare @Result1 as varchar(max)
	SET @Result1= ''
	exec [pub].[funGetColumnsWithoutXColumns] @SchemaName='trs',@tableName='tblPayDtl',
					@ColumnsName='Amount',
					@CompressTableName='D',@Result=@Result1 output

	SET @StrWhere =' 1 = 1 '
	SET @StrWhere2 =''
	if (@ProcessID =2 )
		begin
	If	(@DebitCode1 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'AA.AtomAcntCode') 
		If	(@DebitCode2 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'AA.AtomAcntCode') 
		If	(@DebitCode3 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'AA.AtomAcntCode') 
		If	(@DebitCode4 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'AA.AtomAcntCode') 
	end
	if (@ProcessID =1 )
		begin
		If	(@CreditCode1 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'AA.AtomAcntCode') 
		If	(@CreditCode2 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'AA.AtomAcntCode') 
		If	(@CreditCode3 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'AA.AtomAcntCode') 
		If	(@CreditCode4 > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'AA.AtomAcntCode') 
	end

	If (@DescMaskDtl Is Not Null) And (@DescMaskDtl <> '')
		SET @StrWhere2 = @StrWhere2 + ' AND (Replace(D.RowDesc, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMaskDtl, ' ', '')) + '%'')'

	if (@BehalfID Is Not Null) and (@BehalfID <> '')
		Set @StrWhere2 = @StrWhere2 + ' And (H.BehalfID = '+str(@BehalfID)+' )'
		
	--------------------------------------------------------------------------------------------
	-- S E L E C T -----------------------------------------------------------------------------
	Set @StrSelect = ''
	Set @StrSelect1 = ' Select * from (
	SELECT	Distinct  
	Case When (SELECT Count(*) 
			   FROM trs.tblPayAtm A 
			   WHERE A.ProcessID = D.ProcessID AND A.ProcessNo = D.ProcessNo AND A.FiscalYear = D.FiscalYear AND 
					 A.SerialNo = D.SerialNo AND A.DocRowNo = D.DocRowNo) > 0 THEN 
							(SELECT IsNull(SUM(AA.AtomAmount),0) 
							 FROM trs.tblPayAtm AA 
							 WHERE AA.ProcessID = D.ProcessID AND AA.ProcessNo = D.ProcessNo AND 
								   AA.FiscalYear = D.FiscalYear AND AA.SerialNo = D.SerialNo AND AA.DocRowNo = D.DocRowNo AND 
								   '+ @StrWhere + ' ) 
	ELSE Amount END Amount,
	H.BaseDocType  ,'+ @Result1 +', H.DebitCode AS DebitCodeH, H.CreditCode AS CreditCodeH, H.VchNo, H.DescHdr, isNull([trs].[GetBehalfName](H.BehalfID,'+@LangID+'),'''') BehalfName,
			pub.GetCodeName(H.DebitCode, '  + @LangID + ') DebitNameAHdr,
			pub.GetBankName(H.DebitCode, '  + @LangID + ') DebitNameBHdr,
			pub.GetCodeName(H.CreditCode, ' + @LangID + ') CreditNameAHdr,
			pub.GetBankName(H.CreditCode, ' + @LangID + ') CreditNameBHdr,
			pub.GetCodeName(D.DebitCode, '  + @LangID + ') DebitNameA,
			pub.GetBankName(D.DebitCode, '  + @LangID + ') DebitNameB,
			pub.GetCodeName(D.CreditCode, ' + @LangID + ') CreditNameA,
			pub.GetBankName(D.CreditCode, ' + @LangID + ') CreditNameB,
			pub.GetUserName(H.SessionNo1) AS UserName, LD.LocationName,
			pub.funFarsiDateDiff(''Day'', ''' + @BaseDate + ''', D.DocDate) AS DateDuration,
			pub.funGetBankTypeName(D.BankTypeID, '  + @LangID + ') AS DebitBankTypeName,
			pub.funGetBankTypeName(D.BankTypeID2, ' + @LangID + ') AS CreditBankTypeName,
			(SELECT Count(*) FROM trs.tblPayAtm A WHERE A.ProcessID = D.ProcessID AND A.ProcessNo = D.ProcessNo AND A.FiscalYear = D.FiscalYear AND A.SerialNo = D.SerialNo AND A.DocRowNo = D.DocRowNo) AS AtomCount,
			T.TypeText as PayTypeName
	FROM	trs.tblPayDtl D
				INNER JOIN trs.tblPayHdr AS H ON D.ProcessID  = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
				LEFT  JOIN pub.tblLocationsDtl AS LD ON D.LocationID2 = LD.LocationID AND LD.LanguageID = ' + @LangID + '
				left join pub.tblTypeValues T on T.TypeID = 2 and T.TypeValue = D.PayTypeID
				left join  trs.tblPayAtm A on A.ProcessID = D.ProcessID AND A.ProcessNo = D.ProcessNo AND A.FiscalYear = D.FiscalYear AND A.SerialNo = D.SerialNo AND A.DocRowNo = D.DocRowNo
	WHERE	D.FiscalYear = ' + @year + ' and D.ProcessID = ' + LTrim(Str(@ProcessID)) + ' AND 
			( ' + LTrim(Str(@ProcessNo))+' = 0  or D.ProcessNo = ' + LTrim(Str(@ProcessNo)) +')' + @StrWhere2
	
	If	(@SelectPayTypeID > 0)
		SET @StrSelect = @StrSelect + ' AND D.PayTypeID in( ' + LTrim(@PayTypeIDS)+')'
	If	(@DebitCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'D.DebitCode') +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode1, 'A.AtomAcntCode') + ' )' 
	If	(@DebitCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'D.DebitCode') +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode2, 'A.AtomAcntCode') + ' )' 
	If	(@DebitCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'D.DebitCode') +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode3, 'A.AtomAcntCode') + ' )' 
	If	(@DebitCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'D.DebitCode') +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @DebitCode4, 'A.AtomAcntCode') + ' )' 

	If	(@CreditCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'D.CreditCode')  +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode1, 'A.AtomAcntCode') + ' )' 
	If	(@CreditCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'D.CreditCode')  +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode2, 'A.AtomAcntCode') + ' )' 
	If	(@CreditCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'D.CreditCode')  +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode3, 'A.AtomAcntCode') + ' )' 
	If	(@CreditCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND (' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'D.CreditCode')  +' or ' + pub.funGetFilterString(@SessionNo, @ReportID, @CreditCode4, 'A.AtomAcntCode') + ' )' 

	If	(@VisitorCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode') 
	If	(@VisitorCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode') 
	If	(@VisitorCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode') 
	If	(@VisitorCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode') 

	If	(@CollectorCode1 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode1, 'H.CollectorAcntCode') 
	If	(@CollectorCode2 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode2, 'H.CollectorAcntCode') 
	If	(@CollectorCode3 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode3, 'H.CollectorAcntCode') 
	If	(@CollectorCode4 > 0)
		SET @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @CollectorCode4, 'H.CollectorAcntCode') 

	If	(@SerialNoFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	If	(@SerialNoTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If	(@DateFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.DocDate >= ''' + @DateFr + ''''
	If	(@DateTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.DocDate <= ''' + @DateTo + ''''

	If	(@UsanceDateFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.ChequeDate >= ''' + @UsanceDateFr + ''''
	If	(@UsanceDateTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.ChequeDate <= ''' + @UsanceDateTo + ''''

	If	(@AmountFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.Amount >= ' + LTrim(Str(@AmountFr))
	If	(@AmountTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.Amount <= ' + LTrim(Str(@AmountTo))

	If	(@ChequeNoFr Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.ChequeNo >= ''' + LTrim(@ChequeNoFr) + ''''
	If	(@ChequeNoTo Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.ChequeNo <= ''' + LTrim(@ChequeNoTo) + ''''

	If	(@PayTypeID Is Not Null)
		SET @StrSelect = @StrSelect + ' AND D.PayTypeID = ' + LTrim(Str(@PayTypeID)) 

	If (@DescMask Is Not Null)
		SET @StrSelect = @StrSelect + ' AND (Replace(H.DescHdr, '' '', '''') LIKE N''%' + RTrim(Replace(@DescMask, ' ', '')) + '%'')'
		
		--------------------------------------------------------------------------------------------
	Declare @DonotFilterAcc2Trs AS bit
	SET @DonotFilterAcc2Trs = 0
	SELECT @DonotFilterAcc2Trs = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DonotFilterAcc2Trs'
		
if @DonotFilterAcc2Trs=0 	
begin
			
	
	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;

	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);


	BEGIN TRY
		DROP TABLE #tblAcntCode
		DROP TABLE #tblOurBanks
	END TRY
	BEGIN CATCH
	END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 CREATE TABLE #tblOurBanks
	(
		CreditCode 			Varchar(20)collate arabic_cs_as null
	)
	if (@UserIsAdmin = 0)
	begin
	
		if @ProcessID =2 
		 begin
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and  ( D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) 
												or   D.CreditCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		end 
	 if @ProcessID =1 
		begin 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
			Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
			SET @StrSelect =  @StrSelect + '  and (  D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks     ) 
												or   D.DebitCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) )'
		end 
		if @ProcessID =40
		begin 
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
			Insert into  #tblOurBanks (CreditCode) SELECT  Distinct DebitCode	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblOurBanks', 'CreditCode', 'trs.tblOurBanks', @UserID; 
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct CreditCode	FROM       trs.tblPayDtl
				Insert into  #tblAcntCode (AcntCode) SELECT  Distinct DebitCode 	FROM       trs.tblPayDtl
			exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID; 
		
			SET @StrSelect =  @StrSelect + '  and ( ( D.DebitCode in (SELECT   CreditCode	FROM  #tblOurBanks    ) or  D.CreditCode in (SELECT   CreditCode	FROM  #tblOurBanks    )  )
												 or   ( D.DebitCode in (SELECT   AcntCode		FROM  #tblAcntCode    ) or  D.CreditCode in (SELECT   AcntCode		FROM  #tblAcntCode    )  ) ) '
		end 


	end 
	
Delete From  #tblAcntCode where AcntCode='' or AcntCode is null
Delete From  #tblOurBanks where CreditCode='' or CreditCode is null
		
			
end
	-- Sort ------------------------------------------------------------------------------------
	Set @StrSelect = @StrSelect + ' )a where Amount>0 ORDER BY ' + @SortFields
	--------------------------------------------------------------------------------------------
	Print @StrSelect1;
	Print @StrSelect;	
	Set @StrSelect = @StrSelect1 + @StrSelect

	Exec sp_executesql @StrSelect;
END
GO
