USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1396/06/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش موجودی کالا ها به تفکیک انبار
-- ==============================================
CREATE PROCEDURE [inv].[RptKmpGoodsQty]
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
BEGIN
---- Declarations ---------------
	Declare @StrSelect			NVarChar(max);
	Declare @StrWhere			NVarChar(max);

	DECLARE	@LangID		Char(1);
	DECLARE	@SessionNo	Int; 
	DECLARE	@ReportID	Int;
	DECLARE	@UserID		Int;
	DECLARE	@Round		Int;

	DECLARE	@UserIsAdmin bit;

	Declare @GoodsID varchar(20)
	Declare @StoreID		Int 
		Declare @DateFr				char(10) 
		Declare @DateTo				char(10) 
		
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
		----------------------------------------------------

	SET @GoodsID	= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @StoreID	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @DateFr		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @DateTo		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	--select @GoodsID,@StoreID,@DateFr,@DateTo

	Set @StrWhere = ''
	IF (@GoodsID <> '')
		SET @StrWhere = @StrWhere + ' AND b.GoodsID='''+ @GoodsID +''''
	IF (@StoreID > 0)
	
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @StoreID, 'b.StoreID') 
		
	IF (@DateFr Is Not Null) And (@DateFr <> '')
		set @StrWhere = @StrWhere + ' AND (a.DocDate >= ''' + @DateFr + ''')';
	
	IF (@DateTo Is Not Null) And (@DateTo <> '')
		set @StrWhere = @StrWhere + ' AND (a.DocDate <= ''' + @DateTo + ''')';
		
	set @Round = 1;

	select @Round = SettingValue
	from pub.tblSettings
	where SettingKey = 'QuantityDecimals'


SET @StrSelect = '
	SELECT GoodsID [کد کالا] ,[192][ورود] ,[193][خروج] ,Var4 [پسکرایه], Averge [وزن میانگین], DriverID[راننده], 
		   DocDate[تاریخ],[pub].[funGetGoodsName](GoodsID,1) [نام کالا] 
	FROM
		( 
			select GoodsID, ProcessID, Qty, Var4, Averge, DriverID, DocDate
			from
			(
				Select b.GoodsID, b.ProcessID, sum(GoodsQuantity * EnterKind) Qty, Var4, a.DriverID,a.DocDate, 
					   b.SubUnitQuantity / (Case When b.VirtualQuantity=0 Then 1 Else b.VirtualQuantity End) Averge
				From inv.tblStorageDocsDtl b 
				Inner Join inv.tblStorageDocsHdr a On a.ProcessID = b.ProcessID and a.ProcessNo = b.ProcessNo and 
													  a.FiscalYear = b.FiscalYear and a.SerialNo = b.SerialNo
				Where 1 = 1 ' + @StrWhere + '
				Group By  GoodsID, b.ProcessID, Var4, b.SubUnitQuantity, b.VirtualQuantity, a.DriverID, a.DocDate
			) T
		) P	
	PIVOT 
		(
			Sum(P.Qty)
			for P.ProcessID In ([192],[193])
		) AS PVT '

	Print @StrSelect
	Exec sp_executesql @StrSelect; 
	
END
GO
