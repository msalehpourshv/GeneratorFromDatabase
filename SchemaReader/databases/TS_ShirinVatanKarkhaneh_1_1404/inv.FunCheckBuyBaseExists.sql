USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create Function inv.FunCheckBuyBaseExists
(
@ProcessID	Int = 0,
@ProcessNo	Int = 0,
@FiscalYear	Int = 0,
@SerialNo	Int = 0,
@DocRowNo  	Int = 0
 )

RETURNS Varchar(200)
WITH ENCRYPTION
AS
BEGIN

DECLARE @BaseProcessID	Int = 0;
DECLARE	@BaseProcessNo	Int = 0;
DECLARE	@BaseFiscalYear	Int = 0;
DECLARE	@BaseSerialNo	Int = 0;
DECLARE	@BaseDocRowNo  	Int = 0;
DECLARE @RST			Varchar(Max);

IF @ProcessID = 55
	SELECT @BaseProcessID = BaseProcessID,
		   @BaseProcessNo = BaseProcessNo,
		   @BaseFiscalYear = BaseFiscalYear,
		   @BaseSerialNo = BaseSerialNo,
		   @BaseDocRowNo = BaseDocRowNo 
	FROM inv.tblStorageDocsDtl
	WHERE ProcessID = @ProcessID	
	  AND ProcessNo = @ProcessNo	
	  AND FiscalYear = @FiscalYear	
	  AND SerialNo = @SerialNo	
	  AND DocRowNo = @DocRowNo  	
	  AND BaseProcessID = 170
	
	IF ISNULL(@BaseSerialNo, 0) > 0
	BEGIN
		--set @RST= str( @BaseProcessID	) +'@'+	str( @BaseProcessNo		) +'@'+	str( 	@BaseFiscalYear		) +'@'+	str( 	@BaseSerialNo		) +'@'+	str( 	@BaseDocRowNo  	    ) 	   
		SET @RST = ' مرجع رسید موقت ' + ':' + LTRIM(RTRIM(STR(@BaseFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseSerialNo)))
	    SET @RST = @RST + ' | ' + ISNULL(inv.FunCheckBuyBaseExists (@BaseProcessID, @BaseProcessNo, @BaseFiscalYear, @BaseSerialNo, @BaseDocRowNo), '')
 		RETURN @RST 
	END 


IF @ProcessID = 170
	SELECT @BaseProcessID = BaseProcessID,
		   @BaseProcessNo = BaseProcessNo,
		   @BaseFiscalYear = BaseFiscalYear,
		   @BaseSerialNo = BaseSerialNo,
		   @BaseDocRowNo = BaseDocRowNo 
	FROM inv.tblInvTempReceiptDtl
	WHERE ProcessID = @ProcessID	
	  AND ProcessNo = @ProcessNo	
	  AND FiscalYear = @FiscalYear	
	  AND SerialNo = @SerialNo	
	  AND DocRowNo = @DocRowNo  	
	  AND BaseProcessID = 160

	IF ISNULL(@BaseSerialNo, 0) > 0
	BEGIN
		--set @RST= str( @BaseProcessID	) +'@'+	str( @BaseProcessNo		) +'@'+	str( 	@BaseFiscalYear		) +'@'+	str( 	@BaseSerialNo		) +'@'+	str( 	@BaseDocRowNo  	    ) 	   
		SET @RST = ' مرجع سفارش ' + ':'+ LTRIM(RTRIM(STR(@BaseFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseSerialNo)))
	    SET @RST = @RST + ' | ' + ISNULL(inv.FunCheckBuyBaseExists (@BaseProcessID, @BaseProcessNo, @BaseFiscalYear, @BaseSerialNo, @BaseDocRowNo), '')
 		RETURN @RST 
	END 

IF @ProcessID = 160
	SELECT @BaseProcessID = BaseProcessID,
		   @BaseProcessNo = BaseProcessNo,
		   @BaseFiscalYear = BaseFiscalYear,
		   @BaseSerialNo = BaseSerialNo,
		   @BaseDocRowNo = BaseDocRowNo 
	FROM cmr.tblOrderDtl
	WHERE ProcessID = @ProcessID	
	  AND ProcessNo = @ProcessNo	
	  AND FiscalYear = @FiscalYear	
	  AND SerialNo = @SerialNo	
	  AND DocRowNo = @DocRowNo  
	  AND BaseProcessID = 150

	IF ISNULL(@BaseSerialNo, 0) > 0 
	BEGIN
		--set @RST= str( @BaseProcessID	) +'@'+	str( @BaseProcessNo		) +'@'+	str( 	@BaseFiscalYear		) +'@'+	str( 	@BaseSerialNo		) +'@'+	str( 	@BaseDocRowNo  	    ) 	   
		SET @RST= ' مرجع درخواست ' + ':' + LTRIM(RTRIM(STR(@BaseFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseSerialNo)))
	    SET @RST = @RST + ' | ' + ISNULL(inv.FunCheckBuyBaseExists (@BaseProcessID, @BaseProcessNo, @BaseFiscalYear, @BaseSerialNo, @BaseDocRowNo), '')
 		RETURN @RST
	END  

	RETURN NCHAR(8204) + @RST + NCHAR(8204) + ' | '
END 
GO
