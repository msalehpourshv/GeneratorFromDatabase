USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/06/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[sp_api_Tasnim_AutoSerials]
@ProcessID as tinyint,
@ProcessNo as tinyint,
@FiscalYear as Int,
@SerialNo as Int,
@RowNo as Int,
@AtomRowNo as Int,
@GoodsID AS VARCHAR(20),
@PSerialNo varchar(30),
@EnterKind smallint,
@StoreID AS VARCHAR(20),
@Desc AS NVARCHAR(300)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
BEGIN TRY

	DECLARE @ProductSerialID as int=0
	
	SELECT @ProductSerialID=ProductSerialID 
	FROM  [pln].[tblProductSerials]
	WHERE ProductID=@GoodsID and SerialNo=@PSerialNo

	IF @ProductSerialID = 0
	BEGIN
		Set @StrErrorMessage = N'سریال   '+ @PSerialNo+ +' برای کالای '++@GoodsID+' تعریف نشده است '
		raiserror (@StrErrorMessage, 16, 1)
	END	
	insert into [inv].[tblStorageDocsSerials]
	([ProcessID], [ProcessNo], [FiscalYear], [SerialNo], [DocRowNo], [AtomRowNo], [DocAtomRowNo], [ProductSerialID], [PSerialNo], [StoreID], [EnterKind], 
	[NumberPerSerial], [SerialDesc])
	SELECT @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @RowNo, @AtomRowNo, @AtomRowNo, @ProductSerialID, @PSerialNo, @StoreID, @EnterKind,1,@Desc

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
