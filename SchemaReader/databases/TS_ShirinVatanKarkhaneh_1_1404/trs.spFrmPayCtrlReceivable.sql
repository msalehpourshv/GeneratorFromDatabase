USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create PROCEDURE [trs].[spFrmPayCtrlReceivable] 
(
	@VolumeFiscalYear	SmallInt, 
	@VolumeRowNo		Int,
	@Code 		        Varchar(20),
	@ProcessID			INT,
	@ProcessNo			INT,
	@LanguageID			Int
)
WITH ENCRYPTION
AS

BEGIN
	DECLARE @LastProcessID   smallint,
			@MaxEventNo  Varchar(20)

	IF @ProcessID IN (31,32)
		BEGIN
			SELECT TOP 1 @LastProcessID = ProcessID , @MaxEventNo=EventNo
			FROM trs.tblPayDtl 
			WHERE VolumeFiscalYear=@VolumeFiscalYear  AND 
				VolumeRowNo= @VolumeRowNo AND 
				PayTypeID IN (16)
			ORDER BY EventNo Desc
			
			if @LastProcessID IN (31)
				SELECT TOP 1 *,AcntCode1,AcntCode2,AcntCode3,BankState,
						   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
						   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
							   pub.funGetCurrencyTypesName(PD.CurrencyTypeID,@LanguageID) AS CurrencyTypeName
				FROM trs.tblPayDtl PD,trs.tblOurBanks OB
				WHERE PD.EventNo = @MaxEventNo AND 
					  PD.DebitCode = @Code AND 
					  PD.DebitCode = OB.BankCode AND 
					  VolumeFiscalYear=@VolumeFiscalYear  AND 
					  VolumeRowNo= @VolumeRowNo AND 
					  PayTypeID IN (16) AND 
					  PD.ProcessNo = @ProcessNo
				ORDER BY EventNo Desc
			ELSE
				SELECT TOP 1 *,AcntCode1,AcntCode2,AcntCode3,BankState,
						   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
						   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
							   pub.funGetCurrencyTypesName(PD.CurrencyTypeID,@LanguageID) AS CurrencyTypeName
				FROM trs.tblPayDtl PD,trs.tblOurBanks OB
				WHERE PD.EventNo = @MaxEventNo AND 
					  PD.CreditCode = @Code AND 
					  PD.CreditCode = OB.BankCode AND 
					  VolumeFiscalYear=@VolumeFiscalYear  AND 
					  VolumeRowNo= @VolumeRowNo AND 
					  PayTypeID IN (16) AND
					  PD.ProcessNo = @ProcessNo
				ORDER BY EventNo Desc
				
		END
	ELSE
		BEGIN
			SELECT TOP 1 @LastProcessID = ProcessID , @MaxEventNo=EventNo
			FROM trs.tblPayDtl 
			WHERE VolumeFiscalYear=@VolumeFiscalYear  AND 
				VolumeRowNo= @VolumeRowNo AND 
				PayTypeID IN (6,26)
			ORDER BY EventNo Desc

			if @LastProcessID IN (1,3,10,17,23,40)
				SELECT TOP 1 *,AcntCode1,AcntCode2,AcntCode3,BankState,
						   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
						   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
							   pub.funGetCurrencyTypesName(PD.CurrencyTypeID,@LanguageID) AS CurrencyTypeName
				FROM trs.tblPayDtl PD,trs.tblOurBanks OB
				WHERE PD.EventNo = @MaxEventNo AND 
					  PD.DebitCode = @Code AND 
					  PD.DebitCode = OB.BankCode AND 
					  VolumeFiscalYear=@VolumeFiscalYear  AND 
					  VolumeRowNo= @VolumeRowNo AND 
					  PayTypeID IN (6,26) AND 
					  PD.ProcessNo = @ProcessNo
				ORDER BY EventNo Desc
			ELSE
				SELECT TOP 1 *,AcntCode1,AcntCode2,AcntCode3,BankState,
						   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
						   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
							   pub.funGetCurrencyTypesName(PD.CurrencyTypeID,@LanguageID) AS CurrencyTypeName
				FROM trs.tblPayDtl PD,trs.tblOurBanks OB
				WHERE PD.EventNo = @MaxEventNo AND 
					  PD.CreditCode = @Code AND 
					  PD.CreditCode = OB.BankCode AND 
					  VolumeFiscalYear=@VolumeFiscalYear  AND 
					  VolumeRowNo= @VolumeRowNo AND 
					  PayTypeID IN (6,26) AND
					  PD.ProcessNo = @ProcessNo
				ORDER BY EventNo Desc
		END

END










GO
