USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Create Date: 1386/11/15 (02-04-2008 )
-- Description: موجودی یک کالا را در یک انبار یا کلیه انبارها برمی گرداند
--              اگر تاریخ اعلام شود موجودی در آن تاریخ والاّ موجودی فعلی را برمی گرداند 
-- ==============================================
CREATE FUNCTION [inv].[funGetGoodsQuantity](
	@GoodsID	VarChar(20),
	@StoreID	VarChar(20) = Null,
	@Date		Char(10) = Null
)
RETURNS Int
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

	DECLARE @Result AS Int

	If (@Date Is Null)
	Begin
		If (@StoreID Is Null)
		Begin
			SELECT	@Result = IsNull(Sum(B2.QtyRemain), 0)
			FROM    inv.tblStorageDocsDtl As B2 INNER JOIN
			(
				SELECT	B1.StoreID, B1.DocDate, Max(B1.VolumeRowNo) VolumeRowNo
				FROM    inv.tblStorageDocsDtl As B1 INNER JOIN
				(
					SELECT	StoreID, Max(DocDate) DocDate
					FROM    inv.tblStorageDocsDtl
					WHERE	(GoodsID = @GoodsID)
					GROUP By StoreID
				) A1 ON B1.StoreID = A1.StoreID AND B1.DocDate = A1.DocDate
				WHERE B1.GoodsID = @GoodsID
				GROUP BY B1.StoreID, B1.DocDate
			) A2 ON B2.StoreID = A2.StoreID AND B2.DocDate = A2.DocDate AND B2.VolumeRowNo = A2.VolumeRowNo
			WHERE B2.GoodsID = @GoodsID
		End
		Else -- StoreID <> Null
		Begin
			SELECT	TOP 1 @Result = QtyRemain
			FROM	inv.tblStorageDocsDtl
			WHERE	(GoodsID = @GoodsID) AND (StoreID = @StoreID)
			ORDER BY DocDate DESC, VolumeRowNo DESC
		End
	End
	Else -- (Date <> Null)
	Begin
		If (@StoreID Is Null)
		Begin
			SELECT	@Result = IsNull(Sum(B2.QtyRemain), 0)
			FROM    inv.tblStorageDocsDtl As B2 INNER JOIN
			(
				SELECT	B1.StoreID, B1.DocDate, Max(B1.VolumeRowNo) VolumeRowNo
				FROM    inv.tblStorageDocsDtl As B1 INNER JOIN
				(
					SELECT	StoreID, Max(DocDate) DocDate
					FROM    inv.tblStorageDocsDtl
					WHERE	(GoodsID = @GoodsID) AND (DocDate <= @Date)
					GROUP By StoreID
				) A1 ON B1.StoreID = A1.StoreID AND B1.DocDate = A1.DocDate
				WHERE B1.GoodsID = @GoodsID
				GROUP BY B1.StoreID, B1.DocDate
			) A2 ON B2.StoreID = A2.StoreID AND B2.DocDate = A2.DocDate AND B2.VolumeRowNo = A2.VolumeRowNo
			WHERE B2.GoodsID = @GoodsID
		End
		Else -- StoreID <> Null
		Begin
			SELECT	TOP 1 @Result = QtyRemain
			FROM	inv.tblStorageDocsDtl
			WHERE	(GoodsID = @GoodsID) AND (StoreID = @StoreID) AND (DocDate <= @Date)
			ORDER BY DocDate DESC, VolumeRowNo DESC
		End
	End

	Return IsNull(@Result, 0)
End   -- === E N D ===============================================







GO
