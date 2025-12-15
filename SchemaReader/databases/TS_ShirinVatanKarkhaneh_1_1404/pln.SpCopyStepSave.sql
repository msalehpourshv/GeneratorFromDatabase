USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : jafari	
-- Create date   : 1400/09/14
-- Viewed By	 : 
-- Last Modified : 
-- Description   : کپی مراحل تولید محصول
-- =============================================
Create PROCEDURE pln.SpCopyStepSave
	@FromGoodsID	Varchar(20),
	@ToGoodsID		Varchar(20),
	@FromStepNo		Int,
	@ToStepNo		Int,
	@ToStepName		Nvarchar(100),
	@CopyStep		Bit,
	@CopyGoods		Bit,
	@CopyTools		Bit,
	@CopyMachinery	Bit,
	@SessionNo		Int,
	@StepRecID		bigint,
	@OverLoadRecID  bigint,
	@LanguageID		TinyInt
	WITH ENCRYPTION
AS

BEGIN

	Declare @strMsgText	Nvarchar(2000)
	
	SET @strMsgText=''

	BEGIN TRAN

	BEGIN TRY
		 
		IF (	select count(*) from  pln.tblProduceOrderDtl where  ProductID=@ToGoodsID and StepNo=@ToStepNo)>0
		begin 
				--این روش درسفارش تولید استفاده شده است'
				SET @strMsgText='این روش برای سفارش تولید استفاده شده است'
				-- Raiserror (16016,16,@LanguageID)
				SELECT	@strMsgText AS ReturnValue 			
		end		
		else IF 	(SELECT COUNT(ProductID) FROM 	pln.tblProduceStepDtl WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromStepNo ) = 0
		BEGIN
				---- این روش توسط کاربر دیگری حذف شده است
				SET @strMsgText='این روش توسط کاربر دیگری حذف شده است'
				--Raiserror (@strMsgText,16,1)
				SELECT	@strMsgText AS ReturnValue
		END				
		else IF 	(SELECT COUNT(ProductID) FROM 	pln.tblProduceStepHdr	WHERE [ProductID] = @ToGoodsID AND [SerialNo]=@ToStepNo ) > 0
		BEGIN
				-- به این شماره روش توسط کاربر دیگری ایجاد شده است
				SET @strMsgText='به این شماره روش توسط کاربر دیگری ایجاد شده است'
				--Raiserror (@strMsgText,16,1)
				SELECT	@strMsgText AS ReturnValue 
		END

		INSERT INTO pln.tblProduceStepHdr	
			  (ProductID, SerialNo, RecID, SessionNo,ProduceMethodName,IsDefaultMethod,FormulaNo	,Tolerance,	ProductionLineID)
		SELECT @ToGoodsID, @ToStepNo, @StepRecID, @SessionNo, @ToStepName,'False', FormulaNo,Tolerance,	ProductionLineID			   
		FROM pln.tblProduceStepHdr	
		WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromStepNo

		IF (SELECT COUNT(*) FROM pln.tblProduceStepHdr WHERE [ProductID] = @ToGoodsID ) = 1
			UPDATE pln.tblProduceStepHdr
			SET IsDefaultMethod = 'True'
			WHERE [ProductID] = @ToGoodsID AND [SerialNo]=@ToStepNo
		IF @CopyStep= 1
			INSERT INTO pln.tblProduceStepDtl 
				  (ProductID,SerialNo,RowNo,GoodsIDInStep,DocRowNo,ProduceStepID,ProduceStepName,ProduceStepTime,OperatorCount,DepartmentID,CostAcntCode,CostPerProduct,LastProduceStepTime,OperationDesc,OperationImage,AcceptStoreID,FailedStoreID,LossStoreID,UsageStoreID,WorkTariffeID,NeedStep,RequestStep,NeedConfirm)
			SELECT @ToGoodsID, @ToStepNo, RowNo,GoodsIDInStep,DocRowNo,ProduceStepID,ProduceStepName,ProduceStepTime,OperatorCount,DepartmentID,CostAcntCode,CostPerProduct,LastProduceStepTime,OperationDesc,OperationImage,AcceptStoreID,FailedStoreID,LossStoreID,UsageStoreID,WorkTariffeID,NeedStep,RequestStep,NeedConfirm
			FROM  pln.tblProduceStepDtl
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromStepNo 	

		IF @CopyGoods= 1
			update prd.tblFormulasDtl 
				set ProduceStepID=b.ProduceStepID
			from prd.tblFormulasDtl a
			inner join (select * from prd.tblFormulasDtl Where (ProductID=@FromGoodsID) AND SerialNo =(SELECT top 1 FormulaNo FROM pln.tblProduceStepHdr	WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromStepNo)  )  b
				on a.SerialNo=b.SerialNo and a.GoodsID=b.GoodsID 
			where a.ProductID = @ToGoodsID AND a.SerialNo =(SELECT top 1 FormulaNo FROM pln.tblProduceStepHdr	WHERE [ProductID] = @ToGoodsID AND [SerialNo]=@ToStepNo) 

		IF @CopyTools= 1			
			INSERT INTO pln.tblProduceStepAtom
				  (ProductID,SerialNo,DocRowNo,AtomRowNo,DocAtomRowNo,ToolID,StepToolTime,IsDefaultTool)
			SELECT @ToGoodsID, @ToStepNo, DocRowNo, AtomRowNo, DocAtomRowNo, ToolID,StepToolTime,IsDefaultTool
			FROM  pln.tblProduceStepAtom
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromStepNo

		IF @CopyMachinery= 1
			INSERT INTO pln.tblProduceStepAtom2
				  (ProductID,SerialNo,DocRowNo,AtomRowNo,DocAtomRowNo,MachineryEquipmentID	,ProduceStepTime	,OperatorCount, ProduceSetTime)
			SELECT @ToGoodsID, @ToStepNo, DocRowNo, AtomRowNo, DocAtomRowNo,MachineryEquipmentID	,ProduceStepTime	,OperatorCount, ProduceSetTime
			FROM  pln.tblProduceStepAtom2
			WHERE [ProductID] = @FromGoodsID AND [SerialNo]=@FromStepNo

		SELECT '' AS ReturnValue
		COMMIT TRAN
		
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN
		
	END CATCH
	
END
GO
