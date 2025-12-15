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
Create PROCEDURE pln.RptPln_OrderWorkUseGoods
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
 
 	select ProcessID,ProcessNo, DocDate, S.GoodsID ProductID,SerialNo  FormulaNo,FiscalYear,SerialNo ,S.GoodsID,'' GoodsName ,SubUnitID  , '' UnitName, GoodsQuantity,  GoodsQuantity QtyFormula, GoodsAmount , GoodsAmount Price, GoodsAmount GoodsAmount2, GoodsAmount Price2
	Into #TblOrderWorkUseGoods
	from inv.tblStorageDocsDtl S
	where 1=0
	
	insert into #TblOrderWorkUseGoods
	select S.ProcessID,S.ProcessNo, S.DocDate, T.ProductID,T.FormulaNo,T.FiscalYear,T.SerialNo ,S.GoodsID,'' GoodsName ,(Select UnitID from inv.tblGoods G where G.GoodsID =S.GoodsID)  ,''
	,Sum(GoodsQuantity),0 ,GoodsAmount, GoodsAmount*SubUnitQuantity,0,0
	from pln.tblTaskOrderHdr T
	inner join inv.tblStorageDocsDtl S 
	on T.ProcessID=S.BaseProcessID and T.ProcessNo=S.BaseProcessNo and T.FiscalYear=S.BaseFiscalYear and T.SerialNo =S.BaseSerialNo	
	where T.SerialNo>=@SerialNo and T.FiscalYear>=@FiscalYear 
	 and T.SerialNo<=@SerialNoTo and T.FiscalYear<=@FiscalYearTo  and S.ProcessID in  (82,83)
	Group by  S.ProcessID,S.ProcessNo, S.DocDate,T.ProductID,T.FormulaNo,S.GoodsID, GoodsAmount,GoodsAmount*SubUnitQuantity,T.FiscalYear,T.SerialNo 
	select Sum(S2.GoodsQuantity)ProdQuantity, S2.GoodsID ProductID, Sum(S1.GoodsQuantity)GoodsQuantity, S1.GoodsID, S1.GoodsAmount,S1.DocDate
			,S1.BaseProcessID,S1.BaseProcessNo,S1.BaseFiscalYear,S1.BaseSerialNo--,S1.BaseDocRowNo
			Into #TblGoodsQuantity2
	from inv.tblStorageDocsDtl  S1
	inner join inv.tblStorageDocsDtl  S2	on S1.BaseProcessID=S2.BaseProcessID and S1.BaseProcessNo=S2.BaseProcessNo and S1.BaseFiscalYear=S2.BaseFiscalYear 	and S1.BaseSerialNo=S2.BaseSerialNo  and S1.BaseDocRowNo=S2.BaseDocRowNo
	 and S2.ProcessID in (72,73)
	where  
	S1.BaseSerialNo>=@SerialNo and S1.BaseFiscalYear>=@FiscalYear 
	 and S1.BaseSerialNo<=@SerialNoTo and S1.BaseFiscalYear<=@FiscalYearTo
	 and S1.ProcessID in (82,83)
	Group by S1.GoodsID, S2.GoodsID , S1.GoodsAmount,S1.DocDate,S1.BaseProcessID,S1.BaseProcessNo,S1.BaseFiscalYear,S1.BaseSerialNo
	order by S1.GoodsID

 	 update #TblOrderWorkUseGoods
	 set QtyFormula= d.GoodsQuantity*p.ProdQuantity/h.ProductCount
	 from #TblOrderWorkUseGoods a
	 inner join #TblGoodsQuantity2 p on  a.ProductID=p.ProductID and a.GoodsID=p.GoodsID and a.SerialNo=p.BaseSerialNo  and a.FiscalYear=p.BaseFiscalYear and a.GoodsQuantity=p.GoodsQuantity
	 inner join prd.tblFormulasDtl d  on a.GoodsID=d.GoodsID and  a.ProductID=d.ProductID
	 inner join prd.tblFormulasHdr h on h.ProductID=d.ProductID and d.SerialNo=h.SerialNo and d.SerialNo=a.FormulaNo
	 
 	 --------- برای نمایش کالا هایی که در فرمول موجود ولی در تولید استفاده شده است  ----------------------------------------------------------------------------------------------
	insert into #TblOrderWorkUseGoods(ProcessID,ProcessNo, DocDate, ProductID,FormulaNo, SerialNo	,GoodsID,	SubUnitID, FiscalYear,GoodsName , UnitName, GoodsQuantity,  QtyFormula, GoodsAmount , Price, GoodsAmount2 , Price2)
	select Distinct 0,0,'',f.ProductID,FormulaNo, 0	,f.GoodsID,	f.UnitID,0,'',  '',0,0,0,0,0,0 from 	prd.tblFormulasDtl f 
		inner join #TblOrderWorkUseGoods p
		on f.ProductID=p.ProductID
		and f.SerialNo=p.FormulaNo
	except		
	select Distinct 0,0,'',ProductID, FormulaNo,0,GoodsID,	SubUnitID,0,'',  '',0,0,0,0 ,0,0	 from #TblOrderWorkUseGoods
	
	update #TblOrderWorkUseGoods
	set QtyFormula=f.GoodsQuantity
	from 	#TblOrderWorkUseGoods p
		inner join prd.tblFormulasDtl f 
		on f.ProductID=p.ProductID
		and f.SerialNo=p.FormulaNo
	where FiscalYear=0
	 
	update #TblOrderWorkUseGoods
	set FiscalYear= (select  top 1 FiscalYear from #TblOrderWorkUseGoods where FiscalYear<>0)
	, SerialNo= (select  top 1 SerialNo from #TblOrderWorkUseGoods where SerialNo<>0)
	where FiscalYear=0
	 -------------------------------------------------------------------------------------------------------
	 if (Select Count(*) from #TblOrderWorkUseGoods  where GoodsAmount=0	)>0
	 begin	 		
		Update #TblOrderWorkUseGoods 
			set GoodsAmount=isnull((select top 1 isnull(GoodsAmount,0) from inv.tblStorageDocsDtl S 	where S.GoodsID= #TblOrderWorkUseGoods.GoodsID	and GoodsAmount<>0	order by DocDate desc ),0)
			where GoodsAmount=0		
	 end

	 update #TblOrderWorkUseGoods 	 	 
	 set QtyFormula=	 
		 (isnull(( Select Sum(p2.AcceptableCount+p2.UnacceptableCount) 
		 from pln.tblTaskOrderHdr p1 
		 inner join pln.tblTaskOrderDtl p2 on  p1.SerialNo=p2.SerialNo  and p1.FiscalYear=p2.FiscalYear 
		 where a.ProductID=p1.ProductID and a.SerialNo=p1.SerialNo  and a.FiscalYear=p1.FiscalYear 
		 ),0 ) *d.GoodsQuantity/h.ProductCount)--, a.* 
		 --select  Sum(p2.AcceptableCount+p2.UnacceptableCount) *d.GoodsQuantity/h.ProductCount--, a.* 
	 from #TblOrderWorkUseGoods a	 
	 inner join prd.tblFormulasDtl d  on a.GoodsID=d.GoodsID and  a.ProductID=d.ProductID
	 inner join prd.tblFormulasHdr h on h.ProductID=d.ProductID and d.SerialNo=h.SerialNo and d.SerialNo=a.FormulaNo
	where a.GoodsQuantity=0

	Update #TblOrderWorkUseGoods
	set ProcessID=b.ProcessID,ProcessNo=b.ProcessNo,DocDate=b.DocDate--,StoreID=b.StoreID
	from  #TblOrderWorkUseGoods a
	inner join (select * from  #TblOrderWorkUseGoods ) b 
	on a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and b.ProcessID<>0
	where a.ProcessID=0

	 update #TblOrderWorkUseGoods
	 set GoodsAmount2=[inv].[funGetLastPrice](	0,	0,	0,	GoodsID	,	''	,	DocDate	) 	 
	 where GoodsQuantity=0

	select  t.FiscalYear,t.SerialNo ,t.GoodsID,pub.GetGoodsName(t.GoodsID,1) GoodsName,SubUnitID	,inv.funGetUnitName (t.SubUnitID  ,1) UnitName 	, Sum(GoodsQuantity) GoodsQuantity	, Sum(QtyFormula)   QtyFormula
	,case when Sum(GoodsQuantity)=0 then SUm(QtyFormula*GoodsAmount2)/Sum(QtyFormula)*-1  else  SUm(GoodsQuantity*GoodsAmount)/Sum(GoodsQuantity) end  GoodsAmount
	,case when Sum(GoodsQuantity)=0 then SUm(QtyFormula*GoodsAmount2)*-1  else SUm(GoodsQuantity*GoodsAmount) end Price 	
	,GoodsWeight,PureWeight,ExtraField1	,ExtraField2	,ExtraField3	,ExtraField4	,ExtraField5	,ExtraField6	,ExtraField7	,ExtraField8	,ExtraField9	,ExtraField10	,ExtraField11	,ExtraField12	,ExtraField13	,ExtraField14	,ExtraField15	,ExtraField16	,ExtraField17	,ExtraField18	,ExtraField19	,ExtraField20
	 from #TblOrderWorkUseGoods  t	
	 inner join inv.tblGoods G on t.GoodsID=G.GoodsID
	group by t.FiscalYear,t.SerialNo ,t.GoodsID,GoodsName,SubUnitID	,UnitName
	,GoodsWeight,PureWeight,ExtraField1	,ExtraField2	,ExtraField3	,ExtraField4	,ExtraField5	,ExtraField6	,ExtraField7	,ExtraField8	,ExtraField9	,ExtraField10	,ExtraField11	,ExtraField12	,ExtraField13	,ExtraField14	,ExtraField15	,ExtraField16	,ExtraField17	,ExtraField18	,ExtraField19	,ExtraField20
	order by t.FiscalYear,t.SerialNo , t.GoodsID 

END
GO
