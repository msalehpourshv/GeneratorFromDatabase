USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/01/19
-- Viewed By	 : 
-- Last Modified : 1386/08/29
-- Description: <Production Goods Tree>
-- ---------------------------------------------
--   مواد مورد نیاز و مقدار مورد نیاز برای 
--   تولید یک محصول بدون توجه به میزان موجودی
--   نمایش بصورت درختی 
-- Reports Using: rptProductionGoodsTree
-- =============================================
CREATE PROCEDURE [prd].[RptProductionGoodsTree_NotRecursive]
	@ProductID  VarChar(20),
    @ProductQty Real,
    @LanguageID TinyInt = 1
WITH ENCRYPTION
AS

	--SET @LanguageID = pub.funGetCurrentLanguageID();

CREATE Table #tblTemp
(
	ProductID	NVarChar(250),
	Qty_Request Float,
	GoodsID		NVarChar(250),
	Qty_Needed	Float
)

DECLARE @PID	NVarChar(50)
DECLARE @GID	NVarChar(50)
DECLARE @Qty_Request	Float
DECLARE @Qty_Needed		Float
DECLARE @UnitPart	TINYINT

BEGIN

	SET NOCOUNT ON;

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
	
	INSERT INTO #tblTemp (ProductID, Qty_Request, GoodsID, Qty_Needed)
	SELECT FH.ProductID, @ProductQty, FD.GoodsID, (@ProductQty / FH.ProductCount) * FD.GoodsQuantity
	FROM   prd.tblFormulasDtl FD INNER JOIN prd.tblFormulasHdr FH ON
           FD.SerialNo = FH.SerialNo AND FD.ProductID = FH.ProductID 
	WHERE  FH.ProductID = @ProductID

	DECLARE csr_Productions CURSOR FOR
		SELECT	ProductID, Qty_Request, GoodsID, Qty_Needed
		FROM	#tblTemp

	OPEN csr_Productions 

	FETCH NEXT FROM csr_Productions INTO @PID, @Qty_Request, @GID, @Qty_Needed

	WHILE (@@FETCH_STATUS = 0)
	BEGIN

		INSERT INTO #tblTemp (ProductID, Qty_Request, GoodsID, Qty_Needed)
		SELECT	FH.ProductID, @Qty_Needed, FD.GoodsID, (@Qty_Needed / FH.ProductCount) * FD.GoodsQuantity
		FROM	prd.tblFormulasDtl FD INNER JOIN prd.tblFormulasHdr FH ON
				FD.SerialNo = FH.SerialNo AND FD.ProductID = FH.ProductID
		WHERE	FH.ProductID = @GID

		FETCH NEXT FROM csr_Productions INTO @PID, @Qty_Request, @GID, @Qty_Needed
	END

	CLOSE csr_Productions 
	DEALLOCATE csr_Productions 

    SELECT	LST.*, GD.GoodsName, [pub].[funGetGoodsUnitName] (LST.GoodsID, @LanguageID) As UnitName
    FROM	(((#tblTemp LST
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(LST.GoodsID, @str_Goods + 1, @str_GoodsSum) AND GD.PartNumber=@UnitPart)))
    WHERE GD.LanguageID = @LanguageID
	ORDER BY GoodsID

END
GO
