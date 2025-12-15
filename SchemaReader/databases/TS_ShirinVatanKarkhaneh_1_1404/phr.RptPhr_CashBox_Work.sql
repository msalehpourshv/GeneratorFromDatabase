USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/09/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_CashBox_Work]

	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@UserID			Varchar(20) = Null,
	@UserAcntCode	Varchar(20) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrSelect2	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);
Declare @StrWhere2	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	-- Where Clause -----------------------------------------
	Set @StrWhere = '1 = 1'
	Set @StrWhere2 = 'where 1 = 1'

	IF (@DocDateFr Is Not Null)
		
		SET @StrWhere = @StrWhere + ' AND A.DocDate >= ''' + @DocDateFr + ''''
		
	IF @DocDateTo Is Not Null
			
		SET @StrWhere = @StrWhere + ' AND A.DocDate <= ''' + @DocDateTo + ''''
		
	IF @UserID Is NOT NULL		
		SET @StrWhere = @StrWhere + ' AND A.UserID = ''' + @UserID + ''''
		
		
	------------------------------			
	IF (@DocDateFr Is Not Null)
		
		SET @StrWhere2 = @StrWhere2 + ' AND DocDate >= ''' + @DocDateFr + ''''
		
	IF @DocDateTo Is Not Null
			
		SET @StrWhere2 = @StrWhere2 + ' AND DocDate <= ''' + @DocDateTo + ''''
		
	IF @UserID Is Not Null
			
		SET @StrWhere2 = @StrWhere2 + ' AND UserID = ''' + @UserID + ''''		
			
		
		
	-- Select Clause -------------------------------------------

	SET @StrSelect2='select SUM(Discount) FROM phr.tblCashBoxDtl '

	SET @StrSelect = '
	Select IsNull(SUM(Case When A.PayTypeID = 1 Then A.PayedAmount Else 0 End),0) As CashPayed,
		   IsNull(SUM(Case When A.PayTypeID = 2 Then A.PayedAmount Else 0 End),0) As PosPayed,
		   IsNull(SUM(Case When A.PayTypeID = 3 Then A.PayedAmount Else 0 End),0) As DepositPayed,
		  (' + @StrSelect2 + @StrWhere2 +') As Discounts
	From phr.tblCashBoxAtm A 
	Where ' + @StrWhere
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
