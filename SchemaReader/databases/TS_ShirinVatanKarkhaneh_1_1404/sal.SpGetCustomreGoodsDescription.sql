USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[SpGetCustomreGoodsDescription]
	
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(4000);

BEGIN
	SET NOCOUNT ON;

begin try
if (select COUNT(*)  from sys.tables where name='tbl_CDescriptionTmp')=0
BEGIN
	
	CREATE TABLE sal.tbl_CDescriptionTmp
	(
		GoodsID VarChar(20) Collate arabic_cs_as NOT NULL,
		CustomerKindID VarChar(20) Collate arabic_cs_as NOT NULL,
		CDescription NVarChar(1000) NOT NULL,
		SerialNo Int
	)

	CREATE NONCLUSTERED INDEX [IX_sal.tbl_CDescriptionTmp_GoodsID_CustomerKindID] 
	ON sal.tbl_CDescriptionTmp( GoodsID,CustomerKindID) 
	 WITH (PAD_INDEX = OFF,
	STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, 
	 ONLINE = OFF,DROP_EXISTING = OFF, ALLOW_ROW_LOCKS = ON,ALLOW_PAGE_LOCKS  = ON)
	ON [PRIMARY]

END

if (select COUNT(*)  from sys.tables where name='tbl_CDescription')=0
BEGIN
	CREATE TABLE sal.tbl_CDescription
	(
		GoodsID VarChar(20) Collate arabic_cs_as NOT NULL,
		CustomerKindID VarChar(20) Collate arabic_cs_as NOT NULL,
		CDescription NVarChar(1000) NOT NULL,
		SerialNo Int
	)

	CREATE NONCLUSTERED INDEX [IX_sal.tbl_CDescription_GoodsID_CustomerKindID] 
	ON sal.tbl_CDescription( GoodsID,CustomerKindID) 
	 WITH (PAD_INDEX = OFF,
	STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, 
	 ONLINE = OFF,DROP_EXISTING = OFF, ALLOW_ROW_LOCKS = ON,ALLOW_PAGE_LOCKS  = ON)
	ON [PRIMARY]

END
END Try
BEGIN catch
END catch

	delete from sal.tbl_CDescriptionTmp
	delete from sal.tbl_CDescription

	DECLARE @GoodsID VarChar(20),
			@CustomerKindID VarChar(20)
			
	DECLARE My_Cursor CURSOR FOR
	SELECT CustomerKindID
	from sal.tblCustomerKinds b
	WHERE CustomerKindID <> ''

		OPEN My_Cursor
		FETCH NEXT FROM My_Cursor INTO  @CustomerKindID

		WHILE @@Fetch_Status = 0 
		Begin
			SET @StrSelect = ' INSERT INTO sal.tbl_CDescriptionTmp
					SELECT Distinct GoodsID, ''' + @CustomerKindID +  ''', Description' + @CustomerKindID + ',SerialNo
					FROM sal.tblGoodsPriceForCustomerKindDtl
					ORDER BY SerialNo Desc'
					
			EXEC sp_executesql @StrSelect;
					
			FETCH NEXT FROM My_Cursor INTO @CustomerKindID
		END
	
		CLOSE My_Cursor
		DEALLOCATE My_Cursor
	INSERT INTO sal.tbl_CDescription
	SELECT DISTINCT a.GoodsID,a.CustomerKindID,a.CDescription,0 from (
	SELECT  a.GoodsID,a.CustomerKindID,a.CDescription ,ROW_NUMBER()over(PARTITION by b.GoodsID,b.CustomerKindID Order by b.GoodsID,b.CustomerKindID)RowNo
	FROM sal.tbl_CDescriptionTmp a
	inner join (select b.GoodsID,b.CustomerKindID,b.CDescription,MAX(b.SerialNo) SerialNo 
	from sal.tbl_CDescriptionTmp b 
	group by b.GoodsID,b.CustomerKindID,b.CDescription
	) b
	On a.GoodsID=b.GoodsID AND a.CustomerKindID=b.CustomerKindID and a.SerialNo=b.SerialNo 
	) a
	where RowNo=1
	
	SELECT * from 	sal.tbl_CDescription		
END
--sal.SpGetCustomreGoodsDescription
GO
