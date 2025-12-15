USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		Sadeghi, Hadi
-- Create date: 91/04/24
-- Description: 
-- ----------------------------------------------
-- ==============================================
Create PROCEDURE [trs].[spFrmLoanDtlListSelect]
	@ProcessID			SMALLINT,
	@ProcessNo			TINYINT,
	@BaseFiscalYear		SMALLINT,
	@BaseSerialNo		INT,
	@InstallmentNo      INT
	WITH ENCRYPTION
As
BEGIN
Declare   @BaseProcessID int

	IF @ProcessID = 8
		set @BaseProcessID=7		
	IF @ProcessID = 48
		set @BaseProcessID=47


if (SELECT COUNT(SerialNo)
	FROM trs.tblLoanHdr 
	WHERE ProcessID=@BaseProcessID AND ProcessNo=@ProcessNo AND 
		  FiscalYear=@BaseFiscalYear AND SerialNo=@BaseSerialNo AND
		Cancel = 'True') >0
BEGIN
	SELECT TOP 0 * from trs.tblLoanDtl
	Return
END

declare @trs_InloanRegAnyInstallment as bit
select @trs_InloanRegAnyInstallment = isnull(SettingValue, 'False')	from pub.tblSettings	where SettingKey = 'trs_InloanRegAnyInstallment'
set @trs_InloanRegAnyInstallment=isnull(@trs_InloanRegAnyInstallment, 'False')

if @trs_InloanRegAnyInstallment ='true'
	select a.* from 
		(SELECT * FROM trs.tblLoanDtl WHERE ProcessID = @BaseProcessID  AND ProcessNo = @ProcessNo AND FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo ) a
	left join 
		(SELECT  SUm(InstallmentAmount) InstallmentAmount, SUm(InstallmentCost) InstallmentCost, SUm(InstallmentFine) InstallmentFine,ProcessID,ProcessNo,FiscalYear,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,InstallmentNo 
			FROM trs.tblLoanDtl
			WHERE BaseProcessID = @BaseProcessID and BaseProcessNo=@ProcessNo AND	BaseFiscalYear=@BaseFiscalYear AND BaseSerialNo=@BaseSerialNo 
			group by ProcessID,ProcessNo,FiscalYear,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,InstallmentNo 
		) b	
	on  a.ProcessID = b.BaseProcessID AND a.ProcessNo = b.BaseProcessNo AND a.FiscalYear = b.BaseFiscalYear AND a.SerialNo = b.BaseSerialNo AND a.InstallmentNo = b.InstallmentNo 
	where  (a.InstallmentAmount-isnull(b.InstallmentAmount,0)>0 or a.InstallmentCost-isnull(b.InstallmentCost,0)>0 or a.InstallmentFine-isnull(b.InstallmentFine,0)>0)
	 AND  (@InstallmentNo=0 OR a.InstallmentNo=@InstallmentNo)
else
		SELECT L.*
		FROM trs.tblLoanDtl L INNER JOIN (
				SELECT ProcessID, ProcessNo, FiscalYear, SerialNo,InstallmentNo 
				FROM trs.tblLoanDtl
				WHERE ProcessID = @BaseProcessID  AND ProcessNo = @ProcessNo AND FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo
			EXCEPT 
				SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,InstallmentNo
				FROM trs.tblLoanDtl
				WHERE ProcessID = @ProcessID AND ProcessNo = @ProcessNo
				) D
		ON 	L.ProcessID=D.ProcessID AND L.ProcessNo=D.ProcessNo AND L.FiscalYear=D.FiscalYear AND L.SerialNo=D.SerialNo AND L.InstallmentNo=D.InstallmentNo
	 WHERE  (@InstallmentNo=0 OR L.InstallmentNo=@InstallmentNo)
  
End
GO
