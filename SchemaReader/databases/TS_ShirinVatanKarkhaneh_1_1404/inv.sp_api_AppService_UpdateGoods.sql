USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : E.Alian
-- Create date   : 1401/06/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_AppService_UpdateGoods

@TechnicalNo AS NVARCHAR(100),
@GoodsName AS NVARCHAR(100),
@Description AS NVARCHAR(100)

WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)

BEGIN TRY

	
	IF(SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=@TechnicalNo)=0
	BEGIN
		Set @StrErrorMessage = N'کد کالا ثبت نشده است'
		raiserror (@StrErrorMessage, 16, 1)
	END
	else
	begin

	--set @StrErrorMessage='update gd
	--	set gd.Description='''+@Description+''' ,gd.GoodsName='''+@GoodsName +'''
	--	from inv.tblGoods g
	--	inner join inv.tblGoodsDtl gd on g.GoodsID=gd.GoodsID
	--	where g.GoodsID='''+@TechnicalNo+''''
		
		print @StrErrorMessage

		update gd
		set gd.Description=@Description ,gd.GoodsName=@GoodsName 
		from inv.tblGoods g
		inner join inv.tblGoodsDtl gd on g.GoodsID=gd.GoodsID
		where g.GoodsID=@TechnicalNo
	end



END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
