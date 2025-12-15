USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 87/10/01
-- Description:	
-- =============================================

Create PROCEDURE [ast].[spFrmAssetSave] 
	@ProcessID		smallint,
	@ProcessNo		tinyint,
	@FiscalYear	smallint,
	@SerialNo		int,
	@LanguageID    tinyint
	WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

	Declare @strMsgText		NVarChar(2044)
	Declare @AssetPlaque	Varchar(20)
	Declare @TmpAssetPlaque	Varchar(20)
	Declare @TmpProcessID		smallint
	Declare @TmpSerialNo		int

	SET @AssetPlaque = ''
	SET @TmpAssetPlaque = ''

	Declare	Cursor_Rec CURSOR For 
		SELECT AssetPlaque
		FROM ast.tblAssetsDtl
		WHERE  ProcessID=@ProcessID AND
			   ProcessNo=@ProcessNo AND
			   FiscalYear=@FiscalYear AND
			   SerialNo=@SerialNo 

	Open  Cursor_Rec; 

	Fetch NEXT From Cursor_Rec Into @AssetPlaque

	While (@@Fetch_Status = 0)
	BEGIN

		SET @TmpAssetPlaque = ''
		SET @TmpProcessID = 0

		SELECT TOP 1 @TmpAssetPlaque=AssetPlaque,@TmpProcessID=ProcessID,@TmpSerialNo=SerialNo
		FROM ast.tblAssetsDtl
		WHERE AssetPlaque  = @AssetPlaque AND 
			NOT(ProcessID  = @ProcessID AND
			    ProcessNo  = @ProcessNo AND
			    FiscalYear = @FiscalYear AND
			    SerialNo   = @SerialNo)
		order by DocDate desc,EventNo Desc

		IF @TmpAssetPlaque <> '' AND @TmpProcessID <> 495
		begin
			Close Cursor_Rec;
			Deallocate Cursor_Rec;

			IF @TmpProcessID = 450
				--شماره پلاک %s در استقرار اول دوره دارایی به شماره %d استفاده شده است
				SET @strMsgText=TS.pub.funGetMessages(19001,@LanguageID)

			ELSE IF @TmpProcessID = 455
				--شماره پلاک %s در خرید دارایی از طریق انبار به شماره %d استفاده شده است
				SET @strMsgText=TS.pub.funGetMessages(19002,@LanguageID)

			ELSE IF @TmpProcessID = 460
				--شماره پلاک %s در خرید دارایی مستقیم به شماره %d استفاده شده است
				SET @strMsgText=TS.pub.funGetMessages(19003,@LanguageID)
			
			ELSE	
				BEGIN
					SELECT @strMsgText = ProcessName 
					FROM pub.tblProcess 
					WHERE ProcessID = @TmpProcessID AND 
						  ProcessNo = @ProcessNo
					  
					SET @strMsgText='شماره پلاک %s در ' + @strMsgText + ' به شماره %d استفاده شده است'
				END
				
			Raiserror (@strMsgText,16,1,@AssetPlaque,@TmpSerialNo)
			Return
		END


		Fetch NEXT From Cursor_Rec Into @AssetPlaque

	End

	Close Cursor_Rec;
	Deallocate Cursor_Rec; 

	select 'True' as Result

END

GO
