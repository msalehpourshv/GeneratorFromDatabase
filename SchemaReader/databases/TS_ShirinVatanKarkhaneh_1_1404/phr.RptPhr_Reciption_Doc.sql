USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/07/02
-- Viewed By	 : 
-- Last Modified : 1392/09/02
-- Last Modifier : Hamid
-- Description	 : 
-- ==============================================
Create PROCEDURE [phr].[RptPhr_Reciption_Doc] 

	@FiscalYear			Int = Null,
	@SerialNo			Int = Null,
	@ReciptionTimeOut	Int = Null,
	@RepOptions			VarChar(10) = '111011111',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(MAX);
Declare @StrFrom	NVarChar(MAX);
Declare @StrWhere	NVarChar(MAX);

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
	Select @StrWhere = '1 = 1 AND D.DrugKind IN(1,2)'

	IF (@SerialNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo = ' + LTrim(Str(@SerialNo))  

	IF (@FiscalYear Is Not Null)
	SET @StrWhere = @StrWhere + ' AND H.FiscalYear = ' + LTrim(Str(@FiscalYear))  

	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT H.SerialNo ,H.DocDate ,H.PrescriptionDate,H.DocTime ,PD.PatientName + '' '' + PD.PatientLastName As PatientName ,H.IllInsuranceNo ,
		   ID.InsuranceName ,ITD.InsuranceTypeName ,H.DoctorName + '' '' + H.DoctorLastName As DoctorName ,
		   GD.GoodsName As DrugName ,Sum(D.SimilarQty) AS QTY ,D.SalePrice As SalePrice ,D.InsurancePrice As InsurancePrice ,
		   D.PriceDiff As PriceDiff ,Sum(D.TotalPrice) AS TotalPrice ,Sum(D.IllPortion) AS llPortion ,
		   Sum(D.InsurancePortion) AS InsurancePortion ,H.ProficiencyCost AS ProficiencyCost ,H.PayablePrice ,
		   H.BoxingCost ,H.PlusCost ,H.Discount ,H.DiscountReason ,H.InformaticCost AS  InformaticCost ,H.IsPreSale ,
		   H.CompleteInsuranceSum,H.CompleteInsuranceSum2,H.CompleteInsuranceSum3,H.DiffPrice
		   
  ,C1.InsuranceName as CompleteInsuranceName1,C2.InsuranceName as CompleteInsuranceName2,C3.InsuranceName as CompleteInsuranceName3
		   ,Ct1.InsuranceTypeName as CompleteInsuranceTypeName1,Ct2.InsuranceTypeName as CompleteInsuranceTypeName2,Ct3.InsuranceTypeName as CompleteInsuranceTypeName3
		  

	FROM phr.tblReciptionDtl D
		INNER JOIN phr.tblReciptionHdr H
		ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
		LEFT Join phr.tblInsuranceDtl ID
		ON ID.InsuranceID = H.InsuranceID
		LEFT Join phr.tblInsuranceTypeDtl ITD
		ON ITD.InsuranceTypeID = H.InsuranceTypeID
		LEFT Join inv.tblGoodsDtl GD
		ON D.SimilarGoodsID = GD.GoodsID
		LEFT JOIN phr.tblPatientDtl PD ON PD.PatientID = H.PatientID
	
		left Join  phr.tblInsuranceDtl C1 On C1.InsuranceID=H.CompleteInsuranceID
		left Join  phr.tblInsuranceDtl C2 On C2.InsuranceID=H.CompleteInsuranceID2
		left Join  phr.tblInsuranceDtl C3 On C3.InsuranceID=H.CompleteInsuranceID3
		left Join phr.tblInsuranceTypeDtl Ct1 On Ct1.InsuranceTypeID=H.CompleteInsuranceTypeID
		left Join phr.tblInsuranceTypeDtl Ct2 On Ct2.InsuranceTypeID=H.CompleteInsuranceTypeID2
		left Join phr.tblInsuranceTypeDtl Ct3 On Ct3.InsuranceTypeID=H.CompleteInsuranceTypeID3
		
	WHERE ' + @StrWhere + '
	GROUP BY H.SerialNo, H.DocDate, H.PrescriptionDate, H.DocTime, PD.PatientName, PD.PatientLastName, D.GoodsID, D.SalePrice,
			 H.IllInsuranceNo ,ID.InsuranceName ,ITD.InsuranceTypeName ,H.DoctorName ,D.SalePrice ,
			 H.DoctorLastName ,GD.GoodsName ,D.SalePrice ,D.InsurancePrice ,D.PriceDiff ,H.ProficiencyCost ,
			 H.InformaticCost ,H.IsPreSale ,H.PayablePrice ,H.BoxingCost ,H.PlusCost ,H.Discount ,
			 H.DiscountReason ,H.CompleteInsuranceSum,H.CompleteInsuranceSum2,H.CompleteInsuranceSum3,D.DocRowNo,H.DiffPrice
			 ,C1.InsuranceName ,C2.InsuranceName ,C3.InsuranceName ,Ct1.InsuranceTypeName ,Ct2.InsuranceTypeName ,Ct3.InsuranceTypeName 
	
	ORDER BY D.DocRowNo'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
