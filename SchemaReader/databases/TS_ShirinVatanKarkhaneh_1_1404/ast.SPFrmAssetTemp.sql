USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1400/03/25
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : کویری های لازم در فرم
-- ==============================================
Create PROCEDURE ast.SPFrmAssetTemp
	@CallType		int,
	@ExtraParams	NVarChar(Max) = ''
WITH ENCRYPTION
AS
BEGIN

if  @CallType=5051
begin 
--	select  ' and  AD1.AssetPlaque  in ( SELECT a.AssetPlaque FROM ast.tblAssetsDtl a inner join ( SELECT max(EventNo)EventNo,MAX(DocDate) DocDate,AssetPlaque FROM ast.tblAssetsDtl a  group by AssetPlaque  ) b on a.AssetPlaque=b.AssetPlaque  and a.EventNo=b.EventNo  and a.AssetState=5 )'
	select  ' and AD1.AssetPlaque  in ( SELECT AssetPlaque FROM [ast].[funAssetPlaqueLastState](AD1.AssetPlaque,'''',0,0,0,0,520,472,470,1) where ProcessID=500  )'

	return
end
if  @CallType=5052
begin 
--	select  'AD1.AssetPlaque  in ( SELECT a.AssetPlaque FROM ast.tblAssetsDtl a inner join ( SELECT max(EventNo)EventNo,MAX(DocDate) DocDate,AssetPlaque FROM ast.tblAssetsDtl a  group by AssetPlaque  ) b on a.AssetPlaque=b.AssetPlaque  and a.EventNo=b.EventNo  and a.AssetState=5 )'
	select  'AD1.AssetPlaque  in ( SELECT AssetPlaque FROM [ast].[funAssetPlaqueLastState](AD1.AssetPlaque,'''',0,0,0,0,520,472,470,1) where ProcessID=500  )'

	return
end


if  @CallType=5053
begin 
--	select  'AD1.AssetPlaque  in ( SELECT a.AssetPlaque FROM ast.tblAssetsDtl a inner join ( SELECT max(EventNo)EventNo,MAX(DocDate) DocDate,AssetPlaque FROM ast.tblAssetsDtl a  group by AssetPlaque  ) b on a.AssetPlaque=b.AssetPlaque  and a.EventNo=b.EventNo  and a.AssetState=5 )'
	Declare  @AssetPlaque as varchar(20)
	Declare  @DocDate as char(10)
	Declare  @EventNo as int
	set @AssetPlaque= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	set @DocDate= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	set @EventNo= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 

	select   'SELECT *  FROM  [ast].[funAssetPlaqueLastState]('''+  @AssetPlaque + ''','''+ @DocDate +''','+ str(@EventNo) +',0,0,0,520,472,470,1)  a  '

	return
end

end
GO
