USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/09/23
-- Viewed By	 : 
-- Last Modified : 1392/09/23
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_TechnicalOfficer_Admin]

	@DeliverDocDateFr	Char(10) = Null,
	@DeliverDocDateTo	Char(10) = Null,
	@RepOptions			VarChar(10) = '111011111',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect		NVarChar(4000);
Declare @StrFrom		NVarChar(4000);
Declare @StrWhere		NVarChar(4000);
Declare @StrWhere2		NVarChar(4000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;

DECLARE	@BranchDBName	 NVarChar(50);

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	Select @BranchDBName = pub.funGetBranchDBName();
	
	-- Where Clause -----------------------------------------
	Select @StrWhere = 'CD.DeliveryToCustomer = 1'
	Select @StrWhere2 = ' And CD1.DeliveryToCustomer = 1'

	IF (@DeliverDocDateFr Is Not Null)
	Begin	
		SET @StrWhere = @StrWhere + ' AND (CD.DeliverDocDate >= ''' + @DeliverDocDateFr + ''')'
		SET @StrWhere2 = @StrWhere2 + ' AND (CD1.DeliverDocDate >= ''' + @DeliverDocDateFr + ''')'
	End
	
	IF @DeliverDocDateTo Is Not Null
	Begin
		SET @StrWhere = @StrWhere + ' AND (CD.DeliverDocDate <= ''' + @DeliverDocDateTo + ''')'
		SET @StrWhere2 = @StrWhere2 + ' AND (CD1.DeliverDocDate <= ''' + @DeliverDocDateTo + ''')'
	End			
	
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	Select ' + @BranchDBName + '.pub.funUserFullName(CD.DeliverUserID) As UserName ,
		   (Select COUNT(*) From phr.tblReciptionHdr RH1
	    		Inner Join (Select Distinct ReciptionFiscalYear, ReciptionSerialNo, DeliveryToCustomer,
                            DeliverDocDate ,DeliverUserID From phr.tblCashBoxDtl) CD1
                ON RH1.FiscalYear = CD1.ReciptionFiscalYear And
	    				   RH1.SerialNo = CD1.ReciptionSerialNo
		   Where RH1.ReciptionTypeID = 1 And CD.DeliverUserID = CD1.DeliverUserID ' + @StrWhere2 + ') As Insurance ,
		  (Select COUNT(*) From phr.tblReciptionHdr RH1
	    		Inner Join phr.tblCashBoxDtl CD1 ON RH1.FiscalYear = CD1.ReciptionFiscalYear And
	    				   RH1.SerialNo = CD1.ReciptionSerialNo
		   Where RH1.ReciptionTypeID <> 1 And CD1.DeliverUserID = CD.DeliverUserID
				 ' + @StrWhere2 + ') As Free ,
		  IsNull((Select IsNull(COUNT(*),0) From phr.tblReciptionHdr RH1
	    		Inner Join phr.tblCashBoxDtl CD1 ON RH1.FiscalYear = CD1.ReciptionFiscalYear And
	    				   RH1.SerialNo = CD1.ReciptionSerialNo
		   Where RH1.ReciptionTypeID = 1 And CD1.DeliverUserID = CD.DeliverUserID And RH1.ConfirmType = 1 
				 ' + @StrWhere2 + '
		   ),0) As Web       
	              
	From phr.tblReciptionHdr RH
		Inner Join phr.tblCashBoxDtl CD ON RH.FiscalYear = CD.ReciptionFiscalYear And RH.SerialNo = CD.ReciptionSerialNo
	Where ' + @StrWhere + '
	Group By CD.DeliverUserID'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
