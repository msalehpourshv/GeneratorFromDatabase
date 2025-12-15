USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : jafari
-- Create date   : 1400/02/21
-- Viewed By	 : 
-- Last Modified :
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchUseService]
		@intVchNo				Int,
		@intDocStep				TinyInt,
		@strVchDate				Char(10),
		@intSourceProcessID		TinyInt,
		@intSourceProcessNo		TinyInt,
		@intSourceFiscalYear	SmallInt,
		@intSourceSerialNo		Int,
		@intMaxRowNo			Int,
		@intMaxDocRowNo			Int,
		@SessionNo				Int,
		@LanguageID				TinyInt,
		@VchKind				TinyInt = 1	
WITH ENCRYPTION
AS

BEGIN
	
	Declare @AcntCode					Varchar(20)
	Declare @GoodsID					Varchar(20)	
	Declare @OrderAcntCode				Varchar(20)
	Declare @strRecDesc					NVarChar(1000)	
	Declare @strRecDesc2					NVarChar(1000)	
	declare @GoodsPrice1 as float
	declare @GoodsPrice2 as float
	set @GoodsPrice1=0	
	set @GoodsPrice2=0	
	
	Declare	curStore CURSOR For
		 
	SELECT	d.AcntCode,d.OrderAcntCode,d.GoodsPrice*d.GoodsQuantity,d.GoodsPrice,d.GoodsID,d.DescDtl
	FROM inv.tblStorageDocsDtl d
	inner join inv.tblGoods g on d.GoodsID=g.GoodsID and g.IsService='True'
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	Open curStore;
		
	Fetch NEXT From curStore Into @AcntCode,@OrderAcntCode,@GoodsPrice1,@GoodsPrice2,@GoodsID,@strRecDesc2
	
	While (@@Fetch_Status = 0)
		BEGIN
			
			SET @strRecDesc = ' ثبت هزینه و قطعات مصرفی سرویس کاران ' +  ' شماره ' + ltrim(rtrim(str(@intSourceFiscalYear))) +'/'  +  ltrim(rtrim(str(@intSourceSerialNo )))
			+ ' - فی ' +   ISNULL(ltrim(rtrim(str(@GoodsPrice2))),'')
			+'  کالای ' + pub.GetGoodsName(@GoodsID,1)
				    
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1				
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @OrderAcntCode,@GoodsPrice1,0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)) )	

			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1				
			
			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,@VchKind,@intMaxRowNo ,@intMaxDocRowNo,
					 @AcntCode,0,@GoodsPrice1,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)))	
			
		 	Fetch NEXT From curStore Into @AcntCode,@OrderAcntCode,@GoodsPrice1 ,@GoodsPrice2,@GoodsID,@strRecDesc2

		ENd -- curStore
		Close curStore;
		Deallocate curStore; 
					
END
GO
