USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO


Create FUNCTION [pub].[funGetAcntCodeFromBankCode] 
(
	@ProcessID AS INT,
	@PayTypeID AS INT,
	@BankCode as varchar(20),
	@AmountType as Int-- Debit=1,Credit=2
	
)
RETURNS varchar(20)
WITH ENCRYPTION            
AS
BEGIN

	DECLARE @AcntCode as varchar(20)

Set @AcntCode =''

if (@ProcessID=1 and @PayTypeID=1 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=2 )
	select  @AcntCode=AcntCode3 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=3 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=4 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=6 )
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=26 )
	select  @AcntCode=AcntCode5 from trs.tblOurBanks 	where BankCode = @BankCode 
-----------------------------------------------------------------------------------	
if (@ProcessID=1 and @PayTypeID=1 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=2 )
	select  @AcntCode=AcntCode3 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=3 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=4 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=5 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=6 )
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=7 )
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=8 )
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=1 and  @PayTypeID=28 )
	select  @AcntCode=AcntCode3 from trs.tblOurBanks 	where BankCode = @BankCode 
---------------------------------------
if (@ProcessID=10 and  @PayTypeID=6 )
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=10 and  @PayTypeID=26 )
	select  @AcntCode=AcntCode5 from trs.tblOurBanks 	where BankCode = @BankCode 
---------------------------------------
if (@ProcessID=12 and  @PayTypeID=6 )
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=12 and  @PayTypeID=26 )
	select  @AcntCode=AcntCode5 from trs.tblOurBanks 	where BankCode = @BankCode 
---------------------------------------
if (@ProcessID=13 and  @PayTypeID=6 )
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=13 and  @PayTypeID=26 )
	select  @AcntCode=AcntCode5 from trs.tblOurBanks 	where BankCode = @BankCode 
---------------------------------------
if (@ProcessID=17 and  @PayTypeID=6 )
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=17 and  @PayTypeID=26 )
	select  @AcntCode=AcntCode5 from trs.tblOurBanks 	where BankCode = @BankCode 
	
---------------------------------------
if (@ProcessID=21 and  @PayTypeID=6 and @AmountType=1)
	select  @AcntCode=AcntCode2 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=21 and  @PayTypeID=6 and @AmountType=2)
	select  @AcntCode=AcntCode3 from trs.tblOurBanks 	where BankCode = @BankCode 
	
if (@ProcessID=21 and  @PayTypeID=26 and @AmountType=1)
	select  @AcntCode=AcntCode5 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=21 and  @PayTypeID=26 and @AmountType=2)
	select  @AcntCode=AcntCode3 from trs.tblOurBanks 	where BankCode = @BankCode 
	
---------------------------------------
if (@ProcessID=22 and  @PayTypeID=6 and @AmountType=1)
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=22 and  @PayTypeID=6 and @AmountType=2)
	select  @AcntCode=AcntCode3 from trs.tblOurBanks 	where BankCode = @BankCode 
	
if (@ProcessID=22 and  @PayTypeID=26 and @AmountType=1)
	select  @AcntCode=AcntCode1 from trs.tblOurBanks 	where BankCode = @BankCode 
if (@ProcessID=22 and  @PayTypeID=26 and @AmountType=2)
	select  @AcntCode=AcntCode3 from trs.tblOurBanks 	where BankCode = @BankCode 
	
	



	
	
--	SELECT     TOP (100) PERCENT aa.ProcessID, aa.ProcessNo, aa.FiscalYear, aa.SerialNo, aa.AcntCode, aa.s, bb.SourceProcessID, bb.SourceProcessNo, bb.SourceFiscalYear, 
--                      bb.SourceSerialNo, bb.AcntCode AS AcntCode2, bb.s AS S2, bb.SerialNo AS SerialNo2
--FROM         (SELECT     ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode, SUM(s) AS s
--                       FROM          (SELECT     ProcessID, ProcessNo, FiscalYear, SerialNo, PayTypeID, pub.funGetAcntCodeFromBankCode(ProcessID, PayTypeID, DebitCode, 1) AS AcntCode,
--                                                                       SUM(Amount) AS s
--                                               FROM          trs.tblPayDtl AS D
--                                               WHERE      (ProcessID IN (1, 10, 17, 23, 40, 20, 21, 28, 31, 34, 22, 27)) AND (FiscalYear = 94)
--                                               GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, DebitCode, PayTypeID) AS a
--                       GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode) AS aa FULL OUTER JOIN
--                          (SELECT     SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, AcntCode, SUM(Debit) AS s, SerialNo
--                            FROM          acc.tblVoucherDtl
--                            WHERE      (SourceProcessID IN (1, 10, 17, 23, 40, 20, 21, 28, 31, 34, 22, 27)) AND (Debit <> 0)
--                            GROUP BY SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, AcntCode, SerialNo) AS bb ON 
--                      aa.ProcessID = bb.SourceProcessID AND aa.ProcessNo = bb.SourceProcessNo AND aa.FiscalYear = bb.SourceFiscalYear AND aa.SerialNo = bb.SourceSerialNo AND 
--                      aa.s = bb.s AND aa.AcntCode = bb.AcntCode
--WHERE     (aa.ProcessID IS NULL) OR
--                      (bb.SourceProcessID IS NULL)
--     union 
                      
--SELECT     TOP (100) PERCENT aa.ProcessID, aa.ProcessNo, aa.FiscalYear, aa.SerialNo, aa.AcntCode, aa.s, bb.SourceProcessID, bb.SourceProcessNo, bb.SourceFiscalYear, 
--                      bb.SourceSerialNo, bb.AcntCode AS EXPR1, bb.s AS EXPR2, bb.SerialNo AS EXPR3
--FROM         (SELECT     ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode, SUM(s) AS s
--                       FROM          (SELECT     ProcessID, ProcessNo, FiscalYear, SerialNo, PayTypeID, pub.funGetAcntCodeFromBankCode(ProcessID, PayTypeID, CreditCode, 2) 
--                                                                      AS AcntCode, SUM(Amount) AS s
--                                               FROM          trs.tblPayDtl AS D
--                                               WHERE      (ProcessID IN (12, 13, 24, 32, 33, 2, 25, 22, 27)) AND (FiscalYear = 94)
--                                               GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, CreditCode, PayTypeID) AS a
--                       GROUP BY ProcessID, ProcessNo, FiscalYear, SerialNo, AcntCode) AS aa FULL OUTER JOIN
--                          (SELECT     SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, AcntCode, SUM(Credit) AS s, SerialNo
--                            FROM          acc.tblVoucherDtl
--                            WHERE      (SourceProcessID IN (12, 13, 24, 32, 33, 2, 25, 22, 27)) AND (Credit <> 0)
--                            GROUP BY SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, AcntCode, SerialNo) AS bb ON aa.ProcessID = bb.SourceProcessID AND 
--                      aa.ProcessNo = bb.SourceProcessNo AND aa.FiscalYear = bb.SourceFiscalYear AND aa.SerialNo = bb.SourceSerialNo AND aa.AcntCode = bb.AcntCode AND 
--                      aa.s = bb.s
--WHERE     (aa.ProcessID IS NULL) OR
--                      (bb.SourceProcessID IS NULL)
--ORDER BY aa.ProcessID    ,SourceProcessID 
	RETURN @AcntCode


END
	

GO
