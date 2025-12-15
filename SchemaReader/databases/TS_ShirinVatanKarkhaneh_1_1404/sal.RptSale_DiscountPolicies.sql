USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/07/02
-- Viewed By	 : 
-- Last Modified : 1392/09/02
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_DiscountPolicies] 
	@ProcessID			VarChar(20) = 90,
	@FromSerialNo		Int = Null,
	@ToSerialNo			Int = Null,
	@FromDate			Char(10) = Null,
	@ToDate				Char(10) = Null,
	@SaleTypeID			VarChar(20) = Null,
	@CustomerKindID		VarChar(20) = Null,
	@GoodsGroupID		VarChar(20) = Null,
	@GoodsID			VarChar(20) = Null,
	@PackID				VarChar(20) = Null,
	@RepOptions			VarChar(10) = '111011111',  -- Bit Array Options
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

Begin -- ============== S T A R T  C O D E ====================================

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
	
	-- Init Variables -------------------------------------

	--IF (@FiscalYear Is Null)	SET @SerialNo = Null;
	--IF (@SerialNo	Is Null)	SET @FiscalYear = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'

	IF (@ProcessID Is Not Null And @ProcessID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.ProcessID = ''' + @ProcessID + ''')'
		
	IF (@FromSerialNo Is Not Null And @FromSerialNo <> 0)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo >= ' + LTrim(Str(@FromSerialNo))  

	IF (@ToSerialNo Is Not Null And @ToSerialNo <> 0)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo <= ' + LTrim(Str(@ToSerialNo))  
		
	--IF (@FiscalYear Is Not Null)
	--SET @StrWhere = @StrWhere + ' AND H.FiscalYear = ' + LTrim(Str(@FiscalYear))  

	IF (@FromDate Is Not Null And @FromDate <> '')
		Set @StrWhere = @StrWhere + ' AND (H.FromDate = ''' + @FromDate + ''')'
		
	IF (@ToDate Is Not Null And @ToDate <> '')
		Set @StrWhere = @StrWhere + ' AND (H.ToDate = ''' + @ToDate + ''')'

	IF (@SaleTypeID Is Not Null And @SaleTypeID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'
		
	IF (@CustomerKindID Is Not Null And @CustomerKindID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.CustomerKindID = ''' + @CustomerKindID + ''')'

	IF (@GoodsGroupID Is Not Null And @GoodsGroupID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.GoodsGroupID = ''' + @GoodsGroupID + ''')'				

	IF (@GoodsID Is Not Null And @GoodsID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @GoodsID + ''')'
		
	IF (@PackID Is Not Null And @PackID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.PackID = ''' + @PackID + ''')'		
						
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select D.ProcessID, D.SerialNo, D.SaleTypeID, IsNull(S.SaleTypeName,'''') As SaleTypeName, 
		   D.CustomerKindID, C.CustomerKindName, D.GoodsGroupID, IsNull(GG.GoodsGroupName,'''') As GoodsGroupName, 
		   D.GoodsID, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		   IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, D.DiscountPercent, D.Discount, D.FromAmount, 
		   D.ToAmount, D.AcntCode1, D.AcntCode2, D.AcntCode3, D.AcntCode4, D.PackID, IsNull(P.PackName,'''') As PackName, 
		   D.FromQty, D.ToQty, D.PackQty, D.UnitID, IsNull(U.UnitName,'''') As UnitName, D.ForQty
	From sal.tblDiscountPoliciesDtl D
	Inner Join sal.tblDiscountPoliciesHdr H ON H.ProcessID = D.ProcessID And H.SerialNo = D.SerialNo
	Left Join inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	Left Join inv.tblGoodsGroupsDtl GG ON GG.GoodsGroupID = D.GoodsGroupID
	Left Join sal.tblSaleTypesDtl S ON S.SaleTypeID = D.SaleTypeID
	Left Join sal.tblCustomerKindsDtl C ON C.CustomerKindID = D.CustomerKindID
	Left Join inv.tblUnitsDtl U ON U.UnitID = D.UnitID
	Left Join sal.tblPackDtl P ON P.PackID = D.PackID
	Where ' + @StrWhere + '
	Order By SerialNo'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
