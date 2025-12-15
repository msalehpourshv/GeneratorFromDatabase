USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE sal.RptSaleOrder_Docs_Detailed_SHV
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@SerialNoFr		Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoTo		Int = NULL,
	@DocDateFr		Char(10) = NULL,
	@DocDateTo		Char(10) = NULL,
	@OrdDateFr		Char(10) = NULL,
	@OrdDateTo		Char(10) = NULL,
	@DelDateFr		Char(10) = NULL,
	@DelDateTo		Char(10) = NULL,
	@SelectedOrder1	Int = NULL,
	@SelectedOrder2	Int = NULL,
	@SelectedOrder3	Int = NULL,
	@SelectedOrder4	Int = NULL,
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@SelectedGoods	Int = NULL,
	@SortFields		NVarChar(100) = NULL,
	@RepOptions		NVarChar(20) = '211', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrSelect1	NVarChar(Max);
DECLARE @StrSelect2	NVarChar(Max);
DECLARE @StrSelect3	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrRem		NVARCHAR(max);
DECLARE @StrWhere2	NVarChar(1000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @UserID		VarChar(10);
DECLARE @AgreeNo    NVarchar(50)

DECLARE @RemainOnly	bit;    -- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
DECLARE @DecRet		bit;
DECLARE	@UserIsAdmin	bit;
DECLARE @DocStep	Int;
DECLARE @round_val	int;

DECLARE @SgnSN1		TinyInt;
DECLARE @SgnSN2		TinyInt;
DECLARE @SgnSN3		TinyInt;
DECLARE @SgnSN4		TinyInt;
DECLARE @SgnSN5		TinyInt;

DECLARE @db_0000    NVarchar(50)
SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

DECLARE @GetRemainSaleOrder AS bit;

DECLARE @SelectedStore Int;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '1';
	IF (@ProcessNo	Is Null)	SET @ProcessNo  = 1;

	If (@FiscalYearFr	Is Null) SET @SerialNoFr	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;
	If (@SerialNoFr		Is Null) SET @FiscalYearFr	= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;
	If (@SortFields		Is Null) SET @SortFields    = 'FiscalYear, SerialNo';

	IF (@SelectedGoods  Is Null) SET @SelectedGoods = 0;

	IF (@SelectedOrder1 Is Null) SET @SelectedOrder1 = 0;
	IF (@SelectedOrder2 Is Null) SET @SelectedOrder2 = 0;
	IF (@SelectedOrder3 Is Null) SET @SelectedOrder3 = 0;
	IF (@SelectedOrder4 Is Null) SET @SelectedOrder4 = 0;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	SET @DecRet			= Substring(@RepOptions, 1, 1);
	SET @DocStep		= Substring(@RepOptions, 2, 1);
	SET @RemainOnly		= Substring(@RepOptions, 3, 1);
	SET @SgnSN1			= Substring(@RepOptions, 5, 1);
	SET @SgnSN2			= Substring(@RepOptions, 6, 1);
	SET @SgnSN3			= Substring(@RepOptions, 7, 1);
	SET @SgnSN4			= Substring(@RepOptions, 8, 1);
	SET @SgnSN5			= Substring(@RepOptions, 9, 1);	
	SET @SelectedStore	= Substring(@RepOptions, 10, 1);	

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin = pub.funSplitString(@RepInfo, '@', 5);
	SET @AgreeNo		= pub.funSplitString(@RepInfo, '@', 7);		

	
	SET @GetRemainSaleOrder = 'False'
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	select @round_val = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'	
	
	IF @GetRemainSaleOrder = 'False'
		SET @DecRet = 'False'
	
	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID   Int,
		UserSign Image
	);
	
	SET @StrSelect = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@db_0000)) + '.usr.tblUsers U '
		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
	UPDATE inv.tblStorageDocsDtl 
	SET BaseDocRowNo = A.DocRowNo,BaseProcessNo=A.ProcessNo
	--select *
	FROM inv.tblStorageDocsDtl B INNER JOIN 
	sal.tblSaleOrderDtl A 
	ON A.ProcessID=B.BaseProcessID AND --A.ProcessNo=B.BaseProcessNo  AND 
	A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND 
	A.GoodsID=B.GoodsID AND A.DocRowNo<>B.BaseDocRowNo AND B.BaseProcessNo=0 and (B.IsReward='False' and B.IsReward0='False')
	AND A.AcntCode=B.AcntCode
	AND A.GoodsID NOT IN (SELECT GoodsID 
	FROM sal.tblSaleOrderDtl AA 
	WHERE AA.ProcessID = 180 AND AA.ProcessID=A.ProcessID AND 
	AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo 
	GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID 
	HAVING COUNT(GoodsID)>1)
	-- W H E R E --------------------------------------------------------------
	--SET @StrWhere = ' (D.AutoOrder = 0) and D.ProcessID  = ' + @StrPID_ORD + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	SET @StrWhere = '(D.ProcessID=180) AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ') OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '
	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate>=''' + @DocDateFr + ''')'
	If (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DocDateTo + ''')'

	If (@OrdDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.OrderDate>=''' + @OrdDateFr + ''')'
	If (@OrdDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.OrderDate<=''' + @OrdDateTo + ''')'

	If (@DelDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DeliveryDate>=''' + @DelDateFr + ''')'
	If (@DelDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DeliveryDate<=''' + @DelDateTo + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID')

	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND (D.StoreID = '''' OR ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore , 'D.StoreID') + ')'

	-- Acnt
	IF	(@SelectedOrder1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder1, 'D.AcntCode') 
	IF	(@SelectedOrder2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder2, 'D.AcntCode') 
	IF	(@SelectedOrder3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder3, 'D.AcntCode') 
	IF	(@SelectedOrder4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedOrder4, 'D.AcntCode') 

	-- Visitor
	IF	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	IF	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	IF	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	IF	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	IF (@SgnSN1 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN1 > 0)'
	--ELSE IF	(@SgnSN1 = 0)
	--	SET @StrWhere = @StrWhere + ' AND (H.SgnSN1 = 0)'
		
	IF (@SgnSN2 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN2 > 0)'
	--ELSE IF	(@SgnSN2 = 0)
	--	SET @StrWhere = @StrWhere + ' AND (H.SgnSN2 = 0)'
		
	IF (@SgnSN3 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN3 > 0)'
	--ELSE IF (@SgnSN3 = 0)
	--	SET @StrWhere = @StrWhere + ' AND (H.SgnSN3 = 0)'
		
	IF (@SgnSN4 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN4 > 0)'
	--ELSE IF (@SgnSN4 = 0)
	--	SET @StrWhere = @StrWhere + ' AND (H.SgnSN4 = 0)'
		
	IF (@SgnSN5 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN5 > 0)'
	--ELSE IF (@SgnSN5 = 0)
	--	SET @StrWhere = @StrWhere + ' AND (H.SgnSN5 = 0)'							
	
	-- DocStep
	IF (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep=' + Str(@DocStep) + ')'
	if  @AgreeNo is not null and @AgreeNo<>''
		SET @StrWhere = @StrWhere + ' And H.AgreeNo =''' + ltrim(rtrim(@AgreeNo))+ ''''	
	
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	IF @GetRemainSaleOrder = 'True'
		SET @StrSelect2 = 'AND SD.BaseDocRowNo = D.DocRowNo AND SD.GoodsID=D.GoodsID '
	Else
		SET @StrSelect2 = ''
	
	IF @GetRemainSaleOrder = 'False'
		set @StrRem = ' (SELECT DISTINCT S.ProcessID, S.ProcessNo, S.FiscalYear, S.SerialNo, S.RowNo, S.DocRowNo, 
									     S.DocStep, S.DocDate, S.AcntCode, S.GoodsID, S.SubUnitID, S.SubUnitQuantity, 
									     S.ConfirmQuantity, S.GoodsQuantity, S.GoodsPrice, S.DescDtl, S.BaseDocType, 
									     S.BaseProcessID, S.BaseProcessNo, S.BaseFiscalYear, S.BaseSerialNo, 
									     S.BaseDocRowNo, S.AgreeNo, S.OrderDate, S.DeliveryDate, S.VisitorAcntCode, 
									     S.IsReward, S.SubUnitPrice, S.AutoOrder, S.TransferSerialNo, S.DiscountPercentDtl, 
									     S.DiscountDtl, S.VisitorPercent, S.SaleTypeID, S.SubUnitPrice2, S.SubUnitQuantity2, 
									     S.TaxOverWorthCostDtl, S.TollOverWorthCostDtl, S.CurrencyAmount, S.VisitorAcntCode2, 
									     S.VisitorPercent2, S.ConstText1, S.ConstText2, S.ConstText3, S.ConstText4, S.StoreID 
						 FROM sal.tblSaleOrderDtl S 
						 INNER JOIN
						 (
							SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
							WHERE ProcessID=180  
							EXCEPT
							SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
							WHERE BaseProcessID=180 AND ProcessID=90  
						) A
						ON A.ProcessID=S.ProcessID AND A.ProcessNo=S.ProcessNo AND A.FiscalYear=S.FiscalYear AND 
						   A.SerialNo=S.SerialNo) '
	ELSE
		set @StrRem = ' sal.tblSaleOrderDtl '						   

			
	IF (@DecRet = 1) 
		SET @StrSelect = '
			(
			 SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
			 FROM    inv.tblStorageDocsDtl
			 WHERE   (ProcessID=100) AND BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND 
					 BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND BaseDocRowNo = SD.DocRowNo
			)'
	Else
		SET @StrSelect = 'cast(0 as float)'
	
	DECLARE @CountCustomerKind  INT;
	
	if (select COUNT(*)  from sys.tables where name='tbl_CDescription')=0
	BEGIN
		EXEC [sal].[SpGetCustomreGoodsDescription]
	END

	Select @CountCustomerKind = Count(*)
	From sal.tbl_CDescription
	where CDescription<>''
		
		--Select * from #tbl_CDescription
		
	SET @StrSelect1 = '
	SELECT T.*,inv.funGetSubUnitFromGoodsQuantity (T.GoodsID,T.UnitID,SoldQuantity)	SoldQuantity2,	inv.funGetSubUnitFromGoodsQuantity (T.GoodsID,T.UnitID,QtyAfterCancel)	QtyAfterCancel2,
	[pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode,
		   [pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName, F.Address1, F.Address2, F.Tel, F.Mobile, F.Fax,
			(
			 SELECT  IsNull(Sum(GoodsQuantity * EnterKind),0) 
			 FROM   inv.tblStorageDocsDtl
			 WHERE  GoodsID = T.GoodsID AND (T.StoreID = '''' OR T.StoreID Is Null OR StoreID = T.StoreID) AND 
					DocDate <= T.DocDate AND BatchNo = '''' --AND (EnterKind=1) 
			) As GoodsRemain
			--[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,T.StoreID,T.GoodsID,'''',T.DocDate,0) GoodsRemain			
			,'+ Case When @CountCustomerKind > 0 Then ' IsNull(DS.CDescription, '''')' Else ' T.GoodsID' End + '
			BarCodeFromPrice,isnull(TechnicalNo,'''') TechnicalNo,IsNull(GoodsWeight,0) GoodsWeight
			INTO ##SaleOrder_Docs_Detailed
	FROM
	(
		SELECT	D.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo, D.DocDate, H.DocDesc,[sal].[funGetSaleOrderPureAmount](H.SerialNo,H.ProcessNo, H.FiscalYear) PureAmount , D.AcntCode, D.GoodsID, H.StoreID,
				D.SubUnitID UnitID, UD.UnitName, D.OrderDate, D.DeliveryDate, H.DeliveryDate DeliveryDateHdr, D.AgreeNo, D.DescDtl,   GoodsQuantity,
				D.VisitorAcntCode, pub.GetCodeName(D.VisitorAcntCode,'+ LTrim(RTrim(Str(@LangID))) +') AS VisitorName,D.GoodsPrice,D.SubUnitPrice,D.SubUnitPrice2,
		        pub.UN(H.SessionNo) UserName,pub.UN(H.SessionNo2) UserName1, H.PayOffTypeID, H.DocTime, H.SendTime, H.SendDate,
				Case When H.SgnSN1=0 Then '''' Else pub.GetUserName(H.SgnSN1) End Signer1Name,
				Case When H.SgnSN2=0 Then '''' Else pub.GetUserName(H.SgnSN2) End Signer2Name,
				Case When H.SgnSN3=0 Then '''' Else pub.GetUserName(H.SgnSN3) end Signer3Name,
				Case When H.SgnSN4=0 Then '''' Else pub.GetUserName(H.SgnSN4) End Signer4Name,
				Case When H.SgnSN5=0 Then '''' Else pub.GetUserName(H.SgnSN5) End Signer5Name,
				Case When H.SgnSN1=0 Then '''' Else N''تائید کننده 1, '' End +
				Case When H.SgnSN2=0 Then '''' Else N''تائید کننده 2, '' End +
				Case When H.SgnSN3=0 Then '''' Else N''تائید کننده 3, '' End +
				Case When H.SgnSN4=0 Then '''' Else N''تائید کننده 4, '' End +
				Case When H.SgnSN5=0 Then '''' Else N''تائید کننده 5, '' End As Confirmers,
				S1.UserSign As UserSignature1,
				S2.UserSign As UserSignature2,
				S3.UserSign As Signature1,
				S4.UserSign As Signature2,
				S5.UserSign As Signature3,
				S6.UserSign As Signature4,
				S7.UserSign As Signature5,
				(
				 SELECT	IsNull(Sum(GoodsQuantity), 0)
				 FROM	sal.tblSaleOrderDtl
				 WHERE	BaseProcessID=D.ProcessID AND BaseProcessNo=D.ProcessNo AND BaseFiscalYear=D.FiscalYear AND BaseSerialNo=D.SerialNo AND BaseDocRowNo=D.DocRowNo
				) AS CancelQuantity,' 
	SET @StrSelect2 = '
				isnull((
					-- Sold Pure Qty = sum of sold qty - sum of sold return qty
					SELECT Sum(Sold - SoldRet)
					FROM
					(
						SELECT	GoodsQuantity AS Sold, ' + @StrSelect + ' AS SoldRet
						FROM	inv.tblStorageDocsDtl SD
						WHERE	(SD.ProcessID=90) AND SD.BaseProcessID = D.ProcessID AND SD.BaseProcessNo = D.ProcessNo AND SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo ' + @StrSelect2 + '
					) SNR
				),0) AS SoldQuantity,
				D.GoodsQuantity - (
									SELECT	IsNull(Sum(GoodsQuantity), 0)
									FROM	sal.tblSaleOrderDtl
									WHERE	BaseProcessID=D.ProcessID AND BaseProcessNo=D.ProcessNo AND BaseFiscalYear=D.FiscalYear AND BaseSerialNo=D.SerialNo AND BaseDocRowNo=D.DocRowNo
								   ) AS QtyAfterCancel								   
		FROM ' + @StrRem + ' AS D
		INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		LEFT JOIN inv.tblUnitsDtl UD ON UD.UnitID = D.SubUnitID
		LEFT  JOIN #tbl_Invoice_Signatures S1 on S1.UserID = ' + LTrim(RTrim(@db_0000)) + '.[pub].[funGetUserID](H.SessionNo)
		LEFT  JOIN #tbl_Invoice_Signatures S2 on S2.UserID = ' + LTrim(RTrim(@db_0000)) + '.[pub].[funGetUserID](H.SessionNo2)
		LEFT  JOIN #tbl_Invoice_Signatures S3 on S3.UserID = ' + LTrim(RTrim(@db_0000)) + '.[pub].[funGetUserID](H.SgnSN1)
		LEFT  JOIN #tbl_Invoice_Signatures S4 on S4.UserID = ' + LTrim(RTrim(@db_0000)) + '.[pub].[funGetUserID](H.SgnSN2)
		LEFT  JOIN #tbl_Invoice_Signatures S5 on S5.UserID = ' + LTrim(RTrim(@db_0000)) + '.[pub].[funGetUserID](H.SgnSN3)
		LEFT  JOIN #tbl_Invoice_Signatures S6 on S6.UserID = ' + LTrim(RTrim(@db_0000)) + '.[pub].[funGetUserID](H.SgnSN4)
		LEFT  JOIN #tbl_Invoice_Signatures S7 on S7.UserID = ' + LTrim(RTrim(@db_0000)) + '.[pub].[funGetUserID](H.SgnSN5)
		WHERE ' + @StrWhere + '
	) T 
	--LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(T.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' AND G.LanguageID = ' + @LangID + '
	LEFT JOIN inv.tblGoods G ON G.GoodsID = SUBSTRING(T.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' --AND G.LanguageID = ' + @LangID + '
	
	 '+	Case When @CountCustomerKind > 0 Then '
				LEFT JOIN sal.tbl_CDescription DS ON DS.CustomerKindID = [pub].[funGetCustomerKindID] (T.AcntCode) AND DS.GoodsID = T.GoodsID '
				Else '' End+'
	OUTER APPLY [acc].[funGetCodeInfo](T.AcntCode) AS F	' 
	
	Print @StrSelect1
	Print @StrSelect2
	SET @StrSelect = @StrSelect1 + @StrSelect2

	IF @GetRemainSaleOrder = 'True'
		SET @StrWhere2 = 'WHERE (Round(T.SoldQuantity,' + str(@round_val) + ') < Round(T.GoodsQuantity-T.CancelQuantity,' + str(@round_val) + '))'
	Else
		SET @StrWhere2 = 'WHERE Round(T.SoldQuantity, ' + str(@round_val) + ') <= 0 And Round(T.QtyAfterCancel, ' + str(@round_val) + ') > 0'
	
	If (@RemainOnly = 1)
	SET @StrSelect = @StrSelect + ' ' + @StrWhere2
	
	--Print @StrWhere2
	
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	
	Print 'ORDER BY ' + @SortFields

	begin try
		drop table ##SaleOrder_Docs_Detailed
	end try
	begin catch
	end catch

	---------------------------------------------------------------------------
	---- R U N ----------------------------------------------------------------
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------

	IF @UserIsAdmin=0
	begin
		 exec pub.SpFilterByPermission2 '##SaleOrder_Docs_Detailed', 'AcntCode', 'acc.tblAcnt', @UserID;
		 exec pub.SpFilterByPermission2 '##SaleOrder_Docs_Detailed', 'GoodsID', 'inv.tblGoods', @UserID;
	END
	
	-- ====================================================================== Select
	--SELECT a.*, b.UnitID  UnitIDBase , U.UnitName UnitNameBase, isnull(UnitValue,1)UnitValue, isnull(MainUnitValue,1)MainUnitValue, isnull(SubUnitID,'') SubUnitID,
	--       isnull(U2.UnitName ,'') UnitNameSubUnitID,
	--      (SELECT Top 1 ManualUserPrice  
	--	   FROM sal.tblGoodsPriceForCustomerKindDtl D 
	--	   inner join sal.tblGoodsPriceForCustomerKindHdr H on D.SerialNo=H.SerialNo 
	--	   where GoodsID=a.GoodsID and FromDate<=a.DocDate 
	--	   order by DocDate Desc, D.SerialNo Desc) ManualUserPrice 
	--FROM ##SaleOrder_Docs_Detailed a
	--inner join inv.tblGoods b 	ON SUBSTRING(a.GoodsID,@str_Goods+1,@str_GoodsSum)=b.GoodsID AND b.PartNumber=@UnitPart 
	--LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = b.UnitID
	--LEFT JOIN inv.tblSubUnitsDtl UD ON UD.GoodsID = b.GoodsID and ShowInInvoice=1
	--LEFT JOIN inv.tblUnitsDtl U2 ON U2.UnitID = UD.SubUnitID

	-- ====================================================================== Last Select
	SELECT a.FiscalYear, a.SerialNo, a.DocDate, a.GoodsID, a.GoodsName, a.AcntCode, AcntName, a.VisitorAcntCode, a.VisitorName,
	       a.QtyAfterCancel2 - a.SoldQuantity2 SaleOrder_Remain
	       
	FROM ##SaleOrder_Docs_Detailed a
	inner join inv.tblGoods b 	ON SUBSTRING(a.GoodsID,@str_Goods+1,@str_GoodsSum)=b.GoodsID AND b.PartNumber=@UnitPart 
	LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = b.UnitID
	LEFT JOIN inv.tblSubUnitsDtl UD ON UD.GoodsID = b.GoodsID and ShowInInvoice=1
	LEFT JOIN inv.tblUnitsDtl U2 ON U2.UnitID = UD.SubUnitID
	WHERE 1 = 1
	  --And a.GoodsID IN('41070335002024')

END
GO
