USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1402/08/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : ارسال اطلاعات اسناد به ورانگر
-- =============================================
Create PROCEDURE pub.spSendDoc2OtherSoftWare
	@ExtraParams		NVarChar(Max) = ''

WITH ENCRYPTION
AS
BEGIN

	Declare @StartLayer		TINYINT;
	Declare @LayerLen		TINYINT;
	Declare @PartNumber		TINYINT;
	Declare @StartLayer1	TINYINT;
	Declare @LayerLen1		TINYINT;
	Declare @StartLayer2	TINYINT;
	Declare @LayerLen2		TINYINT;
	Declare @StartLayer3	TINYINT;
	Declare @LayerLen3		TINYINT;
	Declare @StartLayer4	TINYINT;
	Declare @LayerLen4		TINYINT;

	Declare @SourceProcessID	int;
	Declare @SourceProcessNo	int;
	Declare @SourceFiscalYear	int;
	Declare @SourceSerialNo		int;
	Declare @SerialNo			int;

	DECLARE @StrSelect		NVarChar(Max);
	DECLARE @StrWhere		NVarChar(Max);

	select  @StartLayer1=[acc].[funGetAcntLayerStartandLen](1,1)
			,@LayerLen1=[acc].[funGetAcntLayerStartandLen](1,2)
			,@StartLayer2=[acc].[funGetAcntLayerStartandLen](2,1)
			,@LayerLen2=[acc].[funGetAcntLayerStartandLen](2,2)
			,@StartLayer3=[acc].[funGetAcntLayerStartandLen](3,1)
			,@LayerLen3=[acc].[funGetAcntLayerStartandLen](3,2)
			,@StartLayer4=[acc].[funGetAcntLayerStartandLen](4,1)
			,@LayerLen4=[acc].[funGetAcntLayerStartandLen](4,2)

	SET @SerialNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @SourceProcessID	= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @SourceProcessNo	= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @SourceFiscalYear	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @SourceSerialNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 

	set @StrWhere='	and  V.SerialNo='+ str(@SerialNo)+'
					and V.SourceProcessID='+ str(@SourceProcessID)+'	
					and  V.SourceProcessNo='+ str(@SourceProcessNo )+'
					and  V.SourceFiscalYear='+ str(@SourceFiscalYear)+'  
					and  V.SourceSerialNo='+ str(@SourceSerialNo)+' '

SET @StrSelect = ' Select V.SerialNo ID ,V.DocDate VoucherDate ,''دارایی و اموال'' VoucherTypeName  ,case when H.DocDesc='''' then ''-'' else H.DocDesc end VoucherComment  ,1 DCCode 
					,isnull(A1.EqualAcntCode , '''') SLCode ,isnull(A2.EqualAcntCode , '''') DLCode ,isnull(A3.EqualAcntCode , '''') FifthLedgerCode 
					,isnull(A4.EqualAcntCode , '''') SixthLedgerCode ,'''' SeventhLedgerCode
					,V.Debit DebitAmount,V.Credit CreditAmount,V.RecDesc VoucherItemComment,H.OldSerialNo ReferenceNo
					,V.SourceProcessID,V.SourceProcessNo,V.SourceFiscalYear, V.SourceSerialNo
				from acc.tblVoucherDtl V 
				inner join acc.tblVoucherHdr H on V.SerialNo=H.SerialNo
				left join acc.tblAcnt A1 on substring (V.AcntCode,'+ STR(@StartLayer1) +','+ STR(@LayerLen1) +')=A1.AcntCode and A1.PartNumber=1
				left join acc.tblAcnt A2 on substring (V.AcntCode,'+ STR(@StartLayer2) +','+ STR(@LayerLen2) +')=A2.AcntCode and A2.PartNumber=2
				left join acc.tblAcnt A3 on substring (V.AcntCode,'+ STR(@StartLayer3) +','+ STR(@LayerLen3) +')=A3.AcntCode and A3.PartNumber=3
				left join acc.tblAcnt A4 on substring (V.AcntCode,'+ STR(@StartLayer4) +','+ STR(@LayerLen4) +')=A4.AcntCode and A4.PartNumber=4
                where 1=1 ' + @StrWhere
	
	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;

END
GO
