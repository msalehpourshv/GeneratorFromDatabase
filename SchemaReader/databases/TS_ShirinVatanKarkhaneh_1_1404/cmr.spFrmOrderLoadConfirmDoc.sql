USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : 
-- Last Modified : 1393/08/21 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE [cmr].[spFrmOrderLoadConfirmDoc] 
	 @ProcessID			tinyint,
	 @ProcessNo			tinyint,
	 @BaseFiscalYear	smallint,
	 @BaseSerialNo		int,
	 @DocDate			Char(10),
	 @AcntCode			Varchar(20),
	 @LanguageID		Tinyint,
	 @SerialNo			Int,
	 @FiscalYear		Smallint,
	 @ExtraParams		NVarChar(Max) 

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
	-- select @ConfirmCount,@Sgn1,@Sgn2
Declare @strMsgText	 NVarChar(2044)
Declare @DocStep Tinyint

--select @UnitPart,@str_Goods,@str_GoodsSum
IF @ProcessID=150 -- درخواست خرید
BEGIN
	
	SELECT * 
	FROM ( SELECT DISTINCT acc.funIsCodeClosed(AcntCode) IsCodeClosed,
						   [cmr].[funLastDescError](DocDate,AcntCode,	GoodsID) LastDescError,
						   *,
						   [inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications,
						   ConfirmQuantity SubUnitQuantity,
						   pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, 
						   [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,ConfirmQuantity) GoodsQuantity,
						   IsNull([inv].[FunGetGoodsBarCode](GoodsID), '') BarCode, 
						   inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName 	
			FROM cmr.FunCmrGoodsQtyRemain(@ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
			WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) 
			  AND DocDate<=@DocDate 
			  AND ConfirmQuantity>0
			  AND DocStep = 2
			  AND ((@ConfirmCount=0 AND ((@Confirm=0 and DocStep=1)
					 			    OR (@Confirm=1 and DocStep=2))
				  ) OR (@ConfirmCount>0 
				    AND ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  	AND ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
					AND ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
					AND ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
					AND ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				  ))) A
		   WHERE IsCodeClosed = 0

END
ELSE
IF @ProcessID=160 -- سفارش خرید
	BEGIN
		SELECT @DocStep=DocStep
		FROM cmr.tblOrderHdr 
		WHERE SerialNo=@BaseSerialNo AND 
			  ProcessID=@ProcessID AND 
			  ProcessNo=@ProcessNo AND 
			  FiscalYear=@BaseFiscalYear AND 
			  AcntCode=	@AcntCode AND	
			  DocDate<=@DocDate
		IF @DocStep=1
		BEGIN
			--این شماره تایید نشده است
			SET @strMsgText=TS.pub.funGetMessages(13001,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END
		---------------------------------------------

		SELECT * 
		FROM ( SELECT DISTINCT acc.funIsCodeClosed(AcntCode) IsCodeClosed,
							   [cmr].[funLastDescError](DocDate,AcntCode,	GoodsID) LastDescError,
							   *,
							   [inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications,
							   ConfirmQuantity SubUnitQuantity,
							   pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, 
							   [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,ConfirmQuantity) GoodsQuantity,
							   IsNull([inv].[FunGetGoodsBarCode](GoodsID), '') BarCode,
							   inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName 
			   FROM cmr.FunCmrGoodsQtyRemain(@ProcessID,@ProcessNo,@BaseFiscalYear,@BaseSerialNo,0,0,0,0,0,0)
			   WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) 
				 AND DocDate<=@DocDate 
				 AND ConfirmQuantity>0
				 AND DocStep=2
				 AND ((@ConfirmCount=0 AND ((@Confirm=0 and DocStep=1)
									   OR (@Confirm=1 and DocStep=2))
					  ) OR (@ConfirmCount>0 
					    AND ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  		AND ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
						AND ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
						AND ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
						AND ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
					 ))) A
		   WHERE IsCodeClosed = 0
	END
END
GO
