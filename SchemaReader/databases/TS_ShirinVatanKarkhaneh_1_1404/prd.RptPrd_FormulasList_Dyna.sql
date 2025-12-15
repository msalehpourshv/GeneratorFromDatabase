USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/12/07
-- Viewed By	 : 
-- Last Modified : 1390/01/21
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_FormulasList_Dyna]
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@FormulaNo		int = 0, -- default formula if zero
	@FormulaName	nvarchar(200) = Null,
	@RepOptions		nvarchar(200) = '111',
	@RepInfo		nvarchar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @GoodsID	nVarChar(50);

DECLARE @Accepted	Bit;
DECLARE @NoAccept	Bit;

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedProds	Is Null)	SET @SelectedProds = 0;
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@RepOptions		Is Null)	SET @RepOptions = '111'

	SET @Accepted	= Substring(@RepOptions, 1, 1);
	SET @NoAccept	= Substring(@RepOptions, 2, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------

	-- WHERE SECTION --------------------------------
	SET @StrWhere = '(1=1)'
	
	If (@SelectedProds > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.ProductID') 
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 

	if (@Accepted = 0)
		SET @StrWhere = @StrWhere + ' AND (H.AcceptFormula = 0)' 
	if (@NoAccept = 0)
		SET @StrWhere = @StrWhere + ' AND (H.AcceptFormula = 1)' 
	
	If (@FormulaName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FormulaName LIKE N''%' + @FormulaName + '%'')' 

	if (@FormulaNo is not null)
		if (@FormulaNo = 0)
			SET @StrWhere = @StrWhere + ' AND (H.IsDefault = 1)' 
		else
			SET @StrWhere = @StrWhere + ' AND (H.SerialNo = ' + LTrim(Str(@FormulaNo)) + ')' 
	-------------------------------------------------
	create table #tbl_Result
	(
		ProductID	varchar(20) collate arabic_cs_as not null,
		GoodsName	nvarchar(100) not null,
		Quantity	float not null
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Result(ProductID, GoodsName, Quantity)
	SELECT	D.ProductID, [pub].[funGetGoodsName](D.GoodsID, ' + LTrim(RTrim(@LangID)) + ') As GoodsName, 
	       (D.GoodsQuantity / H.ProductCount) as Quantity
	FROM	prd.tblFormulasDtl D 
				inner join prd.tblFormulasHdr H on H.ProductID = D.ProductID and H.SerialNo = D.SerialNo 
	WHERE	' + @StrWhere

	print @StrSelect;
	exec sp_executesql @StrSelect;
	-------------------------------------------------
	declare @colsD nvarchar(max);
	set @colsD = '';
	
	declare csr_Codes cursor for 
		select distinct GoodsName
		from #tbl_Result
		order by GoodsName
	open csr_Codes;

	fetch next from csr_Codes into @GoodsID;

	while (@@FETCH_STATUS = 0) 
	begin
		if (@colsD <> '') 
			set @colsD = @colsD + ',';
			
		set @colsD = @colsD + '[' + @GoodsID + ']';
		fetch next from csr_Codes into @GoodsID;
	end

	close csr_Codes;
	deallocate csr_Codes;

	if (@colsD = '')
		set @colsD = '[0]';

	-- SELECT SECTION -------------------------------
	SET @StrSelect = '
	select X.*, [pub].[funGetGoodsName](X.[کد محصول], ' + LTrim(RTrim(@LangID)) + ') As [نام محصول]
	from
	(
		select ' + @colsD + ', ProductID as [کد محصول]
		from #tbl_Result P
		PIVOT 
		(
			Sum(P.Quantity)
			for P.GoodsName In (' + @colsD + ')
		) AS PVT 
	) X 
	--inner join inv.tblGoodsDtl G on G.GoodsID = X.[کد محصول]
	order by [کد محصول] '
	-------------------------------------------------

	print @StrSelect;
	exec sp_executesql @StrSelect;
END
GO
