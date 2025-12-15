USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1404/03/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : Set Wrong Event Nos
-- =============================================
Create PROCEDURE [trs].[spChequeEventNoSetup] 

WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;
	UPDATE trs.tblPayDtl
	SET EventNo = EVN
	FROM trs.tblPayDtl a
	INNER JOIN (
				SELECT ROW_NUMBER()over(partition by a.VolumeFiscalYear,a.VolumeRowNo ORDER BY DocDate,a.VolumeRowNo,ProcessID) EVN,
					   a.* 
				FROM trs.tblPayDtl a
				INNER JOIN ( 
							SELECT VolumeFiscalYear,
								   VolumeRowNo,
								   ChequeNo,
								   EventNo 
							FROM trs.tblPayDtl
							WHERE VolumeRowNo > 0 
							  AND ProcessID <> 41
							GROUP BY VolumeFiscalYear, VolumeRowNo, ChequeNo, EventNo
							HAVING COUNT(*) > 1) b ON a.VolumeFiscalYear = b.VolumeFiscalYear 
												  AND a.VolumeRowNo = b.VolumeRowNo 
												  AND a.ChequeNo = b.ChequeNo 
				)b ON a.ProcessID = b.ProcessID 
				  AND a.ProcessNo = b.ProcessNo 
				  AND a.FiscalYear = b.FiscalYear 
				  AND a.SerialNo = b.SerialNo 
				  AND a.RowNo = b.RowNo
	WHERE a.EventNo <> EVN and (SELECT COUNT(*) 
								FROM trs.tblPayDtl c 
								WHERE a.VolumeFiscalYear = c.VolumeFiscalYear 
								  AND a.VolumeRowNo = c.VolumeRowNo 
								  AND a.ChequeNo = c.ChequeNo 
								  AND a.DocDate = c.DocDate)=1
END
GO
