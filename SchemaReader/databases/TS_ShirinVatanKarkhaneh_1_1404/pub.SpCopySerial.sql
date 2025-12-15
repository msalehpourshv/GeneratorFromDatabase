USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Sadeghi
-- Create date   : 920110
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Sadeghi
-- Description	 : 
-- ==============================================
--[pub].[SpCopySerial] 55,1,91,5000,5348,'','','','inv.tblStorageDocsHdr','inv.tblStorageDocsDtl','inv.tblStorageDocsAtom'
Create PROCEDURE [pub].[SpCopySerial]
(@ProcessID		INT,
 @ProcessNo		INT,
 @FiscalYear	INT,
 @FromSerialNo  INT,
 @ToSerialNo	INT,
 @FieldName		VARCHAR(200),
 @FieldFrmValue	VARCHAR(200),
 @FieldToValue	VARCHAR(200),
 @HdrTblName	VARCHAR(300),
 @DtlTblName	VARCHAR(300),
 @AtmTblName	VARCHAR(300),
 @Atm2TblName	VARCHAR(300),
 @Atm3TblName	VARCHAR(300),
 @VchDate		VARCHAR(300),
 @VchNoFldName  VARCHAR(300),
 @VoucherCreateMetod TINYINT,
 @DocFormType1	TINYINT,
 @SessionNo		int
)
WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @StrQuery NVARCHAR(4000)
	DECLARE @StrWhere NVARCHAR(4000)
	DECLARE @StrSet	  NVARCHAR(4000)
	
	DECLARE @HistoryID	  	bigint
	DECLARE @RecordID	  	bigint
	DECLARE @HistoryBatch	bigint
	DECLARE @CurDate	  	char(10)
	DECLARE @CutTime	  	char(5)
	DECLARE @HstXML	  	 NVARCHAR(2000)
		
	SET @HstXML = 	N'<DocumentElement><H><FN>AcntName</FN><OV /><NV>کپی از برگه  ' +  LTRIM(STR(@FromSerialNo))  + ' </NV></H></DocumentElement>'
		
	Create table  #T1(HID bigint)
	Create table  #T2(HID bigint)
	Create table  #T3(HID bigint)
	insert into #T1
	exec [hst].[funGetUniqueId]
	insert into #T2
	exec [hst].[funGetUniqueId]
	insert into #T3
	exec [hst].[funGetUniqueId]

	select @HistoryID=HID from #T1
	select @RecordID=HID from #T2
	select @HistoryBatch=HID from #T3

	select @CurDate=[pub].[funChangeDate_GergorianToPersian](GETDATE()),@CutTime=LEFT(convert(time,GETDate()),5)

	SET @StrQuery = ''
	SET @StrWhere = ' WHERE '
	SET @StrSet = ''
	
	IF @ProcessID <> 0
		SET @StrWhere = @StrWhere + ' ProcessID = '  + LTRIM(STR(@ProcessID)) + ' AND '
		
	IF @ProcessNo <> 0
		SET @StrWhere = @StrWhere + ' ProcessNo = '  + LTRIM(STR(@ProcessNo)) + ' AND '

	IF @FiscalYear <> 0
		SET @StrWhere = @StrWhere + ' FiscalYear = '  + LTRIM(STR(@FiscalYear)) + ' AND '

	IF @FromSerialNo <> 0
		SET @StrWhere = @StrWhere + ' SerialNo = '  + LTRIM(STR(@FromSerialNo)) + ' AND '

	IF @FieldName <> ''
		SET @StrWhere = @StrWhere + ' ' + @FieldName + ' = '''  + @FieldFrmValue + ''' AND '
	
	SET @StrWhere = SUBSTRING(@StrWhere,1 ,LEN(@StrWhere)-4)
	
	IF  @FromSerialNo <> @ToSerialNo
		SET @StrSet = ' SerialNo=' +  LTRIM(STR(@ToSerialNo))+ ' ,'

	IF  @FieldFrmValue <> @FieldToValue AND @FieldName <>''
	
		SET @StrSet += '  ' + @FieldName + '=''' +  @FieldToValue + ''' ,'

	SET @StrSet = SUBSTRING(@StrSet,1 ,LEN(@StrSet)-2)

	IF @HdrTblName <> ''
	BEGIN
		SET @StrQuery = @StrQuery + 'SELECT * INTO #tblH FROM ' + @HdrTblName + @StrWhere + ';'

		if @HdrTblName='sal.tblSaleOrderHdr' or @HdrTblName='inv.tblStorageDocsHdr' or @HdrTblName='cmr.tblCMRHdr' or @HdrTblName='cmr.tblOrderHdr' 
			SET @StrQuery = @StrQuery + 'UPDATE #tblH SET DocStep=1,SgnSN1=0,SgnSN2=0,SgnSN3=0,SgnSN4=0,SgnSN5=0,BaseProcessID=0,BaseProcessNo=0,BaseFiscalYear=0,BaseSerialNo=0,BaseDocType=0' + @StrWhere + ';'		
	
		if @HdrTblName='inv.tblPreSaleHdr' 
			SET @StrQuery = @StrQuery + 'UPDATE #tblH SET DocStep=1,SgnSN1=0,SgnSN2=0,SgnSN3=0,SgnSN4=0,SgnSN5=0' + @StrWhere + ';'		

		SET @StrQuery = @StrQuery + 'UPDATE #tblH SET RecID ='+  STR(@RecordID) + ',SessionNo= ' + str(@SessionNo) + @StrWhere + ';'
		
		SET @StrQuery = @StrQuery + 'UPDATE #tblH SET ' + @StrSet + @StrWhere + ';'
		
		SET @StrQuery = @StrQuery + 'INSERT INTO ' + @HdrTblName + ' SELECT * FROM #tblH ;'
	END
				
	IF @DtlTblName <> ''
	BEGIN
		SET @StrQuery =  @StrQuery + 'SELECT * INTO #tblD FROM ' + @DtlTblName + @StrWhere + ';'
		
		if @DtlTblName='sal.tblSaleOrderDtl' or @DtlTblName='inv.tblStorageDocsDtl' or @DtlTblName='cmr.tblOrderDtl' 
			SET @StrQuery = @StrQuery + 'UPDATE #tblD SET DocStep=1,BaseProcessID=0,BaseProcessNo=0,BaseFiscalYear=0,BaseSerialNo=0,BaseDocType=0,BaseDocRowNo=0' + @StrWhere + ';'
		
		if @DtlTblName='cmr.tblCMRDtl' 
			SET @StrQuery = @StrQuery + 'UPDATE #tblD SET DocStep=1,BaseProcessID=0,BaseProcessNo=0,BaseFiscalYear=0,BaseSerialNo=0,BaseDocRowNo=0' + @StrWhere + ';'

		if @DtlTblName='inv.tblPreSaleDtl' 
			SET @StrQuery = @StrQuery + 'UPDATE #tblD SET DocStep=1 ' + @StrWhere + ';'
	
		SET @StrQuery =  @StrQuery + 'UPDATE #tblD SET ' + @StrSet + @StrWhere + ';'
		
		SET @StrQuery =  @StrQuery + 'INSERT INTO ' + @DtlTblName + ' SELECT * FROM #tblD ;'
	END

	IF @AtmTblName <> ''
	BEGIN
		SET @StrQuery = @StrQuery + 'SELECT * INTO #tblA FROM ' + @AtmTblName + @StrWhere + ';'
		
		SET @StrQuery = @StrQuery + 'UPDATE #tblA SET ' + @StrSet + @StrWhere + ';'
		
		SET @StrQuery =  @StrQuery + 'INSERT INTO ' + @AtmTblName + ' SELECT * FROM #tblA ;'
		
	END
	
	IF @Atm2TblName <> ''
	BEGIN
		SET @StrQuery = @StrQuery + 'SELECT * INTO #tblA2 FROM ' + @Atm2TblName + @StrWhere + ';'
		
		SET @StrQuery = @StrQuery + 'UPDATE #tblA2 SET ' + @StrSet + @StrWhere + ';'
		
		SET @StrQuery =  @StrQuery + 'INSERT INTO ' + @Atm2TblName + ' SELECT * FROM #tblA2 ;'
		
	END
	
	IF @Atm3TblName <> ''
	BEGIN
		SET @StrQuery = @StrQuery + 'SELECT * INTO #tblA3 FROM ' + @Atm3TblName + @StrWhere + ';'
		
		SET @StrQuery = @StrQuery + 'UPDATE #tblA3 SET ' + @StrSet + @StrWhere + ';'
		
		SET @StrQuery =  @StrQuery + 'INSERT INTO ' + @Atm3TblName + ' SELECT * FROM #tblA3 ;'
		
	END
	print @StrQuery
	EXEC sp_executesql @StrQuery


	exec [hst].[spAddHistoryRecords] @HistoryID,@RecordID,@ProcessID,@ProcessNo,@FiscalYear,@ToSerialNo,'',1,0,0,1,@SessionNo,@CurDate,@CutTime,@HistoryBatch,@HstXML
	

	IF @VchNoFldName <>''
	BEGIN

	EXEC [acc].[SpVch_CreateDoc]   
			@intVchNo			= 0,  
			@intDocStep		    = 0,  
			@strVchDate			= @VchDate, 
			@strOldVchDate		= @VchDate,  
			@intSourceProcessID	= @ProcessID,  
			@intSourceProcessNo	= @ProcessNo,  
			@intSourceFiscalYear= @FiscalYear,  
			@intSourceSerialNo	= @ToSerialNo,  
			@strHdrTblName		= @HdrTblName,  
			@strVchNoFieldName	= @VchNoFldName,  
			@VoucherCreateMetod=  @VoucherCreateMetod ,  
			@DocFormType        = @DocFormType1 ,  
            @SelectedUserVchNoType = 1 , 
			@intOldVchNo = 0 
			
	END
END
GO
