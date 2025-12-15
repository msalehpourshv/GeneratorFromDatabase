USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [sal].[SP_CheckGoodsIDAfterSave]
@ProcessID  int,
@ProcessNo  int,
@FiscalYear int,
@SerialNo   int

WITH ENCRYPTION
 AS
BEGIN
DECLARE @StrSelect as NVarChar(1000)

SELECT 1 R,DocRowNo,GoodsID INTO #T 
FROM sal.tblRestaurantSaleDtl
WHERE ProcessID = @ProcessID
  AND ProcessNo = @ProcessNo
  AND FiscalYear = @FiscalYear
  AND SerialNo = @SerialNo
  AND GoodsID not in (select GoodsID from inv.tblGoods)

IF (SELECT COUNT(*) FROM #T)>0
    BEGIN 
    	SET @StrSelect = 'SELECT * FROM #T'
    END
ELSE
    BEGIN
    	DECLARE @L AS TINYINT = 0
    	SELECT @L= pub.funGetLayerLen('inv.tblGoods',1,9,1)-1
    
    	SET @StrSelect = 
		'SELECT 2 R,DocRowNo,GoodsID 
    	FROM sal.tblRestaurantSaleDtl a
    	WHERE ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) +'
          AND ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) +'
          AND FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear))) +'
          AND SerialNo = ' + LTrim(RTrim(Str(@SerialNo))) +'
          AND LEN(GoodsID)<' + LTrim(RTrim(Str(@L))) + '
          AND (SELECT COUNT(*) 
    	       FROM inv.tblGoods b 
    	       WHERE LEFT(b.GoodsID,len(a.GoodsID)) = a.GoodsID)>1'
	END 

	PRINT @StrSelect
	EXEC sp_executesql @StrSelect;

END 
GO
