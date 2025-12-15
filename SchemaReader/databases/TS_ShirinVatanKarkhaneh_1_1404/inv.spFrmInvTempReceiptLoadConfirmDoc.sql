USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[spFrmInvTempReceiptLoadConfirmDoc] 
 @BaseProcessID tinyint,
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @BaseFiscalYear	smallint,
 @BaseSerialNo		int,
 @AcntCode		VarChar(20),
 @DocDate		Char(10),
 @LanguageID	Tinyint,
 @SerialNo		Int,
 @FiscalYear	Smallint,
 @ExtraParams	NVarChar(Max) = ''
WITH ENCRYPTION
 AS

BEGIN

SET NOCOUNT ON;

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

Declare @strMsgText	 NVarChar(2044)
Declare @DocStep Tinyint
-------------------------------------------------------------------------------------------------------------------
IF @BaseProcessID=150 

SELECT * FROM (
	select Distinct acc.funIsCodeClosed(AcntCode) IsCodeClosed
				,*	,[inv].[funGetGoodsQuantityFromSubUnit] (GoodsID, SubUnitID,ConfirmQuantity ) GoodsQuantity,ConfirmQuantity SubUnitQuantity
				, [inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications
			,pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName
			,inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName  
				from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
				where  (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					AND  DocDate<=@DocDate 
					AND ConfirmQuantity>0
					AND   DocStep =2
			 and (
						(@ConfirmCount=0 and (	(@Confirm=0 and DocStep=1)
											  or(@Confirm=1 and DocStep=2)
											  )
						)or 
						(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  						 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)
	) A WHERE IsCodeClosed = 0
		 
-------------------------------------------------------------------------------------------------------------------
ELSE IF  @BaseProcessID=160

SELECT * FROM (
	select Distinct acc.funIsCodeClosed(AcntCode) IsCodeClosed
				,*,[inv].[funGetGoodsQuantityFromSubUnit] (GoodsID, SubUnitID,ConfirmQuantity ) GoodsQuantity,ConfirmQuantity SubUnitQuantity
				, [inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications
			,pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName
			,inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName  
				from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
				where  (@AcntCode IS NULL OR AcntCode = @AcntCode) 
					AND  DocDate<=@DocDate 
					AND ConfirmQuantity>0
					AND   DocStep=2			 
			 and (
						(@ConfirmCount=0 and (	(@Confirm=0 and DocStep=1)
											  or(@Confirm=1 and DocStep=2)
											  )
						)or 
						(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  						 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)				
	) A WHERE IsCodeClosed = 0
		 
-------------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID = 170  or @ProcessID = 171
	BEGIN
		SELECT @DocStep=DocStep
		FROM inv.tblInvTempReceiptHdr 
		WHERE SerialNo=@BaseSerialNo AND 
			  ProcessID=@ProcessID AND 
			  ProcessNo=@ProcessNo AND 
			  FiscalYear=@BaseFiscalYear AND
			  DocDate<=@DocDate
		IF @DocStep=1
		BEGIN
			--این شماره تایید نشده است
			SET @strMsgText=TS.pub.funGetMessages(13001,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

		---------------------------------------------
	SELECT *,[inv].[funGetGoodsQuantityFromSubUnit] (GoodsID, SubUnitID,ConfirmQuantity ) GoodsQuantity,ConfirmQuantity SubUnitQuantity 
	FROM (
		select Distinct acc.funIsCodeClosed(AcntCode) IsCodeClosed,
					pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName
					, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName ,*
					from cmr.FunCmrGoodsQtyRemain(@ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
					where  (@AcntCode IS NULL OR AcntCode = @AcntCode) 
						AND  DocDate<=@DocDate 
						AND ConfirmQuantity>0
						AND DocStep=2
						and (( @BaseProcessID=171 and   Recognition =1)
								or( @BaseProcessID=@ProcessID and   Recognition in(1,2,3,4)))											
		) A WHERE IsCodeClosed = 0		
	END
ELSE IF @ProcessID = 175
	BEGIN
		SELECT @DocStep=DocStep
		FROM inv.tblInvTempReceiptHdr 
		WHERE SerialNo=@BaseSerialNo AND 
			  ProcessID=@ProcessID AND 
			  ProcessNo=@ProcessNo AND 
			  FiscalYear=@BaseFiscalYear AND
			  DocDate<=@DocDate
		IF @DocStep=1
		BEGIN
			--این شماره تایید نشده است
			SET @strMsgText=TS.pub.funGetMessages(13001,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

		---------------------------------------------
	SELECT *,[inv].[funGetGoodsQuantityFromSubUnit] (GoodsID, SubUnitID,ConfirmQuantity ) GoodsQuantity,ConfirmQuantity SubUnitQuantity 
	FROM (
		select Distinct acc.funIsCodeClosed(AcntCode) IsCodeClosed,
					pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName
					, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName ,*
					from cmr.FunCmrGoodsQtyRemain(@ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
					where  (@AcntCode IS NULL OR AcntCode = @AcntCode) 
						AND  DocDate<=@DocDate 
						AND ConfirmQuantity>0
						AND DocStep=2
					--	and (( @BaseProcessID=170 and   Recognition in(1,2,3))or( @BaseProcessID=@ProcessID and   Recognition in(1,2,3,4)))
											
		) A WHERE IsCodeClosed = 0		
	END
		
END
GO
