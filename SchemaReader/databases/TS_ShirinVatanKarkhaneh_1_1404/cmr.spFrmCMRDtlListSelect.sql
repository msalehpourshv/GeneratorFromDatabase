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
Create PROCEDURE [cmr].[spFrmCMRDtlListSelect]
	@DocDate	Char(10),
	@AcntCode	Varchar(20),
	@GoodsID	Varchar(20),
	@FiscalYear	smallint,
	@SerialNo	int,
	@LanguageID int,
	@ProcessID	smallint,
	@ExtraParams		NVarChar(Max) = ''
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

	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	
	
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
if @ProcessID=155
	SELECT * FROM (
		SELECT DISTINCT acc.funIsCodeClosed(Cd1.AcntCode) IsCodeClosed, Cd1.ProcessID, Cd1.ProcessNo, Cd1.FiscalYear, Cd1.SerialNo, Cd1.RowNo, Cd1.DocRowNo,
			Cd1.DocStep, Cd1.DocDate, Cd1.AcntCode, Cd1.GoodsID, Cd1.SubUnitID,ConfirmQuantity SubUnitQuantity, 
			ConfirmQuantity,  DocDesc DescDtl, DocDate OrderDate, Cd1.BaseProcessID,
			Cd1.BaseProcessNo, Cd1.BaseFiscalYear, Cd1.BaseSerialNo, Cd1.BaseDocRowNo, 
			pub.funGetGoodsName(Cd1.GoodsID,@LanguageID) AS GoodsName, IsNull([inv].[FunGetGoodsBarCode] (Cd1.GoodsID), '') BarCode,
			inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
			[inv].[funGetTechnicalSpecifications](Cd1.GoodsID) AS TechnicalSpecifications
			,inv.funGetGoodsQuantityFromSubUnit(GoodsID,SubUnitID,ConfirmQuantity) GoodsQuantity
		From cmr.FunCmrGoodsQtyRemain(150,@ProcessNo,0,0,0,0,0,0,0,0)		Cd1	
		WHERE  (@AcntCode IS NULL OR AcntCode = @AcntCode) 
			AND (@GoodsID IS NULL OR Cd1.GoodsID = @GoodsID) 
			AND Cd1.DocDate<=@DocDate AND 
			   (@SerialNo IS NULL OR (Cd1.SerialNo=@SerialNo AND Cd1.FiscalYear=@FiscalYear)) 
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
else IF @ProcessID=150
	begin
	if @FiscalYear is null
		set @FiscalYear=0
	if @SerialNo is null
		set @SerialNo=0

	Select *from (
		select a.*,[inv].[funGetUnitName] (a.SubUnitID,1)SubUnitName
		 ,[pub].[funGetGoodsName] (a.GoodsID,1) GoodsName
		 , cast([inv].[funGetGoodsQuantityFromSubUnit](a.GoodsID,a.SubUnitID
						,(SELECT	isnull(sum(GoodsQuantity*EnterKind),0) FROM	inv.tblStorageDocsDtl d 
						WHERE	d.GoodsID = a.GoodsID AND d.StoreID = a.StoreID	and d.DocDate <=@DocDate
					)   )as float) Qty 
		FROM inv.tblStoresRequestsDtl a
		inner join (
		
		select ProcessID,ProcessNo,FiscalYear,SerialNo ,DocRowNo
		 FROM inv.tblStoresRequestsDtl 
	where (@FiscalYear=0  or  @FiscalYear=FiscalYear)
	and (@SerialNo=0  or  @SerialNo=SerialNo)
		except
		select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo ,BaseDocRowNo
		FROM  inv.tblStorageDocsDtl
--		where BaseProcessID=230		and BaseProcessNo=1		and BaseFiscalYear=97		and BaseSerialNo=16
		except
		select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo  ,BaseDocRowNo
		FROM cmr.tblCMRDtl	
--		where BaseProcessID=230		and BaseProcessNo=1		and BaseFiscalYear=97		and BaseSerialNo=16

	) b on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo =b.SerialNo and a.DocRowNo =b.DocRowNo 

	) a  Where 
	--Qty<=SubUnitQuantity 	and 
	(@FiscalYear=0  or  @FiscalYear=FiscalYear)
	and (@SerialNo=0  or  @SerialNo=SerialNo)
	and (@ProcessNo=0 or ProcessNo=@ProcessNo)			
	end 
	
	
END
GO
