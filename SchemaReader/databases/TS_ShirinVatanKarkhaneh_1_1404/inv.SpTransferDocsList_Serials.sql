USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/01/07
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Inv Transfer Docs
-- ----------------------------------------------
--  موجودی آخر دوره انبار جهت انتقال
-- ==============================================
Create PROCEDURE [inv].[SpTransferDocsList_Serials]

WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarchar(Max)
DECLARE @fy			Int 
DECLARE @DbName 	NVarChar(100);

BEGIN

	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = IsNull(Sum(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart	

	SET @fy		= Cast(RIGHT(db_name(),4) As Int) + 1
	SET @DbName = SubString(DB_name(), 1, Len(DB_name()) - 4) + LTrim(RTrim(Str(@fy)))
	--=====================================
	
                ALTER TABLE inv.tblStorageDocsSerials DISABLE TRIGGER trgStorageDocsSerialsUpdate
                ALTER TABLE inv.tblStorageDocsSerials DISABLE TRIGGER trgtblStorageDocsSerialsUPDATE
                
				update  inv.tblStorageDocsSerials 
                set PSerialNo=''
                where PSerialNo='0'
                and PSerialNo<>''
				
				update  inv.tblStorageDocsSerials 
                set ProductSerialID=isnull(ProductSerialID,0)             

				ALTER TABLE inv.tblStorageDocsSerials Enable TRIGGER trgtblStorageDocsSerialsUPDATE
                ALTER TABLE inv.tblStorageDocsSerials Enable TRIGGER trgStorageDocsSerialsUpdate 


    if (select Count(*) from inv.tblGoods where HasSerial=1)>0
	--=====================================
	SET @StrSelect = '
	SELECT ProcessID, ProcessNo, FiscalYear, a.SerialNo, DocRowNo ,
		   Row_Number() Over(Partition by a.GoodsID order by a.GoodsID,DocRowNo) AtomRowNo,
		   Row_Number() Over(Partition by a.GoodsID order by a.GoodsID,DocRowNo) DocAtomRowNo,
		   c.ProductSerialID, 1 EventNo,b.StoreID,1 EnterKind, '''' BatchNo 
		   , b.PSerialNo
		   ,ContainerID	,ContainerStoresID,ProductionDate, b.ExpireDate,NumberPerContainer
	FROM ' + @DbName + '.inv.tblStorageDocsDtl a
	INNER JOIN 
	(
	SELECT StoreID,GoodsID,ProductSerialID ,PSerialNo,ContainerID,ContainerStoresID,ProductionDate,ExpireDate,Q NumberPerContainer 
		FROM (
		Select b.StoreID,GoodsID,a.ProductSerialID ,a.PSerialNo 
			,'''' ContainerID,'''' ContainerStoresID,'''' ProductionDate, '''' ExpireDate			
			, SUM(case when b.EnterKind =0 then a.EnterKind else b.EnterKind  end )  Q
		From inv.tblStorageDocsSerials a
		Inner Join inv.tblStorageDocsDtl b On a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
		Group By b.StoreID,GoodsID,a.ProductSerialID ,a.PSerialNo 
	) a
		GROUP BY StoreID,GoodsID,ProductSerialID,PSerialNo,ContainerID,ContainerStoresID,ProductionDate, ExpireDate,Q
		Having Abs(SUM(Q))>0.00001
	) b on a.GoodsID = b.GoodsID and a.StoreID = b.StoreID
	Left JOIN pln.tblProductSerials c ON c.ProductSerialID=b.ProductSerialID
	WHERE ProcessID = 50 and a.DocDate = ''' + LTrim(RTrim(Str(@fy))) + '/01/01''
	ORDER BY PSerialNo,StoreID,a.GoodsID,b.ProductSerialID,ContainerID,ContainerStoresID,ProductionDate, ExpireDate'	
	else
		--=====================================
	SET @StrSelect = '
	SELECT ProcessID, ProcessNo, FiscalYear, a.SerialNo, DocRowNo ,
		   Row_Number() Over(Partition by a.GoodsID order by a.GoodsID,DocRowNo) AtomRowNo,
		   Row_Number() Over(Partition by a.GoodsID order by a.GoodsID,DocRowNo) DocAtomRowNo,
		   c.ProductSerialID, 1 EventNo,b.StoreID,1 EnterKind, '''' BatchNo 
		   , b.PSerialNo
		   ,ContainerID	,ContainerStoresID,ProductionDate, b.ExpireDate,NumberPerContainer
	FROM ' + @DbName + '.inv.tblStorageDocsDtl a
	INNER JOIN 
	(
		SELECT StoreID,GoodsID,ProductSerialID,PSerialNo,ContainerID,ContainerStoresID,ProductionDate,ExpireDate,Q NumberPerContainer 
		FROM (
		Select b.StoreID,GoodsID,'''' ProductSerialID,''''PSerialNo 
			,a.ContainerID,ContainerStoresID,ProductionDate, a.ExpireDate			
			, SUM(case when ContainerID<>'''' then NumberPerContainer * case when b.EnterKind =0 then a.EnterKind else b.EnterKind  end   else  1*case when b.EnterKind =0 then a.EnterKind else b.EnterKind  end end )  Q
		From inv.tblStorageDocsSerials a
		Inner Join inv.tblStorageDocsDtl b On a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
		Group By b.StoreID,GoodsID,a.ContainerID,ContainerStoresID,ProductionDate, a.ExpireDate			
	) a
		GROUP BY StoreID,GoodsID,ProductSerialID,PSerialNo,ContainerID,ContainerStoresID,ProductionDate, ExpireDate,Q
		Having Abs(SUM(Q))>0.00001
	) b on a.GoodsID = b.GoodsID and a.StoreID = b.StoreID
	Left JOIN pln.tblProductSerials c ON c.ProductSerialID=b.ProductSerialID
	WHERE ProcessID = 50 and a.DocDate = ''' + LTrim(RTrim(Str(@fy))) + '/01/01''
	ORDER BY PSerialNo,StoreID,a.GoodsID,b.ProductSerialID,ContainerID,ContainerStoresID,ProductionDate, ExpireDate'	
	
	Print @StrSelect
	EXEC sp_executesql @StrSelect;

END
GO
