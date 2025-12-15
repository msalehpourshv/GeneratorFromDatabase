USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		 : Javad Bayani
-- Create date	 : 1388/10/19
-- Last Modified : 1389/02/20
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : This Procedure Select Produce Steps
-- =============================================
Create PROCEDURE pln.RptPln_ProduceSteps
	@SelectedProductID	Int = 0,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	Nvarchar(4000);
DECLARE @StrWhere	Nvarchar(4000);

DECLARE	@LangID		NvarChar(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE	@DefaultOnly	 Int;
DECLARE	@FSNO			 Int;
DECLARE @DefaultSerialNo BIT;
DECLARE @SerialNo		 INT;
DECLARE @DefaultFormula	 NVarChar(100);

BEGIN
	SET NOCOUNT ON;

	-- ---------------------------------------------------------------------------------
	IF @RepInfo IS NULL SET @RepInfo = '1@1@1'
	IF @SelectedProductID IS NULL SET @SelectedProductID = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @DefaultOnly		= pub.funSplitString(@RepInfo, '@', 6);
	SET @FSNO				= pub.funSplitString(@RepInfo, '@', 7);
	SET @DefaultSerialNo	= pub.funSplitString(@RepInfo, '@', 8);
	SET @SerialNo			= pub.funSplitString(@RepInfo, '@', 9);
	SET @DefaultFormula		= ''
	-- ---------------------------------------------------------------------------------

	SET @StrWhere	= '(1 = 1)';

	IF (@SelectedProductID > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProductID, 'D.ProductID') 

	IF (@DefaultOnly = 1)
		SET @DefaultFormula = ' AND F.IsDefault = 1 '
	
	IF (@DefaultOnly = 2)
		SET @StrWhere = @StrWhere + ' AND (F.SerialNo = ' + STR(@FSNO) + ')' 
	
	IF @DefaultSerialNo = 'True'
		SET @StrWhere = @StrWhere + ' AND (H.IsDefaultMethod = 1)' 

	IF @SerialNo <> 0
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo = '+ Str(@SerialNo) +')' 

	SET @StrSelect = N'
	SELECT D.*, 
		   H.ProduceMethodName, 
		   F.SerialNo FormulaNo,
		   [pub].[funGetGoodsName](D.ProductID,' + @LangID + ')  as ProductName,
		   [pub].[funGetGoodsName](D.GoodsIDInStep,' + @LangID + ')  as GoodsName, 
		   H.IsDefaultMethod,
		   0 as Balance, 
		   0 as Balance_Prd,
		   (SELECT COUNT(*)
		    FROM prd.tblFormulasHdr HH
			INNER JOIN prd.tblFormulasDtl DD ON HH.ProductID = DD.ProductID And HH.SerialNo = DD.SerialNo
			WHERE HH.ProductID = H.ProductID 
			  AND HH.SerialNo = H.FormulaNo 
			  AND DD.ProduceStepID = D.ProduceStepID) GoodsCount, 
		   (SELECT COUNT(*)
		    FROM pln.tblProduceStepAtom HH 
			WHERE HH.ProductID = D.ProductID 
			  AND HH.SerialNo = D.SerialNo 
			  AND HH.DocRowNo = D.DocRowNo) ToolsCount,
		   (SELECT COUNT(*)
		    FROM pln.tblProduceStepAtom2 HH	
			WHERE HH.ProductID = D.ProductID 
			  AND HH.SerialNo = D.SerialNo 
			  AND HH.DocRowNo = D.DocRowNo) MECount, 
		   H.ProductionLineID, 
		   pln.funGetProductionLineName(H.ProductionLineID,' + @LangID + ') ProductionLineName
	FROM pln.tblProduceStepDtl D
	INNER JOIN pln.tblProduceStepHdr H ON H.ProductID = D.ProductID 
									  AND H.SerialNo = D.SerialNo
	INNER JOIN prd.tblFormulasHdr F ON F.ProductID = H.ProductID ' + @DefaultFormula + '
	WHERE ' + @StrWhere + '
	ORDER BY D.DocRowNo '

	-- ---------------------------------------------------------------------------------
	PRINT @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
