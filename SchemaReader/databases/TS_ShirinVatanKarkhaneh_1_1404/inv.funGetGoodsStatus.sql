USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 87/05/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[funGetGoodsStatus]
(
	@GoodsID		VarChar(20),
	@StoreID		VarChar(20),
	@DocDate		Varchar(10),
	@VolumeRowNo	FLOAT,
	@GetFromGoodsStatus bit,
    @ProcessID		INT,
    @ProcessNo		INT,
    @FiscalYear		INT,
    @SerialNo		INT
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result		Float
	DECLARE @QtyRemain	Float
	DECLARE @SetPoint	Float
	
	SET @SetPoint = 0
	
	Select TOP(1) @QtyRemain = SUM(GoodsQuantity * EnterKind)
	From [inv].[tblStorageDocsDtl] 
	Where	StoreID = @StoreID AND GoodsID = @GoodsID AND 
			(DocDate < @DocDate OR (DocDate = @DocDate AND  (@VolumeRowNo = 0 OR VolumeRowNo <= @VolumeRowNo)))
			AND NOT (
			ProcessID = @ProcessID AND
			ProcessNo = @ProcessNo AND
			FiscalYear = @FiscalYear AND
			SerialNo = @SerialNo ) 			
			
	IF @GetFromGoodsStatus = 'True'
		SELECT	@SetPoint = SetPoint
		FROM	inv.tblGoodsStatusDtl
		WHERE	GoodsID = @GoodsID AND StoreID = @StoreID 
	ELSE
		SELECT	@SetPoint = SetPoint
		FROM	inv.tblGoods
		WHERE	GoodsID = @GoodsID 
		
	SET @Result = ISNULL(@QtyRemain,0) - ISNULL(@SetPoint,0)
	
	IF @SetPoint = 0
		SET @Result = 0 
		
	RETURN @Result 

END
GO
