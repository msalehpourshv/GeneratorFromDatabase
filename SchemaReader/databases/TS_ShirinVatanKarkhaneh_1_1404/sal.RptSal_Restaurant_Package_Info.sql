USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1391/11/28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : چاپ قرارداد  
-- =============================================
CREATE PROCEDURE [sal].[RptSal_Restaurant_Package_Info] 
		
	@FromSerialNo		INT =5,
	@EarnestMoney		FLOAT =0,
	@SalonName1			NVarChar(100) = NULL,
    @SalonName2			NVarChar(100) = NULL,
    @SalonName3			NVarChar(100) = NULL,
    @SalonName4			NVarChar(100) = NULL,
	@RepInfo			NVarChar(100) = '1@1@1' ,
	@pmFixOptions		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
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
		
	--============== 
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

-- ================ WHERE ===========================
	SET @StrWhere = '(1=1) '
	
	IF (@FromSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.ProcessID=181 AND h.SerialNo =' + LTRIM(STR(@FromSerialNo))
	
-- ================ SELECT ===========================

	SET @StrSelect ='
	SELECT h.*,d1.*,[pub].[funGetGoodsName](d1.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (d1.GoodsID), '''') BarCode,b.BranchName,pd.ReasonName,
		   pub.GetCodeName(h.ReciverAcntCode,' + LTRIM(STR(@LangID))+') AS ReciverName
			
	FROM sal.tblRestaurantContractHdr h
	INNER JOIN  sal.tblRestaurantContractDtl1 d1 ON h.ProcessID=d1.ProcessID and h.SerialNo = d1.SerialNo AND 
													h.BranchID = d1.BranchID
	INNER JOIN inv.tblGoodsDtl gd ON gd.GoodsID = SUBSTRING(d1.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND gd.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	INNER JOIN sal.tblBranchesDtl b	ON h.BranchID=b.BranchID
	INNER JOIN sal.tblPartyReasonDtl pd	ON h.ReasonID=pd.ReasonID
    WHERE '  + @StrWhere
				 
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
