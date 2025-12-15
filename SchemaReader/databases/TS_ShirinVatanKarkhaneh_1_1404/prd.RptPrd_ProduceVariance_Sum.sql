USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [prd].[RptPrd_ProduceVariance_Sum]
	@FiscalYearFr	int = 0,
	@FiscalYearTo	int = 0,
	@SerialNoFr		int = 0,
	@SerialNoTo		int = 0,
	@DocDateFr		char(10) = null,
	@DocDateTo		char(10) = null,
	@SelectedProds	int = 0,
	@SelectedGoods	int = 0,
	@SelectedAcnt1	int = 0,
	@SelectedAcnt2	int = 0,
	@SelectedAcnt3	int = 0,
	@SelectedAcnt4	int = 0,
	@RepOptions		NVarChar(200) = '111',
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @ExtraParams	NVarChar(2000)
DECLARE	@GoodsID		Varchar(20) 

DECLARE	@Round		Int;

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'
	---------------------------------------------------------------------------
	set @ExtraParams=@RepOptions
	
	SET @RepOptions			= pub.funSplitString(@ExtraParams, '@', 1);
	SET @GoodsID			= pub.funSplitString(@ExtraParams, '@', 2);
		
	if @GoodsID=''
		set @GoodsID=null
	-- SELECT SECTION -------------------------------
	create table #tbl_Prd_ProduceVariance_Total
	(
		FiscalYear		int	not null,
		SerialNo		int	not null,
		ProductID		varchar(20) collate arabic_cs_as not null,
		FormulaNo		int	not null,
		GoodsID			varchar(20)	collate arabic_cs_as not null,
		SentQuantity	float	not null,
		FormulaQuantity	float	not null,
		Kind			int,
		BaseFiscalYear	smallint not null,
		BaseSerialNo	int not null,
		BaseDocRowNo	int not null,
		DocDate			char(10) not null,
		ProdQuantity	float	not null,
		GoodsAmount	    float	not null,
		ProductName		nvarchar(120) not null,
		GoodsName		nvarchar(120) not null,
		UnitName		NVarchar(50),
		ProductUnitName	NVarchar(50)
	);
	
	insert into #tbl_Prd_ProduceVariance_Total(FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, 
		SentQuantity, FormulaQuantity, Kind, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocDate, 
		ProdQuantity, GoodsAmount, ProductName, GoodsName, UnitName, ProductUnitName)
	exec [prd].[RptPrd_ProduceVariance] @FiscalYearFr,@FiscalYearTo,@SerialNoFr,@SerialNoTo,@DocDateFr,@DocDateTo,@SelectedProds,@SelectedGoods,@SelectedAcnt1,@SelectedAcnt2,@SelectedAcnt3,@SelectedAcnt4,Null,@GoodsID,@RepOptions,@RepInfo

	-- ==========================================================================
	select ProductID, sum(ProdQuantity) ProdQuantity
	into #tbl_Prd_ProduceVariance_Prods
	from
	(
		select FiscalYear, SerialNo, ProductID, sum(ProdQuantity) ProdQuantity
		from #tbl_Prd_ProduceVariance_Total	
		group by FiscalYear, SerialNo, ProductID
	) T
	group by T.ProductID

	-- ==========================================================================
	select D.ProductID, D.ProductName, P.ProdQuantity, D.GoodsID, D.GoodsName,
		SUM(SentQuantity) SentQuantity,	SUM(FormulaQuantity) FormulaQuantity
	from #tbl_Prd_ProduceVariance_Total	D
		inner join #tbl_Prd_ProduceVariance_Prods P on P.ProductID=D.ProductID
	group by D.ProductID, D.ProductName, P.ProdQuantity, D.GoodsID, D.GoodsName
	having round(SUM(SentQuantity) - SUM(FormulaQuantity), @Round) <> 0
	order by D.ProductID, D.GoodsID
	
END
GO
