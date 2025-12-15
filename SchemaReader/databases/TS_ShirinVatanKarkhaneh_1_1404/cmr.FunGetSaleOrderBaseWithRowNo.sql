USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 93/09/04 - Hamid
-- Description   : 
-- =============================================
--SELECT * from [cmr].[FunGetSaleOrder] ('106001','1393/07/29',1,'False')
Create FUNCTION [cmr].[FunGetSaleOrderBaseWithRowNo]
(
	@ProcessNo		int,
	@FiscalYear		int,
	@SerialNo		int,
	@DocRowNo		int,
	@AcntCode		Varchar(20),
	@DocDate		char(10),
	@DocStep		tinyint,
	@SalRet_RetToSalOdr BIT 
)
RETURNS	@tbl Table 
([ProcessID] [smallint] NOT NULL,
	[ProcessNo] [tinyint] NOT NULL,
	[FiscalYear] [smallint] NOT NULL,
	[SerialNo] [int] NOT NULL,
	[DocRowNo] [int] NOT NULL,
	[StoreID] [varchar](20) NOT NULL,
	[TaxOverWorthCostDtl] [float] NOT NULL,
	[TollOverWorthCostDtl] [float] NOT NULL,
	[BaseProcessID] [smallint] NOT NULL,
	[BaseProcessNo] [tinyint] NOT NULL,
	[BaseFiscalYear] [smallint] NOT NULL,
	[BaseSerialNo] [int] NOT NULL,
	[BaseDocRowNo] [int] NOT NULL,
	[SubUnitID] [varchar](20) NOT NULL,
	[SubUnitQuantity] [float] NOT NULL,
	[ConfirmQuantity] [float] NOT NULL,
	[DocDate] [char](10) NOT NULL,
	[AcntCode] [varchar](20) NOT NULL,
	[GoodsPrice] [float] NOT NULL,
	[SubUnitPrice] [float] NOT NULL,
	[GoodsID] [varchar](20) NOT NULL,
	[VisitorAcntCode] [varchar](20) NOT NULL,
	[VisitorAcntCode2] [varchar](20) NOT NULL,
	[SaleTypeID] [varchar](20) NOT NULL,
	[AgreeNo] [varchar](20) NOT NULL,
	[DocDesc] [nvarchar](2000) NOT NULL,
	[TransportationCostAcntCode] [varchar](20) NOT NULL,
	[TransportationCost] [float] NOT NULL,
	[TransportationIncomeAcntCode] [varchar](20) NOT NULL,
	[TransportationIncome] [float] NOT NULL,
	[VisitorAcntCodeHdr] [varchar](20) NOT NULL,
	[VisitorAcntCodeHdr2] [varchar](20) NOT NULL,
	[HdrVisitorPercent] [float] NOT NULL,
	[HdrVisitorPercent2] [float] NOT NULL,
	[VisitorCost] [float] NOT NULL,
	[VisitorCost2] [float] NOT NULL,
	[PackingCost] [float] NOT NULL,
	[TaxCost] [float] NOT NULL,
	[CurrencyTypeID] [varchar](20) NOT NULL,
	[CurrencyRate] [float] NOT NULL,
	[TaxOverWorthCost] [float] NOT NULL,
	[TollOverWorthCost]  [float] NOT NULL,
	[OtherCostAcntCode] [varchar](20) NOT NULL,
	[OtherCost]  [float] NOT NULL,
	[OtherIncomeAcntCode] [varchar](20) NOT NULL,
	[OtherIncome] [float] NOT NULL,
	[SgnSN1] [int] NOT NULL,
	[SgnSN2] [int] NOT NULL,
	[SgnSN3] [int] NOT NULL,
	[SgnSN4] [int] NOT NULL,
	[SgnSN5] [int] NOT NULL

) 
WITH ENCRYPTION
AS
BEGIn
	declare @LineConfirmationInSaleorder BIt
	SELECT @LineConfirmationInSaleorder = SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'LineConfirmationInSaleorder'

	DECLARE @str_Goods  tinyint,@str_GoodsSum tinyint
	DECLARE	@RetQty as float
	DECLARE @UnitPart TINYINT

	SET @UnitPart  = 1
	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1
	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
		from pub.tblCodeLayer 
		where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
		from pub.tblCodeLayer 
		where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart		
		
insert into @tbl(ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo, StoreID, TaxOverWorthCostDtl,TollOverWorthCostDtl,
					BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,SubUnitID,SubUnitQuantity,ConfirmQuantity,DocDate,AcntCode,GoodsPrice,SubUnitPrice,GoodsID,
					VisitorAcntCode, VisitorAcntCode2, SaleTypeID, AgreeNo, DocDesc, TransportationCostAcntCode, 
	   			    TransportationCost, TransportationIncomeAcntCode, TransportationIncome, VisitorAcntCodeHdr, 
					VisitorAcntCodeHdr2, HdrVisitorPercent, HdrVisitorPercent2,VisitorCost, VisitorCost2, PackingCost, 
					TaxCost, CurrencyTypeID, CurrencyRate, TaxOverWorthCost,TollOverWorthCost, OtherCostAcntCode, 
					OtherCost, OtherIncomeAcntCode, OtherIncome,SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5)		

SELECT D.*, H.VisitorAcntCode, H.VisitorAcntCode2, H.SaleTypeID, H.AgreeNo, H.DocDesc, H.TransportationCostAcntCode, 
	   H.TransportationCost, H.TransportationIncomeAcntCode, H.TransportationIncome, H.VisitorAcntCode As VisitorAcntCodeHdr, 
	   H.VisitorAcntCode2 As VisitorAcntCodeHdr2, H.VisitorPercent As HdrVisitorPercent, H.VisitorPercent2 As HdrVisitorPercent2, 
	   H.VisitorCost, H.VisitorCost2, H.PackingCost, H.TaxCost, H.CurrencyTypeID, H.CurrencyRate, H.TaxOverWorthCost, 
	   H.TollOverWorthCost, H.OtherCostAcntCode, H.OtherCost, H.OtherIncomeAcntCode, H.OtherIncome,
	   SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5
FROM (
		Select	Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo, Cnf.DocRowNo,Cnf.StoreID, 
				Cnf.TaxOverWorthCostDtl, Cnf.TollOverWorthCostDtl,
				Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo,
				Cnf.SubUnitID,				
				Cnf.SubUnitQuantity - ISNULL(Rtn.SubUnitQuantity,0) + ISNULL(SalRet.SubUnitQuantity,0) SubUnitQuantity, -- واحد اصلی مانده کالای سفارش
				Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) + ISNULL(SalRet.ConfirmQuantity,0) ConfirmQuantity, -- واحد اصلی مانده کالای سفارش
				--Cnf.SubUnitQuantity - ISNULL(Rtn.SubUnitQuantity,0) + ISNULL(SalRet.SubUnitQuantity,0) SubUnitQuantity,  -- واحد فرعی مانده کالای سفارش
				--CASE WHEN @SalRet_RetToSalOdr = 'False' THEN Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) ELSE  
				--											 Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) + ISNULL(SalRet.SubUnitQuantity,0) END AS ConfirmQuantity ,
				--CASE WHEN @SalRet_RetToSalOdr = 'False' THEN Cnf.SubUnitQuantity - ISNULL(Rtn.SubUnitQuantity,0) ELSE  
				--											 Cnf.SubUnitQuantity - ISNULL(Rtn.SubUnitQuantity,0) + ISNULL(SalRet.SubUnitQuantity,0) END AS SubUnitQuantity ,
				DocDate,AcntCode,GoodsPrice,SubUnitPrice,Cnf.GoodsID
		From
			(--  محاسبه کل سفارش
				Select	TOD.ProcessID , TOD.ProcessNo , TOD.FiscalYear , TOD.SerialNo ,TOD.DocRowNo,TOD.StoreID,
						TOD.TaxOverWorthCostDtl, TOD.TollOverWorthCostDtl,
						SubUnitID,inv.funGetGoodsSubQuantityBase(TOD.GoodsID,SubUnitID,TOD.GoodsQuantity,TOD.SubUnitQuantity,@str_Goods,@str_GoodsSum) SubUnitQuantity
						,GoodsQuantity,TOD.BaseProcessID , TOD.BaseProcessNo, 
						TOD.BaseFiscalYear , TOD.BaseSerialNo , TOD.BaseDocRowNo,DocDate,AcntCode,TOD.GoodsPrice,TOD.SubUnitPrice,TOD.GoodsID--,RG.SubUnitQuantity
				FROM	sal.tblSaleOrderDtl TOD
				WHERE ProcessID = 180 AND ProcessNo = @ProcessNo AND SerialNo=@SerialNo AND DocRowNo=@DocRowNo AND 
				    (@AcntCode IS NULL OR TOD.AcntCode like @AcntCode+'%') AND  TOD.DocDate <= @DocDate
				     AND (@LineConfirmationInSaleorder='False' OR LineConfirm='True' )
			UNION
				Select	ProcessID , ProcessNo , FiscalYear , SerialNo ,D.DocRowNo,StoreID,
						TaxOverWorthCostDtl, TollOverWorthCostDtl, 
						D.SubUnitID,inv.funGetGoodsSubQuantityBase(D.GoodsID,D.SubUnitID,D.GoodsQuantity,D.SubUnitQuantity,@str_Goods,@str_GoodsSum) SubUnitQuantity
						,GoodsQuantity AS ConfirmQuantity, BaseProcessID, BaseProcessNo, 
						BaseFiscalYear , BaseSerialNo , BaseDocRowNo,DocDate,AcntCode,GoodsPrice,SubUnitPrice,D.GoodsID--,ConfirmQuantity SubUnitQuantity						
				FROM sal.tblSaleOrderDtl D
				Where ProcessID = 180 AND BaseProcessID = 0 AND ProcessNo = @ProcessNo AND SerialNo=@SerialNo AND DocRowNo=@DocRowNo AND 
					 (@AcntCode IS NULL OR AcntCode like @AcntCode+'%') AND  DocDate <= @DocDate AND DocStep >= @DocStep
				AND  (@LineConfirmationInSaleorder='False' OR LineConfirm='True' )
			) Cnf 
		LEFT JOIN 
		(--  محاسبه کل انصراف سفارش
			Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
					SubUnitID,Sum(inv.funGetGoodsSubQuantityBase(GoodsID,SubUnitID,GoodsQuantity,SubUnitQuantity,@str_Goods,@str_GoodsSum) ) SubUnitQuantity,Sum(GoodsQuantity) ConfirmQuantity,GoodsID--,Sum(SubUnitQuantity) SubUnitQuantity
			From sal.tblSaleOrderDtl 
			Where BaseProcessID = 180 AND BaseProcessNo = @ProcessNo AND BaseSerialNo=@SerialNo AND DocRowNo=@DocRowNo AND  (@AcntCode IS NULL OR AcntCode like @AcntCode+'%')
			Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
					BaseDocRowNo,GoodsID,SubUnitID
		) Rtn
		ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
			Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
			Cnf.DocRowNo = Rtn.BaseDocRowNo AND Cnf.GoodsID = Rtn.GoodsID 
		LEFT JOIN
		(
			SELECT a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo ,SubUnitID,SUM(SubUnitQuantity) SubUnitQuantity,SUM(ConfirmQuantity) ConfirmQuantity,a.GoodsID --,SUM(SubUnitQuantity) SubUnitQuantity
			from (
			SELECT SD.BaseProcessID , SD.BaseProcessNo , SD.BaseFiscalYear , SD.BaseSerialNo , SD.BaseDocRowNo ,
			SD.SubUnitID,
			CASE WHEN @SalRet_RetToSalOdr = 'False' THEN - ISNULL(SD.SubUnitQuantity,0) 
				ELSE ISNULL(SD.SubUnitQuantity,0) - ISNULL(SD.SubUnitQuantity,0) END SubUnitQuantity,
			CASE WHEN @SalRet_RetToSalOdr = 'False' THEN - ISNULL(SD.GoodsQuantity,0) 
				ELSE ISNULL(ConfirmQuantity,0) - ISNULL(SD.GoodsQuantity,0) END ConfirmQuantity,SD.GoodsID
			--,CASE WHEN @SalRet_RetToSalOdr = 'False' THEN - ISNULL(SD.SubUnitQuantity,0) 
			--	ELSE ISNULL(SDRet.SubUnitQuantity,0) - ISNULL(SD.SubUnitQuantity,0) END   SubUnitQuantity 
		from ( -- محاسبه کل فروش ها
			  Select	  DISTINCT ProcessID, ProcessNo, FiscalYear, SerialNo, DocRowNo 
					, BaseProcessID, BaseProcessNo, BaseFiscalYear , BaseSerialNo, BaseDocRowNo, 
					GoodsID,SubUnitID,inv.funGetGoodsSubQuantityBase(GoodsID,SubUnitID,GoodsQuantity,SubUnitQuantity,@str_Goods,@str_GoodsSum) SubUnitQuantity, GoodsQuantity--, SubUnitQuantity
			 From inv.tblStorageDocsDtl 
			 WHERE ProcessID = 90 AND BaseProcessID=180 AND BaseProcessNo = @ProcessNo AND BaseSerialNo=@SerialNo AND BaseDocRowNo=@DocRowNo --AND (@AcntCode IS NULL OR AcntCode like @AcntCode+'%')
			)SD
			LEFT JOIN
			(-- محاسبه کل برگشت از فروش ها
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
						, BaseDocRowNo ,SubUnitID,sum(inv.funGetGoodsSubQuantityBase(GoodsID,SubUnitID,GoodsQuantity,SubUnitQuantity,@str_Goods,@str_GoodsSum) )SubUnitQuantity,SUM(GoodsQuantity) ConfirmQuantity,GoodsID--, SUM(SubUnitQuantity) SubUnitQuantity
				From inv.tblStorageDocsDtl 
				WHERE ProcessID = 100 AND BaseProcessID=90 --AND (@AcntCode IS NULL OR AcntCode like @AcntCode+'%')
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,GoodsID,SubUnitID
			)SDRet		
			ON	SD.ProcessID = SDRet.BaseProcessID AND SD.ProcessNo = SDRet.BaseProcessNo AND 
				SD.FiscalYear = SDRet.BaseFiscalYear AND SD.SerialNo = SDRet.BaseSerialNo AND 
				SD.DocRowNo = SDRet.BaseDocRowNo AND SD.GoodsID = SDRet.GoodsID 
			--WHERE ConfirmQuantity IS NOT NULL
			) a 
			Group BY a.BaseProcessID , a.BaseProcessNo , a.BaseFiscalYear , a.BaseSerialNo , a.BaseDocRowNo,a.GoodsID,a.SubUnitID
		)	SalRet
		ON	Cnf.ProcessID = SalRet.BaseProcessID AND Cnf.ProcessNo = SalRet.BaseProcessNo AND 
			Cnf.FiscalYear = SalRet.BaseFiscalYear AND Cnf.SerialNo = SalRet.BaseSerialNo AND 
			Cnf.DocRowNo = SalRet.BaseDocRowNo AND Cnf.GoodsID = SalRet.GoodsID		
	WHERE Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) + ISNULL(SalRet.ConfirmQuantity,0) >0
	and Cnf.SubUnitQuantity - ISNULL(Rtn.SubUnitQuantity,0) + ISNULL(SalRet.SubUnitQuantity,0) >0	
	--WHERE CASE WHEN @SalRet_RetToSalOdr = 'False' THEN Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) ELSE  
	--												   Cnf.GoodsQuantity - ISNULL(Rtn.ConfirmQuantity,0) + ISNULL(SalRet.SubUnitQuantity,0) END > 0 
					) D 
	INNER JOIN sal.tblSaleOrderHdr H
	ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
	   H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo

	   return
END
GO
