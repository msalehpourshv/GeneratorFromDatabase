USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [cmr].[spFrmCMRSave] 
	 @ProcessID		tinyint,
	 @ProcessNo	    tinyint,
	 @FiscalYear	smallint,
	 @SerialNo		int,
	 @LanguageID    TinyInt=1
WITH ENCRYPTION
AS

BEGIN

	--SET @LanguageID = pub.funGetCurrentLanguageID();

SET NOCOUNT ON;
Declare @strMsgText	 NVarChar(2044)
Declare @Counter	 Int

	IF @ProcessID=150
	BEGIN
		SELECT @Counter=Count(*) 
		FROM cmr.tblCMRDtl
		WHERE (BaseProcessID=@ProcessID AND
			   BaseProcessNo=@ProcessNo AND 
			   BaseFiscalYear=@FiscalYear AND
			   BaseSerialNo=@SerialNo) AND
			not(ProcessID=@ProcessID AND
				ProcessNo=@ProcessNo AND 
				FiscalYear=@FiscalYear AND
				SerialNo=@SerialNo)

		IF @Counter>0
		BEGIN
			--
			SET @strMsgText=TS.pub.funGetMessages(13002,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
	END
	--ELSE
	--IF @ProcessID=155
	--BEGIN
	--
	--END

END
GO
