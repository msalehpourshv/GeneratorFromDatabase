USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1388/01/09
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : <Loans Remain Instalments>
-- ----------------------------------------------
-- گزارش اقساط مانده وامهای دریافت شده جهت انتقال
-- ==============================================
Create PROCEDURE [trs].[SpTransferLoans]
WITH ENCRYPTION
As
BEGIN   

	SET NOCOUNT ON;

	SELECT	* from 
(	
	select a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.RowNo,a.InstallmentNo,a.BaseProcessID,a.BaseProcessNo,a.BaseFiscalYear,a.BaseSerialNo,a.InstallmentDate,a.CurrencyTypeID	,a.CurrencyRate	
	,a.InstallmentAmount-isnull(b.InstallmentAmount,0) InstallmentAmount,a.InstallmentCost-isnull(b.InstallmentCost,0) InstallmentCost
		,a.InstallmentFine-isnull(b.InstallmentFine,0) InstallmentFine,a.DocRowNo,a.SourceSerialNo,a.SourceProcessNo,a.HeseYear,a.HeseAmount	
	from 
	(SELECT * FROM trs.tblLoanDtl WHERE ProcessID = 7  ) a
	left join 
	(SELECT  SUm(InstallmentAmount) InstallmentAmount, SUm(InstallmentCost) InstallmentCost, SUm(InstallmentFine) InstallmentFine,ProcessID,ProcessNo,FiscalYear,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,InstallmentNo 
		FROM trs.tblLoanDtl
		WHERE ProcessID = 8 
		group by ProcessID,ProcessNo,FiscalYear,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,InstallmentNo 		
		 ) b
	on  a.ProcessID = b.BaseProcessID AND a.ProcessNo = b.BaseProcessNo AND a.FiscalYear = b.BaseFiscalYear AND a.SerialNo = b.BaseSerialNo AND a.InstallmentNo = b.InstallmentNo 
	where  (a.InstallmentAmount-isnull(b.InstallmentAmount,0)>0 or a.InstallmentCost-isnull(b.InstallmentCost,0)>0 or a.InstallmentFine-isnull(b.InstallmentFine,0)>0)

	union 
	
	select a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.RowNo,a.InstallmentNo,a.BaseProcessID,a.BaseProcessNo,a.BaseFiscalYear,a.BaseSerialNo,a.InstallmentDate,a.CurrencyTypeID	,a.CurrencyRate	
	,a.InstallmentAmount-isnull(b.InstallmentAmount,0) InstallmentAmount,a.InstallmentCost-isnull(b.InstallmentCost,0) InstallmentCost
		,a.InstallmentFine-isnull(b.InstallmentFine,0) InstallmentFine,a.DocRowNo,a.SourceSerialNo,a.SourceProcessNo,a.HeseYear,a.HeseAmount	
	from 
	(SELECT * FROM trs.tblLoanDtl WHERE ProcessID = 47  ) a
	left join 
	(SELECT  SUm(InstallmentAmount) InstallmentAmount, SUm(InstallmentCost) InstallmentCost, SUm(InstallmentFine) InstallmentFine,ProcessID,ProcessNo,FiscalYear,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,InstallmentNo 
		FROM trs.tblLoanDtl
		WHERE ProcessID = 48 
		group by ProcessID,ProcessNo,FiscalYear,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,InstallmentNo 		
		 ) b
	on  a.ProcessID = b.BaseProcessID AND a.ProcessNo = b.BaseProcessNo AND a.FiscalYear = b.BaseFiscalYear AND a.SerialNo = b.BaseSerialNo AND a.InstallmentNo = b.InstallmentNo 
	where  (a.InstallmentAmount-isnull(b.InstallmentAmount,0)>0 or a.InstallmentCost-isnull(b.InstallmentCost,0)>0 or a.InstallmentFine-isnull(b.InstallmentFine,0)>0)
	) a
	
	ORDER BY ProcessNo, FiscalYear, SerialNo, InstallmentNo, RowNo
	

End
GO
