USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/05/09
-- Viewed By	 : 
-- Last Modified : 1393/08/18
-- Last Modifier : TakroSystem\Hamid
-- Description	 : گزارش موجودی یک کالا در انبارها
-- ==============================================
CREATE PROCEDURE [inv].[RptStore_Stock_Goods] 
	@GoodsID		VarChar(20) = Null,
	@DateTo			Char(10) = Null,
	@SortFields		VarChar(100) = Null,
	@RepOptions		VarChar(50) = '10000',
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(200) = Null
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrSelectR	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrYear	Char(4);
DECLARE @ZeroCycle	Bit;
DECLARE @ZeroQuantity Bit;
DECLARE @ZeroAmount	Bit -- شامل سطرهای مبلغ صفر
DECLARE @UsePE		Bit;
DECLARE @PEValue	Bit;
Declare @GoodsAmount varchar(20)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@UserID		Int;
DECLARE	@UserIsAdmin bit;

DECLARE	@HasSerial			Bit;
DECLARE	@FromExpireDate		Varchar(10);
DECLARE	@ToExpireDate		Varchar(10);
DECLARE	@TechnicalNo		NVarchar(50);
DECLARE @BatchNo1	VarChar(20);
DECLARE @BatchNo2	VarChar(20);

DECLARE @UserPriceID			Varchar(20);
DECLARE @OtherFiscalYear		varchar(1)

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1
	
	SET @OtherFiscalYear  = '0'
	SELECT @OtherFiscalYear = SettingValue from pub.tblSettings where SettingKey = 'OtherFiscalYear'

	IF @OtherFiscalYear IS NULL 
		SET @OtherFiscalYear = '0'
		
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
	
	-- Init -----------------------------------------
	If (@ZeroAmount	Is Null)	SET @ZeroAmount = 0;
	If (@RepOptions Is Null)	SET @RepOptions = '10000';
	if (@GoodsID	is null)	set @GoodsID = '';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);

	set @GoodsAmount = LTRIM(inv.funGoodsAmount(@DateTo))
	SET @StrYear = LTrim(RIGHT(db_name(), 4));

	SET @ZeroAmount		= Substring(@RepOptions, 1, 1)
	SET @ZeroQuantity	= Substring(@RepOptions, 2, 1)
	SET @ZeroCycle		= Substring(@RepOptions, 3, 1)
	SET @UsePE			= Substring(@RepOptions, 4, 1)
	SET @PEValue		= Substring(@RepOptions, 5, 1)
	
	SET @HasSerial		= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @FromExpireDate	= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @ToExpireDate	= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @TechnicalNo	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @BatchNo1		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	SET @BatchNo2		= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @UserPriceID	= LTrim(pub.funSplitString(@ExtraParams, '@', 7));
	
	--select @BatchNo1,@BatchNo2
	------------------------------------------------------------

	-- Where Clause ---------------------------------
	SET @StrWhere = '(D.GoodsID=''' + @GoodsID + ''') 
					 And SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') IN 
					(Select GoodsID From inv.tblGoods Where IsService = 0 AND PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ')'
	
	IF @OtherFiscalYear = '0'
		SET @StrWhere = @StrWhere +' AND (D.FiscalYear = ' + @StrYear + ')'

	SET @StrSelectR = '';

	If (@UsePE = 1)
		If (@PEValue = 1) 
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 1)'
		Else
			SET @StrWhere = @StrWhere + ' AND (D.PhysicallyEffected = 0)'

	If @DateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (D.DocDate<=''' + @DateTo + ''')'

	If (@ZeroAmount = 0) 
		SET @StrWhere = @StrWhere + ' AND (D.' + @GoodsAmount +' <> 0) '
		
	If (@TechnicalNo <> '' And @TechnicalNo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (UPPER(D.TechnicalNo) = UPPER(''' + @TechnicalNo + '''))'
	If (@BatchNo1 <> '' And @BatchNo1 Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.BatchNo >= ''' + @BatchNo1 + ''')'
	If (@BatchNo2 <> '' And @BatchNo2 Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.BatchNo <= ''' + @BatchNo2 + ''')'
	
	IF (@UserPriceID Is Not Null) And (@UserPriceID <> '') And (@UserPriceID <> '0')
		SET @StrWhere = @StrWhere + ' AND (D.UserPriceID = ''' + LTrim(RTrim(@UserPriceID)) + ''')'

	-------------------------------------------------
	if (@ZeroCycle = 1)
		set @StrSelectR = ' 
			UNION all 
			SELECT StoreID, 0, 0,''''
			FROM inv.tblStoresDtl 
			WHERE (StoreID <> '''')'

	begin try
		drop table ##tbl_Store_Stock_Goods
	end try
	begin catch
	end catch
	
	-- Select Clause --------------------------------
	SET @StrSelect = '
		SELECT	D.StoreID, S.StoreName, IsNull([inv].[FunGetGoodsBarCode] (''' + @GoodsID + '''), '''') BarCode, 
				SUM(CASE WHEN D.EnterKind = +1 THEN D.GoodsQuantity ELSE 0 END) TotalQuantityInput,
				SUM(CASE WHEN D.EnterKind = -1 THEN D.GoodsQuantity ELSE 0 END) TotalQuantityOutput
		into	##tbl_Store_Stock_Goods
		FROM
		(
			SELECT D.StoreID, D.GoodsQuantity, D.EnterKind ,D.BatchNo
			FROM inv.tblStorageDocsDtl D 		
			WHERE ' + @StrWhere + '
			' + @StrSelectR + '
		) D INNER JOIN inv.tblStoresDtl S ON D.StoreID = S.StoreID 
		GROUP BY D.StoreID, S.StoreName
		'

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
	------------------------------------------------------------
	if (@UserIsAdmin = 0)
	begin
		exec pub.SpFilterByPermission2 '##tbl_Store_Stock_Goods', 'StoreID', 'inv.tblStores', @UserID;
	end

	If (@ZeroQuantity = 0)
		SET @StrSelect = '
		SELECT * 
		FROM ##tbl_Store_Stock_Goods T 
		WHERE (TotalQuantityInput <> TotalQuantityOutput) '
	else
		SET @StrSelect = '
		SELECT * 
		FROM ##tbl_Store_Stock_Goods T '

	-- Sort Clause ---------------------------------------------
	If @SortFields Is Not Null AND (@SortFields <> '') 
		SET @StrSelect = @StrSelect + ' ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
