USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1387/01/22
-- Viewed By	 : 
-- Last Modified : 
-- Description   : آمار باربری ها - لیست فاکتورها
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_TransInvoices]
	@TransPorterID	VarChar(3),
	@FiscalYearFrom	SmallInt = Null,
	@FiscalYearTo	SmallInt = Null,
	@SerialNoFrom	SmallInt = Null,
	@SerialNoTo		SmallInt = Null,
	@DateFrom		Char(10) = Null,
	@DateTo			Char(10) = Null,
	@FullInvoices	Bit = 0,
	@LanguageID		TinyInt = 1
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ---------------------------
	If (@LanguageID Is Null) SET @LanguageID = 1

	If (@FiscalYearFrom Is Null) SET @SerialNoFrom	= Null;
	If (@FiscalYearTo	Is Null) SET @SerialNoTo	= Null;

	If (@SerialNoFrom	Is Null) SET @FiscalYearFrom= Null;
	If (@SerialNoTo		Is Null) SET @FiscalYearTo  = Null;
	---------------------------------------------

	-- Where Clause ------------------------------------------------------------
	SET @StrWhere = '(H.ProcessID = 90) AND (H.TransporterID = ' + @TransPorterID + ')'

	If (@FiscalYearFrom	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFrom)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYearFrom)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFrom)) + ')) '

	If (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '

	If (@DateFrom Is Not Null) OR (@DateTo Is Not Null)
		If (@DateFrom = @DateTo)
			SET @StrWhere = @StrWhere + ' AND H.DocDate  = ''' + @DateFrom + ''''
		Else 
		Begin
			If (@DateFrom Is Not Null)
				SET @StrWhere = @StrWhere + ' AND H.DocDate >= ''' + @DateFrom + ''''
			If @DateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND H.DocDate <= ''' + @DateTo + ''''
		End
	------------------------------------------------------------

	-- Select Clause -------------------------------------------
	SET @StrSelect = '
		SELECT	LTrim(Str(H.FiscalYear)) + ''/'' + LTrim(Str(H.SerialNo)) InvoiceNo, H.DocDate , L.LocationName
		FROM	[inv].[tblStorageDocsHdr] H 
				LEFT JOIN [pub].[tblLocationsDtl] L ON H.LocationID = L.LocationID AND L.LanguageID = ' + LTrim(Str(@LanguageID)) + '
		WHERE	' + @StrWhere  
	--------------------------------------------------------------

	-- Run -------------------------------------------------------
--	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	--------------------------------------------------------------
End
GO
