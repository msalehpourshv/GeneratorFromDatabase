USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ==================
-- Author		 : Sadeghi	
-- Create date   : 1390/01/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : لیست قیمت 
-- ============================================
Create PROCEDURE [inv].[SpGetStorageDocsGoodsAmount] 
	@ProcessID		int,
	@ProcessNo		tinyint,
	@FiscalYear		Smallint,
	@SerialNo		int
WITH ENCRYPTION
AS 
BEGIN		
		DECLARE @DocDate as char(10)
		
		SELECT @DocDate = DocDate
		FROM inv.tblStorageDocsHdr
		WHERE ProcessID = @ProcessID AND 
			  ProcessNo = @ProcessNo AND 
			  FiscalYear = @FiscalYear AND 
			  SerialNo = @SerialNo
				-----
		SELECT GoodsID,StoreID,round (isnull((
				select top 1 D2.AmntRemain0 / D2.QtyRemain 
				from inv.tblStorageDocsDtl D2
				where (D2.GoodsID = D1.GoodsID) AND (D2.StoreID = D1.StoreID) AND (D2.UserPriceID = D1.UserPriceID) AND (D2.BatchNo = D1.BatchNo)  AND (D2.GoodsAmount > 0) AND (D2.QtyRemain > 0) AND 
				     ((D2.DocDate = D1.DocDate AND D2.VolumeRowNo < D1.VolumeRowNo) OR D2.DocDate < D1.DocDate)
				order by DocDate desc, VolumeRowNo desc
			) , 0), 2) GoodsAmount1
		INTO #tblStoreAmount
		FROM inv.tblStorageDocsDtl D1
		WHERE ProcessID = @ProcessID AND 
			  ProcessNo = @ProcessNo AND 
			  FiscalYear = @FiscalYear AND 
			  SerialNo = @SerialNo

		-----
		update #tblStoreAmount
		set GoodsAmount1 = b.GoodsAmount1
		from #tblStoreAmount a
		INNER JOIN (
				SELECT GoodsID,StoreID,round (isnull((
					select top 1 D2.AmntRemain0 / D2.QtyRemain 
					from inv.tblStorageDocsDtl D2
					where (D2.GoodsID = D1.GoodsID) AND (D2.StoreID = D1.StoreID)  AND (D2.GoodsAmount > 0) AND (D2.QtyRemain > 0) AND 
						 ((D2.DocDate = D1.DocDate AND D2.VolumeRowNo < D1.VolumeRowNo) OR D2.DocDate < D1.DocDate)
					order by DocDate desc, VolumeRowNo desc
						) , 0), 2) GoodsAmount1
				FROM inv.tblStorageDocsDtl D1
				WHERE ProcessID = @ProcessID AND 
					  ProcessNo = @ProcessNo AND 
					  FiscalYear = @FiscalYear AND 
					  SerialNo = @SerialNo) b
					  on a.GoodsID=b.GoodsID and a.StoreID=b.StoreID
			   		
		-------
		update #tblStoreAmount 
		set GoodsAmount1 = 
			round (isnull((
				select top 1 GoodsAmount 
				from inv.tblStorageDocsDtl D2
				where (D2.GoodsID = #tblStoreAmount.GoodsID)  AND (D2.DocDate <= @DocDate) AND (D2.StoreID = #tblStoreAmount.StoreID) AND (D2.GoodsAmount > 0)
				order by DocDate desc, VolumeRowNo desc
			) , 0), 2)
		where (GoodsAmount1 = 0) 

		-------
		update #tblStoreAmount 
		set GoodsAmount1 = 
			round (isnull((
				select top 1 GoodsAmount 
				from inv.tblStorageDocsDtl D2
				where (D2.GoodsID = #tblStoreAmount.GoodsID) AND (D2.DocDate <= @DocDate) AND (D2.GoodsAmount > 0)
				order by DocDate desc, VolumeRowNo desc
			), 0), 2)
		where (GoodsAmount1 = 0) 
		
		-----
		SELECT * from #tblStoreAmount
		
END
GO
