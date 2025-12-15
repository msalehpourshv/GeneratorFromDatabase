USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 88/05/14
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE trs.spPayDirectionHdrListSelect 
	@FromDocDate	CHAR(10),
	@DocDate		CHAR(10),
	@SerialNo		INT,
	@FiscalYear		SMALLINT,
	@ProcessNo		TINYINT,
	@DebitCode      VARCHAR(30),
	@LanguageID     tinyint ,
	@ExtraParams	NVarChar(Max) 
WITH ENCRYPTION
 AS
BEGIN

	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;
	DECLARE	@UserIsAdmin	bit;
	DECLARE	@UserID			Int;
	DECLARE @StrSelect		NVarChar(Max);
	DECLARE @StrWhereH		NVarChar(Max);

	
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	SET @UserID				= pub.funSplitString(@ExtraParams, '@', 9);
	SET @UserIsAdmin		= pub.funSplitString(@ExtraParams, '@', 10);


	set @FromDocDate=isnull(@FromDocDate,'')
	set @DocDate=isnull(@DocDate,'')
	set @DebitCode=isnull(@DebitCode,'')
	
	CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	Insert into  #tblAcntCode (AcntCode) SELECT Distinct DebitCode FROM trs.tblPayHdr where  ProcessID = 41
	SET @StrWhereH = ''
	if @UserIsAdmin=0
	begin
		exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		SET @StrWhereH = ' and H.DebitCode in (SELECT AcntCode FROM  #tblAcntCode ) '
	END
	
set @StrSelect = '
	SELECT A.ProcessNo,A.FiscalYear,A.SerialNo,DocDate,B.DebitCode, [pub].[GetCodeName](B.DebitCode,'+ str(@LanguageID)+') AcntName 
	FROM (
		SELECT ProcessNo,FiscalYear,SerialNo
		FROM trs.tblPayHdr A
		WHERE ProcessID = 41 AND ProcessNo = '+ str(@ProcessNo)+' AND
				DocDate >='''+ @FromDocDate+'''   AND DocDate <='''+  @DocDate+'''
				AND ( '''+ @DebitCode+'''  ='''' OR DebitCode ='''+ @DebitCode+'''  )
				and (
					'+ str(@ConfirmCount)+'=0 or 
					('+ str(@ConfirmCount)+' >0 
										and (('+ str(@Sgn1)+'=0 and SgnSN1=0) or ('+ str(@Sgn1)+'>0 and SgnSN1>0)  )
				  						and (('+ str(@Sgn2)+'=0 and SgnSN2=0) or ('+ str(@Sgn2)+'>0 and SgnSN2>0)  )
										and (('+ str(@Sgn3)+'=0 and SgnSN3=0) or ('+ str(@Sgn3)+'>0 and SgnSN3>0)  )
										and (('+ str(@Sgn4)+'=0 and SgnSN4=0) or ('+ str(@Sgn4)+'>0 and SgnSN4>0)  )
										and (('+ str(@Sgn5)+'=0 and SgnSN5=0) or ('+ str(@Sgn5)+'>0 and SgnSN5>0)  )
			)) And  PayDisapprove = 0
		EXCEPT
		SELECT BaseProcessNo,BaseFiscalYear,BaseSerialNo
		FROM trs.tblPayHdr B
		WHERE ProcessID = 2 AND ProcessNo = '+ str(@ProcessNo)+' AND BaseProcessID=41 AND
				NOT (SerialNo='+ str(@SerialNo)+' AND FiscalYear='+ str(@FiscalYear)+') 
		) A
		INNER JOIN
		(	SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,H.DebitCode ,H.DocDate
			FROM     trs.tblPayHdr H
			WHERE H.ProcessID = 41 AND H.ProcessNo ='+ str(@ProcessNo)+'  AND 
				  H.DocDate <= '''+ @DocDate+'''  '+@StrWhereH+'
		 ) B
		ON A.FiscalYear=B.FiscalYear AND A.SerialNo=B.SerialNo AND A.ProcessNo=B.ProcessNo ' 

	print   @StrSelect;             
	EXEC sp_executesql @StrSelect;

END
GO
