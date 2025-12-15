USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 97/10/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [sal].[funGetGoodsRemainMinesReserved]
(	
	@GoodsID		Varchar(20),
	@StoreID		Varchar(20),
	@DocDate		Char(10),
	@ProcessID		int=null,
	@ProcessNo		tinyint=null,
	@FiscalYear		smallint=null,
	@SerialNo		int=null

)
RETURNS decimal(38,5)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Sal_StoreDtl Bit
	SET @Sal_StoreDtl = ISNULL((Select SettingValue From pub.tblSettings
								Where SettingKey = 'Sal_StoreDtl'), 'False')
	-- ======
	IF @FiscalYear IS NULL OR @FiscalYear = 0
		SET @FiscalYear =  RIGHT(db_name(),4)
		
	DECLARE @QtyRemain Float
	DECLARE @GetRemainSaleOrder AS  Nvarchar(5);

	SET @QtyRemain =0
	SET @GetRemainSaleOrder = 'False'

	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	IF @DocDate = '' OR @GoodsID = ''
	BEGIN 
		RETURN 0
	END

 -- 	-- ======
	IF @GetRemainSaleOrder = 'True'
		BEGIN
			SELECT @QtyRemain = ISNULL(SUM(CASE WHEN d.GoodsQuantity -  ISNULL(SO_R.GoodsQuantity,0) - ISNULL(SD.GoodsQuantity,0) > 0 
			                                    THEN d.GoodsQuantity -  ISNULL(SO_R.GoodsQuantity,0) - ISNULL(SD.GoodsQuantity,0) 
			                                    ELSE 0 END),0) 
			FROM sal.tblSaleOrderDtl d
			INNER JOIN sal.tblSaleOrderHdr h
			on d.ProcessID=h.ProcessID AND
			   d.ProcessNo=h.ProcessNo AND 
			   d.FiscalYear=h.FiscalYear AND 
			   d.SerialNo=h.SerialNo 
			LEFT JOIN (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID,SUM(GoodsQuantity) GoodsQuantity 
					   FROM inv.tblStorageDocsDtl
					   where BaseProcessID = 180
					   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID) SD
			ON SD.BaseProcessID = h.ProcessID AND
			   SD.BaseProcessNo=h.ProcessNo AND 
			   SD.BaseFiscalYear=h.FiscalYear AND 
			   SD.BaseSerialNo=h.SerialNo AND 
			   SD.BaseDocRowNo=d.DocRowNo AND  
			   SD.GoodsID=d.GoodsID   
			LEFT JOIN (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID,SUM(GoodsQuantity) GoodsQuantity 
					   FROM sal.tblSaleOrderDtl
					   where BaseProcessID = 180
					   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID) SO_R
			ON SO_R.BaseProcessID = h.ProcessID AND
			   SO_R.BaseProcessNo=h.ProcessNo AND 
			   SO_R.BaseFiscalYear=h.FiscalYear AND 
			   SO_R.BaseSerialNo=h.SerialNo AND 
			   SO_R.BaseDocRowNo=d.DocRowNo AND  
			   SO_R.GoodsID=d.GoodsID   
			WHERE h.ProcessID = 180 AND
				  h.DocDate <= @DocDate AND h.Reserved <>0 AND
				  h.FiscalYear= @FiscalYear AND
				  d.GoodsID = @GoodsID AND (h.StoreID = '' OR @StoreID IS NULL OR (h.StoreID = @StoreID)) AND 
				  NOT(
					  h.ProcessID= @ProcessID AND 
					  h.ProcessNo= @ProcessNo AND 
					  h.FiscalYear= @FiscalYear AND 
					  h.SerialNo= @SerialNo 
					  )
			  					
		END
	ELSE
		BEGIN

  			-- ======
			SELECT @QtyRemain = ISNULL(SUM(S.GoodsQuantity  -  ISNULL(SO_R.GoodsQuantity,0)),0)
			FROM sal.tblSaleOrderDtl S INNER JOIN
			(
				SELECT ProcessID,ProcessNo,FiscalYear,SerialNo FROM sal.tblSaleOrderDtl 
				WHERE ProcessID=180  
				EXCEPT
				SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo FROM inv.tblStorageDocsDtl 
				WHERE BaseProcessID=180 AND ProcessID=90  
			) A
			ON A.ProcessID=S.ProcessID AND A.ProcessNo=S.ProcessNo AND A.FiscalYear=S.FiscalYear AND 
			   A.SerialNo=S.SerialNo
			INNER JOIN sal.tblSaleOrderHdr h
			on S.ProcessID=h.ProcessID AND
			   S.ProcessNo=h.ProcessNo AND 
			   S.FiscalYear=h.FiscalYear AND 
			   S.SerialNo=h.SerialNo 
			LEFT JOIN (SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID,SUM(GoodsQuantity) GoodsQuantity 
					   FROM sal.tblSaleOrderDtl
					   where BaseProcessID = 180
					   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID) SO_R
			ON SO_R.BaseProcessID = h.ProcessID AND
			   SO_R.BaseProcessNo=h.ProcessNo AND 
			   SO_R.BaseFiscalYear=h.FiscalYear AND 
			   SO_R.BaseSerialNo=h.SerialNo AND 
			   SO_R.BaseDocRowNo=S.DocRowNo AND  
			   SO_R.GoodsID=S.GoodsID   
			WHERE S.ProcessID = 180 AND h.Reserved <> 0 AND
				  h.DocDate <= @DocDate AND 
				  S.FiscalYear= @FiscalYear AND
				  S.GoodsID = @GoodsID AND (h.StoreID = '' OR @StoreID IS NULL OR (h.StoreID = @StoreID)) AND 
				  NOT(
					  h.ProcessID= @ProcessID AND 
					  h.ProcessNo= @ProcessNo AND 
					  h.FiscalYear= @FiscalYear AND 
					  h.SerialNo= @SerialNo 
					  )
		END

	IF @ProcessID <>90 AND @ProcessID <>180
		SELECT @QtyRemain=  ISNULL(SUM(GoodsQuantity * EnterKind),0) - @QtyRemain
		FROM inv.tblStorageDocsDtl
		WHERE (StoreID = @StoreID) AND GoodsID = @GoodsID AND  FiscalYear =@FiscalYear


	RETURN @QtyRemain 

END
GO
