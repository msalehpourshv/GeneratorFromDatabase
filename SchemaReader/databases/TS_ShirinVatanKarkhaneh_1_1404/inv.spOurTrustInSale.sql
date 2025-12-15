USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 98/02/21
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[spOurTrustInSale]
	@ProcessID		  tinyint,
	@ProcessNo		  tinyint,
	@FiscalYear       SmallInt=NULL,
	@SerialNo       SmallInt=NULL
WITH ENCRYPTION
AS

BEGIN
	Declare @OurTrustSerialNo as integer
	
	set @OurTrustSerialNo = 0
	
	SELECT @OurTrustSerialNo=SerialNo  
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=130 AND
		  BaseProcessID=@ProcessID AND
		  BaseProcessNo=@ProcessNo AND  
		  BaseFiscalYear=@FiscalYear AND  
		  BaseSerialNo=@SerialNo   
		  
	IF 	@OurTrustSerialNo >0
	
		DELETE FROM inv.tblStorageDocsHdr
		WHERE ProcessID=130 AND
			  BaseProcessID=@ProcessID AND
			  BaseProcessNo=@ProcessNo AND  
			  BaseFiscalYear=@FiscalYear AND  
			  BaseSerialNo=@SerialNo  
	ELSE
		SELECT @OurTrustSerialNo = ISNULL(MAX(SerialNo),0)+1 
		FROM inv.tblStorageDocsHdr
		WHERE ProcessID=130 AND
		      ProcessNo=1 AND  
		      FiscalYear=@FiscalYear 
		      
	Declare  @BaseRowNo as integer
	Declare  @RowNo as integer
	SEt @RowNo = 0	  
	
	DECLARE	OurTrustCursor CURSOR FOR
	SELECT  RowNo
	FROM inv.tblStorageDocsDtl S
	INNER JOIN inv.tblGoods G
	ON S.GoodsID=G.GoodsID AND G.OurTrustInSale = 'True'
	WHERE ProcessID=@ProcessID AND
		  ProcessNo=@ProcessNo AND  
		  FiscalYear=@FiscalYear AND  
		  SerialNo=@SerialNo 
		  
	OPEN OurTrustCursor
	FETCH NEXT FROM OurTrustCursor INTO @BaseRowNo

	WHILE (@@Fetch_Status = 0)
	BEGIN
		SET @RowNo=@RowNo+1

		IF @RowNo = 1
			INSERT INTO inv.tblStorageDocsHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate, StoreID, AcntCode, BaseDocType, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, DocDesc, RecID, SessionNo,BaseDistributionProcessID,BaseDistributionProcessNo,BaseDistributionFiscalYear,BaseDistributionSerialNo)        		    
			SELECT 130,1,@FiscalYear,@OurTrustSerialNo,1,DocDate,StoreID,AcntCode,ProcessID,ProcessID,ProcessNo,FiscalYear,SerialNo,'امانی از برگه فروش' + LTRIM(str(SerialNo)),0,SessionNo,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo
			FROM inv.tblStorageDocsHdr
			WHERE ProcessID=@ProcessID AND
				  ProcessNo=@ProcessNo AND  
				  FiscalYear=@FiscalYear AND  
				  SerialNo=@SerialNo 
				  
		UPDATE 	inv.tblStorageDocsDtl
		SET EnterKind = 0
		WHERE ProcessID=@ProcessID AND
			  ProcessNo=@ProcessNo AND  
			  FiscalYear=@FiscalYear AND  
			  SerialNo=@SerialNo AND	  
			  RowNo=@BaseRowNo 	  

		INSERT INTO inv.tblStorageDocsDtl
			  (ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo, DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind, AcntCode, 
			   GoodsID, SubUnitID, SubUnitQuantity, GoodsQuantity, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, BaseDocType)
		SELECT 130,1,@FiscalYear,@OurTrustSerialNo,@RowNo,@RowNo,1,DocDate,StoreID,1,-1,AcntCode,
		       GoodsID,SubUnitID, SubUnitQuantity, GoodsQuantity,ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,ProcessID
	    FROM inv.tblStorageDocsDtl 
		WHERE ProcessID=@ProcessID AND
			  ProcessNo=@ProcessNo AND  
			  FiscalYear=@FiscalYear AND  
			  SerialNo=@SerialNo AND	  
			  RowNo=@BaseRowNo 
				  
		FETCH NEXT FROM OurTrustCursor INTO @BaseRowNo
	END

	CLOSE		OurTrustCursor;
	DEALLOCATE	OurTrustCursor;
			  
END
GO
