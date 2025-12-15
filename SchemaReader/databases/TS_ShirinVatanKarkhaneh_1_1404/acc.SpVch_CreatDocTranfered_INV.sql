USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--=========== TS-QC:NOTOK ========================
--Author        : Reza Nogrepasand
--Create date   : 91/12/28
--Viewed By	 : 
--Last Modified : 
--Description   : 
--================================================
Create PROCEDURE [acc].[SpVch_CreatDocTranfered_INV]
	   @ProcessID			 AS INT,
	   @ProcessNo			 AS INT,
	   @VoucherCreateMetod1  AS INT,  
	   @DocFormType1		 AS INT,
	   @FromDate			 AS CHAR(10),
	   @ToDate				 AS CHAR(10),
	   @FromSerialNo		 AS int,
	   @ToSerialNo			 AS INT,
	   @IsTransfer			 AS BIT,
	   @FiscalYearFilter	 AS INT
  
WITH ENCRYPTION
AS
BEGIN
	BEGIN TRY
			
	BEGIN TRAN
		 
	DECLARE @Tax_Type int
	set @Tax_Type =0
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
		SET @tmpToSerialNo = 21474836

	Declare @SystemType		varchar(20)
	Declare @Sal_DocStep	int
		
	select @SystemType=SettingValue from pub.tblSettings where SettingKey='SystemType'
	if @ProcessID=90
	begin
		if @ProcessNo=1
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Sal_DocStep1'
		if @ProcessNo=2
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Sal_DocStep2'
		if @ProcessNo=3
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Sal_DocStep3'
		if @ProcessNo=4
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Sal_DocStep4'
		if @ProcessNo=10
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Sal_DocStep10'
	end 
	if @ProcessID=100
	begin
		if @ProcessNo=1
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='SalRet_DocStep1'
		if @ProcessNo=2
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='SalRet_DocStep2'
		if @ProcessNo=3
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='SalRet_DocStep3'
		if @ProcessNo=4
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='SalRet_DocStep4'
		if @ProcessNo=10
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='SalRet_DocStep10'
	end 
	if @ProcessID=55
	begin
		if @ProcessNo=1
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Buy_DocStep1'
		if @ProcessNo=2
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Buy_DocStep2'
		if @ProcessNo=3
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Buy_DocStep3'
		if @ProcessNo=4
			select @Sal_DocStep=SettingValue from pub.tblSettings where SettingKey='Buy_DocStep4'
	end 
	
set @Sal_DocStep=isnull(@Sal_DocStep,0)

if   (SELECT  Count(*)
	   FROM inv.tblStorageDocsHdr
		WHERE 1=1 AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo
			AND DocDate >= @tmpFromDocDate AND DocDate <= @tmpToDocDate
			AND SerialNo >= @tmpFromSerialNo AND SerialNo <= @tmpToSerialNo
	  		AND FiscalYear=@FiscalYearFilter and VchDate='') >0
	begin		
		
		if @SystemType='Sayman' or @Sal_DocStep<=1 
			update  inv.tblStorageDocsHdr set VchDate=DocDate 
				WHERE 1=1 AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo
					AND DocDate >= @tmpFromDocDate AND DocDate <= @tmpToDocDate
					AND SerialNo >= @tmpFromSerialNo AND SerialNo <= @tmpToSerialNo
	  				AND FiscalYear=@FiscalYearFilter and VchDate=''

		else if @Sal_DocStep<>1 
		update  inv.tblStorageDocsHdr set VchDate=Case when DocDate3<>'' then DocDate3 else Case when DocDate2<>'' then DocDate2 else DocDate end  end 
				WHERE 1=1 AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo
					AND DocDate >= @tmpFromDocDate AND DocDate <= @tmpToDocDate
					AND SerialNo >= @tmpFromSerialNo AND SerialNo <= @tmpToSerialNo
	  				AND FiscalYear=@FiscalYearFilter and VchDate=''
					
	end

if @ProcessID <> 95	  
begin

	if (@SystemType='Sayman' or @Sal_DocStep=1 ) and (@ProcessID=90 or @ProcessID=55  or @ProcessID=100)
			update  inv.tblStorageDocsHdr set VchDate=DocDate 
				WHERE 1=1 AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo
					AND DocDate >= @tmpFromDocDate AND DocDate <= @tmpToDocDate
					AND SerialNo >= @tmpFromSerialNo AND SerialNo <= @tmpToSerialNo
	  				AND FiscalYear=@FiscalYearFilter 

	DECLARE  aa_curs CURSOR FOR   
	   SELECT  DocStep,VchNo,VchDate,ProcessID,ProcessNo,FiscalYear,SerialNo ,Tax_Type 
	   FROM inv.tblStorageDocsHdr
		WHERE 1=1 AND ProcessID=@ProcessID AND ProcessNo=@ProcessNo
			AND DocDate >= @tmpFromDocDate AND DocDate <= @tmpToDocDate
			AND SerialNo >= @tmpFromSerialNo AND SerialNo <= @tmpToSerialNo
	  		AND FiscalYear=@FiscalYearFilter
	OPEN aa_curs  
	  
	FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  ,@Tax_Type
	  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  
	  IF @IsTransfer='False'
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
				@strHdrTblName		= 'inv.tblStorageDocsHdr',  
				@strVchNoFieldName	= 'VchNo',  
				@VoucherCreateMetod= @VoucherCreateMetod1 ,  
				@DocFormType        = @DocFormType1 ,  
				@SelectedUserVchNoType = 1 , 
				@intOldVchNo = @VchNo ,
				@Tax_Type=@Tax_Type 
		  END
		  
		FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  ,@Tax_Type
		  
	  END
	
	 IF @IsTransfer='true'
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
				@strHdrTblName		= 'inv.tblStorageDocsHdr',  
				@strVchNoFieldName	= 'VchNo',  
				@VoucherCreateMetod= @VoucherCreateMetod1 ,  
				@DocFormType        = @DocFormType1 ,  
				@SelectedUserVchNoType = 1 , 
				@intOldVchNo = @VchNo ,
				@Tax_Type=@Tax_Type
		
		FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  ,@Tax_Type
		  
	  END
	  
	END   -- end while
	  
	CLOSE aa_curs  
	DEALLOCATE aa_curs 

end

if @ProcessID=95	  
begin
  		
	DECLARE  aa_curs CURSOR FOR   
	   SELECT  DocStep,AfterSaleVchNo,AfterSaleDate,ProcessID,ProcessNo,FiscalYear,SerialNo  ,Tax_Type
	   FROM inv.tblStorageDocsHdr
		WHERE 1=1 AND ProcessID=90 AND ProcessNo=@ProcessNo
			AND AfterSaleDate >= @tmpFromDocDate AND AfterSaleDate <= @tmpToDocDate
			AND SerialNo >= @tmpFromSerialNo AND SerialNo <= @tmpToSerialNo
	  		AND FiscalYear=@FiscalYearFilter and AfterSaleDiscount<>0
	OPEN aa_curs  
	  
	FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  ,@Tax_Type
	  
	WHILE @@FETCH_STATUS = 0  
	BEGIN  
	  
	  IF @IsTransfer='False'
	  BEGIN
	  	
		  IF @VchNo>0
		  BEGIN
			DELETE FROM acc.tblVoucherDtl 
			WHERE SourceProcessID = 95  and 
				  SourceProcessNo = @ProcessNo  and 
				  SourceFiscalYear= @FiscalYear and 
				  SourceSerialNo  = @SerialNo

			EXEC [acc].[SpVch_CreateDoc]   
				@intVchNo			= @VchNo,  
				@intDocStep		    = 11,  
				@strVchDate			= @VchDate, 
				@strOldVchDate		= @VchDate,  
				@intSourceProcessID	= 95,  
				@intSourceProcessNo	= @ProcessNo,  
				@intSourceFiscalYear= @FiscalYear,  
				@intSourceSerialNo	= @SerialNo,  
				@strHdrTblName		= 'inv.tblStorageDocsHdr',  
				@strVchNoFieldName	= 'AfterSaleVchNo',  
				@VoucherCreateMetod= @VoucherCreateMetod1 ,  
				@DocFormType        = @DocFormType1 ,  
				@SelectedUserVchNoType = 1 , 
				@intOldVchNo = @VchNo ,
				@Tax_Type=@Tax_Type
		  END
		  
		FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  ,@Tax_Type
		  
	  END
	
	 IF @IsTransfer='true'
		BEGIN
		 
			DELETE FROM acc.tblVoucherDtl 
			WHERE SourceProcessID = 95  and 
				  SourceProcessNo = @ProcessNo  and 
				  SourceFiscalYear= @FiscalYear and 
				  SourceSerialNo  = @SerialNo
			EXEC [acc].[SpVch_CreateDoc]   
				@intVchNo			= @VchNo,  
				@intDocStep		    = 11,  
				@strVchDate			= @VchDate, 
				@strOldVchDate		= @VchDate,  
				@intSourceProcessID	= 95,  
				@intSourceProcessNo	= @ProcessNo,  
				@intSourceFiscalYear= @FiscalYear,  
				@intSourceSerialNo	= @SerialNo,  
				@strHdrTblName		= 'inv.tblStorageDocsHdr',  
				@strVchNoFieldName	= 'AfterSaleVchNo',  
				@VoucherCreateMetod= @VoucherCreateMetod1 ,  
				@DocFormType        = @DocFormType1 ,  
				@SelectedUserVchNoType = 1 , 
				@intOldVchNo = @VchNo ,
				@Tax_Type=@Tax_Type
		
		FETCH NEXT FROM aa_curs into @DocStep,@VchNo,@VchDate,@ProcessID,@ProcessNo,@FiscalYear,@SerialNo  ,@Tax_Type
		  
	  END
	  
	END   -- end while
	  
	CLOSE aa_curs  
	DEALLOCATE aa_curs 

end

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
