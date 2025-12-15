USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1397/02/27
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- ----------------------------------------------
-- اعتبار مشتری
-- ==============================================
Create PROCEDURE sal.spSaleWithService
	@ExtraParams		NVarChar(Max) 
	WITH ENCRYPTION
AS

BEGIN

	
DECLARE	@CalcType	Int;
DECLARE	@LangID		Int;
DECLARE	@ProcessID  Int;
DECLARE	@ProcessNo  Int;
DECLARE	@FiscalYear Int;
DECLARE	@SerialNo   Int;

DECLARE	@UnitPartGoods  Int;
DECLARE	@StartPartGoods  Int;
DECLARE	@LenPartGoods Int;

SET @CalcType 			 = pub.funSplitString(@ExtraParams, '@', 1);
SET @LangID 			 = pub.funSplitString(@ExtraParams, '@', 2);
SET @ProcessID			 = pub.funSplitString(@ExtraParams, '@', 3);
SET @ProcessNo			 = pub.funSplitString(@ExtraParams, '@', 4);
SET @FiscalYear			 = pub.funSplitString(@ExtraParams, '@', 5);
SET @SerialNo			 = pub.funSplitString(@ExtraParams, '@', 6);

DECLARE @StrSelect NVarChar(4000)
if @CalcType=1
	begin
	if @ProcessID=180
		SET @StrSelect =' Select *, '''' SettlementDate,'''' SubCustomerCode,0 PayWithOutCheque,0 PayWithCheque, 0 TaxAndTollExtra from   sal.tblSaleOrderHdr
		Where ProcessID='+STR(@ProcessID)+' and  ProcessNo='+STR(@ProcessNo)+' 
		and FiscalYear='+STR(@FiscalYear)+' and SerialNo='+STR(@SerialNo)+' '
	if @ProcessID=240 
		SET @StrSelect =' Select * from   inv.tblPreSaleHdr 
		Where  ConfirmState=1 and ProcessID='+STR(@ProcessID)+' and  ProcessNo='+STR(@ProcessNo)+' 
		and FiscalYear='+STR(@FiscalYear)+' and SerialNo='+STR(@SerialNo)+' '
	end
if @CalcType=2
begin
	if @ProcessID=180
		SET @StrSelect =' Select * ,
		inv.funGetUnitName(SubUnitID,'+ STR(@LangID) +') AS SubUnitName,''کيلويي'' CalcType , 0 MainAmount,0 ServiceAmount  
		from  sal.tblSaleOrderDtl
		Where ProcessID='+STR(@ProcessID)+' and  ProcessNo='+STR(@ProcessNo)+' 
		and FiscalYear='+STR(@FiscalYear)+' and SerialNo='+STR(@SerialNo)+' 
		and ltrim(str(ProcessID))+''@''+		ltrim(str(ProcessNo))	+''@''+	ltrim(str(FiscalYear))	 +''@''+ 	ltrim(str(SerialNo))+''@''+	ltrim(str(DocRowNo))
		not in(  select ltrim(str(BaseProcessID))+''@''+		ltrim(str(BaseProcessNo))	+''@''+	ltrim(str(BaseFiscalYear))	 +''@''+ 	ltrim(str(BaseSerialNo))+''@''+	ltrim(str(BaseDocRowNo)) from    inv.tblStorageDocsDtl)
		'
	if @ProcessID=240 
		SET @StrSelect =' Select * ,
		inv.funGetUnitName(SubUnitID,'+ STR(@LangID) +') AS SubUnitName
		from   inv.tblPreSaleDtl 
		Where ProcessID='+STR(@ProcessID)+' and  ProcessNo='+STR(@ProcessNo)+' 
		and FiscalYear='+STR(@FiscalYear)+' and SerialNo='+STR(@SerialNo)+' '
end	
if @CalcType=3
begin
SET @UnitPartGoods			 = pub.funSplitString(@ExtraParams, '@', 7);
SET @StartPartGoods			 = pub.funSplitString(@ExtraParams, '@', 8);
SET @LenPartGoods			 = pub.funSplitString(@ExtraParams, '@', 9);

		SET @StrSelect =' Select GoodsID  from   inv.tblStorageDocsDtl
		Where ProcessID='+STR(@ProcessID)+' and  ProcessNo='+STR(@ProcessNo)+' 
		and FiscalYear='+STR(@FiscalYear)+' and SerialNo='+STR(@SerialNo)+' 
		and SUBSTRING( GoodsID,'+STR(@StartPartGoods)+','+STR(@LenPartGoods)+') in 
		(Select GoodsID FROM inv.tblGoods where PartNumber='+STR(@UnitPartGoods)+' and  IsService=0 ) 
		group by GoodsID  
		having Count(*)>1
 '
end
print @StrSelect	
EXECUTE sp_executesql @StrSelect	
		
end
GO
