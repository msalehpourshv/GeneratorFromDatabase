USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/07/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [prd].[SpControlGoodsInCopyFormula]
	@GoodsID		Varchar(20),
    @IsFromGoods	Bit,
	@FormulaNo		Int=-1,
	@LanguageID		Tinyint=1

	WITH ENCRYPTION
AS

BEGIN

	Declare @TempFormulaNo	Int
	Declare @FormulaName	Nvarchar(100)
	Declare @strMsgText		Nvarchar(2000)

	SET @TempFormulaNo = -1
	SET @FormulaName = ''
	SET @strMsgText = ''

	IF @FormulaNo = -1
		BEGIN
			SELECT TOP 1 @TempFormulaNo=SerialNo ,@FormulaName=FormulaName
			FROM prd.tblFormulasHdr
			WHERE ProductID=@GoodsID
			Order By SerialNo desc

			IF @IsFromGoods = 1 AND @TempFormulaNo = -1
				BEGIN
					-- 
					SET @strMsgText=TS.pub.funGetMessages(16008,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
				END
				
			if @IsFromGoods=0 and(	select count(*) from inv.tblStorageDocsHdr where  ProductID=@GoodsID and FormulaNo=@TempFormulaNo)>0
			begin 
				-- 
					SET @strMsgText=TS.pub.funGetMessages(16016,@LanguageID)
					Raiserror (@strMsgText,16,1)
					Return
			end
			
			IF @TempFormulaNo = -1
				SET @TempFormulaNo = 0
		END
	ELSE
		BEGIN
			SELECT @TempFormulaNo=SerialNo ,@FormulaName=FormulaName
			FROM prd.tblFormulasHdr
			WHERE ProductID=@GoodsID AND SerialNo = @FormulaNo

			IF @IsFromGoods = 1
				BEGIN
					IF @TempFormulaNo = -1
						BEGIN	
							--  
							SET @strMsgText=TS.pub.funGetMessages(16009,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return	
						END
				END
			ELSE
				BEGIN
					IF @TempFormulaNo > 0
						BEGIN	
							-- 
							SET @strMsgText=TS.pub.funGetMessages(16010,@LanguageID)
							Raiserror (@strMsgText,16,1)
							Return	
						END
				END
		END
		
	SELECT @TempFormulaNo AS FormulaNo, @FormulaName AS FormulaName
END

GO
