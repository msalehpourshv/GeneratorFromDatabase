USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[SPStoreStock_PreSaleRemain]
	@StoreID	Varchar(20) = Null,
	@GoodsID	Varchar(20)	= Null
WITH ENCRYPTION
AS

BEGIN

DECLARE @LanguageID TinyInt;

SET NOCOUNT ON;

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	
	SET @LanguageID = pub.funGetCurrentLanguageID();
	
	-- ==========
	DECLARE @UserName NVarChar(4000)
	SET @UserName = ''
	SELECT @UserName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Pub_CurrentUserName'
		
	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- ============================================================= Where
	SET @StrSelect = ''
	SET @StrWhere = 'A.PreSaleQty - A.SaleQty > 0'
	
	IF (@StoreID <> '') And (@StoreID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND A.StoreID Like ''%' + @StoreID + '%'''
			
	IF (@GoodsID <> '') And (@GoodsID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND A.GoodsID Like ''%' + @GoodsID + '%'''	
	
	-- ============================================================= Select
	SET @StrSelect = '
		SELECT LTrim(Str(A.FiscalYear)) + ''/'' + LTrim(Str(A.SerialNo)) FiscalSerial, 
			   ISNULL(A.PreSaleQty - A.SaleQty, 0) PreSaleRemain
		FROM
		(
			SELECT P.ProcessID, P.ProcessNo, P.FiscalYear, P.SerialNo, P.DocRowNo, P.StoreID,
				   IsNull(S.ProcessID, 0) SaleProcessID, IsNull(S.ProcessNo, 0) SaleProcessNo, 
				   IsNull(S.FiscalYear, 0) SaleFiscalYear, IsNull(S.SerialNo, 0) SaleSerialNo, 
				   IsNull(S.DocRowNo, 0) SaleDocRowNo, P.GoodsID2 GoodsID,
				   IsNull(P.GoodsQuantity, 0) PreSaleQty, IsNull(S.VirtualQuantity, 0) SaleQty,
				   IsNull(P.GoodsQuantity, 0) - IsNull(S.VirtualQuantity, 0) PreSaleRemain
			FROM inv.tblPreSaleDtl P
			INNER JOIN inv.tblPreSaleHdr PH ON PH.ProcessID = P.ProcessID And PH.ProcessNo = P.ProcessNo And
											   PH.FiscalYear = P.FiscalYear And PH.SerialNo = P.SerialNo And 
											   PH.ConfirmState In (0, 1) 
			LEFT JOIN inv.tblStorageDocsDtl S ON S.BaseProcessID = P.ProcessID And S.BaseProcessNo = P.ProcessNo And
												 S.BaseFiscalYear = P.FiscalYear And S.BaseSerialNo = P.SerialNo And 
												 S.BaseDocRowNo = P.DocRowNo
			WHERE P.ProcessID = 240 And P.ProcessNo = 1 
				  --And P.FiscalYear = @FiscalYear And P.SerialNo = @SerialNo
		) A
		Where ' + @StrWhere
	-- =============================================================
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- =============================================================
		
END
GO
