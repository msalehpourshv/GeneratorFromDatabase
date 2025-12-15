USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : TakroSystem\ZiA
-- Create date   : 1393/04/24
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- =============================================
CREATE FUNCTION [acc].[funGetLastPartName]
(
	@FullAcntCode VarChar(20)
)
RETURNS	NVarChar(200)
	
WITH ENCRYPTION
AS 
Begin
	declare @AcntName NVarChar(200) 
	DECLARE	@StrAcnt1Start	TinyInt
	DECLARE	@StrAcnt2Start	TinyInt
	DECLARE	@StrAcnt3Start	TinyInt
	DECLARE	@StrAcnt4Start	TinyInt

	DECLARE	@StrAcnt1Len	TinyInt
	DECLARE	@StrAcnt2Len	TinyInt
	DECLARE	@StrAcnt3Len	TinyInt
	DECLARE	@StrAcnt4Len	TinyInt

	DECLARE	@StrAcnt1End	TinyInt
	DECLARE	@StrAcnt2End	TinyInt
	DECLARE	@StrAcnt3End	TinyInt
	DECLARE	@StrAcnt4End	TinyInt

	DECLARE	@intCurrent		TinyInt
	DECLARE	@intLangID		TinyInt

	SET @intLangID = pub.funGetCurrentLanguageID()
	
	SELECT	@StrAcnt1Start = 1;

	SELECT	@StrAcnt1End = @StrAcnt1Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@StrAcnt1Len = @StrAcnt1End + 1 - @StrAcnt1Start;

	--------------------------------------------------------------------

	SELECT	@StrAcnt2Start = @StrAcnt1End + 2;

	SELECT	@StrAcnt2End = @StrAcnt2Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@StrAcnt2Len = @StrAcnt2End + 1 - @StrAcnt2Start;

	--------------------------------------------------------------------

	SELECT	@StrAcnt3Start = @StrAcnt2End + 2;

	SELECT	@StrAcnt3End = @StrAcnt3Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@StrAcnt3Len = @StrAcnt3End + 1 - @StrAcnt3Start;

	--------------------------------------------------------------------

	SELECT	@StrAcnt4Start = @StrAcnt3End + 2;

	SELECT	@StrAcnt4End = @StrAcnt4Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	SELECT	@StrAcnt4Len = @StrAcnt4End + 1 - @StrAcnt4Start;

	--------------------------------------------------------------------
	If Len(@FullAcntCode) <= @StrAcnt1End
	Begin
		SELECT	@AcntName=AcntName
		FROM	acc.tblAcntDtl A 
		WHERE	A.PartNumber = 1 AND A.AcntCode = @FullAcntCode AND LanguageID = @intLangID
	End

	Else If Len(@FullAcntCode) <= @StrAcnt2End
	Begin
		SELECT	@AcntName=AcntName
		FROM	acc.tblAcntDtl A 
		WHERE	A.PartNumber = 2 AND A.AcntCode = Substring(@FullAcntCode, @StrAcnt2Start, @StrAcnt2Len)  AND LanguageID = @intLangID
	End 

	Else If Len(@FullAcntCode) <= @StrAcnt3End
	Begin
		SELECT	@AcntName=AcntName
		FROM	acc.tblAcntDtl A 
		WHERE	A.PartNumber = 3 AND A.AcntCode = Substring(@FullAcntCode, @StrAcnt3Start, @StrAcnt3Len)  AND LanguageID = @intLangID
	End

	Else If Len(@FullAcntCode) <= @StrAcnt4End
	Begin
		SELECT	@AcntName=AcntName
		FROM	acc.tblAcntDtl A 
		WHERE	A.PartNumber = 4 AND A.AcntCode = Substring(@FullAcntCode, @StrAcnt4Start, @StrAcnt4Len) AND LanguageID = @intLangID
	End

	RETURN @AcntName
End
GO
