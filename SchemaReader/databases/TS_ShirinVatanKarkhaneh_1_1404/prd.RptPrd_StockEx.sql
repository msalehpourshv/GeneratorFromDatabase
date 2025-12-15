USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : HamidReza Soltani
-- Create date   : 1389/09/02
-- Viewed By	 : Ahmad Nejad
-- Last Modified : 1389/09/03
-- Last Modifier : HamidReza Soltani
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_StockEx] 
	@SelectedGoods	int = Null,
	@SelectedStore	int = Null,
	@ToDate	char(10) = Null,
	@RepOptions		varchar(10) = '1111',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect	nvarchar(4000);
DECLARE	@StrFrom	nvarchar(4000);
DECLARE	@StrWhereGoods	nvarchar(4000);
DECLARE	@StrWhereStore	nvarchar(4000);

DECLARE	@LangID		char(1);
DECLARE	@SessionNo	int; 
DECLARE	@ReportID	int; 
DECLARE @WhitOutPrice	Bit;  -- احتساب کالای بدون قیمت
DECLARE @WhitOutBalance	Bit;  -- احتساب کالای بدون موجودی
DECLARE @PEffected	Bit;  -- مجوز خروج از انبار

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedStore	Is Null)	set @SelectedStore = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @StrWhereGoods = '(1=1)';
	SET @StrWhereStore = '(1=1)';
	SET @WhitOutPrice = SubString(@RepOptions ,1,1)
	SET @WhitOutBalance = SubString(@RepOptions ,2,1)
	SET @PEffected = SubString(@RepOptions ,3,1)

	if (@SelectedGoods > 0)
		SET @StrWhereGoods = @StrWhereGoods + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'G.GoodsID')
	if (@SelectedStore > 0)
		SET @StrWhereStore = @StrWhereStore + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID')

	if (@ToDate Is Not Null)
			SET @StrWhereStore = @StrWhereStore + ' AND D.DocDate <= ''' + @ToDate + ''''

	if (@WhitOutPrice = 0)
		SET @StrWhereStore = @StrWhereStore + ' And D.GoodsPrice > 0'

	if (@PEffected = 0)
		SET @StrWhereStore = @StrWhereStore + ' And D.PhysicallyEffected <> 0'

	SET @StrSelect = '
	SELECT G.GoodsID, [pub].[funGetGoodsName](G.GoodsID, ' + Ltrim(RTrim(@LangID)) + ') As GoodsName, IsNull(GS.SetPoint, 0) As SetPoint,
			IsNull((
				select Sum(GoodsQuantity * EnterKind)
				from inv.tblStorageDocsDtl D
				where (D.GoodsID = G.GoodsID) and (' + @StrWhereStore + ')
			), 0) as Balance, 
			IsNull((
				select Sum(GoodsQuantity * EnterKind)
				from inv.tblStorageDocsDtl D
				where D.GoodsID in 
					(
						select Goods2ID
						from inv.tblGoodsRelation R
						where (RelationType = 1) And (R.Goods1ID = G.GoodsID) 
					) and (' + @StrWhereStore + ')
			), 0) as StepBalance,
			IsNull(P.ProductCount, 0) as ProduceBalance
	FROM inv.tblGoods G
		left join 
		(
			-- in produce products list	
			select ProductID, sum(ProductCount) as ProductCount
			from inv.tblStorageDocsHdr H
				INNER JOIN 
				(
					select	ProcessNo, FiscalYear, SerialNo
					from	inv.tblStorageDocsHdr
					where	ProcessID = 70
					except
					select	BaseProcessNo, BaseFiscalYear, BaseSerialNo
					from	inv.tblStorageDocsHdr
					where	ProcessID = 80 
				) R ON H.ProcessNo = R.ProcessNo AND H.FiscalYear = R.FiscalYear AND H.SerialNo = R.SerialNo
			where H.ProcessID = 70 	
			group by ProductID
		) P on P.ProductID = G.GoodsID
	LEFT JOIN inv.tblGoodsStatusDtl GS ON GS.GoodsID = G.GoodsID
	WHERE ' + @StrWhereGoods

	
	if (@WhitOutBalance = 0)
		SET @StrSelect = '
		Select * 
		From (' + @StrSelect + ') T 
		Where (T.Balance + T.ProduceBalance + T.StepBalance) > 0'

	SET @StrSelect = @StrSelect + 'Order By GoodsID'

	print @StrSelect;
	Exec sp_executesql @StrSelect;
	
END;
GO
