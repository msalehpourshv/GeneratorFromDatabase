USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/01/30
-- Viewed By	 : 
-- Last Modified : 1386/08/29
-- Description: <Maximun Products can be Produced>
-- بیشینه مقدار تولیدی یک محصول با توجه به موجودی
-- ==============================================
CREATE PROCEDURE [prd].[RptMaxProduceQuantity]
	@ProductCode	VarChar(20),	-- کد محصول
	@IncludeDecimal	Bit = 0,		-- شامل ارقام اعشار باشد یا نه؟
	@Result			Real = 0 Output		-- نتیجه
WITH ENCRYPTION
AS

-- جدول موجودی کالاها 111
Create Table #tblGoodsStock
(
	GoodsID    VarChar(20) COLLATE Arabic_CS_AS Not Null,
	GoodsQty   Real Not Null
)

Create Table #tblResult
(
	ProductID	VarChar(20) COLLATE Arabic_CS_AS Not Null, 
	GoodsID		VarChar(20) COLLATE Arabic_CS_AS Not Null, 
	GoodsQty	Real Not Null,
	GoodsRequested	Real Not Null,
	IsLeaf		Bit
)
-- فرمول محصول - کالا
Create Table #tblProductGoods
(
	ProductID  VarChar(20) COLLATE Arabic_CS_AS Not Null,
	GoodsID    VarChar(20) COLLATE Arabic_CS_AS Not Null,
	GoodsQty   Real Not Null,
)
----------- Declare Variables ----------------------
Declare	@ProductID		VarChar(20),
		@GoodsID		VarChar(20), 
		@ProductQty     Real,
		@AvailableQty	Real,
		@HasChild		Bit,
		@Increment		Real,
		@CanProduce		Bit
--------------------------- Start Procedure Code ---------------------------------------------
BEGIN

	SET NOCOUNT ON;

	Set @Increment = 1

	---- Fill Goods Stock Table ----
	Truncate Table #tblGoodsStock
	
	Insert Into #tblGoodsStock
	Select GoodsID , 
		(
			SELECT IsNull(SUM(D.GoodsQuantity * D.EnterKind), 0)
			FROM inv.tblStorageDocsDtl D
			WHERE (D.GoodsID = inv.tblGoods.GoodsID) AND (D.PhysicallyEffected = 1)
		) As GoodsQty
	From   inv.tblGoods 
	
	----* Declare Cursors ----------------------------------
	Declare Cursor_Goods CURSOR For							
       Select ProductID, GoodsID, GoodsQty
       From   #tblProductGoods
	--------------------------------------------------------

	Insert Into #tblProductGoods
	Select F.ProductID, FC.GoodsID, (FC.GoodsQuantity / F.ProductCount)
	From   prd.tblFormulasDtl FC Inner Join prd.tblFormulasHdr F 
           On FC.ProductID = F.ProductID AND FC.SerialNo = F.SerialNo
	Where  FC.ProductID = @ProductCode

	-- Find Minimum Quantity Can be Produced
	Set @Result = (Select Floor(Min(#tblGoodsStock.GoodsQty / #tblProductGoods.GoodsQty))
	From #tblProductGoods Inner Join #tblGoodsStock On #tblProductGoods.GoodsID = #tblGoodsStock.GoodsID)

	-- Decrease Stock for amount of Minimum that found
	Update #tblGoodsStock
	Set #tblGoodsStock.GoodsQty = #tblGoodsStock.GoodsQty - (#tblProductGoods.GoodsQty * @Result)   
	From #tblGoodsStock Inner Join #tblProductGoods On (#tblGoodsStock.GoodsID = #tblProductGoods.GoodsID);

	While (1 = 1) 
	Begin
		-- Insert First Layer ------
		Truncate Table #tblProductGoods
		Insert Into #tblProductGoods
		Select F.ProductID, FC.GoodsID, (FC.GoodsQuantity / F.ProductCount) * @Increment
		From   prd.tblFormulasDtl As FC Inner Join prd.tblFormulasHdr As F 
			On FC.ProductID = F.ProductID AND FC.SerialNo = F.SerialNo
		Where  FC.ProductID = @ProductCode
		
		---- Read First Row From #tblProductGoods 
		Open  Cursor_Goods
		Fetch NEXT From Cursor_Goods Into @ProductID, @GoodsID, @ProductQty
			
		Set @CanProduce = 1 -- flag to determine whether produce were successfull or not
		
		While @@FETCH_STATUS = 0 --- Cursor_Goods ---
		Begin
			--- Get Available Quantity of Goods
			Select @AvailableQty = GoodsQty
			From   #tblGoodsStock 
			Where  GoodsID = @GoodsID

			--- Requested Quantity is more than available; Append Goods Leafs From Current Product
			If @ProductQty > @AvailableQty
			Begin
				--- Insert childs of Product(@GoodsID) that is needed ----
				Insert Into #tblProductGoods
				Select F.ProductID, FC.GoodsID, ((@ProductQty - @AvailableQty) * FC.GoodsQuantity / F.ProductCount) 
				From   prd.tblFormulasDtl FC Inner Join prd.tblFormulasHdr F 
						On FC.ProductID = F.ProductID AND FC.SerialNo = F.SerialNo
				Where  FC.ProductID = @GoodsID

				--- Check whether inserted any row
				If @@RowCount = 0  
					Set @HasChild = 0
				Else 
					Set @HasChild = 1
				--- Has not any child; Or Result is for special Product
				If (@HasChild = 0)
				Begin 
					Insert Into #tblResult
					Values (@ProductID, @GoodsID, @ProductQty - @AvailableQty, @ProductQty, ~ @HasChild)
					Set @CanProduce = 0 -- flag set to false (could not produce)
					Break 
				End

				--- Consume All Goods Stock; Remain 0  
				Update #tblGoodsStock
				Set    GoodsQty = 0
				Where  GoodsID = @GoodsID
			End
			Else --- Available quantity is enough for request; Consume from goods stock for amount of @GoodsNeeded
			Begin 
				Update #tblGoodsStock
				Set    GoodsQty = GoodsQty - @ProductQty
				Where  GoodsID = @GoodsID
			End

			--- Read Next Row From #tblProductGoods
			Fetch NEXT From Cursor_Goods Into @ProductID, @GoodsID, @ProductQty

		End --- End Of < WHILE @@FETCH_STATUS = 0 > 

		Close Cursor_Goods 

		If (@CanProduce = 1) --- Produced Successfully
		Begin

			Set @Result = @Result + @Increment
			If @Increment >= 1 Set @Increment = @Increment * 2
		End

		Else  -- Could Not Produce --
		Begin

			If @Increment > 1    -- < Integer Bound > Change Inc Factor & Continue --
				Set @Increment = @Increment / 2

			Else If @Increment = 1   -- End of Integer Bound
			Begin		
				If @IncludeDecimal = 1   -- Init Decimal Section & Continue
					Set @Increment = 0.1
				Else   -- Ending Query with Integer numbers
					Break
			End

			Else   ----- < Decimal Bound > -----
			Begin
				If @Increment >= 0.0001   -- Change Inc Factor & Continue 
					Set @Increment = @Increment / 10 
				Else   -- Ending Query                 
					Break
			End    ----- < Decimal Bound > -----

		End -- End Of < Could Not Produce >

	End -- End of < While(1 = 1) >

	DeAllocate  Cursor_Goods

	Set @Result = Convert(Real, Str(@Result, 20, 3))

END
--  ========================================================================================
GO
