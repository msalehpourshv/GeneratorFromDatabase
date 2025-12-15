USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/11/02
-- Viewed By	 : 
-- Last Modified : 1389/10/07
-- Last Modifier : TakroSystem\Zia
-- Description	 : گزارش کلی انبار
-- Dependencies  :	RptAst_Unavailable, RptAst_Balance, 
--					RptAst_Loss, RptAst_Use
-- ==============================================
Create PROCEDURE ast.RptAst_All 
	@ProcessIDList		VarChar(200) = Null ,
	@ProcessNo			Int = Null,
	@FiscalFr			Int = Null,
	@SerialFr			Int = Null,
	@FiscalTo			Int = Null,
	@SerialTo			Int = Null,
	@BaseFiscal			Int = Null,
	@BaseSerial			Int = Null,
	@DocDateFr			VarChar(10) = Null,
	@DocDateTo			VarChar(10) = Null,
	@PurchaseDateFr		VarChar(10) = Null,
	@PurchaseDateTo		VarChar(10) = Null,
	@ReturnDateFr		VarChar(10) = Null,
	@ReturnDateTo		VarChar(10) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@AssetPlaqueFr		VarChar(20) = Null,
	@AssetPlaqueTo		VarChar(20) = Null,
	@AssetAcntCodeFr	VarChar(20) = NULL,
	@AssetAcntCodeTo	VarChar(20) = NULL,
	@LocateIDFr			VarChar(20) = Null, 
	@LocateIDTo			VarChar(20) = Null, 
	@AstGroupIDFr		VarChar(20) = Null,
	@AstGroupIDTo		VarChar(20) = Null,
	@GoodsIDFr			VarChar(20) = Null,
	@GoodsIDTo			VarChar(20) = Null,  
	@AssetManagerID		VarChar(20) = Null,
	@ResponsibleID		VarChar(20) = Null,
	@ObverseAcntCode	VarChar(20) = Null,
	@DeprecAcntCode		VarChar(20) = Null,
	@OtherCostAcntCode  VarChar(20) = Null,
	@OtherIncomeAcntCode VarChar(20) = Null,
	@DeprecMethod		TinyInt = Null,
	@RenovationTypeID	TinyInt	= Null,
	@AssetStatus		TinyInt = Null, -- وضعیت ردیف
	@AssetLastStatus	TinyInt = Null, -- وضعیت جاری
	@DescHdr			NVarChar(2000) = Null,
	@LastRowOnly		Bit = 0, -- فقط سطر آخر برای هر پلاک گزارش شود یا کل گردش؟
	@SortFields			NVarChar(Max) = Null
WITH ENCRYPTION
AS 
DECLARE @LangID		VarChar(3);
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrWhere2	NVarChar(max);
Declare @ExtraParams	nvarchar(100) ;
DECLARE	@ShowDesc		Int;
DECLARE	@ExitWithOutEnter	bit;

BEGIN 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;
	Set @ExtraParams =@SortFields
	SET @SortFields = pub.funSplitString(@ExtraParams, '@', 1);
	SET @ShowDesc = pub.funSplitString(@ExtraParams, '@', 2);
	SET @ExitWithOutEnter = pub.funSplitString(@ExtraParams, '@', 3);
	
	---- INIT -----------------------------------------------------------------
	SET @LangID = LTRim(Str(pub.funGetCurrentLanguageID()));

	IF @FiscalFr Is Null SET @SerialFr = Null
	IF @FiscalTo Is Null SET @SerialTo = Null
	IF @SerialFr Is Null SET @FiscalFr = Null
	IF @SerialTo Is Null SET @FiscalTo = Null

	IF @BaseFiscal Is Null SET @BaseSerial = Null
	IF @BaseSerial Is Null SET @BaseFiscal = Null
	---------------------------------------------------------------------------

	---- WHERE ----------------------------------------------------------------
	SET @StrWhere = '(1 = 1)'

	IF (@ProcessIDList Is Not Null )
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID IN (' + @ProcessIDList + '))'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.FiscalYear > ' + LTrim(Str(@FiscalFr)) + ') OR ((D.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ') AND (D.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')))'
	
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((D.FiscalYear < ' + LTrim(Str(@FiscalFr)) + ') OR ((D.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ') AND (D.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')))'

	IF (@BaseSerial Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear = ' + LTrim(Str(@BaseFiscal)) + ') AND (D.SerialNo >= ' + LTrim(Str(@BaseSerial)) + ')'

	IF (@DocDateFr Is Not Null) AND (@DocDateTo Is Not Null) AND (@DocDateFr = @DocDateTo)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate = ''' + @DocDateFr + ''')'
	ELSE
	BEGIN
		IF (@DocDateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')'

		IF (@DocDateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')'
	END

	IF (@PurchaseDateFr Is Not Null) AND (@PurchaseDateTo Is Not Null) AND (@PurchaseDateFr = @PurchaseDateTo)
		SET @StrWhere = @StrWhere + ' AND (D.PurchaseDate = ''' + @PurchaseDateFr + ''')'
	ELSE
	BEGIN
		IF (@PurchaseDateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.PurchaseDate >= ''' + @PurchaseDateFr + ''')'
		IF (@PurchaseDateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.PurchaseDate <= ''' + @PurchaseDateTo + ''')'
	END

	IF (@ReturnDateFr Is Not Null) AND (@ReturnDateTo Is Not Null) AND (@ReturnDateFr = @ReturnDateTo)
		SET @StrWhere = @StrWhere + ' AND (D.ReturnDate = ''' + @ReturnDateFr + ''')'
	ELSE
	BEGIN
		IF (@ReturnDateFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.ReturnDate >= ''' + @ReturnDateFr + ''')'
		IF (@ReturnDateTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.ReturnDate <= ''' + @ReturnDateTo + ''')'
	END

	IF (@VchNoFr Is Not Null) AND (@VchNoTo Is Not Null) AND (@VchNoFr = @VchNoTo)
		SET @StrWhere = @StrWhere + ' AND (H.VchNo = ' + LTrim(Str(@VchNoFr)) + ')'
	ELSE
	BEGIN
		IF (@VchNoFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@VchNoFr)) + ')'
		IF (@VchNoTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@VchNoTo)) + ')'
	END

	IF (@AssetPlaqueFr Is Not Null) AND (@AssetPlaqueTo Is Not Null) AND (@AssetPlaqueFr = @AssetPlaqueTo)
		SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque = ''' + @AssetPlaqueFr + ''')'
	ELSE
	BEGIN
		If (@AssetPlaqueFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque >= ''' + @AssetPlaqueFr + ''')'
		If (@AssetPlaqueTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetPlaque <= ''' + @AssetPlaqueTo + ''')'
	END

	IF (@AssetAcntCodeFr Is Not Null) AND (@AssetAcntCodeTo Is Not Null) AND (@AssetAcntCodeFr = @AssetAcntCodeTo)
		SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode = ''' + @AssetAcntCodeFr + ''')'
	ELSE
	BEGIN
		IF (@AssetAcntCodeFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode >= ''' + @AssetAcntCodeFr + ''')'
		IF (@AssetAcntCodeTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AssetAcntCode <= ''' + @AssetAcntCodeTo + ''')'
	END

	IF (@LocateIDFr Is Not Null) AND (@LocateIDTo Is Not Null) AND (@LocateIDFr = @LocateIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.LocateID LIKE ''' + @LocateIDFr + '%'')'
	ELSE
	BEGIN
		IF (@LocateIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID >= ''' + @LocateIDFr + ''')'
		IF (@LocateIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.LocateID <= ''' + @LocateIDTo + ''')'
	END

	IF (@AstGroupIDFr Is Not Null) AND (@AstGroupIDTo Is Not Null) AND (@AstGroupIDFr = @AstGroupIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.AstGroupID = ''' + @AstGroupIDFr + ''')'
	ELSE
	BEGIN
		IF (@AstGroupIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID >= ''' + @AstGroupIDFr + ''')'
		IF (@AstGroupIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.AstGroupID <= ''' + @AstGroupIDTo + ''')'
	END

	IF (@GoodsIDFr Is Not Null) AND (@GoodsIDTo Is Not Null) AND (@GoodsIDFr = @GoodsIDTo)
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + @GoodsIDFr + ''')'
	ELSE 
	BEGIN
		IF (@GoodsIDFr Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.GoodsID >= ''' + @GoodsIDFr + ''')'
		IF (@GoodsIDTo Is Not Null)
			SET @StrWhere = @StrWhere + ' AND (D.GoodsID <= ''' + @GoodsIDTo + ''')'
	END

	If (@AssetManagerID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetManagerID = ''' + @AssetManagerID + ''')'

	If (@ResponsibleID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ResponsibleID = ''' + @ResponsibleID + ''')'



	IF (@DeprecAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationAcntCode = ''' + @DeprecAcntCode + ''')'

	IF (@OtherCostAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OtherCostAcntCode = ''' + @OtherCostAcntCode + ''')'

	IF (@OtherIncomeAcntCode Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.OtherIncomeAcntCode = ''' + @OtherIncomeAcntCode + ''')'

	If (@DeprecMethod Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DepreciationMethod = ' + LTRim(Str(@DeprecMethod)) + ')'

	If (@RenovationTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.RenovationTypeID = ' + LTrim(Str(@RenovationTypeID)) + ')'

	IF (@AssetStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.AssetState = ' + LTRim(Str(@AssetStatus)) + ')'

	IF (@AssetLastStatus Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (ast.funGetPlaqueStatus(D.AssetPlaque) = ' + LTRim(Str(@AssetLastStatus)) + ')'

	IF (@DescHdr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DescHdr LIKE N''%' + @DescHdr + '%'')'
		
		set @StrWhere2=@StrWhere
		
			IF (@ObverseAcntCode Is Not Null  )
		SET @StrWhere = @StrWhere + ' AND (D.ObverseAcntCode like  ''' + @ObverseAcntCode + '%'')'
	---------------------------------------------------------------------------
	if @ExitWithOutEnter='True'
	begin	
		SET @StrWhere = @StrWhere + 
		' AND  D.AssetPlaque in ( 
			select AssetPlaque from (
			select Count(*) cnt, AssetPlaque from ast.tblAssetsDtl b where b.ProcessID=500 Group by AssetPlaque
				except
			select Count(*) cnt, AssetPlaque from ast.tblAssetsDtl b where  b.ProcessID=505 Group by AssetPlaque 
			)d )'
	end		
	---- SELECT ---------------------------------------------------------------
	SET @StrSelect = '
	SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, Case when D.ProcessID in (450,455,460) Then D.PurchaseDate else D.DocDate end DocDate, D.AstGroupID, D.LocateID, D.GoodsID, 
		    D.AssetPlaque, D.AssetTitle, D.AssetManagerID, D.ResponsibleID, D.AssetAcntCode, D.ObverseAcntCode, D.PurchaseDate, 
			D.PurchaseAmount, D.SetupAmount, D.OtherCosts, D.UseDate, D.DepreciationAcntCode, D.OldValue, D.TopRegisteredValue, 
			D.CostAmount, D.DocRowNo, D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.BaseDocRowNo, 
			D.DepreciationMethod, D.DepreciationRate, D.DepreciationAmount, D.RegisteredValue, D.RenovationTypeID, 
			D.ChangeAmount, D.ReturnDate, D.AssetState, D.EventNo, D.CostAcntCode, D.SourceSerialNo, D.SourceProcessNo, 
			D.SetupAmountAcntCode, D.OtherCostsAcntCode, D.DepreciationValue, D.CostInSale, D.DescDtl, D.DepreciationCost, 
			D.DepreciationCostAcntCode, D.AssetAcntCode2, H.GoodsQuantity, H.VchNo,(select OldSerialNo from acc.tblVoucherHdr where SerialNo =H.VchNo) as OldVchNo,  H.VchDate, H.DescHdr, H.OtherCostAcntCode, 
			H.OtherIncome, H.OtherIncomeAcntCode, H.TaxOverWorthCost,H.PersonnelID, P.FirstName + '' '' + P.LastName as PersonnelName,
			H.OtherCost, GR.AstGroupName, LC.LocateName, GD.GoodsName,   F.Address1 , F.Address2 , F.Tel,
		    H.ObverseAcntCode HdrObverseAcntCode , H.ThroughAcntCode , 
			pub.funGetProcessName(D.ProcessID,D.ProcessNo, ' + @LangID + ') ProcessName,
			pub.GetCodeName(D.AssetAcntCode, ' + @LangID + ') AssetAcntName,
			pub.GetCodeName(D.ObverseAcntCode, ' + @LangID + ') ObverseAcntName,
		    pub.GetCodeName(H.ObverseAcntCode, ' + @LangID + ') HdrObverseAcntName,
			ast.funGetAssetManagerName(D.AssetManagerID,' + @LangID + ') AssetManagerName,
			prs.funGetPersonnelName(D.ResponsibleID,' + @LangID + ') ResponsibleName,
			ast.funGetRenovTypeName(D.RenovationTypeID) RenovationTypeName,
			ast.funGetDeprecMethodName(D.DepreciationMethod) DeprecMethodName,
			pub.GetUserName(H.SessionNo) AS UserName,
			ast.funGetLocateName(B.LocateID,' + @LangID + ') LocateName2,
			ast.funGetAssetManagerName(B.AssetManagerID,' + @LangID + ') AssetManagerName2,
			prs.funGetPersonnelName(B.ResponsibleID,' + @LangID + ') PersonnelName2, 
			(SELECT     COUNT(*) AS AtomCout
				FROM         ast.tblAstGroupSpecs AS S INNER JOIN
                ast.tblAssetsAtm AS A ON S.AstGroupSpecID = A.AstGroupSpecID
				WHERE     (A.ProcessID = D.ProcessID ) AND (A.ProcessNo = D.ProcessNo ) AND (A.FiscalYear = D.FiscalYear ) AND (A.SerialNo = D.SerialNo ) AND (A.DocRowNo = D.DocRowNo ) AND (S.AstGroupID = D.AstGroupID )) as AtomCout		
	FROM	ast.tblAssetsDtl D
			INNER JOIN ast.tblAssetsHdr    H  ON H.ProcessID   = D.ProcessID  AND H.ProcessNo   = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
			LEFT  JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = H.PersonnelID AND P.LanguageID = ' + @LangID + '
			LEFT  JOIN inv.tblGoodsDtl     GD ON GD.GoodsID    = D.GoodsID    AND GD.LanguageID = ' + @LangID + '
			LEFT  JOIN ast.tblLocatesDtl   LC ON LC.LocateID   = D.LocateID   AND LC.LanguageID = ' + @LangID + '
			LEFT  JOIN ast.tblAstGroupsDtl GR ON GR.AstGroupID = D.AstGroupID AND GR.LanguageID = ' + @LangID + '
			LEFT JOIN (Select * From ast.tblAssetsDtl   '
	IF (@ProcessIDList Is Not Null And @ProcessIDList<>'480')
		SET @StrSelect = 	@StrSelect + ' Where 1=0'	

		SET @StrSelect = 	@StrSelect + ')B ON D.AssetPlaque=B.AssetPlaque AND D.EventNo-1=B.EventNo  OUTER APPLY [acc].[funGetCodeInfo](H.ObverseAcntCode) AS F
	WHERE ' + @StrWhere 
	
	-- // This Line must be after all conditions //
	IF (@LastRowOnly = 1)
		SET @StrSelect = ' 
		select A.*
		from (' + @StrSelect + ') A
			inner join 
			(
				SELECT D.AssetPlaque, MAX(D.EventNo) EventNo
				FROM	ast.tblAssetsDtl D
							INNER JOIN ast.tblAssetsHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
				 WHERE ' + @StrWhere2 + '
				 
				GROUP BY D.AssetPlaque
			) MX on MX.AssetPlaque = A.AssetPlaque and MX.EventNo = A.EventNo '

	IF (@SortFields Is Not Null)
	SET @StrSelect = @StrSelect + '
	ORDER BY ' + @SortFields
	---------------------------------------------------------------------------

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
