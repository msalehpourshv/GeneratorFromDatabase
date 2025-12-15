USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/01/21
-- Viewed By	 : 
-- Last Modified : 1386/08/29
-- Description: <Production Goods Needed>
-- ----------------------------------------------------------------
-- مواد مورد نیاز برای تولید یک یا چند محصول با توجه به میزان موجودی 
-- برای یک محصول خاص می تواند بصورت نمایش درختی استفاده شود
-- ----------------------------------------------------------------
-- =================================================================
CREATE PROCEDURE [prd].[spProduceNeeds]
	@SerialNo	INT=1,
	@StoreID	Varchar(20)='01',
	@AcntCode	Varchar(20)='',
	@DocDate	Varchar(10)='',
	@LanguageID	TinyInt = 1
-- ----------------------------------------------------
-- if value of @ProductCode is'nt null then 
--    result produced from that product only
--    and can be displayed as tree
-- else 
--    result produced from content of #tblInputProducts
-- ----------------------------------------------------
WITH ENCRYPTION
AS

-- جدول برای لیست محصولاتی که باید تولید شوند
CREATE TABLE #tblInputProducts
(
	ProduceProduct    VarChar(20) Not Null,
	ProduceQuantity   Real Not Null,
    FormulaNo         INT, 
	WageRate		  INT,	
	AcntCode		  VarChar(20)	
)
-- جدول موجودی کالاها
CREATE TABLE #tblGoodsStock
(
	GoodsID    VarChar(20) COLLATE Arabic_CS_AS  Not Null,
	GoodsQty   Real Not Null
)
-- جدول نتیجه
CREATE TABLE #tblResult
(
	ProductID	VarChar(20) COLLATE Arabic_CS_AS  Not Null, 
	GoodsID		VarChar(20) COLLATE Arabic_CS_AS  Not Null, 
	GoodsQty	Real Not Null,
	GoodsRequested	Real Not Null,
	IsLeaf		Bit
)
-- جدول فرمول محصول - کالا
CREATE TABLE #tblProductGoods
(
	ProductID  VarChar(20) COLLATE Arabic_CS_AS Not Null,
	GoodsID    VarChar(20) COLLATE Arabic_CS_AS Not Null,
	GoodsQty   Real Not Null,
	SubUnitQty Real Not Null,
	UnitID     VarChar(20) COLLATE Arabic_CS_AS Not Null,
	FormulaNo  INT Not Null,
	WageRate   INT Not Null,
	AcntCode		  VarChar(20)	
)

----------- DECLARE Variables ----------------------
DECLARE	@ProductID		VarChar(20)
DECLARE	@FormulaNo		INT
DECLARE	@WageRate		int
DECLARE	@ProductQty     Real
DECLARE	@GoodsID		VarChar(20) 
DECLARE	@AvailableQty	Real
DECLARE	@HasChild		Bit	
DECLARE	@IsFirstLayer	Bit
DECLARE @TmpProduct varchar(20)
DECLARE @UnitPart	TINYINT

----------- Fill in InputProducts table ------------
INSERT	INTO #tblInputProducts 
SELECT	ProductID, SubUnitQuantity, FormulaNo, WageRate, AcntCode
FROM	prd.tblProductGroupsDtl
WHERE	SerialNo = @SerialNo AND --( @AcntCode IS NULL OR AcntCode = @AcntCode) AND
		SerialNo NOT IN (SELECT BaseSerialNo 
						 FROM inv.tblStorageDocsDtl 
				 		 WHERE ProcessID= 70 AND BaseSerialNo <> 0 )

--------------------------- Start Procedure Code ---------------------------------------------
BEGIN

	SET NOCOUNT ON; 

	-- Fill Goods Stock table ---
--	TRUNCATE TABLE #tblGoodsStock
--
--	INSERT	INTO #tblGoodsStock
--	SELECT	GoodsID, inv.funGetGoodsQuantity(GoodsID, Null, Null) AS GoodsQty
--    FROM	inv.tblGoods

	--================================== UnitPart
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
	--==================================
	
	--* DECLARE Cursors ------------------------------------
	-- کرسر برای حرکت در جدول محصولهای درخواستی
	DECLARE CRS_Products CURSOR FOR							
		SELECT ProduceProduct, ProduceQuantity, FormulaNo, WageRate, AcntCode			
        FROM   #tblInputProducts							

	-- کرسر برای حرکت در جدول کالاهای مورد نیاز
	DECLARE CRS_Goods CURSOR FOR							
       SELECT ProductID, GoodsID, GoodsQty
       FROM   #tblProductGoods								
	--------------------------------------------------------

	OPEN  CRS_Products;
	FETCH NEXT FROM CRS_Products INTO @ProductID, @ProductQty,@FormulaNo,@WageRate,@AcntCode

    WHILE @@FETCH_STATUS = 0 -- CRS_Products
    BEGIN
		
		SELECT TOP 1 @TmpProduct = ProductID FROM prd.tblFormulasHdr FH
		WHERE	FH.ProductID = SUBSTRING(@ProductID,1,LEN(FH.ProductID)) AND FH.SerialNo = @FormulaNo
		order by LEN(ProductID) DESC

		-- Append Goods Leafs FROM Current Product -----
		INSERT	INTO #tblProductGoods(ProductID, GoodsID, GoodsQty,SubUnitQty,UnitID,FormulaNo,WageRate,AcntCode)
		SELECT	@ProductID, FD.GoodsID, (@ProductQty * FD.GoodsQuantity / FH.ProductCount), (@ProductQty * FD.GoodsQuantity / FH.ProductCount) * FD.SubUnitQuantity/GoodsQuantity,FD.UnitID , @FormulaNo,@WageRate,@AcntCode
		FROM	prd.tblFormulasDtl FD INNER JOIN prd.tblFormulasHdr FH ON
				FD.ProductID = FH.ProductID AND FD.SerialNo = FH.SerialNo
		WHERE	FH.ProductID = @TmpProduct AND FH.SerialNo = @FormulaNo

		-- Read Next Row Fom #tblInputProducts
		FETCH NEXT FROM CRS_Products INTO  @ProductID, @ProductQty,@FormulaNo,@WageRate,@AcntCode

    END -- CRS_Products

	Close		CRS_Products
	DeAllocate  CRS_Products
	
--  ========================================================================================
--  ========================================================================================

-- شود Join اگر ستون موجودی کالاها نیز درخواست شده باشد باید نتیجه با جدول موقت مربوط به موجودی

	SELECT R.GoodsID, Sum(R.GoodsQty) As GoodsQuantity, Sum(R.SubUnitQty) As SubUnitQuantity,GD.GoodsName,
		   FormulaNo,WageRate,R.UnitID SubUnitID, U.UnitName SubUnitName,R.AcntCode,[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,@StoreID,R.GoodsID,'',@DocDate,0) AS GoodsRemain
    FROM  #tblProductGoods AS R
  	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(R.GoodsID, @str_Goods + 1, @str_GoodsSum) AND GD.PartNumber=@UnitPart
	INNER JOIN inv.tblUnitsDtl AS U On U.UnitID = R.UnitID
            
    WHERE  GD.LanguageID = @LanguageID  AND U.LanguageID = @LanguageID 
	Group By R.GoodsID, GD.GoodsName,FormulaNo,WageRate, R.UnitID, U.UnitName, R.AcntCode

END
GO
