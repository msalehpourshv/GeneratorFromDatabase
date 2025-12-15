USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H Sadeghi
-- Create date   : 1400/09/29
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   :
-- ==============================================
--[inv].[RptStore_PrintSerials] 55,1,1400,591,'','',''
Create PROCEDURE [inv].[RptStore_PrintSerials]
	@ProcessID		int=50,
	@ProcessNo		int=1,
	@FiscalYear		int=95,
	@SerialNo		int=1,
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(400) = '',
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE @StrFrom		NVarChar(4000);
DECLARE @FldGoodsID		VarChar(20);
DECLARE @FldGoodsName	NVarChar(100);
DECLARE @BatchNo		VarChar(20);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@QtyInRow		Int;
DECLARE	@PrintOne		Int;
DECLARE	@price			NVarChar(500);
DECLARE @StoreID		VarChar(20) ;
DECLARE @DocDate		VarChar(10) ;
Declare @SaleTypeID		VarChar(20) ;
Declare @PSerialNo		VarChar(30) ;
Declare @PSerialNo1		VarChar(30) ;
Declare @PSerialNo2		VarChar(30) ;
Declare @PSerialNo3		VarChar(30) ;
Declare @PSerialNo4		VarChar(30) ;
Declare @PSerialNo5		VarChar(30) ;
DECLARE @UnitPart		TINYINT

DECLARE @SelectedGoods	Int;

DECLARE @ByMainUnit	Bit;

BEGIN --============== S T A R T  C O D E ===================================================
	
	SET @SelectedGoods = 0
	SET	@QtyInRow	=0
	SET @UnitPart  = 1

	SET @StrWhere = '1 = 1'
	
	--==============
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

	SET NOCOUNT ON;
	
	if @ExtraParams <> ''
	begin 
		SET @SaleTypeID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
		SET @StoreID		= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
		SET @DocDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
		SET @SelectedGoods	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
		SET @ByMainUnit		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
		SET @QtyInRow		= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	end 
		print 	@QtyInRow	
		set @PrintOne= LTrim(pub.funSplitString(@ExtraParams, '@', 11));
	--print '@ExtraParams=' + @ExtraParams
	--print '@SaleTypeID='+ @SaleTypeID
	--print '@StoreID='+ @StoreID
	--print '@DocDate='+ @DocDate
	
	
	-- Init Variables ---------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @LangID=1
BEGIN TRY
		DROP TABLE #tblGoods
		END TRY
		BEGIN CATCH
		END CATCH

CREATE TABLE #tblGoods
	(	GoodsID			VarChar(20)   COLLATE ARABIC_CS_AS,
		GoodsName		NVarChar(120)  COLLATE ARABIC_CS_AS,
		BarCode			VarChar(20) COLLATE ARABIC_CS_AS,
		PSerialNo			VarChar(20) COLLATE ARABIC_CS_AS,
		PSerialNo2			VarChar(20) COLLATE ARABIC_CS_AS,
		PSerialNo3			VarChar(20) COLLATE ARABIC_CS_AS,
		PSerialNo4			VarChar(20) COLLATE ARABIC_CS_AS,
		PSerialNo5			VarChar(20) COLLATE ARABIC_CS_AS,
		DocRowNo		int,
		SalePrice		float,
		GoodsQuantity	float,
		BatchNo			VarChar(20)   COLLATE ARABIC_CS_AS,
		AcntCode			VarChar(20)   COLLATE ARABIC_CS_AS,
		AcntName		NVarChar(120)  COLLATE ARABIC_CS_AS
	)
	
DECLARE @GID		NVarChar(20) ;
DECLARE @BeforeGID		NVarChar(20) ;
DECLARE @GName		NVarChar(1000) ;
DECLARE @DocRowNo  int;
DECLARE @Qty  float ;
DECLARE @Qty2  float ;
DECLARE @AcntCode		NVarChar(20) ;
DECLARE @AcntName		NVarChar(1000) ;
DECLARE @Counter as int=0
DECLARE @CounterPserial as int=0
SET @PSerialNo=''
SET @PSerialNo1=''
SET @PSerialNo2=''
SET @PSerialNo3=''
SET @PSerialNo4=''
SET @PSerialNo5=''
SEt @BeforeGID = ''

DECLARE csr1 CURSOR FOR 

SELECT D.GoodsID, GoodsQuantity, [pub].[funGetGoodsName](D.GoodsID, @LangID) GoodsName, D.DocRowNo,1
,D.BatchNo,AcntCode, pub.GetCodeName(AcntCode, 1) AS AcntName,s.PSerialNo
FROM   inv.tblStorageDocsDtl AS D  
INNER JOIN inv.tblStorageDocsSerials s
on D.ProcessID=s.ProcessID and D.ProcessNo=s.ProcessNo and D.FiscalYear=s.FiscalYear and D.SerialNo=s.SerialNo and s.DocRowNo=D.DocRowNo
WHERE (D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear = @FiscalYear) AND (D.SerialNo = @SerialNo)
ORDER BY D.DocRowNo
 
	OPEN csr1
	FETCH NEXT FROM csr1 INTO @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@PSerialNo

	WHILE @@Fetch_Status = 0
	BEGIN
		set @Counter +=1
		set @CounterPserial +=1
		
		IF  @Counter =1
			SET @PSerialNo1=@PSerialNo
		IF  @Counter=2
			SET @PSerialNo2=@PSerialNo
		IF  @Counter=3
			SET @PSerialNo3=@PSerialNo
		IF  @Counter=4
			SET @PSerialNo4=@PSerialNo
		IF  @Counter=5
			SET @PSerialNo5=@PSerialNo

		IF (@Counter % @QtyInRow)=0  OR @CounterPserial=@Qty 
		begin
			--select @GID,@GName,'',@PSerialNo1,@PSerialNo2,@PSerialNo3,@PSerialNo4,@PSerialNo5,0,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName

			insert into #tblGoods(GoodsID,GoodsName,BarCode,PSerialNo,PSerialNo2,PSerialNo3,PSerialNo4,PSerialNo5,SalePrice,DocRowNo,GoodsQuantity,BatchNo,AcntCode,AcntName)
			select @GID,@GName,'',@PSerialNo1,@PSerialNo2,@PSerialNo3,@PSerialNo4,@PSerialNo5,0,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName
			SET @PSerialNo1=''
			SET @PSerialNo2=''
			SET @PSerialNo3=''
			SET @PSerialNo4=''
			SET @PSerialNo5=''
			SEt @Counter  = 0
		END
		IF @CounterPserial=@Qty
			SET @CounterPserial=0

		SET @BeforeGID = @GID
		FETCH NEXT FROM csr1 INTO  @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@PSerialNo
	END

	CLOSE csr1
	DEALLOCATE csr1


	set @SaleTypeID = LTRIM(Rtrim( @SaleTypeID ))

	update #tblGoods
	set BarCode = IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
		From #tblGoods G  INNER JOIN inv.tblGoods D 
		ON D.GoodsID = G.GoodsID 
                      
	update #tblGoods
	set SalePrice =  H.SalePrice 
	From #tblGoods G  INNER JOIN sal.tblGoodsPricesDtl H 
	ON H.GoodsID = G.GoodsID 
	where LTRIM(Rtrim(  H.SaleTypeID))  =   LTRIM(Rtrim( @SaleTypeID ))

	--================== Where
	If (@SelectedGoods > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.GoodsID') 
	end	
	
SET @StrSelect =' Select T.GoodsID, T.GoodsName, IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode, T.DocRowNo, T.SalePrice, H.CodeClosed, H.UnitID, H.TechnicalSpecifications, H.TechnicalNo, H.MiscSpecifications, H.GoodsLength, H.GoodsWidth, H.GoodsHeight, 
                      H.GoodsWeight, H.MapNo, H.MasterCode, H.CheckBuyRequest, H.CheckBuyOrder, H.CheckQualityControl, H.RecID, H.SessionNo, H.GlobalCodingID, 
                      H.IranCodeID, H.ExtraField1, H.ExtraField2, H.ExtraField3, H.ExtraField4, H.ExtraField5, H.FitPoint, H.SetPoint, H.BatchSize, H.HasSerial, H.UseFactor, 
                      H.CostCenterAcntCode, H.ProduceWithoutFormula, H.GoodsClassificationID, H.PrinterID, H.ShowInSaleMenu, H.GoodsPrice, H.SpecialCode, H.NationalCode, 
                      H.DrugKindID, H.CompanyID, H.MinSaleCeiling, H.MaxBuyCeiling, H.QtyInPerPacket,  H.BuyPrice, H.IsRation, H.RationQty, H.IsCombination, 
                      H.CombinationAmount, H.IsMammyDrug, H.IsSalePermit, H.IsComplementDrug, H.IsDecorDrug, H.IsNotInventoryCountDrug, H.IsNotTariffDrug, H.IsComrade, 
                      H.VisitorPercent, H.DoseID, H.SpecialAlarm, H.GenericCode, H.IsOTC, H.DrugSetID, H.UseExpireDate, H.GenericID, H.IsService, H.IsCombined, H.IsSendInfo, 
                      H.ContainTax, H.HasExpireDate, H.HasBatchNo, H.HasLentgh, H.SaleTypeID, H.DfStoreID, H.GoodsGroup, H.SubGroup, H.PublisherAcntCode, H.GoodsCount, 
                      H.GoodsType, H.PrintTurn, H.PrintYear, H.PageCount, H.BuyPricePercent, D.LanguageID, D.GoodsName2, D.GenericName, 
                      D.Author, D.Translator, D.GoodsLocation,
                      U.UnitName,U.UnitID,CASE WHEN  UDS.GoodsID IS NULL THEN U.UnitID ELSE UDS.SubUnitID END SubUnitID 
			         ,ISNULL(U2.UnitName,'''') SubUnitName,isnull(UDS.UnitValue,1) UnitValue ,isnull(UDS.MainUnitValue,1) MainUnitValue
					 ,T.GoodsQuantity,T.BatchNo,T.AcntCode,T.AcntName,T.PSerialNo,T.PSerialNo2,T.PSerialNo3,T.PSerialNo4,T.PSerialNo5,H.GoodsCID
					 ,ExtraField6,ExtraField7,ExtraField8,ExtraField9,ExtraField10
					 ,ExtraField11,ExtraField12,ExtraField13,ExtraField14,ExtraField15
					 ,ExtraField16,ExtraField17,ExtraField18,ExtraField19,ExtraField20	,BC.BarCodeImage,BC3.BarCodeImage BarCodeImage3, I.GoodsImage
                 FROM inv.tblGoods  H 
                      INNER JOIN inv.tblGoodsDtl D  ON H.GoodsID = D.GoodsID AND H.PartNumber=D.PartNumber AND H.PartNumber=' + LTRIM(STR(@UnitPart)) + '
                      INNER JOIN  #tblGoods T   ON H.GoodsID = SUBSTRING(T.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ')  
					  LEFT  JOIN inv.tblGoodsImages I ON I.GoodsID =  SUBSTRING(T.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ')
				      left  JOIN inv.tblSubUnitsDtl UDS ON H.GoodsID=UDS.GoodsID AND UDS.ShowInInvoice=1
		              left  join inv.tblUnitsDtl U2 on U2.UnitID = UDS.SubUnitID AND U2.LanguageID =  1
				      LEFT  JOIN inv.tblUnitsDtl U ON U.UnitID = H.UnitID AND U.LanguageID = 1
					  LEFT  JOIN rpt.tblBarCodeImage BC	ON BC.BarCode = T.GoodsID and BC.SessionNo='+ str(@SessionNo)+' and BC.ReportID='+ str(@ReportID)+'  and BC.Type=1
					  LEFT  JOIN rpt.tblBarCodeImage BC3 ON BC3.BarCode = T.PSerialNo and BC3.SessionNo='+ str(@SessionNo)+' and BC3.ReportID='+ str(@ReportID)+' and BC3.Type=3
				      Where ' + @StrWhere

If (@SortFields Is Not Null) AND (@SortFields <> '')
		SET @StrSelect = @StrSelect + '
		ORDER BY ' + @SortFields
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

END
GO
