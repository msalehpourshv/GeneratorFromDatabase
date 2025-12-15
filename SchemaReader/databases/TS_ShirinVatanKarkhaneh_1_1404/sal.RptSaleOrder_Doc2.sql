USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : ?
-- Viewed By	 : 
-- Last Modified : 1393/07/01
-- Last Modifier : TakroSystem\Hamid
-- Description   : برگ سفارش فروش
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_Doc2]
	@ProcessID			Int = 180, -- Sale Order Process ID
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@BaseProcessID		Int = 150,
	@BaseProcessNo		Int = Null,
	@BaseFiscalYear		Int = Null,
	@BaseSerialNo		Int = Null,
	@ShowTrsInfo		Bit = 0,
	@DocStep			Int = 0,
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @Db0000		VarChar(50);

select @Db0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

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
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	IF (@DocStep < 1)			SET @DocStep	 = Null;
	IF (@ProcessNo	  Is Null)	SET @ProcessNo   = 1;
	IF (@ShowTrsInfo  Is Null)	SET @ShowTrsInfo = 0;

	IF (@FiscalYearFr  Is Null)	SET @SerialNoFr	  = Null;
	IF (@FiscalYearTo  Is Null)	SET @SerialNoTo	  = Null;
	IF (@SerialNoFr	   Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	   Is Null)	SET @FiscalYearTo = Null;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID   Int,
		UserSign Image
	);
	
	SET @StrSelect = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@Db0000)) + '.usr.tblUsers U '
	
	print @StrSelect;
	exec sp_executesql @StrSelect;
	
	--============================= Where
	--SET @StrWhere = '(D.AutoOrder = 0) and D.ProcessID = ' + Str(@ProcessID) + ' AND D.ProcessNo = ' + Str(@ProcessNo)
	SET @StrWhere = 'D.ProcessID = ' + Str(@ProcessID) + ' AND D.ProcessNo = ' + Str(@ProcessNo)
	
	If (@FiscalYearFr	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DocStep Is Not Null) 
		Set @StrWhere = @StrWhere + ' AND (D.DocStep >= ' + Str(@DocStep) + ')'
		
	If (@BaseProcessID	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.BaseProcessID = ' + Str(@BaseProcessID) + ')'
		
	If (@BaseProcessNo	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.BaseProcessNo = ' + Str(@BaseProcessNo) + ')'
		
	If (@BaseFiscalYear	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear = ' + Str(@BaseFiscalYear) + ')'
		
	If (@BaseSerialNo	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo = ' + Str(@BaseSerialNo) + ')'				
				
	--============================= Select
	SET @StrSelect = '
	SELECT	D.*, F.*, H.DocDesc, H.VisitorAcntCode, U1.UnitName, U2.UnitName as SubUnitName, 
			[pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode,
			H.DiscountPercent As DiscountPercentHdr, H.Discount + H.Discount2 AS DiscountHdr, 
			H.TransportationCost, H.TransportationIncome, H.VisitorPercent As VisitorPercentHdr, H.VisitorCost, H.PackingCost, 
			H.TaxCost, H.TaxOverWorthCost, H.TollOverWorthCost, H.OtherCost, H.OtherIncome, 
			pub.GetCodeName(H.VisitorAcntCode, ' + @LangID + ') VisitorAcntName, 
			pub.funGetLocationName(F.LocationID, ' + @LangID + ') LocationName,
			sal.funGetSaleTypeName(H.SaleTypeID, ' + LTrim(RTrim(@LangID)) + ') SaleTypeName,
			acc.funAcntDebitRemain(D.AcntCode) DebitRemain,
			trs.funAcntUnReceiptRemain(D.AcntCode, 1) UnReceiptRemain,
			trs.funAcntReturnedRemain(D.AcntCode, 1) ReturnedRemain,
			pub.GetUserName(H.SessionNo) AS UserName,
			pub.GetUserName(H.SessionNo2) AS UserName2,
			(SELECT UserSignature from ' + @Db0000 + '.usr.tblUsers 
			where UserID= ' + @Db0000 + '.pub.funGetUserID(H.SessionNo) ) As UserSign,
			(SELECT UserSignature from ' + @Db0000 + '.usr.tblUsers 
			where UserID= ' + @Db0000 + '.pub.funGetUserID(H.SessionNo2) ) As UserSign2,			
			inv.funSubUnit2(D.GoodsID) UnitScale,
			inv.funSubUnit2Name(D.GoodsID) UnitNameX,
			GH.TechnicalSpecifications,GH.TechnicalNo, GH.MiscSpecifications,
			H.C1,H.C2,H.C3,H.C4,H.C5,H.C6,H.C7,H.C8,H.C9,H.C10,H.C11,H.C12,H.C13,H.C14,H.C15,H.B1,H.B2,H.B3,H.B4,H.B5,H.B6,H.B7,H.B8,H.B9,H.B10,H.B11,H.B12,H.B13,H.B14,H.B15,H.Reserved,
			pub.UN(SgnSN1) As SgnSN1, pub.UN(SgnSN2) As SgnSN2, pub.UN(SgnSN3) As SgnSN3, pub.UN(SgnSN4) As SgnSN4,
			pub.UN(SgnSN5) As SgnSN5, 
			S1.UserSign As UserSignature1,
			S2.UserSign As UserSignature2,
			S3.UserSign As Signature1,
			S4.UserSign As Signature2,
			S5.UserSign As Signature3,
			S6.UserSign As Signature4,
			S7.UserSign As Signature5

	FROM    sal.tblSaleOrderDtl AS D
	INNER JOIN [sal].[tblSaleOrderHdr] H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	
	LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			
	LEFT  JOIN [inv].tblUnitsDtl U1 ON U1.UnitID = GH.UnitID 
	LEFT  JOIN [inv].tblUnitsDtl U2 ON U2.UnitID = D.SubUnitID
	
	LEFT  JOIN #tbl_Invoice_Signatures S1 on S1.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo)
	LEFT  JOIN #tbl_Invoice_Signatures S2 on S2.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo2)
	
	LEFT  JOIN #tbl_Invoice_Signatures S3 on S3.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN1)
	LEFT  JOIN #tbl_Invoice_Signatures S4 on S4.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN2)
	LEFT  JOIN #tbl_Invoice_Signatures S5 on S5.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN3)
	LEFT  JOIN #tbl_Invoice_Signatures S6 on S6.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN4)
	LEFT  JOIN #tbl_Invoice_Signatures S7 on S7.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN5)
	
	OUTER APPLY [acc].funGetCodeInfo(D.AcntCode) F 
	WHERE ' + @StrWhere + '
	ORDER BY D.FiscalYear, D.SerialNo, D.DocRowNo '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
