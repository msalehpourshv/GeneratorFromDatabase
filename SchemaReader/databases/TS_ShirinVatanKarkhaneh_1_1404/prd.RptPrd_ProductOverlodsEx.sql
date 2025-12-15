USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/07
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <سربار محصولات>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProductOverlodsEx]
	@SelectedProds	Int = 0,
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE @AcntCode	VarChar(20)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
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

	create table #tblAcntCodes
	(
		AcntCode varchar(20) collate arabic_cs_as
	)
	-- where section ----------------------------------------------------------
	set @StrWhere = '(D.OverLoadAmount>0)';

	if (@SelectedProds > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.ProductID') 

	SET @StrSelect = '
	insert into #tblAcntCodes
	select distinct OverLoadAcntCode
	from prd.tblFormulasOverLoadDtl D
	where (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))   And ' + @StrWhere 

	print @StrSelect;
	exec sp_executesql @StrSelect;

	---------------------------------------------------------------------------
	-- select section ---------------------------------------------------------
	declare @colsD nvarchar(4000);
	set @colsD = '';
	
	declare csr_Codes cursor for 
		select AcntCode
		from #tblAcntCodes
	open csr_Codes;

	fetch next from csr_Codes into @AcntCode;

	while (@@FETCH_STATUS = 0) 
	begin
		if (@colsD <> '') 
			set @colsD = @colsD + ',';
			
		set @colsD = @colsD + '[' + @AcntCode + ']';
		fetch next from csr_Codes into @AcntCode;
	end

	close csr_Codes;
	deallocate csr_Codes;

	if (@colsD = '')
		set @colsD = '[0]';
	
	SET @StrSelect = '
	select X.*, [pub].[funGetGoodsName](X.[کد محصول], ' + Ltrim(RTrim(@LangID)) + ') As [نام محصول]
	from
	(
		select ' + @colsD + ', ProductID as [کد محصول]
		from 
		(
			select D.ProductID, OverLoadAcntCode, OverLoadAmount
			from prd.tblFormulasOverLoadDtl	D
				inner join prd.tblFormulasHdr H on (H.ProductID = D.ProductID) and (D.SerialNo = H.SerialNo) and (H.IsDefault = 1)
			where  (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))   And ' + @StrWhere + '
		) P	PIVOT 
		(
			Sum(P.OverLoadAmount)
			for P.OverLoadAcntCode In (' + @colsD + ')
		) AS PVT 
	) X 
	--inner join inv.tblGoodsDtl G on G.GoodsID = X.[کد محصول]
	order by [کد محصول] '

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	-- enlist amount
	---------------------------------------------------------------------------
END
GO
