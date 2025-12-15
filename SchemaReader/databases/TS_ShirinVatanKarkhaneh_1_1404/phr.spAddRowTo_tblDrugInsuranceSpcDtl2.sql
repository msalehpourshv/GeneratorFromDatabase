USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : REZA NOGREPASAND \ TakroSystem
-- Create date   : 1392/07/29
-- Viewed By	 : 
-- Last Modified : 1393/03/11
-- Last Modifier : REZA NOGHREPASAND
-- Description	 : 
-- ==============================================
create PROCEDURE [phr].[spAddRowTo_tblDrugInsuranceSpcDtl2]

	@InsuranceID VarChar(20),
	@InsuranceTypeID VarChar(20),
	@ProficiencyTypeID VarChar(20),
	@ProficiencyID VarChar(20),
	@GoodsID VarChar(20),
	@InsuranceIDNew VarChar(20),
	@InsuranceTypeIDNew VarChar(20),
	@ProficiencyTypeIDNew VarChar(20),
	@ProficiencyIDNew VarChar(20),
	@InsurancePercent FLOAT,
	@InsurancePrice float,
	@LastUpdateDate char(10),
	@InsuranceGenericID VarChar(20),
	@CurrenrDate char(10)
	
WITH ENCRYPTION
AS 
---- Declarations ---------------

--DECLARE	@RowNo		Int;
--DECLARE	@DocRowNo	Int;

DECLARE @Percent		 VarChar(50);
DECLARE @Price			 VarChar(50);
DECLARE	@ProfID			 VarChar(50);
DECLARE	@ProfTypeID		 VarChar(50);
DECLARE	@LastDate	  	 VarChar(50);
DECLARE	@IGenericID		 VarChar(50);
DECLARE	@GoodsIDNew		 VarChar(50);

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);


Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;
	
set @StrWhere= ' WHERE (1=1) '	

	
IF (@InsuranceID IS NOT null and @InsuranceID<>'')
		SET @StrWhere = @StrWhere + ' AND (InsuranceID=''' +  @InsuranceID + ''')'


IF (@InsuranceTypeID IS NOT null and @InsuranceTypeID<>'')
		SET @StrWhere = @StrWhere + ' AND (InsuranceTypeID=''' +  @InsuranceTypeID + ''')'

IF (@ProficiencyTypeID IS NOT null and @ProficiencyTypeID <>'')
		SET @StrWhere = @StrWhere + ' AND (ProficiencyTypeID=''' +  @ProficiencyTypeID + ''')'


IF (@ProficiencyID IS NOT null and @ProficiencyID<>'')
		SET @StrWhere = @StrWhere + ' AND (ProficiencyID=''' +  @ProficiencyID + ''')'

IF (@GoodsID IS NOT null and @GoodsID<>'')
		SET @StrWhere = @StrWhere + ' AND (d.GoodsID=''' +  @GoodsID + ''')'


IF (@InsurancePercent >0)
		SET @Percent =rtrim(ltrim(str(@InsurancePercent)))
	else
		SET @Percent ='R.InsuranceCommitmentPercent' 
		 
IF (@InsurancePrice >0)
		SET @Price =rtrim(ltrim(str(@InsurancePrice)))
	else
		SET @Price ='R.InsuranceCommitmentAmount' 

IF (@ProficiencyTypeIDNew IS NOT null and @ProficiencyTypeIDNew <>'')
		SET @ProfTypeID =''''+ @ProficiencyTypeIDNew + ''''
	else
		SET @ProfTypeID = 'R.ProficiencyTypeID'
		

IF (@ProficiencyIDNew IS NOT null and @ProficiencyIDNew<>'')
		SET @ProfID = ''''+@ProficiencyIDNew +''''
	else
		SET @ProfID = 'R.ProficiencyID'
		
		 
IF (@LastUpdateDate IS NOT null and @LastUpdateDate<>'')
		SET @LastDate = ''''+ @LastUpdateDate +''''
	else
		SET @LastDate = 'R.LastUpdateDate'

		 
IF (@InsuranceGenericID IS NOT null and @InsuranceGenericID <>'')
		SET @IGenericID = ''''+ @InsuranceGenericID +''''
	else
		SET @IGenericID = 'R.InsuranceGenericID'

IF (@GoodsID IS NOT null and @GoodsID<>'' )
		SET @GoodsIDNew = ''''+ @GoodsID +''''
	else
		SET @GoodsIDNew = 'R.GoodsID'
		
	
		 
	set @StrSelect='INSERT INTO phr.tblDrugInsuranceSpcDtl
		(GoodsID, RowNo, DocRowNo, InsuranceID, ProficiencyTypeID,
		 InsuranceCommitmentAmount,InsuranceCommitmentPercent, InsuranceConditions,
		  NeedForConfirmation, HospitalDrug, InsurancePercentCal, LetInternetUpdate,
		   ProficiencyID, InsuranceCommitmentAmountOld,
		   LastUpdateDate, InsuranceTypeID, MaximumReciption,InsuranceGenericID,ModifyDate)
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
		  '''+@InsuranceIDNew+''','+ @ProfTypeID +', '+ @Price +',
			   '+ @Percent +', R.InsuranceConditions, R.NeedForConfirmation,
			   R.HospitalDrug, R.InsurancePercentCal, R.LetInternetUpdate,'+@ProfID+',
			   R.InsuranceCommitmentAmountOld, '+ @LastDate +','''+ @InsuranceTypeIDNew + ''',
			   R.MaximumReciption,'+ @IGenericID +','''+@CurrenrDate + '''
		FROM
		(SELECT d.GoodsID, d.RowNo, d.DocRowNo, d.InsuranceID, d.ProficiencyTypeID,
		d.InsuranceCommitmentAmount, d.InsuranceCommitmentPercent, d.InsuranceConditions,
		 d.NeedForConfirmation, d.HospitalDrug, d.InsurancePercentCal, d.LetInternetUpdate,
		  d.ProficiencyID, d.InsuranceCommitmentAmountOld, d.LastUpdateDate, d.InsuranceTypeID,
		   d.MaximumReciption,g.GenericID,d.InsuranceGenericID
		 FROM phr.tblDrugInsuranceSpcDtl d
		INNER JOIN inv.tblGoods g
		ON d.GoodsID=g.GoodsID
		'+ @StrWhere +') R	'
		

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
		set @StrSelect='SELECT count(*)
		FROM
		(SELECT d.GoodsID, d.RowNo, d.DocRowNo, d.InsuranceID, d.ProficiencyTypeID,
		d.InsuranceCommitmentAmount, d.InsuranceCommitmentPercent, d.InsuranceConditions,
		 d.NeedForConfirmation, d.HospitalDrug, d.InsurancePercentCal, d.LetInternetUpdate,
		  d.ProficiencyID, d.InsuranceCommitmentAmountOld, d.LastUpdateDate, d.InsuranceTypeID,
		   d.MaximumReciption,g.GenericID,d.InsuranceGenericID
		 FROM phr.tblDrugInsuranceSpcDtl d
		INNER JOIN inv.tblGoods g
		ON d.GoodsID=g.GoodsID
		'+ @StrWhere +') R	'
	EXEC sp_executesql @StrSelect;
	
	
End
GO
