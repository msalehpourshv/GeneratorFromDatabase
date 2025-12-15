USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [trs].[spFrmPayCtrlReceivableExistCheque] 
(
	@BankOurCode Varchar(30) ,
	@ChequeNo	 DECIMAL(28,9) ,
	@ChequeNoNew varchar(20),
	@ProcessNo	 INT,
	@LanguageID	 Int
)
WITH ENCRYPTION
AS

BEGIN

	SELECT PD.*,OB.*,AcntCode1,AcntCode2,AcntCode3,BankState,
			   pub.funGetBankTypeName(PD.BankTypeID,@LanguageID) AS BankTypeName,
			   pub.funGetLocationName(PD.LocationID,@LanguageID) AS LocationName,
				   pub.funGetCurrencyTypesName(PD.CurrencyTypeID,@LanguageID) AS CurrencyTypeName
	FROM trs.tblPayDtl PD,trs.tblOurBanks OB,
	   (SELECT VolumeFiscalYear,VolumeRowNo,Max(EventNo) EventNo
		FROM trs.tblPayDtl 
		WHERE ((@ChequeNo>0 and ChequeNo=@ChequeNo ) OR (@ChequeNo=0 and ChequeNoNew=@ChequeNoNew))  AND
			PayTypeID IN (6,26) 
		Group By VolumeFiscalYear,VolumeRowNo
		) G 
	WHERE G.VolumeFiscalYear = PD.VolumeFiscalYear AND 
	      G.VolumeRowNo = PD.VolumeRowNo AND 
	      G.EventNo = PD.EventNo AND 
	      PD.DebitCode = OB.BankCode AND 
	      PD.DebitCode = @BankOurCode AND 
		  ((@ChequeNo>0 and ChequeNo=@ChequeNo ) OR (@ChequeNo=0 and ChequeNoNew=@ChequeNoNew)) AND 
		  PayTypeID IN (6,26) AND 
		  PD.ProcessNo = @ProcessNo
	ORDER BY PD.EventNo Desc

END





GO
