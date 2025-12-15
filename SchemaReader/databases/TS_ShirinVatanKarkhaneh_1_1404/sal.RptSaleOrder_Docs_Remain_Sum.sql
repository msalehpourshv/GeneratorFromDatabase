USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1387/02/14
-- Viewed By	 : 
-- Last Modified : 1393/06/31
-- Last Modifier : TakroSystem\Hamid
-- Description   : لیست سفارشات فروش- خلاصه
-- =============================================
Create PROCEDURE [sal].[RptSaleOrder_Docs_Remain_Sum]
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = NULL,
	@FiscalYearTo	Int = NULL,
	@SerialNoFr		Int = NULL,
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
DECLARE @StrSelect2	NVarChar(Max);
DECLARE @StrSelect3	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @UserID		VarChar(10);
DECLARE @UserID2	VarChar(10);
DECLARE @AgreeNo    NVarchar(50)
DECLARE	@UserIsAdmin	bit;

DECLARE @DocStep	Int;
DECLARE @RemainOnly	Bit;    -- فقط سفارشاتی که مانده دارند (سفارش با تحویل برابر نیست) بیاید؟
DECLARE @DecRet		bit;
DECLARE @round_val	int;

DECLARE @db_0000    NVarchar(50)

DECLARE @SgnSN1		TinyInt;
DECLARE @SgnSN2		TinyInt;
DECLARE @SgnSN3		TinyInt;
DECLARE @SgnSN4		TinyInt;
DECLARE @SgnSN5		TinyInt;

DECLARE @GetRemainSaleOrder AS  Nvarchar(5);
DECLARE @SelectedStore Int;

Begin --============== S T A R T  C O D E ===================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '1';
	IF (@ProcessNo	   Is Null) SET @ProcessNo  = 1;

	IF (@SelectedOrder1 Is Null)	SET @SelectedOrder1 = 0;
	IF (@SelectedOrder2 Is Null)	SET @SelectedOrder2 = 0;
	IF (@SelectedOrder3 Is Null)	SET @SelectedOrder3 = 0;
	IF (@SelectedOrder4 Is Null)	SET @SelectedOrder4 = 0;

	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;

	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;

	If (@FiscalYearFr	Is Null) SET @SerialNoFr	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;
	If (@SerialNoFr		Is Null) SET @FiscalYearFr	= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;
	If (@SortFields		Is Null) SET @SortFields    = 'FiscalYear, SerialNo';

	SET @DecRet		= Substring(@RepOptions, 1, 1);
	SET @DocStep	= Substring(@RepOptions, 2, 1);
	SET @RemainOnly	= Substring(@RepOptions, 3, 1);
	SET @SgnSN1		= Substring(@RepOptions, 5, 1);
	SET @SgnSN2		= Substring(@RepOptions, 6, 1);
	SET @SgnSN3		= Substring(@RepOptions, 7, 1);
	SET @SgnSN4		= Substring(@RepOptions, 8, 1);
	SET @SgnSN5		= Substring(@RepOptions, 9, 1);
	SET @SelectedStore	= Substring(@RepOptions, 10, 1);	
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);
	SET @UserID2		= pub.funSplitString(@RepInfo, '@', 6);	
	SET @AgreeNo		= pub.funSplitString(@RepInfo, '@', 7);		
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	DECLARE @UnitPart TINYINT
	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	SET @UnitPart  = 1
	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	SET @GetRemainSaleOrder = 'False'
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	select @round_val = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'	

	SEt @StrWhere2 = ''
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
	--SET @StrWhere = ' (D.AutoOrder = 0) and D.ProcessID  = ' + LTrim(Str(@StrPID_ORD)) + ' AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	SET @StrWhere = '(D.ProcessID=180) AND (D.ProcessNo=' + LTrim(Str(@ProcessNo)) + ')'

	If (@FiscalYearFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

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

	IF	(@SelectedGoods > 0)
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
	ELSE IF	(@SgnSN1 = 0)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN1 = 0)'
		
	IF (@SgnSN2 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN2 > 0)'
	ELSE IF	(@SgnSN2 = 0)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN2 = 0)'
		
	IF (@SgnSN3 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN3 > 0)'
	ELSE IF (@SgnSN3 = 0)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN3 = 0)'
		
	IF (@SgnSN4 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN4 > 0)'
	ELSE IF (@SgnSN4 = 0)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN4 = 0)'
		
	IF (@SgnSN5 = 1)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN5 > 0)'
	ELSE IF (@SgnSN5 = 0)
		SET @StrWhere = @StrWhere + ' AND (H.SgnSN5 = 0)'
				
	-- DocStep
	If (@DocStep > 0)
		SET @StrWhere = @StrWhere + ' AND (D.DocStep=' + Str(@DocStep) + ')'
		
	-- UserID
	If (@UserID2 > -1)
		SET @StrWhere = @StrWhere + ' AND (' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo) = ' + LTrim(RTrim(Str(@UserID2))) + ')'	
		
	if  @AgreeNo is not null and @AgreeNo<>''
		SET @StrWhere = @StrWhere + ' And H.AgreeNo =''' + ltrim(rtrim(@AgreeNo))+ ''''	
	---------------------------------------------------------------------------------
		BEGIN TRY
			DROP TABLE #tblAcntCode
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 Insert into  #tblAcntCode (AcntCode) SELECT  Distinct AcntCode	FROM  sal.tblSaleOrderDtl

	if @UserIsAdmin=0
	begin
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		SET @StrWhere =   @StrWhere + '  and   D.AcntCode in (SELECT   AcntCode	FROM  #tblAcntCode    ) '		 
	END	 
			
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	IF @GetRemainSaleOrder = 'True'
		SET @StrSelect2 = 'AND SD.BaseDocRowNo = D.DocRowNo'
	Else
		SET @StrSelect2 = ''

	if (@DecRet = 1) 
		set @StrSelect = '
								(
									SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
									FROM    inv.tblStorageDocsDtl
									WHERE   (ProcessID=100) and BaseProcessID=SD.ProcessID AND BaseProcessNo=SD.ProcessNo AND BaseFiscalYear=SD.FiscalYear AND BaseSerialNo=SD.SerialNo AND BaseDocRowNo=SD.DocRowNo
								)'
	else
		set @StrSelect = 'cast(0 as float)'

	If (@RemainOnly = 1)
	BEGIN
		IF @GetRemainSaleOrder = 'True'
			SET @StrWhere2 = '
			WHERE (Round(T.SoldQuantity,' + LTrim(RTrim(Str(@round_val))) + ') < Round(T.GoodsQuantity - T.CancelQuantity,' + LTrim(RTrim(Str(@round_val))) + '))'
		Else
			SET @StrWhere2 = '
			WHERE Round(T.SoldQuantity, ' + LTrim(RTrim(Str(@round_val))) + ')=0 AND (Round(T.GoodsQuantity, ' + LTrim(RTrim(Str(@round_val))) + ') - Round(T.CancelQuantity, ' + LTrim(RTrim(Str(@round_val))) + ')) > 0'
	END
	
	Set @StrSelect = '
	SELECT	DISTINCT T.*, [pub].GetCodeName(T.AcntCode, ' + @LangID + ') As AcntName, F.Address1, F.Address2, F.Tel, 
			F.Mobile, F.Fax, Case When T.SgnSN1=0 Then '''' Else pub.GetUserName(T.SgnSN1) End Signer1Name,
			Case When T.SgnSN2=0 Then '''' Else pub.GetUserName(T.SgnSN2) End Signer2Name,
			Case When T.SgnSN3=0 Then '''' Else pub.GetUserName(T.SgnSN3) end Signer3Name,
			Case When T.SgnSN4=0 Then '''' Else pub.GetUserName(T.SgnSN4) End Signer4Name,
			Case When T.SgnSN5=0 Then '''' Else pub.GetUserName(T.SgnSN5) End Signer5Name,
			pub.UN(T.SessionNo) UserName,pub.UN(T.SessionNo2) UserName1,
			pub.GetCodeName(T.VisitorAcntCode,'+ LTrim(RTrim(Str(@LangID))) +') AS VisitorName,
			[inv].[funGetSaleOrderGoodsWeight] (180, 1 ,T.FiscalYear, T.SerialNo) GoodsWeightSum, 			
			[inv].[funGetSaleOrderGoodsWeightRemain] (180, 1 ,T.FiscalYear, T.SerialNo,T.AcntCode,T.DocDate,T.DocStep)  GoodsWeightRemain,
			' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](T.SessionNo)  As UserID
	FROM
	(
	SELECT * FROM (
		SELECT D.DocStep,D.FiscalYear, D.SerialNo, D.DocDate, D.AcntCode, D.OrderDate, D.DeliveryDate, D.DocDesc, D.PayOffTypeID, D.PayOffTypeName,
			   Sum(D.GoodsQuantity) GoodsQuantity, Sum(D.GoodsWeight) GoodsWeight, Sum(CancelQuantity) CancelQuantity, Sum(SoldQuantity) SoldQuantity,
			   Sum(D.GoodsQuantity) - Sum(D.CancelQuantity) As QtyAfterCancel, 
			   Sum((D.GoodsQuantity-D.CancelQuantity) * D.GoodsPrice - D.DiscountDtl+ TaxToll) Price,
			   D.SgnSN1,D.SgnSN2,D.SgnSN3,D.SgnSN4,D.SgnSN5,D.SessionNo,D.SessionNo2, Confirmers, D.VisitorAcntCode, 
			   D.DocTime, D.SendTime, D.SendDate
		FROM
		(
			SELECT	H.DocStep,D.FiscalYear, D.SerialNo, D.DocDate, D.AcntCode, D.OrderDate, H.DeliveryDate,DocDesc,GoodsQuantity,
			(case when SubUnitQuantity = 0 THEN D.ConfirmQuantity ELSE (D.ConfirmQuantity*GoodsQuantity/SubUnitQuantity) END)* GoodsWeight GoodsWeight,
					D.GoodsPrice, D.SubUnitPrice, D.DiscountDtl, D.TaxOverWorthCostDtl + D.TollOverWorthCostDtl TaxToll, D.VisitorAcntCode, 
					 H.DocTime, H.SendTime, H.SendDate,
					H.SgnSN1,H.SgnSN2,H.SgnSN3,H.SgnSN4,H.SgnSN5,H.SessionNo,H.SessionNo2,
					Case When H.SgnSN1=0 Then '''' Else N''تائید کننده 1, '' End +
					Case When H.SgnSN2=0 Then '''' Else N''تائید کننده 2, '' End +
					Case When H.SgnSN3=0 Then '''' Else N''تائید کننده 3, '' End +
					Case When H.SgnSN4=0 Then '''' Else N''تائید کننده 4, '' End +
					Case When H.SgnSN5=0 Then '''' Else N''تائید کننده 5, '' End As Confirmers,
					(
						SELECT	IsNull(Sum(GoodsQuantity), 0)
						FROM	sal.tblSaleOrderDtl
						WHERE	(ProcessID = 185) and BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND 
								 BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
					) AS CancelQuantity,
					(
						-- Sold Pure Qty = sum of sold qty - sum of sold return qty
						SELECT IsNull(Sum(Sold - SoldRet), 0)
						FROM
						(
							SELECT	GoodsQuantity AS Sold, ' + @StrSelect + ' AS SoldRet
							FROM	inv.tblStorageDocsDtl SD
							WHERE	(SD.ProcessID = 90) AND SD.BaseProcessID = D.ProcessID AND SD.BaseProcessNo = D.ProcessNo AND 
									 SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo ' + @StrSelect2 + '  AND SD.GoodsID=D.GoodsID
						) SaleAndRet
					) AS SoldQuantity, H.PayOffTypeID, P.PayOffTypeName '
	Set @StrSelect3 = '
			FROM	sal.tblSaleOrderDtl D
			inner join  inv.tblGoods b	on SUBSTRING(D.GoodsID,'+str(@str_Goods+1)+','+str(@str_GoodsSum)+')=b.GoodsID and b.PartNumber='+str(@UnitPart)+'
			INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			LEFT JOIN sal.tblPayOffTypesDtl P ON P.PayOffTypeID = H.PayOffTypeID AND P.LanguageID = ' + @LangID + '
			WHERE   ' + @StrWhere + '
		) D
		GROUP BY D.DocStep,D.FiscalYear, D.SerialNo, D.DocDate, D.AcntCode, D.OrderDate, D.DeliveryDate, D.DocDesc,
		         D.SgnSN1,D.SgnSN2,D.SgnSN3,D.SgnSN4,D.SgnSN5,D.SessionNo,D.SessionNo2, Confirmers,
		         D.DocTime, D.SendTime, D.SendDate, D.VisitorAcntCode, D.PayOffTypeID, D.PayOffTypeName
	 ) T ' + ' ' + @StrWhere2 + '
	) T 
	OUTER APPLY [acc].[funGetCodeInfo](T.AcntCode) AS F	' 

	SET @StrSelect3 = @StrSelect3 + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	PRINT @StrSelect;
	PRINT @StrSelect3;
	SET @StrSelect = @StrSelect + @StrSelect3
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
