USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATE ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/10/21
-- Viewed By	 : Hadi Sadeghi
-- Last Modified : 
-- Description   : Control Receipt Saving
-- =============================================
Create PROCEDURE [ast].[spFrmAssetPlaqueSave] 
  @ProcessID	smallint,
  @ProcessNo	tinyint,
  @FiscalYear	smallint,
  @SerialNo     int,
  @LanguageID   TinyInt=1
  WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;

Declare @strMsgText		NVarChar(2044)
Declare @EventNo		int
Declare @AssetPlaque	Varchar(20)
Declare @MaxEventNo     int
Declare @AssetState     int
Declare @RowNo          int
Declare @LastProcessID  int
  		
	------------------------------
	SET @strMsgText = ''

	------------------------------
	Declare	Cursor_Rec CURSOR For 
    SELECT EventNo,AssetPlaque,RowNo
    FROM ast.tblAssetsDtl
    WHERE  ProcessID=@ProcessID AND
           ProcessNo=@ProcessNo AND
           FiscalYear=@FiscalYear AND
           SerialNo=@SerialNo

	------------------------------
	Open  Cursor_Rec; 

	Fetch NEXT From Cursor_Rec Into @EventNo,@AssetPlaque,@RowNo

		While (@@Fetch_Status = 0)
		BEGIN

			IF @EventNo = 0
				BEGIN

				SELECT @MaxEventNo=MAX(EventNo)
                FROM ast.tblAssetsDtl 
                WHERE AssetPlaque=@AssetPlaque

				------------------------------
				IF @MaxEventNo = 0
					BEGIN
						Close Cursor_Rec;
						Deallocate Cursor_Rec; 
						--شماره پلاک  %s حذف شده است
						SET @strMsgText=TS.pub.funGetMessages(19004,@LanguageID)
						Raiserror (@strMsgText,16,1,@AssetPlaque)
						Return
					END
					
				SELECT @AssetState=AssetState,@LastProcessID  =ProcessID  
                FROM ast.tblAssetsDtl 
                WHERE AssetPlaque=@AssetPlaque AND EventNo=@MaxEventNo
                
				IF @ProcessID in (505,490) and @LastProcessID<>486
					BEGIN
						IF @AssetState = 1
							BEGIN
								Close Cursor_Rec;
								Deallocate Cursor_Rec; 
								--شماره پلاک  %s قبلا به اموال وارد شده است
								SET @strMsgText=TS.pub.funGetMessages(19006,@LanguageID)
								Raiserror (@strMsgText,16,1,@AssetPlaque)
								Return
							END
					END
				ELSE 
					BEGIN
						IF @AssetState = 2 or @AssetState = 4
							BEGIN
								Close Cursor_Rec;
								Deallocate Cursor_Rec;								 
								--شماره پلاک  %s قبلا از اموال خارج شده است
								SET @strMsgText=TS.pub.funGetMessages(19005,@LanguageID)
								Raiserror (@strMsgText,16,1,@AssetPlaque)
								Return
							END
					END
					

				UPDATE ast.tblAssetsDtl SET EventNo = (@MaxEventNo + 1)
				WHERE  ProcessID=@ProcessID AND
					   ProcessNo=@ProcessNo AND
					   FiscalYear=@FiscalYear AND
					   SerialNo=@SerialNo AND 
					   RowNo=@RowNo

			END

			Fetch NEXT From Cursor_Rec Into @EventNo,@AssetPlaque,@RowNo
		End

	------------------------------
	Close Cursor_Rec;
	Deallocate Cursor_Rec; 
	if @ProcessID=485 or @ProcessID=495 
		update ast.tblAssetsDtl 
		set RegisteredValue=0,DepreciationAmount=0--DepreciationAmount+RegisteredValue,
		,DepreciationValue=0
		WHERE ProcessID=@ProcessID AND
			  ProcessNo=@ProcessNo AND
			  FiscalYear=@FiscalYear AND
			  SerialNo=@SerialNo 

	SELECT RowNo,AssetPlaque,EventNo
	FROM ast.tblAssetsDtl 
	WHERE ProcessID=@ProcessID AND
		  ProcessNo=@ProcessNo AND
		  FiscalYear=@FiscalYear AND
		  SerialNo=@SerialNo 

END
GO
