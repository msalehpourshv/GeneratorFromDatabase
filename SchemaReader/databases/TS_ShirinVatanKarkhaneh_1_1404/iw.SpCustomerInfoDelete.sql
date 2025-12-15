USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/19
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < ایجاد مشتریان>
-- ==============================================
Create PROCEDURE iw.SpCustomerInfoDelete 
	@UserID			int,
	@StationID		varchar(20) ,
	@CustomerInfoID	varchar(20) 	
WITH ENCRYPTION
AS
BEGIN	
	Declare @StrSelect	NVarChar(max);
 
	set @StrSelect	=' Delete From  lyl.tblCustomerInfo 
					where CustomerInfoID=''' +@CustomerInfoID+ ''''
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	   
	set @StrSelect	=' Select isnull(Count(*),0) TotalCount From  lyl.tblCustomerInfo 
						where CustomerInfoID=''' +@CustomerInfoID+ ''''
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END

--لیست ورودی 
--1- کد کاربر
--2- کد شعبه
--3- کد



-- لیست خروجی
--1- تعداد مشتری
GO
