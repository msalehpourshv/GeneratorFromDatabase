USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ========= TS-QC:OK ==========================
-- Author        : Majid Mohammadi
-- Description   : تست اینکه کدام استور پرو سیجرها یا فانکشین ها بازبینی شده است؟
-- Create date   : 1386/11/23
-- Last Modified : 1386/11/29
-- Viewed By	 : Majid Mohammadi
-- =============================================

CREATE PROCEDURE [pub].[spMM]
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	select * from sys.all_objects as o
	inner join sys.sql_modules as m
	on m.object_id=o.object_id
--  where [type]in ('FN','IF','TF','FS')
--	where not definition like '%TS-QC:OK%' and not definition like '%Majid%'
	order by o.name

END









GO
