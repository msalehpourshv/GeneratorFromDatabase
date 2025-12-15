USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author: Sadeghi, Hadi
-- Create Date: 09-19-2007 (1386/06/18)
-- Description: <Store Documents>
-- ----------------------------------------------
-- کنترل برگ 
-- ==============================================
CREATE PROCEDURE [trs].[spFrmPayPaymentTrustRecord]
    @CreditCode	      VarChar(20)
WITH ENCRYPTION
AS
BEGIN
	Declare @strMsgText	NVarChar(2044)
	DECLARE @AcntCode4	varchar(20)
	Declare @LanguageID Tinyint

	SET @LanguageID = pub.funGetCurrentLanguageID();

	SELECT @AcntCode4=AcntCode4
	FROM trs.tblOurBanks 
	WHERE BankCode=@CreditCode 

	IF (@AcntCode4)=''
	BEGIN
		SET @strMsgText=TS.pub.funGetMessages(11034,@LanguageID)
		Raiserror (@strMsgText,16,1)
	END

END





















GO
