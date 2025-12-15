USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED =====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 1389/04/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_VisitorCustomers]
	@VisitorAcntCode	Varchar(20) = Null,
	@FromDate			Char(10) = Null,
	@ToDate				Char(10) = Null,	
	@ExtraParams		NVarChar(200) = '',
	@RepOptions			NVarChar(100) = '',
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect		NVarChar(4000);
Declare @StrFrom		NVarChar(2000);
Declare @StrWhere		NVarChar(2000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	Int;
DECLARE @ReportID	Int;
Begin --============== S T A R T  C O D E ===================================================
	set NOCOUNT ON;

	-- Init Variables ------------------------------------------
	If (@RepInfo Is Null) set @RepInfo = '1@1@1';
	
	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- ---------------------------------------------------------
	-- Where Clause --------------------------------------------
	SET @StrWhere = '(1 = 1)'
	
	If (@VisitorAcntCode IS Not Null) And (@VisitorAcntCode <> '')
		SET @StrWhere = @StrWhere + ' AND (H.VisitorAcntCode = ''' + LTrim(@VisitorAcntCode) + ''')';

	IF (@FromDate Is Not Null) And (@FromDate <> '')
		SET @StrWhere = @StrWhere + ' AND (H.FromDate = ''' + LTrim(@FromDate) + ''')'
		
	IF (@ToDate Is Not Null) And (@ToDate <> '')
		SET @StrWhere = @StrWhere + ' AND (H.ToDate = ''' + LTrim(@ToDate) + ''')'
		
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	set @StrSelect = '
	Select	D.*, H.VisitorAcntCode, H.FromDate, H.ToDate, pub.GetCodeName(H.VisitorAcntCode, 1) as VisitorName,
				pub.GetCodeName(D.CustomerAcntCode, 1) As AcntName,
				[sal].[funGetCustomerKindName](CustomerKindID,1) CustomerKindName,
				[pub].[funGetLocationName](LocationID,1) LocationName,
				IsNull((Select Sum(Debit - Credit)
				 From acc.tblVoucherDtl
				 Where (VchKind <> 0) And AcntCode = D.CustomerAcntCode),0) As CustomerRemain,
				 
				IsNull((Select Sum(Debit - Credit)
				 From acc.tblVoucherDtl
				 Where (VchKind <> 0) And AcntCode = H.VisitorAcntCode),0) As VisitorRemain
				 
	From	sal.tblVisitorsCustomersHdr H
	Inner Join sal.tblVisitorsCustomersDtl D ON D.VisitorAcntCode = H.VisitorAcntCode
	Where ' + @StrWhere + '
	Order By DocRowNo '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
