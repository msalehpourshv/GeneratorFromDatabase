USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi Sadeghi
-- Create date   : 1400/10/11
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =================================================================
CREATE PROCEDURE [prd].[SPDeleteAutoGroupProduce]
	@SNo		varchar(10) = 0

WITH ENCRYPTION
AS

BEGIN
	
   BEGIN TRY
		
	BEGIN TRAN

	DECLARE @ProcessID INT,
	        @ProcessNo INT,
	        @FiscalYear INT,
	        @SerialNo INT,
	        @BaseProcessID INT,
	        @BaseProcessNo INT,
	        @BaseFiscalYear INT,
	        @BaseSerialNo INT

	Declare	curStore CURSOR For
	select ProcessID,ProcessNo,FiscalYear,SerialNo,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
	from inv.tblStorageDocsHdr where AgreeNo='67-' + @SNo and ProcessID=80
	order by SerialNo desc
	
	Open curStore;
		
	Fetch NEXT From curStore Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo
	
	While (@@Fetch_Status = 0)
	BEGIN
				  
		DELETE from inv.tblStorageDocsHdr 
		where ProcessID=@ProcessID AND
			  ProcessNo=@ProcessNo AND
			  FiscalYear=@FiscalYear AND
			  SerialNo=@SerialNo 
			  
		DELETE FROM inv.tblStorageDocsSerials 
		where ProcessID=@ProcessID AND
			  ProcessNo=@ProcessNo AND
			  FiscalYear=@FiscalYear AND
			  SerialNo=@SerialNo 
			  

		DELETE from inv.tblStorageDocsHdr 
		where ProcessID=@BaseProcessID AND
			  ProcessNo=@BaseProcessNo AND
			  FiscalYear=@BaseFiscalYear AND
			  SerialNo=@BaseSerialNo 

			  
		Fetch NEXT From curStore Into @ProcessID,@ProcessNo,@FiscalYear,@SerialNo,@BaseProcessID,@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo
	END -- curStore
	Close curStore;
	Deallocate curStore; 

		DELETE from inv.tblStorageDocsHdr 
		where BaseProcessID=67 AND
			  BaseProcessNo=1 AND
			  BaseFiscalYear=@FiscalYear AND
			  BaseSerialNo=@SNo 

		COMMIT TRAN
	
 END TRY
	  	
	BEGIN CATCH
		Close curStore;
		Deallocate curStore; 
	    ROLLBACK TRAN
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)
		 CLOSE aa_curs  
		DEALLOCATE aa_curs 
	END CATCH
END
GO
