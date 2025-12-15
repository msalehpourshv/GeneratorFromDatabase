USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hadi Sadeghi
-- Creation Date : 1401/07-02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- ==============================================
Create PROCEDURE [inv].[SpMergeStoresNumeration]
	@Serials			VarChar(max) = '1,2', 
	@StoreID			VarChar(300) = '0201', 
	@Options			VarChar(10) = '110', 
	@Info			NVarChar(100) = '1@1@1' 
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE	@SelectedService2	Int; 
DECLARE	@SelectedService3	Int; 
DECLARE	@SelectedService4	Int; 

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;


BEGIN TRY
	Drop Table   ##StoresNumeration
END TRY
BEGIN CATCH
END CATCH


	-- Select Clause ----------------------------------------
	SET @StrSelect = '
	SELECT   SerialNo, RowNo, DocDate, StoreID, GoodsID, DescDtl, DocRowNo, SubUnitID, GoodsQuantity, SubUnitQuantity, BatchNo, UserPriceID ,
              ROW_NUMBER()over(order by GoodsID,SerialNo,DocRowNo) R 
	INTO ##StoresNumeration
	FROM inv.tblStoresNumerationDtl
	WHERE StoreID=''' + @StoreID + ''' AND SerialNo IN (' + @Serials + ')'

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------

	if (select COUNT(*) from ##StoresNumeration )=0
		return 

	DECLARE @maxSerial as int
	DECLARE @maxDate as varchar(10)

	select @maxSerial =max(SerialNo)  from [inv].[tblStoresNumerationHdr]

	SEt @maxSerial = @maxSerial + 1

	select @maxDate =max(DocDate)  from ##StoresNumeration


	INSERT INTO [inv].[tblStoresNumerationHdr]
	(SerialNo, DocDate, StoreID, DocDesc, RecID, SessionNo, OldSerialNo, TransferSerialNo, IsAutoDoc)
	select @maxSerial,@maxDate,@StoreID,'ادغام برگه های' + @Serials ,0,0,0,'','True'

	INSERT INTO inv.tblStoresNumerationDtl
	(SerialNo, RowNo, DocDate, StoreID, GoodsID, DescDtl, DocRowNo, SubUnitID, GoodsQuantity, SubUnitQuantity, BatchNo, UserPriceID )
	SELECT @maxSerial SerialNo,R RowNo,@maxDate DocDate, a.StoreID, a.GoodsID, a.DescDtl,R DocRowNo, a.SubUnitID, a.GoodsQuantity, a.SubUnitQuantity, a.BatchNo, a.UserPriceID 
	FROM inv.tblStoresNumerationDtl a
	INNER JOIN ##StoresNumeration b
	ON a.SerialNo=b.SerialNo and a.RowNo=b.RowNo

	INSERT INTO  [inv].[tblStoresNumerationSerials]
	(SerialNo, DocRowNo, AtomRowNo, DocAtomRowNo, ProductSerialID, EventNo, BatchNo, ExpireDate, PSerialNo, StoreID, EnterKind, NumberPerSerial, ContainerID, NumberPerContainer, SerialDesc, ContainerWeight, ContainerID2,ContainerStoresID,ProductionDate)
	SELECT @maxSerial SerialNo, R DocRowNo, AtomRowNo, DocAtomRowNo, ProductSerialID, EventNo, a.BatchNo, ExpireDate, PSerialNo, a.StoreID, EnterKind, NumberPerSerial, ContainerID, NumberPerContainer, SerialDesc, ContainerWeight, ContainerID2,ContainerStoresID,ProductionDate
	FROM inv.tblStoresNumerationSerials a
	INNER JOIN ##StoresNumeration b
	ON a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo


	update [inv].[tblStoresNumerationSerials]
	set AtomRowNo= R+1000000
	from [inv].[tblStoresNumerationSerials] a
	inner join 
	(
	select ROW_NUMBER()over(order by SerialNo,DocRowNo,AtomRowNo) R,*
	from inv.[tblStoresNumerationSerials]
	where SerialNo=@maxSerial
	)b
	on a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo and a.AtomRowNo=b.AtomRowNo

	where a.SerialNo=@maxSerial

	update [inv].[tblStoresNumerationSerials]
	set AtomRowNo= AtomRowNo-1000000
	where SerialNo=@maxSerial

End
GO
