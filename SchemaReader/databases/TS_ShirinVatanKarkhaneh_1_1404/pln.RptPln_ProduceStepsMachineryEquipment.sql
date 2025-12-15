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
Create PROCEDURE pln.RptPln_ProduceStepsMachineryEquipment
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
DECLARE @DBNAME		VarChar(100)

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
	SET @DBNAME = db_name()
	SET @DBNAME = Substring(@DBNAME, 1, Len(@DBNAME) - 4) + '0000'
	-- S E L E C T ------------------------------------------------------------
	Set @StrSelect = '		 
		SELECT A.*, T.MachineryEquipmentName  
              FROM pln.tblProduceStepAtom2 A 
              INNER JOIN '+@DBNAME+'.tpm.tblMachineryEquipmentDtl T ON A.MachineryEquipmentID = T.MachineryEquipmentID  
		Where ' + @StrWhere
	
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
