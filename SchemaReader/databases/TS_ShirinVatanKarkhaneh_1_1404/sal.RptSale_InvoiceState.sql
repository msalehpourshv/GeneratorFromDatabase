USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Taari
-- Create Date   : 1388/11/28
-- Viewed By	 : 
-- Last Modified : 1389/03/05
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : وضعیت فاکتورهای فروش
-- ==============================================
Create PROCEDURE  [sal].[RptSale_InvoiceState]
	@SettleDateFr	Char(10) = Null,
	@SettleDateTo	Char(10) = Null,
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@AcntCode		Varchar(20) = Null,
	@SaleTypeID		VarChar(20) = Null,
	@RepOptions		VarChar(20) = '00',
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(Max) = ''

WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);

Declare @DistFiscalYearFrom	int;
Declare @DistSerialNoFrom	int;
Declare @DistFiscalYearTo	int;
Declare @DistSerialNoTo		int;
Declare @HasVchNo			Bit;
Declare @VisitorAcntCode	Varchar(20) = Null;
Declare @strAcnt1			NVarChar(Max) = '';
Declare @strAcnt2			NVarChar(Max) = '';
Declare @strAcnt3			NVarChar(Max) = '';
Declare @strAcnt4			NVarChar(Max) = '';
Declare @rdoState			char(2);

--DECLARE @ShowUnSettled		Bit;
--DECLARE @ShowHardRec		Bit;
--DECLARE @ShowIsConfirmed	Bit;
--DECLARE @ShowAll			Bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------
	If (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	If (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	If (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	If (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	--SET @ShowUnSettled = Substring(@RepOptions, 1, 1)
	--SET @ShowHardRec = Substring(@RepOptions, 2, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	Set @DistFiscalYearFrom = pub.funSplitString(@ExtraParams,'@',1);
	Set @DistSerialNoFrom = pub.funSplitString(@ExtraParams,'@',2);
	Set @DistFiscalYearTo = pub.funSplitString(@ExtraParams,'@',3);
	Set @DistSerialNoTo = pub.funSplitString(@ExtraParams,'@',4);
	Set @HasVchNo = pub.funSplitString(@ExtraParams,'@',5);
	Set @VisitorAcntCode = pub.funSplitString(@ExtraParams,'@',6);
	Set @strAcnt1 = pub.funSplitString(@ExtraParams,'@',7);
	Set @strAcnt2 = pub.funSplitString(@ExtraParams,'@',8);
	Set @strAcnt3 = pub.funSplitString(@ExtraParams,'@',9);
	Set @strAcnt4 = pub.funSplitString(@ExtraParams,'@',10);
	Set @rdoState = pub.funSplitString(@ExtraParams,'@',11);
	
	---------------------------------------------------------
	-- Where Clause -----------------------------------------
	SET @StrWhere = 'H.ProcessID in (90,91)'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(RTrim(Str(@FiscalYearFr))) + ' OR (H.FiscalYear = ' +LTrim(RTrim(Str(@FiscalYearFr))) + ' AND H.SerialNo >= ' + LTrim(RTrim(Str(@SerialNoFr))) + '))';

	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' OR (H.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' AND H.SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo))) + '))';

	IF (@SettleDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.SettlementDate >= ''' + @SettleDateFr + ''')';

	IF (@SettleDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.SettlementDate <= ''' + @SettleDateTo + ''')';
	
	IF (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')';

	IF (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')';

	IF (@AcntCode is not null)
		SET @StrWhere = @StrWhere + ' AND (H.AcntCode = ''' + @AcntCode + ''')';

	If (@SaleTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.SaleTypeID=''' + @SaleTypeID + ''''

	If (@DistFiscalYearFrom is not null) and (@DistFiscalYearFrom <> '')
		SET @StrWhere = @StrWhere + ' AND (H.BaseDistributionFiscalYear >= '''+LTrim(RTrim(Str(@DistFiscalYearFrom)))+''')';

	If (@DistSerialNoFrom is not null) and (@DistSerialNoFrom <> '')
		SET @StrWhere = @StrWhere + ' AND (H.BaseDistributionSerialNo >= '''+LTrim(RTrim(Str(@DistSerialNoFrom)))+''')';

	If (@DistFiscalYearTo is not null) and (@DistFiscalYearTo <> '')
		SET @StrWhere = @StrWhere + ' AND (H.BaseDistributionFiscalYear <= '''+LTrim(RTrim(Str(@DistFiscalYearTo)))+''')';

	If (@DistSerialNoTo is not null) and (@DistSerialNoTo <> '')
		SET @StrWhere = @StrWhere + ' AND (H.BaseDistributionSerialNo <= '''+LTrim(RTrim(Str(@DistSerialNoTo)))+''')';

	If (@HasVchNo is not null) and (@HasVchNo <> '')
	Begin
		If (@HasVchNo = '1')
			Set @StrWhere = @StrWhere + ' AND (H.VchNo > 0) ';
		else if (@HasVchNo = '2')
			Set @StrWhere = @StrWhere + ' AND (H.VchNo = 1) ';
		else
			Set @StrWhere = @StrWhere + '';
	End

	If (@VisitorAcntCode is not null) and (@VisitorAcntCode <> '')
		SET @StrWhere = @StrWhere + ' AND (H.VisitorAcntCode LIKE '''+@VisitorAcntCode+'%'')';

	If (@strAcnt1 is not null) and (@strAcnt1 <>'')
		SET @StrWhere = @StrWhere +  @strAcnt1 ;

	If (@strAcnt2 is not null) and (@strAcnt2 <>'')
		SET @StrWhere = @StrWhere  + @strAcnt2 ;

	If (@strAcnt3 is not null) and (@strAcnt3 <>'')
		SET @StrWhere = @StrWhere  + @strAcnt3 ;

	If (@strAcnt4 is not null) and (@strAcnt4 <>'')
		SET @StrWhere = @StrWhere  + @strAcnt4 ;
	
	if (@rdoState is not null) and (@rdoState <>'')
	Begin
		IF (@rdoState = '00')
			SET @StrWhere = @StrWhere + '';
	
		IF (@rdoState = '01')
			SET @StrWhere = @StrWhere + ' AND (H.IsConfirmed = 0)';

		IF (@rdoState = '10')
			SET @StrWhere = @StrWhere + ' AND (H.HardRecivable = 1)';
		
		IF (@rdoState = '11')
			SET @StrWhere = @StrWhere + ' AND (H.ConfirmReceipt = 1)';
	End
	------------------------------------------------------------
	-- SELECT Clause ----------------------------------------
	SET @StrSelect = '
	SELECT FiscalYear, SerialNo, AcntCode, pub.GetCodeName (AcntCode,1) AcntName, Price, DocDate, SettlementDate,
			ST.SaleTypeName, VisitorAcntCode, pub.GetCodeName (VisitorAcntCode,1) VisitorAcntName
	FROM inv.tblStorageDocsHdr H
			left join sal.tblSaleTypesDtl ST on ST.SaleTypeID = H.SaleTypeID
	WHERE ' + @StrWhere
	------------------------------------------------------------
	-- RUN -----------------------------------------------------
	PRINT @StrSelect ;
	EXEC sp_executesql @StrSelect ;
	------------------------------------------------------------
End
GO
