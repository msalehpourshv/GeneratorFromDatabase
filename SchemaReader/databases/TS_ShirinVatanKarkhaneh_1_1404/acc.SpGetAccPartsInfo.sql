USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 86/12/25
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : اطلاعات مربوط به طول بخشها را در متغیرهای
--					مربوطه پر می کند
-- ==============================================
CREATE PROCEDURE [acc].[SpGetAccPartsInfo]
	@Part1Start	TinyInt	OUTPUT,
	@Part2Start	TinyInt	OUTPUT,
	@Part3Start	TinyInt	OUTPUT,
	@Part4Start	TinyInt	OUTPUT,

	@Part1End	TinyInt	OUTPUT,
	@Part2End	TinyInt	OUTPUT,
	@Part3End	TinyInt	OUTPUT,
	@Part4End	TinyInt	OUTPUT,

	@Part1Len	TinyInt	OUTPUT,
	@Part2Len	TinyInt	OUTPUT,
	@Part3Len	TinyInt	OUTPUT,
	@Part4Len	TinyInt	OUTPUT
	WITH ENCRYPTION
AS 
Begin --============== S T A R T  C O D E =======================================

	Set NoCount On;

	SELECT	@Part1Start = 1;

	SELECT	@Part1End = @Part1Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part1Len = @Part1End + 1 - @Part1Start;

	--------------------------------------------------------------------

	SELECT	@Part2Start = @Part1End + 2;

	SELECT	@Part2End = @Part2Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part2Len = @Part2End + 1 - @Part2Start;

	--------------------------------------------------------------------

	SELECT	@Part3Start = @Part2End + 2;

	SELECT	@Part3End = @Part3Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part3Len = @Part3End + 1 - @Part3Start;

	--------------------------------------------------------------------

	SELECT	@Part4Start = @Part3End + 2;

	SELECT	@Part4End = @Part4Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	SELECT	@Part4Len = @Part4End + 1 - @Part4Start;
End
GO
