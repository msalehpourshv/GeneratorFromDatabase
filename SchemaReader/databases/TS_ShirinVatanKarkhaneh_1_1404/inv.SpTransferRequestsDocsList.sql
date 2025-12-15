USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1401/01/29
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Inv Transfer Requests
-- ----------------------------------------------
--     درخواست انتقال بین انبار جهت انتقال
-- ==============================================
Create PROCEDURE inv.SpTransferRequestsDocsList
WITH ENCRYPTION
AS
BEGIN

		SELECT OD.* 
		FROM	
			(
				Select	CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo , CmrCnf.DocRowNo,
						CmrCnf.ConfirmQuantity - ISNULL(StorageDocs.ConfirmQuantity,0) AS ConfirmQuantity, CmrCnf.DocDesc,
						CmrCnf.IntTrnTypID
				From
				(
					Select	A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.DocRowNo, A.DocDate, H.DocDesc,
							H.IntTrnTypID, A.GoodsQuantity - ISNULL(B.GoodsQuantity,0) As ConfirmQuantity
					FROM  inv.tblStoresRequestsDtl A
					INNER JOIN inv.tblStoresRequestsHdr H ON A.ProcessID = H.ProcessID AND A.ProcessNo = H.ProcessNo AND 
														  A.FiscalYear = H.FiscalYear AND A.SerialNo  = H.SerialNo
					LEFT  JOIN  ( Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) GoodsQuantity From inv.tblStoresRequestsDtl 
				group by  BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo)B
					ON A.ProcessID = B.BaseProcessID AND A.ProcessNo = B.BaseProcessNo AND A.FiscalYear = B.BaseFiscalYear AND 
    				   A.SerialNo  = B.BaseSerialNo AND A.DocRowNo  = B.BaseDocRowNo 
					WHERE A.ProcessID = 127 AND A.GoodsQuantity - ISNULL(B.GoodsQuantity,0)>0  					
				) CmrCnf 
			LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
					From [inv].[FunGetBaseStorageDocsStoreTransfer](NULL,'9999/12/29') 
				) StorageDocs
				ON CmrCnf.ProcessID  = StorageDocs.BaseProcessID  AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
				   CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo   = StorageDocs.BaseSerialNo  AND 
				   CmrCnf.DocRowNo   = StorageDocs.BaseDocRowNo  AND CmrCnf.DocDate<='9999/12/29' 
			) CMROrderHdr
		INNER JOIN
		inv.tblStoresRequestsDtl OD	ON OD.ProcessID = CMROrderHdr.ProcessID AND  OD.ProcessNo = CMROrderHdr.ProcessNo AND 
									   OD.FiscalYear = CMROrderHdr.FiscalYear AND OD.SerialNo = CMROrderHdr.SerialNo AND 
									   OD.DocRowNo = CMROrderHdr.DocRowNo 
		WHERE (NULL IS NULL OR AcntCode = NULL) AND OD.DocDate <= '9999/12/29' AND CMROrderHdr.ConfirmQuantity>0 

END
GO
