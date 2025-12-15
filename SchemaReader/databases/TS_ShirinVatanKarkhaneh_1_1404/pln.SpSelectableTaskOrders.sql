USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 
-- ==============================================
create PROCEDURE [pln].[SpSelectableTaskOrders]
@LanguageID Smallint=1,
	@PartNumber Smallint,
	@PartNumber1 Smallint,
	@PartNumber2 Smallint,
	@PartNumber3 Smallint,
	@GoodsIDLen smallint,
	@FromSerialNo as int,
	@ToSerialNo as int,
	@part2 as int,
	@part3 as int,
	@part4 as int,
	@GoodsID2 as int,
	@FromOrderSerialNo as int,
	@ToOrderSerialNo as int 
   
WITH ENCRYPTION
AS

BEGIN
declare  @strSelect as NVarchar(4000)
declare  @strWhere as NVarchar(4000)
declare  @strWhere2 as NVarchar(4000)=''


set @strWhere ='AND 1=1'

if @FromSerialNo<>0 
set @strWhere = @strWhere + ' AND  TH.SerialNo >= '+CAST( @FromSerialNo as varchar(20))  


if @ToSerialNo<>0 
set @strWhere = @strWhere + ' AND  TH.SerialNo <= '+CAST( @ToSerialNo as varchar(20)) 

if @FromOrderSerialNo<>0 
 set @strWhere = @strWhere + ' AND  PO.SerialNo >= '+CAST( @FromOrderSerialNo as varchar(20)) 

if @ToOrderSerialNo<>0 
 set @strWhere = @strWhere + ' AND  PO.SerialNo <= '+CAST( @ToOrderSerialNo as varchar(20)) 
  
set @strSelect=
   'select * from  (select TH.SerialNo,TH.ProductQuantity2, TH.OrderCount ,TH.DocDate , substring(cast(TH.ProductID as varchar(20)),0,'+cast(@GoodsIDLen as varchar(5))+')ProductID ,TH.FiscalYear
, [inv].[FunGoods_PartInfo]  (IsNull('+cast(@PartNumber3 as varchar(20))+',0),TH.ProductID ) part2,
						  [inv].[FunGoods_PartInfo]  (IsNull('+cast(@PartNumber2 as varchar(20))+' ,0),TH.ProductID ) part3,
						  [inv].[FunGoods_PartInfo]  (IsNull('+cast(@PartNumber1 as varchar(20))+' ,0),TH.ProductID ) part4,
						   right(TH.ProductID ,2) GoodsID2,
						   isnull((select SUM(isnull(ProductCount,0))  from pln.tblTaskOrderDtl where  SerialNo = TH.SerialNo
and ProcessID = TH.ProcessID and  ProcessNo = TH.ProcessNo and FiscalYear = TH.FiscalYear ),0) SumProductCount
 from pln.tblTaskOrderHdr  TH
 left  join pln.tblItemRelations R on TH.ProcessID = R.ProcessID and TH.FiscalYear = R.FiscalYear 
 and TH.SerialNo=R.SerialNo  inner join pln.tblProduceOrderHdr PO on R.BaseProcessID = PO.ProcessID  
 and R.BaseSerialNo = PO.SerialNo and R.FiscalYear = PO.FiscalYear  where  R.ProcessID = 610 and PO.BaseProcessID = 240
 ' + @strWhere + ' )a 
 where 1=1  And (part2='+ cast(@part2 as varchar(10))+ ' or '+ cast(@part2 as varchar(10)) +'= 0 )
            And (part3='+ cast(@part3 as varchar(10))+ ' or '+ cast(@part3 as varchar(10)) +'= 0 )
            And (part4='+ cast(@part4 as varchar(10))+ ' or '+ cast(@part4 as varchar(10)) +'= 0 )
            And (GoodsID2='+ cast(@GoodsID2 as varchar(10))+ ' or '+ cast(@GoodsID2 as varchar(10)) +'= 0 ) 
            And ProductQuantity2 > SumProductCount' 
 
-- SET @strSelect= @strSelect + @strWhere 
 
SET @strSelect=@strSelect + ' ORDER BY SerialNo'
   print @strSelect
	Exec sp_executesql @strSelect;
END
GO
