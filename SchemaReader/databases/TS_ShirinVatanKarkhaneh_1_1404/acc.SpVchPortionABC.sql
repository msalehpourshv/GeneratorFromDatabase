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
Create PROCEDURE [acc].[SpVchPortionABC]
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

	Declare @RowAcntCode			Varchar(20)
	Declare @RowAmount				Float
	Declare @ColumnAcntCode			Varchar(20)
	Declare @cellAmount				Float
	Declare @SumCellAmount			Float
	Declare @CellCounter			Int
	Declare @CellCount				Int
 	Declare @strRecDesc				NVarChar(1000)
 	Declare @strRecDesc1			NVarChar(1000)

	--------------------------------------------------------------------------------------------------------
	SET @strRecDesc = 'سند هزینه یابی بر اساس فعالیت ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
	Declare	curPortionABC_Row CURSOR For 
	SELECT	DISTINCT RowAcntCode,RowAmount
	FROM cac.tblPortionABCDtl
	where ProcessID= @intSourceProcessID
	  AND ProcessNo= @intSourceProcessNo
	  AND FiscalYear= @intSourceFiscalYear
	  AND SerialNo= @intSourceSerialNo
	  
	Open  curPortionABC_Row; 
		
	Fetch NEXT From curPortionABC_Row Into @RowAcntCode, @RowAmount

	While (@@Fetch_Status = 0)
		BEGIN
			IF @RowAmount <> 0
				BEGIN
					SET @SumCellAmount = 0
					SET @CellCounter = 0
					Declare	curPortionABC_Col CURSOR For 
					SELECT	DISTINCT ColumnAcntCode,cellAmount,count(cellAmount)over(partition by ProcessID,ProcessNo,RowNumber,RowAcntCode) CellCount
					FROM cac.tblPortionABCDtl
					where ProcessID= @intSourceProcessID
					  AND ProcessNo= @intSourceProcessNo
					  AND FiscalYear= @intSourceFiscalYear
					  AND SerialNo= @intSourceSerialNo
					  AND RowAcntCode = @RowAcntCode
					  
					Open  curPortionABC_Col; 
						
					Fetch NEXT From curPortionABC_Col Into @ColumnAcntCode,@cellAmount,@CellCount

					While (@@Fetch_Status = 0)
						BEGIN
							SET @CellCounter = @CellCounter +1
							
							IF @CellCounter=@CellCount
								SET @cellAmount = @RowAmount - @SumCellAmount

							SET @SumCellAmount= @SumCellAmount + ROUND(@cellAmount,0)
							
							PRINT @SumCellAmount
							
							IF @SumCellAmount>@RowAmount
								SET @cellAmount = @cellAmount - (@SumCellAmount-ROUND(@RowAmount,0))

							set @strRecDesc1 = @strRecDesc 
							SET @intMaxDocRowNo = @intMaxDocRowNo + 1
							SET @intMaxRowNo = @intMaxRowNo + 1
				
							INSERT INTO acc.tblVoucherDtl
									(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
									 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
							VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @ColumnAcntCode,ROUND(@cellAmount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc1)),'',0)	
							
							Fetch NEXT From curPortionABC_Col Into @ColumnAcntCode,@cellAmount,@CellCount
						END

					Close curPortionABC_Col;
					Deallocate curPortionABC_Col; 	

					set @strRecDesc1 = @strRecDesc 
					SET @intMaxDocRowNo = @intMaxDocRowNo + 1
					SET @intMaxRowNo = @intMaxRowNo + 1
		
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @RowAcntCode,0,ROUND(@RowAmount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc1)),'',0)	
				END
			Fetch NEXT From curPortionABC_Row Into @RowAcntCode, @RowAmount
		END

	Close curPortionABC_Row;
	Deallocate curPortionABC_Row; 	


END

GO
