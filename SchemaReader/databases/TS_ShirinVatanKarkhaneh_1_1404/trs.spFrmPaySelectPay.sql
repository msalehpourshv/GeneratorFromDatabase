USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date:(1386/07/18)
-- ==============================================
Create PROCEDURE [trs].[spFrmPaySelectPay]
	@ProcessID   tinyint,
	@ProcessNO   tinyint,
	@FiscalYear  smallint,
	@SerialNo    int,
	@LanguageID    int
WITH ENCRYPTION
AS

BEGIN

--	SET @LanguageID = pub.funGetCurrentLanguageID();

IF (@ProcessID=3) 
	BEGIN
		SELECT PD.*,[pub].[funGetLocationName] (TargetLocationID,1)TargetLocationName, [pub].[funGetBankTypeName] (TargetBankID, 1)TargetBankName,'' AcntCode1,'' AcntCode2,'' AcntCode3,'' AcntCode4,'' AcntCode5,0 BankState,
			   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
			   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
			   pub.funGetBankTypeName(PD.BankTypeID2,@LanguageID) AS BankTypeName2,
			   pub.funGetLocationName(PD.LocationID2,@LanguageID) AS LocationName2,
			   trs.funGetPayMaxEventNo(VolumeFiscalYear,VolumeRowNo,PayTypeID) AS MaxEventNo,
			   [acc].[funAccountRemain](CreditCode,DocDate) AS AccountRemain
			,isnull(CurrencyTypeName,'') CurrencyTypeName
		FROM trs.tblPayDtl PD
		Left join pub.tblCurrencyTypesDtl Cu on PD.CurrencyTypeID =Cu.CurrencyTypeID
		WHERE  ProcessID =@ProcessID AND 
			  ProcessNo=@ProcessNO AND 
			  FiscalYear=@FiscalYear AND 
			  SerialNo=@SerialNo 
		ORDER BY DocRowNo
	END
ELSE IF (@ProcessID=4)
	BEGIN
		SELECT PD.*,[pub].[funGetLocationName] (TargetLocationID,1)TargetLocationName, [pub].[funGetBankTypeName]  (TargetBankID, 1)TargetBankName,'' AcntCode1,'' AcntCode2,'' AcntCode3,'' AcntCode4,'' AcntCode5,0 BankState,
			   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
			   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
			   pub.funGetBankTypeName(PD.BankTypeID2,@LanguageID) AS BankTypeName2,
			   pub.funGetLocationName(PD.LocationID2,@LanguageID) AS LocationName2,
			   trs.funGetPayMaxEventNo(VolumeFiscalYear,VolumeRowNo,PayTypeID) AS MaxEventNo,
			   [acc].[funAccountRemain](DebitCode,DocDate) AS AccountRemain
		,isnull(CurrencyTypeName,'') CurrencyTypeName
		FROM trs.tblPayDtl PD
		Left join pub.tblCurrencyTypesDtl Cu on PD.CurrencyTypeID =Cu.CurrencyTypeID
		WHERE ProcessID =@ProcessID AND 
			  ProcessNo=@ProcessNO AND 
			  FiscalYear=@FiscalYear AND 
			  SerialNo=@SerialNo 
		ORDER BY DocRowNo
	END	
ELSE IF (@ProcessID=1) OR (@ProcessID=10) OR (@ProcessID=31)
	BEGIN
		SELECT PD.*,[pub].[funGetLocationName] (TargetLocationID,1)TargetLocationName, [pub].[funGetBankTypeName]  (TargetBankID, 1)TargetBankName,AcntCode1,AcntCode2,AcntCode3,AcntCode4,AcntCode5,OB.BankState,
			   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
			   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
			   pub.funGetBankTypeName(PD.BankTypeID2,@LanguageID) AS BankTypeName2,
			   pub.funGetLocationName(PD.LocationID2,@LanguageID) AS LocationName2,
			   trs.funGetPayMaxEventNo(VolumeFiscalYear,VolumeRowNo,PayTypeID) AS MaxEventNo,
			   [acc].[funAccountRemain](CreditCode,DocDate) AS AccountRemain
			   ,isnull(CurrencyTypeName,'') CurrencyTypeName
		FROM trs.tblPayDtl PD
		inner join trs.tblOurBanks OB on PD.DebitCode =OB.BankCode
		Left join pub.tblCurrencyTypesDtl Cu on PD.CurrencyTypeID =Cu.CurrencyTypeID
		WHERE 
			  ProcessID =@ProcessID AND 
			  ProcessNo=@ProcessNO AND 
			  FiscalYear=@FiscalYear AND 
			  SerialNo=@SerialNo 
		ORDER BY DocRowNo
	END
ELSE IF (@ProcessID=2)OR (@ProcessID=33) OR (@ProcessID=25)
	BEGIN
		SELECT PD.*,[pub].[funGetLocationName] (TargetLocationID,1)TargetLocationName,[pub].[funGetBankTypeName] (TargetBankID, 1)TargetBankName,AcntCode1,AcntCode2,AcntCode3,AcntCode4,AcntCode5,OB.BankState,
			   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
			   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
			   pub.funGetBankTypeName(PD.BankTypeID2,@LanguageID) AS BankTypeName2,
			   pub.funGetLocationName(PD.LocationID2,@LanguageID) AS LocationName2,
			   trs.funGetPayMaxEventNo(VolumeFiscalYear,VolumeRowNo,PayTypeID) AS MaxEventNo,
			   [acc].[funAccountRemain](DebitCode,DocDate) AS AccountRemain
		,isnull(CurrencyTypeName,'') CurrencyTypeName
		FROM trs.tblPayDtl PD
		inner join trs.tblOurBanks OB on PD.CreditCode =OB.BankCode
		Left join pub.tblCurrencyTypesDtl Cu on PD.CurrencyTypeID =Cu.CurrencyTypeID
		WHERE 
			  ProcessID =@ProcessID AND 
			  ProcessNo=@ProcessNO AND 
			  FiscalYear=@FiscalYear AND 
			  SerialNo=@SerialNo 
		ORDER BY DocRowNo
	END
ELSE IF (@ProcessID=40)
	BEGIN
		SELECT PD.*,[pub].[funGetLocationName] (TargetLocationID,1)TargetLocationName, [pub].[funGetBankTypeName] (TargetBankID, 1)TargetBankName,
			   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
			   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
			   pub.funGetBankTypeName(PD.BankTypeID2,@LanguageID) AS BankTypeName2,
			   pub.funGetLocationName(PD.LocationID2,@LanguageID) AS LocationName2,
			   trs.funGetPayMaxEventNo(VolumeFiscalYear,VolumeRowNo,PayTypeID) AS MaxEventNo,
			   0 AS AccountRemain
		,isnull(CurrencyTypeName,'') CurrencyTypeName
		FROM trs.tblPayDtl PD
		Left join pub.tblCurrencyTypesDtl Cu on PD.CurrencyTypeID =Cu.CurrencyTypeID
		WHERE ProcessID =@ProcessID AND 
			  ProcessNo=@ProcessNO AND 
			  FiscalYear=@FiscalYear AND 
			  SerialNo=@SerialNo 
		ORDER BY DocRowNo
	END
END 
GO
