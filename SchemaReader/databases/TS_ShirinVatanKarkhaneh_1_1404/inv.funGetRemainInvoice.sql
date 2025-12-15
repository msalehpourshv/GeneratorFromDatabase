USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION inv.funGetRemainInvoice
(
	@ProcessID	TinyInt,
	@ProcessNo	TinyInt,
	@FiscalYear	SmallInt,
	@SerialNo	Int
	
)
RETURNS float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================

	 Declare @Fact float
	Declare @Discount float
	Declare @Ret float
	Declare @Pay float


SELECT   @Fact=  ISNULL(SUM(Amount+AfterSaleDiscount), 0) 
	FROM         inv.tblStorageDocsHdr AS a
	WHERE     (ProcessID = @ProcessID) AND (ProcessNo = @ProcessNo) AND (FiscalYear = @FiscalYear) AND (SerialNo = @SerialNo)
select @Pay=Sum(Amount) from acc.tblAccState
WHERE     (SourceProcessID1	 = @ProcessID) AND (SourceProcessNo1 = @ProcessNo) AND (SourceFiscalYear1 = @FiscalYear) AND (SourceSerialNo1 = @SerialNo)
--  تخفیفات کسر نشود و تطبیق یافته ها 
and not (  (SourceProcessID2	 = @ProcessID) AND (SourceProcessNo2 = @ProcessNo) AND (SourceFiscalYear2 = @FiscalYear) AND (SourceSerialNo2 = @SerialNo))
if @Fact is null 
set @Fact=0
if @Pay is null 
set @Pay=0

	Return @Fact-@Pay
End   -- === E N D ===============================================
GO
