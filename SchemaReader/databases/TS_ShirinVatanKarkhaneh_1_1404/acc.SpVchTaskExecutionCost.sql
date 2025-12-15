USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   :
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchTaskExecutionCost]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		SmallInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN
	-----
	
	Declare @strMsgText				NVarChar(2044)

	Declare @AcntCode				Varchar(20)
	Declare @CostAcntCode			Varchar(20)
	Declare @Amount					Float
	Declare @SumAmount				Float
 	Declare @strRecDesc				NVarChar(1000)
 	Declare @strRecDesc1			NVarChar(1000)
	DECLARE @StrSelect				NVarChar(4000);
	
	SET @SumAmount =0
	SET @AcntCode = ''	
	declare @db_0000 as varchar(300)= Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	CREATE TABLE #tbl_TaskExecutionCost
	(
		CostAcntCode		varchar(20),
		Amount				float,
		AcntCode		varchar(20)
	);

		SET @StrSelect = '
		INSERT INTO #tbl_TaskExecutionCost
		SELECT	a.CostAcntCode,a.Amount,b.AcntCode
		FROM ' + @db_0000 + '.tpm.tblTaskExecutionCostDtl a
		INNER JOIN ' + @db_0000 + '.tpm.tblTaskExecutionHdr b
		ON a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and 
		   a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
		WHERE b.ProcessID=' + str(@intSourceProcessID) + ' AND
			  b.ProcessNo=' + str(@intSourceProcessNo) + ' AND
			  b.FiscalYear=' + str(@intSourceFiscalYear)+ ' AND
			  b.SerialNo=' + str(@intSourceSerialNo) 

	EXEC sp_executesql @StrSelect;

			
	--------------------------------------------------------------------------------------------------------
	SET @strRecDesc = 'هزینه تعمیرات و نگهداری برگه ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
		Declare	curTaskExecutionCost CURSOR For 
		SELECT	*
		FROM #tbl_TaskExecutionCost
	
		Open  curTaskExecutionCost; 
			
		Fetch NEXT From curTaskExecutionCost Into @CostAcntCode, @Amount,@AcntCode
	
		While (@@Fetch_Status = 0)
		
			BEGIN
			
				IF @Amount <> 0 and @CostAcntCode<>''
					BEGIN
						SET @SumAmount = @SumAmount + @Amount 
						set @strRecDesc1 = @strRecDesc 
						
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1

						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @CostAcntCode,@Amount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc1)),'',0 )	

					END
	
				Fetch NEXT From curTaskExecutionCost Into @CostAcntCode, @Amount,@AcntCode
			END
	
		Close curTaskExecutionCost;
		Deallocate curTaskExecutionCost; 	

		IF @AcntCode<>'' AND @SumAmount>0
		BEGIN
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,0,@SumAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
		END

END
GO
