USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [inv].[spFrmPreSale2QuantityControl] 
	 @ProcessID			tinyint,
	 @ProcessNo			tinyint,
	 @FiscalYear	smallint,
	 @SerialNo		int,
	 @DocDate			Char(10),
	 @LanguageID		Tinyint

WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

SELECT Distinct H.GoodsID2,pub.funGetGoodsName(H.GoodsID2,@LanguageID) AS GoodsName--,[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,StoreID,H.GoodsID2,Null,@DocDate,0) y,[inv].[funGetGoodsRemainInPreSale](H.GoodsID2,StoreID,@DocDate,'False',1,0,3)Z
	,[inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,StoreID,H.GoodsID2,Null,@DocDate,0) - [inv].[funGetGoodsRemainInPreSale](H.GoodsID2,StoreID,@DocDate,'False',1,0,3) Qty
FROM (select GoodsID2,StoreID,SUM(GoodsQuantity)PreQty from inv.tblPreSaleDtl H 
where ProcessID = @ProcessID 
AND   ProcessNo = @ProcessNo
AND   FiscalYear= @FiscalYear
AND   SerialNo  = @SerialNo
group by GoodsID2,StoreID) H
WHERE  [inv].[funGetGoodsRemain](NULL,NULL,NULL,NULL,NULL,StoreID,H.GoodsID2,Null,@DocDate,0) - [inv].[funGetGoodsRemainInPreSale](H.GoodsID2,StoreID,@DocDate,'False',1,0,3)<0

end
GO
