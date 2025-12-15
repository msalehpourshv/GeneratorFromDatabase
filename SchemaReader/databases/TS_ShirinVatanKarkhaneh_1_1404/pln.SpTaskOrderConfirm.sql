USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1402/05/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE pln.SpTaskOrderConfirm 
	@ExtraParams	NVarChar(4000),
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
BEGIN

	DECLARE @StrSelect NVarChar(max);
	DECLARE @StrWhere  NVarChar(max);

	DECLARE	@LangID		Char(1);
	DECLARE	@SessionNo	Int; 
	DECLARE	@ReportID	Int;
	DECLARE	@UserID		Int;
	DECLARE	@UserIsAdmin bit;
	
	declare @ProductID			Varchar(20)
	
	declare @OrderFiscalYearFr  int;
	declare @OrderSerialNoFr	int;
	declare @OrderFiscalYearTo  int;
	declare @OrderSerialNoTo	int;
	declare @OrderDocDateFr		char(10);
	declare @OrderDocDateTo		char(10);

	declare @TaskFiscalYearFr	int;
	declare @TaskSerialNoFr		int;
	declare @TaskFiscalYearTo	int;
	declare @TaskSerialNoTo		int;
	declare @TaskDocDateFr		char(10);
	declare @TaskDocDateTo		char(10);
	
	declare @SgnSN				int;
	declare @Confirmed			bit;
	declare @NotConfirmed		bit;
	
	SET @LangID				= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		= pub.funSplitString(@RepInfo, '@', 5);

	SET @ProductID			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @OrderFiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @OrderSerialNoFr	= pub.funSplitString(@ExtraParams, '@', 3);
	SET @OrderFiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 4);
	SET @OrderSerialNoTo	= pub.funSplitString(@ExtraParams, '@', 5);
	SET @OrderDocDateFr		= pub.funSplitString(@ExtraParams, '@', 6);
	SET @OrderDocDateTo		= pub.funSplitString(@ExtraParams, '@', 7);

	SET @TaskFiscalYearFr	= pub.funSplitString(@ExtraParams, '@', 8);
	SET @TaskSerialNoFr		= pub.funSplitString(@ExtraParams, '@', 9);
	SET @TaskFiscalYearTo	= pub.funSplitString(@ExtraParams, '@', 10);
	SET @TaskSerialNoTo		= pub.funSplitString(@ExtraParams, '@', 11);
	SET @TaskDocDateFr		= pub.funSplitString(@ExtraParams, '@', 12);
	SET @TaskDocDateTo		= pub.funSplitString(@ExtraParams, '@', 13);
	
	SET @SgnSN				= pub.funSplitString(@ExtraParams, '@', 14);
	SET @Confirmed			= pub.funSplitString(@ExtraParams, '@', 15);
	SET @NotConfirmed		= pub.funSplitString(@ExtraParams, '@', 16);

	SET @StrWhere = ' TaskStateID=4 '

	IF @ProductID > 0
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @ProductID, 'T.ProductID')
	IF @OrderFiscalYearFr > 0
		SET @StrWhere = @StrWhere + ' AND O.FiscalYear>=' +str(@OrderFiscalYearFr)
	IF @OrderSerialNoFr > 0
		SET @StrWhere = @StrWhere + ' AND O.SerialNo>=' +str(@OrderSerialNoFr)
	IF @OrderFiscalYearTo > 0
		SET @StrWhere = @StrWhere + ' AND O.FiscalYear<=' +str(@OrderFiscalYearTo)
	IF @OrderSerialNoTo > 0
		SET @StrWhere = @StrWhere + ' AND O.SerialNo<=' +str(@OrderSerialNoTo)

	IF @OrderDocDateFr <> ''
		SET @StrWhere = @StrWhere + ' AND O.DocDate>=''' +	@OrderDocDateFr+''''

	IF @OrderDocDateTo <> ''
		SET @StrWhere = @StrWhere + ' AND O.DocDate<=''' + @OrderDocDateTo+''''

	IF @TaskFiscalYearFr > 0
		SET @StrWhere = @StrWhere + ' AND T.FiscalYear>=' +str(@TaskFiscalYearFr)
	IF @TaskSerialNoFr > 0
		SET @StrWhere = @StrWhere + ' AND T.SerialNo>=' +str(@TaskSerialNoFr)
	IF @TaskFiscalYearTo > 0
		SET @StrWhere = @StrWhere + ' AND T.FiscalYear<=' +str(@TaskFiscalYearTo)
	IF @TaskSerialNoTo > 0
		SET @StrWhere = @StrWhere + ' AND T.SerialNo<=' +str(@TaskSerialNoTo)
	IF @TaskDocDateFr <> ''
		SET @StrWhere = @StrWhere + ' AND T.DocDate>=''' +	@TaskDocDateFr+''''
	IF @TaskDocDateTo <> ''
		SET @StrWhere = @StrWhere + ' AND T.DocDate<=''' + @TaskDocDateTo+''''
	if  @Confirmed<>@NotConfirmed
		begin
		if @Confirmed='True'
			SET @StrWhere = @StrWhere + ' AND T.SgnSN'+ltrim(str(@SgnSN))+'>0' 
			else
			SET @StrWhere = @StrWhere + ' AND T.SgnSN'+ltrim(str(@SgnSN))+'=0' 
		end 

	SET @StrSelect = '
	SELECT   T.*, O.DocDate ProduceDocDate,  pub.funGetGoodsName(T.ProductID,1) as ProductName
	FROM pln.tblTaskOrderHdr T    
	INNER JOIN pln.tblProduceOrderHdr O ON O.ProcessID = T.BaseProcessID AND O.ProcessNo = T.BaseProcessNo AND O.FiscalYear = T.BaseFiscalYear AND O.SerialNo = T.BaseSerialNo  
	INNER JOIN pln.tblProduceOrderDtl OD ON OD.ProcessID = T.BaseProcessID AND OD.ProcessNo = T.BaseProcessNo AND OD.FiscalYear = T.BaseFiscalYear AND OD.SerialNo = T.BaseSerialNo  AND OD.DocRowNo = T.ProdDocRowNo                     
	WHERE ' + @StrWhere + '
	ORDER BY O.SerialNo, T.SerialNo'
 
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

END
GO
