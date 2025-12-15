USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : Control Receipt Saving
-- =============================================
Create PROCEDURE [trs].[spFrmPayReceiptSelectPayReceipt]
	@ProcessID   tinyint,
	@ProcessNO   tinyint,
	@FiscalYear  smallint,
	@SerialNo    int,
	@LanguageID  int
WITH ENCRYPTION
AS

BEGIN
	SELECT *,pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
		   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
   		   CASE WHEN ProcessID=28 THEN [trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo) 
   		   ELSE '' END CustomerCode,
		   CASE WHEN ProcessID=28 THEN pub.GetCodeName([trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo),@LanguageID) 
   				WHEN ProcessID=18 THEN [pub].[GetCodeName](CreditCode,@LanguageID) 
		   ELSE '' END CustomerName,
		   trs.funGetPayMaxEventNo(PD.VolumeFiscalYear,PD.VolumeRowNo,
		   CASE WHEN PayTypeID in (7,8,28) THEN 7 ELSE PayTypeID END ) AS MaxEventNo,
		   pub.funGetCurrencyTypesName(PD.CurrencyTypeID,@LanguageID) AS CurrencyTypeName,
		   CASE WHEN PayTypeID in (7,8,18,28) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END FirstCreditCode ,
		   [pub].[GetCodeName](CASE WHEN PayTypeID in (7,8,18,28) THEN [trs].[funGetPayChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) ELSE [trs].[funGetChequeOwner](VolumeFiscalYear,VolumeRowNo,PayTypeID) END,@LanguageID) FirstCreditName,
		   [trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo) PayChequeCustomerCode,
		   pub.GetCodeName([trs].[funGetPayChequeCustomer](VolumeFiscalYear,VolumeRowNo),@LanguageID) PayChequeCustomerName,
		   PD.WithAcntCode, [pub].[GetCodeName](PD.WithAcntCode,@LanguageID) As WithName
		   , [pub].[GetCodeName](VisitorAcntCode,@LanguageID) as VisitorAcntName
	FROM trs.tblPayDtl PD
	WHERE ProcessID=@ProcessID AND 
		  ProcessNo=@ProcessNO  AND 
		  FiscalYear=@FiscalYear AND 
		  SerialNo=@SerialNo
	ORDER BY DocRowNo
END 
GO
