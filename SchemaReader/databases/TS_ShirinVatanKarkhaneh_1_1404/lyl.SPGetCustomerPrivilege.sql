USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--EXEC [lyl].[SPGetCustomerPrivilege] 90, 1, 95, 0, '', '0003772367', ''
CREATE PROCEDURE [lyl].[SPGetCustomerPrivilege]
(
	@ProcessID		Int = 90,
	@ProcessNo		Int,
	@FiscalYear		Int,
	@SerialNo		Int,
	@Date   		Varchar(20),
	@CustomerCardNo	VarChar(20) = '',
	@ExtraParams	NVarChar(200) = ''
)
WITH ENCRYPTION
AS

Begin -- ====================================================

	DECLARE @GoodsID VARCHAR(20)
	DECLARE @GoodsID1 VARCHAR
	DECLARE @GoodsQuantity DECIMAL(28,9)
	DECLARE @GoodsPrice DECIMAL(28,9)
	DECLARE @DiscountDtl DECIMAL(28,9)
	DECLARE @TaxOverWorthCostDtl DECIMAL(28,9)
	DECLARE @TollOverWorthCostDtl DECIMAL(28,9)
	DECLARE @CustomerInfoID VARCHAR(20)
	DECLARE @ForEachRials FLOAT  
	DECLARE @Score FLOAT
	DECLARE @EnterKind INT
	DECLARE @BeforeCardDiscount		 DECIMAL(28,9)
	DECLARE @CustomerCardPrivilege1  DECIMAL(28,9)
	DECLARE @CustomerCardPrivilegeR1 DECIMAL(28,9)

	DECLARE @EnterKindR				INT
	DECLARE @GoodsQuantityR 		DECIMAL(28,9)
	DECLARE @GoodsPriceR			DECIMAL(28,9)
	DECLARE @DiscountDtlR			DECIMAL(28,9)
	DECLARE @TaxOverWorthCostDtlR	DECIMAL(28,9)
	DECLARE @TollOverWorthCostDtlR	DECIMAL(28,9)

	SET @BeforeCardDiscount = 0
	SET @CustomerCardPrivilege1 = 0
	SET @CustomerCardPrivilegeR1 = 0
	
	CREATE TABLE #tmpTable
	(
		GoodsGroup       Varchar(20),
		TotalGoodsPrice  FLOAT,
		TotalGoodsPriceR FLOAT,
		ForEachRials	 FLOAT,
		Score		     FLOAT,
	)
	
	-- ==========
	SELECT TOP 1 @CustomerInfoID = CustomerInfoID
	from 	lyl.tblLoyalCardDtl
	WHERE IsActive ='True' AND LoyalCardNo = @CustomerCardNo
	order by DocDate desc
		
	-- ==========
	DECLARE	Cursor_SaleOrderDtl CURSOR For 
	SELECT	s.EnterKind, s.GoodsID, s.GoodsQuantity, s.GoodsPrice, s.DiscountDtl, s.TaxOverWorthCostDtl, s.TollOverWorthCostDtl,
			IsNull(R.EnterKind,0) EnterKindR, IsNull(R.GoodsQuantity,0) GoodsQuantityR, IsNull(R.GoodsPrice,0) GoodsPriceR, 
			IsNull(R.DiscountDtl,0) DiscountDtlR, IsNull(R.TaxOverWorthCostDtl,0) TaxOverWorthCostDtlR, IsNull(R.TollOverWorthCostDtl,0) TollOverWorthCostDtlR
	FROM inv.tblStorageDocsDtl s
	LEFT JOIN inv.tblStorageDocsDtl R ON s.ProcessID  = R.BaseProcessID  And s.ProcessNo = R.BaseProcessNo And 
										 s.FiscalYear = R.BaseFiscalYear And s.SerialNo  = R.BaseSerialNo And
										 s.DocRowNo = R.BaseDocRowNo
	LEFT JOIN inv.tblStorageDocsHdr h ON s.ProcessID  = h.ProcessID  And s.ProcessNo = h.ProcessNo And 
										 s.FiscalYear = h.FiscalYear And s.SerialNo  = h.SerialNo 

	WHERE (@SerialNo = 0 OR @SerialNo Is Null OR (s.SerialNo = @SerialNo)) AND
		  s.ProcessID  = @ProcessID AND
		  s.FiscalYear = @FiscalYear AND
		  s.ProcessNo  = @ProcessNo AND 
		  h.CCNo = @CustomerCardNo

	-- ==========
	Open  Cursor_SaleOrderDtl;
	Fetch NEXT From Cursor_SaleOrderDtl Into @EnterKind, @GoodsID, @GoodsQuantity, @GoodsPrice, @DiscountDtl, @TaxOverWorthCostDtl, @TollOverWorthCostDtl,
											 @EnterKindR, @GoodsQuantityR, @GoodsPriceR, @DiscountDtlR, @TaxOverWorthCostDtlR, @TollOverWorthCostDtlR
	While (@@Fetch_Status = 0)
	BEGIN
	
		SELECT TOP 1 @GoodsID1=d1.GoodsID, @ForEachRials=d1.ForEachRials, @Score=d1.Score
		FROM lyl.tblLoyalCarnivalInfoDtl1 d1
		INNER JOIN (SELECT * FROM lyl.tblLoyalCarnivalInfoHdr 
					WHERE CustomerInfoID = SUBSTRING(@CustomerInfoID,1,LEN(CustomerInfoID)) AND 
					(@Date = '' OR @Date Is Null OR (FromDate <= @Date AND ToDate >= @Date))) H
		ON H.SerialNo = d1.SerialNo
		WHERE d1.GoodsID <= SUBSTRING(@GoodsID,1,LEN(d1.GoodsID)) AND d1.GoodsIDTo >= SUBSTRING(@GoodsID,1,LEN(d1.GoodsIDTo))
		ORDER BY LEN(d1.GoodsID) Desc

		IF ((SELECT COUNT(*) FROM #tmpTable WHERE GoodsGroup = @GoodsID1)= 0)
			INSERT INTO #tmpTable 
			VALUES(@GoodsID1, 
				   (-1 * @EnterKind * @GoodsQuantity*@GoodsPrice-(@DiscountDtl+@TaxOverWorthCostDtl+@TollOverWorthCostDtl)), 
				   (1 * @EnterKindR * @GoodsQuantityR*@GoodsPriceR-(@DiscountDtlR+@TaxOverWorthCostDtlR+@TollOverWorthCostDtlR)),
				   @ForEachRials, @Score)
		ELSE	
			UPDATE #tmpTable
			SET TotalGoodsPrice = TotalGoodsPrice + (-1 * @EnterKind * (@GoodsQuantity*@GoodsPrice-(@DiscountDtl+@TaxOverWorthCostDtl+@TollOverWorthCostDtl))),
				TotalGoodsPriceR = TotalGoodsPriceR + (1 * @EnterKindR * (@GoodsQuantityR*@GoodsPriceR-(@DiscountDtlR+@TaxOverWorthCostDtlR+@TollOverWorthCostDtlR)))
			WHERE GoodsGroup = @GoodsID1
			
		Fetch NEXT From Cursor_SaleOrderDtl Into @EnterKind, @GoodsID, @GoodsQuantity, @GoodsPrice, @DiscountDtl, @TaxOverWorthCostDtl, @TollOverWorthCostDtl,
												 @EnterKindR, @GoodsQuantityR, @GoodsPriceR, @DiscountDtlR, @TaxOverWorthCostDtlR, @TollOverWorthCostDtlR
	END
	
	Close Cursor_SaleOrderDtl;
	Deallocate Cursor_SaleOrderDtl;
	 
	-- ==========
	IF (SELECT COUNT(*) FROM lyl.tblLoyalCarnivalInfoDtl2 d2 WHERE d2.SpesialDate = @Date) = 1
	BEGIN
		DECLARE @ScoreCoefficient AS FLOAT
		
		SELECT @ScoreCoefficient=ScoreCoefficient FROM lyl.tblLoyalCarnivalInfoDtl2 d2 
		WHERE @Date = '' OR @Date Is Null OR d2.SpesialDate = @Date
		
		UPDATE #tmpTable SET Score = Score * @ScoreCoefficient
		 
	END 

	DECLARE @TotalGoodsPrice AS DECIMAL(28,9)
	DECLARE @TotalGoodsPriceR AS DECIMAL(28,9)
	
	SELECT @CustomerCardPrivilege1 =  ISNULL(FLOOR(SUM(TotalGoodsPrice*Score/ForEachRials)),0),
		   @CustomerCardPrivilegeR1 =  ISNULL(FLOOR(SUM(TotalGoodsPriceR*Score/ForEachRials)),0),
	       @TotalGoodsPrice = SUM(TotalGoodsPrice),
	       @TotalGoodsPriceR = SUM(TotalGoodsPriceR)
	FROM #tmpTable
	DROP TABLE #tmpTable
	
	Print 'DefaultPrivilege = ' + Str(@CustomerCardPrivilege1)
	Print 'DefaultPrivilegeR = ' + Str(@CustomerCardPrivilegeR1)
	
	--==================================
	--DECLARE @CustomerInfoID VARCHAR(20)
	DECLARE @CustomerName   NVARCHAR(200)
	
	SELECT TOP 1 @CustomerInfoID = CustomerInfoID
	FROM 	lyl.tblLoyalCardDtl
	WHERE IsActive ='True' AND LoyalCardNo = @CustomerCardNo
	order by DocDate desc
	
	Select @CustomerName = FirstName + ' ' + LastName
	From lyl.tblCustomerInfoDtl
	Where CustomerInfoID = @CustomerInfoID
	
	--==================================
	Declare @CustomerCardPrivilege AS Float
	SET @CustomerCardPrivilege = 0;

	Select @CustomerCardPrivilege = IsNull(Sum(H1.CCPrivilege), 0) - IsNull(Sum(H2.CCPrivilege), 0) 
		   --,H1.ProcessID, H1.SerialNo, H1.CCNo 
	From inv.tblStorageDocsHdr H1
	Left Join inv.tblStorageDocsHdr H2 ON H1.ProcessID = H2.BaseProcessID And H1.ProcessNo = H2.BaseProcessNo And 
										  H1.FiscalYear = H2.BaseFiscalYear And H1.SerialNo = H2.BaseSerialNo
	Where H1.ProcessID = @ProcessID And H1.ProcessNo = @ProcessNo And H1.FiscalYear = @FiscalYear And H1.CCNo = @CustomerCardNo
	Group By H1.ProcessID, H1.SerialNo, H1.CCNo
		
	--==================================
	DECLARE @FromDate CHAR(10)
	DECLARE @ToDate CHAR(10)
	DECLARE @DiscountPercent FLOAT
	DECLARE @DiscountAmount FLOAT
	DECLARE @ForEachScore FLOAT

	SELECT TOP 1 @DiscountPercent=DiscountPercent, @DiscountAmount=DiscountAmount,@ForEachScore=ForEachScore,
				 @FromDate=FromDate,@ToDate=ToDate
	FROM lyl.tblLoyalCarnivalInfoHdr
	WHERE CustomerInfoID = SUBSTRING(@CustomerInfoID,1,LEN(CustomerInfoID)) AND 
		  (@Date = '' OR @Date Is Null OR (FromDate <= @Date AND ToDate >= @Date))
	ORDER BY SerialNo DESC

	--====		
	Declare @NationalNumber 		AS Char(10)
	Declare @IDNumber				AS Char(10)
	Declare @BirthDate				AS Char(10)
	Declare @RegisterDate			AS Char(10)
	Declare @MobileNumber			AS Char(20)
	Declare @PhoneNumber			AS Char(20)
	Declare @LoyalTimeLimit 		AS Int
	Declare @DefaultPrivilegeDate	AS Char(10)
	Declare @DefaultPrivilege		AS Float
	
	SELECT TOP 1 @CustomerCardPrivilege = @CustomerCardPrivilege + ISNULL(DefaultPrivilege ,0), 
				 @NationalNumber = NationalNumber, @IDNumber = IDNumber, @BirthDate = BirthDate, @RegisterDate = RegisterDate, 
				 @MobileNumber = MobileNumber, @PhoneNumber = PhoneNumber, @LoyalTimeLimit = LoyalTimeLimit, 
				 @DefaultPrivilegeDate = DefaultPrivilegeDate, @DefaultPrivilege = ISNULL(DefaultPrivilege ,0)
				 
	From lyl.tblCustomerInfo
	WHERE (@Date = '' OR @Date Is Null OR (DefaultPrivilegeDate <= @Date)) AND DefaultPrivilegeDate >= @FromDate AND DefaultPrivilegeDate<= @ToDate AND
		  CustomerInfoID = SUBSTRING(@CustomerInfoID,1,LEN(CustomerInfoID))
	Order By LEN(CustomerInfoID) Desc	
	
	--==================================
	DECLARE @UsedPrivilege AS DECIMAL(28,9)
	DECLARE @UsedDiscount AS DECIMAL(28,9)
	DECLARE @DiscountAmountM AS DECIMAL(28,9)
	DECLARE @ForEachScoreM AS DECIMAL(28,9)

	SELECT  @UsedPrivilege = (CCDiscount * ForEachScore / DiscountAmount), @UsedDiscount = CCDiscount, 
			@DiscountAmountM = DiscountAmount, @ForEachScoreM = ForEachScore
	FROM 
		(
		 SELECT ISNULL(SUM(Case when ProcessID = @ProcessID THEN CCDiscount ELSE (-1 * CCDiscount) END),0) CCDiscount,
				(Select DiscountAmount From lyl.tblLoyalCarnivalInfoHdr
				 Where CustomerInfoID = SUBSTRING(@CustomerInfoID, 1, LEN(CustomerInfoID))) DiscountAmount,
				(Select ForEachScore From lyl.tblLoyalCarnivalInfoHdr
				 Where CustomerInfoID = SUBSTRING(@CustomerInfoID, 1, LEN(CustomerInfoID))) ForEachScore	    
			    
		 FROM inv.tblStorageDocsHdr H
		 WHERE CCNo = @CustomerCardNo AND
			   ProcessID IN(@ProcessID) AND 
			   FiscalYear = @FiscalYear
		) A	
		
	Print '@FromDate = ' + @FromDate
	Print '@ToDate = ' + @ToDate
	Print '@CustomerInfoID = ' + @CustomerInfoID
	Print '@DiscountAmount = ' + Str(@DiscountAmount)
	Print '@ForEachScore = ' + Str(@ForEachScore)
	Print '@BeforeCardDiscount = ' + Str(@BeforeCardDiscount)
			
	--==================================
	DECLARE @CurrentDiscount FLOAT
	DECLARE @CurrentDiscountR FLOAT
	set @CurrentDiscount = 0 
	set @CurrentDiscountR = 0 
	
	IF @CustomerCardPrivilege1 >= @ForEachScore AND @DiscountAmount>0
		BEGIN

			SET @CurrentDiscount = @CustomerCardPrivilege1 * @DiscountAmount / @ForEachScore
			SET @CurrentDiscount = @CurrentDiscount-@BeforeCardDiscount
			SET @CurrentDiscount = ISNULL((@CurrentDiscount/@DiscountAmount)* @DiscountAmount,0)
			
			SET @CurrentDiscountR = @CustomerCardPrivilegeR1 * @DiscountAmount / @ForEachScore
			SET @CurrentDiscountR = @CurrentDiscountR-@BeforeCardDiscount
			SET @CurrentDiscountR = ISNULL((@CurrentDiscountR/@DiscountAmount)* @DiscountAmount,0)
						
		END
			
	Print '@CurrentDiscount = ' + Str(@CurrentDiscount)
	Print '@CurrentDiscountR = ' + Str(@CurrentDiscountR)
	Print '@DiscountAmount = ' + Str(@DiscountAmount)
						
	----==================================
	SELECT IsNull(@CustomerInfoID,0) CustomerInfoID, IsNull(@CustomerName,0) CustomerName, @NationalNumber NationalNumber,
		   @IDNumber IDNumber, @BirthDate BirthDate, @RegisterDate RegisterDate, @MobileNumber MobileNumber, 
		   @PhoneNumber PhoneNumber, @LoyalTimeLimit LoyalTimeLimit, @DefaultPrivilegeDate DefaultPrivilegeDate,
		   IsNull(@DefaultPrivilege,0) DefaultPrivilege, IsNull(ROUND(@CustomerCardPrivilege1,0),0) CurrentSalePrivilege,
		   IsNull(ROUND(@CustomerCardPrivilegeR1,0),0) CurrentSalePrivilegeRet, ROUND(@CurrentDiscount,0) CurrentSaleDiscount,
		   ROUND(@CurrentDiscountR,0) CurrentSaleDiscountRet, IsNull(@CustomerCardPrivilege,0) TotalPrivilege, 
		   IsNull(@UsedPrivilege,0) UsedPrivilege, IsNull(@CustomerCardPrivilege - @UsedPrivilege,0) PrivilegeRemain, 
		   IsNull(@UsedDiscount,0) UsedDiscount, IsNull(((@CustomerCardPrivilege - @UsedPrivilege) / @ForEachScoreM) * @DiscountAmountM, 0) DiscountRemain
END
GO
