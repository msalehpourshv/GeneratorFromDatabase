USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/05/07
-- Viewed By	 : 
-- Last Modified : 1392/02/15
-- Last Modifier : TakroSystem\ZiA
-- Description	 : < ثبت سند بستن حسابها >
-- =============================================
Create PROCEDURE [acc].[SpVch_CreateDoc_Closing]
	@SerialNo	Int,
	@AcntCode	VarChar(20),		-- کد حساب 
	@DocDate	Char(10),			-- تاریخ ثبت
	@DocDesc	NVarChar(500) = '',	-- شرح
	@SessionNo	Int
WITH ENCRYPTION
AS
DECLARE @StrTemp		NVarChar(1000);
DECLARE @IntTemp		BigInt;
DECLARE @IntMaxRow		Int;
DECLARE @IntRow			Int;
DECLARE @OldSerialNo	Int;
DECLARE @IntLayerLen	Int;
DECLARE @RecID			bigint;
DECLARE @ErrorMsg		nvarchar(2000);
DECLARE @FinishingDocWithProcessNo Bit
BEGIN

	SET NOCOUNT ON;
	
	-- Init -----------------------------------
	If (@DocDesc Is Null) SET @DocDesc = ''
	If (@DocDate Is Null) SET @DocDate = RIGHT(db_name(), 4) + '/12/30'
	SET @IntMaxRow = 0
	----------مجوز ثبت چندین بستن موقت سند---------------------------------------------
	---- Check Not to Exist Any Similar Doc --
	--SELECT	@IntTemp = COUNT(*)
	--FROM	acc.tblVoucherHdr
	--WHERE	VchKind = 4

	--If (@IntTemp > 0)
	--Begin
	--	--RaisError ('این نوع سند قبلاً ثبت شده است', 5, 16)
	--	Return -1;
	--End

	-- Check finish doc not to be saved before --
	SELECT	@IntTemp = Count(*)
	FROM	acc.tblVoucherDtl
	WHERE	VchKind = 3

	If (@IntTemp > 0)
	Begin
		--RaisError ('سند اختتامیه ایجاد شده است', 5, 16)
		Return -3;
	End

	SELECT @FinishingDocWithProcessNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'FinishingDocWithProcessNo'

	-- Check another user not to be connected to database --
	DECLARE @ParmDefinition NVarChar(100)
	SET @StrTemp = '
		SELECT	@CountOUT = Count(*)
		FROM	[' + pub.funGetBranchDBName() + '].[usr].[tblActiveUsers]
		WHERE	DateDiff(mi, GetDate(), RefreshDateTime) < 6'

	SET @ParmDefinition = N'@CountOUT Int OUTPUT';

	Execute sp_executesql @StrTemp, @ParmDefinition, @CountOUT = @IntTemp OUTPUT;

	If (@IntTemp > 1)
	Begin
		--RaisError  ('کابر دیگری در سیستم مشغول است' ,5, 16)
		Return -4;
	End

	-- Set Acnt Part 1 Len --
	SELECT	@IntLayerLen = Layer1
	FROM	pub.tblCodeLayer 
	WHERE	PartNumber = 1 AND TableName = 'acc.tblAcnt'

	IF @SerialNo = 0
		SELECT	@SerialNo = IsNull(Max(SerialNo), 0) + 1,
				@OldSerialNo = IsNull(Max(OldSerialNo), 0) + 1
		FROM	acc.tblVoucherHdr
	ELSE
		IF (SELECT COUNT(*) FROM acc.tblVoucherHdr WHERE SerialNo = @SerialNo )=0
			SELECT	@OldSerialNo = IsNull(Max(OldSerialNo), 0) + 1
			FROM	acc.tblVoucherHdr
		ELSE
			SELECT @IntMaxRow=ISNULL(MAX(RowNo),0) 
			FROM acc.tblVoucherDtl  
			WHERE SerialNo = @SerialNo
	-------------------------------------------------
	CREATE TABLE #tmp(Id bigint)
	
	insert into	#tmp
	exec [hst].[funGetUniqueId]

	select @RecID = Id from #tmp
	
	-- Start to Save ---------------------------------------------------

	BEGIN TRANSACTION;	

	BEGIN TRY
		-- Set Header Section --
		IF (SELECT COUNT(*) FROM acc.tblVoucherHdr WHERE SerialNo = @SerialNo )=0
			INSERT INTO	acc.tblVoucherHdr(SerialNo, DocDate, DocRegisterState, DocDesc, DocDesc2, VchKind, RecID, SessionNo, OldSerialNo, CurrencyTypeID, CurrencyRate, RowNo)
			VALUES (@SerialNo, @DocDate, 1, @DocDesc, '', 4, @RecID, @SessionNo, @OldSerialNo, '', 0, 0)
				         
		-- Set Details Section --
		insert into	acc.tblVoucherDtl(
				SerialNo, RowNo, DocRowNo, DocDate, AcntCode, CurrencyTypeID, CurrencyAmount, 
				Debit, Credit, SessionNo, RecDesc, RecDesc2, IsAutoDoc, VchKind, IsShowDetail,
				SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocType,
				SourceCodeFieldValue, Emphasize, Emphasize2, Emphasize3 , VisitorAcntCode)
				
		select	@SerialNo, T.RowNo, T.RowNo, @DocDate, T.AcntCode, '' as CurrencyTypeID, 0 CurrencyAmount,
			round(CASE WHEN (T.NativeRemain < 0) THEN (-T.NativeRemain) ELSE 0 END , 0)AS Debit,
			round(CASE WHEN (T.NativeRemain > 0) THEN (+T.NativeRemain) ELSE 0 END , 0)AS Credit,
				@SessionNo, @DocDesc, '' as RecDesc2, 1 as IsAutoDoc, 4 as VchKind, 0 as IsShowDetail,
				0 as SourceProcessID, T.SourceProcessNo , 0 as SourceFiscalYear, 0 as SourceSerialNo,
				0 as SourceDocType, 0 as SourceCodeFieldValue, 0 as Emphasize, 0 as Emphasize2, 0 as Emphasize3 , VisitorAcntCode
		FROM
		(
			SELECT	D.AcntCode , VisitorAcntCode, @IntMaxRow + Row_Number() Over (ORDER BY D.AcntCode) AS RowNo,
					isnull(sum(D.Debit - D.Credit), 0) AS NativeRemain ,CASE WHEN @FinishingDocWithProcessNo = 'False' then 0 ELSE D.SourceProcessNo END SourceProcessNo 
			FROM	acc.tblVoucherDtl D 
						INNER JOIN acc.tblAcnt A ON	A.PartNumber = 1 AND LEFT(RTrim(D.AcntCode), @IntLayerLen) = A.AcntCode
			WHERE	(D.VchKind <> 0) AND (A.AcntType IN(41, 51, 61, 62,81)) -- Gain & Loss Accounts
			and DocDate<=@DocDate
			GROUP BY D.AcntCode , VisitorAcntCode,CASE WHEN @FinishingDocWithProcessNo = 'False' then 0 ELSE D.SourceProcessNo END 
		) T
		where (NativeRemain <> 0)
		
		set @IntTemp=0
		-- Calc Remain Balance --
		SELECT	@IntTemp = IsNull(Sum(Debit - Credit), 0), 
				@IntRow = IsNull(Max(RowNo), 0) + 1
		FROM	acc.tblVoucherDtl D
		WHERE	SerialNo = @SerialNo
		GROUP BY D.SerialNo	

		if (@IntTemp is null)
			set @IntTemp = 0

		if (@IntRow is null)
			set @IntRow = 1
			
		-- Set Detail Balance Section --
		insert into	acc.tblVoucherDtl(
				SerialNo, RowNo, DocRowNo, DocDate, AcntCode, CurrencyTypeID, CurrencyAmount, 
				Debit, Credit, SessionNo, RecDesc, RecDesc2, IsAutoDoc, VchKind, IsShowDetail,
				SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, SourceDocType,
				SourceCodeFieldValue, Emphasize, Emphasize2, Emphasize3)
		
		select	@SerialNo, @IntRow, @IntRow, @DocDate, @AcntCode, '' CurrencyTypeID, 0 CurrencyAmount,
			round(CASE WHEN (@IntTemp < 0) THEN (-@IntTemp) ELSE 0 END, 0),
			round(CASE WHEN (@IntTemp > 0) THEN (+@IntTemp) ELSE 0 END, 0),
				@SessionNo,	@DocDesc, '', 1 as IsAutoDoc, 4 as VchKind, 0 as IsShowDetail,
				0 as SourceProcessID, 0 as SourceProcessNo, 0 as SourceFiscalYear, 0 as SourceSerialNo,
				0 as SourceDocType, 0 as SourceCodeFieldValue, 0 as Emphasize, 0 as Emphasize2, 0 as Emphasize3 
				
		if (select sum(isnull(Debit,0)) from acc.tblVoucherDtl where SerialNo = @SerialNo)=0
			begin
				delete  from acc.tblVoucherHdr where SerialNo = @SerialNo
				delete  from acc.tblVoucherDtl where SerialNo = @SerialNo
				set @SerialNo=-1
			end
			

		COMMIT TRANSACTION;
		RETURN @SerialNo
	
	END TRY

	BEGIN CATCH
		IF (@@TRANCOUNT > 0)
	        ROLLBACK TRANSACTION;

		select @ErrorMsg = ERROR_MESSAGE()
		raiserror(@ErrorMsg, 16, 1)
		--PRINT ERROR_MESSAGE()
		RETURN 0

	END CATCH

END
GO
