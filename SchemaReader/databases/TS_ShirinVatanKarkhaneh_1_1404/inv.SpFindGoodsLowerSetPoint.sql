USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1392/04/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
Create PROCEDURE [inv].[SpFindGoodsLowerSetPoint] 
	@Fiscalyear		AS	INT,
	@UserID			AS	INT,
	@IsAdmin		AS	Bit,
	@LangID			AS INT
WITH ENCRYPTION
AS
BEGIN 
	-- ===========================================	
	DECLARE @QuantityDecimalsToForms AS Int
	SET		@QuantityDecimalsToForms = 3
	SELECT  @QuantityDecimalsToForms = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'QuantityDecimalsToForms'
	
	-- ===========================================	
	SELECT Distinct  StoreID, StoreName, SetPoint, GoodsID, GoodsName, 
					 Round(GoodsRemain, @QuantityDecimalsToForms) GoodsRemain, 
					 Round(a.SetPoint - a.GoodsRemain, @QuantityDecimalsToForms) AS ShortageQuantity 
	FROM (
			SELECT u.*, pub.GetStoreName(s.StoreID,@LangID)AS StoreName,
				   s.SetPoint, s.GoodsID, pub.GetGoodsName(s.GoodsID,@LangID) AS GoodsName,
					(
						SELECT  ISNULL (Sum(GoodsQuantity * EnterKind), 0)
						FROM inv.tblStorageDocsDtl  
						WHERE StoreID = s.StoreID AND GoodsID = s.GoodsID
						AND (FiscalYear = @Fiscalyear OR (FiscalYear <> @Fiscalyear AND EnterKind=1))
					) as GoodsRemain
			FROM inv.tblUsersRelStoresDtl u
			LEFT JOIN inv.tblGoodsStatusDtl s ON u.StoreID=s.StoreID
			WHERE 1 = 1 
			And (u.UserID = @UserID OR (@IsAdmin='True' OR ((u.UserID=@UserID AND 
												  (SELECT COUNT(*) 
												   FROM  inv.tblStoresRng R 
												   WHERE R.UserID =@UserID AND R.AllowCodeView=1 AND LEFT(s.StoreID,LEN(FromCode)) >= FromCode AND 
														 LEFT(s.StoreID, LEN(ToCode)) <= ToCode) > 0 OR 
														 (SELECT COUNT(*) 
														  FROM inv.tblStoresRng R  
														  WHERE R.UserID = @UserID AND R.AllowCodeView =1 AND R.AccessAllCode =1) > 0) 
			AND ((SELECT COUNT(*) 
				  FROM  inv.tblGoodsRng G 
				  WHERE G.UserID = @UserID AND G.AllowCodeView=1 AND LEFT(s.GoodsID,LEN(FromCode)) >= FromCode AND 
						LEFT(s.GoodsID, LEN(ToCode)) <= ToCode) > 0 OR ((SELECT COUNT(*) 
																		 FROM  inv.tblGoodsRng G  
																		 WHERE G.UserID =@UserID AND G.AllowCodeView=1 AND 
																			   G.AccessAllCode =1) >0)))))			 	 
	) a 
	WHERE SetPoint > GoodsRemain
	
END
GO
