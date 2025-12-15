USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid	
-- Create date   : 1394/09/22
-- Viewed By		 : Hadi Sadeghi
-- Last Modified : 
-- Last Modifier : 
-- Description   : برگ سفارش خرید کالا
-- =============================================
Create PROCEDURE [cmr].[RptBuyOrder_Doc2]
	@ProcessID			Int = 160, -- Buy Order Process ID
	@ProcessNo			Int = 1, 	
	@FiscalYear			Int = Null,
	@SerialNo			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@BaseProcessID		Int = 150,
	@BaseProcessNo		Int = Null,
	@BaseFiscalYear		Int = Null,
	@BaseSerialNo		Int = Null,
	@GoodsID			Varchar(20) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LanguageID TinyInt;
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @BaseDocRowNo	Int ;

Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();
	Set NoCount On;

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
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	If (@ProcessNo	  Is Null)	SET @ProcessNo  = 1;
	If (@LanguageID	  Is Null)	SET @LanguageID = 1
	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo	  Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@GoodsID	  Is Null)	SET @GoodsID	= '';

	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);	
	SET @BaseDocRowNo	= pub.funSplitString(@RepInfo, '@', 6);	
	
	set @BaseDocRowNo=isnull(@BaseDocRowNo,0)
	--============================= Where
	SET @StrWhere = 'D.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND D.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	
	If (@FiscalYear	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(RTrim(Str(@FiscalYear))) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND D.SerialNo >= ' + LTrim(RTrim(Str(@SerialNo))) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' OR 
		(D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo))) + ')) '

	IF @ProcessID = @BaseProcessID
	BEGIN
		If (@BaseProcessID	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.ProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
	
		If (@BaseProcessNo	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
	
		If (@BaseFiscalYear	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
	
		If (@BaseSerialNo	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.SerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	

		If @BaseDocRowNo>0
			SET @StrWhere = @StrWhere + ' AND (D.DocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'		
	END
	ELSE
	BEGIN
		If (@BaseProcessID	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
	
		If (@BaseProcessNo	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
	
		If (@BaseFiscalYear	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
	
		If (@BaseSerialNo	Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	

		If @BaseDocRowNo>0
			SET @StrWhere = @StrWhere + ' AND (D.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'		
	END
		
	If (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''')'
	
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, H.DocDesc, H.AgreeNo As HdrAgreeNo, 
		    [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName, 
		    IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '''') BarCode, U.UnitName, 
			pub.GetCodeName(D.AcntCode, ' + Str(@LanguageID) + ') AcntName,
			pub.GetUserName(H.SessionNo) AS UserName,
			inv.funSubUnit2(D.GoodsID) UnitScale,
			inv.funSubUnit2Name(D.GoodsID) UnitNameX,
			GH.TechnicalNo, GH.TechnicalSpecifications, GH.MiscSpecifications
	FROM    cmr.tblOrderDtl AS D 
				INNER JOIN cmr.tblOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT JOIN inv.tblGoods GH ON GH.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				LEFT  JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID AND U.LanguageID = ' + Str(@LanguageID) + '
	WHERE ' + @StrWhere
	
	--================================		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
