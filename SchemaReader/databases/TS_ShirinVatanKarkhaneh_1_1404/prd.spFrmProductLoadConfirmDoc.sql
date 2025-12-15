USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/02/03
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [prd].[spFrmProductLoadConfirmDoc]
 	@ProcessID		tinyint,
 	@ProcessNo		tinyint,
 	@FiscalYear	smallint,
 	@SerialNo		int,
 	@DocStep		tinyint,
 	@DocDate		Char(10),
 	@AcntCode		Varchar(20),
 	@StoreID		Varchar(20),
 	@LanguageID	Tinyint
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;

	SELECT *  --,[inv].[funGetSubUnitFromGoodsQuantity](GoodsID,SubUnitID,SendQty - ReciveQty - RetQty) SubUnitQuantity
	FROM 
		(
			SELECT	OD.ProcessID, OD.ProcessNo, OD.FiscalYear, OD.SerialNo, RowNo, OD.DocRowNo, VolumeRowNo, OD.DocStep, OD.DocDate, OD.StoreID, 
					PhysicallyEffected, EnterKind, OD.StoreID2, OD.AcntCode, OD.VisitorAcntCode, OD.OrderAcntCode, GoodsID, SubUnitID, 
					OD.GoodsQuantity, OD.GoodsQuantity SendQty,
					Round(((
							IsNull((
									Select SUM(GoodsQuantity)
									From inv.tblStorageDocsDtl D
									Where D.ProcessID = 80 And D.BaseProcessID = 70 And 
										  D.BaseProcessNo  = OD.ProcessNo And 
										  D.BaseFiscalYear = OD.FiscalYear And 
										  D.BaseSerialNo   = OD.SerialNo And 
										  D.GoodsID = OH.ProductID
									),0)) * OD.GoodsQuantity) /  case when OH.ProductCount=0 then 1 else OH.ProductCount end, 3) ReciveQty,
												
					Round(((OH.ProductCount -
							IsNull((
									Select SUM(GoodsQuantity)
									From inv.tblStorageDocsDtl D
									Where D.ProcessID = 80 And D.BaseProcessID = 70 And 
										  D.BaseProcessNo  = OD.ProcessNo And 
										  D.BaseFiscalYear = OD.FiscalYear And 
										  D.BaseSerialNo   = OD.SerialNo
									),0)) * OD.GoodsQuantity) /  case when OH.ProductCount=0 then 1 else OH.ProductCount end, 3) SendRemain,
					IsNull((
							Select Sum(GoodsQuantity) GoodsQuantity
							From inv.tblStorageDocsDtl 
							Where ProcessID = 75 AND BaseProcessID = 70 AND BaseProcessNo = OD.ProcessNo And
								  BaseFiscalYear = OD.FiscalYear And BaseSerialNo = OD.SerialNo And
								  BaseDocRowNo = OD.DocRowNo
							),0) RetQty,							
				 QtyRemain, GoodsAmount, AtomAmount, GoodsPrice, DescDtl, 
					OD.BaseProcessID, OD.BaseProcessNo, OD.BaseFiscalYear, OD.BaseSerialNo, OD.BaseDocRowNo, OD.BaseDocType, OD.AgreeNo, 
					OD.BatchNo, DiscountPercentDtl, DiscountDtl, Cnf.ConfirmQuantity ConfirmQuantity1,
					[inv].[funGetTechnicalSpecifications](GoodsID) AS TechnicalSpecifications,
					pub.funGetGoodsName(GoodsID,@LanguageID) AS GoodsName, inv.funGetUnitName(SubUnitID,@LanguageID) AS SubUnitName,
					[inv].[funGetMaxGoodsRemain](OD.ProcessID,OD.ProcessNo,OD.FiscalYear,OD.SerialNo,OD.ProcessID,OD.ProcessNo,
					OD.FiscalYear,OD.SerialNo,OD.DocRowNo,OD.StoreID,GoodsID,OD.BatchNo,OD.DocDate,1)  AS Remain
					,Round(Cnf2.GoodsQuantity  * OD.GoodsQuantity /  case when OH.ProductCount=0 then 1 else OH.ProductCount end, 5)  SubUnitQuantity 
					,Round(Cnf2.GoodsQuantity* OD.GoodsQuantity /  case when OH.ProductCount=0 then 1 else OH.ProductCount end, 5) 	ConfirmQuantity
			FROM  [prd].[FunGetProduct] (@AcntCode, @DocDate, @DocStep,@ProcessNo) Cnf 
			INNER JOIN inv.tblStorageDocsDtl AS OD
			ON	Cnf.ProcessID = OD.ProcessID AND Cnf.ProcessNo = OD.ProcessNo AND 
				Cnf.FiscalYear = OD.FiscalYear AND Cnf.SerialNo = OD.SerialNo AND 
				Cnf.DocRowNo = OD.DocRowNo 
			INNER JOIN inv.tblStorageDocsHdr AS OH
			ON	Cnf.ProcessID = OH.ProcessID AND Cnf.ProcessNo = OH.ProcessNo AND 
				Cnf.FiscalYear = OH.FiscalYear AND Cnf.SerialNo = OH.SerialNo
			inner join prd.funPrd_ReceiveProduct(@ProcessID,@ProcessNo,@FiscalYear,@SerialNo,'','')  Cnf2 
			 on Cnf.ProcessID = Cnf2.ProcessID AND Cnf.ProcessNo = Cnf2.ProcessNo AND 
				Cnf.FiscalYear = Cnf2.FiscalYear AND Cnf.SerialNo = Cnf2.SerialNo 
				AND OH.ProductID= Cnf2.ProductID
				
			WHERE Cnf.ConfirmQuantity > 0 AND Cnf.SerialNo = @SerialNo AND Cnf.FiscalYear = @FiscalYear AND 
				  OD.ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate 
		) A
END
GO
