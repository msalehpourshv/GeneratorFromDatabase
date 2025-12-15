USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ====================
-- Author		 : Hadi Sadeghi
-- Create date   : 86/03/26
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ==============================================

CREATE PROCEDURE [sal].[SpSaleServiceControl]
	@AcntCode VarChar(20),
	@LanguageID Tinyint
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	Declare @OtherAcntCode   VarChar(20)
	Declare @GoodsID	    VarChar(20)
	Declare @strMsgText	    NVarchar(2044)

	Declare	Cursor_SaleService CURSOR For 
    SELECT GoodsID
    FROM sal.tblSaleServiceDtl
    WHERE  AcntCode=@AcntCode

	Open  Cursor_SaleService; 
	Fetch NEXT From Cursor_SaleService Into @GoodsID

	While (@@Fetch_Status = 0)
	BEGIN
		
		SET @OtherAcntCode = ''

		SELECT TOP 1 @OtherAcntCode = AcntCode
			FROM sal.tblSaleServiceDtl
			WHERE AcntCode <> @AcntCode AND GoodsID = @GoodsID
		IF @OtherAcntCode <>''
			BEGIN
				Close Cursor_SaleService;
				Deallocate Cursor_SaleService; 
				--کالای %s در کد %s به کار رفته شده است
				SET @strMsgText=TS.pub.funGetMessages(18004,@LanguageID)
				Raiserror (@strMsgText,16,1,@GoodsID,@OtherAcntCode)
				Return
			END
	Fetch NEXT From Cursor_SaleService Into  @GoodsID
	End

	Close Cursor_SaleService;
	Deallocate Cursor_SaleService; 
END















GO
