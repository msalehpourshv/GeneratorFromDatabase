USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/12/27
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchAssetTempExit]
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
	Declare @AssetAcntCode		Varchar(20)
	Declare @ObverseAcntCode	Varchar(20)
	Declare @CostAmount			Float
	
	Declare @AssetTitle			NVarChar(1000)
	Declare @AssetPlaque		NVarChar(1000)
	Declare @strRecDesc			NVarChar(1000)
	Declare	@intTmpMaxRowNo		Int
	Declare	@intTmpMaxDocRowNo	Int
	DECLARE @EventNo			Int
	
	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1

	SET @intTmpMaxDocRowNo = @intMaxDocRowNo
	SET @intTmpMaxRowNo = @intMaxRowNo
	
	Declare	curTempExit CURSOR For 
	SELECT	AssetTitle,AssetPlaque,EventNo,ObverseAcntCode
	FROM ast.tblAssetsDtl 
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	----- سطر به سطر به حساب مشتری میرود
	Open  curTempExit; 

	Fetch NEXT From curTempExit Into @AssetTitle,@AssetPlaque,@EventNo,@ObverseAcntCode

	While (@@Fetch_Status = 0)
		BEGIN
					
				SELECT TOP 1  @AssetAcntCode=AssetAcntCode
				FROM  ast.tblAssetsHdr	 
				WHERE ProcessID=@intSourceProcessID AND
					  ProcessNo=@intSourceProcessNo AND
					  FiscalYear=@intSourceFiscalYear AND
					  SerialNo=@intSourceSerialNo 

				if isnull(@AssetAcntCode,'')=''				
					SELECT TOP 1  @AssetAcntCode=AssetAcntCode
					FROM  ast.tblAssetsDtl			 
					WHERE AssetPlaque = @AssetPlaque AND EventNo <= @EventNo
						and isnull(AssetAcntCode,'')<>''	
					ORDER BY EventNo Desc

				SELECT TOP 1  @CostAmount=CostAmount
				FROM  ast.tblAssetsDtl			 
				WHERE AssetPlaque = @AssetPlaque AND EventNo <= @EventNo
					and isnull(CostAmount,0)<>0
				ORDER BY EventNo Desc

				SET @strRecDesc = ' خروج موقت دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
			
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						 @ObverseAcntCode,@CostAmount,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	

				SET @strRecDesc = ' خروج موقت دارایی ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))  + ' - ' + @AssetTitle + ' - به شماره پلاک  ' + @AssetPlaque
				
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
			
				INSERT INTO acc.tblVoucherDtl
						(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType) 
				VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@AssetAcntCode ,0,@CostAmount,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0 )	
				
			Fetch NEXT From curTempExit Into @AssetTitle,@AssetPlaque,@EventNo,@ObverseAcntCode
			
		END

	Close curTempExit;
	Deallocate curTempExit; 
				
END
GO
