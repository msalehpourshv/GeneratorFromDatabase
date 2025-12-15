USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 99/12/23
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE pln.SPTaskOrderReview 
@CallType Int, 
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

DECLARE @StrSelect		NVarChar(max)
DECLARE @StrWhere		NVarChar(max)
DECLARE @StrGoods		NVarChar(max)

DECLARE @TaskSerialNoFR			int
DECLARE @TaskSerialNoTO			int
DECLARE @TaskFiscalYearFR		int
DECLARE @TaskFiscalYearTO		int

DECLARE @ProduceSerialNoFR		int
DECLARE @ProduceSerialNoTO		int
DECLARE @ProduceFiscalYearFR	int
DECLARE @ProduceFiscalYearTO	int

DECLARE @SaleSerialNoFR			int
DECLARE @SaleSerialNoTO			int
DECLARE @SaleFiscalYearFR		int
DECLARE @SaleFiscalYearTO		int

DECLARE @PreSaleSerialNoFR		int
DECLARE @PreSaleSerialNoTO		int
DECLARE @PreSaleFiscalYearFR	int
DECLARE @PreSaleFiscalYearTO	int
DECLARE @ProcessNo1				int
DECLARE @ProcessNo2				int

DECLARE @AcntCode as varchar(20),
@GoodsID as varchar(20),
@StoreID as varchar(20),
@FromDate as varchar(10),
@ToDate as varchar(10),
@ShowOrder as integer
Declare @Part as tinyint=1
select @Part=[acc].[FunGetAcntInfoForRemain](1)

if @CallType=1
	begin
		SET @StrGoods		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
		SET @TaskFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
		SET @TaskSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
		SET @TaskFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
		SET @TaskSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
		
		SET @ProduceFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
		SET @ProduceSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
		SET @ProduceFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
		SET @ProduceSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 

		SET @SaleFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
		SET @SaleSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
		SET @SaleFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 12)); 
		SET @SaleSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 

		SET @PreSaleFiscalYearFR	= LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
		SET @PreSaleSerialNoFR		= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
		SET @PreSaleFiscalYearTO	= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 
		SET @PreSaleSerialNoTO		= LTrim(pub.funSplitString(@ExtraParams, '@', 17)); 
		SET @ProcessNo1			= LTrim(pub.funSplitString(@ExtraParams, '@', 18)); 
		SET @ProcessNo2			= LTrim(pub.funSplitString(@ExtraParams, '@', 19)); 
		

		set @StrWhere = ' 1=1 '
		if @StrGoods<>''
				set @StrWhere =@StrWhere+ @StrGoods
		if @AcntCode<>'' 
			set @StrWhere = @StrWhere+' AND D.AcntCode  =''' + @AcntCode + ''''		
		if @TaskFiscalYearFR=0 and @TaskFiscalYearTO=0 and @ProduceFiscalYearFR=0 and @ProduceFiscalYearTO=0 and @SaleFiscalYearFR=0 and @SaleFiscalYearTO=0 and @PreSaleFiscalYearFR=0 and @PreSaleFiscalYearTO=0
			set @StrWhere =@StrWhere+ ' AND PO.FiscalYear=' +  right (db_name(),4)

		if @TaskFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND TH.FiscalYear>=' +str(@TaskFiscalYearFR)
		if @TaskSerialNoFR>0
			set @StrWhere = @StrWhere+' AND TH.SerialNo  >=' +str(@TaskSerialNoFR)
		if @TaskFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND TH.FiscalYear<=' +str(@TaskFiscalYearTO)
		if @TaskSerialNoTO>0
			set @StrWhere = @StrWhere+' AND TH.SerialNo	<=' +str(@TaskSerialNoTO)
	
	
		if @ProduceFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND PO.FiscalYear>=' +str(@ProduceFiscalYearFR)
		if @ProduceSerialNoFR>0
			set @StrWhere = @StrWhere+' AND PO.SerialNo  >=' +str(@ProduceSerialNoFR)
		if @ProduceFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND PO.FiscalYear<=' +str(@ProduceFiscalYearTO)
		if @ProduceSerialNoTO>0
			set @StrWhere = @StrWhere+' AND PO.SerialNo	<=' +str(@ProduceSerialNoTO)
	
	
		if @SaleFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND D.FiscalYear>=' +str(@SaleFiscalYearFR)
		if @SaleSerialNoFR>0
			set @StrWhere = @StrWhere+' AND D.SerialNo  >=' +str(@SaleSerialNoFR)
		if @SaleFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND D.FiscalYear<=' +str(@SaleFiscalYearTO)
		if @SaleSerialNoTO>0
			set @StrWhere = @StrWhere+' AND D.SerialNo	<=' +str(@SaleSerialNoTO)
	
	
		if @PreSaleFiscalYearFR>0
			set @StrWhere =@StrWhere+ ' AND D.BaseFiscalYear>=' +str(@PreSaleFiscalYearFR)
		if @PreSaleSerialNoFR>0
			set @StrWhere = @StrWhere+' AND D.BaseSerialNo  >=' +str(@PreSaleSerialNoFR)
		if @PreSaleFiscalYearTO>0
			set @StrWhere =@StrWhere+ ' AND D.BaseFiscalYear<=' +str(@PreSaleFiscalYearTO)
		if @PreSaleSerialNoTO>0
			set @StrWhere = @StrWhere+' AND D.BaseSerialNo	<=' +str(@PreSaleSerialNoTO)
	
		set @StrWhere = @StrWhere+' AND PO.ProcessNo	in (' +str(@ProcessNo1)+' ,' +str(@ProcessNo2)+' )'
		
set @StrSelect = ' 
		select isnull(D.ProcessID,0) ProcessID,isnull(D.ProcessNo,0)ProcessNo,isnull(D.FiscalYear,0)FiscalYear,isnull(D.SerialNo,0)SerialNo,isnull(D.DocRowNo,0) DocRowNo,
			isnull(D.BaseProcessID,0) BaseProcessID,isnull(D.BaseProcessNo,0) BaseProcessNo,isnull(D.BaseFiscalYear,0)BaseFiscalYear 
			,isnull(D.BaseSerialNo,0)BaseSerialNo	,isnull(D.BaseDocRowNo,0) BaseDocRowNo, PO.BatchNo,
			acc.funPartAcntNameRecurcive(D.AcntCode,' + str(@Part) + ') AcntName,PO.SerialNo SerialNoP,pub.GetGoodsName(PO.ProductID,1) GoodsName ,TH.SerialNo SerialNoT,pub.GetGoodsName(TH.ProductID,1) GoodsName2 
			,inv.funGetUnitName(G.UnitID,1)  UnitName,
			SD.ProduceStepID,SD.ProduceStepName,PO.ProductCount,
			 case when StartDate='''' then ''----/--/--'' else  isnull(StartDate,''----/--/--'') end StartDate ,isnull(TH.OrderCount,0) OrderCount
			 ,case when FinishDate='''' then ''----/--/--'' else   isnull(FinishDate,''----/--/--'') end FinishDate ,			
			pub.funFarsiDateDiff(''Day'',case when StartDate is null or StartDate='''' then [pub].[funChangeDate_GergorianToPersian](GETDATE()) else StartDate end
										, case when  FinishDate is null or FinishDate='''' then [pub].[funChangeDate_GergorianToPersian](GETDATE()) else FinishDate end) 			DateDefu ,
			isnull(AcceptableCount, 0) 	AcceptableCount,isnull(UnacceptableCount , 0) 	UnacceptableCount ,
			stuff((
			select   '' ''+convert(varchar(200),FirstName + '' ''+ LastName)+ '' , ''
			from pln.tblTaskOrderOperators S
				inner join prs.tblPersonnelsDtl PS on PS.PersonnelID=S.OperatorID
			where S.ProcessID=TD.ProcessID 
				and S.ProcessNo=TD.ProcessNo
				and S.FiscalYear=TD.FiscalYear
				and S.SerialNo=TD.SerialNo
				and S.RowNo=TD.RowNo
			for xml path('''')
		),1,1,'''') OperatorName
		
		from pln.tblProduceOrderDtl PO 
			inner join inv.tblGoods G on G.GoodsID=PO.ProductID
			left join pln.tblItemRelations D2 on PO.ProcessID=D2.ProcessID And PO.ProcessNo=D2.ProcessNo And PO.FiscalYear=D2.FiscalYear And PO.SerialNo=D2.SerialNo And PO.DocRowNo=D2.DocRowNo
			left join sal.tblSaleOrderDtl D on 
								((PO.BaseProcessID=D.ProcessID And PO.BaseProcessNo=D.ProcessNo And PO.BaseFiscalYear=D.FiscalYear And PO.BaseSerialNo=D.SerialNo And PO.BaseDocRowNo=D.DocRowNo)
								or (D2.BaseProcessID=D.ProcessID And D2.BaseProcessNo=D.ProcessNo And D2.BaseFiscalYear=D.FiscalYear And D2.BaseSerialNo=D.SerialNo And D2.BaseDocRowNo=D.DocRowNo))
			left join pln.tblTaskOrderHdr TH on TH.BaseProcessID=PO.ProcessID And TH.BaseProcessNo=PO.ProcessNo And TH.BaseFiscalYear=PO.FiscalYear And TH.BaseSerialNo=PO.SerialNo And TH.ProdDocRowNo=PO.DocRowNo
			left join pln.tblProduceStepDtl SD on  SD.ProductID=TH.ProductID and SD.SerialNo=PO.StepNo
			left join pln.tblTaskOrderDtl TD on TH.ProcessID=TD.ProcessID And TH.ProcessNo=TD.ProcessNo And TH.FiscalYear=TD.FiscalYear And TH.SerialNo=TD.SerialNo and SD.ProduceStepID=TD.ProduceStepID 
		where  ' + @StrWhere +'
		Order by D.SerialNo,D.BaseSerialNo,D.BaseProcessNo,SD.ProduceStepID '

	print @StrSelect
	Exec sp_executesql @StrSelect;
end 
end 
GO
