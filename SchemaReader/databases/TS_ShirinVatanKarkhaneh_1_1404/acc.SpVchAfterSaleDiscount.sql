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
CREATE PROCEDURE [acc].[SpVchAfterSaleDiscount]
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
	Declare @SaleDiscountAcntCode	Varchar(20)
	Declare @strRecDesc				NVarChar(1000)
	Declare @DescDtl				NVarChar(1000)
	Declare @Price					Float

	-----
	
	SET @strRecDesc = N'سند تخفيفات پخش ' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
		Declare	curAfterSale CURSOR For 
			SELECT AcntCode,ts.SaleDiscountAcntCode,AD.Price,AD.DescDtl,VisitorAcntCode
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
			
		Fetch NEXT From curAfterSale Into @AcntCode,@SaleDiscountAcntCode,@Price,@DescDtl,@VisitorAcntCode
	
		While (@@Fetch_Status = 0)
		
			BEGIN
			
				IF @Price <> 0
					BEGIN

						IF @SaleDiscountAcntCode = ''
							BEGIN
								
								Close curAfterSale;
								Deallocate curAfterSale; 	
								Raiserror (N'کد حسابداري تخفيفات فروش در تعريف انبار خالي است',16,1)
								Return
							END

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,VisitorAcntCode) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @SaleDiscountAcntCode,@Price,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescDtl,0,@VisitorAcntCode)	

						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
			
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,VisitorAcntCode ) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @AcntCode,0,@Price,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),@DescDtl,0,@VisitorAcntCode)	

					END
	
				Fetch NEXT From curAfterSale Into @AcntCode,@SaleDiscountAcntCode,@Price,@DescDtl,@VisitorAcntCode
			END
	
		Close curAfterSale;
		Deallocate curAfterSale; 	

END

GO
