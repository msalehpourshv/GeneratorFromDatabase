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

CREATE  PROCEDURE  [sal].[SpSumSaleOrderRemainFilteringDtl] 
	
	@AcntCode	Varchar(20),
	@FiscalYear	Smallint,
	@ProcessNo	TINYINT,
	@SerialNo	INT
		
WITH ENCRYPTION
AS

BEGIN

 SELECT 
 OD.GoodsID,OD.SubUnitID,OD.GoodsQuantity,OD.GoodsPrice,
 OD.FiscalYear,OD.SerialNo,OD.DocRowNo,
 
 ISNULL((OD.GoodsQuantity -(SELECT isnull(SUM(SD.GoodsQuantity),0)
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
	 h.SerialNo=@SerialNo AND
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
      

END
GO
