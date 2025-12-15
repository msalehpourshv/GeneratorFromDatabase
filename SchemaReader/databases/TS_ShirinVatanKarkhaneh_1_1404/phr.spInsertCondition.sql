USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-PHR:NOTOK ========================
-- Author        : Reza Nogrepasand
-- Create date   : 92/11/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE [phr].[spInsertCondition]

@GoodsID as VARCHAR(20),
@InsuranceID AS VARCHAR(20),
@InsuranceTypeID AS VARCHAR(20),
@ProficiencyTypeID as VARCHAR(20),
@ProficiencyID as VARCHAR(20),
@InsuranceCommitmentAmount AS FLOAT,
@InsuranceCommitmentPercent AS FLOAT,
@InsuranceConditions AS NVARCHAR(500),
@NeedForConfirmation AS BIT,
@HospitalDrug AS BIT,
@InsuranceCommitmentAmountOld AS FLOAT,
@LastUpdateDate AS CHAR(10),
@InsuranceGenericID as VARCHAR(20),
@CurrenrDate   AS CHAR(10)


WITH ENCRYPTION
 AS
BEGIN

	 
 BEGIN TRY

	DECLARE @RowNo AS INT
	DECLARE @DocRowNo AS INT
	DECLARE @OldAmount AS float
	
	set @OldAmount=0;


	SELECT @RowNo=isnull(max(RowNo),0) FROM phr.tblDrugInsuranceSpcDtl	
	WHERE GoodsID=@GoodsID 
	SET @RowNo=@RowNo+1
	
	SELECT @DocRowNo=isnull(max(DocRowNo),0) FROM phr.tblDrugInsuranceSpcDtl	
	WHERE GoodsID=@GoodsID
	SET @DocRowNo=@DocRowNo+1
	
	
	
	--  =====================================
	 IF  (SELECT COUNT(*) FROM phr.tblDrugInsuranceSpcDtl 
          WHERE GoodsID=@GoodsID
          AND InsuranceID=@InsuranceID
          AND InsuranceTypeID=@InsuranceTypeID
          AND ProficiencyTypeID=@ProficiencyTypeID
          AND  ProficiencyID =@ProficiencyID)>0
    BEGIN
    	SELECT @RowNo=RowNo FROM phr.tblDrugInsuranceSpcDtl 
          WHERE GoodsID=@GoodsID
          AND InsuranceID=@InsuranceID
          AND InsuranceTypeID=@InsuranceTypeID
          AND ProficiencyTypeID=@ProficiencyTypeID
          AND  ProficiencyID =@ProficiencyID
          
          SELECT @DocRowNo=DocRowNo FROM phr.tblDrugInsuranceSpcDtl 
          WHERE GoodsID=@GoodsID
          AND InsuranceID=@InsuranceID
          AND InsuranceTypeID=@InsuranceTypeID
          AND ProficiencyTypeID=@ProficiencyTypeID
          AND  ProficiencyID =@ProficiencyID


     -- یافتن مقدار قدیمی قبلی =================
		if @InsuranceCommitmentAmountOld=0
		 select top 1 @OldAmount= InsuranceCommitmentAmount
			from phr.tblDrugInsuranceSpcDtl
			 WHERE GoodsID=@GoodsID
			  AND InsuranceID=@InsuranceID
			  AND InsuranceTypeID=@InsuranceTypeID
			  AND ProficiencyTypeID=@ProficiencyTypeID
			  AND  ProficiencyID =@ProficiencyID   
		 else
			 set @OldAmount=@InsuranceCommitmentAmountOld
		--======================================
			
		
		-- حذف سطر قدیمی			      
      DELETE FROM  phr.tblDrugInsuranceSpcDtl
         WHERE GoodsID=@GoodsID
          AND InsuranceID=@InsuranceID
          AND InsuranceTypeID=@InsuranceTypeID
          AND ProficiencyTypeID=@ProficiencyTypeID
          AND  ProficiencyID =@ProficiencyID   	
		
	
	END
                    
	-- ======================================
	
		INSERT INTO phr.tblDrugInsuranceSpcDtl
		(GoodsID, RowNo, DocRowNo, InsuranceID, ProficiencyTypeID,
		InsuranceCommitmentAmount, InsuranceCommitmentPercent, InsuranceConditions,
		NeedForConfirmation, HospitalDrug, InsurancePercentCal, LetInternetUpdate,
		InsuranceCommitmentAmountOld, LastUpdateDate, ProficiencyID, InsuranceTypeID,
		MaximumReciption, InsuranceGenericID,ModifyDate)
	VALUES(@GoodsID, @RowNo, @DocRowNo, @InsuranceID, @ProficiencyTypeID,
       @InsuranceCommitmentAmount, @InsuranceCommitmentPercent, @InsuranceConditions,
       @NeedForConfirmation, @HospitalDrug, 0, 0,
       @OldAmount, @LastUpdateDate, @ProficiencyID,
       @InsuranceTypeID, 0, @InsuranceGenericID,@CurrenrDate)
			
END TRY

	BEGIN CATCH
	
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage,16,1)

	END CATCH
 
END
GO
