USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/04/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : register Void Cheque
-- =============================================
CREATE PROCEDURE [trs].[SpReceivableControl] 
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo      int,
 @LanguageID	Tinyint
WITH ENCRYPTION
AS

BEGIN

	SET NOCOUNT ON;
Declare @LocationID		VarChar(20)
Declare @BankTypeID		VarChar(20)
Declare @strMsgText	    NVarchar(2044)


Declare	Cursor_Chq CURSOR For 
        SELECT LocationID,BankTypeID
        FROM trs.tblReceivableChq RC, trs.tblReceivableDtl RD
        WHERE  RD.ProcessID=@ProcessID AND
               RD.ProcessNo=@ProcessNo AND
               RD.FiscalYear=@FiscalYear AND
               RD.SerialNo=@SerialNo AND 
               RD.VolumeFiscalYear=RC.VolumeFiscalYear AND
               RD.VolumeRowNo=RC.VolumeRowNo

Open  Cursor_Chq; 
Fetch NEXT From Cursor_Chq Into @LocationID, @BankTypeID
While (@@Fetch_Status = 0)
begin
IF ( SELECT count(*)
     FROM trs.tblBankTypes
     WHERE BankTypeID=@BankTypeID )=0
begin
	Close Cursor_Chq;
	Deallocate Cursor_Chq; 
	--بانكي به کد  %s وجود ندارد
	SET @strMsgText=TS.pub.funGetMessages(12001,@LanguageID)
	Raiserror (@strMsgText,16,1,@BankTypeID)
	Return
END

IF ( SELECT count(*)
     FROM pub.tblLocations
     WHERE LocationID=@LocationID )=0
begin
	Close Cursor_Chq;
	Deallocate Cursor_Chq; 
	--شهري به کد  %s وجود ندارد
	SET @strMsgText=TS.pub.funGetMessages(12002,@LanguageID)
	Raiserror (@strMsgText,16,1,@LocationID)
	Return
END

Fetch NEXT From Cursor_Chq Into @LocationID, @BankTypeID
End
	Close Cursor_Chq;
	Deallocate Cursor_Chq; 
END










GO
