USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1400/10/08
-- Viewed By	 : 
-- Last Modified : 
-- Description   : ورود سفارش خرید از crm  رز
-- =============================================
Create PROCEDURE crm.sp_AutoOrderDtlForRozCRM
@ProcessNo as int,
@SerialNo as Int,
@GoodsID AS VARCHAR(20),
@UnitID AS VARCHAR(20),
@Quantity as FLOAT,
@GoodsPrice as FLOAT,
@DescDtl as NVARCHAR(500),
@Repeat as int

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY

	declare @RowNo				int;
	declare @FiscalYear				int;
	set @FiscalYear=RIGHT (DB_NAME(),4) 

	IF (SELECT Count(*) FROM inv.tblGoods	where GoodsID =@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا  '+@GoodsID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	IF (SELECT Count(*) FROM inv.tblUnits	where UnitID =@UnitID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد واحد کالا  '+@UnitID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END
	
	IF (SELECT Count(*) FROM inv.tblGoods	where GoodsID =@GoodsID and UnitID =@UnitID)<=0 and (SELECT Count(*) FROM inv.tblSubUnitsDtl where GoodsID =@GoodsID and SubUnitID =@UnitID)<=0
	BEGIN
		Set @StrErrorMessage = N'کد کالا  '+@GoodsID+' برای کد واحد کالا  '+@UnitID+' نامعتبر است'
		raiserror (@StrErrorMessage, 16, 1)
	END		
	
	declare @DocDate as CHAR(10)
	declare @StoreID AS VARCHAR(20)
	declare @AcntCode AS VARCHAR(20)

	Select  @DocDate=DocDate, @AcntCode=AcntCode
	from cmr.tblOrderHdr
	where ProcessID=160 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
	
if (Select Count(*)	from cmr.tblOrderDtl	where ProcessID=160 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo and GoodsID=@GoodsID and @Repeat=0)<=0
begin

	SELECT @RowNo = isnull(MAX(DocRowNo),0)
	FROM cmr.tblOrderDtl
	WHERE ProcessID=160
	  AND ProcessNo=@ProcessNo
	  AND FiscalYear=@FiscalYear

	INSERT INTO cmr.tblOrderDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,DocStep, DocDate, StoreID, 
		AcntCode,GoodsID, SubUnitID, SubUnitQuantity,ConfirmQuantity,GoodsQuantity, GoodsPrice,DescDtl)
	
	select 160, @ProcessNo, @FiscalYear, @SerialNo,@RowNo+1,@RowNo+1,2, @DocDate, '', 
		@AcntCode, @GoodsID,@UnitID ,@Quantity ,@Quantity ,  [inv].[funGetGoodsQuantityFromSubUnit](@GoodsID,@UnitID, @Quantity ),@GoodsPrice  ,@DescDtl 
		   
	
	SELECT   @SerialNo SerialNo, @AcntCode AcntCode,@RowNo RowNo,@GoodsID  GoodsID ,0 IsExist 	
	
end 
else 
	Select  SerialNo, AcntCode, RowNo,GoodsID ,1 IsExist 	from cmr.tblOrderDtl	
		where ProcessID=160 and ProcessNo=@ProcessNo and FiscalYear=@FiscalYear and SerialNo=@SerialNo
		and GoodsID=@GoodsID

END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
