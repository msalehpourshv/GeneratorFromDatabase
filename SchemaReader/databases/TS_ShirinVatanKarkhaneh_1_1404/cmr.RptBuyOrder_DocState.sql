USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/10/16
-- Viewed By	 : 
-- Last Modified : 1387/06/03
-- Description   : وضعیت خرید برای یک سفارش
-- =============================================
CREATE PROCEDURE [cmr].[RptBuyOrder_DocState]
	@ProcessID		Int = 160, 
	-- 160 = Buy Order
	-- 165 = Buy Order Cancel
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@LanguageID		Int = 1
WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @PID_BUY		TinyInt;
DECLARE @PID_BUY_RET	TinyInt;
DECLARE @PID_ORD		TinyInt;
DECLARE @PID_ORD_CNL	TinyInt;
Begin --============== S T A R T  C O D E ======================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

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
	If (@ProcessID  Is Null) SET @ProcessID  = 160;
	If (@ProcessNo  Is Null) SET @ProcessNo  = 1;
	If (@LanguageID Is Null) SET @LanguageID = 1;
	If (@FiscalYearTo  Is Null) SET @FiscalYearTo  = @FiscalYear;
	If (@SerialNoTo  Is Null)	SET @SerialNoTo  = @SerialNo;

	SET @PID_ORD = 160;		-- ProcessID for Order
	SET @PID_ORD_CNL = 165;	-- ProcessID for Order Cancel
	SET @PID_BUY = 55;		-- ProcessID for Buy
	SET @PID_BUY_RET = 60;	-- ProcessID for Buy Return
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SELECT	ORD.FiscalYear, ORD.SerialNo, ORD.RowNo, ORD.DocRowNo, ORD.GoodsID, 
			[pub].[funGetGoodsName](ORD.GoodsID,@LanguageID) GoodsName, 
			IsNull([inv].[FunGetGoodsBarCode] (ORD.GoodsID), '') BarCode, ORD.GoodsQuantity,
			ORD.ConfirmQuantity AS RequestedQty, ORD.AcntCode,
			pub.GetCodeName(ORD.AcntCode, @LanguageID) AS AcntName, ORD.DocDate,
			-- Cancel Qty for CMR
			(
				SELECT	IsNull(Sum(CNL.GoodsQuantity), 0)
				FROM	cmr.tblOrderDtl AS CNL
				WHERE	CNL.BaseProcessID  = ORD.ProcessID AND CNL.BaseProcessNo = ORD.ProcessNo AND
						CNL.BaseFiscalYear = ORD.FiscalYear AND CNL.BaseSerialNo = ORD.SerialNo AND
						CNL.BaseDocRowNo   = ORD.DocRowNo AND CNL.ProcessID = @PID_ORD_CNL
			) AS CanceledQty,
			-- Purchased Qty for CMR
			IsNull(Sum(BUY.Qty), 0) AS BoughtQty
	FROM    cmr.tblOrderDtl AS ORD 
			INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(ORD.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LanguageID
			-- Calculating Purchased Qty ...
			LEFT JOIN
			(
				-- ORDER -> BUY
				SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = @PID_BUY_RET
					) AS Qty
				FROM	cmr.tblOrderDtl C INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = C.ProcessID AND S.BaseProcessNo = C.ProcessNo AND S.BaseFiscalYear = C.FiscalYear AND S.BaseSerialNo = C.SerialNo AND S.BaseDocRowNo = C.DocRowNo
				WHERE	S.ProcessID = @PID_BUY
				UNION all
				-- ORDER -> RECEIPT -> BUY
				SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = @PID_BUY_RET
					) AS Qty
				FROM	cmr.tblOrderDtl C 
						LEFT JOIN inv.tblInvTempReceiptDtl R
						ON R.BaseProcessID = C.ProcessID AND R.BaseProcessNo = C.ProcessNo AND R.BaseFiscalYear = C.FiscalYear AND R.BaseSerialNo = C.SerialNo AND R.BaseDocRowNo = C.DocRowNo
						INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
				WHERE S.ProcessID = @PID_BUY
			) AS BUY
			ON	BUY.ProcessID = ORD.ProcessID AND BUY.ProcessNo = ORD.ProcessNo AND 
				BUY.FiscalYear = ORD.FiscalYear AND BUY.SerialNo = ORD.SerialNo AND BUY.DocRowNo = ORD.DocRowNo
	WHERE   ORD.ProcessID  = @ProcessID  AND ORD.ProcessNo = @ProcessNo AND
			ORD.FiscalYear >= @FiscalYear AND ORD.SerialNo  >= @SerialNo AND
			ORD.FiscalYear <= @FiscalYearTo AND ORD.SerialNo  <= @SerialNoTo
	GROUP BY ORD.ProcessID, ORD.ProcessNo, ORD.FiscalYear, ORD.SerialNo, ORD.DocRowNo, ORD.RowNo, ORD.GoodsID,ORD.GoodsQuantity, ORD.ConfirmQuantity, GD.GoodsName, ORD.AcntCode, ORD.DocDate
End
GO
