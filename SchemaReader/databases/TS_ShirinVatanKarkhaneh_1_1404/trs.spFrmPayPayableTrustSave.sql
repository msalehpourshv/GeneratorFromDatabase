USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- [FrmPay].[SpRecivableTrustSave] 16,1,86,1

-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/08/16
-- Description:	Control Receipt 
-- =============================================
CREATE PROCEDURE [trs].[spFrmPayPayableTrustSave] 
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo      int
WITH ENCRYPTION
 AS

BEGIN	

SET NOCOUNT ON;
Declare @strMsgText	 NVarChar(2044)
Declare @LocationID	 VarChar(20)
Declare @BankTypeID	 VarChar(20)
Declare @rr		     NVarChar(500)
Declare @PayTypeID	 Int
Declare @EventNo	 Int
Declare @VolumeFiscalYear INT
Declare @VolumeRowNo Int
Declare @RowNo       Int
Declare @ChequeNo	VarChar(20)
Declare @LanguageID	Tinyint
Declare @DocDate	Char(10)
Declare @MaxDocDate			Char(10)

	SET @LanguageID = pub.funGetCurrentLanguageID();
---------------------------------------------
Declare	Cursor_PayDtl CURSOR For 
	SELECT RD.LocationID,RD.BankTypeID,PayTypeID,EventNo,VolumeFiscalYear,VolumeRowNo,RowNo,ChequeNo,DocDate
	FROM trs.tblPayDtl RD
	WHERE RD.ProcessID=@ProcessID AND
		  RD.ProcessNo=@ProcessNo AND
		  RD.FiscalYear=@FiscalYear AND
		  RD.SerialNo=@SerialNo 

Open  Cursor_PayDtl; 

Fetch NEXT From Cursor_PayDtl Into @LocationID, @BankTypeID,@PayTypeID,@EventNo,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@ChequeNo,@DocDate

While (@@Fetch_Status = 0)
begin
	DECLARE @MaxEvn int
	IF @LocationID IS NULL
		SET @LocationID = ''

	IF @BankTypeID IS NULL
		SET @BankTypeID = 0

	IF @EventNo IS NULL
		SET @EventNo = 0

	IF @VolumeFiscalYear IS NULL
		SET @VolumeFiscalYear = 0

	IF @VolumeRowNo IS NULL
		SET @VolumeRowNo = 0

	IF @ChequeNo IS NULL
		SET @ChequeNo = 0

			IF  @EventNo > 0
			BEGIN
				SELECT @MaxDocDate = DocDate
				FROM trs.tblPayDtl 
				WHERE VolumeFiscalYear=@VolumeFiscalYear AND  
						VolumeRowNo=@VolumeRowNo AND 
						ProcessNo=@ProcessNo AND 
						EventNo = @EventNo+1 AND
						PayTypeID IN (16,31,34)

				IF @MaxDocDate < @DocDate
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec;
						--تاریخ جاری از تاریخ آخرین حالت چک بزرگتر است
						SET @strMsgText='تاریخ جاری از تاریخ آخرین حالت چک بزرگتر است'
						Raiserror (@strMsgText,16,1) 
						Return
					END
			END
			
    -------------------------------------------
	IF @BankTypeID>0 AND 
       (SELECT COUNT(*)
		FROM trs.tblBankTypes
		WHERE BankTypeID=@BankTypeID) = 0
	BEGIN
		Close Cursor_PayDtl;
		Deallocate Cursor_PayDtl; 
		--بانكي به کد  %s وجود ندارد
		SET @strMsgText=TS.pub.funGetMessages(12001,@LanguageID)
		Raiserror (@strMsgText,16,1,@BankTypeID)
	END

    -------------------------------------------
	IF @LocationID<>'' AND 
      (SELECT count(*)
	   FROM pub.tblLocations
	   WHERE LocationID=@LocationID) = 0
	BEGIN
		Close Cursor_PayDtl;
		Deallocate Cursor_PayDtl; 
		--شهری به کد  %s وجود ندارد
		SET @strMsgText=TS.pub.funGetMessages(12002,@LanguageID)
		Raiserror (@strMsgText,16,1,@LocationID)
		Return
	END


    -------------------------------------------
	IF @PayTypeID=18
	BEGIN
		DECLARE @TempProcessID Tinyint

		SELECT TOP 1 @TempProcessID= ProcessID 
		FROM trs.tblPayDtl
		WHERE PayTypeID=18 AND
		      VolumeFiscalYear=@VolumeFiscalYear AND
		      VolumeRowNo=@VolumeRowNo AND 
			  ProcessID<>@ProcessID AND
			  ProcessNo<>@ProcessNo AND
			  FiscalYear<>@FiscalYear AND
			  SerialNo<>@SerialNo AND 
			  EventNo<>@EventNo
		Order By EventNo Desc

		IF (@TempProcessID=34)
		BEGIN
			Close Cursor_PayDtl;
			Deallocate Cursor_PayDtl; 
			--چک به شماره %s قبلا مسترد شده است
			SET @strMsgText=TS.pub.funGetMessages(12003,@LanguageID)
			Raiserror (@strMsgText,16,1,@ChequeNo)
			Return
		END 

	END
    -------------------------------------------
	Fetch NEXT From Cursor_PayDtl Into @LocationID, @BankTypeID,@PayTypeID,@EventNo,@VolumeFiscalYear,@VolumeRowNo,@RowNo,@ChequeNo,@DocDate

End

Close Cursor_PayDtl;
Deallocate Cursor_PayDtl; 

-------------------------------------------------------------------------------

DECLARE @MaxVolumeRowNo int

SELECT @MaxVolumeRowNo = ISNULL(MAX(VolumeRowNo),0)
FROM trs.tblPayDtl 
WHERE PayTypeID IN ( 18,32,33) AND
	  VolumeFiscalYear = @FiscalYear

if @MaxVolumeRowNo=0
	SELECT   @MaxVolumeRowNo= SettingValue FROM         pub.tblSettings WHERE     (SettingKey = N'StartVolumeRowNo')


UPDATE  trs.tblPayDtl
SET  VolumeRowNo=@MaxVolumeRowNo+ROW_N
FROM trs.tblPayDtl, 
	(SELECT RowNo,ROW_NUMBER() OVER(ORDER BY DocRowNo) As ROW_N
	 FROM	trs.tblPayDtl
	 WHERE	ProcessID = @ProcessID  AND
		    ProcessNo = @ProcessNo  AND
		    FiscalYear= @FiscalYear AND
		    SerialNo  = @SerialNo   AND
		    VolumeRowNo = 0	        AND
		    PayTypeID IN ( 18,32,33)    ) t 
WHERE ProcessID =@ProcessID  AND
	  ProcessNo =@ProcessNo  AND
	  FiscalYear=@FiscalYear AND
	  SerialNo  =@SerialNo   AND
	  PayTypeID IN ( 18,32,33)  AND
      VolumeRowNo = 0	     AND
	  trs.tblPayDtl.RowNo=t.RowNo

-------------------------------------------------------------------------------
SELECT DocRowNo, ISNULL(VolumeFiscalYear,0) VolumeFiscalYear, ISNULL(VolumeRowNo,0) VolumeRowNo
FROM trs.tblPayDtl 
WHERE ProcessID = @ProcessID  AND
      ProcessNo = @ProcessNo  AND
      FiscalYear= @FiscalYear AND
      SerialNo  = @SerialNo 
ORDER BY DocRowNo

END
GO
