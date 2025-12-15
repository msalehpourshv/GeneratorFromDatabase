USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1395/09/08
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
--Select [sal].[funSaleReturn_Price1] (90, 1, 95, 1, 1, '1395/09/09', '1395/09/11', '', '', 1, 1)
--Select [sal].[funSaleReturn_Price1] (90, 1, 95, 1, 1, '1395/09/09', '1395/09/11', '', '', 1, 2)
--Select [sal].[funSaleReturn_Price1] (90, 1, 95, 1, 1, '1395/09/09', '1395/09/11', '', '', 1, 3)
--Select [sal].[funSaleReturn_Price1] (90, 1, 95, 1, 1, '1395/09/09', '1395/09/11', '', '', 1, 4)
--Select [sal].[funSaleReturn_Price1] (90, 1, 95, 1, 1, '1395/09/09', '1395/09/11', '', '', 1, 5)
--Select [sal].[funSaleReturn_Price1] (90, 1, 95, 1, 1, '1395/09/09', '1395/09/11', '', '', 1, 6)
--Select [sal].[funSaleReturn_Price1] (90, 1, 95, 1, 1, '1395/09/09', '1395/09/11', '', '', 1, 7)
CREATE FUNCTION [sal].[funSaleReturn_Price1]
(
	@ProcessID			Int = 90,
	@ProcessNo			Int = 1,
	@FiscalYear			Int = Null,
	@SerialNo			Int = Null,
	@DocRowNo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@VisitorAcntCode  	Varchar(20),
	@GoodsID  			Varchar(20),
	@DeductDiscount		Bit,
	@RetType			SmallInt
)
RETURNS DECIMAL(28,9)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS DECIMAL(28,9)
	SET @Result = 0
	
--SELECT A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.DocRowNo, A.GoodsID,
--	   A.SalePrice, A.SameDateRetPrice, A.AfterSale_RetPrice,
--	   A.SalePrice - A.SameDateRetPrice - A.AfterSale_RetPrice NetSalePrice

-- =======================================================
IF @RetType = 1 -- NetSales

	SELECT @Result = Case When @DeductDiscount = 0 Then A.SalePrice - A.SameDateRetPrice - A.AfterSale_RetPrice - A.AfterSale_RetPrice2 
					 Else (A.SalePrice - A.SameDateRetPrice - A.AfterSale_RetPrice - A.AfterSale_RetPrice2) - A.SaleDiscountDtl End
	FROM(
		Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
			   (IsNull(SD.GoodsQuantity,0)   * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
			   (IsNull(Ret1.GoodsQuantity,0) * IsNull(Ret1.GoodsPrice,0)) SameDateRetPrice, IsNull(Ret1.DiscountDtl,0) SameDateRetDiscountDtl, IsNull(Ret1.TotalLineDiscount,0) SameDateRetDiscount, 
			   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount,
			   (IsNull(Ret3.GoodsQuantity,0) * IsNull(Ret3.GoodsPrice,0)) AfterSale_RetPrice2, IsNull(Ret3.DiscountDtl,0) AfterSale_RetDiscountDtl2, IsNull(Ret3.TotalLineDiscount,0) AfterSale_RetDiscount2,
			   (IsNull(SD.GoodsQuantity,0)   - IsNull(Ret1.GoodsQuantity,0) - IsNull(Ret2.GoodsQuantity,0)) NetSaleQty
			   	   
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
											   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
		-- SameDateRets
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo
		) Ret1 ON	Ret1.BaseProcessID  = SD.ProcessID  And Ret1.BaseProcessNo = SD.ProcessNo And
					Ret1.BaseFiscalYear = SD.FiscalYear And Ret1.BaseSerialNo  = SD.SerialNo And 
					Ret1.BaseDocRowNo   = SD.DocRowNo   And Ret1.DocDate = SD.DocDate And 
					((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret1.VisitorAcntCode Is Not Null) AND 
					 (Ret1.VisitorAcntCode <> '') And (((Ret1.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret1.GoodsID = @GoodsID)
					
		-- AfteSale_Rets
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo  
		) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
					Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
					Ret2.BaseDocRowNo   = SD.DocRowNo   And Ret2.DocDate > SD.DocDate And
					(@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret2.DocDate <= @DocDateTo) And 
					((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret2.VisitorAcntCode Is Not Null) AND 
					 (Ret2.VisitorAcntCode <> '') And (((Ret2.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret2.GoodsID = @GoodsID)
					
		-- AfteSale_Rets No Limit
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo  
		) Ret3 ON	Ret3.BaseProcessID  = SD.ProcessID  And Ret3.BaseProcessNo = SD.ProcessNo And
					Ret3.BaseFiscalYear = SD.FiscalYear And Ret3.BaseSerialNo  = SD.SerialNo And 
					Ret3.BaseDocRowNo   = SD.DocRowNo   And (@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret3.DocDate > @DocDateTo) And 
					((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret3.VisitorAcntCode Is Not Null) AND 
					 (Ret3.VisitorAcntCode <> '') And (((Ret3.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret3.GoodsID = @GoodsID)					
					
		-- NoBaseDoc_Rets
		--Left Join inv.tblStorageDocsDtl Ret3 ON Ret3.GoodsID = SD.GoodsID
		Where SD.ProcessID = @ProcessID And SD.ProcessNo = @ProcessNo And SD.FiscalYear = @FiscalYear And SD.SerialNo = @SerialNo And 
			  SD.DocRowNo = @DocRowNo And (@DocDateFr = '' OR @DocDateFr = '@@@' OR SD.DocDate >= @DocDateFr) And 
			  (@DocDateTo = '' OR @DocDateTo = '@@@' OR SD.DocDate <= @DocDateTo) And 
			  ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (SH.VisitorAcntCode Is Not Null) AND 
			   (SH.VisitorAcntCode <> '') And (((SH.VisitorAcntCode = @VisitorAcntCode)))) AND
			  (@GoodsID Is Null OR @GoodsID = '' OR SD.GoodsID = @GoodsID)
	) A

-- ********************
ELSE IF @RetType = 2 -- SameDate_Rets

	SELECT @Result = ISNULL(SUM(Case When @DeductDiscount = 0 Then A.SameDateRetPrice Else A.SameDateRetPrice - A.SameDateRetDiscountDtl End),0)
	FROM(
		Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
			   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
			   (IsNull(Ret1.GoodsQuantity,0) * IsNull(Ret1.GoodsPrice,0)) SameDateRetPrice, IsNull(Ret1.DiscountDtl,0) SameDateRetDiscountDtl, IsNull(Ret1.TotalLineDiscount,0) SameDateRetDiscount
			   	   
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
											   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
		-- SameDateRets
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo  
		) Ret1 ON	Ret1.BaseProcessID  = SD.ProcessID  And Ret1.BaseProcessNo = SD.ProcessNo And
					Ret1.BaseFiscalYear = SD.FiscalYear And Ret1.BaseSerialNo  = SD.SerialNo And 
					Ret1.BaseDocRowNo   = SD.DocRowNo   And (@DocDateFr = '' OR @DocDateFr = '@@@' OR Ret1.DocDate >= @DocDateFr) And 
					(@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret1.DocDate <= @DocDateTo) And 
					((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret1.VisitorAcntCode Is Not Null) AND 
					 (Ret1.VisitorAcntCode <> '') And (((Ret1.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret1.GoodsID = @GoodsID)

		Where SD.ProcessID = @ProcessID And SD.ProcessNo = @ProcessNo And SD.FiscalYear = @FiscalYear And SD.SerialNo = @SerialNo And 
			  SD.DocRowNo = @DocRowNo And (@DocDateFr = '' OR @DocDateFr = '@@@' OR SD.DocDate >= @DocDateFr) And 
			  (@DocDateTo = '' OR @DocDateTo = '@@@' OR SD.DocDate <= @DocDateTo) And 
			  ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (SH.VisitorAcntCode Is Not Null) AND 
			   (SH.VisitorAcntCode <> '') And (((SH.VisitorAcntCode = @VisitorAcntCode)))) AND
			  (@GoodsID Is Null OR @GoodsID = '' OR SD.GoodsID = @GoodsID)
	) A
	
-- ********************
ELSE IF @RetType = 3 -- AfterSale_Rets

	SELECT @Result = Case When @DeductDiscount = 0 Then A.AfterSale_RetPrice Else A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl End
	FROM(
		Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
			   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
			   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount
			   	   
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
											   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
		-- AfteSale_Rets
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo
		) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
					Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
					Ret2.BaseDocRowNo   = SD.DocRowNo   And Ret2.DocDate > SD.DocDate And
					(@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret2.DocDate <= @DocDateTo) And 
					((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret2.VisitorAcntCode Is Not Null) AND 
					(Ret2.VisitorAcntCode <> '') And (((Ret2.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret2.GoodsID = @GoodsID)
					
		Where SD.ProcessID = @ProcessID And SD.ProcessNo = @ProcessNo And SD.FiscalYear = @FiscalYear And SD.SerialNo = @SerialNo And 
			  SD.DocRowNo = @DocRowNo And (@DocDateFr = '' OR @DocDateFr = '@@@' OR SD.DocDate >= @DocDateFr) And 
			  (@DocDateTo = '' OR @DocDateTo = '@@@' OR SD.DocDate <= @DocDateTo) And 
			  ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (SH.VisitorAcntCode Is Not Null) AND 
			   (SH.VisitorAcntCode <> '') And (((SH.VisitorAcntCode = @VisitorAcntCode)))) AND
			  (@GoodsID Is Null OR @GoodsID = '' OR SD.GoodsID = @GoodsID)
	) A
	
-- ********************
ELSE IF @RetType = 4 -- AfterSale_Rets No Limit

	SELECT @Result = Case When @DeductDiscount = 0 Then A.AfterSale_RetPrice Else A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl End
	FROM(
		Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
			   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
			   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount
			   	   
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
											   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo  
		) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
					Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
					Ret2.BaseDocRowNo   = SD.DocRowNo   And (@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret2.DocDate > @DocDateTo) And 
				    ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret2.VisitorAcntCode Is Not Null) AND 
				     (Ret2.VisitorAcntCode <> '') And (((Ret2.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret2.GoodsID = @GoodsID)
					
		Where SD.ProcessID = @ProcessID And SD.ProcessNo = @ProcessNo And SD.FiscalYear = @FiscalYear And SD.SerialNo = @SerialNo And 
			  SD.DocRowNo = @DocRowNo And (@DocDateFr = '' OR @DocDateFr = '@@@' OR SD.DocDate >= @DocDateFr) And 
			  (@DocDateTo = '' OR @DocDateTo = '@@@' OR SD.DocDate <= @DocDateTo) And 
			  ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (SH.VisitorAcntCode Is Not Null) AND 
			   (SH.VisitorAcntCode <> '') And (((SH.VisitorAcntCode = @VisitorAcntCode)))) AND
			  (@GoodsID Is Null OR @GoodsID = '' OR SD.GoodsID = @GoodsID)
	) A
	
-- ********************
ELSE IF @RetType = 5 -- SaleRets_Sum

	SELECT @Result = Case When @DeductDiscount = 0 Then A.SameDateRetPrice + A.AfterSale_RetPrice 
					 Else (A.AfterSale_RetPrice - A.AfterSale_RetDiscountDtl) + (A.SameDateRetPrice - A.SameDateRetDiscountDtl) +
					      (A.AfterSale_RetPrice2 - A.AfterSale_RetDiscountDtl2)
					 End
	FROM(
		Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, 
			   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) SalePrice, IsNull(SD.DiscountDtl,0) SaleDiscountDtl, IsNull(SH.TotalLineDiscount,0) SaleDiscount,
			   (IsNull(Ret1.GoodsQuantity,0) * IsNull(Ret1.GoodsPrice,0)) SameDateRetPrice, IsNull(Ret1.DiscountDtl,0) SameDateRetDiscountDtl, IsNull(Ret1.TotalLineDiscount,0) SameDateRetDiscount, 
			   (IsNull(Ret2.GoodsQuantity,0) * IsNull(Ret2.GoodsPrice,0)) AfterSale_RetPrice, IsNull(Ret2.DiscountDtl,0) AfterSale_RetDiscountDtl, IsNull(Ret2.TotalLineDiscount,0) AfterSale_RetDiscount,
			   (IsNull(Ret3.GoodsQuantity,0) * IsNull(Ret3.GoodsPrice,0)) AfterSale_RetPrice2, IsNull(Ret3.DiscountDtl,0) AfterSale_RetDiscountDtl2, IsNull(Ret3.TotalLineDiscount,0) AfterSale_RetDiscount2,
			   (IsNull(SD.GoodsQuantity,0)  - IsNull(Ret1.GoodsQuantity,0) - IsNull(Ret2.GoodsQuantity,0)) NetSaleQty
			   	   
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
											   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 
		-- SameDateRets
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo  
		) Ret1 ON	Ret1.BaseProcessID  = SD.ProcessID  And Ret1.BaseProcessNo = SD.ProcessNo And
					Ret1.BaseFiscalYear = SD.FiscalYear And Ret1.BaseSerialNo  = SD.SerialNo And 
					Ret1.BaseDocRowNo   = SD.DocRowNo   And (@DocDateFr = '' OR @DocDateFr = '@@@' OR 
					Ret1.DocDate >= @DocDateFr) And 
					(@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret1.DocDate <= @DocDateTo) And 
				    ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret1.VisitorAcntCode Is Not Null) AND 
				     (Ret1.VisitorAcntCode <> '') And (((Ret1.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret1.GoodsID = @GoodsID)
		-- AfteSale_Rets
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo  
		) Ret2 ON	Ret2.BaseProcessID  = SD.ProcessID  And Ret2.BaseProcessNo = SD.ProcessNo And
					Ret2.BaseFiscalYear = SD.FiscalYear And Ret2.BaseSerialNo  = SD.SerialNo And 
					Ret2.BaseDocRowNo   = SD.DocRowNo   And Ret2.DocDate > SD.DocDate And
					(@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret2.DocDate <= @DocDateTo) And 
				    ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret2.VisitorAcntCode Is Not Null) AND 
				     (Ret2.VisitorAcntCode <> '') And (((Ret2.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret2.GoodsID = @GoodsID)
		-- AfteSale_Rets No Limit
		Left Join
		(
		 Select RD1.*, RH1.TotalLineDiscount 
		 From inv.tblStorageDocsDtl RD1 
		 Inner Join inv.tblStorageDocsHdr RH1 ON RH1.ProcessID  = RD1.ProcessID  And RH1.ProcessNo = RD1.ProcessNo And
												 RH1.FiscalYear = RD1.FiscalYear And RH1.SerialNo  = RD1.SerialNo
		 Where RD1.ProcessID = 100 And RD1.ProcessNo = @ProcessNo  
		) Ret3 ON	Ret3.BaseProcessID  = SD.ProcessID  And Ret3.BaseProcessNo = SD.ProcessNo And
					Ret3.BaseFiscalYear = SD.FiscalYear And Ret3.BaseSerialNo  = SD.SerialNo And 
					Ret3.BaseDocRowNo   = SD.DocRowNo   And (@DocDateTo = '' OR @DocDateTo = '@@@' OR Ret3.DocDate > @DocDateTo) And 
				    ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (Ret3.VisitorAcntCode Is Not Null) AND 
				     (Ret3.VisitorAcntCode <> '') And (((Ret3.VisitorAcntCode = @VisitorAcntCode)))) AND
					(@GoodsID Is Null OR @GoodsID = '' OR Ret3.GoodsID = @GoodsID)
					
		-- NoBaseDoc_Rets
		--Left Join inv.tblStorageDocsDtl Ret3 ON Ret3.GoodsID = SD.GoodsID
		Where SD.ProcessID = @ProcessID And SD.ProcessNo = @ProcessNo And SD.FiscalYear = @FiscalYear And SD.SerialNo = @SerialNo And 
			  SD.DocRowNo = @DocRowNo And (@DocDateFr = '' OR @DocDateFr = '@@@' OR SD.DocDate >= @DocDateFr) And 
			  (@DocDateTo = '' OR @DocDateTo = '@@@' OR SD.DocDate <= @DocDateTo) And 
			  ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (SH.VisitorAcntCode Is Not Null) AND 
			   (SH.VisitorAcntCode <> '') And (((SH.VisitorAcntCode = @VisitorAcntCode)))) AND
			  (@GoodsID Is Null OR @GoodsID = '' OR SD.GoodsID = @GoodsID)
	) A

-- ********************
ELSE IF @RetType = 6 -- WithoutBaseDoc_Rets

	SELECT @Result = ISNULL(SUM(Case When @DeductDiscount = 0 Then A.RetPrice Else A.RetPrice - A.RetDiscountDtl End),0)
	FROM
	(
		Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID,
			   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) RetPrice, IsNull(SD.DiscountDtl,0) RetDiscountDtl, 
			    IsNull(SH.TotalLineDiscount,0) RetDiscount
			   
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
											   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo 	
											   
		Where SD.ProcessID = 100 And SD.ProcessNo = @ProcessNo And (
			 (SD.BaseProcessID = 0 And SD.BaseProcessNo = 0 And SD.BaseFiscalYear = 0 And SD.BaseSerialNo = 0) OR 
			  SD.BaseFiscalYear < @FiscalYear OR 
			 (SD.BaseProcessID = @ProcessID AND SD.BaseProcessNo = @ProcessNo AND 
			  SD.BaseFiscalYear = @FiscalYear  AND SD.BaseDocRowNo = 0))And  
			 (@DocDateFr = '' OR @DocDateFr = '@@@' OR SD.DocDate >= @DocDateFr) And 
			 (@DocDateTo = '' OR @DocDateTo = '@@@' OR SD.DocDate <= @DocDateTo) And 
			 ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (SH.VisitorAcntCode Is Not Null) AND 
			  (SH.VisitorAcntCode <> '') And (((SH.VisitorAcntCode = @VisitorAcntCode)))) AND
			 (@GoodsID Is Null OR @GoodsID = '' OR SD.GoodsID = @GoodsID)
	) A

-- ********************
ELSE IF @RetType = 7 -- Rets With Before Date Sale
	
	SELECT @Result = ISNULL(SUM(Case When @DeductDiscount = 0 Then A.RetPrice Else A.RetPrice - A.RetDiscountDtl End),0)
	FROM
	(
		Select SD.ProcessID, SD.ProcessNo, SD.FiscalYear, SD.SerialNo, SD.DocRowNo, SD.GoodsID, SD.BaseDocDate,
			   (IsNull(SD.GoodsQuantity,0) * IsNull(SD.GoodsPrice,0)) RetPrice, IsNull(SD.DiscountDtl,0) RetDiscountDtl, 
			    IsNull(SH.TotalLineDiscount,0) RetDiscount
			   
		From inv.tblStorageDocsDtl SD
		Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID  = SD.ProcessID  And SH.ProcessNo = SD.ProcessNo And
											   SH.FiscalYear = SD.FiscalYear And SH.SerialNo  = SD.SerialNo
		
		Inner Join inv.tblStorageDocsHdr Sale ON Sale.ProcessID = SD.BaseProcessID And Sale.ProcessNo = SD.BaseProcessNo And
												 Sale.FiscalYear = SD.BaseFiscalYear And Sale.SerialNo = SD.BaseSerialNo And
												 Sale.DocDate < @DocDateFr
											   
		Where SD.ProcessID = 100 And SD.ProcessNo = @ProcessNo And SD.BaseProcessID <> 0 And SD.BaseProcessNo <> 0 And 
			  SD.BaseFiscalYear <> 0 And SD.BaseSerialNo <> 0 And 
			 (@DocDateFr = '' OR @DocDateFr = '@@@' OR SD.DocDate >= @DocDateFr) And 
			 (@DocDateTo = '' OR @DocDateTo = '@@@' OR SD.DocDate <= @DocDateTo) And 
			 ((@VisitorAcntCode = '' OR @VisitorAcntCode Is Null) OR (SH.VisitorAcntCode Is Not Null) AND 
			  (SH.VisitorAcntCode <> '') And (((SH.VisitorAcntCode = @VisitorAcntCode)))) AND
			 (@GoodsID Is Null OR @GoodsID = '' OR SD.GoodsID = @GoodsID) 
	) A	

-- =======================================================
	RETURN @Result
	
END
GO
