USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 87/11/24
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spFrmTrust_ReceiveDtlListSelect] 
	@ProcessID	Tinyint,
	@ProcessNo	Tinyint,
	@StoreID    Varchar(20),
	@AcntCode	VarChar(20),
	@GoodsID	VarChar(20),
	@DocDate	Char(10),
	@LanguageID Int,
	@SerialNo	Int,
	@FiscalYear Smallint,
	@BaseSerialNo	Int,
	@BaseFiscalYear Smallint
	
WITH ENCRYPTION
 AS
BEGIN

SET NOCOUNT ON;

 IF @ProcessID = 135
	SELECT	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, BatchNo ,
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, [inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID,OD.SubUnitID,Cn.ConfirmQuantity) SubUnitQuantity, Cn.ConfirmQuantity, Cn.ConfirmQuantity GoodsQuantity, OD.QtyRemain, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,GoodsID,OD.BatchNo,DocDate,1)  AS Remain
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			SELECT ProcessID,ProcessNo, FiscalYear,SerialNo,DocRowNo,ConfirmQuantity
			FROM [inv].[FunGetOurTrust](@AcntCode,@DocDate)
			WHERE ProcessNo = @ProcessNo AND ConfirmQuantity >0		
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
		WHERE DocDate<=@DocDate AND (@GoodsID IS NULL OR GoodsID = @GoodsID) AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND --StoreID = @StoreID AND 
   		     (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear))

ELSE IF @ProcessID = 131
	SELECT	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.VolumeRowNo, OD.DocStep, 
			OD.DocDate, OD.StoreID, OD.EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, BatchNo ,
			OD.OrderAcntCode, OD.GoodsID, OD.SubUnitID, [inv].[funGetSubUnitFromGoodsQuantity](OD.GoodsID,OD.SubUnitID,Cn.ConfirmQuantity) SubUnitQuantity, Cn.ConfirmQuantity, Cn.ConfirmQuantity GoodsQuantity, OD.QtyRemain, 
			OD.GoodsAmount, OD.AtomAmount, OD.GoodsPrice, OD.DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.AgreeNo, OD.DocRowNo,
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
						OD.FiscalYear,OD.SerialNo,OD.DocRowNo,StoreID,GoodsID,OD.BatchNo,DocDate,1)  AS Remain
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			SELECT ProcessID,ProcessNo, FiscalYear,SerialNo,DocRowNo,ConfirmQuantity
			FROM [inv].[FunGetOtherTrust](@AcntCode,@DocDate)
			WHERE ProcessNo = @ProcessNo AND ConfirmQuantity >0			
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo AND 
				Cn.DocRowNo = OD.DocRowNo 
		WHERE DocDate<=@DocDate AND (@GoodsID IS NULL OR GoodsID = @GoodsID) AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND --StoreID = @StoreID AND 
   		     (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear))

END








GO
