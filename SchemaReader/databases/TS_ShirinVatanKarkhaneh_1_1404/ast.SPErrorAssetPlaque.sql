USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1404/01/05
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : شماره اموالهای دارای گردش مشکل دار
-- ==============================================
Create PROCEDURE ast.SPErrorAssetPlaque
	@CallType		int,
	@ExtraParams	NVarChar(Max) = ''
WITH ENCRYPTION
AS
BEGIN


	declare @AssetPlaque	VarChar(20) 
	declare @Cnt1	int
	declare @Cnt2	int
	declare @Evn	int

select   AssetPlaque,EventNo Into #AstList from ast.tblAssetsDtl where 1=0

	
DECLARE ASt1 CURSOR FOR
select Distinct AssetPlaque from ast.tblAssetsDtl
order by AssetPlaque

OPEN ASt1
FETCH NEXT FROM ASt1 INTO @AssetPlaque

WHILE @@fetch_status = 0
BEGIN

	set @Cnt2=0
	
	DECLARE ASt2 CURSOR FOR
	select   EnterKind,EventNo from ast.tblAssetsDtl where AssetPlaque=@AssetPlaque
	order by  DocDate, EventNo

	OPEN ASt2
	FETCH NEXT FROM ASt2 INTO @Cnt1,@Evn

	WHILE @@fetch_status = 0
	BEGIN

	Select @Cnt2=@Cnt2+@Cnt1
	if @Cnt2<0 or @Cnt2>1
		insert into #AstList
		select @AssetPlaque,@Evn
 
	FETCH NEXT FROM ASt2 INTO @Cnt1,@Evn
	END

	CLOSE ASt2
	DEALLOCATE ASt2
	   	 
FETCH NEXT FROM ASt1 INTO @AssetPlaque
END

CLOSE ASt1
DEALLOCATE ASt1

select * from #AstList

end
GO
