USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1393/10/13
-- Viewed By	 : 
-- Last Modified :  
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSal_CustomerGoodsQuotas]
	@GoodsID			Varchar(20) = Null,
	@CustomerKindID		VarChar(20) = Null, 
	@RepOptions			VarChar(20) = '00',
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
 

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	--========================
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
	
	-- Init Variables -------------------------------------
 	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions Is Null)	SET @RepOptions = '110001';
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'

	IF (@CustomerKindID Is Not Null And @CustomerKindID <> '')
		SET @StrWhere = @StrWhere + ' AND (C.CustomerKindID = ''' + @CustomerKindID + ''')'
		
	IF (@GoodsID Is Not Null And @GoodsID <> '')
		SET @StrWhere = @StrWhere + ' AND C.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''''
		
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select C.GoodsID, [pub].[funGetGoodsName](C.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (C.GoodsID), '''') BarCode, 
		   C.CustomerKindID, CK.CustomerKindName, C.CountGoods 
	From sal.tblCustomGoodsDtl C
	Inner Join inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(C.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	Inner Join sal.tblCustomerKindsDtl CK ON C.CustomerKindID = CK.CustomerKindID
	Where '+ @StrWhere
			 
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
