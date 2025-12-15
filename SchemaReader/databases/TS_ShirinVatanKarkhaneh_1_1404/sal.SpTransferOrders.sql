USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/10
-- Viewed By	 : 
-- Last Modified : 1391/01/23
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست سفارشات تحویل داده نشده جهت انتقال
-- =============================================
Create PROCEDURE [sal].[SpTransferOrders]
	@FiscalYear	int,
	@DocRet		bit = 0,
	@Remain		bit = 0
WITH ENCRYPTION
AS 

DECLARE @StrSelect	NVarChar(max);
DECLARE @StrSelect2	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE @Factor1	int;
DECLARE @Factor2	int;

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	if (@DocRet = 1)
		set @Factor1 = 1
	else
		set @Factor1 = 0

	if (@Remain = 1)
		set @Factor2 = 1
	else
		set @Factor2 = 0

	DECLARE @GetRemainSaleOrder bit;
	SET @GetRemainSaleOrder = 'False'
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'		

set @StrSelect2=''
	-- W H E R E ------------------------------------------------------------
	SET @StrWhere = '1 = 1'
	IF @GetRemainSaleOrder = 'True'
		SET @StrWhere = @StrWhere + ' AND Round(T.OrdQty - T.SoldQty, 2) > 0'
	ELSE
	BEGIN
		SET @StrWhere = @StrWhere + '  AND Round(T.OrdQty, 2) > 0 AND Round(T.SoldQty, 2) = 0 '
		set @StrSelect2=		'INNER JOIN
			(	SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
				WHERE ProcessID=180  
				EXCEPT
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
				WHERE BaseProcessID=180 AND ProcessID=90  
			) A
			ON A.ProcessID=ORD.ProcessID AND A.ProcessNo=ORD.ProcessNo AND A.FiscalYear=ORD.FiscalYear AND A.SerialNo=ORD.SerialNo'
	END		
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT	ORD.*, T.SoldQty as SoldQuantity,(T.OrdQty - T.SoldQty) AS RemainQuantity,inv.funGetSubUnitFromGoodsQuantity(GoodsID,SubUnitID,(T.OrdQty - T.SoldQty)) RemainSubUnitQuantity
	FROM sal.tblSaleOrderDtl ORD ' + @StrSelect2 +'
	INNER JOIN
	(
		SELECT	ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, 
				(GoodsQuantity - 
					(
						SELECT	IsNull(Sum(GoodsQuantity), 0)
						FROM	sal.tblSaleOrderDtl
						WHERE	BaseProcessID = ORD.ProcessID AND BaseProcessNo = ORD.ProcessNo AND BaseFiscalYear = ORD.FiscalYear AND BaseSerialNo = ORD.SerialNo AND BaseDocRowNo = ORD.DocRowNo
					) 
				) AS OrdQty,
				(
					-- Sold Pure Qty = sum of sold qty - sum of sold return qty
					SElECT IsNull(Sum(SOLD.GoodsQuantity - SOLD.SoldRet), 0)
					FROM
					(
						SELECT	SD.GoodsQuantity, 
								(
									SELECT IsNull(Sum(GoodsQuantity), 0)
									FROM   inv.tblStorageDocsDtl
									WHERE  BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND BaseDocRowNo = SD.DocRowNo 
								) * ' + LTrim(Str(@Factor1)) + ' AS SoldRet
						FROM	inv.tblStorageDocsDtl SD
						WHERE	SD.ProcessID = 90 AND SD.BaseProcessID = ORD.ProcessID AND SD.BaseProcessNo = ORD.ProcessNo AND SD.BaseFiscalYear = ORD.FiscalYear AND SD.BaseSerialNo = ORD.SerialNo AND SD.BaseDocRowNo = ORD.DocRowNo
					) AS SOLD
				) AS SoldQty
		FROM	sal.tblSaleOrderDtl AS ORD
		WHERE   (ORD.FiscalYear <= ' + LTrim(Str(@FiscalYear)) + ') and (ORD.ProcessID  = 180)
	) T ON ORD.ProcessID = T.ProcessID AND ORD.ProcessNo = T.ProcessNo AND ORD.FiscalYear = T.FiscalYear AND ORD.SerialNo = T.SerialNo AND ORD.DocRowNo = T.DocRowNo
	WHERE ' + @StrWhere + '
	ORDER BY T.FiscalYear, T.SerialNo, T.DocRowNo'
	
	---- R U N ----------------------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
			
END
GO
