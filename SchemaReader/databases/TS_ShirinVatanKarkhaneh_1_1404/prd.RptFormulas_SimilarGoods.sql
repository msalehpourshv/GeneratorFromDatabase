USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Hamid
-- Create date   : 393/08/15
-- Viewed By	 : 
-- Last Modified : 1393/08/15
-- Last Modifier : TakroSystem/Hamid
-- Description   : برگ سفارش خرید کالا
-- =============================================
Create PROCEDURE prd.RptFormulas_SimilarGoods
	@ProductID		Varchar(20) = Null,
	@SerialNo		Int = Null,
	@DocRowNo		Int = Null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @LanguageID TinyInt;
DECLARE @HasSerial  Bit;

Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set @StrSelect = ''
	Set @StrWhere = '1 = 1'

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	If (@LanguageID Is Null)	SET @LanguageID = 1

	-- W H E R E --------------------------------------------------------------
	IF (@ProductID Is Not Null And @ProductID <> '')
		Set @StrWhere = @StrWhere + ' And A.ProductID = ''' + @ProductID + ''''
		
	IF (@SerialNo Is Not Null And @SerialNo <> 0)
		Set @StrWhere = @StrWhere + ' And A.SerialNo = ''' + LTrim(RTrim(@SerialNo)) + ''''		
		
	IF (@DocRowNo Is Not Null And @DocRowNo <> 0)
		Set @StrWhere = @StrWhere + ' And A.DocRowNo = ''' + LTrim(RTrim(@DocRowNo)) + ''''			
	
	-- S E L E C T ------------------------------------------------------------

	Set @StrSelect = '
		SELECT A.*,  [pub].[funGetGoodsName](A.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName 
		, isnull((Select Sum(GoodsQuantity*EnterKind) From inv.tblStorageDocsDtl  S where S.GoodsID=A.GoodsID) ,0 )GoodsQty
		,[inv].[funGetSubUnitFromGoodsQuantity](A.GoodsID,A.SubUnitID, isnull((Select Sum(GoodsQuantity*EnterKind) From inv.tblStorageDocsDtl  S where S.GoodsID=A.GoodsID),0 ) ) SubUnitQty
		FROM prd.tblFormulasAtm A
		INNER JOIN prd.tblFormulasDtl D ON D.ProductID = A.ProductID And D.SerialNo = A.SerialNo And D.DocRowNo = A.DocRowNo
		WHERE ' + @StrWhere + '
		ORDER BY A.SerialNo, A.DocRowNo '
	
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
