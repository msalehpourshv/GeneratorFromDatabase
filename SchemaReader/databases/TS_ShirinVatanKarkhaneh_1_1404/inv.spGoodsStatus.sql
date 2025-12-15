USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [inv].[spGoodsStatus]
	@LanguageID		TINYINT,
	@UserID		INT,
	@IsAdmin	Bit
	 
WITH ENCRYPTION
 AS

BEGIN
	SELECT GS.StoreID,
		   pub.GetStoreName(GS.StoreID,@LanguageID) StoreName,
		   GS.GoodsID,
		   pub.funGetGoodsName(GS.GoodsID,@LanguageID) GoodsName,
		   GS.SetPoint,
		   ISNULL(SD.GoodsQuantity,0) GoodsQuantity,
		   ISNULL(GS.SetPoint-ISNULL(SD.GoodsQuantity,0),0) ShortageQuantity
	FROM inv.tblGoodsStatusDtl GS
	LEFT JOIN (SELECT StoreID,GoodsID,SUM(GoodsQuantity*EnterKind ) GoodsQuantity 
				FROM inv.tblStorageDocsDtl
				GROUP BY StoreID,GoodsID) SD
	ON GS.StoreID=SD.StoreID AND GS.GoodsID=SD.GoodsID
	WHERE ISNULL(GoodsQuantity,0)<SetPoint AND 
	 ( @IsAdmin  = 'True' OR(((SELECT COUNT(*) 
			 FROM  inv.tblStoresRng R 
			 WHERE R.UserID =@UserID AND 
		  	 R.AllowCodeView=1 AND 
			 LEFT(SD.StoreID,LEN(FromCode)) >= FromCode AND 
			 LEFT(SD.StoreID, LEN(ToCode)) <= ToCode) > 0 OR (SELECT COUNT(*) FROM  inv.tblStoresRng R  WHERE R.UserID =@UserID AND R.AllowCodeView=1 AND R.AccessAllCode =1) >0)
			 
	AND
	((SELECT COUNT(*) 
			 FROM  inv.tblGoodsRng G 
			 WHERE G.UserID =@UserID AND 
		  	 G.AllowCodeView=1 AND 
			 LEFT(SD.GoodsID,LEN(FromCode)) >= FromCode AND 
			 LEFT(SD.GoodsID,LEN(ToCode)) <= ToCode) > 0  OR ((SELECT COUNT(*) FROM  inv.tblGoodsRng G  WHERE G.UserID =@UserID AND G.AllowCodeView=1 AND G.AccessAllCode =1) >0))))
	ORDER BY GS.StoreID
			 
END
GO
