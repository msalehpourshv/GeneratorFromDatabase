USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 86/11/06
-- Description:	Control Receipt 
-- =============================================
--declare @YR varchar(4) =right(DB_Name(),4) ;exec	[inv].[spGetBaseRetInAllYears] 90,3,@YR,NULL
--exec [inv].[spGetBaseRetInAllYears] 90,3,1402,NULL
Create PROCEDURE [inv].[spGetBaseRetInAllYears] 
	@BaseProcessID		varchar(10),
	@BaseProcessNo		varchar(3),
	@BaseFiscalYear		varchar(4),
	@AcntCode		varchar(20)
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

DECLARE @StrSQL	NVarChar(4000);
DECLARE @curr_db_name	VarChar(100);
DECLARE @Next_db_name	VarChar(100);


SELECT CD.BaseProcessID, 
	   CD.BaseProcessNo, 
	   CD.BaseFiscalYear,
	   CD.BaseSerialNo, 
	   CD.BaseDocRowNo, 
	   SUM(CD.GoodsQuantity) GoodsQuantity 
INTO #tblRetAllYears
FROM inv.tblStorageDocsDtl CD
WHERE CD.BaseProcessID = @BaseProcessID 
  AND CD.ProcessNo = @BaseProcessNo 
  AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
GROUP BY CD.BaseProcessID, CD.BaseProcessNo, CD.BaseFiscalYear, CD.BaseSerialNo, CD.BaseDocRowNo

SET @curr_db_name = db_name();
EXEC [pub].[SpGetNextDBName]  @curr_db_name, @Next_db_name OUTPUT

	IF @Next_db_name<>''
	BEGIN

		SET @StrSQL	= N'
		INSERT INTO #tblRetAllYears
		SELECT CD.BaseProcessID, 
			   CD.BaseProcessNo, 
			   CD.BaseFiscalYear, 
			   CD.BaseSerialNo,
			   CD.BaseDocRowNo, 
			   SUM(CD.GoodsQuantity) GoodsQuantity 
		FROM ' + @Next_db_name + '.inv.tblStorageDocsDtl CD
		WHERE CD.BaseProcessID = ' + @BaseProcessID + ' 
		  AND BaseFiscalYear = ' + @BaseFiscalYear + ' 
		  AND CD.ProcessNo = ' +  @BaseProcessNo + ' 
		GROUP BY CD.BaseProcessID , CD.BaseProcessNo , CD.BaseFiscalYear , CD.BaseSerialNo , CD.BaseDocRowNo'
		
		PRINT @StrSQL
		EXEC sp_executesql @StrSQL

		SET @curr_db_name = @Next_db_name;
		SET @Next_db_name = '';

		EXEC [pub].[SpGetNextDBName]  @curr_db_name, @Next_db_name OUTPUT

		PRINT '123'
		PRINT @curr_db_name
		PRINT @Next_db_name
		PRINT '123'
		
		IF @Next_db_name <> '' AND @Next_db_name IS not NULL
		BEGIN

			SET @StrSQL	= N'
			INSERT INTO #tblRetAllYears
			SELECT CD.BaseProcessID, 
				   CD.BaseProcessNo, 
				   CD.BaseFiscalYear, 
				   CD.BaseSerialNo,
				   CD.BaseDocRowNo, 
				   SUM(CD.GoodsQuantity) GoodsQuantity 
			FROM ' + @Next_db_name + '.inv.tblStorageDocsDtl CD
			WHERE CD.BaseProcessID = ' + @BaseProcessID + ' 
			  AND BaseFiscalYear = ' + @BaseFiscalYear + ' 
			  AND CD.ProcessNo = ' +  @BaseProcessNo + ' 
			GROUP BY CD.BaseProcessID, CD.BaseProcessNo, CD.BaseFiscalYear, CD.BaseSerialNo, CD.BaseDocRowNo'
		
			PRINT @StrSQL
			EXEC sp_executesql @StrSQL
			
		END
	END
	
	SELECT CD.BaseProcessID, 
		   CD.BaseProcessNo, 
		   CD.BaseFiscalYear, 
		   CD.BaseSerialNo,
		   CD.BaseDocRowNo, 
		   SUM(CD.GoodsQuantity) GoodsQuantity 
	FROM #tblRetAllYears CD
	GROUP BY CD.BaseProcessID, CD.BaseProcessNo, CD.BaseFiscalYear, CD.BaseSerialNo, CD.BaseDocRowNo
END
GO
