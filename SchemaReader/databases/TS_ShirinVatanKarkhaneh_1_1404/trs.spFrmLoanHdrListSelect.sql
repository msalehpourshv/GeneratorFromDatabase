USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		Sadeghi, Hadi
-- Create date: 88/06/24
-- Description: 
-- ----------------------------------------------
-- ==============================================

CREATE PROCEDURE [trs].[spFrmLoanHdrListSelect]
	@ProcessID		SMALLINT,
	@ProcessNo		TINYINT,
	@CustomerAcntCode	VARCHAR(20),
	@LoanAcntCode	VARCHAR(20),
	@LoanNo			NVARCHAR(200),
	@LoanName		NVARCHAR(200),
	@Interest		float,
	@Cancel			BIT
	WITH ENCRYPTION
As
BEGIN
	-- ================= AcntPartNumberForRemainCalculation
	DECLARE @AcntPartNumberForRemainCalculation int
	DECLARE @Start int =0
	DECLARE @LEN int =0
	SELECT @AcntPartNumberForRemainCalculation=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	IF @AcntPartNumberForRemainCalculation >0
	BEGIN
		SELECT @Start = [acc].[funGetAcntLayerStartandLen](@AcntPartNumberForRemainCalculation,1)
		SELECT @LEN = [acc].[funGetAcntLayerStartandLen](@AcntPartNumberForRemainCalculation,2)
	END

	IF @ProcessID = 7 OR @ProcessID = 47
		SELECT ProcessID, ProcessNo, FiscalYear, SerialNo,LoanHdrDesc,LoanNo,LoanName,Interest,
		       LoanAcntCode,DocDate,pub.GetCodeName(LoanAcntCode, 1) AS LoanAcntName
		FROM trs.tblLoanHdr
		WHERE ProcessID = @ProcessID AND ProcessNo = @ProcessNo AND
			 (@LoanAcntCode='' OR LoanAcntCode=@LoanAcntCode)  AND
			 (@CustomerAcntCode='' OR SUBSTRING(LoanAcntCode,@Start,@LEN)=@CustomerAcntCode)  AND
			 (@LoanNo='' OR LoanNo=@LoanNo)  AND
			 (@LoanName='' OR LoanName=@LoanName) AND
			 (@Interest=0 OR Interest=@Interest) AND (@Cancel = 'False' OR Cancel=@Cancel)

	ELSE IF @ProcessID = 8
	begin
	
		declare @trs_InloanRegAnyInstallment as bit
		select @trs_InloanRegAnyInstallment = isnull(SettingValue, 'False')	from pub.tblSettings	where SettingKey = 'trs_InloanRegAnyInstallment'
		set @trs_InloanRegAnyInstallment=isnull(@trs_InloanRegAnyInstallment, 'False')

		if @trs_InloanRegAnyInstallment ='true'
			SELECT D.*,LoanHdrDesc,LoanNo,LoanName,Interest,LoanAcntCode,DocDate,pub.GetCodeName(LoanAcntCode, 1) AS LoanAcntName
			FROM trs.tblLoanHdr L INNER JOIN (
					SELECT ProcessID, ProcessNo, FiscalYear, SerialNo,SUm(InstallmentAmount) InstallmentAmount, SUm(InstallmentCost) InstallmentCost, SUm(InstallmentFine) InstallmentFine,MAX(InstallmentNo) InstallmentNo
					FROM trs.tblLoanDtl
					WHERE ProcessID = 7 AND ProcessNo = @ProcessNo
					GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo
				EXCEPT 
					SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,SUm(InstallmentAmount) InstallmentAmount, SUm(InstallmentCost) InstallmentCost, SUm(InstallmentFine) InstallmentFine,MAX(InstallmentNo) InstallmentNo
					FROM trs.tblLoanDtl
					WHERE ProcessID = 8 AND ProcessNo = @ProcessNo
					GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo
					) D
			ON 	L.ProcessID=D.ProcessID AND L.ProcessNo=D.ProcessNo AND L.FiscalYear=D.FiscalYear AND L.SerialNo=D.SerialNo
			WHERE L.Cancel ='False' AND (@LoanAcntCode='' OR LoanAcntCode=@LoanAcntCode)  AND
			     (@CustomerAcntCode='' OR SUBSTRING(LoanAcntCode,@Start,@LEN)=@CustomerAcntCode)  AND
				 (@LoanNo='' OR LoanNo=@LoanNo)  AND
				 (@LoanName='' OR LoanName=@LoanName)  AND
				 (@Interest=0 OR Interest=@Interest)  
		else
			SELECT D.*,LoanHdrDesc,LoanNo,LoanName,Interest,LoanAcntCode,DocDate,pub.GetCodeName(LoanAcntCode, 1) AS LoanAcntName
				FROM trs.tblLoanHdr L INNER JOIN (
						SELECT ProcessID, ProcessNo, FiscalYear, SerialNo,MAX(InstallmentNo) InstallmentNo
						FROM trs.tblLoanDtl
						WHERE ProcessID = 7 AND ProcessNo = @ProcessNo
						GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo
					EXCEPT 
						SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,MAX(InstallmentNo) InstallmentNo
						FROM trs.tblLoanDtl
						WHERE ProcessID = 8 AND ProcessNo = @ProcessNo
						GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo
						) D
				ON 	L.ProcessID=D.ProcessID AND L.ProcessNo=D.ProcessNo AND L.FiscalYear=D.FiscalYear AND L.SerialNo=D.SerialNo
				WHERE L.Cancel ='False' AND (@LoanAcntCode='' OR LoanAcntCode=@LoanAcntCode)  AND
					 (@CustomerAcntCode='' OR SUBSTRING(LoanAcntCode,@Start,@LEN)=@CustomerAcntCode)  AND
					 (@LoanNo='' OR LoanNo=@LoanNo)  AND
					 (@LoanName='' OR LoanName=@LoanName)  AND
					 (@Interest=0 OR Interest=@Interest) 
	end
	ELSE
		SELECT D.*,LoanHdrDesc,LoanNo,LoanName,Interest,LoanAcntCode,DocDate,pub.GetCodeName(LoanAcntCode, 1) AS LoanAcntName
		FROM trs.tblLoanHdr L INNER JOIN (
				SELECT ProcessID, ProcessNo, FiscalYear, SerialNo,MAX(InstallmentNo) InstallmentNo
				FROM trs.tblLoanDtl
				WHERE ProcessID = 47 AND ProcessNo = @ProcessNo
				GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo
			EXCEPT 
				SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,MAX(InstallmentNo) InstallmentNo
				FROM trs.tblLoanDtl
				WHERE ProcessID = 48 AND ProcessNo = @ProcessNo
				GROUP BY  BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo
				) D
		ON 	L.ProcessID=D.ProcessID AND L.ProcessNo=D.ProcessNo AND L.FiscalYear=D.FiscalYear AND L.SerialNo=D.SerialNo  
		WHERE L.Cancel ='False' AND (@LoanAcntCode='' OR LoanAcntCode=@LoanAcntCode)   AND
			 (@CustomerAcntCode='' OR SUBSTRING(LoanAcntCode,@Start,@LEN)=@CustomerAcntCode)  AND
			 (@LoanNo='' OR LoanNo=@LoanNo)  AND
			 (@LoanName='' OR LoanName=@LoanName)  AND
			 (@Interest=0 OR Interest=@Interest) 
	
End
GO
