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

CREATE PROCEDURE  [sal].[SpSumSaleOrderRemainFilteringHdr2] 
	
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
			

		 SELECT distinct h.ProcessID,h.ProcessNo,h.FiscalYear,h.SerialNo
		,h.SaleTypeID,h.DocDesc,[sal].[funGetSaleTypeName](h.SaleTypeID,1)AS SaleTypeName
			
		
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
					AND OD.DocRowNo=SD1.BaseDocRowNo)-
			
			(
				SELECT isnull(SUM(SD4.GoodsQuantity),0)
			 FROM (
				SELECT SD2.ProcessID, SD2.ProcessNo, SD2.FiscalYear, 
					   SD2.SerialNo,SD2.BaseProcessID ,SD2.BaseProcessNo,SD2.BaseFiscalYear,
					   SD2.BaseSerialNo,SD2.BaseDocRowNo,RD.GoodsQuantity 
				FROM 
				(SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,isnull(SUM(GoodsQuantity),0) GoodsQuantity
				FROM inv.tblStorageDocsDtl
				WHERE ProcessID=100
				GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
				) RD
				INNER JOIN  inv.tblStorageDocsDtl SD2
				ON SD2.ProcessID = RD.BaseProcessID AND
				SD2.ProcessNo = RD.BaseProcessNo   
				AND SD2.FiscalYear=RD.BaseFiscalYear 
				AND SD2.SerialNo=RD.BaseSerialNo 
				AND SD2.DocRowNo=RD.BaseDocRowNo
				AND SD2.ProcessID = 90) SD4
			WHERE h.ProcessID = SD4.BaseProcessID AND
			h.ProcessNo = SD4.BaseProcessNo   
			AND h.FiscalYear=SD4.BaseFiscalYear 
			AND h.SerialNo=SD4.BaseSerialNo and SD4.ProcessID=90
			AND OD.DocRowNo=SD4.BaseDocRowNo
			) 
			
		)<OD.GoodsQuantity 
				
		 
		END  -- end if
		     
	IF @GetRemainSaleOrder='False'     
		BEGIN
			
		SELECT distinct h.ProcessID,h.ProcessNo,h.FiscalYear,h.SerialNo
		,h.SaleTypeID,h.DocDesc,[sal].[funGetSaleTypeName](h.SaleTypeID,1)AS SaleTypeName
			
		
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
					AND OD.DocRowNo=SD1.BaseDocRowNo) -
					
						(
				SELECT isnull(SUM(SD4.GoodsQuantity),0)
			 FROM (
				SELECT SD2.ProcessID, SD2.ProcessNo, SD2.FiscalYear, 
					   SD2.SerialNo,SD2.BaseProcessID ,SD2.BaseProcessNo,SD2.BaseFiscalYear,
					   SD2.BaseSerialNo,SD2.BaseDocRowNo,RD.GoodsQuantity 
				FROM 
				(SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,isnull(SUM(GoodsQuantity),0) GoodsQuantity
				FROM inv.tblStorageDocsDtl
				WHERE ProcessID=100
				GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo
				) RD
				INNER JOIN  inv.tblStorageDocsDtl SD2
				ON SD2.ProcessID = RD.BaseProcessID AND
				SD2.ProcessNo = RD.BaseProcessNo   
				AND SD2.FiscalYear=RD.BaseFiscalYear 
				AND SD2.SerialNo=RD.BaseSerialNo 
				AND SD2.DocRowNo=RD.BaseDocRowNo
				AND SD2.ProcessID = 90) SD4
			WHERE h.ProcessID = SD4.BaseProcessID AND
			h.ProcessNo = SD4.BaseProcessNo   
			AND h.FiscalYear=SD4.BaseFiscalYear 
			AND h.SerialNo=SD4.BaseSerialNo and SD4.ProcessID=90
			AND OD.DocRowNo=SD4.BaseDocRowNo
			) 
			
			
			
	)<OD.GoodsQuantity 
					
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
