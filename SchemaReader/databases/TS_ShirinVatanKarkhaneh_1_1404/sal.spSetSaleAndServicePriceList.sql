USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 97/02/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[spSetSaleAndServicePriceList]
	@CustomerKindID		Varchar(20)

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	update sal.tblSaleAndServicePriceListDtl
	set Var1 = b.Var1,
		Var2 = b.Var2,
		Var3 = b.Var3,
		Var4 = b.Var4,
		Var5 = b.Var5,
		Var6 = b.Var6,
		Var7 = b.Var7,
		Var8 = b.Var8,
		Var9 = b.Var9,
		Var10 = b.Var10
	from sal.tblSaleAndServicePriceListDtl a
	inner join (SELECT * from sal.tblSaleAndServicePriceListDtl where CustomerKindID = @CustomerKindID) b
	on a.GoodsID=b.GoodsID and a.GoodsID2=b.GoodsID2
	where a.CustomerKindID <> @CustomerKindID
	
	
	Declare	curCustomerKind CURSOR For 
	SELECT	CustomerKindID
	FROM sal.tblCustomerKinds
	where CustomerKindID <> @CustomerKindID and CustomerKindID <>''

	declare @CustomerKindID1	Varchar(20)
	declare @MaxRowNo			INT
	declare @MaxDocRowNo			INT

	Open  curCustomerKind; 

	Fetch NEXT From curCustomerKind Into @CustomerKindID1

	While (@@Fetch_Status = 0)
		BEGIN

			IF (select COUNT(*) from sal.tblSaleAndServicePriceListHdr where CustomerKindID=@CustomerKindID1 )=0
				INSERT INTO sal.tblSaleAndServicePriceListHdr (CustomerKindID) select @CustomerKindID1

			select @MaxRowNo = ISNULL(MAX(RowNo),0) from sal.tblSaleAndServicePriceListDtl where CustomerKindID = @CustomerKindID1
			select @MaxDocRowNo = ISNULL(MAX(DocRowNo),0) from sal.tblSaleAndServicePriceListDtl where CustomerKindID = @CustomerKindID1
			
			insert into sal.tblSaleAndServicePriceListDtl
			(CustomerKindID, RowNo, DocRowNo, LastBuyPrice, GoodsID, GoodsID2, ServicePrice, Var1, Var2, Var3, Var4, Var5, Var6, Var7, Var8, Var9, Var10, Weight)--,SalTyp01,SalTyp02,SalTyp03)
	
			select @CustomerKindID1 CustomerKindID,@MaxRowNo+ ROW_NUMBER()over(order by  CustomerKindID) RowNo,@MaxDocRowNo+ ROW_NUMBER()over(order by  CustomerKindID) DocRowNo, LastBuyPrice, a.GoodsID, a.GoodsID2, ServicePrice, Var1, Var2, Var3, Var4, Var5, Var6, Var7, Var8, Var9, Var10, Weight--,SalTyp01,SalTyp02,SalTyp03
			from sal.tblSaleAndServicePriceListDtl a inner join (
			select  GoodsID, GoodsID2 from sal.tblSaleAndServicePriceListDtl where CustomerKindID = @CustomerKindID
			except
			select  GoodsID, GoodsID2 from sal.tblSaleAndServicePriceListDtl where CustomerKindID = @CustomerKindID1) b
			ON a.GoodsID=b.GoodsID and a.GoodsID2=b.GoodsID2
			WHERE a.CustomerKindID = @CustomerKindID

			Fetch NEXT From curCustomerKind Into @CustomerKindID1
		END
	Close curCustomerKind;
	Deallocate curCustomerKind; 	
				
END
GO
