USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1387/01/06
-- Viewed By	 : 
-- Last Modified : 1393/09/05
-- Last Modifier : TakroSystem\Hamid
-- Description	 : برگ انبار
-- ==============================================
Create PROCEDURE [inv].[RptStore_Doc]
	@ProcessID		Int = 110,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = 96,
	@SerialNo		Int = 2381,
	@FiscalYearTo	Int = 96,
	@SerialNoTo		Int = 2381
WITH ENCRYPTION
AS

DECLARE @LanguageID			TinyInt;
DECLARE @IsDistribute		bit;
DECLARE @IsSettle			bit;
DECLARE @IsMultiLng			bit;
DECLARE @Inv_SecondPrice	bit;

DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrSelect2		NVarChar(Max);
DECLARE @StrSelect3		NVarChar(Max);
DECLARE @StrSelect4		NVarChar(Max);
DECLARE @StrSelect5		NVarChar(Max);
DECLARE @StrSelect6		NVarChar(Max);
DECLARE @StrSelect7		NVarChar(Max);
DECLARE @StrSelect8		NVarChar(Max);

DECLARE @StrWhere		NVarChar(Max);
DECLARE @StrWhere2		NVarChar(Max);
DECLARE @StrDebitRemain	NVarChar(Max);

Declare @StrSelectIMGField	NVarChar(Max);
Declare @StrSelectIMGTable	NVarChar(Max);

DECLARE @StrUserPrice		NVarChar(1000);
DECLARE @StrUserPriceGrp	NVarChar(1000);

DECLARE @StrWithBatch		NVarChar(1000);
DECLARE @StrWithBatchGrp	NVarChar(1000);

DECLARE @StrGoodsPrice		NVarChar(1000);
DECLARE @StrGoodsPriceGrp	NVarChar(1000);

DECLARE @Eqal				NVarChar(2000);

-- ======
DECLARE @BatchNo						Varchar(20);
DECLARE @ProductID						Varchar(20);
DECLARE @goods_id						Varchar(20);
DECLARE @serial_no						int;
DECLARE @docrowno						int;
DECLARE @goods_quantity					DECIMAL(28,9);

-- ======
DECLARE @unit_name						nvarchar(200);
DECLARE @unit_id						varchar(20);
DECLARE @unit_value						float;
DECLARE @unit_value_Temp				float;
DECLARE @Mainunit_value					float;
DECLARE @Cnt							INT;

-- ======
DECLARE @unit_nameGoods1				nvarchar(200);
DECLARE @unit_idGoods1					varchar(20);
DECLARE @unit_valueGoods1				float;
DECLARE @Mainunit_valueGoods1			float;

DECLARE @unit_nameGoods2				nvarchar(200);
DECLARE @unit_idGoods2					varchar(20);
DECLARE @unit_valueGoods2				float;
DECLARE @Mainunit_valueGoods2			float;

DECLARE @Remain1		Bit;
DECLARE @Remain2		Bit;
DECLARE @Remain3		Bit;
DECLARE @Remain4		Bit;
DECLARE @Part1Start		Int;
DECLARE @Part2Start		Int;
DECLARE @Part3Start		Int;
DECLARE @Part4Start		Int;
DECLARE @Part1Len		Int;
DECLARE @Part2Len		Int;
DECLARE @Part3Len		Int;
DECLARE @Part4Len		Int;
DECLARE @Part1End		TinyInt;
DECLARE @VchNo			NVarChar(50);
DECLARE @SH				NVarChar(50);
DECLARE @SD				NVarChar(50);
DECLARE @UseCurrency		 bit;
DECLARE @WithBatch			 bit;
DECLARE @ShowContainerAndPos bit;
DECLARE @PrintUserID		 Int;

DECLARE @db_0000		NVarchar(50)

SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

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
	Declare @PrintSerials						 Bit;	
	Declare @NotPrintIsService					 Bit;	
	Declare @DocStepIn							 Tinyint;
	
	declare @StorageJoin						 varchar(1000);
	declare @StorageSelect						 varchar(1000);

	SET @sal_AggregateSimilarGoodsUPI			= 0
	SET @sal_AggregateSimilarGoodsInRpt			= 0
	SET @sal_AggregateSimilarGoodsByPrice		= 0
	SET	@QuantityDecimalsToForms				= 3
	SET @sal_ShowSubUnitInRpt					= 0
	SET @sal_ShowMainAndSubUnitInRpt			= 0
	SET @TTMSPayTypeShowForAll					= 0
	SET @sal_HasDst								= 0
	SET @SalShowRemainInPreSaleDoc				= 0
	SET @CustomerPartNo							= 0
	SET @PrintSerials							= 0
	SET @NotPrintIsService						= 0
	
	SELECT @sal_AggregateSimilarGoodsInRpt = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsInRpt'
	SELECT @sal_AggregateSimilarGoodsUPI = SettingValue		FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsUPI'
	SELECT @sal_AggregateSimilarGoodsByPrice = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'sal_AggregateSimilarGoodsByPrice'
	SELECT @QuantityDecimalsToForms=SettingValue			FROM pub.tblSettings	WHERE SettingKey = 'QuantityDecimalsToForms'
	SELECT @sal_ShowSubUnitInRpt = SettingValue				FROM pub.tblSettings	WHERE SettingKey = 'sal_ShowSubUnitInRpt'
	SELECT @sal_ShowMainAndSubUnitInRpt = SettingValue		FROM pub.tblSettings	WHERE SettingKey = 'sal_ShowMainAndSubUnitInRpt'
	SELECT @TTMSPayTypeShowForAll = SettingValue			FROM pub.tblSettings	WHERE SettingKey = 'TTMSPayTypeShowForAll'
	SELECT @sal_HasDst = SettingValue 						FROM pub.tblSettings	WHERE SettingKey = 'sal_HasDst'
	SELECT @SalShowRemainInPreSaleDoc = SettingValue		FROM pub.tblSettings	WHERE SettingKey = 'SalShowRemainInPreSaleDoc'
	SELECT @CustomerPartNo = SettingValue					FROM pub.tblSettings	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

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
	
	SET @NotPrintIsService					   = LTrim(pub.funSplitString(@ExtraParams, '@', 20));  
	SET @BatchNo							   = LTrim(pub.funSplitString(@ExtraParams, '@', 21));  
	SET @ProductID							   = LTrim(pub.funSplitString(@ExtraParams, '@', 22));  
	SET @UseCurrency						   = LTrim(pub.funSplitString(@ExtraParams, '@', 23));  
	SET @WithBatch							   = LTrim(pub.funSplitString(@ExtraParams, '@', 24));  	
	SET @DocStepIn							   = LTrim(pub.funSplitString(@ExtraParams, '@', 25));  
	SET @ShowContainerAndPos				   = LTrim(pub.funSplitString(@ExtraParams, '@', 29));  
	SET @PrintUserID						   = LTrim(pub.funSplitString(@ExtraParams, '@', 30));  

	if isnull(@DocStepIn,0)=11
		set @VchNo=' H.AfterSaleVchNo '
	else
		set @VchNo=' H.VchNo '

	IF @ProcessID = 70
		SET @sal_AggregateSimilarGoodsByPrice=0			

	SET @QuantityDecimalsToForms = @QuantityDecimalsToForms - 1
	
	-- ==========
	begin try
		drop table #tbl_result
		drop table ##tbl_Tmp1
		drop table ##tbl_Tmp2

	end try
	begin catch
	end catch

	Create Table #tbl_result
	(
		SerialNo				Int,
		RowNo				    Int,
		DocRowNo				Int,
		GoodsID					varchar(20) collate Arabic_CS_AS null,
		GoodsName				nvarchar(200) collate Arabic_CS_AS null,
		GoodsQuantity			DECIMAL(28,9),
		UnitIDGoods1			varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods1			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity1			DECIMAL(28,9),
		UnitIDGoods2			varchar(20) collate Arabic_CS_AS null,
		UnitNameGoods2			nvarchar(20) collate Arabic_CS_AS null,
		GoodsQuantity2			DECIMAL(28,9),
		Weight					float,
		Volume					float,
		BarCode					varchar(20) collate Arabic_CS_AS null,
		Batch					varchar(20) collate Arabic_CS_AS null,
		CDiscount				float
	);
		
	Declare @tbl_units as table
	(
		unit_id					varchar(20) not null, 
		unit_name				nvarchar(200) not null, 
		unit_value				float not null,
		Mainunit_value			float not null,
		cnt						int not null
	);
	
	-- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	SET @IsDistribute    = 0;
	SET @IsMultiLng      = 0;
	SET @IsSettle		 = 0;
	SET @Inv_SecondPrice = 0;

	SELECT @IsMultiLng = IsNull(SettingValue, 0)	FROM pub.tblSettings	WHERE SettingKey = 'IsMultiLanguage'
	
	--==============	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	IF @ProcessID Is Null OR @ProcessID = 0
		SET @ProcessID = 230
		
	SELECT @Inv_SecondPrice = IsNull(SettingValue, 0)	FROM pub.tblSettings	WHERE SettingKey = 'PrpInv_SecondPrice'

	IF @Inv_SecondPrice = 0
		SELECT @IsDistribute = IsNull(SettingValue, 0)		FROM pub.tblSettings		WHERE SettingKey = 'SalIsDistribution'

	SELECT @IsSettle = IsNull(SettingValue, 0)	FROM pub.tblSettings	WHERE SettingKey = 'InvHasSettlementKind'
	
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	IF (@FiscalYearTo =0)	SET @FiscalYearTo = @FiscalYear;
	
	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	SET @StrDebitRemain = ''
	
	IF @BatchNo<>'' and @ProductID<>''
	BEGIN
		SET @StrWhere = @StrWhere + ' AND ((H.BatchNo =''' + LTrim(@BatchNo) + ''') AND (H.ProductID = ''' + LTrim(@ProductID) + ''')) '
		SET @FiscalYearTo=0
	END
	-- Where ----------------------------------------
	IF (@FiscalYear Is Not Null) and @FiscalYear>0
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	IF (@FiscalYearTo Is Not Null) and @FiscalYearTo>0
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
		
	--=======================
	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID   Int,
		UserSign Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@db_0000)) + '.usr.tblUsers U '
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;		
	
	--=======================
	CREATE TABLE #tbl_Session1
	(
		SerialNo	Int,
		UserID		Int
	);
	
	SET @StrSelect = '
	INSERT INTO #tbl_Session1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_Session2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo2)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	CREATE TABLE #tbl_Session3
	(
		SerialNo	Int,
		UserID		Int	);

	SET @StrSelect = '
	INSERT INTO #tbl_Session3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo3)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

	--=======================
	CREATE TABLE #tbl_SgnSN1
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN1)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
	
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_SgnSN2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN2)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

	--=======================
	CREATE TABLE #tbl_SgnSN3
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN3)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
			
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;		
		
	--=======================
	CREATE TABLE #tbl_SgnSN4
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN4(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN4)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	--=======================
	CREATE TABLE #tbl_SgnSN5
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN5(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN5)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	--===============================
	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
		
	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)
			

	-- ===============
	Select @Remain1 = SettingValue 	From pub.tblSettings 	Where SettingKey = 'SalIvcRemain1'
	
	Select @Remain2 = SettingValue 	From pub.tblSettings 	Where SettingKey = 'SalIvcRemain2'
	
	Select @Remain3 = SettingValue 	From pub.tblSettings 	Where SettingKey = 'SalIvcRemain3'
	
	Select @Remain4 = SettingValue 	From pub.tblSettings 	Where SettingKey = 'SalIvcRemain4'			

	-- ==============

	Declare @ShowGoodsImage Bit;
	Set @ShowGoodsImage = 0

	Select @ShowGoodsImage = SettingValue
	From pub.tblSettings
	Where SettingKey = 'ShowGoodsImage'
				
	-- ===============
	IF @sal_AggregateSimilarGoodsUPI = 1
	Begin
		SET	@StrUserPrice    = 'ISNULL(UPI.UParams,'''') UserPrice, ISNULL(UPI2.UParams,'''') UserPrice2'				
		SET	@StrUserPriceGrp = ', UPI.UParams, UPI2.UParams'				
	End	
	Else
	Begin
		SET	@StrUserPrice    = '0 UserPrice, 0 UserPrice2'				
		SET	@StrUserPriceGrp = ''				
	End		
	-- ========================================
	IF @WithBatch= 1
	Begin
		SET	@StrWithBatch    = 'ISNULL(D.BatchNo,'''') Batch'				
		SET	@StrWithBatchGrp = ', D.BatchNo'				
	End	
	Else
	Begin
		SET	@StrWithBatch    = ''''' Batch'				
		SET	@StrWithBatchGrp = ''				
	End		
	-- ========================================
	IF @sal_AggregateSimilarGoodsByPrice = 1
	Begin
		SET	@StrGoodsPrice    = 'ISNULL(D.GoodsPrice,0) GoodsPrice, ISNULL(D.SubUnitPrice,0) SubUnitPrice, ISNULL(D.SubUnitPrice2,0) SubUnitPrice2'				
		SET	@StrGoodsPriceGrp = ', D.GoodsPrice, D.SubUnitPrice, D.SubUnitPrice2'				
	End	
	Else
	Begin
		SET	@StrGoodsPrice    = '0 GoodsPrice, 0 SubUnitPrice, 0 SubUnitPrice2'				
		SET	@StrGoodsPriceGrp = ''		
	End	
	-- ========================================
	DECLARE @strUnitName as nvarchar(100)
	DECLARE @strUnitNameGrp as nvarchar(100)

	IF @sal_ShowMainAndSubUnitInRpt= 1 and @sal_AggregateSimilarGoodsByPrice = 0
	Begin
		SET	@strUnitName    = ', '''' UnitName '				
		SET	@strUnitNameGrp = ''
	End	
	Else
	Begin
		SET	@strUnitName    = ',U.UnitName '				
		SET	@strUnitNameGrp = ',U.UnitName'				
	End		
	-- ========================================
	If (@SalShowRemainInPreSaleDoc = 1) OR @ProcessID = 100
	Begin
		declare @CountPartRemain tinyint
		SET @CountPartRemain=0;
	
		SET @Eqal = '1=1'

		IF (@Remain1 = 1)
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain2 = 1) AND @CountPartRemain = 1
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain3 = 1) AND @CountPartRemain = 2
			SET @CountPartRemain = @CountPartRemain + 1
		IF (@Remain4 = 1) AND @CountPartRemain = 3
			SET @CountPartRemain = @CountPartRemain + 1

		IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
			BEGIN
					SET @Eqal = @Eqal + ' AND M.AcntCode=H.AcntCode'
			END
			ELSE
			BEGIN
				IF (@Remain1 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
				IF (@Remain2 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
				IF (@Remain3 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
				IF (@Remain4 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(H.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
			END	

			SET @StrDebitRemain = ' 
					,(SELECT IsNull(Sum(Debit-Credit),0) Debit 
						FROM	acc.tblVoucherDtl M 
						INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
						INNER join acc.tblAcnt b ON b.PartNumber= 1 And 
													SUBSTRING(M.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') = 
														SUBSTRING(b.AcntCode,1,' + LTrim(RTrim(STR(@Part1End))) + ') AND 
													LEN(b.AcntCode) = ' + LTrim(RTrim(STR(@Part1End))) + '
						WHERE  b.AcntType NOT IN (91,92) AND M.VchKind <> 0 AND VH.DocRegisterState > 0 AND (' + @Eqal + ') AND 
							(M.DocDate<=H.VchDate 
							AND Not (
									M.DocDate = H.VchDate AND 
									M.SourceProcessID  IN(' + LTRIM(STR(@ProcessID))+ ') AND 
									M.SourceProcessNo  = H.ProcessNo AND 
									M.SourceFiscalYear = H.FiscalYear AND 
									M.SourceSerialNo   >= H.SerialNo
									)
								)
					) DebitRemain '	

	End
	Else
		SET @StrDebitRemain = ', 0 AS DebitRemain'
			
	-- SELECT Clause ----------------------------------------
	IF @ProcessID = 230 OR @ProcessID = 235 OR @ProcessID = 127 OR @ProcessID = 128
	BEGIN
		begin try
			drop table ##tbl_Tmp1
		end try
		begin catch
		end catch

		update inv.tblStoresRequestsDtl
		set DocRowNo = R
		from inv.tblStoresRequestsDtl a
		inner join 
		(select ROW_NUMBER()over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo order by ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo) R ,* 
		from inv.tblStoresRequestsDtl
		)b
		on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.RowNo=b.RowNo
		where R<>a.DocRowNo
 		 
		SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, D.DocRowNo, D.RowNo, H.DocDate, H.StoreID, S.StoreName,
		       H.AcntCode, pub.GetCodeName(H.AcntCode, @LanguageID) AS AcntName,D.BaseSerialNo, D.GoodsID, D.GoodsQuantity, 
		       [pub].[funGetGoodsName](D.GoodsID,@LanguageID) GoodsName, IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '') BarCode, 
		       D.SubUnitQuantity, D.SubUnitID, U.UnitName, D.DescDtl, H.DocDesc, '' DocDesc2, pub.GetUserName(H.SessionNo) AS UserName, '' UnitName2,
		       0 MainUnitValue, 0 UnitValue, '' TTMSPayOffTypeID, '' CustomerCode, '' CustomerName, ISNULL(UPI.UParams,'') UserPrice,UserPriceID
			   ,GH.TechnicalSpecifications,GH.TechnicalNo,ISNULL(D.BatchNo,'''') Batch
		INTO	##tbl_Tmp1
		FROM inv.tblStoresRequestsHdr H
		Inner Join inv.tblStoresRequestsDtl D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
												 H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
		--INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID	                                     
		INNER JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = @LanguageID
		LEFT  JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = @LanguageID
		LEFT  JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,@str_Goods+1,@str_GoodsSum) AND GH.PartNumber=@UnitPart
		LEFT  JOIN inv.tblGoodsUserPrice UPI on UPI.GoodsID = D.GoodsID and D.UserPriceID=UPI.ID
		WHERE D.ProcessID = @ProcessID And D.ProcessNo = @ProcessNo AND
			  D.FiscalYear >= @FiscalYear AND D.SerialNo >= @SerialNo AND
			  D.FiscalYear <= @FiscalYearTo AND D.SerialNo <= @SerialNoTo
		ORDER BY ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo			
	END
	ELSE
	BEGIN
		begin try
			drop table ##tbl_Tmp2
		end try
		begin catch
		end catch
		
		begin try
			drop table ##tbl_Tmp3
		end try
		begin catch
		end catch		
		
		DECLARE @SaleOrderJoin NVARCHAR(MAX)
		DECLARE @SaleOrderSgn NVARCHAR(MAX)
		DECLARE @SaleOrderGrp NVARCHAR(MAX)
		SET @SaleOrderJoin = ''
		SET @SaleOrderGrp = ''
		IF @ProcessID = 90 
		BEGIN
			SET @SaleOrderJoin = '
			LEFT JOIN sal.tblSaleOrderHdr SOH ON H.BaseProcessID = SOH.ProcessID AND H.BaseProcessNo = SOH.ProcessNo AND H.BaseFiscalYear = SOH.FiscalYear AND H.BaseSerialNo = SOH.SerialNo '
			
			SET @SaleOrderSgn = '
					pub.GetUserName(SOH.SgnSN1) Sgn1OrderName,(SELECT UserSign FROM #tbl_Invoice_Signatures WHERE UserID =' + @db_0000 + '.[pub].[funGetUserID](SOH.SgnSN1)  ) SignatureSH1, 
					pub.GetUserName(SOH.SgnSN2) Sgn2OrderName,(SELECT UserSign FROM #tbl_Invoice_Signatures WHERE UserID =' + @db_0000 + '.[pub].[funGetUserID](SOH.SgnSN2)  ) SignatureSH2, '

			SEt @SaleOrderGrp = ',SOH.SgnSN1,SOH.SgnSN2'
		END
		ELSE
			SET @SaleOrderSgn = '
					'''' Sgn1OrderName,0 SignatureSH1, 
					'''' Sgn2OrderName,0 SignatureSH2, '

if (@UseCurrency = 1)
	begin
			set @SH = 'inv.vwStorageHdr_Currency'
			set @SD = 'inv.vwStorageDtl_Currency'		
	
	end
	else
	begin
			set @SH = 'inv.tblStorageDocsHdr'
			set @SD = 'inv.tblStorageDocsDtl'		
	end

	--select @sal_AggregateSimilarGoodsInRpt ,@UseCurrency
	
	set @StrSelectIMGField=',Cast('''' as Image) GoodsImage '
	set @StrSelectIMGTable=' '

	if @ShowGoodsImage='True'
	begin
		set @StrSelectIMGField=', GI.GoodsImage '
		set @StrSelectIMGTable=' Left  Join inv.tblGoodsImages GI On GH.GoodsID = GI.GoodsID '
	end 

		IF @sal_AggregateSimilarGoodsInRpt = 0
		BEGIN	  
			SET @StrSelect = '			
			SELECT	D.*'+@StrSelectIMGField +' , 
				pub.funChangeDate_PersianToGergorian(D.DocDate) GeorgDocDate,
				IsNull(TKD.TransportationKindName,'''') TransportationKindName, 
				IsNull(GRDH.ReciverAddress,'''') ReciverAddress,
				H.CurrencyTypeID,
				H.CurrencyRate, 
				IsNull(CT.ISOCode,'''') CurrencyTypeISOName, 
				GH.BarCode, 
				FH.ProductCount as ProductCountOfFormula,
				FD.GoodsQuantity as GoodsQuantityOfFormula,
				[inv].[funGetSubGoodsRemain](D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.VolumeRowNo,D.StoreID,D.GoodsID,D.SubUnitID,D.DocDate,D.BatchNo,D.UserPriceID) GoodsRemain, 
				pub.funFarsiDate(GETDATE()) PrintDate, 
				IsNull(H.GoodsReciverID,'''') GoodsReciverIDHdr, 
				IsNull(GR.ReciverName,'''') ReciverName,
				IsNull(GRD.ReciverName,'''') ReciverNameDtl,
				[inv].[funGetBatchName](D.BatchNo,' + LTRIM(RTrim(@LanguageID)) + ') BatchName,
				' + @db_0000 + '.[pub].[funUserName](' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)) User_Name,
				H.BatchNo BatchNoHdr,
				B.BatchName BatchNameHdr,
				H.CashID , 
				H.PriceParvane PriceParvaneHdr ,
				[lyl].[GetCustomerInfo](H.OrderAcntCode,' + LTrim(RTrim(@LanguageID)) + ') CustomerInfoName,
				(SELECT IsNull(GoodsWeight,0) FROM inv.tblGoods WHERE GoodsID = D.GoodsID) * D.GoodsQuantity GoodsWeight,
				IsNull(GS.SetPoint,0) as SetPoint,
				IsNull(GS.MaxPoint,0)as MaxPoint,
				IsNull(GS.FitPoint,0) as FitPoint,
				inv.GetGoodsPlaceNameFromStore(GS.StoreID,GS.DocRowNo,1) RecDesc,
				Cast(' + LTRIM(RTrim(Str(@IsMultiLng))) + ' As Bit) As IsMultiLng,
				'+str(@DocStepIn)+' DocStepIn, 
				'+@VchNo+' VchNo, 
				H.VchNo2, 
				H.ProductID, 
				inv.funGetGoodsRemain(Null,Null,Null,Null,Null,Null,H.ProductID,Null,H.DocDate,0) As ProductRemain, 
				H.ProductCount, 
				H.DocDesc,
				H.DocDesc2, 
				D.DescDtl DocDescDtl, 
				H.EarnestMoney,
				H.DocDate DocDateH,
				H.DocDate2 DocDate2H,
				H.DocDate3 DocDate3H,
				H.DocDate4 DocDate4H,
				H.VchDate, 
				H.PayOffTypeID, 
				PT.PayOffTypeName, 
				H.TTMSPayOffTypeID, 
				ISNULL(UPI.UParams,'''') UserPrice, 
				ISNULL(UPI2.UParams,'''') UserPrice2,
				D.BatchNo Batch,
				pub.GetCodeName(H.VisitorAcntCode, ' + LTRIM(RTrim(@LanguageID)) + ') AS VisitorAcntName, 
				H.DriverID, 
				DRH.DriverTel, 
				DRH.DriverMobile, 
				DRH.VehicleNo,
				DRH.NationalNumber DriverNationalNumber,
				DRD.FirstName + '' '' + DRD.LastName DriverName, 
				H.TaxOverWorthCost, 
				H.DiscountTaxOverWorth, 
				( H.Discount + (H.CurrencyDiscount * H.CurrencyRate) + H.Discount2 + H.Discount3) AS Discount, 
				H.TaxCost, 
				H.DiscountPercent,
				H.TollOverWorthCost, 
				H.TotalLineDiscount, 
				[pub].[funGetGoodsName](D.GoodsID,' + LTRIM(RTrim(@LanguageID)) + ') GoodsName, 
				GH.ExtraField1, 
				GH.ExtraField2, 
				GH.ExtraField3,
				GH.ExtraField4, 
				GH.ExtraField5,
				IsNull(GH_P.ExtraField1,'''') ExtraField1_P, 
				IsNull(GH_P.ExtraField2,'''') ExtraField2_P, 
				IsNull(GH_P.ExtraField3,'''') ExtraField3_P,
				IsNull(GH_P.ExtraField4,'''') ExtraField4_P, 
				IsNull(GH_P.ExtraField5,'''') ExtraField5_P,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') GoodsBarCode, 
				pub.funGetGoodsName(H.ProductID, 
				' + LTRIM(RTrim(@LanguageID)) + ') As ProductName, 
				IsNull([inv].[FunGetGoodsBarCode] (H.ProductID), '''') ProductBarCode, 
				H.OtherIncome, 
				H.BascolWeight,
				H.WasteWeight,
				H.PureWeight, 
				GH.PureWeight GoodsPureWeight,
				H.OtherCost, 
				pub.funGetGoodsName(D.GoodsID2, ' + LTRIM(RTrim(@LanguageID)) + ') AS GoodsName2, 
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID2), '''') GoodsBarCode2, 
				CASE WHEN H.ProcessID in (90,100) THEN STD.SaleTypeName WHEN H.ProcessID in (55,60) THEN BTD.BuyTypeName ELSE '''' END SaleTypeName,
				F.*, 
				D.AtomAmount AS OverloadAmount, 
				T.TransporterName ,
				H.PackingCost,
				S.StoreName,
				S2.StoreName AS StoreName2, 
				S.Address StoreAddress, 
				S2.Address StoreAddress2, 
				Cast(''بسته بندی'' AS VarChar(100)) AS Packing2, 
				SH.StoreKeeperID, 
				SK.StoreKeeperName, 
				SH2.StoreKeeperID StoreKeeperID2,
				SK2.StoreKeeperName StoreKeeperName2,
				SH.Tel StoreTel, 
				SH2.Tel StoreTel2,
				pub.funGetLocationName(F.LocationID, ' + LTRIM(RTrim(@LanguageID)) + ') AS LocationName, 
				H.TransportationCost,
				H.CurrencyTransportationCost,
				H.CurrencyTransportationIncome,
				H.TransportationIncome, 
				T2.TransporterName AS TransporterName2,	
				pub.funGetLocationName(H.LocationID, ' + LTRIM(RTrim(@LanguageID)) + ') AS LocationName2, 
				IsNull(P.ProcessName, '''') AS ProcessName,
				F.Tel As HdrAcntTel,
				F.Tel As DtlAcntTel, 
				H.CashAmount, 
				H.ChequeAmount,'					
			SET @StrSelect2 = '	
					pub.GetUserName(H.SessionNo) AS UserName, 
					pub.GetUserName(H.SessionNo) AS UserName1, 
					pub.GetUserName(H.SessionNo2) AS UserName2, 
					pub.GetUserName(H.SessionNo3) AS UserName3, 
					pub.GetUserName(H.SessionNo4) AS UserName4, 
					pub.GetUserName(H.SessionNo5) AS UserName5, 
					' + @SaleOrderSgn + '
					Cast(' + LTRIM(RTrim(Str(@IsDistribute))) + ' As Bit) AS IsDistribute, 
					AfterSaleDiscount
					' + @strUnitName + ', ISNULL(W.UnitName,
					U.UnitName) UnitName2,
					Cast(' + LTRIM(RTrim(Str(@IsSettle))) + ' As Bit) AS HasSettlement, 
					V.UnitValue, 
					V.MainUnitValue,
					inv.funSubUnit2(D.GoodsID) UnitScale,
					X.UnitName MainUnitName,
					inv.funSubUnit2Name(D.GoodsID) UnitNameX,
					TransporterID2,
					GH.TechnicalSpecifications, 
					GH.TechnicalNo, 
					GH.GoodsCID,
					H.OwnerDocNo,
					H.AgreeNo AS AgreeNoHdr,
					H.ComssionCostPrice, 
					H.BasculePrice,
					H.LaborPrice, 
					H.TransportPrice,
					IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS 
							Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
							SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
							SS.DocRowNo = D.DocRowNo),0) As ProductSerialID, 
					IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
							Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
							SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
							SS.DocRowNo = D.DocRowNo),'''') As PrdBatchNo,
					IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
							Where SS.ProcessID = D.ProcessID And SS.ProcessNo = D.ProcessNo And 
							SS.FiscalYear = D.FiscalYear And SS.SerialNo = D.SerialNo And 
							SS.DocRowNo = D.DocRowNo),'''') As PrdExpireDate,	
					IsNull((SELECT TOP 1 SettingValue
							FROM pub.tblSettings
							WHERE SettingKey = ''TitleSale' + ltrim(str(@ProcessNo)) + '''), '''') AS SaleName,
					IsNull((SELECT TOP 1 SettingValue
							FROM pub.tblSettings
							WHERE SettingKey = ''TitleBuy' + ltrim(str(@ProcessNo)) + '''), '''') AS BuyName,
							inv.UQ2(D.GoodsID,D.SubUnitID) SQ2, H.C1, H.C2, H.C3, H.C4, H.C5, H.C6, H.C7, H.C8, H.C9, H.C10, H.C11, H.C12,
					IsNull((Select SUM(TaxOverWorthCost) From ' + @SH + '  SS 
							Where SS.BaseProcessID = D.ProcessID And SS.BaseProcessNo = D.ProcessNo And 
							SS.BaseFiscalYear = D.FiscalYear And SS.BaseSerialNo = D.SerialNo ),0) As BaseTaxOverWorthCost,
					IsNull((Select SUM(TollOverWorthCost) From ' + @SH + '  SS 
							Where SS.BaseProcessID = D.ProcessID And SS.BaseProcessNo = D.ProcessNo And 
							SS.BaseFiscalYear = D.FiscalYear And SS.BaseSerialNo = D.SerialNo ),0) As BaseTollOverWorthCost,
					IsNull((Select top 1 VchNo From ' + @SH + '  SS 
							Where SS.BaseProcessID = D.ProcessID And SS.BaseProcessNo = D.ProcessNo And 
							SS.BaseFiscalYear = D.FiscalYear And SS.BaseSerialNo = D.SerialNo ),0) As BaseVchNo,
					IsNull((Select top 1 VchNo2 From ' + @SH + '  SS 
							Where SS.BaseProcessID = D.ProcessID And SS.BaseProcessNo = D.ProcessNo And 
							SS.BaseFiscalYear = D.FiscalYear And SS.BaseSerialNo = D.SerialNo ),0) As BaseVchNo2,'					
			SET @StrSelect3= '	
					Case When H.SgnSN1=0 Then '''' Else pub.GetUserName(H.SgnSN1) End Signer1Name,
					Case When H.SgnSN2=0 Then '''' Else pub.GetUserName(H.SgnSN2) End Signer2Name,
					Case When H.SgnSN3=0 Then '''' Else pub.GetUserName(H.SgnSN3) end Signer3Name,
					Case When H.SgnSN4=0 Then '''' Else pub.GetUserName(H.SgnSN4) End Signer4Name,
					Case When H.SgnSN5=0 Then '''' Else pub.GetUserName(H.SgnSN5) End Signer5Name,
					S1.UserSign As UserSignature1,
					S8.UserSign As UserSignature2,
					S9.UserSign As UserSignature3,
					S3.UserSign As Signature1,
					S4.UserSign As Signature2,
					S5.UserSign As Signature3,
					S6.UserSign As Signature4,
					S7.UserSign As Signature5,
					H.Address, 
					H.DestinationAddress,
					ISNULL(DR.DescRetSaleName,'''') DescRetSaleName,
					acc.funGetAcntName(D.CustomerCode , ' + LTRIM(RTrim(Str(@CustomerPartNo))) + ', ' + LTRIM(RTrim(@LanguageID)) + ') CustomerName, 
					H.ExtraField1 As ExtraField1Sale,
					Wage1, 
					Wage2, 
					Wage3, 
					Wage4, 
					Wage5, 
					Wage6, 
					Wage7, 
					Wage8, 
					Wage9, 
					Wage10, 
					WageName,
					isnull(BD.SerialNo ,0) BaskulSerialNo ,
					isnull(BD.FullVehicleWeight,0) FullVehicleWeight,
					isnull(BD.EmptyVehicleWeight,0) EmptyVehicleWeight,
					GH.IsService '+ @StrDebitRemain +'  ,
					H.ProductSerialID	ProductSerialIDHdr,
					H.PSerialNo PSerialNoHdr,
					H.FmlParam1,
					CurrencyTypeName,
					isnull(tr.Recognition,0)Recognition,
					case when isnull(tr.Recognition,0)=0 then N''انتخاب نشده'' when isnull(tr.Recognition,0)=1 then N''تایید'' when isnull(tr.Recognition,0)=2 then N''تایید مشروط'' when isnull(tr.Recognition,0)=3 then N''تایید ارفاقی'' when isnull(tr.Recognition,0)=4 then N''عدم تایید'' end RecognitionName,
					H.Price,
					tr.DescDtl RecognitionDesc, 
					H.TaxSerialNoInvoice TaxSerialNo, 
					H.CurrencyDiscount,
					H.ProdManUnitCount,
					H.ProdManSubUnitCount,
					H.SettlementDate,
					[inv].[funGetLastGoodsAmount](D.GoodsID,D.DocDate,D.VolumeRowNo) AS LastGoodsAmount,
					pub.funReverseForCrystal(inv.FunCheckBuyBaseExists (D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo)) BuyBaseInfo
			INTO	##tbl_Tmp2
			FROM	' + @SD + '  D 
			INNER JOIN ' + @SH + '  H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			' + @SaleOrderJoin +'
			LEFT JOIN inv.tblBaskulSalesDtl BD 
			ON (H.BaskulSerialNo=BD.SerialNo AND D.BaseProcessID = BD.BaseProcessID AND D.BaseProcessNo = BD.BaseProcessNo AND D.BaseFiscalYear = BD.BaseFiscalYear AND D.BaseSerialNo = BD.BaseSerialNo  AND D.BaseDocRowNo= BD.BaseDocRowNo AND BD.BaseSerialNo <>0)
			OR (D.BaseProcessID = BD.ProcessID AND D.BaseProcessNo = BD.ProcessNo AND D.BaseFiscalYear = BD.FiscalYear AND D.BaseSerialNo = BD.SerialNo  AND D.BaseDocRowNo= BD.DocRowNo)
			LEFT JOIN  prd.tblFormulasOverLoadHdr FO on H.ProductID=FO.ProductID and H.FormulaNo=FO.SerialNo And (FO.OverLoadProduct=1 or (FO.OverLoadProduct=0 and FO.OverLoadDecomposition=0))
			LEFT JOIN prd.tblFormulasHdr FH ON FH.ProductID=H.ProductID and FH.SerialNo=H.FormulaNo
			LEFT JOIN (SELECT ProductID,SerialNo,GoodsID,SUM(GoodsQuantity) GoodsQuantity FROM prd.tblFormulasDtl Group by ProductID,SerialNo,GoodsID) FD ON FD.ProductID=H.ProductID and FD.SerialNo=H.FormulaNo	and FD.GoodsID=D.GoodsID			
			LEFT JOIN sal.tblTransportersDtl T ON H.TransporterID = T.TransporterID AND T.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsStatusDtl GS ON D.StoreID = GS.StoreID And D.GoodsID = GS.GoodsID  AND GS.DocRowNo =(select max(DocRowNo) from inv.tblGoodsStatusDtl GS2 where  D.StoreID = GS2.StoreID And D.GoodsID = GS2.GoodsID )
			LEFT JOIN sal.tblTransportersDtl T2 ON H.TransporterID2 = T2.TransporterID AND T.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			'+@StrSelectIMGTable+'
			LEFT JOIN trn.tblTransportationKindDtl TKD On H.TransportationKindID = TKD.TransportationKindID
			LEFT JOIN inv.tblGoodsReciverDtl GRDH On H.GoodsReciverID = GRDH.ReciverID
			LEFT JOIN inv.tblGoods GH_P ON GH_P.GoodsID=SUBSTRING(H.ProductID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH_P.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN sal.tblDescRetSaleDtl DR ON DR.DescRetSaleID = H.DescRetSaleID AND DR.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '' 
SET @StrSelect4 = '
			LEFT JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStores SH ON SH.StoreID = D.StoreID
			LEFT JOIN inv.tblStores SH2 ON SH2.StoreID = D.StoreID2
			LEFT JOIN inv.tblStoreKeepersDtl SK ON SH.StoreKeeperID = SK.StoreKeeperID AND SK.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStoreKeepersDtl SK2 ON SH2.StoreKeeperID = SK2.StoreKeeperID AND SK2.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStoresDtl S2 ON S2.StoreID = D.StoreID2 AND S2.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN sal.tblSaleTypesDtl STD ON STD.SaleTypeID = D.SaleTypeID AND STD.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblBuyTypeDtl BTD ON BTD.BuyTypeID = D.SaleTypeID AND BTD.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN pub.tblProcess P ON P.ProcessID = D.ProcessID AND P.ProcessNo = D.ProcessNo			
			OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F
			LEFT JOIN (select distinct ShowInInvoice,GoodsID,SubUnitID,UnitValue, MainUnitValue from inv.tblSubUnitsDtl) V ON V.GoodsID=D.GoodsID AND V.ShowInInvoice=1
			LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblUnitsDtl W ON W.UnitID=V.SubUnitID AND W.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '	
			LEFT JOIN inv.tblUnitsDtl X ON X.UnitID=GH.UnitID AND X.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN #tbl_Invoice_Signatures S1 on S1.UserID = (SELECT UserID FROM #tbl_Session1 Where SerialNo = H.SerialNo)
			LEFT JOIN #tbl_Invoice_Signatures S8 on S8.UserID = (SELECT UserID FROM #tbl_Session2 Where SerialNo = H.SerialNo)
			LEFT JOIN #tbl_Invoice_Signatures S9 on S9.UserID = (SELECT UserID FROM #tbl_Session3 Where SerialNo = H.SerialNo)
			LEFT JOIN #tbl_Invoice_Signatures S3 on S3.UserID = (SELECT UserID FROM #tbl_SgnSN1 Where SerialNo = H.SerialNo)
			LEFT JOIN #tbl_Invoice_Signatures S4 on S4.UserID = (SELECT UserID FROM #tbl_SgnSN2 Where SerialNo = H.SerialNo)
			LEFT JOIN #tbl_Invoice_Signatures S5 on S5.UserID = (SELECT UserID FROM #tbl_SgnSN3 Where SerialNo = H.SerialNo)
			LEFT JOIN #tbl_Invoice_Signatures S6 on S6.UserID = (SELECT UserID FROM #tbl_SgnSN4 Where SerialNo = H.SerialNo)
			LEFT JOIN #tbl_Invoice_Signatures S7 on S7.UserID = (SELECT UserID FROM #tbl_SgnSN5 Where SerialNo = H.SerialNo)
			LEFT JOIN sal.tblPayOffTypesDtl PT ON H.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsUserPrice UPI on UPI.GoodsID = D.GoodsID and D.UserPriceID=UPI.ID
			LEFT JOIN inv.tblGoodsUserPrice UPI2 on UPI2.GoodsID = D.GoodsID and D.UserPriceID=UPI2.ID
			LEFT JOIN inv.tblGoodsReciverDtl GR on GR.ReciverID = H.GoodsReciverID AND GR.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsReciverDtl GRD ON GRD.ReciverID = D.GoodsReciverIDDtl AND GRD.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '			
			LEFT JOIN pub.tblDrivers DRH ON H.DriverID = DRH.DriverID 
			LEFT JOIN pub.tblDriversDtl DRD ON DRH.DriverID = DRD.DriverID 
			LEFT JOIN inv.tblBatchDtl B ON H.BatchNo = B.BatchNo AND B.LanguageID=' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN pub.tblCurrencyTypesDtl CR ON H.CurrencyTypeID = CR.CurrencyTypeID AND CR.LanguageID=' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblInvTempReceiptDtl tr ON tr.ProcessID = D.BaseProcessID AND tr.ProcessNo = D.BaseProcessNo AND tr.FiscalYear = D.BaseFiscalYear AND tr.SerialNo = D.BaseSerialNo AND tr.DocRowNo= D.BaseDocRowNo			 
			LEFT JOIN pub.tblCurrencyTypes CT On H.CurrencyTypeID = CT.CurrencyTypeID
			WHERE ' + @StrWhere + '
			ORDER BY DocRowNo'
			
			Print @StrSelect
			Print @StrSelect2
			Print @StrSelect3
			Print @StrSelect4
 			
			SET @StrSelect = @StrSelect + @StrSelect2 + @StrSelect3+ @StrSelect4;			
			EXEC sp_executesql @StrSelect; 
						
			update ##tbl_Tmp2
			Set DocDate2H=case when isnull(DocDate2H,'')='' then DocDateH else DocDate2H end 
			,DocDate3H= case when isnull(DocDate3H,'')='' then case when isnull(DocDate2H,'')='' then DocDateH else DocDate2H end  else DocDate3H end  
			,DocDate4H =case when isnull(DocDate3H,'')='' then case when isnull(DocDate3H,'')='' then case when isnull(DocDate2H,'')='' then DocDateH else DocDate2H end  else DocDate3H end   else DocDate4H end   
				
		END					
		ELSE
		BEGIN		
			SET @StrSelect = '			
			SELECT	0 GoodsRemain,
				D.ProcessID, 
				D.ProcessNo, 
				D.FiscalYear, 
				D.SerialNo,  
				0 RowNo, 
				0 DocRowNo, 
				0 VolumeRowNo, 
				0 DocStep, 
				H.DocDate, 
				H.StoreID, 
				0 PhysicallyEffected,
				GH.BarCode,
				D.EnterKind, 
				D.StoreID2, 
				H.AcntCode, 
				H.VisitorAcntCode,
				'''' OrderAcntCode, 
				D.GoodsID, 
				'''' SubUnitID, 
				Sum(D.SubUnitQuantity) SubUnitQuantity,
				pub.funFarsiDate(GETDATE()) PrintDate, 
				IsNull(H.GoodsReciverID,'''') GoodsReciverIDHdr, 
				IsNull(GR.ReciverName,'''') ReciverName,
				IsNull(GRD.ReciverName,'''') ReciverNameDtl,
				'''' BatchName, 
				'''' User_Name,
				Sum(D.GoodsQuantity) GoodsQuantity, 
				D.QtyRemain, 
				0 GoodsAmount, 
				0 AmntRemain,
				0 AtomAmount,
				'+ @StrGoodsPrice + ', 
				'''' DescDtl, 
				0 BaseProcessID, 
				0 BaseProcessNo, 
				0 BaseFiscalYear, 
				0 BaseSerialNo, 
				0 BaseDocRowNo, 
				0 BaseDocType, 
				'''' BatchNo, 
				'''' AgreeNo,
				Sum(D.DiscountPercentDtl) DiscountPercentDtl,
				Sum(D.DiscountDtl) DiscountDtl, 
				'''' BaseDocDate,
				0 VirtualQuantity,
				0 IsReward,
				0 FormulaNo,
				'''' GoodsID2,
				0 Wage, 
				0 WageRate, 
				0 FormulaProductCount,  
				H.CurrencyTypeID,
				H.CurrencyRate, 
				ISNULL(CurrencyAmount,0) CurrencyAmount, 
				0 CalculatingAmount,
				'''' VchDate2, 
				0 UserGoodsAmount, 
				'''' ExpireDate, 
				0 SourceSerialNo,
				'''' BatchNoHdr,
				'''' BatchNameHdr, 
				'
				Set @StrSelect7 = 
				'
				H.CashID ,
				H.KotagNo ,
				H.KotagDate ,
				H.AssessmentLocation , 
				H.ExitLocation ,
				H.PriceParvane PriceParvaneHdr , 
				0 Price0,'''' CustomerInfoName  ,
				0 SourceProcessNo, 
				'''' DailyUsesBranchID, 
				Sum(GoodsAmount1) GoodsAmount1, 
				Sum(GoodsAmount2) GoodsAmount2,
				Sum(GoodsAmount3) GoodsAmount3,
				Sum(GoodsAmount4) GoodsAmount4, 
				Sum(GoodsAmount5) GoodsAmount5, 
				Sum(GoodsAmount6) GoodsAmount6, 
				Sum(GoodsAmount7) GoodsAmount7, 
				Sum(GoodsAmount8) GoodsAmount8,
				Sum(GoodsAmount9) GoodsAmount9,
				Sum(GoodsAmount10) GoodsAmount10,
				Sum(GoodsAmount11) GoodsAmount11,
				Sum(GoodsAmount12) GoodsAmount12, 
				0 StoreVariable1,
				0 StoreVariable2, 
				0 SalePrice, 
				''''PhrBatchNo,
				'''' Packing,
				'''' GregorianExpireDate,
				0 PricePercent, 
				Sum(D.VisitorPercent) VisitorPercent,
				0 ContainTax,
				Case When IsNumeric(D.ConstText1) = 0 OR D.ConstText1 = ''0'' OR D.ConstText1 = '''' Then 0 Else D.ConstText1 End As ConstText1,
				Case When IsNumeric(Sum(Cast(replace(D.ConstText2,''/'',''.'') As Float))) = 1 Then Sum(Cast(replace(D.ConstText2,''/'',''.'') As Float)) Else 0 End As ConstText2, 
				Case When IsNumeric(Sum(Cast(D.ConstText3 As Float))) = 1 Then Sum(Cast(D.ConstText3 As Float)) Else 0 End As ConstText3,Case When IsNumeric(Sum(Cast(D.ConstText4 As Float))) = 1 Then Sum(Cast(D.ConstText4 As Float)) Else 0 End As ConstText4, 
				0 Var1, 
				0 Var2,
				0 Var3, 
				0 Var4, 
				D.SaleTypeID,
				H.PayOffTypeID,
				PT.PayOffTypeName,
				H.TTMSPayOffTypeID,
				Sum(SubUnitQuantity2) SubUnitQuantity2,
				Sum(TaxOverWorthCostDtl) TaxOverWorthCostDtl, 
				H.DiscountTaxOverWorth, 
				Sum(TollOverWorthCostDtl) TollOverWorthCostDtl,
				H.VisitorAcntCode2, 
				Sum(D.VisitorPercent2) VisitorPercent2, 
				'''' SendNo, 
				0 LoadWeight,
				0 EmptyWeight, 
				0 NetWeight, 
				'''' ReciverAcntCode, 
				' + @StrUserPrice + ', 
				' + @StrWithBatch + ',
				(SELECT IsNull(GoodsWeight,0) FROM inv.tblGoods WHERE GoodsID = D.GoodsID) * Sum(D.GoodsQuantity) GoodsWeight, 
				0 AS SetPoint, 
				0 MaxPoint, 
				0 AS FitPoint,
				0 RecDesc, 
				0 As IsMultiLng,
				'+str(@DocStepIn)+' DocStepIn, 
				'+@VchNo+' VchNo,
				H.VchNo2,
				'''' ProductID,
				inv.funGetGoodsRemain(Null,Null,Null,Null,Null,Null,H.ProductID,Null,H.DocDate,0) As ProductRemain,'
			
			SET @StrSelect2 = '
			    0 ProductCount,
				H.DocDesc, 
				H.DocDesc2, 
				'''' DocDescDtl,
				H.EarnestMoney, 
				H.DocDate DocDateH,
				H.DocDate2 DocDate2H,
				H.DocDate3 DocDate3H, 
				H.DocDate4 DocDate4H, 
				H.VchDate,
				pub.GetCodeName(H.VisitorAcntCode, ' + LTRIM(RTrim(@LanguageID)) + ') AS VisitorAcntName,
				H.DriverID, 
				DRH.DriverTel, 
				DRH.DriverMobile,
				DRH.VehicleNo,
				DRH.NationalNumber DriverNationalNumber, 
				DRD.FirstName + '' '' + DRD.LastName DriverName, 
				H.TaxOverWorthCost, 
				H.DiscountPercent,
				(H.Discount + (H.CurrencyDiscount * H.CurrencyRate) + H.Discount2 + H.Discount3) AS Discount,
				H.TaxCost,
				H.TollOverWorthCost,
				H.TotalLineDiscount,
				[pub].[funGetGoodsName](D.GoodsID,1) GoodsName,
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') GoodsBarCode, 
				GH.ExtraField1,
				GH.ExtraField2,
				GH.ExtraField3, 
				GH.ExtraField4, 
				GH.ExtraField5, 
				'''' ProductName,
				'''' ProductBarCode, 
				H.OtherIncome,
				D.OtherIncomePerentDtl,
				D.OtherIncomeDtl,
				H.BascolWeight,
				H.WasteWeight, 
				H.PureWeight, 
				GH.PureWeight GoodsPureWeight,
				IsNull(GH_P.ExtraField1,'''') ExtraField1_P, 
				IsNull(GH_P.ExtraField2,'''') ExtraField2_P, 
				IsNull(GH_P.ExtraField3,'''') ExtraField3_P,
				IsNull(GH_P.ExtraField4,'''') ExtraField4_P,
				IsNull(GH_P.ExtraField5,'''') ExtraField5_P,
				H.OtherCost,
				pub.funGetGoodsName(D.GoodsID2, ' + LTRIM(RTrim(@LanguageID)) + ') AS GoodsName2,  
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID2), '''') GoodsBarCode2, 
				CASE WHEN H.ProcessID in (90,100) THEN STD.SaleTypeName WHEN H.ProcessID in (55,60) THEN BTD.BuyTypeName ELSE '''' END SaleTypeName,
				F.* ' + @strUnitName + ',
				ISNULL(W.UnitName,'''') UnitName2,
				H.PackingCost, 
				S.StoreName, 
				S2.StoreName AS StoreName2, 
				S.Address StoreAddress,
				S2.Address StoreAddress2, '

			SET @StrSelect3 = '
					Cast(''بسته بندی'' AS VarChar(100)) AS Packing2,
					SH.StoreKeeperID, 
					SK.StoreKeeperName,
					SH2.StoreKeeperID StoreKeeperID2, 
					SK2.StoreKeeperName StoreKeeperName2, 
					SH.Tel StoreTel, 
					SH2.Tel StoreTel2,
					pub.funGetLocationName(F.LocationID, ' + LTRIM(RTrim(@LanguageID)) + ') AS LocationName,
					H.TransportationCost, 
					H.TransportationIncome,
				    H.CurrencyTransportationCost,
				    H.CurrencyTransportationIncome,
					T.TransporterID TransporterID1, 
					T.TransporterName, 
					T2.TransporterID TransporterID2,
					T2.TransporterName AS TransporterName2,
					pub.funGetLocationName(H.LocationID, ' + LTRIM(RTrim(@LanguageID)) + ') AS LocationName2,
					IsNull(P.ProcessName, '''') AS ProcessName, 
					F.Tel As HdrAcntTel,
					F.Tel As DtlAcntTel, 
					H.CashAmount,
					H.ChequeAmount,
					pub.GetUserName(H.SessionNo) AS UserName,
					pub.GetUserName(H.SessionNo) AS UserName1,
					pub.GetUserName(H.SessionNo2) AS UserName2,
					pub.GetUserName(H.SessionNo3) AS UserName3,
					pub.GetUserName(H.SessionNo4) AS UserName4, 
					pub.GetUserName(H.SessionNo5) AS UserName5, 
					' + @SaleOrderSgn + ' Cast(' + LTRIM(RTrim(Str(@IsDistribute))) + ' As Bit) AS IsDistribute, 
					AfterSaleDiscount,
					Cast(' + LTRIM(RTrim(Str(@IsSettle))) + ' As Bit) AS HasSettlement,
					V.UnitValue, 
					V.MainUnitValue,
					inv.funSubUnit2(D.GoodsID) UnitScale,
					X.UnitName MainUnitName,
					inv.funSubUnit2Name(D.GoodsID) UnitNameX,
					GH.TechnicalSpecifications, 
					GH.TechnicalNo, 
					GH.GoodsCID, 
					H.OwnerDocNo,
					H.AgreeNo AS AgreeNoHdr, 
					H.ComssionCostPrice,
					H.BasculePrice,
					H.LaborPrice,
					H.TransportPrice,
					'''' ProductSerialID,
					'''' PrdBatchNo, 
					'''' PrdExpireDate,
				'
				Set @StrSelect6 = 
				'
					IsNull((SELECT TOP 1 SettingValue FROM pub.tblSettings WHERE SettingKey = ''TitleSale' + ltrim(str(@ProcessNo)) + '''), '''') AS SaleName,
					IsNull((SELECT TOP 1 SettingValue FROM pub.tblSettings WHERE SettingKey = ''TitleBuy' + ltrim(str(@ProcessNo)) + '''), '''') AS BuyName,
					0 SQ2,
					H.C1, 
					H.C2, 
					H.C3, 
					H.C4, 
					H.C5, 
					H.C6, 
					H.C7, 
					H.C8, 
					H.C9, 
					H.C10, 
					H.C11, 
					H.C12,
					0 BaseTaxOverWorthCost,
					0 BaseTollOverWorthCost,
					0 BaseVchNo,
					0 BaseVchNo2,
					Case When H.SgnSN1=0 Then '''' Else pub.GetUserName(H.SgnSN1) End Signer1Name,
					Case When H.SgnSN2=0 Then '''' Else pub.GetUserName(H.SgnSN2) End Signer2Name,
					Case When H.SgnSN3=0 Then '''' Else pub.GetUserName(H.SgnSN3) end Signer3Name,
					Case When H.SgnSN4=0 Then '''' Else pub.GetUserName(H.SgnSN4) End Signer4Name,
					Case When H.SgnSN5=0 Then '''' Else pub.GetUserName(H.SgnSN5) End Signer5Name,
					H.Address,
					H.DestinationAddress,
					ISNULL(DR.DescRetSaleName,'''') DescRetSaleName,
					H.ExtraField1 As ExtraField1Sale ,
					0 Wage1,
					0 Wage2,
					0 Wage3,
					0 Wage4,
					0 Wage5,
					0 Wage6,
					0 Wage7,
					0 Wage8,
					0 Wage9,
					0 Wage10,
					'''' WageName,
					isnull(BD.SerialNo ,0) BaskulSerialNo ,
					isnull(BD.FullVehicleWeight,0) FullVehicleWeight,
					isnull(BD.EmptyVehicleWeight,0) EmptyVehicleWeight,
					GH.IsService,
					GoodsReciverIDDtl,
					LocationIDDtl,
					DrAccept ,
					H.ProductSerialID ProductSerialIDHdr,
					H.PSerialNo PSerialNoHdr,
					FmlParam1,
					CurrencyTypeName,
					isnull(tr.Recognition,0)Recognition,
					case when isnull(tr.Recognition,0)=0 then N''انتخاب نشده'' when isnull(tr.Recognition,0)=1 then N''تایید'' when isnull(tr.Recognition,0)=2 then N''تایید مشروط'' when isnull(tr.Recognition,0)=3 then N''تایید ارفاقی'' when isnull(tr.Recognition,0)=4 then N''عدم تایید'' end RecognitionName,
					H.Price,
					tr.DescDtl RecognitionDesc,
					H.TaxSerialNoInvoice TaxSerialNo,
					H.CurrencyDiscount,
					H.ProdManUnitCount,
					H.ProdManSubUnitCount,
					H.SettlementDate,
					[inv].[funGetLastGoodsAmount](D.GoodsID,H.DocDate,0) AS LastGoodsAmount,
					'''' BuyBaseInfo
			INTO	##tbl_Tmp3
			FROM	' + @SD + '  D 
			INNER JOIN ' + @SH + '  H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo '  
			
			SET @StrSelect4 = 
			+ @SaleOrderJoin + '
			LEFT JOIN inv.tblBaskulSalesDtl BD 
			ON (D.BaseProcessID = BD.BaseProcessID AND D.BaseProcessNo = BD.BaseProcessNo AND D.BaseFiscalYear = BD.BaseFiscalYear AND D.BaseSerialNo = BD.BaseSerialNo  AND D.BaseDocRowNo= BD.BaseDocRowNo)
			OR (D.BaseProcessID = BD.ProcessID AND D.BaseProcessNo = BD.ProcessNo AND D.BaseFiscalYear = BD.FiscalYear AND D.BaseSerialNo = BD.SerialNo  AND D.BaseDocRowNo= BD.DocRowNo)			
			LEFT JOIN sal.tblTransportersDtl T ON H.TransporterID = T.TransporterID AND T.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsStatusDtl GS ON H.StoreID = GS.StoreID And D.GoodsID = GS.GoodsID AND GS.DocRowNo =(select max(DocRowNo) from inv.tblGoodsStatusDtl GS2 where  H.StoreID = GS2.StoreID And D.GoodsID = GS2.GoodsID )
			LEFT JOIN sal.tblTransportersDtl T2 ON H.TransporterID2 = T2.TransporterID AND T.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN sal.tblDescRetSaleDtl DR ON DR.DescRetSaleID = H.DescRetSaleID AND DR.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStoresDtl S ON S.StoreID = H.StoreID AND S.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStores SH ON SH.StoreID = H.StoreID 
			LEFT JOIN inv.tblStores SH2 ON SH2.StoreID = D.StoreID2 
			LEFT JOIN inv.tblStoreKeepersDtl SK ON SH.StoreKeeperID = SK.StoreKeeperID AND SK.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStoreKeepersDtl SK2 ON SH2.StoreKeeperID = SK2.StoreKeeperID AND SK2.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblStoresDtl S2 ON S2.StoreID = D.StoreID2 AND S2.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+'			
			LEFT JOIN inv.tblGoods GH_P ON GH_P.GoodsID=SUBSTRING(H.ProductID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH_P.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
			LEFT JOIN sal.tblSaleTypesDtl STD ON STD.SaleTypeID = D.SaleTypeID AND STD.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblBuyTypeDtl BTD ON BTD.BuyTypeID = D.SaleTypeID AND BTD.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN pub.tblProcess P ON P.ProcessID = D.ProcessID AND P.ProcessNo = D.ProcessNo
			OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F
			LEFT JOIN (select distinct ShowInInvoice,GoodsID,SubUnitID,UnitValue, MainUnitValue from inv.tblSubUnitsDtl) V ON V.GoodsID=D.GoodsID AND V.ShowInInvoice=1
			LEFT JOIN inv.tblUnitsDtl W ON W.UnitID=V.SubUnitID	 AND W.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblUnitsDtl X ON X.UnitID=GH.UnitID AND X.LanguageID = ' + LTRIM(RTrim(@LanguageID)) + '
			LEFT JOIN sal.tblPayOffTypesDtl PT ON H.PayOffTypeID = PT.PayOffTypeID AND PT.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsUserPrice UPI on UPI.GoodsID = D.GoodsID and D.UserPriceID=UPI.ID
			LEFT JOIN inv.tblGoodsUserPrice UPI2 on UPI2.GoodsID = D.GoodsID and D.UserPriceID=UPI2.ID
			LEFT JOIN inv.tblGoodsReciverDtl GR on GR.ReciverID = H.GoodsReciverID  AND GR.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblGoodsReciverDtl GRD ON GRD.ReciverID = D.GoodsReciverIDDtl AND GRD.LanguageID = ' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN pub.tblDrivers DRH ON H.DriverID = DRH.DriverID 
			LEFT JOIN pub.tblDriversDtl DRD ON DRH.DriverID = DRD.DriverID
			LEFT JOIN pub.tblCurrencyTypesDtl CR ON H.CurrencyTypeID = CR.CurrencyTypeID AND CR.LanguageID=' + LTrim(RTrim(@LanguageID)) + '
			LEFT JOIN inv.tblInvTempReceiptDtl tr ON tr.ProcessID = D.BaseProcessID AND tr.ProcessNo = D.BaseProcessNo AND tr.FiscalYear = D.BaseFiscalYear AND tr.SerialNo = D.BaseSerialNo AND tr.DocRowNo= D.BaseDocRowNo			 

			WHERE ' + @StrWhere
			SET @StrSelect5 = '
			Group By H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo,D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.GoodsID, H.StoreID, S.StoreName, D.StoreID2, S2.StoreName,
					 tr.Recognition,H.AcntCode, F.LocationID, F.CodeClosed, H.LocationID' + @strUnitNameGrp + @SaleOrderGrp + ', W.UnitName, T.TransporterID, T.TransporterName, T2.TransporterID,
					 T2.TransporterName, D.SaleTypeID, STD.SaleTypeName, BTD.BuyTypeName, SH.StoreKeeperID, SK.StoreKeeperName, H.VisitorAcntCode, H.DocDesc,H.DocDesc2,
					 '+@VchNo+', H.VchNo2, H.ProductID, H.ProductCount, H.DocDate, H.DocDate2, H.DocDate3, H.DocDate4, H.EarnestMoney,
					 F.AccountNumber,F.ShabaAccountNumber,GH.IsService,GoodsReciverIDDtl,LocationIDDtl,DrAccept, H.ProductSerialID	,H.PSerialNo ,
					 H.VchDate, H.DriverID, DRH.DriverTel, DRH.DriverMobile, DRH.VehicleNo,DRH.NationalNumber, DRD.FirstName, DRD.LastName, H.TaxOverWorthCost, H.TollOverWorthCost, 
					 H.DiscountPercent, H.Discount, H.Discount2,H.Discount3 ,CampaignID, H.TaxCost, H.TotalLineDiscount, GH.ExtraField1, GH.ExtraField2, GH.ExtraField3,GH.ExtraField4, GH.ExtraField5, 
					 GH_P.ExtraField1, GH_P.ExtraField2, GH_P.ExtraField3,GH_P.ExtraField4, GH_P.ExtraField5,PayIdentity,
					 H.OtherIncome,D.OtherIncomePerentDtl,D.OtherIncomeDtl,H.BascolWeight,H.WasteWeight,H.PureWeight, GH.PureWeight , H.OtherCost, D.GoodsID2, F.Tel, F.OtherTels, F.EconomicalCode, F.AcntName, 
					 F.AcntComment, F.SaleCash, F.Address1, F.Address2, F.InitialGrad, F.CustomerFirstName, F.CustomerLastName, F.ZipCode, F.InternetAddress,
					 F.CompanyRegisterNo, F.NationalIDNumber, F.Mobile, F.OrganzationName, F.MaxDebitRemain, F.MaxReceivableRemain, F.DistributionPoint,
					 F.AsnafID, F.Sequence,F.TableauText, F.Fax, F.SMSMobile, F.Email, F.MemberDate, F.VisitPathID1, F.VisitPathID2, F.VisitPathID3, F.VisitPathID4,
					 F.TransporterID, F.NationalIdentity, F.SaleCustomerType, F.BuyCustomerType, F.CustomerKindID, F.SalesRoomClass, F.AcntContainTax,F.StoreZipCode,PersonType, PersonTypeName, 
					 H.PackingCost, S.Address, S2.Address, SH.StoreKeeperID, SK.StoreKeeperName, SH2.StoreKeeperID, SK2.StoreKeeperName,F.AccExtraField1,F.AccExtraField2,F.AccExtraField3,F.AccExtraField4,
					 F.AccExtraField5,F.AccExtraField6,F.AccExtraField7,F.AccExtraField8,F.AccExtraField9,F.AccExtraField10,tr.DescDtl,H.TaxSerialNoInvoice, H.CurrencyDiscount,
					 H.ProdManUnitCount, H.ProdManSubUnitCount,H.SettlementDate,SH.Tel, SH2.Tel, H.TransportationCost, H.CurrencyTransportationCost, H.CurrencyTransportationIncome, H.TransportationIncome, P.ProcessName, H.CashAmount, H.ChequeAmount,
					 H.SessionNo, H.SessionNo2, H.SessionNo3, H.SessionNo4, H.SessionNo5, H.AfterSaleDiscount, V.UnitValue, V.MainUnitValue,
					 X.UnitName, H.TransporterID2, GH.TechnicalSpecifications, GH.TechnicalNo, GH.GoodsCID, H.AgreeNo,H.OwnerDocNo, H.ComssionCostPrice, H.BasculePrice,
					 H.LaborPrice, H.TransportPrice, H.C1, H.C2, H.C3, H.C4, H.C5, H.C6, H.C7, H.C8, H.C9, H.C10, H.C11, H.C12, H.SgnSN1, H.SgnSN2, H.SgnSN3, H.SgnSN4, H.SgnSN5,H.CashID , H.KotagNo , H.KotagDate , H.AssessmentLocation , H.ExitLocation ,H.PriceParvane 
					, H.Address, H.DestinationAddress,ISNULL(DR.DescRetSaleName,''''), H.ExtraField1, D.EnterKind, D.QtyRemain' + @StrGoodsPriceGrp + ', H.VisitorAcntCode2,
					 Case When IsNumeric(D.ConstText1) = 0 OR D.ConstText1 = ''0'' OR D.ConstText1 = '''' Then 0 Else D.ConstText1 End, H.DiscountTaxOverWorth,H.FmlParam1,CurrencyTypeName,tr.Recognition,
					 H.PayOffTypeID, PT.PayOffTypeName, H.TTMSPayOffTypeID, DR.DescRetSaleID, IsNull(H.GoodsReciverID,''''), IsNull(GR.ReciverName,''''),IsNull(GRD.ReciverName,'''') ' + @StrUserPriceGrp + ' ' + @StrWithBatchGrp + '
					 ,H.GoodsReciverID,GH.BarCode,GR.ReciverName,GRD.ReciverName,H.CurrencyTypeID ,H.CurrencyRate, CurrencyAmount,D.ConstText1,U.UnitName,H.SgnSN1,H.Price
					 ,BD.SerialNo ,BD.FullVehicleWeight,BD.EmptyVehicleWeight
					 
			ORDER BY DocRowNo'

			Print @StrSelect
			Print @StrSelect2
			Print @StrSelect3
			Print @StrSelect4
			Print @StrSelect5
			
			SET @StrSelect = @StrSelect + @StrSelect7 + @StrSelect2 + @StrSelect3 +  @StrSelect6 + @StrSelect4+ @StrSelect5;
			EXEC sp_executesql @StrSelect;

			-- ===============
			SET @StrSelect = '
			UPDATE ##tbl_Tmp3 
			SET DocRowNo = ROW_NO,RowNo = ROW_NO
			FROM ##tbl_Tmp3 A inner join 
				(SELECT GoodsID,GoodsPrice,ConstText1,ConstText2,Batch,ROW_NUMBER() OVER(ORDER BY GoodsID,GoodsPrice,ConstText1,ConstText2,Batch) As ROW_NO
				 FROM ##tbl_Tmp3) B
			ON 	A.GoodsID=B.GoodsID  AND A.GoodsPrice=B.GoodsPrice AND A.ConstText1=B.ConstText1 AND A.ConstText2=B.ConstText2 AND A.Batch=B.Batch '
						
			--Print @StrSelect
			EXEC sp_executesql @StrSelect;
					
			update ##tbl_Tmp3
			Set DocDate2H=case when isnull(DocDate2H,'')='' then DocDateH else DocDate2H end 
			,DocDate3H= case when isnull(DocDate3H,'')='' then case when isnull(DocDate2H,'')='' then DocDateH else DocDate2H end  else DocDate3H end  
			,DocDate4H =case when isnull(DocDate3H,'')='' then case when isnull(DocDate3H,'')='' then case when isnull(DocDate2H,'')='' then DocDateH else DocDate2H end  else DocDate3H end   else DocDate4H end   
				
			-- ===============					
			SET @StrSelect = '
			SELECT H.*,
				   S1.UserSign As UserSignature1,
				   S8.UserSign As UserSignature2,
				   S9.UserSign As UserSignature3,
				   S3.UserSign As Signature1,
				   S4.UserSign As Signature2,
				   S5.UserSign As Signature3,
				   S6.UserSign As Signature4,
				   S7.UserSign As Signature5	'+ @StrDebitRemain +' 		
			INTO  ##tbl_Tmp2
			FROM  ##tbl_Tmp3 H
			LEFT  JOIN #tbl_Invoice_Signatures S1 on S1.UserID = (SELECT UserID FROM #tbl_Session1 Where SerialNo = H.SerialNo)
			LEFT  JOIN #tbl_Invoice_Signatures S8 on S8.UserID = (SELECT UserID FROM #tbl_Session2 Where SerialNo = H.SerialNo)
			LEFT  JOIN #tbl_Invoice_Signatures S9 on S9.UserID = (SELECT UserID FROM #tbl_Session3 Where SerialNo = H.SerialNo)
			LEFT  JOIN #tbl_Invoice_Signatures S3 on S3.UserID = (SELECT UserID FROM #tbl_SgnSN1 Where SerialNo = H.SerialNo)
			LEFT  JOIN #tbl_Invoice_Signatures S4 on S4.UserID = (SELECT UserID FROM #tbl_SgnSN2 Where SerialNo = H.SerialNo)
			LEFT  JOIN #tbl_Invoice_Signatures S5 on S5.UserID = (SELECT UserID FROM #tbl_SgnSN3 Where SerialNo = H.SerialNo)
			LEFT  JOIN #tbl_Invoice_Signatures S6 on S6.UserID = (SELECT UserID FROM #tbl_SgnSN4 Where SerialNo = H.SerialNo)
			LEFT  JOIN #tbl_Invoice_Signatures S7 on S7.UserID = (SELECT UserID FROM #tbl_SgnSN5 Where SerialNo = H.SerialNo)'

			Print @StrSelect
			EXEC sp_executesql @StrSelect;
					
		END
	END	

	begin try
		drop table #tbl_Tmp1
		drop table #tbl_Tmp2
		drop table #tbl_Tmp3
	end try
	begin catch
	end catch
	if exists (select * from tempdb.sys.tables where name ='##tbl_Tmp1')
		select * into #tbl_Tmp1 from ##tbl_Tmp1
	if exists (select * from tempdb.sys.tables where name ='##tbl_Tmp2')
		select * into #tbl_Tmp2 from ##tbl_Tmp2
	if exists (select * from tempdb.sys.tables where name ='##tbl_Tmp3')
		select * into #tbl_Tmp3 from ##tbl_Tmp3
	begin try
		drop table ##tbl_Tmp1
		drop table ##tbl_Tmp2
		drop table ##tbl_Tmp3
	end try
	begin catch
	end catch

	-- ******************************************************************************
	IF @ProcessID = 230  OR @ProcessID = 235 OR @ProcessID = 127 OR @ProcessID = 128
	BEGIN	
		SET @StrSelect = '
		INSERT INTO #tbl_result
		Select S.SerialNo, S.RowNo, S.DocRowNo, S.GoodsID, '''', 
			   Case When (SU.TolerancePercent > 0 OR ToleranceValue > 0) And 
						 (S.SubUnitID = (Select SubUnitID
										 From inv.tblSubUnitsDtl
										 Where GoodsID = S.GoodsID And ShowInInvoice = 1)) 
			   Then 
					S.SubUnitQuantity * (SU.MainUnitValue/SU.UnitValue) 
			   Else 
					S.GoodsQuantity
			   End, '''', '''', 0, '''', '''', 0, 0, 0, '''', '''',0
		From #tbl_Tmp1 S
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = SUBSTRING(S.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + 
										   ltrim(rtrim(STR(@str_GoodsSum))) + ') AND 
										   SU.SubUnitID = (Select SubUnitID
														   From inv.tblSubUnitsDtl
														   Where GoodsID = S.GoodsID And ShowInInvoice = 1) '		
		Print @StrSelect;
		Exec sp_executesql @StrSelect;
	END
	ELSE
	BEGIN	
		SET @StrSelect = '
		INSERT INTO #tbl_result
		Select S.SerialNo, S.RowNo, S.DocRowNo, S.GoodsID, '''', 
			   Case When (SU.TolerancePercent > 0 OR ToleranceValue > 0) And 
						 (S.SubUnitID = (Select SubUnitID
										 From inv.tblSubUnitsDtl
										 Where GoodsID = S.GoodsID And ShowInInvoice = 1)) 
			   Then 
					S.SubUnitQuantity * (SU.MainUnitValue/SU.UnitValue) 
			   Else 
					S.GoodsQuantity
			   End, '''', '''', 0, '''', '''', 0, 0, 0, '''',Batch,CurrencyDiscount
		From #tbl_Tmp2 S 
		LEFT JOIN inv.tblSubUnitsDtl SU ON SU.GoodsID = SUBSTRING(S.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + 
										   ltrim(rtrim(STR(@str_GoodsSum))) + ') AND 
										   SU.SubUnitID = (Select SubUnitID
														   From inv.tblSubUnitsDtl
														   Where GoodsID = S.GoodsID And ShowInInvoice = 1)	'		
		Print @StrSelect;
		Exec sp_executesql @StrSelect;	
	END

	-- ******************************************************************************
	-- *********************************** Units ************************************
	-- ******************************************************************************
	declare cur_goods cursor for
		select SerialNo, RowNo, GoodsID, GoodsQuantity
		from #tbl_result
	open cur_goods;
		
	fetch next from cur_goods into @serial_no, @docrowno, @goods_id, @goods_quantity
	while (@@fetch_status = 0)
	begin
		-- 1- empty units table
		delete from @tbl_units
		
		-- 2- fill units of 1 goods
		insert into @tbl_units
		select top 3 t.UnitID, u.UnitName, t.UnitValue, t.MainUnitValue,
		(SELECT COUNT(*) 
		 from(
				select UnitID, 1 As UnitValue,1 MainUnitValue
				from inv.tblGoods
				where GoodsID = @goods_id
				union
				select SubUnitID, UnitValue,MainUnitValue
				from inv.tblSubUnitsDtl S
				where GoodsID = @goods_id and ShowInInvoice = 1) z
		)cnt
		from
		(
			select UnitID, 1 As UnitValue,1 MainUnitValue
			from inv.tblGoods
			where GoodsID = @goods_id
			union
			select SubUnitID, UnitValue, MainUnitValue
			from inv.tblSubUnitsDtl S
			where GoodsID = @goods_id and ShowInInvoice = 1
			
		) t inner join inv.tblUnitsDtl u on u.UnitID = t.UnitID and u.LanguageID = @LanguageID
		order by (t.MainUnitValue/ t.UnitValue) desc
			
		-- read units row by row
		declare cur_units cursor for
			select * from @tbl_units
		open cur_units;
			
		--select * from @tbl_units

		-- init
		set @unit_idGoods1			 = '';
		set @unit_nameGoods1		 = '';
		set @unit_valueGoods1		 =  0;
		set @Mainunit_valueGoods1	 =  0;
		
		set @unit_idGoods2			 = '';
		set @unit_nameGoods2		 = '';
		set @unit_valueGoods2		 =  0;
		set @Mainunit_valueGoods2	 =  0;
		
		--select * from @tbl_units
		
		-- First Unit
		fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

		if (@@fetch_status = 0)
		begin
			set @unit_idGoods1		= @unit_id;
			set @unit_nameGoods1	= @unit_name;
			
			if @Cnt > 1
			Begin
				set @unit_valueGoods1	 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
			End
			Else
			Begin
				set @unit_valueGoods1	 = @goods_quantity * @unit_value / @Mainunit_value
			End
			
			set @goods_quantity = @goods_quantity - (@unit_valueGoods1 * @Mainunit_value / @unit_value)

			-- Second Unit
			fetch next from cur_units into @unit_id, @unit_name, @unit_value, @Mainunit_value, @Cnt;

			if (@@fetch_status = 0)
			begin
				set @unit_idGoods2		= @unit_id;
				set @unit_nameGoods2	= @unit_name;
				
				if @Cnt > 2 
				Begin
					set @unit_valueGoods2	 = floor((@goods_quantity + 0.000000001) * @unit_value / @Mainunit_value)
				End
				else	
				Begin
					set @unit_valueGoods2	 = @goods_quantity * @unit_value / @Mainunit_value
				End
				
				set @goods_quantity	= @goods_quantity - (@unit_valueGoods2 * @Mainunit_value / @unit_value)
			end;

		end;

		-- close units cursor
		close cur_units;
		deallocate cur_units;
		-- update result
		update #tbl_result
		set GoodsName				= IsNull([pub].[funGetGoodsName](G.GoodsID, @LanguageID), ''),
			UnitIDGoods1			= IsNull(@unit_idGoods1,''),
			UnitNameGoods1			= IsNull(@unit_nameGoods1,''),
			GoodsQuantity1			= IsNull(@unit_valueGoods1,0),
			
			UnitIDGoods2			= IsNull(@unit_idGoods2,''),
			UnitNameGoods2			= IsNull(@unit_nameGoods2,''),
			GoodsQuantity2			= IsNull(@unit_valueGoods2,0),
			
			Weight					= IsNull(G.GoodsWeight,0),
			Volume					= IsNull(G.GoodsLength * G.GoodsHeight * G.GoodsWidth,0),
			BarCode					= IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
			
		from inv.tblGoods G
		INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(G.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LanguageID
		where G.GoodsID = @goods_id AND #tbl_result.GoodsID = @goods_id And #tbl_result.SerialNo = @serial_no And
			  #tbl_result.RowNo = @docrowno
		
		-- next
		fetch next from cur_goods into @serial_no, @docrowno, @goods_id, @goods_quantity
	end

	-- close goods cursor
	Close cur_goods;
	Deallocate cur_goods;
	-- ******************************************************************************
	-- ********************************** Units End *********************************
	-- ******************************************************************************

	Declare @PartNumerV int
	Declare @StartLayerV int
	Declare @LenLayerV int

	select @PartNumerV=[acc].[FunGetAcntInfoForRemain](1)
	select @StartLayerV=[acc].[FunGetAcntInfoForRemain](2)
	select @LenLayerV=[acc].[FunGetAcntInfoForRemain](3)

	IF @ProcessID = 230 OR @ProcessID = 235 OR @ProcessID = 127 OR @ProcessID = 128
	BEGIN
	
	 select AcntCode,DocDate,GoodsQuantity DebitRemain
	 into   #tblAcntCodeRemain  from  #tbl_Tmp1  where 1=0

	 insert into #tblAcntCodeRemain  
	 select Distinct AcntCode,DocDate,0 from #tbl_Tmp1  T
	 
	If (@SalShowRemainInPreSaleDoc = 1) OR @ProcessID = 100
		update #tblAcntCodeRemain
			set 	DebitRemain=acc.funAcntDebitRemainFull(AcntCode,DocDate) 
	--SELECT * from #tblAcntCodeRemain		 
	 Select T.*, Round(IsNull(R.GoodsQuantity,0), @QuantityDecimalsToForms) RGoodsQuantity,
			   Round(IsNull(R.GoodsQuantity1,0), @QuantityDecimalsToForms) GoodsQuantity1, ISNULL(R.UnitIDGoods1,'') UnitIDGoods1, 
			   ISNULL(R.UnitNameGoods1,'') UnitNameGoods1, Round(IsNull(R.GoodsQuantity2,0), @QuantityDecimalsToForms) GoodsQuantity2, 
			   ISNULL(R.UnitIDGoods2,'') UnitIDGoods2, ISNULL(R.UnitNameGoods2,'') UnitNameGoods2, ISNULL(R.Weight,0) RWeight, 
			   ISNULL(R.Volume,0) RVolume, ISNULL(R.BarCode,0) RBarCode, @sal_ShowMainAndSubUnitInRpt MainAndSubUnit, 
			   @sal_ShowSubUnitInRpt ShowSubUnit, @sal_HasDst HasDst, @SalShowRemainInPreSaleDoc ShowRemain, @TTMSPayTypeShowForAll TTMSPayTypeShowForAll
			   ,@ExtraParams ExtraParams,'' MobileVisitor,'' SMSMobileVisitor,0 BaseWage,TechnicalSpecifications,TechnicalNo
			   ,AR.DebitRemain, @ShowContainerAndPos ShowContainerAndPos
		From #tbl_Tmp1 T
		inner join #tblAcntCodeRemain AR on AR.AcntCode=T.AcntCode AND AR.DocDate=T.DocDate
		left join #tbl_result R ON  R.SerialNo = T.SerialNo And R.RowNo = T.RowNo  And R.Batch = T.Batch

		order by T.SerialNo,T.DocRowNo
	END
	ELSE
	BEGIN	
		Select T.*, IsNull(R.GoodsQuantity,0) RGoodsQuantity, IsNull(R.GoodsQuantity1,0) GoodsQuantity1, 
			   ISNULL(R.UnitIDGoods1,'') UnitIDGoods1, ISNULL(R.UnitNameGoods1,'') UnitNameGoods1, 
			   --IsNull(R.GoodsQuantity2,0) GoodsQuantity2, 
			   Case When (SU.TolerancePercent > 0 OR ToleranceValue > 0) And 
						 (T.SubUnitID = (Select SubUnitID
										 From inv.tblSubUnitsDtl
										 Where GoodsID = T.GoodsID And ShowInInvoice = 1)and @sal_ShowMainAndSubUnitInRpt=0) 
			   Then 
					T.GoodsQuantity
			   Else 
					IsNull(R.GoodsQuantity2,0)
			   End GoodsQuantity2,		   
			   ISNULL(R.UnitIDGoods2,'') UnitIDGoods2, 
			   ISNULL(R.UnitNameGoods2,'') UnitNameGoods2, ISNULL(R.Weight,0) RWeight, ISNULL(R.Volume,0) RVolume, 
			   ISNULL(R.BarCode,0) RBarCode, @sal_ShowMainAndSubUnitInRpt MainAndSubUnit, @sal_ShowSubUnitInRpt ShowSubUnit, 
			   @sal_HasDst HasDst, @SalShowRemainInPreSaleDoc ShowRemain, @TTMSPayTypeShowForAll TTMSPayTypeShowForAll,@PrintSerials PrintSerials
			   ,@ExtraParams ExtraParams,isnull(A.Mobile,'') MobileVisitor,isnull(A.SMSMobile,'') SMSMobileVisitor,
			   ISNULL(case when @ProcessID=70 THEN (SELECT TOP 1 Wage FROM inv.tblStorageDocsDtl S WHERE T.ProcessID=S.BaseProcessID and T.ProcessNo=S.BaseProcessNo and T.FiscalYear=S.BaseFiscalYear and T.SerialNo=S.BaseSerialNo ORDER BY DocRowNo) ELSE 0 END,0) BaseWage,
			   CDiscount, @ShowContainerAndPos ShowContainerAndPos--,IsService,T.DebitRemain
			   into #tblTmp 
		From #tbl_Tmp2 T
		Left join acc.tblAcnt A on Substring(T.VisitorAcntCode,@StartLayerV,@LenLayerV)= A.AcntCode and A.PartNumber=@PartNumerV
		left join #tbl_result R ON R.SerialNo = T.SerialNo And R.RowNo = T.RowNo And R.GoodsID = T.GoodsID  And R.Batch = T.Batch
		left join inv.tblSubUnitsDtl SU ON SU.GoodsID = SUBSTRING(T.GoodsID,@str_Goods+1,@str_GoodsSum) AND 
										   SU.SubUnitID = (Select SubUnitID
														   From inv.tblSubUnitsDtl		
														   Where GoodsID = T.GoodsID And ShowInInvoice = 1)		
		where @NotPrintIsService=0 or (@NotPrintIsService=1 and IsService=0)
		order by T.SerialNo,T.DocRowNo													

		IF @ProcessID =111
		begin
	 
			select Distinct t.DocDate ,cast(D.SerialNo as varchar(50))	PSerialNo3, D.ProductSerialID 
			,D.ProductID ,[pub].[funGetGoodsName] (D.ProductID,1) ProductName
			,D.ProductID WarrantyTypeID ,[pub].[funGetGoodsName] (D.ProductID,1) WarrantyTypeName
			,D.ProductID OperatorID ,[pub].[funGetGoodsName] (D.ProductID,1) OperatorName
			,t.DocDate ServiceStartDate
			,t.DocDate ServiceEndDate
			,t.DocDate InstallDate
			 into #tblWarranty
			 from #tblTmp t 
			 inner join pln.tblProductSerials D on D.ProductID <>''  AND  D.SerialNo = t.PSerialNoHdr AND  D.ProductSerialID = t.ProductSerialIDHdr
			 
 			update  #tblWarranty	
				set WarrantyTypeID='',WarrantyTypeName=''
				,OperatorID='',OperatorName=''
				,ServiceStartDate='',ServiceEndDate='',InstallDate=''
			
			select WarrantyTypeID  into #tblWarrantyID from #tblWarranty where 1=0

			declare  @WarrantyTypeID	varchar(20)
			declare  @DocDate			char(1)

			SET @FiscalYear = right  (db_name(),4) 

			DECLARE csr CURSOR FOR 
			SELECT PSerialNo3,DocDate
			FROM #tblWarranty

			OPEN csr
				FETCH NEXT FROM csr INTO @WarrantyTypeID,@DocDate

				WHILE @@Fetch_Status = 0
				BEGIN
		
					set @StrSelect=' insert into  #tblWarrantyID
									exec  TS.[pub].[SPGetWarrantyTypeID] '''+@db_0000+ ''',''' +@DocDate+''','''+@WarrantyTypeID+''','''+ ltrim(str(@FiscalYear)) +''''

					Print @StrSelect;
					Exec sp_executesql @StrSelect;	

					if (select count(*) from #tblWarranty)>0
						update #tblWarranty
						set WarrantyTypeID=(select top 1 WarrantyTypeID from #tblWarrantyID)
						where PSerialNo3=@WarrantyTypeID
					
					
					delete from #tblWarrantyID

				FETCH NEXT FROM csr INTO @WarrantyTypeID,@DocDate
		
				END

				CLOSE csr
				DEALLOCATE csr				

				set @StrSelect=' update #tblWarranty
									set WarrantyTypeName=b.WarrantyTypeName
								from #tblWarranty a
								inner join '+@db_0000+ '.srv.tblWarrantyTypeDtl b
								on a.WarrantyTypeID=b.WarrantyTypeID and b.LanguageID='+ str(@LanguageID)+''

				Print @StrSelect;
				Exec sp_executesql @StrSelect;	
 
				set @StrSelect=' update #tblWarranty
									set OperatorID=W.OperatorID
									,OperatorName=O.OperatorName
									,ServiceStartDate=W.ServiceStartDate
									,ServiceEndDate=W.ServiceEndDate
									,InstallDate=W.InstallDate
								from #tblWarranty a
								inner join '+@db_0000+ '.srv.tblWarrantyHdr W on  W.ProcessID=650 and W.PSerialNo=a.PSerialNo3
									Left Join '+@db_0000+ '.srv.tblOperatorDtl O ON W.OperatorID=O.OperatorID AND O.LanguageID=1'
				Print @StrSelect;
				Exec sp_executesql @StrSelect;	

				select t.*,w.WarrantyTypeID	,w.WarrantyTypeName ,OperatorID,OperatorName,ServiceStartDate,ServiceEndDate,InstallDate,D.ProductID ProductID2,cast(D.SerialNo as varchar(50))	PSerialNo2,
					--,DocDate,BaseSerialNo	,BaseFiscalYear	,BaseProcessID	,NumberPerSerial,GoodsID2		,GoodsID3	
					SerialPrefix	,D.ColorID	,RegDate	,RegEmpID	,IsPrinted		,UserID	,D.MotorTypeID	,IsPrinted2	,IsPrinted3	
					,GoodsID1,GoodsID4,	Property1	,Property2
					,[pub].[funGetGoodsName] (D.ProductID,1)  ProductName2,ISNULL(M.MotorTypeName,'') MotorTypeName,ISNULL(C.ColorName,'') ColorName 			
				 from #tblTmp t 
				 left join pln.tblProductSerials D on D.ProductID <>''  AND   cast(D.SerialNo as varchar(50))=cast( t.PSerialNoHdr as varchar(50)) -- AND  D.ProductSerialID = t.ProductSerialIDHdr
				 left join #tblWarranty	w on w.PSerialNo3 = t.PSerialNoHdr --AND  w.ProductSerialID = t.ProductSerialIDHdr
				 left Join pub.tblColors C on C.ColorID = D.ColorID 
				 left Join pln.tblMotorTypesDtl M on M.MotorTypeID = D.MotorTypeID And M.LanguageID = 1 
				order by t.SerialNo,t.DocRowNo

			end
		else
			begin
	
			Declare @G1 int,@G2 int,@G3 int,@G4 int,@G5 int,@G6 int,@G7 int,@G8 int,@G9 int
			Declare @B1 int,@B2 int,@B3 int,@B4 int,@B5 int,@B6 int,@B7 int,@B8 int,@B9 int
			
			select @G1=Layer1 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G2=Layer1+Layer2 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G3=Layer1+Layer2+Layer3	from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G4=Layer1+Layer2+Layer3+Layer4 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G5=Layer1+Layer2+Layer3+Layer4+Layer5 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G6=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G7=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G8=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1
			select @G9=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1

			select @B1=Layer1 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B2=Layer1+Layer2 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B3=Layer1+Layer2+Layer3	from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B4=Layer1+Layer2+Layer3+Layer4 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B5=Layer1+Layer2+Layer3+Layer4+Layer5 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B6=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B7=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B8=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1
			select @B9=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblBatch' and PartNumber=1

			Declare @FmlParam1		NVarChar(Max)
			SELECT @FmlParam1 = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'FmlParam1'

			select *
			,[pub].[GetUserName](@PrintUserID) PrintUserName
			,pub.funGetGoodsName (SubString(ProductID,1,@G1),1) GoodsName01  
			,pub.funGetGoodsName (SubString(ProductID,1,@G2),1) GoodsName02  
			,pub.funGetGoodsName (SubString(ProductID,1,@G3),1) GoodsName03  
			,pub.funGetGoodsName (SubString(ProductID,1,@G4),1) GoodsName04  
			,pub.funGetGoodsName (SubString(ProductID,1,@G5),1) GoodsName05  
			,pub.funGetGoodsName (SubString(ProductID,1,@G6),1) GoodsName06  
			,pub.funGetGoodsName (SubString(ProductID,1,@G7),1) GoodsName07  
			,pub.funGetGoodsName (SubString(ProductID,1,@G8),1) GoodsName08  
			,pub.funGetGoodsName (SubString(ProductID,1,@G9),1) GoodsName09  

			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B1),1) BatchName01  
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B2),1) BatchName02
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B3),1) BatchName03
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B4),1) BatchName04
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B5),1) BatchName05
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B6),1) BatchName06
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B7),1) BatchName07
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B8),1) BatchName08
			,inv.funGetBatchName (SubString(BatchNoHdr,1,@B9),1) BatchName09,@FmlParam1 FmlParam1Name
			from #tblTmp
			order by SerialNo,DocRowNo
			end 

	END
	-- ******************************************************************************	
END
	
GO
