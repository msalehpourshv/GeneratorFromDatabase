USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/01/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[SpFrmIOSave]
	@ProcessID	smallint,
	@ProcessNo	tinyint,
	@FiscalYear	smallint,
	@SerialNo	int,
	@LanguageID	TINYINT
	
WITH ENCRYPTION
AS

BEGIN

DECLARE @BaseProcessID	smallint,
		@BaseProcessNo	tinyint,
		@BaseFiscalYear	smallint,
		@BaseSerialNo	int,
		@GoodsQuantity FLOAT,
		@GoodsID VARCHAR(30),		
		@strMsgText	 NVarChar(2044)
		
	Declare	Cursor_Rec CURSOR For 
	SELECT 	I1.BaseProcessID , I1.BaseProcessNo , I1.BaseFiscalYear , I1.BaseSerialNo ,
			I1.BaseDocRowNo ,I1.GoodsID,  I1.GoodsQuantity - ISNULL(S.GoodsQuantity,0) GoodsQuantity
	FROM (		
		SELECT	I1.BaseProcessID , I1.BaseProcessNo , I1.BaseFiscalYear , I1.BaseSerialNo ,
				 I1.BaseDocRowNo,I1.GoodsID , SUM(I1.GoodsQuantity) GoodsQuantity
		From inv.tblIODtl I1 
		INNER JOIN 
			(SELECT * from inv.tblIODtl 
			 Where ProcessID = @ProcessID AND ProcessNo= @ProcessNo AND
				   FiscalYear = @FiscalYear AND SerialNo = @SerialNo) I2	
		ON I1.BaseProcessID = I2.BaseProcessID AND I1.BaseProcessNo = I2.BaseProcessNo AND 
		   I1.BaseFiscalYear = I2.BaseFiscalYear  AND I1.BaseSerialNo = I2.BaseSerialNo AND  
		   I1.BaseDocRowNo = I2.BaseDocRowNo
		Group BY I1.BaseProcessID , I1.BaseProcessNo , I1.BaseFiscalYear , I1.BaseSerialNo , I1.BaseDocRowNo,I1.GoodsID
	) I1
	LEFT JOIN inv.tblStorageDocsDtl S
	ON	S.ProcessID  = I1.BaseProcessID  AND S.ProcessNo = I1.BaseProcessNo AND 
	S.FiscalYear = I1.BaseFiscalYear AND S.SerialNo  = I1.BaseSerialNo AND 
	S.DocRowNo   = I1.BaseDocRowNo
	WHERE I1.GoodsQuantity - ISNULL(S.GoodsQuantity,0) < 0

	Open  Cursor_Rec; 

	Fetch NEXT From Cursor_Rec Into @BaseProcessID, @BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@GoodsID,@GoodsQuantity

	While (@@Fetch_Status = 0)
	BEGIN
		
		Close Cursor_Rec;
		Deallocate Cursor_Rec;
		--������ ����� %s ���� �� ���
		SET @strMsgText=TS.pub.funGetMessages(15003,@LanguageID)
		Raiserror (@strMsgText,16,1,@GoodsID)
		Return
		Fetch NEXT From Cursor_Rec Into @BaseProcessID, @BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@GoodsID,@GoodsQuantity
	END
	
END
GO
