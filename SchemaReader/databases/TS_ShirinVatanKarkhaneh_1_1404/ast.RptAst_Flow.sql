USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/10/31
-- Viewed By	 : 
-- Last Modified : 1393/04/31
-- Last Modifier : TakroSystem\Hamid
-- Description	 : گزارش گردش اموال
-- ==============================================
Create PROCEDURE [ast].[RptAst_Flow]

	@ProcessIDList		VarChar(200) = Null,
	@ProcessNo			TinyInt = Null,
	@FiscalFr			SmallInt = Null,
	@FiscalTo			SmallInt = Null,
	@SerialFr			Int = Null,
	@SerialTo			Int = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@DateFr				VarChar(10) = Null,
	@DateTo				VarChar(10) = Null,
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@LocateIDFr			VarChar(20) = Null, -- محل استقرار
	@LocateIDTo			VarChar(20) = Null, -- Not Used Now
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@GoodsIDFr			VarChar(20) = Null,
	@GoodsIDTo			VarChar(20) = Null,  
	@GoodsIDMask		VarChar(20) = Null,  
	@GoodsNameMask		NVarChar(50) = Null,  
	@SelectedGoods		Bit = 0,	-- کد بصورت انتخابی است؟
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null,
	@AssetStatus		TinyInt = Null, -- وضعیت ردیف
	@AssetLastStatus	TinyInt = Null, -- وضعیت جاری
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
	
WITH ENCRYPTION
AS 

DECLARE @LangID		VarChar(3);
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@FromDate	Int; -- برای حالت کدهای انتخابی
DECLARE	@ToDate		Int; -- برای حالت کدهای انتخابی
Declare @ExtraParams	nvarchar(100) ;
DECLARE	@ShowDesc		Int;

BEGIN 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	
	---- INIT -----------------------------------------------------------------
	SET @LangID = LTRim(Str(pub.funGetCurrentLanguageID()));

	IF (@SelectedGoods Is Null) SET @SelectedGoods = 0;
	Set @ExtraParams =@GoodsNameMask
	SET @GoodsNameMask = pub.funSplitString(@ExtraParams, '@', 1);
	SET @ShowDesc = pub.funSplitString(@ExtraParams, '@', 2);
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @FromDate	= pub.funSplitString(@RepInfo, '@', 4);
	SET @FromDate	= pub.funSplitString(@RepInfo, '@', 5);
	
	IF @FiscalFr Is Null SET @SerialFr = Null
	IF @FiscalTo Is Null SET @SerialTo = Null
	IF @SerialFr Is Null SET @FiscalFr = Null
	IF @SerialTo Is Null SET @FiscalTo = Null
	---------------------------------------------------------------------------

	---- WHERE ----------------------------------------------------------------
	SET @StrWhere = '(1 = 1)'

	IF (@ProcessIDList Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID IN (' + @ProcessIDList + '))'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ') AND (D.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')'
	
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ') AND (D.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')'

	IF (@VchNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@VchNoFr)) + ')'

	IF (@VchNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@VchNoTo)) + ')'

	IF (@DateFr Is Not Null) AND (@DateTo Is Not Null) AND (@DateFr = @DateTo)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate = ''' + @DateFr + ''')'
	Else
	BEGIN
		IF (@DateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DateFr + ''')'

		IF (@DateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'
	END

	If (@AssetPlaqueFr Is Not Null) AND (@AssetPlaqueTo Is Not Null) AND (@AssetPlaqueFr = @AssetPlaqueTo)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque = ''' + @AssetPlaqueFr + ''')'
	Else
	Begin
		If (@AssetPlaqueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque >= ''' + @AssetPlaqueFr + ''')'

		If (@AssetPlaqueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque <= ''' + @AssetPlaqueTo + ''')'
	End

	IF (@LocateIDFr Is Not Null) AND (@LocateIDTo Is Not Null) AND (@LocateIDFr = @LocateIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.LocateID LIKE ''' + @LocateIDFr + '%'')'
	Else
	BEGIN
		IF (@LocateIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID >= ''' + @LocateIDFr + ''')'
		IF (@LocateIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND D.LocateID <= ''' + @LocateIDTo + ''''
	END

	IF (@AstGroupIDFr Is Not Null) AND (@AstGroupIDTo Is Not Null) AND (@AstGroupIDFr = @AstGroupIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.AstGroupID = ''' + @AstGroupIDFr + ''')'
	Else
	BEGIN
		IF (@AstGroupIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID >= ''' + @AstGroupIDFr + ''')'
		IF (@AstGroupIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID <= ''' + @AstGroupIDTo + ''')'
	END

	-- (@GoodsIDFr & @GoodsIDTo
	--IF (@GoodsIDFr Is Not Null) AND (@GoodsIDTo Is Not Null) AND (@GoodsIDFr = @GoodsIDTo)
		--SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @GoodsIDFr + ''')'
	--Else 
	--BEGIN
		--IF (@GoodsIDFr Is Not Null)
			--SET @StrWhere = @StrWhere + ' AND (D.GoodsID >= ''' + @GoodsIDFr + ''')'
		--IF (@GoodsIDTo Is Not Null)
			--SET @StrWhere = @StrWhere + ' AND (D.GoodsID <= ''' + @GoodsIDTo + ''')'
	--END
	
	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 	

	IF (@GoodsIDMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID LIKE ''' + RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'')'

	IF (@GoodsNameMask Is Not Null and  @GoodsNameMask<>'0')
		SET @StrWhere = @StrWhere + ' AND Replace(D.AssetTitle, '' '', '''') LIKE N''%' + RTrim(Replace(@GoodsNameMask, ' ', '')) + '%'''

	-- @SelectedGoods ???

	IF (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'

	IF (@AssetLastStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (ast.funGetPlaqueStatus(D.AssetPlaque) = ' + LTRim(Str(@AssetLastStatus)) + ')'
	---------------------------------------------------------------------------

	---- SELECT ---------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.*, G.AstGroupName, L.LocateName, H.DescHdr, H.VchNo,(select OldSerialNo from acc.tblVoucherHdr where SerialNo =H.VchNo) as OldVchNo, H.VchDate, GD.GoodsName,
			H.GoodsQuantity, H.OtherCostAcntCode, H.OtherCost, H.OtherIncome, H.OtherIncomeAcntCode,
			pub.funGetProcessName(D.ProcessID,D.ProcessNo, ' + @LangID + ') ProcessName,
			(SELECT     COUNT(*) AS AtomCout
				FROM         ast.tblAstGroupSpecs AS S INNER JOIN
                ast.tblAssetsAtm AS A ON S.AstGroupSpecID = A.AstGroupSpecID
				WHERE     (A.ProcessID = D.ProcessID ) AND (A.ProcessNo = D.ProcessNo ) AND (A.FiscalYear = D.FiscalYear ) AND (A.SerialNo = D.SerialNo ) AND (A.DocRowNo = D.DocRowNo ) AND (S.AstGroupID = D.AstGroupID )) as AtomCout
	FROM	ast.tblAssetsDtl D
			INNER JOIN ast.tblAssetsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 	
			LEFT JOIN ast.tblAstGroupsDtl G ON G.AstGroupID = D.AstGroupID AND G.LanguageID = ' + @LangID + '
			LEFT JOIN ast.tblLocatesDtl L ON L.LocateID = D.LocateID AND L.LanguageID = ' + @LangID	+ '
			LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = D.GoodsID AND GD.LanguageID = ' + @LangID + '
	WHERE ' + @StrWhere + '
	ORDER BY D.AssetPlaque, D.DocDate ,EventNo '
	---------------------------------------------------------------------------

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
