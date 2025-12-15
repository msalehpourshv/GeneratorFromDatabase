USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1387/07/14
-- Viewed By	 : 
-- Last Modified : 1390/12/24
-- Last Modifier : TakroSystem\Zia
-- Description	 : چاپ فاکتور خدمات - تلفیق شده با فروش
-- =============================================
Create PROCEDURE [acc].[RptAcc_Service_Doc2]
	@SvcProcessID	Int,
	@SvcProcessNo	Int,
	@SvcFiscalYear	Int,
	@SvcSerialNo	Int,
	@IvcProcessID	Int,
	@IvcProcessNo	Int,
	@IvcFiscalYear	Int,
	@IvcSerialNo	Int,
	@ShowRemain		Bit = 0,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 

DECLARE @AcntCode	varchar(20);
DECLARE @DateIvc	char(10);
DECLARE @DateSvc	char(10);
DECLARE @DateMax	char(10);
DECLARE @RemainValue	bigint;
DECLARE @FiscalYear		SmallInt;
DECLARE @IsSettle bit;
BEGIN -- ============================ S T A R T =====================================================

	SET NOCOUNT ON;
	
	DECLARE @Part1End			TinyInt;
	DECLARE @PartStart			TinyInt;
	DECLARE @PartEnd			TinyInt;
	SELECT	@Part1End = Layer1 
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)


select @PartStart= [acc].[FunGetAcntInfoForRemain](2)
select  @PartEnd=[acc].[FunGetAcntInfoForRemain](3)

	--- init -----------------------------------------------
	IF (@SvcProcessNo Is Null)	SET @SvcProcessNo = 1;
	If (@SvcSerialNo Is Null)	SET @SvcSerialNo = 1;
	IF (@IvcProcessNo Is Null)	SET @IvcProcessNo = 1;
	If (@IvcSerialNo Is Null)	SET @IvcSerialNo = 1;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @FiscalYear = Cast(Right(db_name(), 4) AS SmallInt)

	select @IsSettle = isnull(SettingValue, 0)
	from pub.tblSettings
	where SettingKey = 'InvHasSettlementKind'
	
	if @ShowRemain = 0 
		set @RemainValue = 0
	else
	begin
		select @DateIvc = VchDate
		from inv.tblStorageDocsHdr
		where (ProcessID = @IvcProcessID) and (ProcessNo = @IvcProcessNo) and (FiscalYear = @IvcFiscalYear) and (SerialNo = @IvcSerialNo)

		select @DateSvc = VchDate
		from acc.tblServicesHdr
		where (ProcessID = @SvcProcessID) and (ProcessNo = @SvcProcessNo) and (FiscalYear = @SvcFiscalYear) and (SerialNo = @SvcSerialNo)

		if (@DateIvc > @DateSvc)
			set @DateMax = @DateIvc
		else
			set @DateMax = @DateSvc
		
		select	@AcntCode = AcntCode
		from acc.tblServicesHdr
		where (ProcessID = @SvcProcessID) and (ProcessNo = @SvcProcessNo) and (FiscalYear = @SvcFiscalYear) and (SerialNo = @SvcSerialNo)
		
		select	@RemainValue = 	IsNull(Sum(VD.Debit - VD.Credit), 0) 
		from	acc.tblVoucherDtl VD 
					INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo = VD.SerialNo
							INNER join acc.tblAcnt b ON b.PartNumber = 1 AND SUBSTRING(VD.AcntCode, 1, @Part1End) = SUBSTRING(b.AcntCode, 1,@Part1End) AND LEN(b.AcntCode) = @Part1End
					WHERE   b.AcntType NOT IN (91, 92) AND VH.VchKind <> 0 AND  (VH.DocRegisterState > 0) AND 
					(substring(VD.AcntCode,@PartStart,@PartEnd )= substring(@AcntCode,@PartStart,@PartEnd )) AND 
					(
					(VD.DocDate <= @DateMax) 
					AND Not
					(
						(VD.DocDate = @DateSvc) AND 
						(VD.SourceProcessID  = @SvcProcessID) AND 
						(VD.SourceProcessNo  = @SvcProcessNo) AND 
						(VD.SourceFiscalYear = @SvcFiscalYear) AND 
						(VD.SourceSerialNo  >= @SvcSerialNo)
					) 
					AND Not
					(
						(VD.DocDate = @DateIvc) AND 
						(VD.SourceProcessID  = @IvcProcessID) AND 
						(VD.SourceProcessNo  = @IvcProcessNo) AND 
						(VD.SourceFiscalYear = @IvcFiscalYear) AND 
						(VD.SourceSerialNo  >= @IvcSerialNo)
					)
				)
	end
	--------------------------------------------------------
	--- select ----------------------------------------------
		SELECT	H.*, D.DocRowNo, D.ServiceID, D.DescDtl, D.ServiceQuantity, D.ServiceAmount,
				pub.GetCodeName(H.AcntCode, @LangID) AcntName, D.DiscountDtl, D.DiscountDtl DiscountDtl2, D.DiscountPercentDtl, 
				acc.funGetServiceName(D.ServiceID, @LangID) ServiceName, @RemainValue As DebitRemain,
				F.EconomicalCode, F.CustomerFirstName + ' ' + F.CustomerLastName AS CustomerName, 
				F.Address1, F.Address2, F.CompanyRegisterNo, F.NationalIDNumber,F.NationalIdentity, F.OrganzationName, 
				F.ZipCode, IsNull(F.Tel, '') Tel, LH.AreaCode, pub.funGetLocationName(F.LocationID, 1) as LocationName,@IsSettle as HasSettlement
		FROM	acc.tblServicesHdr H 
					INNER JOIN	acc.tblServicesDtl D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
					OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F 
					LEFT  JOIN pub.tblLocationsDtl	LD ON LD.LocationID = F.LocationID AND LD.LanguageID = @LangID
					LEFT  JOIN pub.tblLocations		LH ON LH.LocationID = LD.LocationID
		WHERE	(H.ProcessID = @SvcProcessID) and (H.ProcessNo = @SvcProcessNo) and (H.FiscalYear = @FiscalYear) and (H.SerialNo = @SvcSerialNo)
				
END
GO
