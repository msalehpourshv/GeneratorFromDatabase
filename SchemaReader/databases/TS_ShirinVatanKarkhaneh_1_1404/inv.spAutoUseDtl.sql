USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/01/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[spAutoUseDtl]
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int,
@RowNo as Int,
@DocStep as tinyint,
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@GoodsID AS VARCHAR(20),
@Quantity as FLOAT,
@DescDtl as NVARCHAR(500)

WITH ENCRYPTION
 AS
BEGIN

	Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY


	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )=0
	BEGIN
		Set @StrErrorMessage = N'�� ���� ������� ���'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	INSERT INTO inv.tblStorageDocsDtl
	(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, VolumeRowNo,
	DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity,DescDtl)
	
	select 110, @ProcessNo, @FiscalYear, @SerialNo,@RowNo,@RowNo,0,
		   @DocStep, @DocDate, @StoreID, 'True', -1, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity  ,@DescDtl 
	FROM inv.tblGoods 
	where GoodsID=@GoodsID
    
END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
