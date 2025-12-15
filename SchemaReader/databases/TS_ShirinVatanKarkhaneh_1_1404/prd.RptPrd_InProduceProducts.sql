USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/26
-- Viewed By	 : 
-- Last Modified : 1392/06/13
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_InProduceProducts]
	@SelectedGoods		Int = 0, 
	@SelectedAcnt1		Int = Null, -- کد واحد تولید
	@SelectedAcnt2		Int = Null, -- کد واحد تولید
	@SelectedAcnt3		Int = Null, -- کد واحد تولید
	@SelectedAcnt4		Int = Null, -- کد واحد تولید
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@IncludeQuantity	Bit = 1, -- شامل ستون مقدار
	@IncludePrice		Bit = 1, -- شامل ستون قیمت
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	  NVARCHAR(4000);
DECLARE @StrSelect75  NVARCHAR(4000);
DECLARE @StrFrom	  NVARCHAR(1000);
DECLARE @StrWhere	  NVARCHAR(2000);
DECLARE @StrDate	  NVARCHAR(2000);
DECLARE @BatchNo	  NVARCHAR(20)

DECLARE	@LangID			CHAR(1);
DECLARE	@SessionNo		INT; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		INT; -- برای حالت کدهای انتخابی
DECLARE	@ProductWithBatch	BIT; 

DECLARE @WithFormula VARCHAR(10)
DECLARE @RetTypes	 INT
Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	 
	SET @BatchNo = ''

	IF (SELECT Count(*) FROM inv.tblStorageDocsHdr WHERE ProcessID = 70 AND BatchNo <> '') > 0
		SET @ProductWithBatch = 'True'
	ELSE
		SET @ProductWithBatch = 'False'
		
	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	 = pub.funSplitString(@RepInfo, '@', 3);
	SET @WithFormula = pub.funSplitString(@RepInfo, '@', 6);
	SET @RetTypes	 = pub.funSplitString(@RepInfo, '@', 7);
	SET @BatchNo	 = pub.funSplitString(@RepInfo, '@', 8);
	
	-----------------------------------------------------------------------

	-- W H E R E ----------------------------------------------------------
	SET @StrWhere = '(H.ProcessID = 70)'
	SET @StrDate  = ' '

	SET @DocDateFr = LTRIM(RTRIM(@DocDateFr))
	SET @DocDateTo = LTRIM(RTRIM(@DocDateTo))
	SET @DocDateFr = isnull(@DocDateFr,'')
	SET @DocDateTo = isnull(@DocDateTo,'')

	IF (@DocDateFr Is Not Null AND @DocDateFr <> '')
		SET @StrDate = @StrDate + ' AND DocDate >= ''' + @DocDateFr + ''''
	IF (@DocDateTo Is Not Null AND @DocDateTo <> '')
		SET @StrDate = @StrDate + ' AND DocDate <= ''' + @DocDateTo + ''''

	If (@DocDateFr Is Not Null AND @DocDateFr <> '')
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	IF (@DocDateTo Is Not Null AND @DocDateTo <> '')
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@BatchNo <>'')
		SET @StrWhere = @StrWhere + ' AND (H.BatchNo=''' + @BatchNo + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	--SET @StrSelect = '
	--SELECT	H.ProcessNo, H.FiscalYear, H.SerialNo, H.BatchNo, H.DocDate, H.AcntCode, 
	--		H.ProductID, H.ProductCount, H.DocDesc, 
	--		[pub].[GetGoodsName](H.ProductID, ' + @LangID + ') AS ProductName,
	--		[pub].[GetCodeName](H.AcntCode, ' + @LangID + ') AS AcntName
	--FROM	inv.tblStorageDocsHdr H 
	--			INNER JOIN
	--			(
	--				SELECT	ProcessNo, FiscalYear, SerialNo
	--				FROM	inv.tblStorageDocsHdr
	--				WHERE	ProcessID = 70
	--				EXCEPT
	--				SELECT	BaseProcessNo, BaseFiscalYear, BaseSerialNo
	--				FROM	inv.tblStorageDocsDtl
	--				WHERE	ProcessID = 80
	--			) R ON H.ProcessNo = R.ProcessNo AND H.FiscalYear = R.FiscalYear AND H.SerialNo = R.SerialNo 
	--WHERE ' + @StrWhere
	--------------------------------------------------------------
	DECLARE @WithFormulaFilter as nvarchar(max)
	SET @WithFormulaFilter = '0 '
	if @WithFormula=2
	SEt @WithFormulaFilter = 
		'ISNULL(( SELECT MAX(MaxCount) 
				  FROM ( SELECT ProductCount * R.GoodsQuantity  / D.GoodsQuantity MaxCount
						 FROM (SELECT * 
							   FROM inv.tblStorageDocsDtl 
							   WHERE 1=1 '+@StrDate+') D
						 LEFT JOIN ( SELECT * 
									 FROM inv.tblStorageDocsDtl 
									 WHERE 1=1 '+@StrDate+') R ON R.ProcessID = 75 
															  AND R.BaseProcessID = D.ProcessID 
															  AND R.BaseProcessNo = D.ProcessNo 
															  AND R.BaseFiscalYear = D.FiscalYear 
															  AND R.BaseSerialNo = D.SerialNo
															  AND R.GoodsID = D.GoodsID
						 WHERE D.ProcessID = H.ProcessID
						   AND D.ProcessNo=H.ProcessNo
						   AND D.FiscalYear=H.FiscalYear
						   AND D.SerialNo=H.SerialNo) aaa), 0)'	 

	--=========================
	DECLARE @BatchFilter NVARCHAR(400)
	DECLARE @BatchS		 NVARCHAR(400)
	
	SET @BatchS = 'Cast(H.BatchNo As NVarchar(20)) SerialNo'
	SET @BatchFilter = ' AND D.BatchNo = H.BatchNo '
	
	IF @ProductWithBatch = 'False'
	BEGIN
		SET @BatchS = ' Cast(H.SerialNo As NVarchar(20)) SerialNo'
		SET @BatchFilter = 'And D.BaseProcessID  = 70 
							And D.BaseProcessNo  = H.ProcessNo
							And D.BaseFiscalYear = H.FiscalYear
							And D.BaseSerialNo	 = H.SerialNo '	
	END

	--=================================
	BEGIN TRY
		DROP TABLE ##tblTmp1
		DROP TABLE ##tblTmp2
	END TRY
	BEGIN CATCH
	END CATCH

IF (SELECT COUNT(*) FROM inv.tblStorageDocsDtl WHERE ProcessID = 75) = 0
	SET @StrSelect75 = ' 0 '
ELSE	
	SET @StrSelect75 = 
		'ISNULL((prd.funMaxRetProduct(H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, ' + LTrim(RTrim(Str(@RetTypes))) + ')),0)'
			
	--IF @ProductWithBatch = 'False'							
		SET @StrSelect = '
		SELECT *
		INTO ##tblTmp1
		FROM 
		( SELECT DISTINCT H.ProcessNo, 
						  H.FiscalYear,
						  ' + @BatchS + ', 
						  H.BatchNo, 
						  H.DocDate, 
						  H.AcntCode, 
						  p.ProductID,
						  GoodsQuantity  -'+@WithFormulaFilter+' ProductCount, 
						  [pub].[funGetGoodsName](p.ProductID, ' + @LangID + ') As ProductName,
						  [pub].[GetCodeName](H.AcntCode, ' + @LangID + ') AcntName, 
						  H.DocDesc
		  FROM ( SELECT * 
				 FROM inv.tblStorageDocsHdr 
				 WHERE 1=1 '+@StrDate+')H
		  OUTER APPLY prd.funPrd_ReceiveProduct(H.ProcessID,H.ProcessNo,H.FiscalYear, H.SerialNo,'''+@DocDateFr+''','''+@DocDateTo+''') p
		  WHERE H.ProcessID = 70
		    AND (H.StoreID2 <> '''' OR H.BatchNo = '''')
			AND p.ProcessID is not NULL
			AND ' + @StrWhere + '
		) T
		WHERE (ProductCount > 0.1)'
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--ELSE
		SET @StrSelect = '
		SELECT *
		INTO ##tblTmp2
		FROM 
		( SELECT DISTINCT H.ProcessNo, 
						  H.FiscalYear,
						  ' + @BatchS + ', 
						  H.BatchNo, 
						  H.DocDate, 
						  H.AcntCode, 
						  H.ProductID, 
						  H.ProductCount -  ' + @StrSelect75 +  ' - ISNULL(( SELECT SUM(GoodsQuantity)
																			 FROM inv.tblStorageDocsDtl D
																			 WHERE BaseSerialNo = 0	
																			   AND D.ProcessID = 80 ' + @BatchFilter + ' '+@StrDate+'),0) ProductCount, 
						  [pub].[funGetGoodsName](H.ProductID, ' + @LangID + ') As ProductName,
						  [pub].[GetCodeName](H.AcntCode, ' + @LangID + ') AcntName, 
						  H.DocDesc
		  FROM inv.tblStorageDocsHdr H
		  WHERE (H.StoreID2 ='''' AND H.BatchNo<>'''') 
		    AND ' + @StrWhere + ' '+@StrDate+' ) T
	    WHERE (ProductCount > 0.1)'		
	-- RUN -------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--Select * From ##tblTmp1
	
	--=========================
	--IF @ProductWithBatch = 'True'
	--BEGIN
		BEGIN TRY
			DROP TABLE ##tblSerialBatch1
			DROP TABLE ##tblSerialBatch2
		END TRY
		BEGIN CATCH
		END CATCH
		
		CREATE TABLE ##tblSerialBatch2
		(
			BatchNo	  NVARCHAR(20)  Collate Arabic_CS_AS Null,
			SerialNo  VARCHAR(1000) Collate Arabic_CS_AS Null,
			DocDate	  CHAR(10)	  Collate Arabic_CS_AS Null
		)
			
		SET @StrSelect = 'SELECT FiscalYear, 
								 SerialNo, 
								 BatchNo, 
								 DocDate
						  INTO ##tblSerialBatch1
						  FROM inv.tblStorageDocsHdr H
						  WHERE ' + @StrWhere + ' 
						    AND StoreID2 = ''''
							AND BatchNo <> '''' '+@StrDate+' ' 
		
		--PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
				
		--Select * From ##tblSerialBatch1			

		--=========================
		SET @StrSelect = '
		DECLARE @strSerials  Varchar(1000);
		DECLARE @strBatchNo  NVarchar(20);
		DECLARE @DocDate	 char(10);
		
		SET @strSerials = ''''
		SET @strBatchNo = ''''
		SET @DocDate = ''''
		
		DECLARE curTables1 CURSOR FOR 
			Select BatchNo,
				   DocDate
			From ##tblTmp2
			
		OPEN curTables1;
		
		FETCH NEXT FROM curTables1 INTO @strBatchNo,@DocDate;
		WHILE @@FETCH_STATUS = 0 
			BEGIN
				
				SET @strSerials = ''''
				
				--===============
				DECLARE @intSerialNo   int;
				DECLARE @intFiscalYear int;
							
				DECLARE curTables2 CURSOR FOR 
					SELECT FiscalYear,
						   SerialNo
					FROM ##tblSerialBatch1
					WHERE BatchNo = @strBatchNo
					  AND DocDate = @DocDate
					
				OPEN curTables2;
				
				FETCH NEXT FROM curTables2 INTO @intFiscalYear, @intSerialNo;
				WHILE @@FETCH_STATUS = 0 
					BEGIN
											
						SET @strSerials = @strSerials + Cast(@intFiscalYear As Varchar(20)) + ''/'' + Cast(@intSerialNo As Varchar(20)) + '', ''
						
						FETCH NEXT FROM curTables2 INTO @intFiscalYear, @intSerialNo;
					END
					IF LEN(@strSerials)>0
						SET @strSerials = SubString(@strSerials, 1, Len(@strSerials) - 1)
					ELSE	
						SET @strSerials = ''''
				Close curTables2;
				Deallocate curTables2;				
				--===============
				
				Insert Into ##tblSerialBatch2
				Values (@strBatchNo, @strSerials,@DocDate)
				
				FETCH NEXT FROM curTables1 INTO @strBatchNo,@DocDate;
			END
			
		Close curTables1;
		Deallocate curTables1; '	
		
		--Print @StrSelect;
		EXEC sp_executesql @StrSelect;	
		
	--END
	-- ==========================================
	SELECT *
	FROM ( SELECT T.*, 
				  B.SerialNo SerialNoList
		   FROM ##tblTmp2 T
		   INNER JOIN ##tblSerialBatch2 B ON T.BatchNo = B.BatchNo
		   							     AND T.DocDate = B.DocDate
		   UNION ALL
		   Select T.*, 
		   	      Cast(T.FiscalYear As Varchar(20)) + '/' + Cast(T.SerialNo As Varchar(20)) SerialNoList
		   From ##tblTmp1 T	) A
	ORDER BY DocDate,SerialNo

	-- ==========================================
END
GO
