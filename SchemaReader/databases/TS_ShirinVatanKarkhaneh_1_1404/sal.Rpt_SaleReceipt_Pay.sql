USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid
-- Create date   : 1395/04/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Hamid
-- Description   : ������ ������� �� ������
-- =============================================
--EXEC [sal].[Rpt_SaleReceipt_Pay] 1, 1, 90, 1, 95, 2251, ''
CREATE PROCEDURE [sal].[Rpt_SaleReceipt_Pay]
	@ProcessID		Int = 1,
	@ProcessNo		Int = Null,
	@BaseProcessID	Int = Null,
	@BaseProcessNo	Int = Null,
	@BaseFiscalYear	Int = Null,
	@BaseSerialNo	Int = Null,
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @Db0000		VarChar(50);

select @Db0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

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
	
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	IF (@ProcessNo	  Is Null)	SET @ProcessNo   = 1;

	--IF (@FiscalYear		Is Null)	SET @SerialNo	    = Null;
	IF (@BaseFiscalYear Is Null)	SET @BaseSerialNo   = Null;
	--IF (@SerialNo	    Is Null)	SET @FiscalYear		= Null;
	IF (@BaseSerialNo	Is Null)	SET @BaseFiscalYear = Null;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
 
	IF Str(@LangID) = 0 
		SET @LangID = 1
	---------------------------------------------------------------------------
	SET @StrWhere = 'H.ProcessID = ' + Str(@ProcessID) + ' AND H.ProcessNo = ' + Str(@ProcessNo)

	If (@BaseProcessID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.BaseProcessID = ' + LTrim(Str(@BaseProcessID)) + ')'
		
	If (@BaseProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.BaseProcessNo = ' + LTrim(Str(@BaseProcessNo)) + ')'		

	If (@BaseFiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear = ' + LTrim(Str(@BaseFiscalYear)) + ' AND H.BaseSerialNo = ' + LTrim(Str(@BaseSerialNo)) + ')'
		
	--============================
	SET @StrSelect = '
	SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.BaseProcessID, H.BaseProcessNo, H.BaseFiscalYear, H.BaseSerialNo,
		   H.BaseDocType, D.Amount, D.PayTypeID, D.VolumeRowNo, D.CurrencyTypeID, D.CurrencyRate,
		   D.CurrencyAmount, D.LocationID, D.LocationID2, D.BankTypeID, ISNULL(B.BankTypeName,'''') BankTypeName, D.BankTypeID2, 
		   D.BranchCode, D.BranchName, D.BranchCode2, D.BranchName2, D.AccountNo, D.AccountNo2, D.AccOwnerName, D.AccOwnerName2, 
		   D.ChequeNo, D.ChequeBookID, D.ChequeBookFiscalYear, D.EventNo, D.ChequeDate, D.DeliverTo, D.RowDesc, D.BankSnNo, 
		   D.AccountOwnerType,D.DebitCode, trs.GetOurBankName(D.DebitCode, ' + @LangID + ') AS DebitName,
		   D.CreditCode, pub.GetCodeName(D.CreditCode, ' + @LangID + ') AS CreditName,
		   [pub].[GetUserName](H.SessionNo) AS UserName,
		   [pub].[GetUserName](H.SessionNo2) AS UserName2,
		   [pub].[GetUserName](H.SessionNo3) AS UserName3,
		   [pub].[GetUserName](H.SessionNo4) AS UserName4
	FROM trs.tblPayHdr H
	INNER JOIN trs.tblPayDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And
								  D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
	LEFT JOIN trs.tblBankTypesDtl B ON D.BankTypeID = B.BankTypeID
	WHERE ' + @StrWhere + '
	ORDER BY H.FiscalYear, H.SerialNo'

	--============================
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
