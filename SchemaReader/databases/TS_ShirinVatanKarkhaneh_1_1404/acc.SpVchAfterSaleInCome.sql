USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/12/02
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchAfterSaleInCome]
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
	Declare @VisitorAcntCode		Varchar(20)
	Declare @OtherIncomeAcntCode	Varchar(20)
	Declare @strRecDesc				NVarChar(1000)
	Declare @DescDtl				NVarChar(1000)
	Declare @Price					Float
	Declare @BaseProcessID			Int
	Declare @BaseSerialNo			Int

	-----
	SELECT @BaseProcessID = BaseProcessID,
	       @BaseSerialNo  = BaseSerialNo
	FROM sal.tblAfterSaleBillDtl AD
	WHERE AD.ProcessID=@intSourceProcessID AND
      	  AD.SerialNo=@intSourceSerialNo

	IF @BaseProcessID=209
		SET @strRecDesc = N'سند درآمد تسویه ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@BaseSerialNo))) + ' برگه ' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	ELSE
		SET @strRecDesc = N'سند درآمد پخش ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
		Declare	curAfterSale CURSOR For 
			SELECT AcntCode,ts.OtherIncomeAcntCode,AD.Price,AD.DescDtl, VisitorAcntCode
			FROM sal.tblAfterSaleBillDtl AD
			INNER JOIN inv.tblStorageDocsHdr SH 
			ON  AD.BaseProcessID=SH.ProcessID
			AND AD.BaseProcessNo=SH.ProcessNo
			AND AD.BaseFiscalYear=SH.FiscalYear
			AND AD.BaseSerialNo=SH.SerialNo
			INNER JOIN inv.tblStores ts
			ON ts.StoreID=SH.StoreID
			WHERE AD.ProcessID=@intSourceProcessID AND
      			  AD.SerialNo=@intSourceSerialNo
      			   
      	 Open  curAfterSale; 
			
		Fetch NEXT From curAfterSale Into @AcntCode,@OtherIncomeAcntCode,@Price,@DescDtl,@VisitorAcntCode
	
		While (@@Fetch_Status = 0)
		
			BEGIN
			
				IF @Price <> 0
					BEGIN

						IF @OtherIncomeAcntCode = ''
							BEGIN
								
								Close curAfterSale;
								Deallocate curAfterSale; 	
								Raiserror (N'کد حسابداري سايردرآمدها در تعريف انبار خالي است',16,1)
								Return

							END

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType, VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,@Price,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescDtl,0, @VisitorAcntCode)	

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType, VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @OtherIncomeAcntCode,0,@Price,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescDtl,0, @VisitorAcntCode)	

					END
	
				Fetch NEXT From curAfterSale Into @AcntCode,@OtherIncomeAcntCode,@Price,@DescDtl,@VisitorAcntCode
			END
	
		Close curAfterSale;
		Deallocate curAfterSale; 	

END
GO
