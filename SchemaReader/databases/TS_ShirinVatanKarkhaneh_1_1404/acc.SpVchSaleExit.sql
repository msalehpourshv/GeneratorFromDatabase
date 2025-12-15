USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafar
-- Create date   : 97/03/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [acc].[SpVchSaleExit]
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

Declare @strMsgText					NVarChar(2044)
Declare @DescDtl					NVarChar(1000)

Declare @TransportationIncomeAcntCode Varchar(20)
Declare @TransportationIncome		Float
Declare @Wage						Float
Declare @WageSum					Float
Declare @StoreID					Varchar(20)
Declare @VisitorAcntCode		Varchar(20)
Declare @strTitleSale		    	NVarChar(100)
Declare @strFiscalSerial			VarChar(50)
Declare @GoodsName					NVarChar(1000)
DECLARE @StrQuantity			VarChar(30)
Declare @GoodsUnit					NVarChar(1000)
Declare @decPrice				varchar(30)
DECLARE @strAcntName				NVarChar(500)
DECLARE @SalAcntNameInVoucherDesc   BIT
Declare @AcntCode					Varchar(20)
Declare @GoodsPrice				Float
Declare @SubUnitPrice			Float
Declare @GoodsQuantity			Float
Declare @SubUnitQuantity		Float
Declare @Discount				Float
Declare @Discount2				FLOAT
Declare @CurrencyDiscount		FLOAT
Declare @CustomerCardDiscount	FLOAT
Declare @TotalLineDiscount		Float
Declare @TransportationCost		Float
Declare @strRecDesc					NVarChar(1000)
Declare @strRecDesc2				NVarChar(1000)
Declare @GoodsMainUnit				NVarChar(1000)
Declare @SaleTypeText				NVarChar(1000)
Declare @Address					NVarChar(2000)
Declare @SubUnitID				VarChar(20)
Declare @SubUnitID3				VarChar(20)
Declare @SaleAcntCode				Varchar(20)
Declare @DescHdr					NVarChar(1000)

SET @StrQuantity = ''	

SET @strTitleSale = ''
SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo)))

SELECT @strTitleSale = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'TitleSale' + LTRIM(RTRIM(STR(@intSourceProcessNo)))

SELECT @SalAcntNameInVoucherDesc = SettingValue
FROM pub.tblSettings
WHERE SettingKey = 'SalAcntNameInVoucherDesc'


SELECT	@StoreID=StoreID,@VisitorAcntCode=TransportationIncomeAcntCode,@AcntCode=AcntCode--@AcntCode=AcntCode,@Discount=Discount,@Discount2=Discount2,
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

	select @TransportationIncomeAcntCode=TransportationIncomeAcntCode
	From inv.tblStores where StoreID=@StoreID
	

	IF @SalAcntNameInVoucherDesc = 'True'
		Select @strAcntName = ' به ' + [pub].GetCodeName(@AcntCode, @LanguageID)
	ELSE
		SET @strAcntName = ''

	IF @VisitorAcntCode=''
		Return
		
	IF @TransportationIncomeAcntCode='' 
		BEGIN
			--کد فروش کالا خالي است 
			SET @strMsgText='کد حسابداری درآمد هزینه حمل در فروش خالی است'
			Raiserror (@strMsgText,16,1)
			Return
		END
		
--------------------------------------------------------------------------------------------------------
	

set @WageSum=0
set @VisitorAcntCode=SUBSTRING(@TransportationIncomeAcntCode,1,acc.FunGetAcntInfoForRemain(2)-1)+@VisitorAcntCode
		
		SELECT	@WageSum=SUM( isnull(D.Wage,0))
			FROM inv.tblStorageDocsDtl D
			WHERE ProcessID=@intSourceProcessID AND
				  ProcessNo=@intSourceProcessNo AND
				  FiscalYear=@intSourceFiscalYear AND
				  SerialNo=@intSourceSerialNo AND
				  IsReward = 'False'
				  
			-------------------------------------------------درآمد حمل و نقل---------------------------------------
	IF @TransportationIncomeAcntCode <> '' AND @WageSum <> 0
		BEGIN
		
			DECLARE @strRecDescTrans VARCHAR(1000) 
			
			-- SET @strRecDescTrans = ' درآمد حمل فروش ' + @strTitleSale + @strFiscalSerial
			SET @strRecDescTrans = ' كرايه حمل فروش ' + @strTitleSale + @strFiscalSerial + @strAcntName

			--------------------------------------------------------------------------------------------------------
			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1

			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
						@TransportationIncomeAcntCode,ROUND(@WageSum,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDescTrans)),'',0,0,'')
		END



	-----------------------------------------------------------------------------------------------			  
	Declare	curSale CURSOR For 
		SELECT	D.GoodsPrice,D.SubUnitPrice,CASE WHEN GoodsQuantity>0 THEN GoodsQuantity ELSE VirtualQuantity END GoodsQuantity,D.SubUnitQuantity,D.DescDtl,
					pub.funGetGoodsName(D.GoodsID,@LanguageID) AS GoodsName,
					pub.funGetGoodsUnitName(D.GoodsID, @LanguageID) AS GoodsMainUnit, U.UnitName GoodsUnit, 
					D.SubUnitID, D.SubUnitID3,  D.Wage
			FROM inv.tblStorageDocsDtl D
			left Join inv.tblUnitsDtl U ON D.SubUnitID = U.UnitID
			WHERE ProcessID=@intSourceProcessID AND
				  ProcessNo=@intSourceProcessNo AND
				  FiscalYear=@intSourceFiscalYear AND
				  SerialNo=@intSourceSerialNo AND
				  IsReward = 'False'					
				  
	Open  curSale; 
	
		Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName
		,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3,@Wage
	
		While (@@Fetch_Status = 0)
			BEGIN
		
			IF @Wage <> 0
					BEGIN

					
						SET	@StrQuantity = ltrim(rtrim(str(@SubUnitQuantity)))
						SET @decPrice = Ltrim(rtrim(str(@SubUnitPrice)))
						IF @decPrice = '0'
						BEGIN
							SET @decPrice =Ltrim(rtrim(str(@GoodsPrice)))  
							SET @StrQuantity = ltrim(rtrim(str(@GoodsQuantity))) 
						END	
						
						SET @strRecDesc2 = ' درآمد حمل  ' + @strTitleSale + @strFiscalSerial + ' - ' + @GoodsName + ' - ' + @StrQuantity + @GoodsUnit + @strAcntName
								
						SET @intMaxDocRowNo = @intMaxDocRowNo + 1
						SET @intMaxRowNo = @intMaxRowNo + 1
												
						set @WageSum=@WageSum+@Wage
																							
						INSERT INTO acc.tblVoucherDtl
								(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
								 AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,IsShowDetail,CurrencyAmount,CurrencyTypeID) 
						VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,1,@intMaxRowNo ,@intMaxDocRowNo,
								 @VisitorAcntCode,0,@Wage,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc2)), TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@DescDtl + ' - ' + @DescHdr)),0 ,'True',0,'')
					END
	
			
		
		
				Fetch NEXT From curSale Into @GoodsPrice,@SubUnitPrice,@GoodsQuantity,@SubUnitQuantity,@DescDtl,@GoodsName,@GoodsMainUnit,@GoodsUnit,@SubUnitID,@SubUnitID3, @Wage
			END
	
		Close curSale;
		Deallocate curSale; 


end
GO
