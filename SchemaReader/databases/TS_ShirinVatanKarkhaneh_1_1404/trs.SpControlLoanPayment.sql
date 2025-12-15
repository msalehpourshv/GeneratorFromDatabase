USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ====================
-- Author		 : Hadi Sadeghi
-- Create date   : 86/07/26
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [trs].[SpControlLoanPayment]  
 @ProcessID		tinyint,
 @ProcessNo	    tinyint,
 @FiscalYear	smallint,
 @SerialNo      int,
 @LanguageID	TinyInt
WITH ENCRYPTION
AS

BEGIN

	SET NOCOUNT ON;


Declare @rr	          NVarChar(500)
Declare @strMsgText	    NVarchar(2044)

Declare @intProcessID  tinyint
Declare @intProcessNo  tinyint
Declare @intFiscalYear  smallint
Declare @intSerialNo  int
Declare @BaseProcessNo  smallint
Declare @intBaseFiscalYear  smallint
Declare @intBaseSerialNo  int
Declare @intInstallmentNo  int
Declare @intTmpFiscalYear  smallint
Declare @intTmpSerialNo  int

Declare	Cursor_Rec CURSOR For 
   SELECT  ProcessID,ProcessNo,SerialNo,FiscalYear,BaseProcessNo,BaseSerialNo,BaseFiscalYear,InstallmentNo
   FROM trs.tblLoanDtl 
   WHERE ProcessID=@ProcessID AND
         ProcessNo=@ProcessNo AND
         FiscalYear=@FiscalYear AND
         SerialNo=@SerialNo 

	Open  Cursor_Rec; 
	Fetch NEXT From Cursor_Rec Into @intProcessID,@intProcessNo,@intSerialNo,@intFiscalYear,@BaseProcessNo,@intBaseSerialNo,@intBaseFiscalYear,@intInstallmentNo
	  While (@@Fetch_Status = 0)
	    BEGIN
			SET @intTmpSerialNo = 0
			SET @intTmpFiscalYear = 0
			
			SELECT @intTmpSerialNo =SerialNo ,@intTmpFiscalYear=FiscalYear
			FROM trs.tblLoanDtl 
			WHERE ProcessID = @ProcessID  AND
			   BaseProcessNo =  @BaseProcessNo  AND 
			   BaseFiscalYear =  @intBaseFiscalYear  AND 
			   BaseSerialNo =  @intBaseSerialNo    AND 
			   InstallmentNo = @intInstallmentNo AND 
			   NOT(SerialNo=@SerialNo AND FiscalYear=@FiscalYear)
			
			if @intTmpSerialNo > 0
			begin
				DECLARE @strSerialNo varchar(20)
				SET @strSerialNo =ltrim(str(@intTmpSerialNo)) +'/'+ ltrim(str(@intTmpFiscalYear))
				Close Cursor_Rec;
				Deallocate Cursor_Rec; 
				-- این قسط در سند %s  پرداخت شده است
				SET @strMsgText=TS.pub.funGetMessages(12074,@LanguageID)
				Raiserror (@strMsgText,16,1,@strSerialNo)
				Return
			END

	      Fetch NEXT From Cursor_Rec Into @intProcessID,@intProcessNo,@intSerialNo,@intFiscalYear,@BaseProcessNo,@intBaseSerialNo,@intBaseFiscalYear,@intInstallmentNo
	    End
	Close Cursor_Rec;
	Deallocate Cursor_Rec; 

END
GO
