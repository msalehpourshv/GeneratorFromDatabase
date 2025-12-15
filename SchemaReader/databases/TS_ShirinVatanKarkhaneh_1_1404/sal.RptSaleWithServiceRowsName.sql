USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation date : 1397/03/14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش کلی فروش بهمن فولاد
-- ==============================================
Create PROCEDURE sal.RptSaleWithServiceRowsName
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
BEGIN

	DECLARE	@CalcType		Int;
	SET @CalcType			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	
	--drop table #tblRows
	
	Select 1 Visible,200 ColSize,'نام               مشتری' ColNameFa into #tblRows
	
	Delete from #tblRows
	
	
if @CalcType=1
begin
insert into   #tblRows select  1,75,'شماره'
insert into   #tblRows select  1,75,'تاریخ'
insert into   #tblRows select  1,200,'نام مشتری'
insert into   #tblRows select  1,200,'شرح كالا'
insert into   #tblRows select   1,75,'ضخامت'
insert into   #tblRows select   1,75,'عرض'
insert into   #tblRows select   1,75,'مقدار'
insert into   #tblRows select   1,75,'فی'
insert into   #tblRows select   1,75,'مبلغ فروش'
insert into   #tblRows select   1,75,'نوع محصول'
insert into   #tblRows select   1,75,'طول'
insert into   #tblRows select   1,75,'تعداد'
insert into   #tblRows select   1,75,'متراژ'
insert into   #tblRows select   1,75,'فی'
insert into   #tblRows select   1,75,'ش حواله'
end


if @CalcType=2
begin
insert into   #tblRows select  1,200,'نام مشتری'
insert into   #tblRows select  1,75,'کد كالا'
insert into   #tblRows select  1,200,'شرح كالا'
insert into   #tblRows select   1,75,'ضخامت'
insert into   #tblRows select   1,75,'عرض'
insert into   #tblRows select   1,75,'مقدار'
insert into   #tblRows select   1,75,'فی'
insert into   #tblRows select   1,75,'مبلغ فروش'
insert into   #tblRows select   1,75,'نوع محصول'
insert into   #tblRows select   1,75,'تعداد'
insert into   #tblRows select   1,75,'متراژ'
insert into   #tblRows select   1,75,'فی'


end

if @CalcType=3
begin
insert into   #tblRows select  1,250,'نام مشتری'
insert into   #tblRows select   1,100,'مقدار'
insert into   #tblRows select   1,100,'فی'
insert into   #tblRows select   1,100,'مبلغ فروش'
insert into   #tblRows select   1,100,'تعداد'
insert into   #tblRows select   1,100,'متراژ'
insert into   #tblRows select   1,100,'فی'
end


if @CalcType=4
begin
insert into   #tblRows select  1,200,'شرح كالا'
insert into   #tblRows select   1,100,'مقدار'
insert into   #tblRows select   1,100,'فی'
insert into   #tblRows select   1,100,'مبلغ فروش'
insert into   #tblRows select   1,100,'تعداد'
insert into   #tblRows select   1,100,'متراژ'
insert into   #tblRows select   1,100,'فی'
end

if @CalcType=5
begin
insert into   #tblRows select  1,200,'نام كالا'
insert into   #tblRows select   1,100,'مقدار'
insert into   #tblRows select   1,100,'فی'
insert into   #tblRows select   1,100,'مبلغ فروش'
insert into   #tblRows select   1,100,'تعداد'
insert into   #tblRows select   1,100,'متراژ'
insert into   #tblRows select   1,100,'فی'
end

if @CalcType=6
begin
insert into   #tblRows select  1,200,'نام انبار'
insert into   #tblRows select   1,100,'مقدار'
insert into   #tblRows select   1,100,'فی'
insert into   #tblRows select   1,100,'مبلغ فروش'
insert into   #tblRows select   1,100,'تعداد'
insert into   #tblRows select   1,100,'متراژ'
insert into   #tblRows select   1,100,'فی'
end



if @CalcType=7
begin
insert into   #tblRows select  1,200,'نام كالای تولیدی'
insert into   #tblRows select   1,100,'مقدار'
insert into   #tblRows select   1,100,'فی'
insert into   #tblRows select   1,100,'مبلغ فروش'
insert into   #tblRows select   1,100,'تعداد'
insert into   #tblRows select   1,100,'متراژ'
insert into   #tblRows select   1,100,'فی'
end


if @CalcType=8
begin
insert into   #tblRows select  1,200,'نام کاربر'
insert into   #tblRows select   1,100,'تعداد حواله'
insert into   #tblRows select   1,100,'مقدار'
insert into   #tblRows select   1,100,'فی'
insert into   #tblRows select   1,100,'مبلغ فروش'
insert into   #tblRows select   1,100,'تعداد'
insert into   #tblRows select   1,100,'متراژ'
insert into   #tblRows select   1,100,'فی'
end


if @CalcType=9
begin
insert into   #tblRows select  1,200,'نام رال '
insert into   #tblRows select   1,100,'مقدار'
insert into   #tblRows select   1,100,'فی'
insert into   #tblRows select   1,100,'مبلغ فروش'
insert into   #tblRows select   1,100,'تعداد'
insert into   #tblRows select   1,100,'متراژ'
insert into   #tblRows select   1,100,'فی'
end

if @CalcType=10
begin
insert into   #tblRows select  1,120,'نام فصل'
insert into   #tblRows select  1,120,'مقدار'
insert into   #tblRows select  1,120,'فی'
insert into   #tblRows select  1,120,'مبلغ فروش'
insert into   #tblRows select  1,120,'تعداد'
insert into   #tblRows select  1,120,'متراژ'
insert into   #tblRows select  1,120,'فی'

end

if @CalcType=11
begin
insert into   #tblRows select  1,120,'نام ماه'
insert into   #tblRows select  1,120,'مقدار'
insert into   #tblRows select  1,120,'فی'
insert into   #tblRows select  1,120,'مبلغ فروش'
insert into   #tblRows select  1,120,'تعداد'
insert into   #tblRows select  1,120,'متراژ'
insert into   #tblRows select  1,120,'فی'

end
if @CalcType=12
begin
insert into   #tblRows select  1,200,'نام نصاب'
insert into   #tblRows select  1,100,'مبلغ فروش'
insert into   #tblRows select  1,100,'مبلغ پورسانت'
insert into   #tblRows select  1,100,'متراژ'
insert into   #tblRows select  1,100,'فی پورسانت'

end

if @CalcType=13
begin
insert into   #tblRows select  1,100,'شماره حواله'
insert into   #tblRows select  1,100,'تاریخ'
insert into   #tblRows select  1,200,'نام نصاب'
insert into   #tblRows select  1,100,'مبلغ فروش'
insert into   #tblRows select  1,100,'مبلغ پورسانت'
insert into   #tblRows select  1,100,'متراژ'
insert into   #tblRows select  1,100,'فی پورسانت'

end

if @CalcType=14
begin
insert into   #tblRows select  1,75,'شماره'
insert into   #tblRows select  1,75,'تاریخ'
insert into   #tblRows select  1,200,'نام مشتری'
insert into   #tblRows select  1,200,'شرح كالا'
insert into   #tblRows select   1,75,'ضخامت'
insert into   #tblRows select   1,75,'عرض'
insert into   #tblRows select   1,75,'مقدار'
insert into   #tblRows select   1,75,'فی'
insert into   #tblRows select   1,75,'نوع محصول'
insert into   #tblRows select   1,75,'طول'
insert into   #tblRows select   1,75,'تعداد'
insert into   #tblRows select   1,75,'متراژ'
insert into   #tblRows select   1,75,'باسکول'
insert into   #tblRows select   1,75,'تلرانس'
end


Select * from #tblRows
end 
GO
