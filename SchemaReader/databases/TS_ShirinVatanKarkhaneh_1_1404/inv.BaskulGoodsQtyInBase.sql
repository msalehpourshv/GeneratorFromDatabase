USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create Date   : 1398/02/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : کنترل موجودی باسکول با مجوز فروش
-- ==============================================
Create PROCEDURE [inv].[BaskulGoodsQtyInBase]
	@CallType			int,
	@ExtraParams		NVarChar(Max) = ''
	
WITH ENCRYPTION
AS
BEGIN
declare @BaseProcessID	as int;
declare @BaseProcessNo	as int;
declare @BaseFiscalYear as int;
declare @BaseSerialNo	as int;
declare @DocRowNo	as int;
declare @ProcessID	as int;
declare @ProcessNo	as int;
declare @FiscalYear as int;
declare @SerialNo	as int;
declare @GoodsID		as  varchar(20);
declare @SubUnitID		as  varchar(20);
declare @DriverID		as  varchar(20);
declare @SubUnitQuantity		as  float;
declare @Qty1		as  float;
declare @Qty2		as  float;
declare @Qty3		as  float;
declare @WeightNumberDivision  float;

declare @Inv_BaskulDocsType		as  int;
select @Inv_BaskulDocsType=SettingValue from pub.tblSettings where SettingKey='Inv_BaskulDocsType'

declare @SaleAllowInsertAutoDocStep2 as  bit;
select @SaleAllowInsertAutoDocStep2=SettingValue from pub.tblSettings where SettingKey='SaleAllowInsertAutoDocStep2'

select @WeightNumberDivision=isnull(SettingValue,1) from pub.tblSettings where SettingKey='WeightNumberDivision'
set @WeightNumberDivision=isnull(@WeightNumberDivision,1)
if @WeightNumberDivision=0
	set @WeightNumberDivision=1
if @CallType=1
begin

	SET @BaseProcessID	= pub.funSplitString(@ExtraParams, '@', 1);
	SET @BaseProcessNo	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @BaseFiscalYear	= pub.funSplitString(@ExtraParams, '@', 3);
	SET @BaseSerialNo	= pub.funSplitString(@ExtraParams, '@', 4);
	SET @DocRowNo		= pub.funSplitString(@ExtraParams, '@', 5);
	SET @ProcessID		= pub.funSplitString(@ExtraParams, '@', 6);
	SET @SerialNo		= pub.funSplitString(@ExtraParams, '@', 7);
	SET @GoodsID		= pub.funSplitString(@ExtraParams, '@', 8);

if @BaseProcessID=194 
begin
	if @Inv_BaskulDocsType=2
		select @Qty1=  Cast(( g.GoodsWeight * s.Qty /@WeightNumberDivision)as float ) 
		from sal.tblBaskulCustGoodsDtl  s 
		  inner join inv.tblGoods g on s.GoodsID=g.GoodsID  
		
		 where s.ProcessID= @BaseProcessID
		and s.ProcessNo=@BaseProcessNo
		and s.FiscalYear=@BaseFiscalYear
		and s.SerialNo=@BaseSerialNo
		and s.GoodsID=@GoodsID
		and s.DocRowNo=@DocRowNo
	else
		select @Qty1=  Qty from sal.tblBaskulCustGoodsDtl
		where 
		ProcessID= @BaseProcessID
		and ProcessNo=@BaseProcessNo
		and FiscalYear=@BaseFiscalYear
		and SerialNo=@BaseSerialNo
		and GoodsID=@GoodsID
		and DocRowNo=@DocRowNo
end	
else
begin
	
	if @BaseProcessID=160 
	begin
		if @Inv_BaskulDocsType=2
			select @Qty1=  Cast(( g.GoodsWeight * s.GoodsQuantity /@WeightNumberDivision)as float ) 
			from cmr.tblOrderDtl  s 
			  inner join inv.tblGoods g on s.GoodsID=g.GoodsID  
		
			 where s.ProcessID= @BaseProcessID
			and s.ProcessNo=@BaseProcessNo
			and s.FiscalYear=@BaseFiscalYear
			and s.SerialNo=@BaseSerialNo
			and s.GoodsID=@GoodsID
			and s.DocRowNo=@DocRowNo
		else
			select @Qty1=  GoodsQuantity from cmr.tblOrderDtl
			where 
			ProcessID= @BaseProcessID
			and ProcessNo=@BaseProcessNo
			and FiscalYear=@BaseFiscalYear
			and SerialNo=@BaseSerialNo
			and GoodsID=@GoodsID
			and DocRowNo=@DocRowNo
	end	
	else
	begin
		if @Inv_BaskulDocsType=2
			select @Qty1=  Cast(( Case when isnull(u.UGoodsWeight,0) =0 then g.GoodsWeight else isnull(u.UGoodsWeight,0)  end  * s.GoodsQuantity /@WeightNumberDivision)as float ) 
			from inv.tblStorageDocsDtl  s 
			  inner join inv.tblGoods g on s.GoodsID=g.GoodsID  
			 left join inv.tblGoodsUserPrice u on u.ID=s.UserPriceID
			 where s.ProcessID= @BaseProcessID
			and s.ProcessNo=@BaseProcessNo
			and s.FiscalYear=@BaseFiscalYear
			and s.SerialNo=@BaseSerialNo
			and s.GoodsID=@GoodsID
			and s.DocRowNo=@DocRowNo
		else
			select @Qty1=  GoodsQuantity from inv.tblStorageDocsDtl
			where 
			ProcessID= @BaseProcessID
			and ProcessNo=@BaseProcessNo
			and FiscalYear=@BaseFiscalYear
			and SerialNo=@BaseSerialNo
			and GoodsID=@GoodsID
			and DocRowNo=@DocRowNo
	end	
end	
										
		select @Qty2= SubUnitQuantity from inv.tblBaskulSalesDtl
		where 
		ProcessID= @ProcessID
		and SerialNo=@SerialNo
		and GoodsID=@GoodsID
		and DocRowNo=@DocRowNo

		select @Qty3=Tolerance from inv.tblGoods
		where GoodsID=@GoodsID

		select isnull(@Qty1,0) QtySale, isnull(@Qty2,0) QtyBaskul, isnull(@Qty3,0) Tolerance

end

if @CallType=2
begin

	SET @BaseProcessID	= pub.funSplitString(@ExtraParams, '@', 1);
	SET @BaseProcessNo	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @BaseFiscalYear	= pub.funSplitString(@ExtraParams, '@', 3);
	SET @BaseSerialNo	= pub.funSplitString(@ExtraParams, '@', 4);
	SET @ProcessID		= pub.funSplitString(@ExtraParams, '@', 5);
	SET @SerialNo		= pub.funSplitString(@ExtraParams, '@', 6);
		
if @BaseProcessID=90
begin
					  		
	DECLARE csr CURSOR FOR 
			
	select d.GoodsID, SubUnitID,h.DriverID , SubUnitQuantity,DocRowNo
	 from inv.tblBaskulSalesDtl d
	inner join inv.tblBaskulSalesHdr h
	on h.ProcessID=d.ProcessID and h.SerialNo=d.SerialNo
	where d.ProcessID= @ProcessID
	and d.SerialNo=@SerialNo
			 
	OPEN csr
	FETCH NEXT FROM csr INTO @GoodsID, @SubUnitID, @DriverID,@SubUnitQuantity,@DocRowNo

	WHILE @@Fetch_Status = 0
	BEGIN
		
		update inv.tblStorageDocsHdr
		set DriverID=@DriverID		 
		where 
			ProcessID= @BaseProcessID
			and ProcessNo=@BaseProcessNo
			and FiscalYear=@BaseFiscalYear
			and SerialNo=@BaseSerialNo
		if @Inv_BaskulDocsType<>2
		begin
			update inv.tblStorageDocsHdr
			set   DocStep=2
			where 
				ProcessID= @BaseProcessID
				and ProcessNo=@BaseProcessNo
				and FiscalYear=@BaseFiscalYear
				and SerialNo=@BaseSerialNo
				and DocStep<2
			update inv.tblStorageDocsDtl
			set DocStep=2
			where 
				ProcessID= @BaseProcessID
				and ProcessNo=@BaseProcessNo
				and FiscalYear=@BaseFiscalYear
				and SerialNo=@BaseSerialNo
				and DocRowNo=@DocRowNo
				and DocStep<2
		end
	if ((select count(*) 	 from inv.tblBaskulSalesDtl d 	where d.ProcessID= @ProcessID 	and d.SerialNo=@SerialNo)>0 and ( @Inv_BaskulDocsType<>2)) 
	or @SaleAllowInsertAutoDocStep2='True'
		begin	
		 
		update inv.tblStorageDocsDtl	  set GoodsQuantity=@SubUnitQuantity
		where 
			ProcessID= @BaseProcessID	and ProcessNo=@BaseProcessNo
			and FiscalYear=@BaseFiscalYear	and SerialNo=@BaseSerialNo
			and GoodsID=@GoodsID
			and DocRowNo=@DocRowNo
			 
		update inv.tblStorageDocsDtl	set SubUnitQuantity=@SubUnitQuantity
		where 
			ProcessID= @BaseProcessID	and ProcessNo=@BaseProcessNo
			and FiscalYear=@BaseFiscalYear and SerialNo=@BaseSerialNo
			and GoodsID=@GoodsID	and SubUnitID=@SubUnitID
			and DocRowNo=@DocRowNo			
		end
	
	FETCH NEXT FROM csr INTO @GoodsID, @SubUnitID,@DriverID, @SubUnitQuantity,@DocRowNo
	
	end 
	CLOSE csr
	DEALLOCATE csr
end	
	update inv.tblBaskulSalesHdr 	Set Step=4
	where ProcessID= @ProcessID	and SerialNo=@SerialNo
		
	select 2 RetType
				
end

end
GO
