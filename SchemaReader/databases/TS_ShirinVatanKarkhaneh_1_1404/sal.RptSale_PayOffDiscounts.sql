USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1396/06/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [sal].[RptSale_PayOffDiscounts]
	@CustomerKindID		VarChar(20) = Null,
	@CustomerKindName	VarChar(200) = Null,
	@PayOffTypeID		VarChar(20) = Null,
	@ExtraParams		NVarChar(500) = Null,
	@RepOptions			VarChar(10) = '0',  -- Bit Array Options
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(4000);
Declare @StrWhere	NVarChar(4000);

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
	Select @StrWhere = '1 = 1'
	
	IF (@CustomerKindID Is Not Null And @CustomerKindID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.CustomerKindID = ''' + @CustomerKindID + ''')'
		
	IF (@PayOffTypeID Is Not Null And @PayOffTypeID <> '')
		Set @StrWhere = @StrWhere + ' AND (D.PayOffTypeID = ''' + @PayOffTypeID + ''')'			

	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT D.*, C.CustomerKindName, P.PayOffTypeName
	FROM sal.tblPayOffDiscountsHdr H
	INNER JOIN sal.tblPayOffDiscountsDtl D ON H.CustomerKindID = D.CustomerKindID
	INNER JOIN sal.tblCustomerKindsDtl C ON D.CustomerKindID = C.CustomerKindID
	INNER JOIN sal.tblPayOffTypesDtl P ON P.PayOffTypeID = D.PayOffTypeID
	WHERE ' + @StrWhere
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------

END
GO
