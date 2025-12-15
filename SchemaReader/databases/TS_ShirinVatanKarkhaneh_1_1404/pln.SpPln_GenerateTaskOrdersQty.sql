USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ===================
-- Author		 : TakroSystem\Zia
-- Create date   : 1393/05/12
-- Viewed By	 : 
-- Last Modified : 1394/03/06
-- Last Modifier : TakroSystem\Zia
-- =============================================
Create PROCEDURE pln.SpPln_GenerateTaskOrdersQty
@ProcessID		int, 
@ProcessNo		int,
@FiscalYear		int,
@SerialNo		int,
@DocRowNo		int,
@ExtraParams	NVarChar(100) = ''

WITH ENCRYPTION
AS
declare @StrSelect  nvarchar(4000);
declare @StrWhere	nvarchar(2000);
BEGIN
	SET NOCOUNT ON;

	-- Init ---------------------------------------------------------------------

declare @CallType	int
declare @DocDate	char(10)
declare @AllStore	int 

SET @CallType  = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @DocDate   = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @AllStore  = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 


	create table #tblGoodsStore
	(
		GoodsID				varchar(20) ,
		GoodsName			varchar(2000) ,
		AcceptStoreID		varchar(20) ,
		FailedStoreID		varchar(20) ,
		UsageStoreID		varchar(20) ,
		LossStoreID			varchar(20) ,
		AcceptStoreName		varchar(2000) ,
		FailedStoreName		varchar(2000) ,
		UsageStoreName		varchar(2000) ,
		LossStoreName		varchar(2000) ,
		ProducerAcntCode	varchar(20) ,
		ProducerName		varchar(2000) 
	)

	create table #tbl_Pln_GenerateTaskOrders_GoodsStore
	(
		GoodsID	varchar(20) collate arabic_cs_as not null,
		UsageStoreID  varchar(20) collate arabic_cs_as not null,
		AcceptStoreID varchar(20) collate arabic_cs_as not null,
		FailedStoreID varchar(20) collate arabic_cs_as not null,
		LossStoreID   varchar(20) collate arabic_cs_as not null,
		ProducerAcntCode   varchar(20) collate arabic_cs_as not null
	)

	create table #tbl_Pln_GenerateTaskOrders_Mapping
	(
		ProcessID	int not null,
		ProcessNo	int not null,
		FiscalYear	int not null,
		SerialNo	int not null,
		DocRowNo	int not null,		
		BaseProcessID	int not null,
		BaseProcessNo	int not null,
		BaseFiscalYear	int not null,
		BaseSerialNo	int not null,
		BaseDocRowNo	int not null,
		StepNo			int not null,
		FormulaNo		int not null,
		DocDate			char(10) not null,
		GoodsID			varchar(20) collate arabic_cs_as not null,
		Quantity		float not null,
		ProductWidth	float not null,   
		ProductHeight	float not null,
		ProductQuantity2	float not null,
		LevelStr	varchar(500),
		BatchNo			varchar(20) collate arabic_cs_as not null
	)

	declare @PlnTskSaveStoreDocPerStep bit;
	set @PlnTskSaveStoreDocPerStep=0

	create table #tbl_GoodsID
	( 
	GoodsID	varchar(20) not null
	)
	Declare @GoodsID	varchar(20) =''
	Declare @LevelStr	nvarchar(500) =''
	
	if (@PlnTskSaveStoreDocPerStep = 1)
	begin 
	insert into #tbl_GoodsID
		select GoodsID
		from pln.tblAvailProduceOrders A
			inner join pln.tblProduceStepDtl B
			on B.ProductID=A.GoodsID and A.StepNo=B.SerialNo 
		where	(A.ProcessID = @ProcessID) 
			and (A.ProcessNo = @ProcessNo) 
			and (A.FiscalYear = @FiscalYear) 
			and (A.SerialNo = @SerialNo)
			and (A.BaseDocRowNo = @DocRowNo)
			
	end 
	else
	begin 
		insert into #tbl_GoodsID
	select GoodsID
			from pln.tblAvailProduceOrders A
		where	(A.ProcessID = @ProcessID) 
			and (A.ProcessNo = @ProcessNo) 
			and (A.FiscalYear = @FiscalYear) 
			and (A.SerialNo = @SerialNo)
			and (A.BaseDocRowNo = @DocRowNo)		
	end 

	Declare @ProductID	varchar(100) =''
	Declare @FormulaNo	int=0
	
	select @ProductID=ProductID,@FormulaNo=FormulaNo
	from pln.tblProduceOrderDtl A
		where	(A.ProcessID = @ProcessID) 
			and (A.ProcessNo = @ProcessNo) 
			and (A.FiscalYear = @FiscalYear) 
			and (A.SerialNo = @SerialNo)
			and (A.DocRowNo = @DocRowNo)
			
 set @ProductID=	 '1@' + @ProductID + '@@'
 
	DECLARE csrGoodsID CURSOR FOR 
		select Distinct GoodsID from #tbl_GoodsID

	OPEN csrGoodsID
	FETCH NEXT FROM csrGoodsID INTO @GoodsID

	WHILE @@Fetch_Status = 0
	BEGIN
		delete  from #tblGoodsStore

		INSERT INTO #tblGoodsStore
		exec  pln.spDefaultStoreID @GoodsID,0,0,@ProductID 

		insert into #tbl_Pln_GenerateTaskOrders_GoodsStore(GoodsID, UsageStoreID, AcceptStoreID, FailedStoreID, LossStoreID,ProducerAcntCode)	
		Select GoodsID, UsageStoreID, AcceptStoreID, FailedStoreID, LossStoreID,ProducerAcntCode From  #tblGoodsStore
																						
		FETCH NEXT FROM csrGoodsID INTO @GoodsID
	END

	CLOSE csrGoodsID
	DEALLOCATE csrGoodsID
 
--select * from #tblGoodsStore
--select * from #tbl_Pln_GenerateTaskOrders_GoodsStore
	-- ایجاد جدول 2 برای حالتی که سفارش انجام براساس موجودی انبار باشد و بعضی را بهخاطر موجود بودن تولید نکند  سریالها پشت سر هم باشند
	
	insert into #tbl_Pln_GenerateTaskOrders_Mapping(ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,BaseDocRowNo, GoodsID, Quantity, StepNo, FormulaNo, DocDate,ProductWidth,ProductHeight,ProductQuantity2,LevelStr,BatchNo)
	select	A.ProcessID, A.ProcessNo, A.FiscalYear, 
			A.SerialNo, 
			A.DocRowNo, 
			A.ProcessID BaseProcessID, A.ProcessNo BaseProcessNo, 
			A.FiscalYear BaseFiscalYear, 
			A.SerialNo BaseSerialNo,A.BaseDocRowNo,
			A.GoodsID, A.GoodsQuantity, A.StepNo, A.FormulaNo, H.DocDate,A.ProductWidth,A.ProductHeight,A.ProductQuantity2,LevelStr,''
	from pln.tblAvailProduceOrders A
	inner join pln.tblProduceOrderHdr H on H.ProcessID=A.ProcessID and H.ProcessNo=A.ProcessNo and H.FiscalYear=A.FiscalYear and H.SerialNo=A.SerialNo
	--left join pln.tblProduceStepHdr S on S.ProductID=A.GoodsID and S.SerialNo=A.StepNo-- and S.FormulaNo=A.FormulaNo --and S.IsDefaultMethod=1
	where (A.ProcessID = @ProcessID) 
		and (A.ProcessNo = @ProcessNo) 
		and (A.FiscalYear = @FiscalYear) 
		and (A.SerialNo = @SerialNo)
		and (A.BaseDocRowNo = @DocRowNo)	

----------------------------------------------------------------------------------		 
-- برای بدست آوردن شماره بچ سفارش برای موجودی انبار
	Update #tbl_Pln_GenerateTaskOrders_Mapping 
		set BatchNo=O.BatchNo
	from #tbl_Pln_GenerateTaskOrders_Mapping A
		inner join 	pln.tblProduceOrderDtl H on H.ProcessID=A.BaseProcessID and H.ProcessNo=A.BaseProcessNo and H.FiscalYear=A.BaseFiscalYear and H.SerialNo=A.BaseSerialNo and H.DocRowNo=A.BaseDocRowNo
		inner join sal.tblSaleOrderDtl O on H.BaseProcessID=O.ProcessID and H.BaseProcessNo=O.ProcessNo and H.BaseFiscalYear=O.FiscalYear and H.BaseSerialNo=O.SerialNo and H.BaseDocRowNo=O.DocRowNo
			where (A.BaseProcessID = @ProcessID) 
				and (A.BaseProcessNo = @ProcessNo) 
				and (A.BaseFiscalYear = @FiscalYear) 
				and (A.BaseSerialNo = @SerialNo)
				and (A.BaseDocRowNo = @DocRowNo)		 
-- برای حذف بچ نیمه ساختهایی که بچ و فرمول تولید ندارند
	 Update #tbl_Pln_GenerateTaskOrders_Mapping 
	 set BatchNo=(case when (select count(*) from inv.tblGoods  
									where #tbl_Pln_GenerateTaskOrders_Mapping.GoodsID=inv.tblGoods.GoodsID and inv.tblGoods.HasBatchNo=1)>0
									And (select count(*) from prd.tblFormulasDtl  where ProductID=#tbl_Pln_GenerateTaskOrders_Mapping.GoodsID)>0							
									then   BatchNo else '' end) 
	 
----------------------------------------------------------------------------------		 
 if @CallType=2
	update #tbl_Pln_GenerateTaskOrders_Mapping
		set DocDate=@DocDate
		
--- بررسی موجودی تمامی انبار ها 				
	if @AllStore=1
		update #tbl_Pln_GenerateTaskOrders_Mapping
		set  Quantity= 
						case when   [inv].[funGetGoodsRemain](NULL, NULL, NULL, NULL, NULL, NULL  , m.GoodsID , NULL, m.DocDate, 0) >= m.Quantity
						then 0 else  m.Quantity-[inv].[funGetGoodsRemain](NULL, NULL, NULL, NULL, NULL,NULL , m.GoodsID , NULL, m.DocDate, 0) end 
		from #tbl_Pln_GenerateTaskOrders_Mapping m
			inner join 	#tbl_Pln_GenerateTaskOrders_GoodsStore s on m.GoodsID=s.GoodsID			 
		where LevelStr<>'0'
	else
		update #tbl_Pln_GenerateTaskOrders_Mapping
		set  Quantity= 
						case when   [inv].[funGetGoodsRemain](NULL, NULL, NULL, NULL, NULL, s.AcceptStoreID  , m.GoodsID , BatchNo, m.DocDate, 0) >= m.Quantity
						then 0 else  m.Quantity-[inv].[funGetGoodsRemain](NULL, NULL, NULL, NULL, NULL, s.AcceptStoreID  , m.GoodsID , BatchNo, m.DocDate, 0) end 
		from #tbl_Pln_GenerateTaskOrders_Mapping m
			inner join 	#tbl_Pln_GenerateTaskOrders_GoodsStore s on m.GoodsID=s.GoodsID			 
		where LevelStr<>'0'
				
	DECLARE csrGoodsID CURSOR FOR 
		select LevelStr from #tbl_Pln_GenerateTaskOrders_Mapping where Quantity=0

	OPEN csrGoodsID
	FETCH NEXT FROM csrGoodsID INTO @LevelStr
	
	WHILE @@Fetch_Status = 0
	BEGIN

		delete from #tbl_Pln_GenerateTaskOrders_Mapping 
		 where LevelStr like (@LevelStr+'%')

		FETCH NEXT FROM csrGoodsID INTO @LevelStr
	END

	CLOSE csrGoodsID
	DEALLOCATE csrGoodsID
 
	delete from #tbl_Pln_GenerateTaskOrders_Mapping where Quantity=0
	 

	-- ایجاد جدول 2 برای حالتی که سفارش انجام براساس موجودی انبار باشد و بعضی را بهخاطر موجود بودن تولید نکند  سریالها پشت سر هم باشند
	
select * from #tbl_Pln_GenerateTaskOrders_Mapping  order by LevelStr Desc
 

	-----------------------------------------------------------------------------
END
GO
