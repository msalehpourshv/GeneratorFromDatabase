USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : jafari
-- Create date   : 1395/10/18
-- Viewed By	 : 
-- Last Modified : 1395/10/18
-- Description   : 
-- =============================================
create PROCEDURE  inv.UpdateQty2GoodsUserPrice
	WITH ENCRYPTION
AS

BEGIN


select 1 

-----  این بروز رسانی بعداد موجودی کالا های دارای قیمت مصرف کننده میباشد که هنگام بررسی سرعت شرکت آرمان گلدشت پیدا شد و به همراه آقای صادقی بررسی شد و چون کاربردی پیدا نشد حذف گردید
-----    این کویری جهت بررسی های بعدی در صورت مشکل تعداد  کالا های مصرف کننده دار در برنامه مارک شد و حذف نشد

--update inv.tblGoodsUserPrice
--set GoodsQuantity =Qty
--From inv.tblGoodsUserPrice a 
--inner join  
--(select GoodsID,UserPriceID ,isnull(SUM(EnterKind*GoodsQuantity) ,0) Qty 
--from  inv.tblStorageDocsDtl 
--where UserPriceID<>0 
--group by GoodsID,UserPriceID
--) d 
--on a.ID=d.UserPriceID and a.GoodsID=d.GoodsID           




END
GO
