USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/16
-- Viewed By	 : 
-- Last Modified : 
-- Description   : (Doc) حذف کلی یک سند 
-- =============================================
CREATE PROCEDURE [pub].[SpRemoveDoc]
	@TableNameHdr	VarChar(60),
	@TableNameDtl	VarChar(60),
	@TableNameDtl2	VarChar(60),
	@TableNameAtom	VarChar(60),
	@CodeField		VarChar(600),
	@ProcessID		SmallInt = 0,
	@ProcessNo		TinyInt = 0,
	@FiscalYear		SmallInt = 0,
	@SerialNo		Int = 0,
	@Code			NVarChar(500) = NULL,
	@TableNameAtom2	VarChar(100) = NULL,
	@TableNameAtom3	VarChar(100) = NULL
WITH ENCRYPTION
AS 

Declare @StrSQL	NVarChar(4000);
Declare @StrWHR	NVarChar(4000);

Begin --============== S T A R T  C O D E ===================================================

	Set NoCount On;

	IF @SerialNo = 0
		BEGIN
			Declare @strErr As Nvarchar(1024)
			Declare @LanguageID As tinyint
			SET @LanguageID = pub.funGetCurrentLanguageID();
			Set @strErr = TS.pub.funGetMessages(25001,@LanguageID)
			raiserror (@strErr, 16, 1)
		END
		
	-- I N I T ----------------------------------------------------------------
	If (@ProcessID  Is Null) Set @ProcessID  = 0;
	If (@ProcessNo  Is Null) Set @ProcessNo  = 0;
	If (@FiscalYear Is Null) Set @FiscalYear = 0;
	If (@SerialNo	Is Null) Set @SerialNo	 = 0;

     ---- باعث حذف فرمولهای تولید با شماره 1
	If (@Code = '')	AND (@CodeField = '' OR @CodeField IS NULL)
		Set @Code = NULL ;

	Set @StrWHR = '';
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	If (@ProcessID <> 0)
	Begin
		If (@StrWHR <> '')
			Set @StrWHR = @StrWHR + ' AND '

		Set @StrWHR = @StrWHR + 'ProcessID = ' + LTrim(Str(@ProcessID))
	End

	If (@ProcessNo <> 0)
	Begin
		If (@StrWHR <> '')
			Set @StrWHR = @StrWHR + ' AND '

		Set @StrWHR = @StrWHR + 'ProcessNo = ' + LTrim(Str(@ProcessNo))
	End

	If (@FiscalYear <> 0)
	Begin
		If (@StrWHR <> '')
			Set @StrWHR = @StrWHR + ' AND '

		Set @StrWHR = @StrWHR + 'FiscalYear = ' + LTrim(Str(@FiscalYear))
	End

	If (@SerialNo <> 0)
	Begin
		If (@StrWHR <> '')
			Set @StrWHR = @StrWHR + ' AND '

		Set @StrWHR = @StrWHR + 'SerialNo = ' + LTrim(Str(@SerialNo))
	End


	If (@Code IS NOT NULL)
	Begin
		If (@StrWHR <> '')
			Set @StrWHR = @StrWHR + ' AND '

		IF @CodeField  <> ''
			SET @StrWHR =  @StrWHR + pub.funSplitString(@CodeField, '@', 1) + ' = ''' + pub.funSplitString(@Code, '@', 1) + '''' 
		
		IF @CodeField<>'' AND pub.funSplitString(@CodeField, '@', 2)<>''
			SET @StrWHR = @StrWHR + ' AND ' + pub.funSplitString(@CodeField, '@', 2) + ' = ''' + pub.funSplitString(@Code, '@', 2) + '''' 
		
		IF @CodeField<>'' AND pub.funSplitString(@CodeField, '@', 3)<>''
			SET @StrWHR = @StrWHR + ' AND ' + pub.funSplitString(@CodeField, '@', 3) + ' = ''' + pub.funSplitString(@Code, '@', 3) + '''' 

		IF @CodeField<>'' AND pub.funSplitString(@CodeField, '@', 4)<>''
			SET @StrWHR = @StrWHR + ' AND ' + pub.funSplitString(@CodeField, '@', 4) + ' = ''' + pub.funSplitString(@Code, '@', 4) + '''' 

		IF @CodeField<>'' AND pub.funSplitString(@CodeField, '@', 5)<>''
			SET @StrWHR = @StrWHR + ' AND ' + pub.funSplitString(@CodeField, '@', 5) + ' = ''' + pub.funSplitString(@Code, '@', 5) + '''' 
		
	End
	---------------------------------------------------------------------------

--	IF object_id('tempdb.dbo.##tblSpRemoveDoc') IS NOT NULL DROP TABLE ##tblSpRemoveDoc
	-- جهت اعلام اجرای این تابع در تریگرها
--	Create Table ##tblSpRemoveDoc(fld Bit);

	IF @StrWHR = ''
		RETURN 

	-- S E L E C T ------------------------------------------------------------
	BEGIN TRY
		If (@TableNameAtom Is Not Null) 
		Begin
			Set @StrSQL = '
			DELETE	FROM ' + @TableNameAtom + '
			WHERE	' + @StrWHR 
			
			Exec sp_executesql @StrSQL;
		End
		
		If (@TableNameAtom2 Is Not Null) 
		Begin
			Set @StrSQL = '
			DELETE	FROM ' + @TableNameAtom2 + '
			WHERE	' + @StrWHR 
			
			Exec sp_executesql @StrSQL;
		End
	
		If (@TableNameAtom3 Is Not Null) 
		Begin
			Set @StrSQL = '
			DELETE	FROM ' + @TableNameAtom3 + '
			WHERE	' + @StrWHR 
			
			Exec sp_executesql @StrSQL;
		End
			
		If (@TableNameDtl2 Is Not Null) 
		Begin
			Set @StrSQL = '
			DELETE	FROM ' + @TableNameDtl2 + '
			WHERE	' + @StrWHR 

			Exec sp_executesql @StrSQL;
		End

		If (@TableNameDtl Is Not Null) 
		Begin
			If (@TableNameDtl =N'acc.tblVoucherDtl') 
			Begin
			--  حذف تطبیق های سندهای بدون مرجع
				Set @StrSQL = 'DELETE FROM acc.tblAccState
					WHERE  BaseID1 in( select ID From acc.tblVoucherDtl 	WHERE	' + @StrWHR +'  )
						or BaseID2 in( select ID From acc.tblVoucherDtl 	WHERE	' + @StrWHR +'  )'
					Exec sp_executesql @StrSQL;

					Set @StrSQL = 'DELETE FROM acc.tblVoucher2AccState
					WHERE  BaseID in( select ID From acc.tblVoucherDtl 	WHERE	' + @StrWHR +'  )'
					Exec sp_executesql @StrSQL;

			end 
		
			Set @StrSQL = '
			DELETE	FROM ' + @TableNameDtl + '
			WHERE	' + @StrWHR 

			Exec sp_executesql @StrSQL;
		End

		If (@TableNameHdr Is Not Null) 
		Begin
			Set @StrSQL = '
			DELETE	FROM ' + @TableNameHdr + '
			WHERE	' + @StrWHR 

			Exec sp_executesql @StrSQL;
		End
		
--		Drop Table ##tblSpRemoveDoc

	END TRY

	BEGIN CATCH
--		Drop Table ##tblSpRemoveDoc
		If ERROR_NUMBER() = 547
			raiserror ('با حذف این رکورد مانده در کارت کالا منفی میشود' , 21, 1)
		Else
			Declare @strErrorMessage As Nvarchar(1024)
			Set @strErrorMessage = ERROR_MESSAGE() 
			raiserror (@strErrorMessage, 16, 1)
		RETURN
	
	END CATCH
	---------------------------------------------------------------------------
End
GO
