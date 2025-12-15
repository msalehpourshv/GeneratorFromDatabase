USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION inv.GetGoodsLayerStartPoint(@partNumber INT)
RETURNS    INT 
WITH ENCRYPTION
AS 
 BEGIN
 DECLARE @ln AS INT=0
;WITH cte AS (
	SELECT  PartNumber ,
	SUM(Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9) sumln
	FROM    pub.tblCodeLayer
	WHERE TableName = 'inv.tblGoods' 
	GROUP BY PartNumber  
	),rnk AS
	( 
	SELECT sumln, PartNumber,Row_Number () OVER (ORDER BY PartNumber) rownum
	FROM cte
	)
	SELECT  @ln=(SELECT ISNULL(SUM(sumln),0) FROM rnk c2 WHERE c2.rownum< c1.rownum  )  
	FROM rnk c1  WHERE PartNumber=@partNumber
 
 RETURN @ln+1
END 
 
  
GO
