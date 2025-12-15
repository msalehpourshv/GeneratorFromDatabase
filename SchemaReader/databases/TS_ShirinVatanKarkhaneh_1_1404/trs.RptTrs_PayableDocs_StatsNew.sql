USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/03/16
-- Viewed By	 : 
-- Last Modified : 1392/01/07
-- Description	 : <Cheque Progress>
-- ----------------------------------------------
-- آمار چکهای دریافتی از اشخاص
-- ==============================================
Create PROCEDURE [trs].[RptTrs_PayableDocs_StatsNew]
	@ProcessNo	int = 1,
	@State		int = 0,
	/* 0 = کلیه چکها    */
	/* 1 = چکهای موجود  */
	/* 2 = چکهای برگشتی */
	@RepOptions	VarChar(10) = '1111', -- bit array options
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
Declare @ProcessID			NVarChar(50);
Declare @StrQuery			NVarChar(max);
declare @ChequeIsDigital	bit;
declare @StrWhere			NVarChar(max) = '';

Set @ChequeIsDigital	= pub.funSplitString(@RepInfo, '@', 6);
Begin  -----------------  B E G I N   T O   C O D E  --------------------------
	
	if @ChequeIsDigital = 1
		Set @StrWhere = @StrWhere + ' And PD.ChequeIsDigital = 1'
	if @ChequeIsDigital = 0
		Set @StrWhere = @StrWhere + ''

	Set NoCount On;
	
	-- Init --

	If (@State = 0)      /* All Cheques */
		Set @ProcessID = '25, 2, 40,28'
	Else If (@State = 1) /* Available Cheques */
		Set @ProcessID = '25, 2, 40'
	Else If (@State = 2) /* Returned Cheques */
		Set @ProcessID = '28'
	
		Set @StrQuery = '
			SELECT Credit AS OwnerAcntCode, pub.GetCodeName(Credit, 1) AS OwnerAcntName, 
					 SUM(Amount) AS AmountSum, COUNT(*) ChequeCount
			FROM
			(
				SELECT	Amount,
						(
							SELECT Top 1 DebitCode
							FROM	trs.tblPayDtl
							WHERE	ProcessID IN (2,25) 
									AND ProcessNo = (' + LTrim(str(@ProcessNo)) + ')							
									AND PayTypeID IN (8,28) 
									AND VolumeFiscalYear = PD.VolumeFiscalYear 
									AND VolumeRowNo = PD.VolumeRowNo
							ORDER By EventNo ASC
						) AS Credit
				FROM	 trs.tblPayDtl PD
						 INNER JOIN
						 (
					 		SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo 
					 		FROM	trs.tblPayDtl
					 		WHERE	PayTypeID IN (8, 28)
										AND ProcessNo = ' + LTrim(str(@ProcessNo)) + '
					 		GROUP  BY VolumeFiscalYear, VolumeRowNo
						 ) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
				WHERE	PayTypeID IN (8, 28) 
							AND PD.ProcessNo = ' + LTrim(str(@ProcessNo)) + '
							AND PD.ProcessID IN(' + LTrim(@ProcessID) + ')
							'+@StrWhere+'
			) T
			GROUP BY Credit '
	Print @StrQuery;
	Exec sp_executesql @StrQuery;
End
GO
