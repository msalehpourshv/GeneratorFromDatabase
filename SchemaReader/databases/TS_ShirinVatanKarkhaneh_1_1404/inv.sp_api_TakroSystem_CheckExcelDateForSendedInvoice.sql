USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1402/02/19
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE inv.sp_api_TakroSystem_CheckExcelDateForSendedInvoice
@TaxID           	AS NVARCHAR(100),
@Date            	AS NVARCHAR(100),
@Amount          	AS NVARCHAR(100),
@Ins    			AS NVARCHAR(100)

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @TPEdited	 	 NVARCHAR(50) ='0'
	DECLARE @TPCanceled  	 NVARCHAR(50) ='0'
	DECLARE @SerialNo    	 NVARCHAR(50) ='0'
	DECLARE @ProcessNo   	 NVARCHAR(50) ='0'
	DECLARE @FiscalYear  	 NVARCHAR(50) ='0'
	DECLARE @ProcessID	 	 NVARCHAR(50) ='0'
	DECLARE @Count   	 	 NVARCHAR(50) ='0'
	DECLARE @StrAcntQuery    NVARCHAR(MAX)=''
	DECLARE @StrQuery        NVARCHAR(MAX)
	DECLARE @StrTempQuery        NVARCHAR(MAX)
	DECLARE @StrBaseQuery        NVARCHAR(MAX)
	DECLARE @StrSaleQuery        NVARCHAR(MAX)
	DECLARE @StrRetSaleQuery     NVARCHAR(MAX)
	DECLARE @DBName  	 	 NVARCHAR(MAX)= DB_NAME()
	DECLARE @DBName0000  	 NVARCHAR(MAX)= SUBSTRING (@DBName ,1,LEN(@DBName )-4) +'0000'
	DECLARE @StrDateQuery    NVARCHAR(MAX)=' AND VchDate= '''+@Date +''''
	DECLARE @StrAmountQuery    NVARCHAR(MAX)=' '
	DECLARE @ParmDefinition  NVARCHAR(MAX)
	DECLARE @sql	         NVARCHAR(MAX)

BEGIN TRY

	IF (@Ins=N'اصلاحی')
	BEGIN
		SET @TPEdited=1 
		SET @StrDateQuery=' AND (VchDate= '''+@Date +''' OR TPEditedDate= '''+@Date+''')'
	END 

	ELSE IF (@Ins=N'ابطالی')
	BEGIN
		SET @TPEdited=1
		SET @TPCanceled=1
		SET @StrDateQuery=' AND (VchDate= '''+@Date +''' OR TPCanceledDate= '''+@Date+''')'
	END 
	
	SET @FiscalYear = 0		
	SET @ParmDefinition = N'@FiscalOut as int OUTPUT';
	SET @sql = 'SELECT @FiscalOut=FiscalYear
				 FROM  '+ @DBName0000 +' .pub.tblTPHistories 
				 WHERE  TaxID= '''+ @TaxID+'''
				 ORDER BY SendDateTime'
	Exec sp_executesql @sql,@ParmDefinition, @FiscalOut = @FiscalYear OUTPUT;
	
	if(@FiscalYear<>0)
		SET @DBName=SUBSTRING (@DBName ,1,LEN(@DBName )-4) +@FiscalYear



	SET  @StrTempQuery='SELECT ISNULL(Status ,0) AS Status , SendDateTime,
	CAST (SerialNo AS  NVARCHAR(100)) AS SerialNo, CAST (ISNULL(FiscalYear,'''') AS INT) AS FiscalYear, 
	CAST ( ProcessNo AS  NVARCHAR(100))  AS  ProcessNo ,CAST (ProcessID AS INT)  AS ProcessID ,
	CAST ( TPEdited AS bit )AS TPEdited,CAST (TPCanceled AS bit )AS TPCanceled,
	CAST  ( BaseFiscalYear AS INT ) AS BaseFiscalYear ,CAST  ( BaseProcessID AS INT ) AS BaseProcessID,
	CAST  ( BaseProcessNo AS INT ) AS BaseProcessNo,CAST  ( BaseSerialNo AS bigint ) AS BaseSerialNo,
	TaxSerialNo, ReferenceNumber AS ReferenceNumber, BaseTaxID, TaxID
	into  #TempTax
	FROM  '+ @DBName0000 +' .pub.tblTPHistories
	WHERE  TaxID= '''+ @TaxID+'''
	ORDER BY SendDateTime desc'

	SET @StrBaseQuery=' 
						IF (SELECT COUNT(*) FROM '+ @DBName0000 +' .pub.tblTPHistories WHERE BaseTaxID='''+@TaxID +''')>0 AND 
						   (SELECT COUNT(*) from #TempTax WHERE Status=3)>0
						BEGIN
							SELECT TOP 1 Status,CAST (HIS.SerialNo AS  NVARCHAR(100)) AS SerialNo, CAST (HIS.FiscalYear AS INT) AS FiscalYear, 
						 		CAST (HIS.ProcessNo AS  NVARCHAR(100))  AS  ProcessNo ,CAST (HIS.ProcessID AS INT)  AS ProcessID ,cast(0 as float) as Amount,
						 		CAST (HIS.TPEdited AS bit )AS TPEdited,CAST (HIS.TPCanceled AS bit )AS TPCanceled,
						 		CAST  (HIS.BaseFiscalYear AS INT ) AS BaseFiscalYear ,CAST  (HIS.BaseProcessID AS INT ) AS BaseProcessID,
						 		CAST  (HIS.BaseProcessNo AS INT ) AS BaseProcessNo,CAST  (HIS.BaseSerialNo AS bigint ) AS BaseSerialNo,
						 		HIS.TaxSerialNo,HIS.ReferenceNumber AS ReferenceNumber,HIS.BaseTaxID,HIS.TaxID,
						 		CAST (ISNULL('''','''')AS  NVARCHAR(100))  AS ZipCode,
						 		CAST (ISNULL('''','''')AS  NVARCHAR(100)) AS NationalNumber,
						 		CAST (ISNULL('''','''')AS  NVARCHAR(100)) AS EconomicalCode,
						 		CAST (ISNULL(HIS.SerialNo,0) AS INT) AS hdrSerialNo
							FROM #TempTax HIS
							where TPEdited='+@TPEdited +'And TPCanceled='+@TPCanceled+'
							ORDER BY SendDateTime desc
						END'

	SET  @StrSaleQuery='
						 ELSE 
						 BEGIN
						 	IF(SELECT COUNT(*) FROM #TempTax )>0 AND
						 	(SELECT COUNT(*) FROM #TempTax  WHERE ProcessID=90)>0
						 	BEGIN
						 		SELECT TOP 1
						 		Status,CAST (HIS.SerialNo AS  NVARCHAR(100)) AS SerialNo, CAST (HIS.FiscalYear AS INT) AS FiscalYear, 
						 		CAST (HIS.ProcessNo AS  NVARCHAR(100))  AS  ProcessNo ,CAST (HIS.ProcessID AS INT)  AS ProcessID ,cast(Amount as float) as Amount,
						 		CAST (HIS.TPEdited AS bit )AS TPEdited,CAST (HIS.TPCanceled AS bit )AS TPCanceled,
						 		CAST  (HIS.BaseFiscalYear AS INT ) AS BaseFiscalYear ,CAST  (HIS.BaseProcessID AS INT ) AS BaseProcessID,
						 		CAST  (HIS.BaseProcessNo AS INT ) AS BaseProcessNo,CAST  (HIS.BaseSerialNo AS bigint ) AS BaseSerialNo,
						 		HIS.TaxSerialNo,HIS.ReferenceNumber AS ReferenceNumber,HIS.BaseTaxID,HIS.TaxID,
						 		CAST (ISNULL(HDR.ZipCode,'''')AS  NVARCHAR(100))  AS ZipCode,
						 		CAST (ISNULL(HDR.NationalID,'''')AS  NVARCHAR(100)) AS NationalNumber,
						 		CAST (ISNULL(HDR.EconomicalCode,'''')AS  NVARCHAR(100)) AS EconomicalCode,
						 		CAST (ISNULL(HDR.SerialNo,0) AS INT) AS hdrSerialNo
						 		FROM '+ @DBName0000+' . pub.tblTPHistories HIS
						 		LEFT JOIN  '+ @DBName+' .inv.tblStorageDocsHdr  HDR ON
						 		HIS.SerialNo	=HDR.SerialNo	 AND
						 		HIS.FiscalYear	=HDR.FiscalYear	 AND
						 		HIS.ProcessNo 	=HDR.ProcessNo 	 AND
						 		HIS.ProcessID	=HDR.ProcessID	 AND
						 		Amount = '+@Amount+ @StrDateQuery+'
						 		WHERE HIS.TPEdited='+ @TPEdited +' AND  HIS.TPCanceled='+ @TPCanceled +' AND HIS.TaxID='''+ @TaxID+'''	
						 		ORDER BY HIS.SendDateTime desc
							END'

	set @StrRetSaleQuery ='
							ELSE IF (SELECT COUNT(*)  FROM  #TempTax )>0 AND
						    (SELECT COUNT(*) FROM #TempTax  WHERE ProcessID=100)>0
							BEGIN 
								
								SELECT TOP 1
								Status,CAST (HIS.SerialNo AS  NVARCHAR(100)) AS SerialNo, CAST (HIS.FiscalYear AS INT) AS FiscalYear, 
								CAST (HIS.ProcessNo AS  NVARCHAR(100))  AS  ProcessNo ,CAST (HIS.ProcessID AS INT)  AS ProcessID ,cast(Amount as float) as Amount,
								CAST (HIS.TPEdited AS bit )AS TPEdited,CAST (HIS.TPCanceled AS bit )AS TPCanceled,
								CAST  (HIS.BaseFiscalYear AS INT ) AS BaseFiscalYear ,CAST  (HIS.BaseProcessID AS INT ) AS BaseProcessID,
								CAST  (HIS.BaseProcessNo AS INT ) AS BaseProcessNo,CAST  (HIS.BaseSerialNo AS bigint ) AS BaseSerialNo,
								HIS.TaxSerialNo,HIS.ReferenceNumber AS ReferenceNumber,HIS.BaseTaxID,HIS.TaxID,
								CAST (ISNULL(HDR.ZipCode,'''')AS  NVARCHAR(100))  AS ZipCode,
								CAST (ISNULL(HDR.NationalID,'''')AS  NVARCHAR(100)) AS NationalNumber,
								CAST (ISNULL(HDR.EconomicalCode,'''')AS  NVARCHAR(100)) AS EconomicalCode,
								CAST (ISNULL(HDR.SerialNo,0) AS INT) AS hdrSerialNo
								FROM '+ @DBName0000+' . pub.tblTPHistories HIS
								LEFT JOIN  '+ @DBName+' .inv.tblStorageDocsHdr  HDR ON
								HIS.SerialNo	=HDR.SerialNo	 AND
								HIS.FiscalYear	=HDR.FiscalYear	 AND
								HIS.ProcessNo 	=HDR.ProcessNo 	 AND
								HIS.ProcessID	=HDR.ProcessID
								'+ @StrDateQuery+'
								WHERE  HIS.TaxID='''+ @TaxID+'''	
								ORDER BY HIS.SendDateTime desc
							END'

	SET @StrQuery=@StrTempQuery+ @StrBaseQuery +@StrSaleQuery+@StrRetSaleQuery+'	
						   ELSE IF (SELECT COUNT(*) FROM #TempTax )=0 
					       BEGIN 						
								SELECT
								CAST  (0 AS INT ) AS BaseFiscalYear,CAST  (0 AS INT ) AS BaseProcessID,
								CAST  (0 AS INT ) AS BaseProcessNo, CAST  (0 AS bigint ) AS BaseSerialNo,cast(0 as float) as Amount,
								0 AS  Status, CAST (0 AS  NVARCHAR(100)) AS SerialNo, CAST (0 AS INT) AS FiscalYear, CAST (0 AS  NVARCHAR(100))  AS  ProcessNo ,
								CAST (0 AS INT)  AS ProcessID , CAST (0 AS bit )AS TPEdited,
								CAST (0 AS bit )AS TPEdited,CAST ('''' AS  NVARCHAR(100)) AS TaxSerialNo,CAST ('''' AS  NVARCHAR(100)) AS  ReferenceNumber,
								CAST ('''' AS  NVARCHAR(100)) AS BaseTaxID,
								CAST ('''' AS  NVARCHAR(100)) AS TaxID,
								CAST ('''' AS  NVARCHAR(100))  AS ZipCode,
								CAST ('''' AS  NVARCHAR(100)) AS NationalNumber,
								CAST ('''' AS  NVARCHAR(100)) AS EconomicalCode,
								CAST (0 AS bit )AS TPCanceled,
								CAST (0 AS int) AS hdrSerialNo
					     END
					END'

		PRINT @StrQuery
		EXEC sp_executesql @StrQuery

END TRY

BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END
GO
