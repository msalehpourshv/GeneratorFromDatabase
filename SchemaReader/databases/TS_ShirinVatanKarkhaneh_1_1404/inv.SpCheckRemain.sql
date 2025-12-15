USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: <Ahmadnejad>
-- Create date	: <1388-04-08>
-- Description	: <>
-- =============================================
CREATE PROCEDURE inv.SpCheckRemain
WITH ENCRYPTION
AS
DECLARE @GoodsID		VarChar(20);
DECLARE @StoreID		VarChar(20);
DECLARE @GoodsID_Old	VarChar(20);
DECLARE @StoreID_Old	VarChar(20);

DECLARE @MSG			NVarChar(4000);

DECLARE @GoodsQuantity	float;
DECLARE @EnterKind		Int;
DECLARE @QtyRemain		float;
DECLARE @Remain			float;
DECLARE @DocDate		Char(10);
DECLARE	@VolumeRowNo	Int;
DECLARE	@RowNo			Int;
BEGIN

	SET NOCOUNT ON;

	SET @GoodsID_Old = '';
	SET @StoreID_Old = '';
	SET @MSG = 'Ok';

	-- Start Trans
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRAN

		DECLARE csr_SpCheckRemain CURSOR FOR 
			SELECT StoreID, GoodsID, GoodsQuantity, EnterKind, QtyRemain, DocDate, VolumeRowNo, RowNo
			FROM inv.tblStorageDocsDtl
			ORDER BY StoreID, GoodsID, DocDate, VolumeRowNo

		BEGIN TRY

		OPEN csr_SpCheckRemain

		FETCH NEXT FROM csr_SpCheckRemain INTO @StoreID, @GoodsID, @GoodsQuantity, @EnterKind, @QtyRemain, @DocDate, @VolumeRowNo, @RowNo

		WHILE (@@Fetch_Status = 0)
		BEGIN
			IF (@StoreID <> @StoreID_Old)
			BEGIN				
				SET @StoreID_Old = @StoreID;
				SET @Remain = 0;
			END

			IF (@GoodsID <> @GoodsID_Old)
			BEGIN
				SET @GoodsID_Old = @GoodsID;
				SET @Remain = 0;
			END

			SET @Remain = @Remain + (@GoodsQuantity * @EnterKind);

			IF (Round(@Remain, 5) <> Round(@QtyRemain, 5))
			BEGIN

				SET @MSG = 'Invalid Qty Remain: ' + LTrim(Str(Round(@QtyRemain, 5), 20, 5)) + '  - Real Remain = ' + LTRim(Str(Round(@Remain, 5), 20, 5)) + ' - StoreID = ' + LTrim(@StoreID) + ' - GoodsID = ' + LTrim(@GoodsID) + ' - Quantity = ' + Str(@GoodsQuantity) + ' Date = ' + @DocDate + ' VolumeRowNo = ' + LTrim(Str(@VolumeRowNo)) + ' RowNo = ' + LTrim(Str(@RowNo))
				--Print @MSG;
				BREAK;
			END

			FETCH NEXT FROM csr_SpCheckRemain INTO @StoreID, @GoodsID, @GoodsQuantity, @EnterKind, @QtyRemain, @DocDate, @VolumeRowNo, @RowNo
		END

		-- Commit Trans
		COMMIT TRAN
	END TRY
	BEGIN CATCH
		-- Rollback Trans
		ROLLBACK TRAN
	END CATCH

	CLOSE csr_SpCheckRemain
	DEALLOCATE csr_SpCheckRemain

	SELECT @MSG;

END
GO
