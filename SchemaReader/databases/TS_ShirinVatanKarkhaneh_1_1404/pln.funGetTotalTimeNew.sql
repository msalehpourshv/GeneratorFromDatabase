USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1400-10-14
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : تابعی برای بدست آوردن زمان فعلی برای سفارش انجام کار ناتمام
-- ==============================================
Create FUNCTION pln.funGetTotalTimeNew
(
	@StartDate char(10) ,
	@StartTime char(5) ,
	@TotalTime Int
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN
	Declare @FinishTime char(5) 

	if @TotalTime<>0
		Return  @TotalTime
	
	
	set @FinishTime=convert (char (5),GETDATE(), 108)

	set @TotalTime=  (DATEDIFF(Day,[pub].[funChangeDate_PersianToGergorian](@StartDate),getdate ()))*1440
						+DATEDIFF(MINUTE,  '00:00:00',@FinishTime)
						- DATEDIFF(MINUTE, '00:00:00',@StartTime)

		Return  @TotalTime*60
end 
GO
