USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 92/05/05
-- Description:	
-- =============================================

CREATE PROCEDURE [inv].[spFrmPreSaleDelete] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @LanguageID	tinyint
 
WITH ENCRYPTION
AS

BEGIN

SET NOCOUNT ON;
Declare @strMsgText		NVarChar(2044)
Declare @rr		        NVarChar(500)
Declare @DocRowNo		Int
Declare @BaseSerialNo	Int

	Declare	Cursor_PreSale CURSOR For 
	SELECT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo
	FROM inv.tblPreSaleDtl
	WHERE  ProcessID=@ProcessID AND
		   ProcessNo=@ProcessNo AND
		   FiscalYear=@FiscalYear AND
		   SerialNo=@SerialNo 

	Open  Cursor_PreSale; 

	Fetch NEXT From Cursor_PreSale Into @ProcessID, @ProcessNo,@FiscalYear,@SerialNo,@DocRowNo

	While (@@Fetch_Status = 0)
	
	BEGIN
		
		SELECT TOP 1  @BaseSerialNo = SerialNo
		FROM inv.tblStorageDocsDtl
		WHERE	BaseProcessID = @ProcessID AND BaseProcessNo = @ProcessNo AND 
				BaseFiscalYear = @FiscalYear AND BaseSerialNo = @SerialNo AND BaseDocRowNo = @DocRowNo
		ORDER BY DocDate DESC,VolumeRowNo DESC
		
		If @BaseSerialNo >0  
		BEGIN
			Close Cursor_PreSale;
			Deallocate Cursor_PreSale;
			-- این برگه به علت استفاده در فروش %d غیر قابل حذف میباشد
			SET @strMsgText=TS.pub.funGetMessages(18007,@LanguageID)
			Raiserror (@strMsgText,16,1,@BaseSerialNo)
			Return
		END
		
		FETCH NEXT FROM Cursor_PreSale Into @ProcessID, @ProcessNo,@FiscalYear,@SerialNo,@DocRowNo
	END

	Close Cursor_PreSale;
	Deallocate Cursor_PreSale; 
	
END
GO
