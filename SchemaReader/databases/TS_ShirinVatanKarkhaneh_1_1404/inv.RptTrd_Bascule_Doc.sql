USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/06/08
-- Viewed By	 : 
-- Last Modified : 	
-- Last Modifier : 	 
-- Description	 : �ѐ ��Ә��
-- ==============================================
CREATE PROCEDURE [inv].[RptTrd_Bascule_Doc]
	@ProcessID		Int,
	@SerialFr		Int = Null,
	@SerialTo		Int = Null,
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@SelectedStore	Int = Null,
	@SelectedGoods	Int = Null, -- ������ ����
	@SelectedAcnt1	Int = Null, -- ������ ��� ����
	@SelectedAcnt2	Int = Null,
	@SelectedAcnt3	Int = Null,
	@SelectedAcnt4	Int = Null,
	@RepOptions		VarChar(10) = '',  -- bit array options
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
	SET @StrWhere = ' (H.ProcessID = ' + LTrim(Str(@ProcessID)) + ')'

	IF (@SerialFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo >= ' + LTrim(Str(@SerialFr)) + ')' 
	IF (@SerialTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo <= ' + LTrim(Str(@SerialTo)) + ')' 

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + LTrim(@DocDateFr) + ''')'
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + LTrim(@DocDateTo) + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
	IF (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'D.StoreID') 

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT H.DocDate, H.AcntCode, H.OwnerDocNo,  H.GoodsDocNo, H.GoodsSpecifications,H.LocationID, H.VehicleNo, H.VehicleTypeID,
		   H.DriverID, H.RoadBillNo, H.RoadBillDate, H.VchNo,  H.TransportationCost, H.SerialTime, H.Step, D.ProcessID, D.ProcessNo,D.FiscalYear, 
		   D.SerialNo, D.RowNo, D.DocRowNo, D.GoodsID, D.FullVehicleDate, D.FullVehicleTime, D.FullVehicleBoxes, D.FullVehicleWeight, 
		   D.EmptyVehicleDate, D.EmptyVehicleTime, D.EmptyVehicleBoxes, D.EmptyVehicleWeight, D.BoxGoodsID, D.BoxFee, D.BoxWeight, 
		   D.SubsidencePercent, D.SubsidenceWeight, D.BrixDegree, D.Fee, H.DocDesc,D.DocDesc DescDtl, D.StoreID, D.SubUnitID, D.SubUnitQuantity,
		   pub.GetCodeName(H.AcntCode, ' + @LangID + ') AcntName, G.GoodsName, cast('''' as nvarchar(500)) as GoodsInfo, S.StoreName,
		   L.LocationName, V.VehicleTypeName, R.FirstName + '' '' + R.LastName as DriverName
		   , DR.DriverTel, DR.VehicleNo, DR.DriverAcntCode, DR.DriverPercent, DR.IDNumber, DR.NationalNumber, DR.HabitatCity, DR.DrivingLicenseNo, 
           DR.DrvLicensIssuancePlace, DR.DriverCardNo, DR.DrivingNotebookNo, DR.DriverMobile, DR.DriverEMail, DR.MachineContent, DR.MachineBurden,pub.UN(H.SessionNo) UserName
		   ,H.BaseProcessID  ,H.BaseProcessNo  ,H.BaseFiscalYear  ,H.BaseSerialNo ,H.BaseDocType
		FROM inv.tblBaskulSalesHdr H
			left Join inv.tblBaskulSalesDtl D on D.ProcessID=H.ProcessID and D.SerialNo=H.SerialNo  
			left JOIN inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID  and G.LanguageID=' + @LangID + '
			left JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID  and S.LanguageID=' + @LangID + '
			left JOIN pub.tblLocationsDtl L ON L.LocationID = H.LocationID  and L.LanguageID=' + @LangID + '
			left JOIN sal.tblVehicleTypesDtl V ON V.VehicleTypeID = H.VehicleTypeID  and V.LanguageID=' + @LangID + '
			left JOIN pub.tblDriversDtl R ON R.DriverID = H.DriverID and R.LanguageID=' + @LangID + '
			left JOIN pub.tblDrivers DR ON DR.DriverID = H.DriverID
	WHERE	' + @StrWhere + '
	ORDER BY SerialNo '
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
