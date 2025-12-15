USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/07/29
-- Viewed By	 : 
-- Last Modified : 1392/11/23
-- Last Modifier : REZA NOGHREPASAND
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [phr].[spAddRowTo_tblDrugInsuranceSpcDtl]

	@InsuranceID VarChar(20),
	@InsuranceTypeID VarChar(20),
	@InsuranceIDNew VarChar(20),
	@InsuranceTypeIDNew VarChar(20),
	@InsurancePercent FLOAT
	
WITH ENCRYPTION
AS 
---- Declarations ---------------
--Declare @StrSelect	NVarChar(4000);
--DECLARE	@RowNo		Int;
--DECLARE	@DocRowNo	Int;


Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;
	
IF @InsurancePercent=0
	BEGIN
				
		INSERT INTO phr.tblDrugInsuranceSpcDtl(GoodsID, RowNo, DocRowNo, InsuranceID, ProficiencyTypeID, InsuranceCommitmentAmount, InsuranceCommitmentPercent, InsuranceConditions, NeedForConfirmation, HospitalDrug, InsurancePercentCal, LetInternetUpdate, ProficiencyID, InsuranceCommitmentAmountOld, LastUpdateDate, InsuranceTypeID, MaximumReciption,InsuranceGenericID)
		SELECT R.GoodsID ,
			
				(SELECT  IsNull(Max(RowNo),0)
				
				FROM phr.tblDrugInsuranceSpcDtl 
				WHERE GoodsID=R.GoodsID)+
				(ROW_NUMBER () OVER (PARTITION BY GoodsID ORDER BY   RowNo)) 
			,
			(SELECT  IsNull(Max(DocRowNo),0)
				FROM  phr.tblDrugInsuranceSpcDtl 
				WHERE  GoodsID=R.GoodsID)+
				(ROW_NUMBER () OVER (PARTITION BY GoodsID ORDER BY   DocRowNo))
			,
				@InsuranceIDNew, R.ProficiencyTypeID, R.InsuranceCommitmentAmount,
				R.InsuranceCommitmentPercent, R.InsuranceConditions, R.NeedForConfirmation,
				R.HospitalDrug, R.InsurancePercentCal, R.LetInternetUpdate, R.ProficiencyID,
				R.InsuranceCommitmentAmountOld, R.LastUpdateDate, @InsuranceTypeIDNew,
				R.MaximumReciption,R.GenericID
		FROM
		(
			SELECT d.GoodsID, d.RowNo, d.DocRowNo, d.InsuranceID, d.ProficiencyTypeID,
				d.InsuranceCommitmentAmount, d.InsuranceCommitmentPercent, d.InsuranceConditions,
				d.NeedForConfirmation, d.HospitalDrug, d.InsurancePercentCal, d.LetInternetUpdate,
				d.ProficiencyID, d.InsuranceCommitmentAmountOld, d.LastUpdateDate, d.InsuranceTypeID,
				d.MaximumReciption,g.GenericID
			FROM phr.tblDrugInsuranceSpcDtl d
					INNER JOIN inv.tblGoods g ON d.GoodsID=g.GoodsID
			WHERE InsuranceID = @InsuranceID AND InsuranceTypeID = @InsuranceTypeID
		) R
	
	END --end if percent=0
	
		
		
   IF @InsurancePercent>0
		BEGIN
			INSERT INTO phr.tblDrugInsuranceSpcDtl
		(GoodsID, RowNo, DocRowNo, InsuranceID, ProficiencyTypeID, InsuranceCommitmentAmount,
		 InsuranceCommitmentPercent, InsuranceConditions, NeedForConfirmation, HospitalDrug,
		  InsurancePercentCal, LetInternetUpdate, ProficiencyID, InsuranceCommitmentAmountOld,
		   LastUpdateDate, InsuranceTypeID, MaximumReciption,InsuranceGenericID)
		SELECT R.GoodsID ,
		
				(SELECT  IsNull(Max(RowNo),0)
				
				FROM phr.tblDrugInsuranceSpcDtl 
				WHERE GoodsID=R.GoodsID)+
				(ROW_NUMBER () OVER (PARTITION BY GoodsID ORDER BY   RowNo)) 
				,
			
				(SELECT  IsNull(Max(DocRowNo),0)
				FROM  phr.tblDrugInsuranceSpcDtl 
				WHERE  GoodsID=R.GoodsID)+
				(ROW_NUMBER () OVER (PARTITION BY GoodsID ORDER BY   DocRowNo))
				
		  ,
		  @InsuranceIDNew,R.ProficiencyTypeID, R.InsuranceCommitmentAmount,
			   @InsurancePercent, R.InsuranceConditions, R.NeedForConfirmation,
			   R.HospitalDrug, R.InsurancePercentCal, R.LetInternetUpdate, R.ProficiencyID,
			   R.InsuranceCommitmentAmountOld, R.LastUpdateDate, @InsuranceTypeIDNew,
			   R.MaximumReciption,R.GenericID
		FROM
		(SELECT d.GoodsID, d.RowNo, d.DocRowNo, d.InsuranceID, d.ProficiencyTypeID,
		d.InsuranceCommitmentAmount, d.InsuranceCommitmentPercent, d.InsuranceConditions,
		 d.NeedForConfirmation, d.HospitalDrug, d.InsurancePercentCal, d.LetInternetUpdate,
		  d.ProficiencyID, d.InsuranceCommitmentAmountOld, d.LastUpdateDate, d.InsuranceTypeID,
		   d.MaximumReciption,g.GenericID
		 FROM phr.tblDrugInsuranceSpcDtl d
		INNER JOIN inv.tblGoods g
		ON d.GoodsID=g.GoodsID
		WHERE InsuranceID = @InsuranceID AND InsuranceTypeID = @InsuranceTypeID) R	
		

END --end if percent>0
	



End
GO
