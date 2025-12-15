USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid
-- Create date   : 1395/04/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Hamid
-- Description   : قرارداد حق الحفاظ
-- =============================================
CREATE PROCEDURE [sal].[RptSale_KeepingContract]
	@ProcessID		Int = 190, -- Sale Order Process ID
	@ProcessNo		Int = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @Db0000		VarChar(50);

select @Db0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

Begin --============== S T A R T  C O D E ===================================================

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
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	IF (@ProcessNo	  Is Null)	SET @ProcessNo   = 1;

	IF (@FiscalYearFr  Is Null)	SET @SerialNoFr	  = Null;
	IF (@FiscalYearTo  Is Null)	SET @SerialNoTo	  = Null;
	IF (@SerialNoFr	   Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	   Is Null)	SET @FiscalYearTo = Null;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	---------------------------------------------------------------------------
	--SET @StrWhere = '(D.AutoOrder = 0) and D.ProcessID = ' + Str(@ProcessID) + ' AND D.ProcessNo = ' + Str(@ProcessNo)
	SET @StrWhere = 'SH.ProcessID = ' + Str(@ProcessID) + ' AND SH.ProcessNo = ' + Str(@ProcessNo)

	If (@FiscalYearFr	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SH.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(SH.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND SH.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (SH.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(SH.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND SH.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	--============================
	SET @StrSelect = '
	SELECT SH.ProcessID, SH.ProcessNo, SH.FiscalYear, SH.SerialNo, SH.DocDate, SH.AcntCode, F.NationalIDNumber,
		   F.CompanyRegisterNo, F.EconomicalCode, F.NationalIdentity, F.Address1, F.Address2, F.Tel, F.Fax, F.Mobile,
		   F.DistributionPoint As AccountNumber, pub.GetCodeName(SH.AcntCode, 1) AS AcntName, SH.Duration, SH.ChequeCount,
		   SH.ChequeAmount, SH.DueDate1, SH.DueDate2, SH.DueDate3, SH.DueDate4, SH.DueDate5, SH.TaxPercent, SH.TaxBankName, 
		   SH.TaxChequeAmount, SH.TaxChequeNo, SH.TaxDueDate, SH.OrderDate, SH.DeliveryDate, SD.GoodsID, GD.GoodsName, 
		   SD.SubUnitQuantity, SD.SubUnitID, SD.GoodsPrice, UD.UnitName, SD.SubUnitQuantity * SD.GoodsPrice As TotalPrice,
		   G.IsService,Var1	,Var2,Var3,Var4
	FROM sal.tblSaleOrderHdr SH
	INNER JOIN sal.tblSaleOrderDtl SD ON SH.ProcessID = SD.ProcessID And SH.ProcessNo = SD.ProcessNo And
										 SH.FiscalYear = SD.FiscalYear And SH.SerialNo = SD.SerialNo
	INNER JOIN inv.tblGoods G ON G.GoodsID = SD.GoodsID									 
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SD.GoodsID
	INNER JOIN inv.tblUnitsDtl UD ON UD.UnitID = SD.SubUnitID
	OUTER APPLY acc.funGetCodeInfo(SH.AcntCode) AS F 
	WHERE ' + @StrWhere + '
	ORDER BY SH.FiscalYear, SH.SerialNo'

	--============================
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
