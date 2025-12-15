USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [cmr].[spFrmOrderDtlListSelect] 
	@ProcessID	Tinyint,
	@DocDate	Char(10),
	@AcntCode	Varchar(20),
	@GoodsID	Varchar(20),
	@LanguageID int,
	@SerialNo		Int,
	@FiscalYear		Smallint,
	@BaseSerialNo	Int,
	@BaseFiscalYear	Smallint,
	@ExtraParams		NVarChar(max) = ''
WITH ENCRYPTION
AS
BEGIN

SET NOCOUNT ON;

	Declare @ProcessNo Tinyint
	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;
	DECLARE @SqlStr			Varchar(1000);

	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	SET @SqlStr				= pub.funSplitString(@ExtraParams, '@', 9);

	 

	set @SqlStr	=ISNULL(@SqlStr	,' ')

	if @ProcessNo is null 	set @ProcessNo=0

	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart


	set @FiscalYear=ISNULL(@FiscalYear,0)
	set @SerialNo=ISNULL(@SerialNo,0)
	set @SerialNo=ISNULL(@SerialNo,0)
	set @AcntCode=ISNULL(@AcntCode,'')
	set @DocDate=ISNULL(@DocDate,'')

	 

IF @ProcessID=160
	BEGIN
	
		DECLARE @StrSelect1		NVarChar(Max);
		


		set @StrSelect1 = '	
		SELECT 	acc.funIsCodeClosed(AcntCode) IsCodeClosed, ProcessID, ProcessNo, FiscalYear, SerialNo,DocRowNo RowNo, DocRowNo,
				[cmr].[funLastDescError](DocDate,AcntCode,	GoodsID) LastDescError, DocStep, DocDate, AcntCode, GoodsID, SubUnitID, ConfirmQuantity SubUnitQuantity, 
				ConfirmQuantity, [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,ConfirmQuantity)  GoodsQuantity, DocDesc DescDtl,DocDate OrderDate, 
				BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, 
				[inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications, DocDesc DocDesc, pub.GetCodeName(AcntCode,1) AcntName,
				pub.funGetGoodsName(GoodsID,'+str(@LanguageID)+') AS GoodsName, inv.funGetUnitName(SubUnitID,'+str(@LanguageID)+') AS SubUnitName  
			From cmr.FunCmrGoodsQtyRemain(150,'+str(@ProcessNo)+','+str(@FiscalYear)+','+str(@SerialNo)+',0,0,0,0,0,0) OD
		WHERE acc.funIsCodeClosed(AcntCode) = 0
		and DocDate <='''+@DocDate+'''
		and ('''+@AcntCode+''' =''''   OR AcntCode = '''+@AcntCode+''') 
		and ConfirmQuantity>0
		and   DocStep = 2	
		 and (
				('+str(@ConfirmCount)+'=0 and (	('+str(@Confirm)+'=0 and DocStep=1)
									  or('+str(@Confirm)+'=1 and DocStep=2)
									  )
				)or 
				('+str(@ConfirmCount)+'>0 and (('+str(@Sgn1)+'=0 and SgnSN1=0) or ('+str(@Sgn1)+'>0 and SgnSN1>0)  )
				  				 and (('+str(@Sgn2)+'=0 and SgnSN2=0) or ('+str(@Sgn2)+'>0 and SgnSN2>0)  )
								 and (('+str(@Sgn3)+'=0 and SgnSN3=0) or ('+str(@Sgn3)+'>0 and SgnSN3>0)  )
								 and (('+str(@Sgn4)+'=0 and SgnSN4=0) or ('+str(@Sgn4)+'>0 and SgnSN4>0)  )
								 and (('+str(@Sgn5)+'=0 and SgnSN5=0) or ('+str(@Sgn5)+'>0 and SgnSN5>0)  )
				)
				)' +@SqlStr+''
			print   @StrSelect1;             
			EXEC sp_executesql @StrSelect1	
	END
ELSE
IF @ProcessID=165
	BEGIN
		DECLARE @StrSelect2		NVarChar(Max);
		set @StrSelect2 = '
		SELECT * FROM (
			SELECT 	acc.funIsCodeClosed(AcntCode) IsCodeClosed,ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
				DocStep, DocDate, AcntCode, GoodsID, SubUnitID, ConfirmQuantity SubUnitQuantity, 
				ConfirmQuantity, [inv].[funGetGoodsQuantityFromSubUnit](GoodsID,SubUnitID,ConfirmQuantity) GoodsQuantity,  GoodsPrice, DocDesc DescDtl, DocDate OrderDate, BaseProcessID, 
				BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo,0 AgreeNo, DocDesc, pub.GetCodeName(AcntCode,1) AcntName,
				[inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications,
				IsNull([inv].[FunGetGoodsBarCode](GoodsID), '') BarCode,
				pub.funGetGoodsName(GoodsID,'+str(@LanguageID)+') AS GoodsName, 
				inv.funGetUnitName(SubUnitID,'+str(@LanguageID)+') AS SubUnitName 
		From cmr.FunCmrGoodsQtyRemain(160,'+str(@ProcessNo)+','+str(@FiscalYear)+','+str(@SerialNo)+',0,0,0,0,0,0) OD
		WHERE ('''+@AcntCode+''' IS '''' OR AcntCode = '+@AcntCode+') AND ('+str(@GoodsID)+' IS NULL OR GoodsID = '+str(@GoodsID)+') AND DocDate <= '+@DocDate+' AND
			  ('+str(@BaseSerialNo)+' IS NULL OR (SerialNo='+str(@BaseSerialNo)+' AND FiscalYear='+str(@BaseFiscalYear)+')) 
			   and (
				('+str(@ConfirmCount)+'=0 and (	('+str(@Confirm)+'=0 and DocStep=1)
									  or('+str(@Confirm)+'=1 and DocStep=2)
									  )
				)or 
				('+str(@ConfirmCount)+'>0 and (('+str(@Sgn1)+'=0 and SgnSN1=0) or ('+str(@Sgn1)+'>0 and SgnSN1>0)  )
				  				 and (('+str(@Sgn2)+'=0 and SgnSN2=0) or ('+str(@Sgn2)+'>0 and SgnSN2>0)  )
								 and (('+str(@Sgn3)+'=0 and SgnSN3=0) or ('+str(@Sgn3)+'>0 and SgnSN3>0)  )
								 and (('+str(@Sgn4)+'=0 and SgnSN4=0) or ('+str(@Sgn4)+'>0 and SgnSN4>0)  )
								 and (('+str(@Sgn5)+'=0 and SgnSN5=0) or ('+str(@Sgn5)+'>0 and SgnSN5>0)  )
				)
				)
			) A WHERE IsCodeClosed = 0 ' +@SqlStr+''
		--	and (@ProcessNo=0 or ProcessNo=@ProcessNo)
		print   @StrSelect2;             
		EXEC sp_executesql @StrSelect2
	END

END
GO
