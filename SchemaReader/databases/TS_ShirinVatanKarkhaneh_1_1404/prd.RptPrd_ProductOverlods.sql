USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/09/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 1389/09/27
-- Description   : <سربار محصولات>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProductOverlods]
	@SelectedProds	Int = 0,
	@Acnt01	varchar(20) = null,
	@Acnt02	varchar(20) = null,
	@Acnt03	varchar(20) = null,
	@Acnt04	varchar(20) = null,
	@Acnt05	varchar(20) = null,
	@Acnt06	varchar(20) = null,
	@Acnt07	varchar(20) = null,
	@Acnt08	varchar(20) = null,
	@Acnt09	varchar(20) = null,
	@Acnt10	varchar(20) = null,
	@Acnt11	varchar(20) = null,
	@Acnt12	varchar(20) = null,
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @StrWhere01	NVarChar(2000)
DECLARE @StrWhere02	NVarChar(2000)
DECLARE @StrWhere03	NVarChar(2000)
DECLARE @StrWhere04	NVarChar(2000)
DECLARE @StrWhere05	NVarChar(2000)
DECLARE @StrWhere06	NVarChar(2000)
DECLARE @StrWhere07	NVarChar(2000)
DECLARE @StrWhere08	NVarChar(2000)
DECLARE @StrWhere09	NVarChar(2000)
DECLARE @StrWhere10	NVarChar(2000)
DECLARE @StrWhere11	NVarChar(2000)
DECLARE @StrWhere12	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SelectedProduct varchar(20);
BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedProds	Is Null)	set @SelectedProds = 0;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	create table #tbl_Products
	(
		ProductID	varchar(20) collate Arabic_CS_AS null,
		ProductName	nvarchar(50) 
	);

	-- where section ----------------------------------------------------------
	set @StrWhere = '(1=1)';

	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'ProductID') 
	
	if (@Acnt01 is not null)
		set @StrWhere01 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt01 + ''')'
	else
		set @StrWhere01 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt02 is not null)
		set @StrWhere02 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt02 + ''')'
	else
		set @StrWhere02 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt03 is not null)
		set @StrWhere03 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt03 + ''')'
	else
		set @StrWhere03 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt04 is not null)
		set @StrWhere04 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt04 + ''')'
	else
		set @StrWhere04 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt05 is not null)
		set @StrWhere05 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt05 + ''')'
	else
		set @StrWhere05 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt06 is not null)
		set @StrWhere06 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt06 + ''')'
	else
		set @StrWhere06 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt07 is not null)
		set @StrWhere07 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt07 + ''')'
	else
		set @StrWhere07 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt08 is not null)
		set @StrWhere08 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt08 + ''')'
	else
		set @StrWhere08 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt09 is not null)
		set @StrWhere09 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt09 + ''')'
	else
		set @StrWhere09 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt10 is not null)
		set @StrWhere10 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt10 + ''')'
	else
		set @StrWhere10 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt11 is not null)
		set @StrWhere11 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt11 + ''')'
	else
		set @StrWhere11 =  '(OverLoadAcntCode = ''-'')'

	if (@Acnt12 is not null)
		set @StrWhere12 =  '(D.ProductID=P.ProductID) and (OverLoadAcntCode = ''' + @Acnt12 + ''')'
	else
		set @StrWhere12 =  '(OverLoadAcntCode = ''-'')'
	---------------------------------------------------------------------------
	-- select section ---------------------------------------------------------
	-- enlist products
	set @StrSelect = '
		insert	into #tbl_Products
		select	distinct ProductID, [pub].[funGetGoodsName](ProductID, ' + Ltrim(RTrim(@LangID)) + ') As ProductName
		from	prd.tblFormulasOverLoadDtl O	
		where (O.OverLoadProductDtl=1 or (O.OverLoadProductDtl=0 and O.OverLoadDecompositionDtl=0)) and ' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;

	-- enlist amount
	set @StrSelect = '
	select P.*, 
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere01 + '), 0) Amount01,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere02 + '), 0) Amount02,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere03 + '), 0) Amount03,
		isnull((select sum(OverLoadAmount) 
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere04 + '), 0) Amount04,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere05 + '), 0) Amount05,
		isnull((select sum(OverLoadAmount) 
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere06 + '), 0) Amount06,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere07 + '), 0) Amount07,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere08 + '), 0) Amount08,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere09 + '), 0) Amount09,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere10 + '), 0) Amount10,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere11 + '), 0) Amount11,
		isnull((select sum(OverLoadAmount)
			from prd.tblFormulasOverLoadDtl D inner join prd.tblFormulasHdr H on D.ProductID = H.ProductID and D.SerialNo = H.SerialNo
			where (H.IsDefault = 1) And (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))  and ' + @StrWhere12 + '), 0) Amount12
	from #tbl_Products P
	order by ProductID'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
