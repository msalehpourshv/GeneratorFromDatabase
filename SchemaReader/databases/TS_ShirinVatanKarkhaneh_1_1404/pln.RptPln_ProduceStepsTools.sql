USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1401/11/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
Create PROCEDURE pln.RptPln_ProduceStepsTools
	@ProductID			Varchar(20)	  = Null,
	@SerialNo			Int			  = Null,
	@DocRowNo			Int			  = Null,
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
		Set @StrWhere = @StrWhere + ' And A.ProductID = ''' + LTrim(RTrim(@ProductID)) + ''''
		
	IF (@SerialNo Is Not Null And @SerialNo <> 0)
		Set @StrWhere = @StrWhere + ' And A.SerialNo = ' + LTrim(RTrim(Str(@SerialNo)))
	
	IF (@DocRowNo Is Not Null And @DocRowNo <> 0)
		Set @StrWhere = @StrWhere + ' And A.DocRowNo = ' + LTrim(RTrim(Str(@DocRowNo)))	
		
	-- S E L E C T ------------------------------------------------------------
	Set @StrSelect = '
		select TL.ToolName, A.*
		from pln.tblProduceStepAtom A --on A.ProductID = D.ProductID and A.SerialNo = D.SerialNo and A.DocRowNo = D.DocRowNo
		Left Join pln.tblTools TL on TL.ToolID = A.ToolID  
		Where ' + @StrWhere
	
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
