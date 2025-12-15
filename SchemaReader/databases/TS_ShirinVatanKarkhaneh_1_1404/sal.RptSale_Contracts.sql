USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1388/10/02
-- Viewed By	 : 
-- Last Modified : 1388/10/07
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : لیست قراردادها
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_Contracts]
	@ProcessID			Int = Null,
	@ProcessNo			Int = Null,
	@FiscalFr			Int = Null,
	@SerialFr			Int = Null,
	@FiscalTo			Int = Null,
	@SerialTo			Int = Null,
	@DocStep			Int = Null,
	@GroupType			Int = Null,
	@AcntCode			VarChar(20) = Null,
	@SelectedAcnt1		Int	= 0,			
	@SelectedAcnt2		Int	= 0,			
	@SelectedAcnt3		Int	= 0,			
	@SelectedAcnt4		Int	= 0,			
	@SelectedGoods		Int	= 0,			
	@StartContractDateFr VarChar(10) = Null,
	@StartContractDateTo VarChar(10) = Null,
	@EndContractDateFr	VarChar(10) = Null,
	@EndContractDateTo	VarChar(10) = Null,
	@ContractNo			VarChar(10) = Null,
	@GoodsGroupIDFr		VarChar(20) = Null,
	@GoodsGroupIDTo		VarChar(20) = Null,
	@SaleTypeID			VarChar(20) = Null,
	@DiscountPercentFr	Float = Null,
	@DiscountPercentTo	Float = Null,
	@DiscountFr			Float = Null,
	@DiscountTo			Float = Null,
	@SortFields			NVarChar(200) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

BEGIN 
	--============== S T A R T  C O D E =======================================

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
	
	---- INIT -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo  = '1@1@1';
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	---- WHERE ----------------------------------------------------------------
	SET @StrWhere = '(1 = 1)'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')'
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')'

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsGroupID')

	IF (@StartContractDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.StartContractDate >= ''' + @StartContractDateFr + ''')'
	IF (@StartContractDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.StartContractDate <= ''' + @StartContractDateTo + ''')'

	IF (@EndContractDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.EndContractDate >= ''' + @EndContractDateFr + ''')'
	IF (@EndContractDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.EndContractDate <= ''' + @EndContractDateTo + ''')'

	IF (@GroupType Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.GroupType = ' + LTrim(Str(@GroupType)) + ')'
	IF (@ContractNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.ContractNo = ''' + @ContractNo + ''')'
	IF (@AcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.AcntCode = ''' + @AcntCode + ''')'

	--- dtl --
	IF (@GoodsGroupIDFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsGroupID >= ''' + @GoodsGroupIDFr + ''')'
	IF (@GoodsGroupIDTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsGroupID <= ''' + @GoodsGroupIDTo + ''')'

	IF (@SaleTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SaleTypeID = ''' + @SaleTypeID + ''')'

	IF (@DiscountPercentFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DiscountPercent >= ' + LTrim(Str(@DiscountPercentFr)) + ')'
	IF (@DiscountPercentFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DiscountPercent <= ' + LTrim(Str(@DiscountPercentTo)) + ')'

	IF (@DiscountFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Discount >= ' + LTrim(Str(@DiscountFr)) + ')'
	IF (@DiscountFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.Discount <= ' + LTrim(Str(@DiscountTo)) + ')'
	---------------------------------------------------------------------------
		
	---- SELECT ---------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, H.StartContractDate, H.EndContractDate, H.ContractNo, H.DocDesc,
			[pub].[funGetGoodsName](D.GoodsGroupID,' + LTrim(RTrim(@LangID)) + ') GoodsName,
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsGroupID), '''') BarCode, GGD.GoodsGroupName, STD.SaleTypeName,
			[pub].GetCodeName(H.AcntCode, ' + @LangID + ') AcntName,
			[sal].funContractTypeName(H.GroupType) AS ContractTypeName
	FROM	sal.tblGroupsDiscountDtl D
			INNER JOIN sal.tblGroupsDiscountHdr H ON H.SerialNo = D.SerialNo AND H.AcntCode = D.AcntCode
			LEFT  JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(D.GoodsGroupID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ ' AND GD.LanguageID = ' + @LangID + '
			LEFT  JOIN inv.tblGoodsGroupsDtl GGD ON GGD.GoodsGroupID = D.GoodsGroupID AND GGD.LanguageID = ' + @LangID + '
			LEFT  JOIN sal.tblSaleTypesDtl STD ON STD.SaleTypeID = D.SaleTypeID AND STD.LanguageID = ' + @LangID + '
	WHERE ' + @StrWhere 

	IF (@SortFields Is Not Null)
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
