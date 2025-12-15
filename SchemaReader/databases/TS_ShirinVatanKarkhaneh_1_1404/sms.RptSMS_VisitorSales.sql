USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/03/12
-- Viewed By	 : 
-- Last Modified : 1392/04/30
-- Last Modifier : TakroSystem\Zia
-- Description	 : <Receivable Documents Report>
-- ----------------------------------------------
-- گزارش اسناد دریافتنی
-- ==============================================
CREATE PROCEDURE [sms].[RptSMS_VisitorSales]
	@ProcessID	Int = 0, 
	@SerialNo	Int = 0,
	@SaleDate	Char(10) = Null, 
	@Visitor	VarChar(20)	= Null, 
	@RepOptions	varchar(20) = '0'
WITH ENCRYPTION
As
DECLARE @StrWhere	NVarChar(max);
DECLARE @StrSelect	NVarChar(max);
Declare @GoodsOnly	bit;
BEGIN   

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	SET @GoodsOnly	= Substring(@RepOptions, 1, 1);

	-----------------------------------------------------------------
	set @StrWhere = '(D.ProcessID=90) and (D.VisitorAcntCode <> '''')'
	
	set @StrWhere = @StrWhere + ' 
			AND D.VisitorAcntCode in 
			(
				select AcntCode 
				from TS.sms.tblSmsDocsDtl 
				where ProcessID=' + ltrim(str(@ProcessID)) + ' and SerialNo=' + ltrim(str(@SerialNo)) + '
			)'
		
	IF (@SaleDate Is Not Null)
		SET @StrWhere = @StrWhere + ' 
			AND (D.DocDate=''' + @SaleDate + ''')'
			
	if (@GoodsOnly=1)
		set @StrSelect = 'D.GoodsPriceSum'
	else
		set @StrSelect = 'D.GoodsPriceSum + H.SidePriceSum'

	SET @StrSelect = '
	select 	ltrim(str(isnull(Sum(' + @StrSelect + '),0))) + ''@'' + ltrim(str(Count(*))) Result
	from
		(
			select	ProcessID, ProcessNo, FiscalYear, SerialNo, VisitorAcntCode, 
					Sum(GoodsQuantity*GoodsPrice) GoodsPriceSum
			from inv.tblStorageDocsDtl D
			where ' + @StrWhere + '
			group by ProcessID, ProcessNo, FiscalYear, SerialNo, VisitorAcntCode
		) D 
		inner join inv.vwStorageDocsHdr H on H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
End
GO
