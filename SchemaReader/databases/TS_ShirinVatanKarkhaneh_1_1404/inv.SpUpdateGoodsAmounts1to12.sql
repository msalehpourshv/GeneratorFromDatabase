USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\ Reza Nogrepasand
-- Create date   : 1392/05/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[SpUpdateGoodsAmounts1to12]
	@ProcessID	INT,
	@ProcessNo	INT,
	@FiscalYear	INT,
	@SerialNo	INT
WITH ENCRYPTION
AS 


Begin --

SET NOCOUNT ON;

UPDATE inv.tblStorageDocsDtl
SET GoodsAmount1=GoodsAmount , GoodsAmount2=GoodsAmount, GoodsAmount3=GoodsAmount ,
 GoodsAmount4=GoodsAmount, GoodsAmount5=GoodsAmount, GoodsAmount6=GoodsAmount ,
  GoodsAmount7=GoodsAmount , GoodsAmount8=GoodsAmount , GoodsAmount9=GoodsAmount ,
   GoodsAmount10=GoodsAmount , GoodsAmount11=GoodsAmount , GoodsAmount12=GoodsAmount
      
WHERE ProcessID=@ProcessID AND ProcessNo=@ProcessNo
 AND FiscalYear=@FiscalYear AND SerialNo=@SerialNo 
	

			
End
GO
