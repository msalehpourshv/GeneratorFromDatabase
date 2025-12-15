USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/08/12
-- Viewed By	 : 
-- Last Modified : 1392/08/12
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[RptPhr_Reciption_Pharmacy]
	@FiscalYear			Int = Null,
	@SerialNo			Int = Null,
	@RepOptions			VarChar(10) = '111011111',  -- bit array options
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

	IF (@FiscalYear Is Null)	SET @SerialNo = Null;
	IF (@SerialNo	Is Null)	SET @FiscalYear = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- Where Clause -----------------------------------------
	Select @StrWhere = '1 = 1'

	IF (@SerialNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo = ' + LTrim(Str(@SerialNo))  

	IF (@FiscalYear Is Not Null)
	SET @StrWhere = @StrWhere + ' AND H.FiscalYear = ' + LTrim(Str(@FiscalYear))  

	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT H.SerialNo ,H.DocDate ,H.DocTime ,H.IllName + '' '' + H.IllLastName As PatientName ,H.IllInsuranceNo ,
		   ID.InsuranceName ,ITD.InsuranceTypeName ,H.DoctorName + '' '' + H.DoctorLastName As DoctorName ,
		   GD.GoodsName As DrugName ,D.Qty ,D.SalePrice As SalePrice ,D.ExpDate      
	FROM phr.tblReciptionDtl D
		Inner Join phr.tblReciptionHdr H
		ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		Inner Join phr.tblInsuranceDtl ID
		ON ID.InsuranceID = H.InsuranceID
		Inner Join phr.tblInsuranceTypeDtl ITD
		ON ITD.InsuranceTypeID = H.InsuranceTypeID
		Inner Join inv.tblGoodsDtl GD
		ON D.GoodsID = GD.GoodsID
	WHERE ' + @StrWhere + '
	ORDER BY H.SerialNo ,H.DocDate'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
