USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/01/08
-- Viewed By	 : 
-- Last Modified : 1388/10/09
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : برگ رسید موقت انبار
-- =============================================
Create PROCEDURE [inv].[RptStore_TempReceipt_Doc]
	@ProcessID		Int = 170, -- Temp Receipt Process ID
	@ProcessNo		Int = 1, 
	@FiscalYear		Int =95,
	@SerialNo		Int=1,
	@FiscalYearTo	Int=95,
	@SerialNoTo		Int=100
WITH ENCRYPTION
AS 

DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrSelectA	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrWhere2	NVarChar(4000);

DECLARE @LanguageID TinyInt;
DECLARE @Db0000   nvarchar(50)

Begin --============== S T A R T  C O D E ===================================================

	SET NoCount On;

	SET @Db0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'


	 
	Declare @sal_AggregateSimilarGoodsInRpt		 Bit;
	Declare @sal_AggregateSimilarGoodsUPI		 Bit;
	Declare @sal_AggregateSimilarGoodsByPrice	 Bit;
	DECLARE @QuantityDecimalsToForms			 Int;
	Declare @sal_ShowSubUnitInRpt			     Bit;
	Declare @sal_ShowMainAndSubUnitInRpt		 Bit;
	Declare @TTMSPayTypeShowForAll				 Bit;
	Declare @sal_HasDst							 Bit;
	DECLARE @SalShowRemainInPreSaleDoc			 Bit;
	Declare @CustomerPartNo						 Tinyint
	Declare @PrintSerials						 varchar(1);	
	
	Declare @ExtraParams		NVarChar(Max)
	SELECT    @ExtraParams= Params FROM         rpt.tblRptParams where SessionNo=@FiscalYearTo

	SET @sal_HasDst							   = LTrim(pub.funSplitString(@ExtraParams, '@', 1));  
	SET @sal_AggregateSimilarGoodsInRpt		   = LTrim(pub.funSplitString(@ExtraParams, '@', 2));  
	SET @sal_AggregateSimilarGoodsUPI		   = LTrim(pub.funSplitString(@ExtraParams, '@', 3));  
	SET @sal_ShowSubUnitInRpt				   = LTrim(pub.funSplitString(@ExtraParams, '@', 4));  
	SET @sal_ShowMainAndSubUnitInRpt		   = LTrim(pub.funSplitString(@ExtraParams, '@', 5));  
	SET @sal_AggregateSimilarGoodsByPrice	   = LTrim(pub.funSplitString(@ExtraParams, '@', 6));  
	SET @SalShowRemainInPreSaleDoc			   = LTrim(pub.funSplitString(@ExtraParams, '@', 7));  
	SET @FiscalYearTo						   = LTrim(pub.funSplitString(@ExtraParams, '@', 8));  
	SET @PrintSerials						   = LTrim(pub.funSplitString(@ExtraParams, '@', 9));  
	set @LanguageID=1
	
	-- ==========
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
	
	-- ==========
	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID		Int,
		UserSign	Image
	);
	
	------
	SET @StrSelectA = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + ltrim(rtrim(@Db0000)) + '.usr.tblUsers U '
	
	--print @StrSelectA;
	exec sp_executesql @StrSelectA;

	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1;
	If (@LanguageID Is Null)	SET @LanguageID = 1
	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;

	-- ==================== W H E R E ====================
	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And
					 H.FiscalYear >= ' + LTrim(RTrim(Str(@FiscalYear))) + ' And H.SerialNo >= ' + LTrim(RTrim(Str(@SerialNo))) + ' And
					 H.FiscalYear <= ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' And H.SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo)))
	
	-- S E L E C T =======================================
	SET @StrSelect = '
	SELECT	D.*, S.StoreName, H.DocDesc, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName, U.UnitName,
			[inv].[funSubUnitTools](D.GoodsID,D.GoodsQuantity,1) Unit1,
			[inv].[funSubUnitTools](D.GoodsID,D.GoodsQuantity,2) Unit2,
			[inv].[funSubUnitTools](D.GoodsID,D.GoodsQuantity,3) Unit3,
			[inv].[funSubUnitTools](D.GoodsID,D.GoodsQuantity,4) Unit4,
			[inv].[funSubUnitTools](D.GoodsID,[inv].[funGetGoodsQuantityFromSubUnit](D.GoodsID , D.SubUnitID , D.ConfirmQuantity ) ,1) Unit11,
			[inv].[funSubUnitTools](D.GoodsID,[inv].[funGetGoodsQuantityFromSubUnit](D.GoodsID , D.SubUnitID , D.ConfirmQuantity ),2) Unit12,
			[inv].[funSubUnitTools](D.GoodsID,[inv].[funGetGoodsQuantityFromSubUnit](D.GoodsID , D.SubUnitID , D.ConfirmQuantity ),3) Unit13,
			[inv].[funSubUnitTools](D.GoodsID,[inv].[funGetGoodsQuantityFromSubUnit](D.GoodsID , D.SubUnitID , D.ConfirmQuantity ),4) Unit14,			
			pub.GetCodeName(D.AcntCode, ' + LTrim(RTrim(@LanguageID)) + ') AcntName,
			pub.GetUserName(H.SessionNo) AS UserName, 
			S1.UserSign As UserSignature1,S2.UserSign As UserSignature2,S3.UserSign As Signature1,S4.UserSign As Signature2,S5.UserSign As Signature3,S6.UserSign As Signature4,
			S7.UserSign As Signature5,'+ str(@sal_ShowSubUnitInRpt) +' sal_ShowSubUnitInRpt,' + @PrintSerials + ' PrintSerials,TransporterID2 
			,isnull(O.BaseProcessID ,0 )BaseBaseProcessID ,isnull(O.BaseProcessNo ,0 ) BaseBaseProcessNo ,isnull(O.BaseFiscalYear ,0 ) BaseBaseFiscalYear ,isnull(O.BaseSerialNo ,0 ) BaseBaseSerialNo  ,isnull(O.BaseDocRowNo,0 ) BaseBaseDocRowNo
			,H.ConstTextHdr1 ,H.ConstTextHdr2,H.ConstTextHdr3,H.ConstTextHdr4,H.ConstTextHdr5,H.ConstTextHdr6					
	FROM    [inv].[tblInvTempReceiptDtl] AS D 
	INNER JOIN [inv].[tblInvTempReceiptHdr] H  ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
	LEFT JOIN inv.tblGoodsDtl				GD ON GD.GoodsID  = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart))) + ' AND GD.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
	LEFT  JOIN [inv].[tblUnitsDtl]			U  ON U.UnitID	  = D.SubUnitID AND U.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
	LEFT  JOIN [inv].[tblStoresDtl]			S  ON S.StoreID	  = H.StoreID AND S.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
	LEFT  JOIN #tbl_Invoice_Signatures S1 ON S1.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo)
	LEFT  JOIN #tbl_Invoice_Signatures S2 ON S2.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SessionNo2)
	LEFT  JOIN #tbl_Invoice_Signatures S3 ON S3.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN1)
	LEFT  JOIN #tbl_Invoice_Signatures S4 ON S4.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN2)
	LEFT  JOIN #tbl_Invoice_Signatures S5 ON S5.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN3)
	LEFT  JOIN #tbl_Invoice_Signatures S6 ON S6.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN4)
	LEFT  JOIN #tbl_Invoice_Signatures S7 ON S7.UserID = ' + LTrim(RTrim(@Db0000))+ '.[pub].[funGetUserID](H.SgnSN5)
	LEFT  JOIN cmr.tblOrderDtl O ON D.BaseProcessID = O.ProcessID AND D.BaseProcessNo = O.ProcessNo AND D.BaseFiscalYear = O.FiscalYear AND D.BaseSerialNo = O.SerialNo  AND D.BaseDocRowNo= O.DocRowNo
	
	WHERE ' +  @StrWhere

	--================================		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
End
GO
