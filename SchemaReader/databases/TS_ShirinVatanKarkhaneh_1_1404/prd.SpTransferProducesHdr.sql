USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Zia
-- Create date   : 1391/01/24
-- Viewed By	 : 
-- Last Modified : 1391/01/24
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست حواله های ارسال
-- =============================================
Create PROCEDURE [prd].[SpTransferProducesHdr]
	@WithBatchNo	Bit = 0

WITH ENCRYPTION
AS 

DECLARE @Factor	int;

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------

	--=======
	Declare @DecreasePrdQtyByPrdSendRet AS bit
	SELECT @DecreasePrdQtyByPrdSendRet = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DecreasePrdQtyByPrdSendRet'
	
	--=======
	begin try
		drop table #tbl_SpTransferProducesHdr_Info
		drop table #tbl_SpTransferProducesHdr_Result
	end try
	begin catch
	end catch
	
	create table #tbl_SpTransferProducesHdr_Info
	(
		ProcessID int not null,
		ProcessNo int not null,
		FiscalYear int not null,
		SerialNo int not null,  
		BatchNo	nvarchar(20)  collate arabic_cs_as
	) 

	-- Send Docs (70)
	if (@WithBatchNo = 0)
	BEGIN
		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,''
		from	inv.tblStorageDocsHdr H
		where	(ProcessID = 70) AND
				(H.ProductCount - IsNull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where	D.ProcessID=80 
							and D.BaseProcessID=70 
							and D.BaseProcessNo=H.ProcessNo
							and D.BaseFiscalYear=H.FiscalYear
							and D.BaseSerialNo=H.SerialNo
							and D.GoodsID=H.ProductID
					),0)) - Case When @DecreasePrdQtyByPrdSendRet = 1 Then [prd].[funMaxRetProduct](ProcessID, ProcessNo, FiscalYear, SerialNo,1)  Else 0 end > 0.1

		-- Receive Docs (80)
		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesHdr_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where	(D.ProcessID = 80) and (H.ProcessID = 70)

		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesHdr_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where	(D.ProcessID = 75) and (H.ProcessID = 70)
	END
	else
	BEGIN
		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 1 AND (ProcessID = 70) AND
				(H.ProductCount - IsNull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where D.ProcessID=80 and D.BatchNo = H.BatchNo
					),0)) - Case When @DecreasePrdQtyByPrdSendRet = 1 Then [prd].[funMaxRetProduct](ProcessID, ProcessNo, FiscalYear, SerialNo,1)  Else 0 end > 0.1

		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 1 AND (ProcessID = 70) AND
				(H.BatchNo NOT IN(
						select BatchNo
						from inv.tblStorageDocsDtl D
						where D.ProcessID=80))
					
		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 1 AND (ProcessID = 80) AND
				(H.BatchNo IN (
						select BatchNo
						from #tbl_SpTransferProducesHdr_Info D
						where D.ProcessID=70))

		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 1 AND (ProcessID = 75) AND
				(H.BatchNo IN (
						select BatchNo
						from #tbl_SpTransferProducesHdr_Info D
						where D.ProcessID=70))

		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,''
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 2 AND (ProcessID = 70) AND
				(H.ProductCount - IsNull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where	D.ProcessID=80 
							and D.BaseProcessID=70 
							and D.BaseProcessNo=H.ProcessNo
							and D.BaseFiscalYear=H.FiscalYear
							and D.BaseSerialNo=H.SerialNo
							and D.GoodsID=H.ProductID
					),0)) - Case When @DecreasePrdQtyByPrdSendRet = 1 Then [prd].[funMaxRetProduct](ProcessID, ProcessNo, FiscalYear, SerialNo,1)  Else 0 end > 0.1

		-- Receive Docs (80)
		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesHdr_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where 	D.ProcessNo = 2 AND H.ProcessNo = 2 AND (D.ProcessID = 80) and (H.ProcessID = 70)

		insert into #tbl_SpTransferProducesHdr_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesHdr_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where	D.ProcessNo = 2 AND H.ProcessNo = 2 AND (D.ProcessID = 75) and (H.ProcessID = 70)

	END

	
	-- S E L E C T ------------------------------------------------------------
	SELECT * FROM 
	(
		SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.FormulaNo, H.DocStep, H.DocDate, H.StoreID, H.StoreID2, H.AcntCode, 
			   H.VisitorAcntCode, H.OrderAcntCode, H.CurrencyTypeID, H.CurrencyRate, H.Amount, H.DiscountPercent, H.Discount, H.Discount2+H.Discount3 Discount2,  
			   H.TotalLineDiscount, H.BaseProcessID, H.BaseProcessNo, H.BaseFiscalYear, H.BaseSerialNo, H.BaseDocType, H.VchNo, H.DocDesc, 
			   H.ProductCount, 
			   --Case When @DecreasePrdQtyByPrdSendRet = 1 Then IsNull([prd].[FunGetProductSendRemain] (H.ProcessNo, H.SerialNo), 0) Else H.ProductCount End As ProductCount,
			   H.WageRate, H.ProductID, H.AgreeNo, H.RecID, H.SessionNo, H.SaleTypeID, H.TransporterID, H.LocationID,
			   H.TransportationCost, H.PackingCost, H.TaxCost, H.VisitorCostAcntCode, H.VisitorPercent, H.VisitorCost, H.DiscountAcntCode, 
			   H.EarnestMoney, H.EarnestMoneyPercent, H.EarnestMoneyAcntCode, H.BatchNo, H.TransportationCostAcntCode, H.Price, H.TaxOverWorthCost, 
			   H.VchNo2, H.IsConfirmed, H.SettlementDate, H.TransportationIncomeAcntCode, H.TransportationIncome, H.OtherCostAcntCode, 
			   H.OtherIncomeAcntCode, H.OtherCost, H.OtherIncome, H.DocDate2, H.DocDate3, H.DocDate4, H.AfterSaleDiscount, H.AfterSaleDesc, 
			   H.AfterSaleVchNo, H.AfterSaleDate, H.OldSerialNo, H.HardRecivable, H.IsAutoDoc, H.AfterSaleDiscountAcntCode, H.VchDate, 
			   H.SessionNo2, H.SessionNo3, H.SessionNo4, H.SessionNo5, H.TollOverWorthCost, H.DriverID, H.DistributerID1, H.DistributerID2, 
			   H.BaseDistributionProcessID, H.BaseDistributionProcessNo, H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo, H.DestinationAddress, 
			   H.BaseSaleSerialNo, H.DistributeCostAcntCode, H.DistributeAcntCode, H.DistributePercent, H.DistributeAmount, H.OwnerDocNo, 
			   H.FixCostAcntCode, H.FixCost, H.ConfirmReceipt, H.TransporterID2, H.CashAmount, H.ChequeAmount, Address, H.CCNo, H.CCDiscount, 
			   H.CCPrivilege, H.SourceSerialNo, H.SourceProcessNo, H.DailyUsesBranchID, H.DiscountTaxOverWorth, H.ComssionCostPrice, 
			   H.BasculePrice, H.LaborPrice, H.TransportPrice, H.DailyUsesToDate, H.CostAcntCode, H.CostPercent, H.SgnSN1, H.SgnSN2, 
			   H.SgnSN3, H.SgnSN4, H.SgnSN5, H.IsSendInfo, H.IntTrnTypID, H.BankID, H.BankAmnt, H.AwardAmnt, H.TrnID, H.C1, H.C2, H.C3, 
			   H.C4, H.C5, H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12, H.IAToll, H.IATollCod, H.H, H.BSN, H.BRN, H.BankID2, H.BankAmnt2, H.CashID, H.CashAmnt, H.VisitorAcntCode2, 
			   H.VisitorCostAcntCode2, H.VisitorPercent2, H.VisitorCost2
		
		FROM inv.tblStorageDocsHdr H
		INNER JOIN #tbl_SpTransferProducesHdr_Info T on T.ProcessID = H.ProcessID and T.ProcessNo = H.ProcessNo and T.FiscalYear = H.FiscalYear and T.SerialNo = H.SerialNo
	) A
	WHERE ProductCount > 0 OR ProcessID = 75 OR ProcessID = 80
	order by ProcessID
	---------------------------------------------------------------------------
END
GO
