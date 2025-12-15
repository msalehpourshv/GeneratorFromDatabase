USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		 : jafari	
-- Create date	 : 1403/04/17
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
Create PROCEDURE pln.RptPln_TaskOrder
	@FiscalYear		Int = 0,
	@SerialNo		Int = 0,
	@FiscalYearTo	Int = 0,
	@SerialNoTo		Int = 0,
	@ExtraParams	NVarChar(Max) = '',
	@RepOptions		VarChar(20) = '111' ,
	@RepInfo		NVarChar(100) = '1@1@1@1@1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect			Nvarchar(max);
DECLARE @StrWhere			Nvarchar(max);
DECLARE	@LangID				NvarChar(1);
DECLARE	@ReportID			Int;
DECLARE	@SessionNo			Int;

--DECLARE @FiscalYear		Int = 0
--DECLARE @SerialNo		Int = 0
--DECLARE @FiscalYearTo	Int = 0
--DECLARE @SerialNoTo		Int = 0
DECLARE @ProdFiscalYear		Int = 0
DECLARE @ProdSerialNo		Int = 0
DECLARE @ProdFiscalYearTo	Int = 0
DECLARE @ProdSerialNoTo		Int = 0

BEGIN
	SET NOCOUNT ON;
	-- ---------------------------------------------------------------------------------
	IF @RepInfo IS NULL SET @RepInfo = '1@1@1'


	SET @FiscalYear			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @SerialNo			= pub.funSplitString(@ExtraParams, '@', 2);
	SET @FiscalYearTo		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @SerialNoTo			= pub.funSplitString(@ExtraParams, '@', 4);
	SET @ProdFiscalYear		= pub.funSplitString(@ExtraParams, '@', 5);
	SET @ProdSerialNo		= pub.funSplitString(@ExtraParams, '@', 6);
	SET @ProdFiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 7);
	SET @ProdSerialNoTo		= pub.funSplitString(@ExtraParams, '@', 8);
 
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
 
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

 --select  @FiscalYear,@SerialNo,@FiscalYearTo,@SerialNoTo,@ProdFiscalYear,@ProdSerialNo,@ProdFiscalYearTo,@ProdSerialNoTo


 	SET @StrWhere	= '(1 = 1)';
	if @SerialNo>0
		SET @StrWhere = @StrWhere + ' and  b.FiscalYear>='+str(@FiscalYear)+' and b.SerialNo>='+str(@SerialNo)+'  '
	if @SerialNoTo>0
		SET @StrWhere = @StrWhere + ' and b.FiscalYear<='+str(@FiscalYearTo)+' and b.SerialNo<='+str(@SerialNoTo )+' '

	if @ProdSerialNo>0
		SET @StrWhere = @StrWhere + ' and  a.BaseFiscalYear>='+str(@ProdFiscalYear)+' and a.BaseSerialNo>='+str(@ProdSerialNo)+'  '
	if @ProdSerialNoTo>0
		SET @StrWhere = @StrWhere + ' and a.BaseFiscalYear<='+str(@ProdFiscalYearTo)+' and a.BaseSerialNo<='+str(@ProdSerialNoTo )+' '


	set @StrSelect ='
	SELECT a.ProductID,
		pub.funGetGoodsName(a.ProductID,1) ProductName,
		a.OrderCount,
		a.BatchNo,
		a.TaskStateID,
		a.FormulaNo,
		a.BaseProcessID,
		a.BaseProcessNo,
		a.BaseFiscalYear,
		a.BaseSerialNo,
		a.BaseDocRowNo,
		a.Suspend,
		a.ProdDocRowNo,
		a.UserPriceID,
		b.*,
		ISNULL(ProduceStepName  ,'''') ProduceStepName,
		ISNULL([pub].[GetStoreName](b.AcceptStoreID,1) ,'''') AcceptStoreIDName,
		ISNULL([pub].[GetStoreName](b.FailedStoreID,1) ,'''') FailedStoreIDName,
		ISNULL([pub].[GetStoreName](b.UsageStoreID,1) ,'''') UsageStoreIDName,
		ISNULL([pub].[GetStoreName](b.LossStoreID,1) ,'''') LossStoreIDName,
		ISNULL(pln.funGetProductionLineName(b.ProductionLineID ,1) ,'''')  ProductionLineName,
		ISNULL(emp.funGetShiftTypeName(b.ShiftTypeID ,1) ,'''')  ShiftTypeIDName,
		ISNULL(prs.funGetPersonnelName(b.PersonelID ,1) ,'''')  PersonelIDName,
		ISNULL(inv.funGetUnitName(b.SubUnitID,1) ,'''')  SubUnitName,
		BC.BarCodeImage,
		BC3.BarCodeImage ImageBarCode,
		QRCodeImage
	FROM pln.tblTaskOrderHdr a 
	INNER JOIN pln.tblTaskOrderDtl b ON a.ProcessID=b.ProcessID And a.ProcessNo=b.ProcessNo And a.FiscalYear=b.FiscalYear And a.SerialNo=b.SerialNo 
	LEFT JOIN inv.tblGoods G ON a.ProductID = SUBSTRING(G.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND G.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
 	LEFT JOIN pln.tblProduceStepDtl PS ON a.ProduceStepSerialNo =PS.SerialNo and a.ProductID=PS.ProductID and b.ProduceStepID=PS.ProduceStepID
	LEFT JOIN rpt.tblBarCodeImage BC ON BC.BarCode = G.GoodsID and BC.SessionNo='+ str(@SessionNo)+' and BC.ReportID='+ str(@ReportID)+' and BC.Type=1
	LEFT JOIN rpt.tblBarCodeImage BC3 ON BC3.BarCode = G.BarCode and BC3.SessionNo='+ str(@SessionNo)+' and BC3.ReportID='+ str(@ReportID)+'  and BC3.Type=3
	LEFT JOIN rpt.tblQRCodeImage QR ON QR.QRCode = G.GoodsID and QR.SessionNo='+ str(@SessionNo)+' and QR.ReportID='+ str(@ReportID)+'  
	WHERE ' +@StrWhere

		-- ---------------------------------------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;

END
GO
