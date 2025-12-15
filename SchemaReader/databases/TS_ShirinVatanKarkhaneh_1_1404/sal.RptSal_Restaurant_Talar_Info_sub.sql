USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1393/07/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : چاپ قرارداد  
-- =============================================
CREATE PROCEDURE [sal].[RptSal_Restaurant_Talar_Info_sub]
		
	@FromSerialNo INT = 3
	
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE	@LangID			Char(1);

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	SET @LangID = 1;
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
	
-- ================ WHERE ===========================

	set @StrWhere = '(1=1) '
	
	IF (@FromSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.ProcessID=182 AND h.SerialNo =' + LTRIM(STR(@FromSerialNo))
	
	
-- ================ SELECT ===========================

	SET @StrSelect ='
	SELECT h.*,d1.*,[pub].[funGetGoodsName](d1.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (d1.GoodsID), '''') BarCode
	FROM sal.tblRestaurantContractHdr h
	INNER JOIN  sal.tblRestaurantContractDtl1 d1 ON h.ProcessID=d1.ProcessID and h.SerialNo = d1.SerialNo AND 
													h.BranchID = d1.BranchID
    WHERE '  + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
