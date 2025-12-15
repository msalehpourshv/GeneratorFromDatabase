USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1386/06/08
-- Viewed By	 : 
-- Last Modified : 1386/06/15
-- Last Modifier : TakroSystem\Zia
-- Description	 : �ѐ ��Ә��
-- ==============================================
CREATE PROCEDURE [inv].[RptTrd_Bascule_Docs]
	@ProcessID		Int,
	@SerialFr		Int = Null,
	@SerialTo		Int = Null,
	@OwnerDocNoFr	Int = Null,
	@OwnerDocNoTo	Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@RoadBillDateFr	char(10) = Null,
	@RoadBillDateTo	char(10) = Null,
	@RoadBillNoMask	varchar(20) = Null,
	@DriverID		varchar(20) = Null,
	@DriverNameMask	varchar(50) = Null,
	@VehicleTypeID	varchar(20) = Null,
	@VehicleNoMask	varchar(20) = Null,
	@LocationID		varchar(20) = Null,
	@SelectedStore	Int = Null,
	@SelectedGoods	Int = Null, -- ������ ����
	@SelectedAcnt1	Int = Null, -- ������ ��� ����
	@SelectedAcnt2	Int = Null,
	@SelectedAcnt3	Int = Null,
	@SelectedAcnt4	Int = Null,
	@SortFields		NVarChar(100) = 'SerialNo',
	@RepOptions		VarChar(10) = '', -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect	NVarChar(4000);
DECLARE	@StrFrom	NVarChar(4000);
DECLARE	@StrWhere	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 
BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions	Is Null)	SET @RepOptions = '';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = ' (D.ProcessID = ' + LTrim(Str(@ProcessID)) + ')'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')' 
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')' 

	IF (@OwnerDocNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.OwnerDocNo >= ' + LTrim(Str(@OwnerDocNoFr)) + ')' 
	IF (@OwnerDocNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.OwnerDocNo <= ' + LTrim(Str(@OwnerDocNoTo)) + ')' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate >= ''' + LTrim(@DocDateFr) + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + LTrim(@DocDateTo) + ''')'

	IF (@RoadBillDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.RoadBillDate >= ''' + LTrim(@RoadBillDateFr) + ''')'
	IF (@RoadBillDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.RoadBillDate <= ''' + LTrim(@RoadBillDateTo) + ''')'

	IF (@RoadBillNoMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (Replace(D.RoadBillNo, '' '', '''') LIKE N''%' + RTrim(Replace(@RoadBillNoMask, ' ', '')) + '%'')'
	IF (@VehicleNoMask Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (Replace(D.VehicleNo, '' '', '''') LIKE N''%' + RTrim(Replace(@VehicleNoMask, ' ', '')) + '%'')'

	IF (@DriverID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DriverID = ''' + LTrim(@DriverID) + ''')'
	IF (@VehicleTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.VehicleTypeID = ''' + LTrim(@VehicleTypeID) + ''')'
	IF (@LocationID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.LocationID = ''' + LTrim(@LocationID) + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT D.*, pub.GetCodeName(D.AcntCode, ' + @LangID + ') AcntName, D.SerialTime,
			G.GoodsName, cast('''' as nvarchar(500)) as GoodsInfo, S.StoreName,
			L.LocationName, V.VehicleTypeName, R.FirstName + '' '' + R.LastName as DriverName,
			G2.GoodsName as BoxGoodsName
	FROM inv.tblBaskulSalesHdr D
			INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID 
			INNER JOIN inv.tblGoodsDtl G2 ON G2.GoodsID = D.BoxGoodsID 
			INNER JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID
			INNER JOIN pub.tblLocationsDtl L ON L.LocationID = D.LocationID
			INNER JOIN sal.tblVehicleTypesDtl V ON V.VehicleTypeID = D.VehicleTypeID
			INNER JOIN pub.tblDriversDtl R ON R.DriverID = D.DriverID
	WHERE	' + @StrWhere 
	------------------------------------------------------------
	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
