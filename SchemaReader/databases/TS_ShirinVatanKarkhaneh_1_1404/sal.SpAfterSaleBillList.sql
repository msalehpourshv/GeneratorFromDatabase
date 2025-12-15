USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/12/02
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[SpAfterSaleBillList]
	@ProcessID	SMALLINT,
	@SerialNo	INT,
	@Discount	BIT,
	@LanguageID AS TINYINT
	WITH ENCRYPTION
AS

BEGIN

	SELECT D.BaseSaleProcessID,D.BaseSaleProcessNo,D.BaseSaleFiscalYear,D.BaseSaleSerialNo,D.Price
	,ISNULL(ReceivePrice,0) ReceivePrice
	,ISNULL(H.Amount,0) ReturnPrice
		   ,D.AcntCode,pub.GetCodeName(D.AcntCode,@LanguageID) AcntName
	FROM sal.tblDistributionsDtl D
	LEFT JOIN (
		SELECT H.BaseProcessID,H.BaseProcessNo,H.BaseFiscalYear,H.BaseSerialNo,ISNULL(SUM(D.Amount),0) ReceivePrice
		FROM trs.tblPayHdr H INNER JOIN  trs.tblPayDtl D
		ON D.ProcessID = H.ProcessID AND 
		   D.ProcessNo = H.ProcessNo AND 
		   D.FiscalYear = H.FiscalYear AND 
		   D.SerialNo = H.SerialNo  
		GROUP BY  H.BaseProcessID,H.BaseProcessNo,H.BaseFiscalYear,H.BaseSerialNo
			)P
	ON  D.BaseSaleProcessID = P.BaseProcessID AND D.BaseSaleProcessNo = P.BaseProcessNo
	AND D.BaseSaleFiscalYear = P.BaseFiscalYear AND D.BaseSaleSerialNo = P.BaseSerialNo
	LEFT JOIN inv.tblStorageDocsHdr H
	ON  H.ProcessID = 100 And D.BaseSaleProcessID = H.BaseProcessID AND D.BaseSaleProcessNo = H.BaseProcessNo
	AND D.BaseSaleFiscalYear = H.BaseFiscalYear AND D.BaseSaleSerialNo = H.BaseSerialNo
	
	
	WHERE D.ProcessID=@ProcessID AND D.SerialNo=@SerialNo AND   
		((@Discount	='True' AND ReceivePrice>0 AND D.Price-ReceivePrice>0) OR 
		((@Discount	='False' AND ReceivePrice>0 AND D.Price-ReceivePrice<0)))	
			
END
GO
