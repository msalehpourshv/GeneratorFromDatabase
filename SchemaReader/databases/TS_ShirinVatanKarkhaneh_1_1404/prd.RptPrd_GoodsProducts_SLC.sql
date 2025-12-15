USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/04/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_GoodsProducts_SLC]
	@RepInfo		NVarChar(100) = '1@1@1' 
WITH ENCRYPTION
AS

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
DECLARE	@UserID		Int; 

DECLARE @UnitPart	TINYINT

Begin
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
	
	-- init ------------------------------------------------------------
	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);

	Select  S.ProductID, S.UserID, S.Quantity, G.GoodsName, [pub].[funGetGoodsUnitName] (S.ProductID,1) UnitName
	From    prd.tblProductSlc S
	INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(S.ProductID, @str_Goods + 1, @str_GoodsSum) AND G.PartNumber=@UnitPart
				
	Where	(S.UserID = @UserID)
		AND (G.LanguageID = @LangID)
		AND (S.ReportID = @ReportID)
End
GO
