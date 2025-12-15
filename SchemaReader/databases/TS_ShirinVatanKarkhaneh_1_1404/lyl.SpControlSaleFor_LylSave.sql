USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 91/07/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [lyl].[SpControlSaleFor_LylSave]
	@CustomerCardNo	Varchar(20),
	@Date   		Varchar(20) = Null,
	@intProcessID	TinyInt,
	@intProcessNo	TinyInt,
	@intFiscalYear	SmallInt,
	@intSerialNo	Int,
	@IsView			Bit,
	@IsTransfer		Bit
	

WITH ENCRYPTION
AS

BEGIN
	DECLARE @Discount DECIMAL(28,9)
	DECLARE @GoodsID VARCHAR(20)
	DECLARE @CustomerInfoID VARCHAR(20)
	DECLARE @GoodsQuantity DECIMAL(28,9)
	DECLARE @GoodsPrice DECIMAL(28,9)
	DECLARE @DiscountDtl DECIMAL(28,9)
	DECLARE @TaxOverWorthCostDtl DECIMAL(28,9)
	DECLARE @TollOverWorthCostDtl DECIMAL(28,9)
	
	DECLARE @BeforeCardDiscount  DECIMAL(28,9)
	DECLARE @CustomerCardPrivilege1 DECIMAL(28,9)
	DECLARE @CustomerCardPrivilege DECIMAL(28,9)
	DECLARE @FromDate CHAR(10)
	DECLARE @ToDate CHAR(10)
	DECLARE @SpesialDate CHAR(10)
	
	DECLARE @GoodsID1 VARCHAR
	DECLARE @ForEachRials FLOAT  
	DECLARE @Score FLOAT
	DECLARE @DiscountPercent FLOAT
	DECLARE @DiscountAmount FLOAT
	DECLARE @ForEachScore FLOAT
	DECLARE @EnterKind int

	----------------------------------------------------------------------
	--Declare @SalePricePercentForCartDiscount AS Tinyint
	
	--SET @SalePricePercentForCartDiscount = 0
	
	--SELECT @SalePricePercentForCartDiscount = SettingValue
	--FROM pub.tblSettings
	--WHERE SettingKey = 'SalePricePercentForCartDiscount'
	--------------------------------------------------------------------
		
	SET @Discount = 0
	SET @BeforeCardDiscount = 0
	SET @CustomerCardPrivilege = 0
	SET @CustomerCardPrivilege1 = 0
	
	CREATE TABLE #tmpTable
	(
		GoodsGroup      Varchar(20),
		TotalGoodsPrice FLOAT,
		ForEachRials    FLOAT,
		Score		    FLOAT,
	)
		
	SELECT TOP 1 @CustomerInfoID = CustomerInfoID
	from 	lyl.tblLoyalCardDtl
	WHERE IsActive ='True' AND LoyalCardNo = @CustomerCardNo
	order by DocDate desc
	
	-- ==========
	DECLARE	Cursor_SaleOrderDtl CURSOR For 
	SELECT	EnterKind, GoodsID, GoodsQuantity, GoodsPrice, 
			DiscountDtl, TaxOverWorthCostDtl, TollOverWorthCostDtl 
			--Case When @SalePricePercentForCartDiscount = 0 Then GoodsPrice 
			--Else GoodsPrice * @SalePricePercentForCartDiscount / 100 End GoodsPrice, 
	FROM inv.tblStorageDocsDtl s
	WHERE s.SerialNo=@intSerialNo AND
		  s.ProcessID = @intProcessID AND
		  s.FiscalYear=@intFiscalYear AND
		  s.ProcessNo=@intProcessNo

	-- ==========
	Open  Cursor_SaleOrderDtl;
	Fetch NEXT From Cursor_SaleOrderDtl Into @EnterKind, @GoodsID, @GoodsQuantity, @GoodsPrice, @DiscountDtl, @TaxOverWorthCostDtl, @TollOverWorthCostDtl
	
	While (@@Fetch_Status = 0)
	BEGIN
	
		SELECT TOP 1 @GoodsID1=d1.GoodsID, @ForEachRials=d1.ForEachRials, @Score=d1.Score
		FROM lyl.tblLoyalCarnivalInfoDtl1 d1
		INNER JOIN (SELECT * FROM lyl.tblLoyalCarnivalInfoHdr 
					WHERE CustomerInfoID = SUBSTRING(@CustomerInfoID,1,LEN(CustomerInfoID)) AND 
					(@Date Is Null OR (FromDate <= @Date AND ToDate >= @Date))) H
		ON H.SerialNo = d1.SerialNo
		WHERE d1.GoodsID <= SUBSTRING(@GoodsID,1,LEN(d1.GoodsID)) AND d1.GoodsIDTo >= SUBSTRING(@GoodsID,1,LEN(d1.GoodsIDTo))
		ORDER BY LEN(d1.GoodsID) Desc

		
		IF ((SELECT COUNT(*) FROM #tmpTable WHERE GoodsGroup = @GoodsID1)=0)
			INSERT INTO #tmpTable 
			VALUES(@GoodsID1, (-1 * @EnterKind * @GoodsQuantity*@GoodsPrice-(@DiscountDtl+@TaxOverWorthCostDtl+@TollOverWorthCostDtl)), @ForEachRials, @Score)
		ELSE	
			UPDATE #tmpTable
			SET TotalGoodsPrice = TotalGoodsPrice + (-1 * @EnterKind * (@GoodsQuantity*@GoodsPrice-(@DiscountDtl+@TaxOverWorthCostDtl+@TollOverWorthCostDtl)))
			WHERE GoodsGroup = @GoodsID1
			
		Fetch NEXT From Cursor_SaleOrderDtl Into @EnterKind, @GoodsID, @GoodsQuantity, @GoodsPrice, @DiscountDtl, @TaxOverWorthCostDtl, @TollOverWorthCostDtl
	END
	
	Close Cursor_SaleOrderDtl;
	Deallocate Cursor_SaleOrderDtl;
	 
	-- ==========
	IF (SELECT COUNT(*) FROM lyl.tblLoyalCarnivalInfoDtl2 d2 WHERE d2.SpesialDate = @Date) = 1
	BEGIN
		DECLARE @ScoreCoefficient AS FLOAT
		
		SELECT @ScoreCoefficient=ScoreCoefficient FROM lyl.tblLoyalCarnivalInfoDtl2 d2 WHERE d2.SpesialDate = @Date
		
		UPDATE #tmpTable SET Score = Score * @ScoreCoefficient
		 
	END 

	DECLARE @TotalGoodsPrice AS DECIMAL(28,9)
	SELECT @CustomerCardPrivilege1 =  ISNULL(FLOOR(SUM(TotalGoodsPrice*Score/ForEachRials)),0),
	       @TotalGoodsPrice = SUM(TotalGoodsPrice)
	FROM #tmpTable
	DROP TABLE #tmpTable
	
	SELECT TOP 1 @DiscountPercent=DiscountPercent, @DiscountAmount=DiscountAmount,@ForEachScore=ForEachScore ,@FromDate=FromDate,@ToDate=ToDate
	FROM lyl.tblLoyalCarnivalInfoHdr
	WHERE CustomerInfoID = SUBSTRING(@CustomerInfoID,1,LEN(CustomerInfoID)) AND 
		  (@Date Is Null OR (FromDate <= @Date AND ToDate >= @Date))
	ORDER BY SerialNo DESC

	--==================================
	DECLARE @UsedPrivilege AS DECIMAL(28,9)
	DECLARE @UsedDiscount AS DECIMAL(28,9)
	DECLARE @DiscountAmountM AS DECIMAL(28,9)
	DECLARE @ForEachScoreM AS DECIMAL(28,9)

	-- ========================== Sale
	SELECT  @UsedPrivilege = ((CCDiscount / DiscountAmount) * ForEachScore), @UsedDiscount = CCDiscount, 
			@DiscountAmountM = DiscountAmount, @ForEachScoreM = ForEachScore
	FROM 
		(
		 SELECT ISNULL(SUM(Case when ProcessID = 90 THEN CCDiscount ELSE (-1 * CCDiscount) END),0) CCDiscount,
				(Select DiscountAmount From lyl.tblLoyalCarnivalInfoHdr
				 Where CustomerInfoID = SUBSTRING(@CustomerInfoID, 1, LEN(CustomerInfoID))) DiscountAmount,
				(Select ForEachScore From lyl.tblLoyalCarnivalInfoHdr
				 Where CustomerInfoID = SUBSTRING(@CustomerInfoID, 1, LEN(CustomerInfoID))) ForEachScore	    
			    
		 FROM inv.tblStorageDocsHdr H
		 WHERE CCNo = @CustomerCardNo AND
			   Case When @IsTransfer = 'False' Then DocDate Else '' End >= Case When @IsTransfer = 'False' Then @FromDate Else '' End AND
			   Case When @IsTransfer = 'False' Then DocDate Else '' End <= Case When @IsTransfer = 'False' Then @ToDate Else '' End AND
			   (@intSerialNo = 0 OR SerialNo <= @intSerialNo) AND
			   ProcessID IN(90) AND 
			   FiscalYear = @intFiscalYear
		) A	
		

	-- ========================== SaleRet
	SELECT  @UsedPrivilege = @UsedPrivilege - ((CCDiscount / DiscountAmount) * ForEachScore), 
			@UsedDiscount = @UsedDiscount - CCDiscount, @DiscountAmountM = DiscountAmount, 
			@ForEachScoreM = ForEachScore
	FROM 
		(
		 SELECT ISNULL(SUM(Case when ProcessID = 100 THEN CCDiscount ELSE (-1 * CCDiscount) END),0) CCDiscount,
				(Select DiscountAmount From lyl.tblLoyalCarnivalInfoHdr
				 Where CustomerInfoID = SUBSTRING(@CustomerInfoID, 1, LEN(CustomerInfoID))) DiscountAmount,
				(Select ForEachScore From lyl.tblLoyalCarnivalInfoHdr
				 Where CustomerInfoID = SUBSTRING(@CustomerInfoID, 1, LEN(CustomerInfoID))) ForEachScore	    
			    
		 FROM inv.tblStorageDocsHdr H
		 WHERE CCNo = @CustomerCardNo AND
			   Case When @IsTransfer = 'False' Then DocDate Else '' End >= Case When @IsTransfer = 'False' Then @FromDate Else '' End AND
			   Case When @IsTransfer = 'False' Then DocDate Else '' End <= Case When @IsTransfer = 'False' Then @ToDate Else '' End AND
			   (@intSerialNo = 0 OR SerialNo <= @intSerialNo) AND
			   ProcessID IN(100) AND 
			   FiscalYear = @intFiscalYear
		) A	
			
		--Print '@UsedPrivilege = ' + Str(@UsedPrivilege)
		--Print '@DiscountAmountM = ' + Str(@DiscountAmountM)
		--Print '@ForEachScoreM = ' + Str(@ForEachScoreM)
		
--==================================
IF @intProcessID = 90
BEGIN

	SELECT 	@BeforeCardDiscount= ISNULL(SUM(Case when ProcessID = 90 THEN CCDiscount ELSE -1 * CCDiscount END),0) ,
			@CustomerCardPrivilege = @CustomerCardPrivilege1 + ISNULL(SUM(Case when ProcessID = 90 THEN CCPrivilege 
																		  ELSE (-1 * CCPrivilege) END),0)
	FROM inv.tblStorageDocsHdr 
	WHERE CCNo = @CustomerCardNo AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End >= Case When @IsTransfer = 'False' Then @FromDate Else '' End AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End <= Case When @IsTransfer = 'False' Then @ToDate Else '' End AND
		  --SerialNo<@intSerialNo AND
		  ProcessID IN(90) AND 
		  FiscalYear = @intFiscalYear 
		  		  
  	SELECT 	@BeforeCardDiscount= @BeforeCardDiscount + ISNULL(SUM(Case when ProcessID = 90 THEN CCDiscount ELSE -1 * CCDiscount END),0) ,
	@CustomerCardPrivilege = @CustomerCardPrivilege + ISNULL(SUM(Case when ProcessID = 90 THEN CCPrivilege 
																		  ELSE (-1 * CCPrivilege) END),0)
	FROM inv.tblStorageDocsHdr 
	WHERE CCNo = @CustomerCardNo AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End >= Case When @IsTransfer = 'False' Then @FromDate Else '' End AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End <= Case When @IsTransfer = 'False' Then @ToDate Else '' End AND
		  ProcessID IN(100) AND 
		  FiscalYear = @intFiscalYear 
END

ELSE IF @intProcessID = 100
BEGIN
	SELECT 	@BeforeCardDiscount= ISNULL(SUM(Case when ProcessID = 90 THEN CCDiscount ELSE -1 * CCDiscount END),0) ,
			@CustomerCardPrivilege = @CustomerCardPrivilege1 + ISNULL(SUM(Case when ProcessID = 90 THEN CCPrivilege 
																		  ELSE (-1 * CCPrivilege) END),0)
	FROM inv.tblStorageDocsHdr 
	WHERE CCNo = @CustomerCardNo AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End >= Case When @IsTransfer = 'False' Then @FromDate Else '' End AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End <= Case When @IsTransfer = 'False' Then @ToDate Else '' End AND
		  (@intSerialNo = 0 OR SerialNo < @intSerialNo) AND
		  ProcessID IN(100) AND 
		  FiscalYear = @intFiscalYear 
		  
  	SELECT 	@BeforeCardDiscount= @BeforeCardDiscount + ISNULL(SUM(Case when ProcessID = 90 THEN CCDiscount ELSE -1 * CCDiscount END),0) ,
	@CustomerCardPrivilege = @CustomerCardPrivilege + ISNULL(SUM(Case when ProcessID = 90 THEN CCPrivilege 
																		  ELSE (-1 * CCPrivilege) END),0)
	FROM inv.tblStorageDocsHdr 
	WHERE CCNo = @CustomerCardNo AND
		  DocDate>=@FromDate AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End >= Case When @IsTransfer = 'False' Then @FromDate Else '' End AND
		  Case When @IsTransfer = 'False' Then DocDate Else '' End <= Case When @IsTransfer = 'False' Then @ToDate Else '' End AND 
		  FiscalYear = @intFiscalYear 
END

	-- ========================= Get DefaultPrivilege
	If @IsTransfer = 'False'
		SELECT TOP 1 @CustomerCardPrivilege = @CustomerCardPrivilege + ISNULL(DefaultPrivilege ,0)
		From lyl.tblCustomerInfo
		WHERE DefaultPrivilegeDate <= @Date AND DefaultPrivilegeDate >= @FromDate AND DefaultPrivilegeDate<= @ToDate AND
			  CustomerInfoID = SUBSTRING(@CustomerInfoID,1,LEN(CustomerInfoID))
		Order By LEN (CustomerInfoID) desc
	Else
		SELECT TOP 1 @CustomerCardPrivilege = @CustomerCardPrivilege + ISNULL(DefaultPrivilege ,0)
		From lyl.tblCustomerInfo
		WHERE CustomerInfoID = SUBSTRING(@CustomerInfoID,1,LEN(CustomerInfoID))
		Order By LEN (CustomerInfoID) desc			

	DECLARE @CurrentDiscount FLOAT
	set @CurrentDiscount=0 
	IF @CustomerCardPrivilege >= @ForEachScore AND @DiscountAmount>0
		BEGIN

			SET @CurrentDiscount = @CustomerCardPrivilege * @DiscountAmount / @ForEachScore
			SET @CurrentDiscount = @CurrentDiscount-@BeforeCardDiscount
			SET @CurrentDiscount = ISNULL(FLOOR(@CurrentDiscount/@DiscountAmount)*@DiscountAmount,0)
		END
		
	IF @IsView = 'False'	
	Begin
		UPDATE inv.tblStorageDocsHdr
		SET CCDiscount =ROUND(@CurrentDiscount,0),CCPrivilege=ROUND(@CustomerCardPrivilege1,0)
		WHERE SerialNo=@intSerialNo AND
		  ProcessID=@intProcessID AND 
		  FiscalYear=@intFiscalYear AND
		  ProcessNo=@intProcessNo
	END		  
	
	SELECT IsNull(ROUND(@CustomerCardPrivilege1,0),0) Privilege, IsNull(@CustomerCardPrivilege - @UsedPrivilege,0) TotalPrivilege,
	       ISNULL(((@CustomerCardPrivilege - @UsedPrivilege) / @ForEachScoreM) * @DiscountAmountM, 0) DiscountRemain,
	       IsNull(@CurrentDiscount,0) CurrentDiscount
END
GO
