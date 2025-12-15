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
Create PROCEDURE [inv].[spOurTrustInSale_Ret]
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
	WHERE ProcessID=135 AND
		  BaseDistributionProcessID=@ProcessID AND
		  BaseDistributionProcessNo=@ProcessNo AND  
		  BaseDistributionFiscalYear=@FiscalYear AND  
		  BaseDistributionSerialNo=@SerialNo   
		  
	IF 	@OurTrustSerialNo >0
	
		DELETE FROM inv.tblStorageDocsHdr
		WHERE ProcessID=135 AND
			  BaseDistributionProcessID=@ProcessID AND
			  BaseDistributionProcessNo=@ProcessNo AND  
			  BaseDistributionFiscalYear=@FiscalYear AND  
			  BaseDistributionSerialNo=@SerialNo 
	ELSE
		SELECT @OurTrustSerialNo = ISNULL(MAX(SerialNo),0)+1 
		FROM inv.tblStorageDocsHdr
		WHERE ProcessID=135 AND
		      ProcessNo=1 AND  
		      FiscalYear=@FiscalYear 
		      
	Declare  @BaseSaleProcessID as integer
	Declare  @BaseSaleProcessNo as integer
	Declare  @BaseSaleFiscalYear as integer
	Declare  @BaseSaleSerialNo as integer
	Declare  @BaseRowNo as integer
	Declare  @RowNo as integer
	SEt @BaseSaleProcessID = 0	  
	SEt @BaseSaleProcessNo = 0	  
	SEt @BaseSaleFiscalYear = 0	  
	SEt @BaseSaleSerialNo = 0	  
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
		BEGIN
			SELECT @BaseSaleProcessID=BaseProcessID,
			       @BaseSaleProcessNo=BaseProcessNo,
			       @BaseSaleFiscalYear=BaseFiscalYear,
			       @BaseSaleSerialNo=BaseSerialNo
			FROM inv.tblStorageDocsHdr
			WHERE ProcessID=@ProcessID AND
				  ProcessNo=@ProcessNo AND  
				  FiscalYear=@FiscalYear AND  
				  SerialNo=@SerialNo
				  
			IF 	@BaseSaleProcessID = 90
				SELECT @BaseSaleProcessID=ProcessID,
					   @BaseSaleProcessNo=ProcessNo,
					   @BaseSaleFiscalYear=FiscalYear,
					   @BaseSaleSerialNo=SerialNo   
				FROM inv.tblStorageDocsHdr
				WHERE ProcessID = 130 
				  AND BaseProcessID=@BaseSaleProcessID AND
					  BaseProcessNo=@BaseSaleProcessNo AND  
					  BaseFiscalYear=@BaseSaleFiscalYear AND  
					  BaseSerialNo=@BaseSaleSerialNo 	
			
			INSERT INTO inv.tblStorageDocsHdr
			(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate, StoreID, AcntCode, BaseDocType, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, DocDesc, RecID, SessionNo,BaseDistributionProcessID,BaseDistributionProcessNo,BaseDistributionFiscalYear,BaseDistributionSerialNo)        		    
			SELECT 135,1,@FiscalYear,@OurTrustSerialNo,1,DocDate,StoreID,AcntCode,@BaseSaleProcessID,@BaseSaleProcessID,@BaseSaleProcessNo,@BaseSaleFiscalYear,@BaseSaleSerialNo,'امانی از برگه فروش' + LTRIM(str(SerialNo)),0,SessionNo,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo
			FROM inv.tblStorageDocsHdr
			WHERE ProcessID=@ProcessID AND
				  ProcessNo=@ProcessNo AND  
				  FiscalYear=@FiscalYear AND  
				  SerialNo=@SerialNo 
		END		  
				  
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
		SELECT 135,1,@FiscalYear,@OurTrustSerialNo,@RowNo,@RowNo,1,DocDate,StoreID,1,-1,AcntCode,
		       GoodsID,SubUnitID, SubUnitQuantity, GoodsQuantity,@BaseSaleProcessID,@BaseSaleProcessNo,@BaseSaleFiscalYear,@BaseSaleSerialNo,DocRowNo,@BaseSaleProcessID
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
