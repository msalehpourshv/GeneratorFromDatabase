USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================
create  PROCEDURE [pln].[RptPln_ProductGoods_StepsSub]
	@ProductID		VarChar(20) 
WITH ENCRYPTION
AS

BEGIN
	SET NOCOUNT ON;
	
SELECT  H.ProduceMethodName , P.*, isnull(D.DepartmentName, '') DepartmentName
 FROM pln.tblProduceStepDtl P LEFT JOIN prs.tblDepartmentsDtl D 
 ON P.DepartmentID = D.DepartmentID 
 inner join  pln.tblProduceStepHdr H on H.ProductID = P.ProductID AND H.SerialNo=P.SerialNo    And H.IsDefaultMethod = 1
  WHERE P.ProductID = @ProductID
 
  ORDER BY P.DocRowNo
 
 
 END
GO
