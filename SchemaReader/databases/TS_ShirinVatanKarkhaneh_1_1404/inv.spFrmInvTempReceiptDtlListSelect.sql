USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : Hadi Sadeghi
-- Last Modified : 82/02/30
-- Description   : 
-- =============================================
Create PROCEDURE inv.spFrmInvTempReceiptDtlListSelect 
	@BaseProcessID	VarChar(20),
	@ProcessID	Tinyint,
	@ProcessNo	Tinyint,
	@StoreID	VarChar(20),
	@GoodsID	VarChar(20),
	@AcntCode	VarChar(20),
	@DocDate	Char(10),
	@LanguageID int,
	@SerialNo	INT,
	@FiscalYear Smallint,
	@BaseSerialNo	Int,
	@BaseFiscalYear Smallint,
	@ExtraParams		NVarChar(Max) = ''
	
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

IF @ProcessID=170
	BEGIN
		IF @BaseProcessID = 150 or @BaseProcessID=160
		SELECT * FROM (
			SELECT acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,
				OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocStep, 
				OD.DocDate, OD.GoodsID, OD.SubUnitID, ConfirmQuantity SubUnitQuantity, ConfirmQuantity,
				isnull([inv].[funGetGoodsQuantityFromSubUnit] (OD.GoodsID, OD.SubUnitID,ConfirmQuantity ) ,0) GoodsQuantity, 
				DocDesc DescDtl, OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.DocRowNo,
				pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
				[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
				[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
							OD.FiscalYear,OD.SerialNo,OD.DocRowNo,@StoreID,OD.GoodsID,'',@DocDate,1)  AS GoodsRemain
			From cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0) OD
			WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode) AND  OD.DocDate<=@DocDate AND ConfirmQuantity>0 AND 
				  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) AND
				  (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) 
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

	
END
ELSE IF @ProcessID=175 or @ProcessID=176
SELECT * FROM (
	SELECT acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed,	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, OD.RowNo, OD.DocRowNo, 
			OD.DocStep, OD.DocDate, --OD.StoreID,
			 OD.AcntCode, OD.GoodsID, OD.SubUnitID, ConfirmQuantity SubUnitQuantity, 
			isnull([inv].[funGetGoodsQuantityFromSubUnit] (OD.GoodsID, OD.SubUnitID,ConfirmQuantity ),0) GoodsQuantity, 
			ConfirmQuantity, DocDesc DescDtl, OD.BaseProcessID, 
			OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, 
			[inv].[funGetTechnicalSpecifications](OD.GoodsID) AS TechnicalSpecifications,
			pub.funGetGoodsName(OD.GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName ,Recognition
	From cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0) OD
	WHERE (@GoodsID IS NULL OR OD.GoodsID = @GoodsID) AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND  DocDate<=@DocDate AND 
		  (@BaseSerialNo IS NULL OR (OD.SerialNo=@BaseSerialNo AND OD.FiscalYear=@BaseFiscalYear)) AND 
		  Recognition not in (0 ) 
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
		  

END

GO
