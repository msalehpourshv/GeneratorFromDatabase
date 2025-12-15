USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/10/07
-- Viewed By	 : 
-- Last Modified : 1390/02/11
-- Last Modifier : TakroSystem\Zia
-- Description   : <سربار محصولات>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_ProductOverlodsEx2]
	@SelectedProds	Int = 0,
	@DateFr			char(10) = '0000/00/00',  -- bit array options
	@DateTo			char(10) = '9999/00/00',  -- bit array options
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
DECLARE	@ShowStats	bit;

DECLARE @UnitPart	TINYINT

BEGIN

	SET NOCOUNT ON;

	--================================== UnitPart
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	--==================================
	
	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '0';
	if (@SelectedProds	Is Null)	set @SelectedProds = 0;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @ShowStats	= 0;
	set @ShowStats	= Substring(@RepOptions, 1, 1);
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
	select ' + @colsD + ', 
			sum(GoodsQuantity) as [تعداد کل], 
			sum(GoodsQuantity * GoodsAmount) as [مبلغ کل], 
			ProductID as [کد محصول], 
			G.GoodsName as [نام محصول]
	from
	(
		select ' + @colsD + ', ProductID
		from 
		(
			select D.ProductID, OverLoadAcntCode, OverLoadAmount
			from prd.tblFormulasOverLoadDtl	D
				inner join prd.tblFormulasHdr H on (H.ProductID = D.ProductID) and (D.SerialNo = H.SerialNo) and (H.IsDefault = 1)
			where (D.OverLoadProductDtl=1 or (D.OverLoadProductDtl=0 and D.OverLoadDecompositionDtl=0))   And ' + @StrWhere + '
		) P	PIVOT 
		(
			Sum(P.OverLoadAmount)
			for P.OverLoadAcntCode In (' + @colsD + ')
		) AS PVT 
	) X 
	INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(X.ProductID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '
	left  join inv.tblStorageDocsDtl D on D.GoodsID = X.ProductID  
	where (D.ProcessID = 80) and (D.DocDate >= ''' + @DateFr + ''') and (D.DocDate <= ''' + @DateTo + ''') 
	group by ' + @colsD + ', ProductID, GoodsName
	order by X.ProductID '

	print @StrSelect;
	exec sp_executesql @StrSelect;

	---------------------------------------------------------------------------
END
GO
