USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--=========== TS-QC:NOTOK ========================
--Author        : jafari
--Create date   : 99/09/16
--Viewed By	 : 
--Last Modified : 
--Description   : 
--================================================
CREATE   PROCEDURE acc.SpVch_CreatDocTranfered_SRV
  @ProcessID AS INT,
  @ProcessNo AS INT,
  @VoucherCreateMetod1 AS INT,  
  @DocFormType1    AS INT,
  @FromDate AS CHAR(10),
  @ToDate AS CHAR(10),
  @FromSerialNo AS int,
  @ToSerialNo AS INT,
  @IsTransfer AS BIT,
  @FiscalYearFilter AS INT
      
  WITH ENCRYPTION
AS

BEGIN
	
  BEGIN TRY
			
	BEGIN TRAN
	 
			
	DECLARE @VchNo int 
	DECLARE @DocStep int  
	DECLARE @VchDate varchar(10)  
	--declare @ProcessID Smallint  
	--declare @ProcessNo tinyint  
	DECLARE @FiscalYear Smallint  
	DECLARE @SerialNo int  

	DECLARE @tmpFromDocDate AS CHAR(10)
	DECLARE @tmpToDocDate AS CHAR(10)
	DECLARE @tmpFromSerialNo AS FLOAT
	DECLARE @tmpToSerialNo AS FLOAT

	IF @FromDate <> '' 
		SET @tmpFromDocDate=@FromDate
	ELSE 
		SET @tmpFromDocDate='1000/01/01'
	  
	  
	  IF @ToDate <> '' 
		SET @tmpToDocDate=@ToDate
	ELSE 
		SET @tmpToDocDate='2100/01/01'
		

	SET @tmpFromSerialNo=@FromSerialNo

	  
	   IF @ToSerialNo <> 0 
		SET @tmpToSerialNo=@ToSerialNo
	ELSE 
		SET @tmpToSerialNo=21474836
		

	DECLARE  aa_curs CURSOR FOR   
	   SELECT  VchNo,VchDate,ProcessID,ProcessNo,FiscalYear,SerialNo  
	   FROM   acc.tblServicesHdr
		WHERE 1=1 AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo
			AND DocDate >= @tmpFromDocDate AND DocDate <= @tmpToDocDate
			AND SerialNo >= @tmpFromSerialNo AND SerialNo <= @tmpToSerialNo
			AND FiscalYear=@FiscalYearFilter
	     
	OPEN aa_curs  
	  
	FETCH NEXT FROM aa_curs into @VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
	  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  
	  
	  if @IsTransfer='False' 
	  BEGIN
	  	
		  IF @VchNo>0
		  BEGIN
	  		DELETE FROM acc.tblVoucherDtl 
			WHERE SourceProcessID = @ProcessID  and 
				  SourceProcessNo = @ProcessNo  and 
				  SourceFiscalYear= @FiscalYear and 
				  SourceSerialNo  = @SerialNo

			EXEC [acc].[SpVch_CreateDoc]   
					@intVchNo			= @VchNo,  
					@intDocStep		    = 0,  
					@strVchDate			= @VchDate, 
					@strOldVchDate		= @VchDate,  
					@intSourceProcessID	= @ProcessID,  
					@intSourceProcessNo	= @ProcessNo,  
					@intSourceFiscalYear= @FiscalYear,  
					@intSourceSerialNo	= @SerialNo,  
					@strHdrTblName		= 'acc.tblServicesHdr',  
					@strVchNoFieldName	= 'VchNo',  
					@VoucherCreateMetod= @VoucherCreateMetod1 ,  
					@DocFormType        = @DocFormType1 ,  
					@SelectedUserVchNoType = 1 , 
					@intOldVchNo = @VchNo 
		  END
		  
		FETCH NEXT FROM aa_curs into @VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
		  
	  END
		  
	  
	if @IsTransfer='true' 
	  BEGIN
	  		DELETE FROM acc.tblVoucherDtl 
			WHERE SourceProcessID = @ProcessID  and 
				  SourceProcessNo = @ProcessNo  and 
				  SourceFiscalYear= @FiscalYear and 
				  SourceSerialNo  = @SerialNo

			EXEC [acc].[SpVch_CreateDoc]   
					@intVchNo			= @VchNo,  
					@intDocStep		    = 0,  
					@strVchDate			= @VchDate, 
					@strOldVchDate		= @VchDate,  
					@intSourceProcessID	= @ProcessID,  
					@intSourceProcessNo	= @ProcessNo,  
					@intSourceFiscalYear= @FiscalYear,  
					@intSourceSerialNo	= @SerialNo,  
					@strHdrTblName		= 'acc.tblServicesHdr',  
					@strVchNoFieldName	= 'VchNo',  
					@VoucherCreateMetod= @VoucherCreateMetod1 ,  
					@DocFormType        = @DocFormType1 ,  
					@SelectedUserVchNoType = 1 , 
					@intOldVchNo = @VchNo 
		
		FETCH NEXT FROM aa_curs into @VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  
	
		  
	  END
		  	  
	  
	END   -- end while
	  
	CLOSE aa_curs  
	DEALLOCATE aa_curs 
	
COMMIT TRAN

END TRY

	BEGIN CATCH
		ROLLBACK TRAN
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)	
		CLOSE aa_curs  
		DEALLOCATE aa_curs 
		
	END CATCH
END
GO
