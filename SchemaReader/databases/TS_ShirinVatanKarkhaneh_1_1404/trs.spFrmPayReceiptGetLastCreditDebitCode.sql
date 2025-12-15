USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [trs].[spFrmPayReceiptGetLastCreditDebitCode] 
  @VolumeFiscalYear	SMALLINT,
  @VolumeRowNo		INT,
  @ProcessID		INT 
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

	------------------------------
	Declare @TempDebitCode Varchar(20)
	Declare @TempCreditCode Varchar(20)

	SET @TempDebitCode = ''
	SET @TempCreditCode = ''

	IF @ProcessID = 12 OR @ProcessID = 13 
		SELECT TOP 1 @TempDebitCode=DebitCode
		FROM trs.tblPayDtl 
		WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
			  VolumeRowNo=@VolumeRowNo AND 
			  PayTypeID IN (6,26)
		ORDER BY EventNo Desc

	IF @ProcessID = 13 OR @ProcessID = 18 OR @ProcessID = 24 -- �ѐ�� �� ���� ��
		SELECT @TempCreditCode=CreditCode
		FROM trs.tblPayDtl
		WHERE	ProcessID IN (1,10) AND
				VolumeFiscalYear=@VolumeFiscalYear AND
				VolumeRowNo=@VolumeRowNo

	SELECT @TempDebitCode AS DebitCode,@TempCreditCode CreditCode
	

END












GO
