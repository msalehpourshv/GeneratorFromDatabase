USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/10/16
-- Viewed By	 : 
-- Last Modified : 1387/06/03
-- Description   : وضعیت خرید برای یک درخواست
-- =============================================
Create PROCEDURE [cmr].[RptCMR_DocState]
	@ProcessID		Int = 150, 
	-- 150 = Buy Request
	-- 155 = Buy Request Cancel
	@ProcessNo		Int = 1,
	@FiscalYear		SmallInt,
	@SerialNo		Int,
	@FiscalYearTo	SmallInt,
	@SerialNoTo		Int,
	@LanguageID		TinyInt = 1
	WITH ENCRYPTION
AS 
DECLARE @StrSelect		NVarChar(4000);
DECLARE @PID_BUY		TinyInt;
DECLARE @PID_BUY_RET	TinyInt;
DECLARE @PID_REQ		TinyInt;
DECLARE @PID_REQ_CNL	TinyInt;
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
	If (@ProcessID  Is Null) SET @ProcessID  = 150;
	If (@ProcessNo  Is Null) SET @ProcessNo  = 1;
	If (@LanguageID Is Null) SET @LanguageID = 1;

	If (@FiscalYearTo  Is Null) SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo  Is Null)	SET @SerialNoTo = @SerialNo;

	SET @PID_BUY = 55;		-- ProcessID for Buy
	SET @PID_BUY_RET = 60;	-- ProcessID for Buy Return
	SET @PID_REQ = 150;		-- ProcessID for Request
	SET @PID_REQ_CNL = 155;	-- ProcessID for Request Cancel
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	SELECT	REQ.FiscalYear, REQ.SerialNo, REQ.RowNo, REQ.DocRowNo, REQ.AcntCode,
			REQ.GoodsID,REQ.DescDtl, Hdr.DocDesc, [pub].[funGetGoodsName](REQ.GoodsID,@LanguageID) GoodsName, 
			IsNull([inv].[FunGetGoodsBarCode] (REQ.GoodsID), '') BarCode, 	
			REQ.ConfirmQuantity AS RequestedQty, REQ.DocDate,
			pub.GetCodeName(REQ.AcntCode, @LanguageID) AS AcntName,
			-- Cancel Qty for CMR 
			(
				SELECT	IsNull(Sum(CNL.ConfirmQuantity), 0)
				FROM	cmr.tblCMRDtl AS CNL
				WHERE	CNL.BaseProcessID  = REQ.ProcessID AND CNL.BaseProcessNo = REQ.ProcessNo AND
						CNL.BaseFiscalYear = REQ.FiscalYear AND CNL.BaseSerialNo  = REQ.SerialNo AND
						CNL.BaseDocRowNo   = REQ.DocRowNo AND CNL.ProcessID = @PID_REQ_CNL
			) AS CanceledQty,
			-- Purchased Qty for CMR
			IsNull(Sum(BUY.Qty), 0) AS BoughtQty
	FROM    cmr.tblCMRDtl AS REQ 
	INNER JOIN cmr.tblCMRHdr Hdr ON Hdr.ProcessID=REQ.ProcessID and Hdr.ProcessNo=REQ.ProcessNo	and Hdr.FiscalYear=REQ.FiscalYear and Hdr.SerialNo=REQ.SerialNo	
	INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(REQ.GoodsID,@str_Goods+1, @str_GoodsSum) AND GD.PartNumber= @UnitPart AND GD.LanguageID = @LanguageID
			-- Calculating Purchased Qty ...
			LEFT JOIN
			(
				-- REQ -> BUY
				SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = @PID_BUY_RET
					) AS Qty
				FROM	cmr.tblCMRDtl C INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = C.ProcessID AND S.BaseProcessNo = C.ProcessNo AND S.BaseFiscalYear = C.FiscalYear AND S.BaseSerialNo = C.SerialNo AND S.BaseDocRowNo = C.DocRowNo
				WHERE	S.ProcessID = @PID_BUY
				UNION all
				-- REQ -> ORD -> BUY
				SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = @PID_BUY_RET
					) AS Qty
				FROM	cmr.tblCMRDtl C 
						INNER JOIN cmr.tblOrderDtl O
						ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
						INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = O.ProcessID AND S.BaseProcessNo = O.ProcessNo AND S.BaseFiscalYear = O.FiscalYear AND S.BaseSerialNo = O.SerialNo AND S.BaseDocRowNo = O.DocRowNo
				WHERE S.ProcessID = @PID_BUY
				UNION all
				-- REQ -> REC -> BUY
				SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = @PID_BUY_RET
					) AS Qty
				FROM	cmr.tblCMRDtl C 
						LEFT JOIN inv.tblInvTempReceiptDtl R
						ON R.BaseProcessID = C.ProcessID AND R.BaseProcessNo = C.ProcessNo AND R.BaseFiscalYear = C.FiscalYear AND R.BaseSerialNo = C.SerialNo AND R.BaseDocRowNo = C.DocRowNo
						INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
				WHERE S.ProcessID = @PID_BUY
				UNION all
				-- REQ -> ORD -> REC -> BUY
				SELECT	C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.DocRowNo, S.GoodsQuantity -
					(
						SELECT	IsNULL(Sum(GoodsQuantity), 0)
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = S.ProcessID AND BaseProcessNo = S.ProcessNo AND
								BaseFiscalYear = S.FiscalYear AND BaseSerialNo = S.SerialNo AND
								BaseDocRowNo = S.DocRowNo AND ProcessID = @PID_BUY_RET
					) AS Qty
				FROM	cmr.tblCMRDtl C 
						INNER JOIN cmr.tblOrderDtl O
						ON O.BaseProcessID = C.ProcessID AND O.BaseProcessNo = C.ProcessNo AND O.BaseFiscalYear = C.FiscalYear AND O.BaseSerialNo = C.SerialNo AND O.BaseDocRowNo = C.DocRowNo
						LEFT JOIN inv.tblInvTempReceiptDtl R
						ON R.BaseProcessID = O.ProcessID AND R.BaseProcessNo = O.ProcessNo AND R.BaseFiscalYear = O.FiscalYear AND R.BaseSerialNo = O.SerialNo AND R.BaseDocRowNo = O.DocRowNo
						INNER JOIN inv.tblStorageDocsDtl S
						ON S.BaseProcessID = R.ProcessID AND S.BaseProcessNo = R.ProcessNo AND S.BaseFiscalYear = R.FiscalYear AND S.BaseSerialNo = R.SerialNo AND S.BaseDocRowNo = R.DocRowNo
				WHERE S.ProcessID = @PID_BUY
			) AS BUY
			ON	BUY.ProcessID = REQ.ProcessID AND BUY.ProcessNo = REQ.ProcessNo AND 
				BUY.FiscalYear = REQ.FiscalYear AND BUY.SerialNo = REQ.SerialNo AND BUY.DocRowNo = REQ.DocRowNo
	WHERE   REQ.ProcessID = @ProcessID AND REQ.ProcessNo = @ProcessNo AND
			REQ.FiscalYear >= @FiscalYear AND REQ.SerialNo >= @SerialNo AND
			REQ.FiscalYear <= @FiscalYearTo AND REQ.SerialNo <= @SerialNoTo
	GROUP BY REQ.ProcessID, REQ.ProcessNo, REQ.FiscalYear, REQ.SerialNo, REQ.DocRowNo, 
			REQ.RowNo, REQ.GoodsID, REQ.ConfirmQuantity, GD.GoodsName, REQ.AcntCode, REQ.DocDate
			,REQ.DescDtl, Hdr.DocDesc
End
GO
