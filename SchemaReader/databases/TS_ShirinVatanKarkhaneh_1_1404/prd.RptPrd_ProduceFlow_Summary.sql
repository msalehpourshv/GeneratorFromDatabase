USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1393/04/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_ProduceFlow_Summary]
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedProds	Int = 0,
	@SelectedGroup	Int = 0,
	@SelectedStore	Int = 0,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@RepOptions		varchar(10) = '1',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @RemianOnly	bit

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @UnitPart	TINYINT

BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '1';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;
	
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
	
	---------------------------------------------------------------------------
	
	set @RemianOnly	= Substring(@RepOptions, 1, 1);
	
	-- where section ----------------------------------------------------------
	set @StrWhere = '(D.ProcessID=80 and H.ProcessID=70)';
	set @StrFrom = ''
	
	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))';
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))';

	--if (@SelectedGroup > 0)
		--set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGroup, 'G.GoodsGroupID') 

	if (@SelectedProds > 0) 
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedProds, 'D.GoodsID')
		
	if (@SelectedStore > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	IF (@DocDateFr is not null) 
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + @DocDateFr + ''')';
	IF (@DocDateTo is not null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DocDateTo + ''')';

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')

print @RemianOnly
	if (@RemianOnly=1)
	begin
		select *
		into #tbl_Prd_ProduceFlow_Quantities
		from
		(
			select	H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, 
					H.ProductCount RequestedQuantity, 
					isnull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where D.ProcessID=80 
							and D.BaseProcessID=H.ProcessID 
							and D.BaseProcessNo=H.ProcessNo 
							and D.BaseFiscalYear =H.FiscalYear
							and D.BaseSerialNo=H.SerialNo
					),0) ReceivedQuantity
			from inv.tblStorageDocsHdr H
			where ProcessID = 70
		) T
		where T.RequestedQuantity > T.ReceivedQuantity
		
		set @StrFrom = @StrFrom + ' Inner Join #tbl_Prd_ProduceFlow_Quantities Q on Q.ProcessID=H.ProcessID and Q.ProcessNo=H.ProcessNo and Q.FiscalYear=H.FiscalYear and Q.SerialNo=H.SerialNo'
	end

	---------------------------------------------------------------------------
	set @StrSelect = '
	Select		H.AcntCode,pub.GetCodeName(H.AcntCode,' + @LangID + ') AS AcntCodeName,D.GoodsID As ProductID, G.GoodsName As ProductName,
			(Select COUNT(*) From prd.tblFormulasHdr Where ProductID = D.GoodsID) As FormulaCount,
			FH.SerialNo, FH.IsDefault, FH.BatchSize, 
			Sum(H.ProductCount) As ProductCountSum, Sum(D.GoodsQuantity) As GoodsQuantitySum
	From inv.tblStorageDocsDtl D
	INNER JOIN inv.tblStorageDocsHdr H on H.ProcessID = D.BaseProcessID And H.ProcessNo=D.BaseProcessNo And 
									      H.FiscalYear=D.BaseFiscalYear And H.SerialNo=D.BaseSerialNo
	
	INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ') AND G.PartNumber=' + LTRIM(STR(@UnitPart)) + '
	INNER JOIN prd.tblFormulasHdr FH ON FH.ProductID = D.GoodsID and  FH.SerialNo= H.FormulaNo
	Where ' + @StrWhere + '
	Group By 	H.AcntCode,D.GoodsID, G.GoodsName, FH.SerialNo, FH.IsDefault, FH.BatchSize
    --Order By H.DocDate, H.FiscalYear, H.SerialNo, D.DocDate, D.SerialNo'
	
	---------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	---------------------------------------------------------
END
GO
