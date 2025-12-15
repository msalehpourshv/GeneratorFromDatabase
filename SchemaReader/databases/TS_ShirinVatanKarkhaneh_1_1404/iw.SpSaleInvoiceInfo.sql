USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < ������ �ǘ���  ����  >
-- ==============================================
Create PROCEDURE iw.SpSaleInvoiceInfo
	@UserID			int,
	@StationID		varchar(20) ,
	@StrWhare		NVarChar(MAX),
	@Skip			int,
	@Take			int,
	@ProcessNo		int,
	@FiscalYear		int,
	@SerialNo		int	

WITH ENCRYPTION
AS
BEGIN	
		
DECLARE @StrSelect		NVarChar(MAX);

	if isnull(@Take,0)=0
		set @Take=1

	set @StrSelect ='
	select  Count(*)over () TotalCount, ProcessID, ProcessNo, FiscalYear, SerialNo,DocDate, AcntCode,
		isnull(pub.GetCodeName(AcntCode,1),'''') AS AcntName, StoreID
		, isnull(pub.GetStoreName(StoreID,1) ,'''')  StoreName
		,OrderAcntCode,isnull(lyl.GetCustomerInfo (OrderAcntCode,1) ,'''')   OrderAcntName 
		,DocStep,DocDesc,DocDesc2,Amount,Price, Discount, Discount2, Discount3,DiscountPercent, DiscountPercent2
		,CreditCardDiscount,AutoDiscont,AutoDiscont2,AutoDiscontPercent,DiscountTaxOverWorth,TaxOverWorthCost,TollOverWorthCost
		,isnull( (select Sum(Amount) from trs.tblPayDtl PD
					inner join  trs.tblPayHdr PH
					on PH.ProcessID=PD.ProcessID And PH.ProcessNo=PD.ProcessNo And PH.FiscalYear=PD.FiscalYear And PH.SerialNo=PD.SerialNo
					where PH.BaseProcessID=H.ProcessID and PH.BaseProcessNo=H.ProcessNo and PH.BaseFiscalYear=H.FiscalYear and PH.BaseSerialNo=H.SerialNo
				),0) Payment
		,RowNo	,DocRowNo,GoodsID,pub.funGetGoodsName(GoodsID,1) AS GoodsName,	SubUnitID,inv.funGetUnitName(SubUnitID,1) AS SubUnitName,	SubUnitQuantity
		,GoodsQuantity,GoodsPrice,Price0 ,DiscountPercentDtl	,DiscountDtl,GBarCode, IsReward,IsReward0
	from   inv.tblStorageDocsHdr H
	inner join inv.tblStorageDocsDtl D
	on H.ProcessID=D.ProcessID And H.ProcessNo=D.ProcessNo And H.FiscalYear=D.FiscalYear And H.SerialNo=D.SerialNo	 
	where H.ProcessID=90 and H.ProcessNo='+ str(@ProcessNo)+ ' and H.FiscalYear='+ str(@FiscalYear)+ ' and H.SerialNo='+ str(@SerialNo)+ ' '

	if isnull(@StrWhare,'')<>''
		set @StrSelect +=' and ' +@StrWhare
	
	set @StrSelect += ' Order by H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo
						OFFSET ' +str(@Skip) +' Rows 
						FETCH NEXT ' +Str(@Take) +' Rows ONLY '
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

END
GO
