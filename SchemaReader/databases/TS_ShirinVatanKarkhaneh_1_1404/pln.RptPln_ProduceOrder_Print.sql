USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/04/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش لیست برگه های سفارش تولید
-- ==============================================
Create PROCEDURE [pln].[RptPln_ProduceOrder_Print]
	@ProcessID		Int = 600,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@ExtraParams	NVarChar(200) = Null,
	@RepInfo		NVarChar(100) = Null

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrFrom		NVarChar(1000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrDocDesc		NVarChar(600);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

declare @IsConfirmed	bit;
declare @IsNotConfirmed	bit;
declare @IsFinished		bit;
declare @ShowDtl		int;
Declare @FmlParam1		NVarChar(100)

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepInfo Is Null)			SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowDtl	= pub.funSplitString(@ExtraParams, '@', 1);
	
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'
	SELECT @FmlParam1= SettingValue	FROM pub.tblSettings WHERE SettingKey = 'FmlParam1'
	set @FmlParam1=isnull(@FmlParam1,'لیتر')
	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	---------------------------------------------------------
	-- Where Clause -----------------------------------------
	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))

	IF (@FiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '
	  
	--------------------------------------------------------- 
	-- SELECT Clause ----------------------------------------
	if @ShowDtl=1
		SET @StrSelect = '
		SELECT	H.*, 
			D.DocRowNo, 
			D.ProductID, 
			D.ProductCount, 
			[pub].[funGetGoodsName](D.ProductID,' + @LangID + ') ProductName,
			U.UnitName, 
			S.ProduceStepName,
			D.ProductWidth,
			D.ProductHeight,
			D.ProductQuantity2, 
			pub.GetUserName(H.SessionNo) AS UserName,
			D.DescDtl,
			GH.ExtraField1,
			GH.ExtraField2,
			GH.ExtraField3,
			GH.ExtraField4,
			GH.ExtraField5,
			GH.ExtraField6,
			GH.ExtraField7,
			GH.ExtraField8,
			GH.ExtraField9,
			GH.ExtraField10,
			isnull(O.DescDtl,'''') DescDtlOrder,
			PS.ProductionLineID,
			pln.funGetProductionLineName(PS.ProductionLineID,1)ProductionLineName,
			ShiftTypeID,
			emp.funGetShiftTypeName(ShiftTypeID,1) ShiftTypeName,
			FmlParam1,
			ProduceMethodName,
			(Select sum (OperatorCount) FROM pln.tblProduceStepDtl SD WHERE  SD.ProductID=PS.ProductID AND SD.SerialNo=PS.SerialNo ) OperatorCount,
			O.AcntCode, 
			pub.GetCodeName(O.AcntCode,1) AcntName,
			BC.BarCodeImage,
			BC2.BarCodeImage BatchImage,
			BC3.BarCodeImage ImageBarCode,
			QRCodeImage,
			ISNull(D.BatchNo, '''') BatchNoHdr,
			[inv].[funGetBatchName](D.BatchNo,' + @LangID + ') BatchName
		FROM	pln.tblProduceOrderDtl D
				inner JOIN pln.tblProduceOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT JOIN inv.tblGoods GH ON GH.GoodsID =  SUBSTRING(D.ProductID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = GH.UnitID AND U.LanguageID = ' + @LangID + '
				LEFT JOIN pln.tblProduceOrderStepsDtl S ON S.ProduceStepID = H.ProduceStepID AND S.LanguageID = ' + @LangID + '
				LEFT JOIN sal.tblSaleOrderDtl O on O.ProcessID = D.BaseProcessID AND O.ProcessNo = D.BaseProcessNo AND O.FiscalYear = D.BaseFiscalYear AND O.SerialNo = D.BaseSerialNo AND O.DocRowNo = D.BaseDocRowNo	
				LEFT JOIN rpt.tblBarCodeImage BC  ON BC.BarCode  = GH.GoodsID AND BC.SessionNo='+ str(@SessionNo)+'  AND BC.ReportID='+ str(@ReportID)+'   AND BC.Type=1
				LEFT JOIN rpt.tblBarCodeImage BC2 ON BC2.BarCode = O.BatchNo  AND BC2.SessionNo='+ str(@SessionNo)+' AND BC2.ReportID='+ str(@ReportID)+'  AND BC2.Type=2
				LEFT JOIN rpt.tblBarCodeImage BC3 ON BC3.BarCode = GH.BarCode AND BC3.SessionNo='+ str(@SessionNo)+' AND BC3.ReportID='+ str(@ReportID)+'  AND BC3.Type=3
				LEFT JOIN rpt.tblQRCodeImage  QR  ON QR.QRCode   = GH.GoodsID AND QR.SessionNo='+ str(@SessionNo)+'  AND QR.ReportID='+ str(@ReportID)+' 
				LEFT JOIN pln.tblProduceStepHdr PS ON D.ProductID=PS.ProductID AND D.StepNo=PS.SerialNo  				
		WHERE ' + @StrWhere
	if @ShowDtl=2
		SET @StrSelect = '
		SELECT	H.*,
			D.DocRowNo,
			D.ProductID,
			D.ProductCount,
			[pub].[funGetGoodsName](D.ProductID,' + @LangID + ') ProductName,
			U.UnitName,
			S.ProduceStepName,
			D.ProductWidth,
			D.ProductHeight,
			D.ProductQuantity2, 
			pub.GetUserName(H.SessionNo) AS UserName,
			D.DescDtl,
			GH.ExtraField1,
			GH.ExtraField2,
			GH.ExtraField3,
			GH.ExtraField4,
			GH.ExtraField5,
			GH.ExtraField6,
			GH.ExtraField7,
			GH.ExtraField8,
			GH.ExtraField9,
			GH.ExtraField10,
			isnull(O.DescDtl,'''') DescDtlOrder,
			ShiftTypeID,
			emp.funGetShiftTypeName(ShiftTypeID,1) ShiftTypeName,
			FD.GoodsID,
			[pub].[funGetGoodsName](FD.GoodsID,' + @LangID + ') GoodsName,
			cast(((case when FD.ParamKind=1 then    D.FmlParam1 / FH.FmlParam1 else D.ProductCount / FH.ProductCount end ) * FD.GoodsQuantity)as Float ) GoodsQty,
			U2.UnitName UnitName2,
			D.BatchNo BatchNoHdr,
			B.BatchName,
			D.FmlParam1, 
			'''+@FmlParam1+''' FmlParam1Name,
			ProduceMethodName,
			D.FormulaNo,
			FormulaName,
			O.AcntCode,
			pub.GetCodeName(O.AcntCode,1) AcntName,
			BC.BarCodeImage,
			BC2.BarCodeImage BatchImage,
			BC3.BarCodeImage ImageBarCode,
			QRCodeImage
		FROM	pln.tblProduceOrderDtl D
				INNER JOIN pln.tblProduceOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT JOIN prd.tblFormulasHdr FH  ON FH.ProductID=D.ProductID AND FH.SerialNo=D.FormulaNo	
				LEFT JOIN prd.tblFormulasDtl FD  ON FD.ProductID=D.ProductID AND FD.SerialNo=D.FormulaNo	
				LEFT JOIN inv.tblGoods GH ON GH.GoodsID =  SUBSTRING(FD.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				LEFT JOIN inv.tblGoods GH2 ON GH2.GoodsID =  SUBSTRING(D.ProductID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH2.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = GH2.UnitID AND U.LanguageID = ' + @LangID + '
				LEFT JOIN inv.tblUnitsDtl U2 ON U2.UnitID = FD.UnitID AND U2.LanguageID = ' + @LangID + '
				LEFT JOIN pln.tblProduceOrderStepsDtl S ON S.ProduceStepID = H.ProduceStepID AND S.LanguageID = ' + @LangID + '
				LEFT JOIN sal.tblSaleOrderDtl O ON O.ProcessID = D.BaseProcessID AND O.ProcessNo = D.BaseProcessNo AND O.FiscalYear = D.BaseFiscalYear AND O.SerialNo = D.BaseSerialNo AND O.DocRowNo = D.BaseDocRowNo	
				LEFT JOIN rpt.tblBarCodeImage BC  ON BC.BarCode  = GH.GoodsID AND BC.SessionNo='+ str(@SessionNo)+'  AND BC.ReportID='+ str(@ReportID)+'   AND BC.Type=1
				LEFT JOIN rpt.tblBarCodeImage BC2 ON BC2.BarCode = O.BatchNo  AND BC2.SessionNo='+ str(@SessionNo)+' AND BC2.ReportID='+ str(@ReportID)+'  AND BC2.Type=2
				LEFT JOIN rpt.tblBarCodeImage BC3 ON BC3.BarCode = GH.BarCode AND BC3.SessionNo='+ str(@SessionNo)+' AND BC3.ReportID='+ str(@ReportID)+'  AND BC3.Type=3
				LEFT JOIN rpt.tblQRCodeImage  QR  ON QR.QRCode   = GH.GoodsID AND QR.SessionNo='+ str(@SessionNo)+'  AND QR.ReportID='+ str(@ReportID)+' 
				LEFT JOIN inv.tblBatchDtl B ON B.BatchNo = D.BatchNo AND B.LanguageID = ' + @LangID + '
				LEFT JOIN pln.tblProduceStepHdr PS ON D.ProductID=PS.ProductID AND D.StepNo=PS.SerialNo  				
		WHERE ' + @StrWhere+ '
		ORDER BY D.DocRowNo,FD.DocRowNo
		'
	if @ShowDtl=3
	SET @StrSelect = '
		SELECT	H.*, 
			D.DocRowNo, 
			D.ProductID, 
			D.ProductCount, 
			[pub].[funGetGoodsName](D.ProductID,' + @LangID + ') ProductName,
			U.UnitName,
			S.ProduceStepName,
			D.ProductWidth,
			D.ProductHeight,
			D.ProductQuantity2, 
			pub.GetUserName(H.SessionNo) AS UserName,
			D.DescDtl,
			GH.ExtraField1,
			GH.ExtraField2,
			GH.ExtraField3,
			GH.ExtraField4,
			GH.ExtraField5,
			GH.ExtraField6,
			GH.ExtraField7,
			GH.ExtraField8,
			GH.ExtraField9,
			GH.ExtraField10,
			isnull(O.DescDtl,'''') DescDtlOrder,
			PS.ProductionLineID,
			pln.funGetProductionLineName(PS.ProductionLineID,1)ProductionLineName,
			ShiftTypeID,
			emp.funGetShiftTypeName(ShiftTypeID,1) ShiftTypeName,
			SD.ProduceStepID ProduceStepIDStep,
			SD.ProduceStepName	ProduceStepNameStep,
			ProduceStepTime,
			OperatorCount,
			ProduceMethodName,
			stuff((SELECT '''', '''', '' ('' + case when g2.ExtraField1 <> '''' then g2.ExtraField1 else GoodsName end + ''='' + ltrim(rtrim(cast(pub.funGetMyRound(cast(((case when F.ParamKind = 1 then DD.FmlParam1 / H.FmlParam1 else DD.ProductCount / H.ProductCount end ) * GoodsQuantity) as Decimal(18,6))) as varchar(5000)))) + '')''
				FROM prd.tblFormulasDtl F
				INNER JOIN prd.tblFormulasHdr H ON F.SerialNo = H.SerialNo AND F.ProductID = H.ProductID			 
				INNER JOIN inv.tblGoodsDtl g ON F.GoodsID=g.GoodsID	
				INNER JOIN inv.tblGoods g2 ON F.GoodsID=g2.GoodsID	
				INNER JOIN pln.tblProduceOrderDtl DD ON F.ProductID=DD.ProductID AND F.SerialNo=DD.FormulaNo	
				WHERE F.ProductID=D.ProductID AND F.SerialNo=D.FormulaNo AND F.ProduceStepID=SD.ProduceStepID
					AND D.SerialNo=DD.SerialNo AND D.DocRowNo=DD.DocRowNo
			for xml path('''')		),1,1,'''')  GoodsID,
			D.BatchNo BatchNoHdr,
			B.BatchName,
			D.FmlParam1,
			'''+@FmlParam1+''' FmlParam1Name,
			D.FormulaNo,
			FormulaName,
			O.AcntCode,
			pub.GetCodeName(O.AcntCode,1) AcntName,
			BC.BarCodeImage,
			BC2.BarCodeImage BatchImage,
			BC3.BarCodeImage ImageBarCode,
			QRCodeImage
		FROM	pln.tblProduceOrderDtl D
				INNER JOIN pln.tblProduceOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				LEFT join inv.tblGoods GH ON GH.GoodsID =  SUBSTRING(D.ProductID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR( @str_GoodsSum))) + ') AND GH.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
				LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = GH.UnitID AND U.LanguageID = ' + @LangID + '
				LEFT JOIN pln.tblProduceOrderStepsDtl S ON S.ProduceStepID = H.ProduceStepID AND S.LanguageID = ' + @LangID + '
				LEFT JOIN sal.tblSaleOrderDtl O ON O.ProcessID = D.BaseProcessID AND O.ProcessNo = D.BaseProcessNo AND O.FiscalYear = D.BaseFiscalYear AND O.SerialNo = D.BaseSerialNo AND O.DocRowNo = D.BaseDocRowNo	
				LEFT JOIN rpt.tblBarCodeImage BC  ON BC.BarCode  = GH.GoodsID AND BC.SessionNo='+ str(@SessionNo)+'  AND BC.ReportID='+ str(@ReportID)+'   AND BC.Type=1
				LEFT JOIN rpt.tblBarCodeImage BC2 ON BC2.BarCode = O.BatchNo  AND BC2.SessionNo='+ str(@SessionNo)+' AND BC2.ReportID='+ str(@ReportID)+'  AND BC2.Type=2
				LEFT JOIN rpt.tblBarCodeImage BC3 ON BC3.BarCode = GH.BarCode AND BC3.SessionNo='+ str(@SessionNo)+' AND BC3.ReportID='+ str(@ReportID)+'  AND BC3.Type=3
				LEFT JOIN rpt.tblQRCodeImage  QR  ON QR.QRCode   = GH.GoodsID AND QR.SessionNo='+ str(@SessionNo)+'  AND QR.ReportID='+ str(@ReportID)+' 
				LEFT JOIN pln.tblProduceStepHdr PS ON D.ProductID=PS.ProductID AND D.StepNo=PS.SerialNo  
				LEFT JOIN pln.tblProduceStepDtl SD ON SD.ProductID=PS.ProductID AND SD.SerialNo=PS.SerialNo  
				LEFT JOIN inv.tblBatchDtl B ON B.BatchNo = D.BatchNo AND B.LanguageID = ' + @LangID + '
				LEFT JOIN prd.tblFormulasHdr F  ON F.ProductID=D.ProductID AND F.SerialNo=D.FormulaNo	
		WHERE ' + @StrWhere
	

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
