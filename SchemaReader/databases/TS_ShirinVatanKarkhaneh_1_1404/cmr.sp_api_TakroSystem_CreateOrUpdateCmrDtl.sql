USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [cmr].[sp_api_TakroSystem_CreateOrUpdateCmrDtl]
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int,
@DocStep as tinyint,
@GoodsID AS VARCHAR(20),
@Quantity as FLOAT,
@SubUnitID as varchar(30),
@AcntCode AS VARCHAR(20),
@DescDtl as NVARCHAR(500),
@DocDate as CHAR(10)


WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @MaxRowNo as Int

BEGIN TRY

	

	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا صحیح نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	

	--Update or quantity=0 =>Delete
	if (select count (*) from cmr.tblCMRDtl
	 where GoodsID=@GoodsID and SerialNo=@SerialNo and 
		   ProcessNo=@ProcessNo and ProcessID=150 and FiscalYear=@FiscalYear)>0
	BEGIN
		SELECT @MaxRowNo = RowNo
		FROM cmr.tblCMRDtl
		WHERE ProcessID=150
		 AND ProcessNo=@ProcessNo
		 AND FiscalYear=@FiscalYear
		 AND SerialNo=@SerialNo
		 AND GoodsID=@GoodsID

		if @Quantity=0

		--Delete
		BEGIN
			
			DELETE FROM  cmr.tblCMRDtl
			where RowNo=@MaxRowNo AND 
				  ProcessID=150 AND 
				  ProcessNo=@ProcessNo AND 
				  FiscalYear=@FiscalYear AND 
				  SerialNo=@SerialNo AND 
				  GoodsID=@GoodsID

			Select 'Delete' As ActionName,@MaxRowNo

		END

		ELSE

		--Update
		BEGIN
			
			update cmr.tblCMRDtl
			set   AcntCode=@AcntCode,
			GoodsID=@GoodsID, SubUnitQuantity=@Quantity,GoodsQuantity=@Quantity,DescDtl=@DescDtl
			where
			ProcessID=150 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo and RowNo=@MaxRowNo

			Select 'Update' As ActionName,@MaxRowNo
		END
	End

	--Create
	ELSE
	
	Begin

		SELECT @MaxRowNo = isnull(MAX(RowNo),0)
		FROM cmr.tblCMRDtl
		WHERE ProcessID=150
		 AND ProcessNo=@ProcessNo
		 AND FiscalYear=@FiscalYear
		 AND SerialNo=@SerialNo
			 
		SET @MaxRowNo = @MaxRowNo +1

		INSERT INTO cmr.tblCMRDtl
			(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
			DocStep, DocDate, AcntCode,
			GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity,
			DescDtl)
	
		select 150, @ProcessNo, @FiscalYear, @SerialNo, @MaxRowNo , @MaxRowNo ,
			@DocStep, @DocDate, @AcntCode, 
		    @GoodsID,UnitID ,@Quantity ,@Quantity  ,
		    @DescDtl
		FROM inv.tblGoods 
		where GoodsID=@GoodsID

		Select 'Create' As ActionName,@MaxRowNo
	End
	
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
