USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1392/07/17
-- Viewed By	 : 
-- Last Modified : 1394/12/22
-- Last Modifier : TakroSystem\ZiA
-- Description	 : 
-- ==============================================
Create PROCEDURE [pln].[RptPln_ProductSerials]
	@SelectedProds	VarChar(20) 	= Null,
	@SerialPrefix	VarChar(20) 	= Null,
	@RegDateFr		Char(10) 		= Null,
	@RegDateTo		Char(10) 		= Null,
	@SerialNoFr		Varchar(20) 	= Null,
	@SerialNoTo		Varchar(20) 	= Null,
	@RegEmpID		VarChar(20) 	= Null,
	@ExtraParams	NVarChar(200)	= Null,
	@RepOptions		VarChar(20)		= '', -- bit array options
	@RepInfo		NVarChar(100)	= Null
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect			NVarChar(max);
DECLARE @StrFrom			NVarChar(2000);
DECLARE @StrWhere			NVarChar(2000);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int; 

DECLARE	@PrintedSerials	char(1); 
DECLARE	@SkipPrintedSerials	bit; 
DECLARE	@ProductID			VarChar(20); 
DECLARE	@SerialNo			VarChar(15); 
DECLARE	@CountInPrint		Int; 

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	IF (@RepOptions Is Null)	SET @RepOptions = '0';
	IF (@RepInfo Is Null)		SET @RepInfo	= '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @SkipPrintedSerials = SUBSTRING(@RepOptions, 1, 1);
	SET @PrintedSerials = SUBSTRING(@RepOptions,2, 1);

	SET @ProductID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 	
	SET @SerialNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 	
	SET @CountInPrint	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 	
	---------------------------------------------------------
	
	-- Where Clause -----------------------------------------
	Set @StrWhere = '(D.ProductSerialID <> 0)'
	
	if (@SkipPrintedSerials = 1)
	BEGIN
		IF @PrintedSerials='1'
			set @StrWhere = @StrWhere + ' and (D.IsPrinted = 0)'
		ELSE IF @PrintedSerials='2'
			set @StrWhere = @StrWhere + ' and (D.IsPrinted2 = 0)'
		ELSE IF @PrintedSerials='3'
			set @StrWhere = @StrWhere + ' and (D.IsPrinted3 = 0)'
	END

	IF (@RegDateFr Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @RegDateFr + ''')'
	IF (@RegDateTo Is Not Null) 
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @RegDateTo + ''')'

	IF (@SerialNoFr Is Not Null) And (@SerialNoFr <> '') 
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ''' + @SerialNoFr + ''')'
	IF (@SerialNoTo Is Not Null) And (@SerialNoTo <> '') 
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ''' + @SerialNoTo + ''')'

	if (@SerialPrefix is not null)
		set @StrWhere = @StrWhere + ' AND (D.SerialPrefix = ''' + @SerialPrefix + ''')'
	if (@RegEmpID is not null)
		set @StrWhere = @StrWhere + ' AND (D.RegEmpID = ''' + @RegEmpID + ''')'

	IF (@ProductID <> '' OR @ProductID Is Not Null)
		set @StrWhere = @StrWhere + ' AND (D.ProductID = ''' + @ProductID + ''') '
	Else
	Begin
		IF (@SelectedProds > 0)
			SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.ProductID')	
	End
	IF (@SerialNo <> '' OR @SerialNo Is Not Null)
		if (@SerialNo <> '0')
			set @StrWhere = @StrWhere + ' AND (PSR.SerialNo = ''' + @SerialNo + ''') '

	---------------------------------------------------------

	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
	SELECT	D.*, S.SerialStatusID, ISNULL(SN.SerialStatusName,'''') SerialStatusName, P.FiscalYear, 
			[pub].[funGetGoodsName](D.ProductID,' + @LangID + ') As ProductName,
			[pub].[funGetGoodsName](D.GoodsID1,' + @LangID + ') As GoodsName1,
			[pub].[funGetGoodsName](D.GoodsID2,' + @LangID + ') As GoodsName2,
			[pub].[funGetGoodsName](D.GoodsID3,' + @LangID + ') As GoodsName3,
			[pub].[funGetGoodsName](D.GoodsID4,' + @LangID + ') As GoodsName4,
			[pub].[funGetGoodsName](D.GoodsID5,' + @LangID + ') As GoodsName5,
			[pub].[funGetGoodsName](D.GoodsID6,' + @LangID + ') As GoodsName6,
			g.TechnicalSpecifications,g.TechnicalNo,g.GoodsCID,
			ExtraField1,ExtraField2,ExtraField3,ExtraField4,ExtraField5,
			ExtraField6,ExtraField7,ExtraField8,ExtraField9,ExtraField10,
			ExtraField11,ExtraField12,ExtraField13,ExtraField14,ExtraField15,
			ExtraField16,ExtraField17,ExtraField18,ExtraField19,ExtraField20,
			g.MiscSpecifications,g.MapNo,g.MasterCode,
			ISNULL(ColorName,'''') ColorName,ISNULL(MotorTypeName,'''') MotorTypeName ,BarCodeImage
	FROM	pln.tblProductSerials D
	LEFT  JOIN inv.tblGoods g ON g.GoodsID = D.ProductID
	LEFT  JOIN pub.tblColors C ON D.ColorID = C.ColorID
	LEFT  JOIN pln.tblMotorTypesDtl M		ON D.MotorTypeID = M.MotorTypeID
	LEFT  JOIN pln.tblSerialPrefixes P		ON P.SerialPrefix = D.SerialPrefix
	LEFT  JOIN pln.tblProductSerialStatus S	ON S.ProductSerialID = D.ProductSerialID
	LEFT  JOIN rpt.tblBarCodeImage BC	ON BC.BarCode = D.SerialNo and BC.SessionNo='+ str(@SessionNo)+' and ReportID='+ str(@ReportID)+'
	LEFT JOIN pln.tblSerialStatus SN		ON SN.SerialStatusID = S.SerialStatusID
	Left  Join pln.tblProducesSerialsRegDtl PSR On D.ProductSerialID = PSR.ProductSerialID
	WHERE ' + @StrWhere + '
	ORDER BY ProductID, SerialPrefix, SerialNo '
	------------------------------------------------------------
	
	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
