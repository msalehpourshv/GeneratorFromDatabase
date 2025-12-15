USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [trs].[funGetPayChequeOwner] 
(
	@VolumeFiscalYear	SmallInt,
	@VolumeRowNo		Int,
	@PayTypeID			Tinyint
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

BEGIN -- ============== S T A R T  C O D E =====================================

	Declare @Result AS VarChar(20)
IF @PayTypeID = 18
	SELECT @Result = CASE  WHEN PayTypeID = 18 THEN DebitCode  WHEN PayTypeID = 8 THEN AcntCode2 ELSE AcntCode5 END 
	FROM trs.tblOurBanks , trs.tblPayDtl
	WHERE CreditCode = BankCode AND ProcessID IN (2,33,25) AND 
			PayTypeID IN (8,18,28) AND 
			VolumeFiscalYear = @VolumeFiscalYear AND 
			VolumeRowNo = @VolumeRowNo AND  BankCode =(	
	SELECT Top 1 CreditCode
	FROM	trs.tblPayDtl
	WHERE	ProcessID IN (33) AND 
			PayTypeID IN (18) AND 
			VolumeFiscalYear = @VolumeFiscalYear AND 
			VolumeRowNo = @VolumeRowNo
	ORDER By EventNo ASC)

else
	SELECT @Result = CASE  WHEN PayTypeID = 18 THEN DebitCode  WHEN PayTypeID = 8 THEN AcntCode2 ELSE AcntCode5 END 
	FROM trs.tblOurBanks , trs.tblPayDtl
	WHERE CreditCode = BankCode AND ProcessID IN (2,33,25) AND 
			PayTypeID IN (8,18,28) AND 
			VolumeFiscalYear = @VolumeFiscalYear AND 
			VolumeRowNo = @VolumeRowNo AND  BankCode =(	
	SELECT Top 1 CreditCode
	FROM	trs.tblPayDtl
	WHERE	ProcessID IN (2,25) AND 
			PayTypeID IN (8,28) AND 
			VolumeFiscalYear = @VolumeFiscalYear AND 
			VolumeRowNo = @VolumeRowNo
	ORDER By EventNo ASC)

	Return @Result
END





























GO
