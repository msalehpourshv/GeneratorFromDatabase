USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/11/15
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1389/06/25
-- Last Modifier : TakroSystem\Zia
-- Description   : (سفارشات آماده تحویل یک برگه (وضعیت تحویل برای یک سفارش
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_ReadyDoc]
	@ProcessID		Int = 180, -- Sale Order Process ID
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@RepOptions		VarChar(20) = '00', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @BaseQty	Int;
DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @ZeroBalance	Bit;   -- کالاهای با موجودی صفر را شامل شود یا نه؟
Declare @DecRet			Bit; 
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	
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
	
	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1;
	If (@ZeroBalance Is Null)	SET @ZeroBalance = 0;
	IF (@RepOptions	Is Null)	SET @RepOptions = '00';

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ZeroBalance= Substring(@RepOptions, 1, 1);
	SET @DecRet		= Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	IF (@ZeroBalance = 0) 
		SET @BaseQty = 0
	Else
		SET @BaseQty = -1

	-- ================================================
	SELECT *
	FROM
	(
		SELECT	D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, D.GoodsID, D.GoodsQuantity, 
				[pub].[funGetGoodsName](D.GoodsID, @LangID) GoodsName, 
				IsNull([inv].[FunGetGoodsBarCode] (D.GoodsID), '') BarCode, 
				(
					SELECT	IsNull(Sum(GoodsQuantity), 0)
					FROM	sal.tblSaleOrderDtl
					WHERE	BaseProcessID = D.ProcessID AND BaseProcessNo = D.ProcessNo AND BaseFiscalYear = D.FiscalYear AND BaseSerialNo = D.SerialNo AND BaseDocRowNo = D.DocRowNo
				) AS CancelQty,
				(
					-- Sale Pure Qty = sum of sold qty - sum of sold return qty
					SELECT IsNull(Sum(Sold - SoldRet), 0)
					FROM
					(
						SELECT	GoodsQuantity AS Sold, case when (@DecRet = 1) then
								(
									SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
									FROM    inv.tblStorageDocsDtl
									WHERE   BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND	BaseDocRowNo = SD.DocRowNo
								) else 0 end AS SoldRet
						FROM	inv.tblStorageDocsDtl SD
						WHERE	SD.ProcessID = 90 AND SD.BaseProcessID = D.ProcessID  AND SD.BaseProcessNo = D.ProcessNo AND	SD.BaseFiscalYear = D.FiscalYear AND SD.BaseSerialNo = D.SerialNo AND SD.BaseDocRowNo = D.DocRowNo
					) SaleAndRet
				) AS SoldQty,
				[inv].[funGetGoodsRemain](NULL, NULL, D.FiscalYear, NULL, NULL, NULL, D.GoodsID, '', D.DocDate, 0) As GoodsBalance
				--[inv].[funGetGoodsQuantity](D.GoodsID, Null, Null) As GoodsBalance
		FROM    sal.tblSaleOrderDtl AS D
		INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = SUBSTRING(D.GoodsID,@str_Goods+1, @str_GoodsSum) AND G.PartNumber= @UnitPart AND G.LanguageID = @LangID
					
		WHERE   D.ProcessID = @ProcessID AND D.ProcessNo = @ProcessNo AND D.FiscalYear = @FiscalYear AND D.SerialNo = @SerialNo
	) T
	WHERE	T.GoodsBalance > @BaseQty
	---------------------------------------------------------------------------
END
GO
