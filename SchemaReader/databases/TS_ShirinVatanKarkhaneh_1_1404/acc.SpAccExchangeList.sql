USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1392/02/08
-- Viewed By	 : 
-- Last Modified : 1392/02/08
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- =============================================
Create PROCEDURE [acc].[SpAccExchangeList]
	@CurrencyTypeID varchar(20) = '',
	@CurrencyRate float = 1
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @NotClosedAcntTypeInExchange Bit='True'
	DECLARE @LenAcntPart1 tinyint

	SET @NotClosedAcntTypeInExchange = 'False'

	SELECT @NotClosedAcntTypeInExchange = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'NotClosedAcntTypeInExchange'

	SELECT @LenAcntPart1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer
	where TableName='acc.tblAcnt' and PartNumber=1

	select T.*, pub.GetCodeName(T.AcntCode, 1) AcntName,
		ROUND(T.CurrencyRemain*@CurrencyRate - T.NativeRemain, 0) ExchangeAmount
	from
	(
		select D.AcntCode,
			SUM(D.Debit-D.Credit) NativeRemain,
			ROUND( SUM(case when D.Debit>0 then D.CurrencyAmount else 0-D.CurrencyAmount end),5) CurrencyRemain
		from acc.tblVoucherDtl D
				inner join acc.tblVoucherHdr H on H.SerialNo=D.SerialNo
			    INNER JOIN acc.tblAcnt A On A.PartNumber=1 AND  A.AcntCode = SUBSTRING(D.AcntCode,1,@LenAcntPart1)
		where (D.VchKind <> 0) and (D.CurrencyTypeID=@CurrencyTypeID) and A.IsCurrency='True' AND 
		      (@NotClosedAcntTypeInExchange='False' OR (@NotClosedAcntTypeInExchange = 'True' AND A.AcntType NOT IN(41, 51, 61, 62,81)) )
		group by D.AcntCode
	) T
	where T.CurrencyRemain<>0 OR NativeRemain<> 0
END
GO
