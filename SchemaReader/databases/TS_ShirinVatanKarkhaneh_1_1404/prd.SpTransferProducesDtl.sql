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
Create PROCEDURE [prd].[SpTransferProducesDtl]
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
		drop table #tbl_SpTransferProducesDtl_Info
		drop table #tbl_SpTransferProducesDtl_Result
	end try
	begin catch
	end catch
	
	create table #tbl_SpTransferProducesDtl_Info
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
		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,''
		from	inv.tblStorageDocsHdr H
		where	(ProcessID = 70) AND
				(H.ProductCount - isnull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where	D.ProcessID=80 
							and D.BaseProcessID=70 
							and D.BaseProcessNo=H.ProcessNo
							and D.BaseFiscalYear=H.FiscalYear
							and D.BaseSerialNo=H.SerialNo
							and D.GoodsID=H.ProductID
					),0)) - Case When @DecreasePrdQtyByPrdSendRet = 1 Then [prd].[funMaxRetProduct](ProcessID, ProcessNo, FiscalYear, SerialNo,1)  Else 0 end > 0.1

		-- receive docs (80)
		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesDtl_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where	(D.ProcessID = 80) and (H.ProcessID = 70)

		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesDtl_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where	(D.ProcessID = 75) and (H.ProcessID = 70)


	END
	else
	BEGIN
		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 1 AND (ProcessID = 70) AND
				(H.ProductCount - IsNull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where D.ProcessID=80 and D.BatchNo = H.BatchNo
					),0)) - Case When @DecreasePrdQtyByPrdSendRet = 1 Then [prd].[funMaxRetProduct](ProcessID, ProcessNo, FiscalYear, SerialNo,1)  Else 0 end > 0.1
	
		insert into #tbl_SpTransferProducesDtl_Info
		(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 1 AND (ProcessID = 80) AND
				(H.BatchNo IN (
						select BatchNo
						from #tbl_SpTransferProducesDtl_Info D
						where D.ProcessID=70))

		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 1 AND (ProcessID = 75) AND
				(H.BatchNo IN (
						select BatchNo
						from #tbl_SpTransferProducesDtl_Info D
						where D.ProcessID=70))

		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select	ProcessID, ProcessNo, FiscalYear, SerialNo,''
		from	inv.tblStorageDocsHdr H
		where	ProcessNo = 2 AND (ProcessID = 70) AND
				(H.ProductCount - isnull((
						select SUM(GoodsQuantity)
						from inv.tblStorageDocsDtl D
						where	D.ProcessID=80 
							and D.BaseProcessID=70 
							and D.BaseProcessNo=H.ProcessNo
							and D.BaseFiscalYear=H.FiscalYear
							and D.BaseSerialNo=H.SerialNo
							and D.GoodsID=H.ProductID
					),0)) - Case When @DecreasePrdQtyByPrdSendRet = 1 Then [prd].[funMaxRetProduct](ProcessID, ProcessNo, FiscalYear, SerialNo,1)  Else 0 end > 0.1

		-- receive docs (80)
		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesDtl_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where	D.ProcessNo = 2 AND H.ProcessNo = 2 AND (D.ProcessID = 80) and (H.ProcessID = 70)

		insert into #tbl_SpTransferProducesDtl_Info(ProcessID, ProcessNo, FiscalYear, SerialNo,BatchNo)
		select distinct	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo,''
		from	inv.tblStorageDocsDtl D 
		INNER JOIN #tbl_SpTransferProducesDtl_Info H on D.BaseProcessID=H.ProcessID and D.BaseProcessNo=H.ProcessNo and D.BaseFiscalYear=H.FiscalYear and D.BaseSerialNo=H.SerialNo
		where	D.ProcessNo = 2 AND H.ProcessNo = 2 AND (D.ProcessID = 75) and (H.ProcessID = 70)
	END
	
	
	-- S E L E C T ------------------------------------------------------------
	SELECT D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.RowNo, D.DocRowNo, D.VolumeRowNo, D.DocStep, D.DocDate, D.StoreID, 
		   D.PhysicallyEffected, D.EnterKind, D.StoreID2, D.AcntCode, D.VisitorAcntCode, D.OrderAcntCode, D.GoodsID, D.SubUnitID, 
		   D.SubUnitQuantity, --IsNull(Case When @DecreasePrdQtyByPrdSendRet = 1 Then (Select Top 1 RemainCount From [prd].[FunGetProductSendRemainDtl] (D.ProcessNo, D.SerialNo, D.DocRowNo)) Else D.SubUnitQuantity End,0) As SubUnitQuantity, 
		   D.GoodsQuantity, --IsNull(Case When @DecreasePrdQtyByPrdSendRet = 1 Then (Select Top 1 RemainCount From [prd].[FunGetProductSendRemainDtl] (D.ProcessNo, D.SerialNo, D.DocRowNo)) Else D.GoodsQuantity End,0) As GoodsQuantity, 
		   D.QtyRemain, D.GoodsAmount, D.AmntRemain, D.AtomAmount, D.GoodsPrice, D.DescDtl, 
		   D.BaseProcessID, D.BaseProcessNo, D.BaseFiscalYear, D.BaseSerialNo, D.BaseDocRowNo, D.BaseDocType, D.AgreeNo, D.BatchNo, 
		   D.DiscountPercentDtl, D.DiscountDtl, D.BaseDocDate, D.VirtualQuantity, D.IsReward, D.FormulaNo, D.GoodsID2, D.Wage, 
		   D.WageRate, D.FormulaProductCount, D.CurrencyAmount, D.CalculatingAmount, D.VchDate2, D.SubUnitPrice, D.UserGoodsAmount, 
		   D.ExpireDate, D.SourceSerialNo, D.SourceProcessNo, D.DailyUsesBranchID, D.GoodsAmount1, D.GoodsAmount2, D.GoodsAmount3, 
		   D.GoodsAmount4, D.GoodsAmount5, D.GoodsAmount6, D.GoodsAmount7, D.GoodsAmount8, D.GoodsAmount9, D.GoodsAmount10, 
		   D.GoodsAmount11, D.GoodsAmount12, D.StoreVariable1, D.StoreVariable2, D.SalePrice, D.PhrBatchNo, D.GregorianExpireDate, 
		   D.PricePercent, D.VisitorPercent, D.ContainTax, D.ConstText1, D.ConstText2, D.ConstText3, D.ConstText4, D.Var1, D.Var2, D.Var3, D.Var4, D.SaleTypeID, 
		   D.SubUnitPrice2, D.SubUnitQuantity2, D.TaxOverWorthCostDtl, D.TollOverWorthCostDtl, D.VisitorAcntCode2, D.VisitorPercent2
	INTO #tbl_SpTransferProduces_Result
	FROM inv.tblStorageDocsDtl D
	INNER JOIN #tbl_SpTransferProducesDtl_Info T on T.ProcessID = D.ProcessID and T.ProcessNo = D.ProcessNo and T.FiscalYear = D.FiscalYear and T.SerialNo = D.SerialNo
		
	UPDATE #tbl_SpTransferProduces_Result SET EnterKind = 0

	if (@WithBatchNo = 0)
	BEGIN
		DELETE FROM #tbl_SpTransferProduces_Result
		from #tbl_SpTransferProduces_Result b
		WHERE ProcessID=80 and (SELECT COUNT(*) from #tbl_SpTransferProduces_Result a 
			   WHERE a.ProcessID=70 
				 and a.ProcessID=b.BaseProcessID
				 and a.ProcessNo=b.BaseProcessNo
				 and a.FiscalYear=b.BaseFiscalYear
				 and a.SerialNo=b.BaseSerialNo)=0
	END 

	SELECT * FROM #tbl_SpTransferProduces_Result
	order by ProcessID
	---------------------------------------------------------------------------
END
GO
