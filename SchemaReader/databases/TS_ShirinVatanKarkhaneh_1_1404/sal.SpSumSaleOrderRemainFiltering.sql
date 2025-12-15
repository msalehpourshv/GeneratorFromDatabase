USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\ Reza Nogrepasand
-- Create date   : 1392/06/31
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
CREATE PROCEDURE  [sal].[SpSumSaleOrderRemainFiltering] 
	
	@AcntCode	Varchar(20),
	@DocDate	Char(10),
	@FiscalYear	Smallint,
	@ProcessNo	tinyint
		
WITH ENCRYPTION
AS

BEGIN

	DECLARE @GetRemainSaleOrder AS BIT
	SET @GetRemainSaleOrder ='True'

		SELECT @GetRemainSaleOrder=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'GetRemainSaleOrder'

  IF @GetRemainSaleOrder='True'
	
	BEGIN
		
	 SELECT h.ProcessID,h.ProcessNo,h.FiscalYear,h.SerialNo
	 ,OD.GoodsID,OD.GoodsQuantity,OD.GoodsPrice,OD.SaleTypeID,OD.DocRowNo,OD.SubUnitID
	 ,h.DocDesc,[sal].[funGetSaleTypeName](OD.SaleTypeID,1)AS SaleTypeName
		
		,ISNULL((OD.GoodsQuantity -(SELECT isnull(SUM(SD.GoodsQuantity),0)
		 FROM inv.tblStorageDocsDtl SD 
		  WHERE h.ProcessID = SD.BaseProcessID AND
		   h.ProcessNo = SD.BaseProcessNo   
		   AND h.FiscalYear=SD.BaseFiscalYear 
		   AND h.SerialNo=SD.BaseSerialNo and SD.ProcessID=90
			AND OD.DocRowNo=SD.BaseDocRowNo)- 
        	
		(SELECT isnull(SUM(SD1.GoodsQuantity),0)
		 FROM sal.tblSaleOrderDtl SD1 
		  WHERE h.ProcessID = SD1.BaseProcessID AND
		   h.ProcessNo = SD1.BaseProcessNo   
		   AND h.FiscalYear=SD1.BaseFiscalYear 
		   AND h.SerialNo=SD1.BaseSerialNo and SD1.ProcessID=185
			AND OD.DocRowNo=SD1.BaseDocRowNo)
        
			),OD.GoodsQuantity) AS dif
        
	 FROM sal.tblSaleOrderHdr h 
	 INNER JOIN sal.tblSaleOrderDtl OD  
	 ON  h.ProcessID=OD.ProcessID and 
	 h.ProcessNo=OD.ProcessNo and h.FiscalYear=OD.FiscalYear 
	 and h.SerialNo=OD.SerialNo  
  
   WHERE h.ProcessID = 180 AND
	 h.DocDate<=@DocDate AND
     h.ProcessNo =@ProcessNo AND h.AcntCode=@AcntCode	
	  AND 
		(
    		(SELECT  isnull(sum(SD.GoodsQuantity),0)
		 FROM inv.tblStorageDocsDtl SD 
		  WHERE h.ProcessID = SD.BaseProcessID AND
		   h.ProcessNo = SD.BaseProcessNo   
		   AND h.FiscalYear=SD.BaseFiscalYear 
		   AND h.SerialNo=SD.BaseSerialNo and SD.ProcessID=90
			AND OD.DocRowNo=SD.BaseDocRowNo) + 
        	
			(SELECT isnull(SUM(SD1.GoodsQuantity),0)
			 FROM sal.tblSaleOrderDtl SD1 
			  WHERE h.ProcessID = SD1.BaseProcessID AND
			   h.ProcessNo = SD1.BaseProcessNo   
			   AND h.FiscalYear=SD1.BaseFiscalYear 
			   AND h.SerialNo=SD1.BaseSerialNo and SD1.ProcessID=185
				AND OD.DocRowNo=SD1.BaseDocRowNo))<OD.GoodsQuantity 
	END -- end if
	
	IF @GetRemainSaleOrder='False'
	
	BEGIN
	
	SELECT h.ProcessID,h.ProcessNo,h.FiscalYear,h.SerialNo
	 ,OD.GoodsID,OD.GoodsQuantity,OD.GoodsPrice,OD.SaleTypeID,OD.DocRowNo,OD.SubUnitID
	 ,h.DocDesc,[sal].[funGetSaleTypeName](OD.SaleTypeID,1)AS SaleTypeName
		
		,ISNULL((OD.GoodsQuantity -(SELECT isnull(SUM(SD.GoodsQuantity),0)
		 FROM inv.tblStorageDocsDtl SD 
		  WHERE h.ProcessID = SD.BaseProcessID AND
		   h.ProcessNo = SD.BaseProcessNo   
		   AND h.FiscalYear=SD.BaseFiscalYear 
		   AND h.SerialNo=SD.BaseSerialNo and SD.ProcessID=90
			AND OD.DocRowNo=SD.BaseDocRowNo)- 
        	
		(SELECT isnull(SUM(SD1.GoodsQuantity),0)
		 FROM sal.tblSaleOrderDtl SD1 
		  WHERE h.ProcessID = SD1.BaseProcessID AND
		   h.ProcessNo = SD1.BaseProcessNo   
		   AND h.FiscalYear=SD1.BaseFiscalYear 
		   AND h.SerialNo=SD1.BaseSerialNo and SD1.ProcessID=185
			AND OD.DocRowNo=SD1.BaseDocRowNo)
        
			),OD.GoodsQuantity) AS dif
        
	 FROM sal.tblSaleOrderHdr h 
	 INNER JOIN sal.tblSaleOrderDtl OD  
	 ON  h.ProcessID=OD.ProcessID and 
	 h.ProcessNo=OD.ProcessNo and h.FiscalYear=OD.FiscalYear 
	 and h.SerialNo=OD.SerialNo  
  
   WHERE h.ProcessID = 180 AND
	 h.DocDate<=@DocDate AND
     h.ProcessNo =@ProcessNo AND h.FiscalYear=@FiscalYear AND h.AcntCode=@AcntCode	
	  AND 
		(
    		(SELECT  isnull(sum(SD.GoodsQuantity),0)
		 FROM inv.tblStorageDocsDtl SD 
		  WHERE h.ProcessID = SD.BaseProcessID AND
		   h.ProcessNo = SD.BaseProcessNo   
		   AND h.FiscalYear=SD.BaseFiscalYear 
		   AND h.SerialNo=SD.BaseSerialNo and SD.ProcessID=90
			AND OD.DocRowNo=SD.BaseDocRowNo) + 
        	
			(SELECT isnull(SUM(SD1.GoodsQuantity),0)
			 FROM sal.tblSaleOrderDtl SD1 
			  WHERE h.ProcessID = SD1.BaseProcessID AND
			   h.ProcessNo = SD1.BaseProcessNo   
			   AND h.FiscalYear=SD1.BaseFiscalYear 
			   AND h.SerialNo=SD1.BaseSerialNo and SD1.ProcessID=185
				AND OD.DocRowNo=SD1.BaseDocRowNo))<OD.GoodsQuantity 
        
        AND 
        
        (SELECT COUNT(*) FROM inv.tblStorageDocsDtl SD
       WHERE OD.ProcessID = SD.BaseProcessID
			  AND OD.ProcessNo = SD.BaseProcessNo      
              AND OD.FiscalYear=SD.BaseFiscalYear  
              AND OD.SerialNo=SD.BaseSerialNo 
              AND SD.ProcessID=90)=0
    
	END -- end if

END
GO
