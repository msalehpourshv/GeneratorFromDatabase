USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/12/15
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- ==============================================
CREATE PROCEDURE [trs].[RptTrs_BankDiff_Doc]
	@SerialNo		Int = 0,
	@RepOptions		VarChar(10) = '1111', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(500) = '-@-@-@-'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);
DECLARE @StrWhere1		NVarChar(2000);
DECLARE @StrWhere2		NVarChar(2000);
DECLARE @StrFrom		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;

DECLARE	@ShowDetail1	bit;
DECLARE	@ShowDetail2	bit;
DECLARE	@ShowRelatedY	bit;
DECLARE	@ShowRelatedN	bit;
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables ---------------------------
	IF (@RepOptions Is Null) SET @RepOptions = '1111';
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ShowDetail1	= Substring(@RepOptions, 1, 1);
	SET @ShowDetail2	= Substring(@RepOptions, 2, 1);
	SET @ShowRelatedY	= Substring(@RepOptions, 3, 1);
	SET @ShowRelatedN	= Substring(@RepOptions, 4, 1);
	---------------------------------------------

	-- Where Clause ------------------------------------------------------------
	set @StrWhere = '(SerialNo=' + STR(@SerialNo) + ')'
	set @StrWhere1 = @StrWhere
	set @StrWhere2 = @StrWhere
	
	create table #tbl_Trs_BankDiff
	(
		RowType	int not null,
		DocRowNo int not null,
		ChequeNo bigint not null,
		VchNo int not null,
		VchDate char(10) not null,
		RowDesc nvarchar(2000) not null,
		Amount bigint not null
	);

	if (@ShowDetail1 = 1)
	begin
		if (@ShowRelatedY=0) or (@ShowRelatedN=0)
		begin
			if (@ShowRelatedY=0) 
				set @StrWhere1 = @StrWhere1 + ' and (select count(*) from pln.tblItemRelations R where R.ProcessID = D.ProcessID and R.SerialNo = D.SerialNo and R.DocRowNo = D.DocRowNo)=0'
			if (@ShowRelatedN=0)
				set @StrWhere1 = @StrWhere1 + ' and (select count(*) from pln.tblItemRelations R where R.ProcessID = D.ProcessID and R.SerialNo = D.SerialNo and R.DocRowNo = D.DocRowNo)>0'
		end
		
		set @StrSelect = '
		insert into #tbl_Trs_BankDiff(RowType, DocRowNo, ChequeNo, VchNo, VchDate, RowDesc, Amount)
		select 1, DocRowNo, ChequeNo, VchNo, VchDate, RowDesc, Amount
		from trs.tblBankDiffsDtl1 D
		where ' + @StrWhere1
		
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	end
	
	if (@ShowDetail2 = 1)
	begin
		if (@ShowRelatedY=0) or (@ShowRelatedN=0)
		begin
			if (@ShowRelatedY=0) 
				set @StrWhere2 = @StrWhere2 + ' and (select count(*) from pln.tblItemRelations R where R.BaseProcessID = D.ProcessID and R.BaseSerialNo = D.SerialNo and R.BaseDocRowNo = D.DocRowNo)=0'
			if (@ShowRelatedN=0)
				set @StrWhere2 = @StrWhere2 + ' and (select count(*) from pln.tblItemRelations R where R.BaseProcessID = D.ProcessID and R.BaseSerialNo = D.SerialNo and R.BaseDocRowNo = D.DocRowNo)>0'
		end
		
		set @StrSelect = '
		insert into #tbl_Trs_BankDiff(RowType, DocRowNo, ChequeNo, VchNo, VchDate, RowDesc, Amount)
		select 2, DocRowNo, ChequeNo, 0 VchNo, VchDate, '''' RowDesc, Amount
		from trs.tblBankDiffsDtl2 D
		where ' + @StrWhere2
		
		PRINT @StrSelect;
		EXEC sp_executesql @StrSelect;
	end
	------------------------------------------------------------

	-- Run -------------------------------------------------------
	select *
	from #tbl_Trs_BankDiff
	order by RowType, DocRowNo
	--------------------------------------------------------------
End
GO
