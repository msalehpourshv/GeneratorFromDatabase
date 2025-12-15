USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 88/05/14
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE trs.spPayDirectionConfirmDoc 
	@DocDate		Char(10),
	@ProcessNo		Int,
	@SerialNo		Int,
	@BaseSerialNo	Int,
	@FiscalYear		Smallint,
	@BaseFiscalYear	SMALLINT,
	@ExtraParams	NVarChar(Max)
WITH ENCRYPTION
 AS
BEGIN
	
	
	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;

	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	 

		SELECT FiscalYear,SerialNo,DebitCode 
		FROM trs.tblPayHdr 
		WHERE ProcessID = 41 AND ProcessNo=@ProcessNo AND
			  DocDate <= @DocDate AND
			  SerialNo = @BaseSerialNo AND 
			  FiscalYear = @BaseFiscalYear
			   and (
						@ConfirmCount=0 or 
						(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  						 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)
		EXCEPT
		SELECT BaseFiscalYear,BaseSerialNo,DebitCode 
		FROM trs.tblPayHdr 
		WHERE ProcessID = 2 AND ProcessNo=@ProcessNo AND  
			  NOT (SerialNo=@SerialNo AND FiscalYear=@FiscalYear) 	
			  
END
GO
