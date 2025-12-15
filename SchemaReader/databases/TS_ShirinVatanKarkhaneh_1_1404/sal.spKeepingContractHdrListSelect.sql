USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/12/02
-- Viewed By	 : 
-- Last Modified : 93/07/26
-- Description   : 
-- =============================================			   
CREATE PROCEDURE [sal].[spKeepingContractHdrListSelect] 
	@ProcessID		Smallint,
	@ProcessNo		tinyint,
	@DocStep		tinyint,
	@DocDate		Char(10),
	@AcntCode		Varchar(20),
	@FilterInfo		NVarChar(100) = '@@0@0@'
	
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

DECLARE @SalRet_RetToSalOdr AS BIT
DECLARE @LanguageID AS TinyInt
DECLARE @PreSaleDocStep Tinyint
DECLARE @PreSal_GetRemain AS BIT

DECLARE @FromDate		Char(10);
DECLARE @ToDate	    	Char(10);
DECLARE @FromSerialNo	Int;
DECLARE @ToSerialNo		Int;
DECLARE @RowDesc		NVarChar(4000);

	SET @FromDate		= ''
	SET @ToDate	    	= ''
	SET @FromSerialNo	= 0
	SET @ToSerialNo		= 0
	SET @RowDesc		= ''

	IF (@FilterInfo		Is Null)	SET @FilterInfo ='@@0@0@'

	SET @FromDate		= pub.funSplitString(@FilterInfo, '@', 1);
	SET @ToDate	= pub.funSplitString(@FilterInfo, '@', 2);
	SET @FromSerialNo	= pub.funSplitString(@FilterInfo, '@', 3);
	SET @ToSerialNo	= pub.funSplitString(@FilterInfo, '@', 4);
	SET @RowDesc	= pub.funSplitString(@FilterInfo, '@', 5);
	
	SET @SalRet_RetToSalOdr = 'False'
	SET @LanguageID = pub.funGetCurrentLanguageID()
	SET @PreSal_GetRemain = 'False'

	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @PreSal_GetRemain=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PreSal_GetRemain'
	
	--===================
	--IF @ProcessID = 190 -- قرارداد نگهداری
		Select *, [pub].[GetCodeName](AcntCode,@LanguageID) AcntName
		From sal.tblSaleOrderHdr 
		Where ProcessID = 190 And ProcessNo = @ProcessNo And 
			 (@AcntCode IS NULL OR (@AcntCode IS NOT NULL AND AcntCode = @AcntCode)) AND 
			 (@FromDate = '' OR (@FromDate <> '' AND DocDate = @FromDate)) AND
			 (@ToDate ='' OR (@ToDate <> '' AND DocDate = @ToDate)) 
END
GO
