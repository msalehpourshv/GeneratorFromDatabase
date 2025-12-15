USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/07/21
-- Viewed By	 : 
-- Last Modified : 92/10/07
-- Description   : 
-- =============================================
Create PROCEDURE [prd].[SpCopyFormulaSave]
	@FromGoodsID	Varchar(20),
	@ToGoodsID		Varchar(20),
	@FromFormulaNo	Int,
	@ToFormulaNo	Int,
	@ToFormulaName	Nvarchar(100),
	@CopyPreGoods	Bit,
	@CopyOverLoad	Bit,
	@CopyWage		Bit,
	@CopyWaste		Bit,
	@SessionNo		Int,
	@FormulaRecID	bigint,
	@OverLoadRecID  bigint,
	@LanguageID		TinyInt
	WITH ENCRYPTION
AS

BEGIN

	Declare @strMsgText	Nvarchar(2000)
	
	SET @strMsgText=''
	
	Declare @prdAllowEditFormula Bit;	
	SELECT @prdAllowEditFormula = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'prdAllowEditFormula'

	BEGIN TRAN

	BEGIN TRY
		IF @prdAllowEditFormula = 0
		begin 
			IF (	select count(*) from inv.tblStorageDocsHdr where  ProductID=@ToGoodsID and FormulaNo=@ToFormulaNo)>0
			begin 
				--این فرمول در تولید استفاده شده است'
				SET @strMsgText=TS.pub.funGetMessages(16016,@LanguageID)
				-- Raiserror (16016,16,@LanguageID)
				SELECT	@strMsgText AS ReturnValue 			
			end
			end
	else IF 	(SELECT COUNT(ProductID)
			FROM 	prd.tblFormulasHdr
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo ) = 0
			BEGIN
				---- این فرمول توسط کاربر دیگری حذف شده است
				SET @strMsgText=TS.pub.funGetMessages(16011,@LanguageID)
				--Raiserror (@strMsgText,16,1)
				SELECT	@strMsgText AS ReturnValue
			END				

		else IF 	(SELECT COUNT(ProductID)
			FROM 	prd.tblFormulasHdr
			WHERE [ProductID] = @ToGoodsID AND [SerialNo]=@ToFormulaNo ) > 0
			BEGIN
				-- به این شماره فرمولی توسط کاربر دیگری ایجاد شده است
				SET @strMsgText=TS.pub.funGetMessages(16012,@LanguageID)
				--Raiserror (@strMsgText,16,1)
				SELECT	@strMsgText AS ReturnValue 
			END

		INSERT INTO prd.tblFormulasHdr 
			  (ProductID, SerialNo, RecID, SessionNo, ProductCount, ManagementConfirmation, FormulaName, IsDefault, 
			   BatchSize,AcceptFormula,OutSourcing,Duration,DefaultStoreID,ComplateType,DocDate,SecondaryProdcutAmountType,DocDesc,ExtraF1,ExtraF2,	ExtraF3	,ExtraF4,FmlParam1)
		SELECT @ToGoodsID, @ToFormulaNo, @FormulaRecID, @SessionNo, ProductCount, ManagementConfirmation, @ToFormulaName,IsDefault,
			   BatchSize,AcceptFormula,OutSourcing,Duration,DefaultStoreID,ComplateType,[pub].[funChangeDate_GergorianToPersian](GetDate()) DocDate,SecondaryProdcutAmountType,DocDesc,ExtraF1,ExtraF2,	ExtraF3	,ExtraF4,FmlParam1
		FROM prd.tblFormulasHdr 
		WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo


		IF (SELECT COUNT(*) FROM prd.tblFormulasHdr WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo and IsDefault='True' )  =1
		BEGIN
			UPDATE prd.tblFormulasHdr
			SET IsDefault = 'False'
			WHERE [ProductID] = @ToGoodsID AND [SerialNo]<>@ToFormulaNo
		END

		IF (SELECT COUNT(*) FROM prd.tblFormulasHdr WHERE [ProductID] = @ToGoodsID and IsDefault='True' )  =0
			UPDATE prd.tblFormulasHdr
			SET IsDefault = 'True'
			WHERE [ProductID] = @ToGoodsID AND [SerialNo]=@ToFormulaNo
		
		IF @CopyWaste = 1
			INSERT INTO prd.tblSecondaryProductByFormulaDtl
			(  ProductID, SerialNo, RowNo, DocRowNo, GoodsID, GoodsQuantity, UnitID, ProportionOfFormula, DescDtl, ProductKind, ProduceStepID, 
                      TolerancePercent,Price)
			SELECT   @ToGoodsID, @ToFormulaNo, RowNo, DocRowNo, GoodsID, GoodsQuantity, UnitID, ProportionOfFormula, DescDtl, ProductKind, ProduceStepID, 
                      TolerancePercent,Price
			FROM prd.tblSecondaryProductByFormulaDtl
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo 
			
		IF @CopyPreGoods = 1
		begin
			alter table [prd].[tblFormulasDtl] disable trigger  [trgCheckLoop]

			INSERT INTO prd.tblFormulasDtl 
			      (ProductID, SerialNo, RowNo, GoodsID, GoodsQuantity,SubUnitQuantity, DescDtl, DocRowNo, UnitID, ReusableGoodsID, ReusableGoodsValue, UnusableGoodsID, UnusableGoodsValue, UnitID2, ProduceStepID,DefaultStoreID
				  ,IncreasePercent,DecreasePercent,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5,IsCustomOrder,CustomOrderTitle,ParamKind)
			SELECT @ToGoodsID, @ToFormulaNo, RowNo,GoodsID, GoodsQuantity,SubUnitQuantity, DescDtl, DocRowNo, UnitID, ReusableGoodsID, ReusableGoodsValue, UnusableGoodsID, UnusableGoodsValue, UnitID2 ,ProduceStepID,DefaultStoreID
			,IncreasePercent,DecreasePercent,ConstPrdText1,ConstPrdText2,ConstPrdText3,ConstPrdText4,ConstPrdText5,IsCustomOrder,CustomOrderTitle,ParamKind
			FROM  prd.tblFormulasDtl
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo 	

			INSERT INTO prd.tblFormulasAtm 
				  (ProductID, SerialNo, DocRowNo, AtomRowNo, DocAtomRowNo, GoodsID, GoodsQuantity,SubUnitID	,SubUnitQuantity)
			SELECT @ToGoodsID, @ToFormulaNo, DocRowNo, AtomRowNo, DocAtomRowNo, GoodsID, GoodsQuantity,SubUnitID ,SubUnitQuantity
			FROM  prd.tblFormulasAtm
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo
			
			alter table [prd].[tblFormulasDtl] Enable trigger  [trgCheckLoop]

		end 
		IF @CopyOverLoad = 1 OR @CopyWage = 1
			IF @CopyWage = 1
				INSERT INTO prd.tblFormulasOverLoadHdr 
				      (ProductID, SerialNo, RecID, SessionNo, ProductCount, Wage1, Wage2, Wage3, Wage4, Wage5, Wage6, Wage7, Wage8, Wage9, Wage10, WageName, AcceptFormula)
				SELECT @ToGoodsID, @ToFormulaNo, @OverLoadRecID, @SessionNo, ProductCount, Wage1, Wage2, Wage3, Wage4, Wage5, Wage6, Wage7, Wage8, Wage9, Wage10,WageName,'False'
				FROM prd.tblFormulasOverLoadHdr
				WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo
	 
			ELSE
				INSERT INTO prd.tblFormulasOverLoadHdr
				(ProductID, SerialNo, RecID, SessionNo,  ProductCount,OverLoadProduct,OverLoadDecomposition)	
				SELECT @ToGoodsID, @ToFormulaNo, @OverLoadRecID, @SessionNo, ProductCount,OverLoadProduct,OverLoadDecomposition
				FROM prd.tblFormulasOverLoadHdr
				WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo

		IF @CopyOverLoad = 1
			INSERT INTO prd.tblFormulasOverLoadDtl
			(ProductID, SerialNo, RowNo, DescDtl, DocRowNo, OverLoadAcntCode, OverLoadAmount,OverLoadProductDtl,OverLoadDecompositionDtl)	
			SELECT @ToGoodsID, @ToFormulaNo, RowNo, DescDtl, DocRowNo, OverLoadAcntCode, OverLoadAmount,OverLoadProductDtl,OverLoadDecompositionDtl
			FROM prd.tblFormulasOverLoadDtl
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromFormulaNo 
					
		SELECT '' AS ReturnValue
		COMMIT TRAN
		
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN
		
	END CATCH
	
END
GO
