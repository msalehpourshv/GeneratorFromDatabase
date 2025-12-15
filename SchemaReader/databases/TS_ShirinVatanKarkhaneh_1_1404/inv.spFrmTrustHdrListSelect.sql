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

CREATE PROCEDURE [inv].[spFrmTrustHdrListSelect] 
	@BaseProcessID		tinyint,
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@DocDate		Char(10),
	@AcntCode		varchar(20),
	@StoreID		varchar(20),
	@DocStep		Tinyint,
	@SerialNo		Int,
	@FiscalYear		Smallint
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

IF @DocDate =''
	SELECT Distinct ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate, 
				    SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5,AcntCode, pub.GetCodeName(AcntCode,1) AS AcntName 
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID= @ProcessID AND ProcessNo= @ProcessNo AND DocStep=@DocStep 

ELSE IF @ProcessID = 135

	SELECT DISTINCT OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,DocDate,AcntCode, pub.GetCodeName(AcntCode,1) AS AcntName 
	FROM inv.tblStorageDocsDtl OD 
	INNER JOIN
	(
		SELECT * FROM [inv].[FunGetOurTrust](@AcntCode,@DocDate)	
		WHERE ProcessNo = @ProcessNo AND ConfirmQuantity >0		
	) Cn ON Cn.ProcessID  = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
			Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo 
	--WHERE StoreID = @StoreID

ELSE IF @ProcessID = 131

	SELECT DISTINCT OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,DocDate,AcntCode, pub.GetCodeName(AcntCode,1) AS AcntName 
	FROM inv.tblStorageDocsDtl OD 
	INNER JOIN
	(
		SELECT * FROM [inv].[FunGetOtherTrust](@AcntCode,@DocDate)	
		WHERE ProcessNo = @ProcessNo AND ConfirmQuantity >0		
	) Cn ON Cn.ProcessID  = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
			Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo 
	--WHERE StoreID = @StoreID

END






GO
