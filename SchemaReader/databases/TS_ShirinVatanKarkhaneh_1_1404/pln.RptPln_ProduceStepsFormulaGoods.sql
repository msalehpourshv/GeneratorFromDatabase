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
-- Description   : 
-- =============================================
CREATE PROCEDURE [pln].[RptPln_ProduceStepsFormulaGoods]
	@ProductID			Varchar(20)	  = Null,
	@SerialNo			Int			  = Null,
	@ProduceStepID		Int			  = Null,
	@ExtraParams		NVarChar(200) = Null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @StrWhere2	NVarChar(Max);
DECLARE @LanguageID TinyInt;

BEGIN --============== S T A R T  C O D E ===================================================
	SET NOCOUNT ON;
	
	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set @StrSelect = ''
	Set @StrWhere = '1 = 1'

	-- I N I T ----------------------------------------------------------------
	If (@LanguageID Is Null)	SET @LanguageID = 1

	-- W H E R E --------------------------------------------------------------
	IF (@ProductID Is Not Null And @ProductID <> '')
		Set @StrWhere = @StrWhere + ' And H.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''''
		
	IF (@SerialNo Is Not Null And @SerialNo <> 0)
		Set @StrWhere = @StrWhere + ' And H.SerialNo = ' + LTrim(RTrim(Str(@SerialNo)))
	
	IF (@ProduceStepID Is Not Null And @ProduceStepID <> 0)
		Set @StrWhere = @StrWhere + ' And D.ProduceStepID = ' + LTrim(RTrim(Str(@ProduceStepID)))	
		
	-- S E L E C T ------------------------------------------------------------
	Set @StrSelect = '
		Select H.ProductID, H.ProductCount, H.SerialNo, D.GoodsID, 
			   [pub].[funGetGoodsName](D.GoodsID, ' + LTrim(RTrim(Str(@LanguageID))) + ')  as GoodsName, 
			   D.GoodsQuantity, D.ProduceStepID
		From prd.tblFormulasHdr H
		Inner Join prd.tblFormulasDtl D ON H.ProductID = D.ProductID And H.SerialNo = D.SerialNo
		Where ' + @StrWhere
	
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
