USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [phr].[FunGetNotDeliveryRemain]
(
	@GoodsID VarChar(20), 
	@DocDate Char(10) ,
	@ExpDate CHAR(10),
	@StoreID VARCHAR(20),
	@DateNow CHAR(10)
	
)
	RETURNS FLOAT
WITH ENCRYPTION
AS

Begin -- ====================================================
	
	Declare @StrResult AS FLOAT
	Declare @StrResult2 AS FLOAT
	Declare @Day AS FLOAT
	
	set @StrResult = 0
	set @Day = 0

	select @Day=SettingValue 
	from pub.tblSettings 
	where SettingKey='PhrPharmacyTimeOut'
	
	IF @ExpDate=''
	BEGIN
		
		SELECT  @StrResult=isnull(SUM(RD.Qty),0)
			FROM  phr.tblReciptionDtl RD
			INNER JOIN phr.tblReciptionHdr RH
				ON RH.ProcessID = RD.ProcessID
				 AND RH.ProcessNo = RD.ProcessNo AND
				  RH.FiscalYear = RD.FiscalYear AND RH.SerialNo = RD.SerialNo
				  LEFT JOIN phr.tblCashBoxDtl CD
				  ON RD.FiscalYear=CD.ReciptionFiscalYear
				  AND  RD.SerialNo =CD.ReciptionSerialNo 
		WHERE RD.GoodsID=@GoodsID AND 
		(CD.DeliveryToCustomer IS NULL OR CD.DeliveryToCustomer=0)
		 AND pub.funFarsiDateAddDays('Day',RH.DocDate,@Day) >= @DateNow
		AND RH.DocDate <=@DocDate AND RH.StoreID=@StoreID  AND  RH.Deleted =0
			AND  (SELECT COUNT(*) from inv.tblStorageDocsDtl 
	            where BaseProcessID=RH.ProcessID And 
	            BaseSerialNo = RH.SerialNo And  
				BaseFiscalYear=RH.FiscalYear )=0
				and RD.IsSimilar=0


SELECT  @StrResult2=isnull(SUM(RD.SimilarQty),0)
			FROM  phr.tblReciptionDtl RD
			INNER JOIN phr.tblReciptionHdr RH
				ON RH.ProcessID = RD.ProcessID
				 AND RH.ProcessNo = RD.ProcessNo AND
				  RH.FiscalYear = RD.FiscalYear AND RH.SerialNo = RD.SerialNo
				  LEFT JOIN phr.tblCashBoxDtl CD
				  ON RD.FiscalYear=CD.ReciptionFiscalYear
				  AND  RD.SerialNo =CD.ReciptionSerialNo 
		WHERE RD.SimilarGoodsID=@GoodsID AND 
		(CD.DeliveryToCustomer IS NULL OR CD.DeliveryToCustomer=0)
		 AND pub.funFarsiDateAddDays('Day',RH.DocDate,@Day) >= @DateNow
		AND RH.DocDate <=@DocDate AND RH.StoreID=@StoreID  AND  RH.Deleted =0
			AND  (SELECT COUNT(*) from inv.tblStorageDocsDtl 
	            where BaseProcessID=RH.ProcessID And 
	            BaseSerialNo = RH.SerialNo And  
				BaseFiscalYear=RH.FiscalYear )=0
				and RD.IsSimilar=1


	END
	
	IF @ExpDate <>''
	BEGIN
		
		SELECT  @StrResult=isnull(SUM(RD.Qty),0)
			FROM  phr.tblReciptionDtl RD
			INNER JOIN phr.tblReciptionHdr RH
				ON RH.ProcessID = RD.ProcessID
				 AND RH.ProcessNo = RD.ProcessNo AND
				  RH.FiscalYear = RD.FiscalYear AND RH.SerialNo = RD.SerialNo
				  LEFT JOIN phr.tblCashBoxDtl CD
				  ON RD.FiscalYear=CD.ReciptionFiscalYear
				  AND  RD.SerialNo =CD.ReciptionSerialNo 
		WHERE RD.GoodsID=@GoodsID AND 
		(CD.DeliveryToCustomer IS NULL OR CD.DeliveryToCustomer=0)
		 AND pub.funFarsiDateAddDays('Day',RH.DocDate,@Day) >= @DateNow
		AND RH.DocDate <=@DocDate AND RD.ExpDate=@ExpDate AND RH.StoreID=@StoreID AND  RH.Deleted =0
			AND  (SELECT COUNT(*) from inv.tblStorageDocsDtl 
	            where BaseProcessID=RH.ProcessID And 
	            BaseSerialNo = RH.SerialNo And  
				BaseFiscalYear=RH.FiscalYear )=0
				and RD.IsSimilar=0

SELECT  @StrResult2=isnull(SUM(RD.SimilarQty),0)
			FROM  phr.tblReciptionDtl RD
			INNER JOIN phr.tblReciptionHdr RH
				ON RH.ProcessID = RD.ProcessID
				 AND RH.ProcessNo = RD.ProcessNo AND
				  RH.FiscalYear = RD.FiscalYear AND RH.SerialNo = RD.SerialNo
				  LEFT JOIN phr.tblCashBoxDtl CD
				  ON RD.FiscalYear=CD.ReciptionFiscalYear
				  AND  RD.SerialNo =CD.ReciptionSerialNo 
		WHERE RD.SimilarGoodsID=@GoodsID AND 
		(CD.DeliveryToCustomer IS NULL OR CD.DeliveryToCustomer=0)
		 AND pub.funFarsiDateAddDays('Day',RH.DocDate,@Day) >= @DateNow
		AND RH.DocDate <=@DocDate AND RD.ExpDate=@ExpDate AND RH.StoreID=@StoreID AND  RH.Deleted =0
			AND  (SELECT COUNT(*) from inv.tblStorageDocsDtl 
	            where BaseProcessID=RH.ProcessID And 
	            BaseSerialNo = RH.SerialNo And  
				BaseFiscalYear=RH.FiscalYear )=0
				and RD.IsSimilar=1
				

	END

	Return @StrResult+@StrResult2

END -- ======================================================
GO
