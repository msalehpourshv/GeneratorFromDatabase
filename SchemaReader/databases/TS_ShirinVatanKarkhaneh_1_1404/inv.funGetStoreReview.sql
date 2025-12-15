USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 98/11/30
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
--select * from [inv].[funGetStoreReview](2,7,7,1,1,20,1,0,40)
Create PROCEDURE [inv].[funGetStoreReview]
@AcntPart as tinyint,
@AcntStart as tinyint,
@AcntLen as tinyint,
@GoodsPart as tinyint,
@GoodsStart as tinyint,
@GoodsLen as tinyint,
@LanguageID as tinyint,
@UserIsAdmin as bit,
@UserID as integer,
@StoreID as varchar(20),
@GoodsID as varchar(20),
@FromDate as varchar(10),
@ToDate as varchar(10),
@AcntCode as varchar(20),
@BatchNo as varchar(20),
@UserPriceID as bigint,
@ShowRemain as bigint
WITH ENCRYPTION
AS
begin

DECLARE @AcntStart1 as tinyint,@AcntLen1 as tinyint
DECLARE @AcntStart2 as tinyint,@AcntLen2 as tinyint
DECLARE @AcntStart3 as tinyint,@AcntLen3 as tinyint
DECLARE @AcntStart4 as tinyint,@AcntLen4 as tinyint
DECLARE @inv_GoodsAcntGroup	BIT

 
Declare  @lenDecimal as int
 SELECT @AcntStart1=acc.funGetAcntLayerStartandLen(1,1)
 SELECT @AcntStart2=acc.funGetAcntLayerStartandLen(2,1)
 SELECT @AcntStart3=acc.funGetAcntLayerStartandLen(3,1)
 SELECT @AcntStart4=acc.funGetAcntLayerStartandLen(4,1)
 SELECT @AcntLen1=acc.funGetAcntLayerStartandLen(1,2)
 SELECT @AcntLen2=acc.funGetAcntLayerStartandLen(2,2)
 SELECT @AcntLen3=acc.funGetAcntLayerStartandLen(3,2)
 SELECT @AcntLen4=acc.funGetAcntLayerStartandLen(4,2)

 IF (@ToDate Is Null)or @ToDate=''
	SET @ToDate  = '9999/12/99';

SET @inv_GoodsAcntGroup = 'False'

SELECT @inv_GoodsAcntGroup = SettingValue 
FROM pub.tblSettings 
WHERE UPPER(SettingKey) = UPPER('inv_GoodsAcntGroup')
 
 select @lenDecimal=SettingValue from pub.tblSettings where SettingKey='PriceDecimalsToForms'
 set @lenDecimal=isnull(@lenDecimal,0)

	DECLARE @StrSelect1		NVarChar(Max);
	DECLARE @StrSelect2		NVarChar(Max);
	DECLARE @StrSelectMain		NVarChar(Max);


		set @StrSelect1 =' 
		SELECT H.ProcessID,
			   H.ProcessNo,
			   H.FiscalYear,
			   H.SerialNo,
			   H.DocDate,
			   H.VchDate,
			   H.VchNo, 
			   H.AgreeNo,
			   D.EnterKind,
			   D.AcntCode,
			   D.StoreID,
			   D.GoodsID,
			   D.SubUnitID,
			   D.BatchNo,
			   D.UserPriceID, 
			   ISNULL(G.GoodsName,'''') GoodsName,
			   cast (D.GoodsQuantity as float )GoodsQuantity, 
			   D.DocRowNo, 
			   D.RowNo,
			   ISNULL(U1.UnitName,'''') UnitName,
			   cast (D.SubUnitQuantity  as float )SubUnitQuantity,
			   ISNULL(U2.UnitName,'''')UnitName2,
			   cast (cast(CASE WHEN D.SubUnitID = SU.SubUnitID then D.SubUnitQuantity ELSE (D.GoodsQuantity *ISNULL(SU.UnitValue,1)/Case When ISNULL(SU.MainUnitValue,1) = 0 Then 1 Else ISNULL(SU.MainUnitValue,1) end ) END as decimal(18,'+str(@lenDecimal)+' ))as float ) SubUnitQuantity2,
			   ISNULL(U3.UnitName,'''')UnitName3,
			   D.' + LTRIM(inv.funGoodsAmount(@ToDate)) + ' GoodsAmount,
			   D.GoodsPrice,
			   D.VolumeRowNo, 
			   ISNULL(A.AcntName,'''') AcntName,
			   ISNULL(A1.AcntName,'''')+'' ''+ISNULL(A2.AcntName,'''')+'' ''+ISNULL(A3.AcntName,'''')+'' ''+ISNULL(A4.AcntName,'''') AcntName2,
			   ISNULL(S.StoreName,'''')StoreName,
			   ISNULL(P.ProcessName,'''')ProcessName,
			   ISNULL(BD.BatchName,'''')BatchName,
			   ISNULL(BD.BatchExtraField1,'''') BatchExtraField1,
			   ISNULL(BD.BatchExtraField2,'''') BatchExtraField2,
			   ISNULL(BD.BatchExtraField3,'''') BatchExtraField3,
			   ISNULL(BD.BatchExtraField4,'''') BatchExtraField4,
			   ISNULL(B.BatchCount,0.0)BatchCount,ISNULL(B.ExpireDate,'''') ExpireDate,
			   ISNULL(B.ShiftID,'''') ShiftID,
			   ISNULL(B.ProductionLineID,'''') ProductionLineID,
			   ISNULL(GU.UParams,'''') UParams,
			   ISNULL(PL.ProductionLineName,'''') ProductionLineName,
			   ISNULL(SD.ShiftName,'''') ShiftName,
			   cast (CASE WHEN '+str(@ShowRemain)+'=0 then 0  else  (SELECT SUM(EnterKind* GoodsQuantity) 
																			FROM inv.tblStorageDocsDtl a 
																			WHERE a.GoodsID=D.GoodsID and a.StoreID=D.StoreID 
																			AND (a.DocDate<D.DocDate OR (a.DocDate=D.DocDate AND a.VolumeRowNo<=D.VolumeRowNo))) end as float ) Remain,
			   D.BaseFiscalYear, 
			   D.BaseSerialNo,
			   TechnicalSpecifications,
			   TechnicalNo,
			   MiscSpecifications,
			   BarCode,
			   ISNULL(H.GoodsReciverID,'''') GoodsReciverID, 
			   ISNULL(inv.funGetReciverName(H.GoodsReciverID, 1),'''') GoodsReciverName,
			   Cast(ISNULL(D.TaskFiscalYear,0) as smallint) TaskFiscalYear, 
			   Cast(ISNULL(D.TaskSerialNo,0) as int) TaskSerialNo,
			   Cast(ISNULL(D.BaseTaskFiscalYear,0) as smallint) BaseTaskFiscalYear, 
			   Cast(ISNULL(D.BaseTaskSerialNo,0) as int) BaseTaskSerialNo,			 
			   D.DiscountDtl, 
			   D.TaxOverWorthCostDtl,
			   Cast(CASE WHEN '+str(@inv_GoodsAcntGroup)+' = 0 THEN '''' ELSE IsNull(GA.GoodsAcntGroupID,'''') END as NVarChar) GoodsAcntGroupID,
			   Cast(CASE WHEN '+str(@inv_GoodsAcntGroup)+' = 0 THEN '''' ELSE IsNull(GAD.GoodsAcntGroupName,'''') END as NVarChar) GoodsAcntGroupName

	FROM inv.tblStorageDocsHdr H 
	INNER JOIN inv.tblStorageDocsDtl D 	ON  H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
	Left Join acc.tblAcntDtl A ON SUBSTRING(D.AcntCode,'+STR(@AcntStart)+','+STR(@AcntLen)+')=A.AcntCode and A.LanguageID='+str(@LanguageID) +' and A.PartNumber='+str(@AcntPart )+'
	Left Join acc.tblAcntDtl A1 ON SUBSTRING(D.AcntCode,'+STR(@AcntStart1)+','+STR(@AcntLen1)+')=A1.AcntCode and A1.LanguageID='+str(@LanguageID) +'  and A1.PartNumber=1
	Left Join acc.tblAcntDtl A2 ON SUBSTRING(D.AcntCode,'+STR(@AcntStart2)+','+STR(@AcntLen2)+')=A2.AcntCode and A2.LanguageID='+str(@LanguageID) +'  and A2.PartNumber=2
	Left Join acc.tblAcntDtl A3 ON SUBSTRING(D.AcntCode,'+STR(@AcntStart3)+','+STR(@AcntLen3)+')=A3.AcntCode and A3.LanguageID='+str(@LanguageID) +'  and A3.PartNumber=3
	Left Join acc.tblAcntDtl A4 ON SUBSTRING(D.AcntCode,'+STR(@AcntStart4)+','+STR(@AcntLen4)+')=A4.AcntCode and A4.LanguageID='+str(@LanguageID) +'  and A4.PartNumber=4
	Left Join inv.tblStoresDtl S ON D.StoreID=S.StoreID and S.LanguageID='+STR(@LanguageID)+'
	Left Join pub.tblProcess P ON H.ProcessID=P.ProcessID and H.ProcessNo=P.ProcessNo 
	Left Join inv.tblGoods	  G1 ON SUBSTRING(D.GoodsID,'+STR(@GoodsStart)+','+STR(@GoodsLen)+')=G1.GoodsID and G1.PartNumber='+STR(@GoodsPart )+'
	Left Join inv.tblGoodsDtl G ON SUBSTRING(D.GoodsID,'+STR(@GoodsStart)+','+STR(@GoodsLen)+')=G.GoodsID and G.LanguageID='+STR(@LanguageID)+' and G.PartNumber='+STR(@GoodsPart )+'
	Left Join inv.tblSubUnitsDtl SU ON G1.GoodsID=SU.GoodsID  and SU.ShowInInvoice=1
	Left Join inv.tblUnitsDtl U1 ON G1.UnitID=U1.UnitID  and U1.LanguageID='+STR(@LanguageID)+'
	Left Join inv.tblUnitsDtl U2 ON D.SubUnitID=U2.UnitID  and U2.LanguageID='+STR(@LanguageID)+'
	Left Join inv.tblUnitsDtl U3 ON SU.SubUnitID=U3.UnitID  and U3.LanguageID='+STR(@LanguageID)+'
	Left Join inv.tblBatch B ON D.BatchNo=B.BatchNo '	
		Set @StrSelect2 = '
	Left Join inv.tblBatchDtl BD ON D.BatchNo=BD.BatchNo and BD.LanguageID='+STR(@LanguageID )+'
	Left Join inv.tblGoodsUserPrice GU ON D.UserPriceID=GU.ID 
	Left Join pln.tblProductionLinesDtl PL ON B.ProductionLineID=PL.ProductionLineID 
	Left Join emp.tblShiftsDtl SD ON B.ShiftID=SD.ShiftID 
	LEFT JOIN inv.tblGoodsAcntGroup GA ON GA.GoodsAcntGroupID = G1.GoodsAcntGroupID
	LEFT JOIN inv.tblGoodsAcntGroupDtl GAD ON GA.GoodsAcntGroupID = GAD.GoodsAcntGroupID AND GAD.LanguageID='+STR(@LanguageID )+'

	WHERE ('''+@StoreID+'''='''' OR D.StoreID='''+@StoreID+''') AND 
		('''+@GoodsID+'''='''' OR D.GoodsID='''+@GoodsID+''') AND 
		('''+@AcntCode+'''='''' OR D.AcntCode='''+@AcntCode+''') AND 
		('''+@BatchNo+'''='''' OR D.BatchNo='''+@BatchNo+''') AND 
		('+STR(@UserPriceID )+'=0 OR D.UserPriceID='+Str(@UserPriceID)+') AND 
		('''+@FromDate+'''='''' OR D.DocDate>='''+@FromDate+''') AND 
		('''+@ToDate+'''='''' OR D.DocDate<='''+@ToDate+''') AND 
		D.EnterKind<>0 AND 
		('+str(@UserIsAdmin)+' = ''1'' OR ( 
			(SELECT	 IsNull(COUNT(*), 0)
		 	 FROM inv.tblGoodsRng
			 WHERE	(UserID = '+STR(@UserID )+') AND (PartNumber = '+STR(@GoodsPart )+') AND (AccessAllCode=1 OR ((AllowCodeView = 1) AND
				(LEFT(ISNULL(D.GoodsID,''''), LEN(ToCode)) >= FromCode) AND 
				(LEFT(ISNULL(D.GoodsID,''''), LEN(ToCode)) <= ToCode))))>0 AND
			(SELECT	 IsNull(COUNT(*), 0)
		 	 FROM inv.tblStoresRng
			 WHERE	(UserID = '+STR(@UserID )+') AND (AccessAllCode=1 OR ((AllowCodeView = 1) AND
				(LEFT(ISNULL(D.StoreID,''''), LEN(ToCode)) >= FromCode) AND 
				(LEFT(ISNULL(D.StoreID,''''), LEN(ToCode)) <= ToCode))))>0))

  ORDER BY DocDate,VolumeRowNo'
  
	print   @StrSelect1;             
	print   @StrSelect2;             
	Set @StrSelectMain = @StrSelect1+@StrSelect2
	EXEC sp_executesql @StrSelectMain;

end
GO
