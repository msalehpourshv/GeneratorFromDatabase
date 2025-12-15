USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/10/11
-- Viewed By	 : 
-- Last Modified : 1392/10/21
-- Last Modifier : TakroSystem\Hamid
-- Description   : <لیست انحرافات تولید نسبت به فرمول تولید>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_ProduceVariance_SimilarGoods_Sum]
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

DECLARE	@Round		Int;

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'
	---------------------------------------------------------------------------
	
	-- SELECT SECTION -------------------------------
	create table #tbl_Prd_ProduceVariance_TotalSum
	(
		FiscalYear		int	not null,
		SerialNo		int	not null,
		ProductID		varchar(20) collate arabic_cs_as not null,
		FormulaNo		int	not null,
		GoodsID			varchar(20)	collate arabic_cs_as not null,
		ProdQuantity	float	not null,
		SentQuantity	float	not null,
		FormulaQuantity	float	not null,
		BaseFiscalYear	smallint not null,
		BaseSerialNo	int not null,
		DocDate			char(10) not null,
		GoodsAmount		float	not null,
		GoodsName		nvarchar(120) not null,
		ProductName		nvarchar(120) not null,
		UnitName		NVarchar(50),
		ProductUnitName	NVarchar(50),
		BatchNo			varchar(20) collate arabic_cs_as not null
	);
		 

	insert into #tbl_Prd_ProduceVariance_TotalSum(FiscalYear, SerialNo, ProductID, FormulaNo, GoodsID, ProdQuantity, SentQuantity, FormulaQuantity, BaseFiscalYear, BaseSerialNo, DocDate,GoodsAmount,GoodsName, ProductName, UnitName, ProductUnitName,BatchNo)

	exec [prd].[RptPrd_ProduceVariance_SimilarGoods] @FiscalYearFr,@FiscalYearTo,@SerialNoFr,@SerialNoTo,@DocDateFr,@DocDateTo,@SelectedProds,@SelectedGoods,@SelectedAcnt1,@SelectedAcnt2,@SelectedAcnt3,@SelectedAcnt4,Null,Null,@RepOptions,@RepInfo

	select ProductID, sum(ProdQuantity) ProdQuantity
	into #tbl_Prd_ProduceVariance_Prods
	from
	(
		select FiscalYear, SerialNo, ProductID, sum(ProdQuantity) ProdQuantity
		from #tbl_Prd_ProduceVariance_TotalSum	
		group by FiscalYear, SerialNo, ProductID
	) T
	group by T.ProductID

	Select D.ProductID, D.ProductName, P.ProdQuantity, D.GoodsID, D.GoodsName,
		SUM(SentQuantity) SentQuantity,	SUM(FormulaQuantity) FormulaQuantity
	From #tbl_Prd_ProduceVariance_TotalSum	D
		inner join #tbl_Prd_ProduceVariance_Prods P on P.ProductID = D.ProductID
	Group By D.ProductID, D.ProductName, P.ProdQuantity, D.GoodsID, D.GoodsName
	Having round(SUM(SentQuantity) - SUM(FormulaQuantity), @Round) <> 0
	Order By D.ProductID, D.GoodsID
	
END
GO
