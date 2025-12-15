USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/10/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_AsmanRasa_CreateReceivedFromProduction]

@FiscalYear	As NVARCHAR(50) ,
@AcntCode As NVARCHAR(50) ,
@TransferSerialNo As NVARCHAR(50) ,
@ProcessNo AS NVARCHAR(50),
@DocDate AS NVARCHAR(50),
@DocDesc AS NVARCHAR(50),
@StoreID AS NVARCHAR(50),
@OrderId AS NVARCHAR(50),
@Quantity AS NVARCHAR(50),
@TechnicalNo AS NVARCHAR(50),
@StateIds AS NVARCHAR(50),
@EnterKind as int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @maxSerialNo nvarchar(50)
	DECLARE @GoodsId nvarchar(50)
	DECLARE @UnitId nvarchar(50)
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @GoodsID2 nvarchar(50)
	DECLARE @IsCreate INT

BEGIN TRY

IF(SELECT IsService FROM inv.tblGoods WHERE TechnicalNo=@TechnicalNo and ExtraField5 like '%/'+ ltrim(rtrim(str(@StateIds)))+'/%' )=0
begin

	if(@OrderId=null or @OrderId='')
		set @OrderId=pub.funSplitString (@TransferSerialNo,'_' ,1)

	IF(select count(*) from inv.tblStorageDocsHdr  where ProcessID=80 AND TransferSerialNo=@TransferSerialNo and BatchNo=@OrderId)>0
	BEGIN
		SET @IsCreate=0

		if(@GoodsID2='')
		begin
		Set @StrErrorMessage = N'کد فنی '+@TechnicalNo+' برای وضعیت '+@StateIds+'تعریف نشده است'
		raiserror (@StrErrorMessage, 16, 1)

		end


		IF(SELECT COUNT(*) FROM inv.tblStorageDocsHdr H
			JOIN inv.tblStorageDocsDtl D
			ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo
			WHERE TransferSerialNo=@TransferSerialNo AND H.ProcessID=80 AND D.GoodsID= @GoodsID2)=0
		BEGIN
			SET @IsCreate=1
		END


	END
	
	ELSE
	BEGIN
		SET @IsCreate=1
	END


	if(select count(*) from inv.tblGoods  where TechnicalNo=@TechnicalNo AND (ExtraField4 like '%/64/%' or ExtraField4 like '%/52/%'))=0
	begin
		Set @StrErrorMessage = N'کد فنی '+@TechnicalNo+' دارای وضعیت ارسال به تولید نمی باشد / یا وضعیت ارسال به تولید آن با برنامه منطبق نیست لطفا بررسی کنید'
		raiserror (@StrErrorMessage, 16, 1)
	end 
	
	SELECT @GoodsId=GoodsID ,@UnitId=UnitID FROM inv.tblGoods
	WHERE TechnicalNo=@TechnicalNo and ExtraField5 like '%/'+ ltrim(rtrim(str(@StateIds)))+'/%'

	if(SELECT count(*) FROM inv.tblStorageDocsHdr
	   WHERE  
	   ProductID=@GoodsId And
	   ProcessID=80 and pub.funSplitString (TransferSerialNo,'_' ,1)=@OrderId)>0 --and 
	   --=@StateID )>0 
	BEGIN
		set @IsCreate= 0
	end
	
	IF(@IsCreate=1)
	Begin
		if(select count(*)  from inv.tblStorageDocsHdr where BatchNo=pub.funSplitString(@TransferSerialNo,'_',1))=0
		begin
			Set @StrErrorMessage = N'کد فنی '+@TechnicalNo+' برای وضعیت '+@StateIds+' با شماره بچ '
			+pub.funSplitString(@TransferSerialNo,'_',1)+' هیچ تولیدی ثبت نشده است '
			raiserror (@StrErrorMessage, 16, 1)

		end

		SELECT @GoodsId=GoodsID ,@UnitId=UnitID FROM inv.tblGoods
		WHERE TechnicalNo=@TechnicalNo and ExtraField5 like '%/'+ ltrim(rtrim(str(@StateIds)))+'/%'

		if(@GoodsId is null)
		begin
			Set @StrErrorMessage = N'کد فنی '+@TechnicalNo+' برای وضعیت '+@StateIds+'تعریف نشده است'
			raiserror (@StrErrorMessage, 16, 1)
		end

		if (select count(*) from inv.tblGoods where GoodsID=@GoodsId and GoodsClassificationID<>'')>0
		begin

		SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
		FROM inv.tblStorageDocsHdr 
		WHERE ProcessID=80
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear

		SET @maxSerialNo = @maxSerialNo +1

		INSERT INTO inv.tblStorageDocsHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
			 DocDesc,IsAutoDoc,TransferSerialNo,BatchNo,ProductID,ProductCount)
	
		SELECT 80, @ProcessNo, @FiscalYear, @maxSerialNo, 2, @DocDate, @StoreID, @AcntCode,
			'Api'+@DocDesc,'True',@TransferSerialNo,@OrderId,@GoodsId,@Quantity


		--DTL
		

		INSERT INTO inv.tblStorageDocsDtl
		(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, AcntCode,
		 DescDtl,GoodsID,BatchNo,EnterKind,RowNo,DocRowNo,GoodsQuantity,SubUnitQuantity,SubUnitID)
	
		SELECT 80, @ProcessNo, @FiscalYear, @maxSerialNo, 2, @DocDate, @StoreID, @AcntCode,
		@DocDesc,@GoodsId,@OrderId,1,1,1,@Quantity,@Quantity,@UnitId
end
	END
end

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
