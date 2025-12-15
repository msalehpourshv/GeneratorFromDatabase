USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 14010/12/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier :  
-- Description	 : مانده محصول و ضایعات  ارسال به تولید             
-- ==============================================
Create FUNCTION prd.funPrd_ReceiveProduct	
	(@ProcessID int,
	@ProcessNo int,
	@FiscalYear int,
	@SerialNo int ,
	@DocDateFr Char(10) = Null,
	@DocDateTo Char(10) = Null
	)RETURNS	@tblProduct Table 
		(	
		ProcessID		int,
		ProcessNo		int,
		FiscalYear		int,
		SerialNo		int,
		ProductID		VarChar(20) COLLATE Arabic_CS_AS,		
		GoodsQuantity	float,
		UnitID			VarChar(20) COLLATE Arabic_CS_AS	
		) 
	WITH ENCRYPTION
AS 
Begin 

DECLARE	@LangID	Char(1);
DECLARE	@ProductCount	float;
DECLARE	@ProductID	VarChar(20)
DECLARE	@FormulaNo	int
DECLARE @UnitPart TINYINT

SET @UnitPart  = 1
--SET @SerialNo = ''
SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

IF @UnitPart IS NULL or @UnitPart = 0
	SET @UnitPart = 1

DECLARE @str_Goods  tinyint,
		@str_GoodsSum tinyint

select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
from pub.tblCodeLayer 
where TableName='inv.tblGoods' AND PartNumber<@UnitPart

select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
from pub.tblCodeLayer 
where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

Select	@ProductCount=H.ProductCount-[prd].[funMaxRetProduct](ProcessID,ProcessNo,FiscalYear,SerialNo,0) 
, @ProductID=ProductID,@FormulaNo=FormulaNo
	From inv.tblStorageDocsHdr H
		Where H.ProcessID = @ProcessID and H.ProcessNo = @ProcessNo and H.FiscalYear = @FiscalYear and  H.SerialNo=@SerialNo
		and (isnull(@DocDateFr, '')='' or DocDate>=isnull(@DocDateFr, ''))
		and (isnull(@DocDateTo, '')='' or DocDate<=isnull(@DocDateTo, ''))
		--select @ProductCount,@ProductID,@FormulaNo
insert into @tblProduct
	select  @ProcessID,@ProcessNo,@FiscalYear, @SerialNo, ProductID, ProductCount*@ProductCount/ ProductCount  GoodsQuantity   ,a.UnitID
		from  prd.tblFormulasHdr b	
		inner join inv.tblGoods a on a.GoodsID=SUBSTRING(b.ProductID,@str_Goods+1, @str_GoodsSum) 
		where b.ProductID=@ProductID and b.SerialNo=@FormulaNo
Union all
	select   @ProcessID,@ProcessNo,@FiscalYear, @SerialNo,GoodsID , GoodsQuantity *@ProductCount/ ProductCount,UnitID
		from prd.tblSecondaryProductByFormulaDtl a
		inner join  prd.tblFormulasHdr b on a.ProductID=b.ProductID and a.SerialNo=b.SerialNo
		where b.ProductID=@ProductID and b.SerialNo=@FormulaNo
IF (SELECT COUNT(*) FROM @tblProduct)=0
insert into @tblProduct
	SELECT @ProcessID,@ProcessNo,@FiscalYear, @SerialNo, @ProductID, @ProductCount ,UnitID
    FROM inv.tblGoods  where GoodsID=@ProductID

update @tblProduct 
	Set GoodsQuantity=p.GoodsQuantity  - isnull(d.GoodsQuantity,0) 
		From  @tblProduct p
		inner join  ( select Sum(GoodsQuantity)  GoodsQuantity,GoodsID  from inv.tblStorageDocsDtl H
						Where H.BaseProcessID = @ProcessID and H.BaseProcessNo = @ProcessNo and H.BaseFiscalYear = @FiscalYear and  H.BaseSerialNo=@SerialNo 
							and (isnull(@DocDateFr, '')='' or DocDate>=isnull(@DocDateFr, ''))
							and (isnull(@DocDateTo, '')='' or DocDate<=isnull(@DocDateTo, ''))
						group by GoodsID) d
		on p.ProductID=d.GoodsID	

	delete  from @tblProduct  where GoodsQuantity<=0

	RETURN

END
GO
