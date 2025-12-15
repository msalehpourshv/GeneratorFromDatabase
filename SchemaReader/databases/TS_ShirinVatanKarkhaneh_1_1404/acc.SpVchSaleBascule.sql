USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 89/06/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [acc].[SpVchSaleBascule]
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
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN
	-----

	Declare @strMsgText		NVarChar(2044)
	Declare @CurrencyAmount	Float
	Declare @AcntCode		Varchar(20)
	Declare @SaleAcntCode	Varchar(20)
	Declare @StoreID		Varchar(20)
	Declare @GoodsName		NVarChar(1000)
	Declare @BoxGoodsName	NVarChar(1000)
	DECLARE @PureWeight		FLOAT
	DECLARE @BoxQuantity	FLOAT
	DECLARE @Fee			FLOAT
	DECLARE @BoxFee			FLOAT
	Declare @DescHdr		NVarChar(1000)
	Declare @strRecDesc		NVarChar(1000)
	Declare @strRecDesc2	NVarChar(1000)
	--------------------------------------------------------------------------------------------------------
	SET @CurrencyAmount = 0

	SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@GoodsName=pub.funGetGoodsName(GoodsID,@LanguageID),@BoxGoodsName=pub.funGetGoodsName(BoxGoodsID,@LanguageID),
            @PureWeight = FullVehicleWeight - EmptyVehicleWeight - SubsidenceWeight - ((FullVehicleBoxes - EmptyVehicleBoxes) * BoxWeight) ,
			@Fee = Fee ,@BoxQuantity = FullVehicleBoxes - EmptyVehicleBoxes ,@BoxFee = BoxFee ,@DescHdr=DocDesc
	FROM inv.tblBaskulSalesHdr
	WHERE ProcessID=@intSourceProcessID AND
		  SerialNo=@intSourceSerialNo 

    SELECT @SaleAcntCode=SaleAcntCode
    FROM inv.tblStores 
    WHERE StoreID = @StoreID


	IF @SaleAcntCode=''
		BEGIN
			--کد فروش کالا خالي است 
			SET @strMsgText=TS.pub.funGetMessages(11029,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	
		SET @strRecDesc=' فروش باسکول شماره' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
		----- 

		SET @strRecDesc2 = @strRecDesc + ' - ' + ISNULL(@GoodsName,'') + ' - ' + ISNULL(ltrim(rtrim(str(@PureWeight))),'') + ' - فی ' + ISNULL(ltrim(rtrim(str(@Fee))),'')
				
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @SaleAcntCode,0,ROUND(@Fee * @PureWeight,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount)	

		-----
		IF @BoxQuantity <> 0 AND @BoxFee <> 0 
			BEGIN
				SET @strRecDesc2 = @strRecDesc + ' - ' + ISNULL(@BoxGoodsName,'') + ' - ' + ISNULL(ltrim(rtrim(str(@BoxQuantity))),'') + ' - فی ' + ISNULL(ltrim(rtrim(str(@BoxFee))),'')
						
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				
				IF 	@BoxQuantity > 0 
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @SaleAcntCode,0,ROUND(@BoxFee * abs(@BoxQuantity),0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount)	
				ELSE
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @AcntCode,0,ROUND(@BoxFee * abs(@BoxQuantity),0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount)	
			END
		------
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
		
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
				 @AcntCode,ROUND(@Fee * @PureWeight,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount)	

		IF @BoxQuantity <> 0 AND @BoxFee <> 0 
			BEGIN 
				------
				SET @intMaxDocRowNo = @intMaxDocRowNo + 1
				SET @intMaxRowNo = @intMaxRowNo + 1
				
				IF 	@BoxQuantity > 0 
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @AcntCode,ROUND(@BoxFee * abs(@BoxQuantity),0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount)	
				ELSE
					INSERT INTO acc.tblVoucherDtl
							(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
							 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount) 
					VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
							 @SaleAcntCode,ROUND(@BoxFee * abs(@BoxQuantity),0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescHdr)),0,@CurrencyAmount)	
			END
END
GO
