USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hamid
-- Create date   : 93/09/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[FunVisitorGoodsRemain] 
(
	@GoodsID			VarChar(20) = Null,
	@VisitorAcntCode	VarChar(20) = Null,
	@DocDate			Char(10) = Null
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN
	
	Declare @GoodsRemain As Float
	SET @GoodsRemain = 0
	
	Select @GoodsRemain = 
	(
		Select 
		(Select SUM(GoodsQuantity*EnterKind) From inv.tblStorageDocsDtl (nolock) a
		 Where ProcessID in (50,55,60) AND a.GoodsID = SPD.GoodsID AND DocDate <= @DocDate) * VisitorPercent / 100 
		+
		(Select SUM(GoodsQuantity*EnterKind) From inv.tblStorageDocsDtl (nolock) b
		 Where ProcessID in (90,100) and b.VisitorAcntCode = SPD.VisitorAcntCode AND b.GoodsID = SPD.GoodsID AND DocDate <= @DocDate) Remain
		 From sal.tblVisitorPortionDtl SPD
		 Where VisitorAcntCode = @VisitorAcntCode AND GoodsID = @GoodsID
	)
	
	IF @GoodsRemain Is Null 
		Set @GoodsRemain = -1
		
	RETURN @GoodsRemain
	
END
GO
