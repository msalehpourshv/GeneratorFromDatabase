USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1403/04/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =================================================================
Create PROCEDURE  prd.SPInsertUse_RetForAutoGroupProduce
	@GoodsID		varchar(20),
	@Quantity		Float ,
	@FiscalYear		INT ,
	@SerialNo		INT ,
	@TmpStoreID70	varchar(20),
	@ProductDate	char(10)
	
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

declare	@MaxSerialNo		int
declare @Qty				float
declare	@StrSelect1			NVarChar(2000)
declare	@StrSelect2			NVarChar(2000)
declare	@StrWhere			NVarChar(2000)
declare	@SalerAcntCodeInBuy	varchar(20) 

	select @SalerAcntCodeInBuy=SettingValue   from pub.tblSettings  where SettingKey='SalerAcntCodeInBuy'
	if isnull(@SalerAcntCodeInBuy,'')=''
	BEGIN
		raiserror ('کد حسابداری برگشت از مصرف خالی است', 16, 1)
		RETURN
	END
 
	Select @Qty=Sum(GoodsQuantity *EnterKind) 
	From inv.tblStorageDocsDtl
	where GoodsID=@GoodsID
		and StoreID=@TmpStoreID70
		and DocDate <=@ProductDate

	set @Qty=isnull(@Qty,0)
	
	if @Qty>=@Quantity
		return
	
	if ( select Count(*) from inv.tblStorageDocsHdr  where  ProcessID=115 and ProcessNo=1  and IsAutoDoc = 'True' and  DocDate=@ProductDate  )<=0

	Insert into inv.tblStorageDocsHdr (ProcessID, ProcessNo, FiscalYear, SerialNo,DocStep, DocDate,IsAutoDoc,StoreID,DocDesc,AcntCode  	,BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo	)
                                select 115,1,@FiscalYear,  (select isnull(Max(SerialNo),0)+1 from inv.tblStorageDocsHdr  where ProcessID=115 and ProcessNo=1  )
                                    ,1,@ProductDate  ,'True' ,@TmpStoreID70,':کسر و فزونی خروج و از انبار - تاریخ  '+ @ProductDate,@SalerAcntCodeInBuy,67,1,@FiscalYear,@SerialNo

	select @MaxSerialNo=isnull(Max(SerialNo),0) 
	from inv.tblStorageDocsHdr  
	where  ProcessID=115 
		and ProcessNo=1  
		and IsAutoDoc = 'True' 
		and  DocDate=@ProductDate 

	Set @Qty=@Quantity-@Qty
	if @Qty >0.00001
	begin
		set @StrWhere= 'where ProcessID=115 
						and  ProcessNo=1 
						and  FiscalYear='+ str(@FiscalYear)+' 
						and  SerialNo='+ str(@MaxSerialNo)+' 
						and GoodsID='''+@GoodsID+'''  
						and StoreID='''+@TmpStoreID70+''''

		set @StrSelect1 = 'select isnull(count(*),0)+1 from inv.tblStorageDocsDtl   
							where ProcessID=115 
							and ProcessNo=1 
							and  FiscalYear='+ str(@FiscalYear)+' 
							and SerialNo='+ str(@MaxSerialNo)+' ' 

		set @StrSelect2 = '  if (Select Count(*) from inv.tblStorageDocsDtl  '+ @StrWhere +')>0
								Update  inv.tblStorageDocsDtl  
									Set SubUnitQuantity=SubUnitQuantity+'+str(@Qty,20,5)+' , GoodsQuantity=SubUnitQuantity+'+str(@Qty,20,5)+ ' '+ @StrWhere +'                                                  
							 else
								insert into  inv.tblStorageDocsDtl  
								( ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,DocStep
								, DocDate, StoreID, EnterKind, GoodsID, SubUnitID, SubUnitQuantity, GoodsQuantity ,AcntCode	,BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo)
									SELECT 115,1, '+ str(@FiscalYear)+','+ str(@MaxSerialNo)+' ,  ('+ @StrSelect1 +'),  ('+ @StrSelect1 +') ,1
									,'''+@ProductDate+''','''+@TmpStoreID70+''',1,'''+@GoodsID+'''
									, (select UnitID From inv.tblGoods Where GoodsID='''+@GoodsID+''' and PartNumber=1),
									'+str(@Qty,20,5)+', '+str(@Qty,20,5)+',''' +@SalerAcntCodeInBuy +''',67,1,'+ str(@FiscalYear)+','+ str(@SerialNo)+''
 
		print @StrSelect2;
		exec sp_executesql @StrSelect2;
 
	END
END
GO
