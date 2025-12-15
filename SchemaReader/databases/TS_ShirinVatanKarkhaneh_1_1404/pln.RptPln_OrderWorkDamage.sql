USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		 : jafari	
-- Create date	 : 1401/06/24
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
Create PROCEDURE pln.RptPln_OrderWorkDamage
	@FiscalYear		Int = 0,
	@SerialNo		Int = 0,
	@FiscalYearTo		Int = 0,
	@SerialNoTo		Int = 0,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	Nvarchar(4000);
DECLARE @StrWhere	Nvarchar(4000);

DECLARE	@LangID		NvarChar(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;

BEGIN
	SET NOCOUNT ON;

	-- ---------------------------------------------------------------------------------
	IF @RepInfo IS NULL SET @RepInfo = '1@1@1'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- ---------------------------------------------------------------------------------

	select FiscalYear,SerialNo , GoodsQuantity 
	Into #TblGoodsQuantity
	from inv.tblStorageDocsDtl S
	where 1=0
 
 	select FiscalYear,SerialNo , GoodsQuantity ProductCount
	Into #TblProductCount
	from inv.tblStorageDocsDtl S
	where 1=0

	--select @OrderCount=OrderCount from pln.tblTaskOrderHdr where SerialNo>=@SerialNo and FiscalYear>=@FiscalYear and SerialNo<=@SerialNoTo and FiscalYear<=@FiscalYearTo
	insert into #TblGoodsQuantity
	select  T.FiscalYear,T.SerialNo,Sum(GoodsQuantity)
	from pln.tblTaskOrderHdr T
	inner join inv.tblStorageDocsDtl S on T.ProcessID=S.BaseProcessID and T.ProcessNo=S.BaseProcessNo and T.FiscalYear=S.BaseFiscalYear and T.SerialNo =S.BaseSerialNo
	where T.SerialNo>=@SerialNo and T.FiscalYear>=@FiscalYear 
	 and T.SerialNo<=@SerialNoTo and T.FiscalYear<=@FiscalYearTo and S.ProcessID in (72,73 )
	and T.ProductID<>S.GoodsID
	Group by T.FiscalYear,T.SerialNo

	insert into #TblProductCount
	select t.FiscalYear,t.SerialNo,ProductCount
	from prd.tblFormulasHdr d 
	inner join pln.tblTaskOrderHdr t
	on d.ProductID=t.ProductID and d.SerialNo=t.FormulaNo
	where t.SerialNo>=@SerialNo and t.FiscalYear>=@FiscalYear
	 and t.SerialNo<=@SerialNoTo and t.FiscalYear<=@FiscalYearTo

 	select FiscalYear,SerialNo , S.GoodsID,pub.GetGoodsName(S.GoodsID,1)GoodsName ,SubUnitID  , inv.funGetUnitName (SubUnitID  ,1)UnitName, GoodsQuantity,  GoodsQuantity QtyFormula, GoodsAmount , GoodsAmount Price,LoseGroupID
	Into #TblOrderWorkUseGoods
	from inv.tblStorageDocsDtl S
	where 1=0
 

	insert into #TblOrderWorkUseGoods

	select T.FiscalYear,T.SerialNo ,  S.GoodsID,pub.GetGoodsName(S.GoodsID,1)GoodsName ,(Select UnitID from inv.tblGoods G where G.GoodsID =S.GoodsID)  ,''-- , inv.funGetUnitName (SubUnitID  ,1)UnitName
	,Sum(GoodsQuantity),0 ,GoodsAmount, GoodsAmount*SubUnitQuantity,Max( LoseGroupID)
	from pln.tblTaskOrderHdr T
	inner join inv.tblStorageDocsDtl S on T.ProcessID=S.BaseProcessID and T.ProcessNo=S.BaseProcessNo and T.FiscalYear=S.BaseFiscalYear and T.SerialNo =S.BaseSerialNo	
	where T.SerialNo>=@SerialNo  and T.FiscalYear>=@FiscalYear  
	 and T.SerialNo<=@SerialNoTo and T.FiscalYear<=@FiscalYearTo and S.ProcessID in  (72,73 )
	and T.ProductID<>S.GoodsID

	Group by  S.GoodsID, GoodsAmount,GoodsAmount*SubUnitQuantity,T.FiscalYear,T.SerialNo 
		 	
	 update #TblOrderWorkUseGoods
	 set UnitName=inv.funGetUnitName (SubUnitID  ,1) ,
	 QtyFormula= d.GoodsQuantity*q.GoodsQuantity/p.ProductCount
	 from #TblOrderWorkUseGoods a
	 inner join prd.tblSecondaryProductByFormulaDtl d  on a.GoodsID=d.GoodsID
	 inner join pln.tblTaskOrderHdr t	on d.ProductID=t.ProductID and d.SerialNo=t.FormulaNo
	 inner join #TblProductCount  p on p.FiscalYear=a.FiscalYear  and p.SerialNo=a.SerialNo
	 inner join #TblGoodsQuantity q on q.FiscalYear=a.FiscalYear  and q.SerialNo=a.SerialNo

	where t.SerialNo>=@SerialNo and t.FiscalYear>=@FiscalYear
	 and t.SerialNo<=@SerialNoTo and t.FiscalYear<=@FiscalYearTo
	
	select t.*, l.LoseGroupName from #TblOrderWorkUseGoods  t
	left join pln.tblLoseGroupDtl l on t.LoseGroupID=l.LoseGroupID
	order by t.FiscalYear,t.SerialNo , GoodsID 
	 
END
GO
