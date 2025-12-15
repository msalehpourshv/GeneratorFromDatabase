USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/07
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Inv Transfer Docs
-- ----------------------------------------------
--  موجودی آخر دوره انبار جهت انتقال
-- ==============================================
Create PROCEDURE [inv].[SpTransferDocsList]
WITH ENCRYPTION
AS
DECLARE @fy Int 
BEGIN

	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	DECLARE @AllowStoreNegativeBalance bit
	set @AllowStoreNegativeBalance ='False'
	SELECT @AllowStoreNegativeBalance = SettingValue from pub.tblSettings where SettingKey = 'AllowStoreNegativeBalance'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart	

	SET @fy = Cast(right(db_name(),4) As Int)
	
	Delete FROM inv.tblSubUnitsDtl WHERE MainUnitValue=0
	--=====================================
	SELECT D.StoreID, D.GoodsID,G.UnitID,D.BatchNo,D.UserPriceID,
		   Case When NOT(SU.GoodsID IS NULL) AND (SU.ToleranceValue <> 0 OR SU.TolerancePercent <> 0) THEN SU.SubUnitID ELSE G.UnitID END SubUnitID, 
		   Sum(D.GoodsQuantity * D.EnterKind) AS Remain, 
		   IsNull(Sum(Case When NOT(SU.GoodsID IS NULL) AND (D.SubUnitID = SU.SubUnitID) Then 
								D.SubUnitQuantity 
							Else 
								GoodsQuantity * (SU.UnitValue / SU.MainUnitValue) End * D.EnterKind),0) SubUnitRemain,
		   Round(Sum(D.GoodsQuantity * D.EnterKind * D.GoodsAmount12 +CASE WHEN ProcessID =51 THEN D.EnterKind*D.GoodsPrice ELSE 0 END  ), 1) AS Amount
	FROM	inv.tblStorageDocsDtl D 
	INNER JOIN inv.tblGoods G ON SubString(D.GoodsID,@str_Goods+1,@str_GoodsSum) = G.GoodsID  AND G.PartNumber=@UnitPart
	LEFT JOIN (SELECT * FROM inv.tblSubUnitsDtl WHERE ShowInInvoice = 'True') SU 	ON D.GoodsID=SU.GoodsID
	WHERE  ((D.FiscalYear = @fy) OR (D.FiscalYear <> @fy and D.ProcessID Not In (70,80))) AND G.IsService='False'  -- AND (D.PhysicallyEffected = 1)
	GROUP BY D.StoreID, D.GoodsID,G.UnitID,D.BatchNo,D.UserPriceID,
			 Case When NOT(SU.GoodsID IS NULL) AND (SU.ToleranceValue <> 0 OR SU.TolerancePercent <> 0) THEN SU.SubUnitID ELSE G.UnitID END
	HAVING   (@AllowStoreNegativeBalance = 'True' and Sum(D.GoodsQuantity * D.EnterKind) <> 0)  or Sum(D.GoodsQuantity * D.EnterKind) > 0
	ORDER BY D.StoreID, D.GoodsID, G.UnitID,D.BatchNo,D.UserPriceID

END
GO
