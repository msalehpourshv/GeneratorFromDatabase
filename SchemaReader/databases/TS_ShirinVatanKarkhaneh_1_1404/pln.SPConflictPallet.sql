USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/02/09
-- Viewed By	 : 
-- Last Modified : 
-- Description   : گزارش مغایرت وزن کشی در پالت
-- =============================================
Create PROCEDURE pln.SPConflictPallet
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin
DECLARE @StrSelect				NVarChar(max)
DECLARE @StrWhere				NVarChar(max)
DECLARE @ProductID				NVarChar(2000)
DECLARE @TaskSerialNoFR			int
DECLARE @TaskSerialNoTO			int
DECLARE @TaskFiscalYearFR		int
DECLARE @TaskFiscalYearTO		int

DECLARE @ProduceSerialNoFR		int
DECLARE @ProduceSerialNoTO		int
DECLARE @ProduceFiscalYearFR	int
DECLARE @ProduceFiscalYearTO	int

DECLARE @FromDate				varchar(10)
DECLARE @ToDate					varchar(10)
      
Declare @Part as tinyint=1
select @Part=[acc].[FunGetAcntInfoForRemain](1)

		SET @ProductID				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 

		SET @TaskFiscalYearFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @TaskSerialNoFR			= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @TaskFiscalYearTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @TaskSerialNoTO			= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		
		SET @ProduceFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
		SET @ProduceSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @ProduceFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @ProduceSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 

		SET @FromDate				= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
		SET @ToDate					= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
		
		set @StrWhere = ' 1=1 '
		
		if @ProductID<>''
				set @StrWhere =@StrWhere+ @ProductID

		if @TaskFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND t.FiscalYear>=' +str(@TaskFiscalYearFR)
		if @TaskSerialNoFR>0
			set @StrWhere = @StrWhere+' AND t.SerialNo  >=' +str(@TaskSerialNoFR)
		if @TaskFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND t.FiscalYear<=' +str(@TaskFiscalYearTO)
		if @TaskSerialNoTO>0
			set @StrWhere = @StrWhere+' AND t.SerialNo	<=' +str(@TaskSerialNoTO)

		if @ProduceFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND t.BaseFiscalYear>=' +str(@ProduceFiscalYearFR)
		if @ProduceSerialNoFR>0
			set @StrWhere = @StrWhere+' AND t.BaseSerialNo  >=' +str(@ProduceSerialNoFR)
		if @ProduceFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND t.BaseFiscalYear<=' +str(@ProduceFiscalYearTO)
		if @ProduceSerialNoTO>0
			set @StrWhere = @StrWhere+' AND t.BaseSerialNo	<=' +str(@ProduceSerialNoTO)

		if @FromDate<>''
				set @StrWhere = @StrWhere+' AND d.DocDate >=''' +@FromDate + ''''
		if @ToDate<>''
				set @StrWhere = @StrWhere+' AND d.DocDate <=''' +@ToDate + ''''	 
		set @StrSelect ='
					select t.BaseProcessID	ProdProcessID,t.BaseProcessNo ProdProcessNo,t.BaseFiscalYear ProdFiscalYear,t.BaseSerialNo ProdSerialNo,t.BaseDocRowNo ProdDocRowNo2,t.ProdDocRowNo					
					,d.BaseProcessID,d.BaseProcessNo,d.BaseFiscalYear,d.BaseSerialNo,d.BaseDocRowNo,d.GoodsID, pub.GetGoodsName(d.GoodsID,1)   GoodsName,NumberPerContainer
					,ContainerID, ContainerWeight
					,GoodsWeight*NumberPerContainer/1000   QtyWeight,  ContainerWeight-GoodsWeight*NumberPerContainer/1000 ConflictWeight, d.DocDate
					, case when NumberPerContainer =0 then 0  else  Cast(ContainerWeight/NumberPerContainer*1000 as int) end NumberGoodsWeight,GoodsWeight
					from inv.tblStorageDocsSerials s
					inner join inv.tblStorageDocsDtl d on d.ProcessID=72  and  s.ProcessID=d.ProcessID  and s.ProcessNo=d.ProcessNo and s.FiscalYear=d.FiscalYear and s.SerialNo=d.SerialNo   and s.DocRowNo=d.DocRowNo
					inner join inv.tblGoods g on  g.GoodsID=d.GoodsID
					inner join pln.tblTaskOrderHdr t on d.BaseProcessID=t.ProcessID And d.BaseProcessNo=t.ProcessNo And d.BaseFiscalYear=t.FiscalYear And d.BaseSerialNo=t.SerialNo --And d.BaseDocRowNo=t.DocRowNo  And d.GoodsID=t.ProductID 
					'

		set @StrSelect =  @StrSelect  +' where  '+@StrWhere
	
	Print @StrSelect	 
	EXEC sp_executesql @StrSelect;

end 
GO
