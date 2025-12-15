USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE dbo.SP_Personnels_Absence_Report
	
	@Emp_No   VarChar(200) = '101, 2509',
	@Date_Fr         Int = 14030501,
	@Date_To         Int = 14030531,
	@Detailed        Bit = 0,
	@Reload_Full_Rpt Bit = 0

WITH ENCRYPTION
AS 

DECLARE @StrSelect	NVarChar(Max) = '';
DECLARE @StrSelect2	NVarChar(Max) = '';
DECLARE @StrSelect3	NVarChar(Max) = '';
DECLARE @StrSelect4	NVarChar(Max) = '';
DECLARE @StrSelect5	NVarChar(Max) = '';
DECLARE @StrWhere	NVarChar(Max) = '1 = 1';
DECLARE @StrWhere2	NVarChar(Max) = '1 = 1';
DECLARE @StrWhere3	NVarChar(Max) = '1 = 1';
DECLARE @StrWhere4	NVarChar(Max) = '1 = 1';

DECLARE @Date       Char(10)      = ''

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- ====================================================================================================
	Select @Date = SubString(LTrim(RTrim(Str(@Date_Fr))), 1, 4) + '/' + SubString(LTrim(RTrim(Str(@Date_Fr))), 5, 2) + '/' + SubString(LTrim(RTrim(Str(@Date_Fr))), 7, 2)

	-- ====================================================================================================
	-- ==================================================================================================== WHERE
	-- ====================================================================================================
	SET @StrWhere = @StrWhere + '
	      And T.Emp_No >= 101 
	      And T.Emp_No Not IN(105, 117, 346, 99030064)'

	SET @StrWhere2 = @StrWhere2 + '
	      And ((T1.Date_2 = N''غ'' And IsNull(T3.Date_2, '''') = N''غ'') OR (T1.Date_2 = N''غ'' And IsNull(T2.Date_2, '''') = N''غ''))
	      And T1.Emp_No >= 101
		  And T1.Emp_No Not IN(105, 117, 346, 99030064)'

	SET @StrWhere3 = @StrWhere3 + '
	            And Emp_No IN(DF.Emp_No)'

	SET @StrWhere4 = @StrWhere4 + '
	      And Emp_No >= 101 
	      And Emp_No Not IN(105, 117, 346, 99030064)'

	IF @Emp_No <> '' And @Emp_No Is Not Null
	Begin
	   SET @StrWhere = @StrWhere + '
	      And T.Emp_No IN(' + @Emp_No + ')'

	   SET @StrWhere2 = @StrWhere2 + '
	      And T1.Emp_No IN(' + @Emp_No + ')'

	   SET @StrWhere4 = @StrWhere4 + '
	      And Emp_No IN(' + @Emp_No + ')'
	End

	IF @Date_Fr > 0 And @Date_Fr Is Not Null
	Begin
	   SET @StrWhere = @StrWhere + '
	      And T.Date   >= ' + LTrim(RTrim(Str(@Date_Fr)))

	   SET @StrWhere2 = @StrWhere2 + '
	      And T1.Date_1 >= ' + LTrim(RTrim(Str(@Date_Fr)))

	   SET @StrWhere3 = @StrWhere3 + '
	            And S_Date >= ' + LTrim(RTrim(Str(@Date_Fr)))
    End

	IF @Date_To > 0 And @Date_To Is Not Null
	Begin
	   SET @StrWhere = @StrWhere + '
	      And T.Date   <= ' + LTrim(RTrim(Str(@Date_To)))

	   SET @StrWhere2 = @StrWhere2 + '
	      And T1.Date_1 <= ' + LTrim(RTrim(Str(@Date_To)))

	   SET @StrWhere3 = @StrWhere3 + '
	            And E_Date <= ' + LTrim(RTrim(Str(@Date_To)))
    End

	-- ====================================================================================================
	-- ==================================================================================================== SELECT
	-- ====================================================================================================
	IF @Reload_Full_Rpt = 1
	BEGIN
		SET @StrSelect2 = @StrSelect2 + N'
	IF object_id (''Kara.dbo.TmpTable_4'') Is Not Null DROP TABLE Kara.dbo.TmpTable_4
	IF object_id (''Kara.dbo.Tbl_Days'') Is Not Null DROP TABLE Kara.dbo.Tbl_Days

	-- ====================================================================================================
	-- ==================================================================================================== CREATE Date List
	-- ====================================================================================================
	CREATE TABLE Kara.dbo.Tbl_Days([Emp_No] Int, [Date] Int)

	-- ================================================= START CURSOR
	DECLARE @Emp_No      Int

	-- ===== Cursor11
	DECLARE Cursor11 CURSOR FOR

		SELECT Distinct Emp_No
		FROM Kara.dbo.Employee
		WHERE ' + @StrWhere4 + '

	OPEN Cursor11;

	FETCH NEXT FROM Cursor11 INTO @Emp_No;
	WHILE @@FETCH_STATUS = 0
	BEGIN
		-- ======================================================================
		-- ====================================================================== START Cursor Body
		-- ======================================================================
		Declare @Start_Day    Char(10) = SubString(LTrim(RTrim(Str(''' + LTrim(RTrim(Str(@Date_Fr))) + '''))), 1, 4) + ''/'' + SubString(LTrim(RTrim(Str(''' + LTrim(RTrim(Str(@Date_Fr))) + '''))), 5, 2) + ''/'' + ''01''
		Declare @Start_Number Int      = 0
		Declare @End_Number   Int      = 31 - Cast(SubString(LTrim(RTrim(Str(''' + LTrim(RTrim(Str(@Date_Fr))) + '''))), 7, 2) As Int)
		Declare @Filter_Date  Char(10) = ''''

		Select @Filter_Date = TS_ShirinVatanKarkhaneh_1_1403.pub.funChangeDate_PersianToGergorian(''' + LTrim(RTrim(@Date)) + ''')
		Select @Start_Number = (Cast(SubString(Replace(TS_ShirinVatanKarkhaneh_1_1403.pub.funChangeDate_GergorianToPersian(@Filter_Date), ''/'', ''''), 7, 2) As Int) - 1) * -1

		--Select Replace(TS_ShirinVatanKarkhaneh_1_1403.pub.funChangeDate_GergorianToPersian(DATEADD(day, 3, CONVERT(date, DATEADD(month, 0, @Filter_Date)))), ''/'', '''')

		WHILE (@Start_Number <= @End_Number)
		BEGIN
			Insert Into Kara.dbo.Tbl_Days ([Emp_No], [Date]) 
			Values (@Emp_No, Replace(TS_ShirinVatanKarkhaneh_1_1403.pub.funChangeDate_GergorianToPersian(DATEADD(day, @Start_Number, CONVERT (date, DATEADD(month, 0, @Filter_Date)))), ''/'', ''''))

			Select @Start_Number = @Start_Number + 1
		END
	
		-- ======================================================================
		-- ====================================================================== END Cursor Body
		-- ======================================================================
		
		FETCH NEXT FROM Cursor11 INTO @Emp_No;
	END

	CLOSE Cursor11;
	DEALLOCATE Cursor11;

	--SELECT * FROM Kara.dbo.Tbl_Days Order By Emp_No, Date'

		SET @StrSelect3 = N'
	-- ==========================================================================================================
	-- ========================================================================================================== INIT Temp_Table
	-- ==========================================================================================================
	SELECT ROW_NUMBER() OVER(PARTITION BY Emp_No ORDER BY Emp_No ASC) RowNo, Emp_No, Date_1, 
		   Case When LTrim(RTrim(Status)) = '''' And Date_2 IS Null Then N''غ'' Else Status End Date_2,
		   Case When Day_No = 7 Then N''جمعه'' Else '''' End Day_Name
			--, [Count]
	INTO Kara.dbo.TmpTable_4
	FROM
	(
		Select T.Emp_No, T.Date Date_1, D.Date Date_2, 
			   DATEPART(DW, pub.funChangeDate_PersianToGergorian(SubString(LTrim(RTrim(Str(T.Date))), 1, 4) + ''/'' + 
						  SubString(LTrim(RTrim(Str(T.Date))), 5, 2) + ''/'' + SubString(LTrim(RTrim(Str(T.Date))), 7, 2))) + 1 Day_No,
			   dbo.Fun_Get_Personnel_Absence_Type(T.Emp_No, 14030501, 14030531, T.Date)  Status, Count(T.Emp_No) [Count]
		From Kara.dbo.Tbl_Days       T 
		Left Join Kara.dbo.DataFile D ON D.Emp_No = T.Emp_No And D.Date = T.Date
		Left Join Kara.dbo.Employee E ON E.Emp_No = T.Emp_No And E.Sys_Active = 1 And E.IsCut = 0
		Where ' + @StrWhere + '
		Group By T.Emp_No, T.Date, D.Date
	) A
	ORDER BY A.Date_1
	--SELECT * FROM Kara.dbo.TmpTable_4'
	END

	SET @StrSelect4 = N'
	-- ==========================================================================================================
	-- ========================================================================================================== SELECT
	-- =========================================================================================================='
	IF @Detailed = 0
	   SET @StrSelect4 = @StrSelect4 + N'
	IF object_id (''acc.tblAAAA_Kara_Traffic_Repors'') Is Not Null DROP TABLE acc.tblAAAA_Kara_Traffic_Repors

	-- ==========================================================================================================
    SELECT [کد تکروسیستم] ,[کد پرسنل], [نام پرسنل], [سمت], [بخش], (Select COUNT(Consecutive_Absence) Where Consecutive_Absence = ''دارد'') [غ-متوالی]
	INTO acc.tblAAAA_Kara_Traffic_Repors
    FROM
    ('

	SET @StrSelect4 = @StrSelect4 + N'
      SELECT Emp_No [کد پرسنل], PersonnelID [کد تکروسیستم], Emp_Name [نام پرسنل], Job_Title [سمت], Job_Main_Unit [بخش], 
             IsNull(SubString(LTrim(RTrim(Str(Date))), 1, 4) + ''/'' + SubString(LTrim(RTrim(Str(Date))), 5, 2) + ''/'' + SubString(LTrim(RTrim(Str(Date))), 7, 2), '''') [تاریخ],
             Case When (Status = N''غ'' And Pre_Status = N''غ'') OR (Status = N''غ'' And After_Status = N''غ'') Then N''دارد'' Else '''' End ' +
			 Case When @Detailed = 0 Then 'Consecutive_Absence' Else '[غیبت متوالی]' End + ',
             Day_Name [روز هفته] ' +
      Case When @Detailed <> 0 Then '
	  INTO acc.tblAAAA_Kara_Traffic_Repors'
	  Else '' End + '
      FROM
      (
        SELECT T1.RowNo, T1.Emp_No, P1.PersonnelID, E.Name + '' '' + E.Family Emp_Name, IsNull(T3.Date_1, '''') Pre_Date, IsNull(T3.Date_2, '''') Pre_Status, 
               T1.Date_1 Date, T1.Date_2 Status, IsNull(T2.Date_1, '''') After_Date, IsNull(T2.Date_2, '''') After_Status, P.Title Job_Title,
               S.Title Job_Unit, Kara.dbo.Fun_Get_Section_Parent(E.Sec_No) COLLATE Latin1_General_CS_AS_KS_WS Job_Main_Unit, T1.Day_Name
        FROM       Kara.dbo.TmpTable_4 T1
        LEFT  JOIN Kara.dbo.TmpTable_4 T2 ON T2.Emp_No     = T1.Emp_No And T1.RowNo = T2.RowNo - 1
        LEFT  JOIN Kara.dbo.TmpTable_4 T3 ON T3.Emp_No     = T1.Emp_No And T1.RowNo = T3.RowNo + 1
        INNER JOIN Kara.dbo.Employee    E ON T1.Emp_No     = E.Emp_No And E.Sys_Active = 1 And E.IsCut = 0
        LEFT  JOIN Kara.dbo.Position    P ON P.Pos_No      = E.Pos_No
        LEFT  JOIN Kara.dbo.Sections    S ON S.Sec_No      = E.Sec_No
        LEFT  JOIN prs.tblPersonnels   P1 ON P1.CardNumber = Case When Len(T1.Emp_No) = 3 Then ''0'' + T1.Emp_No Else T1.Emp_No End
        WHERE ' + @StrWhere2 + '
      ) A
	  WHERE Job_Main_Unit <> ''''' +
      Case When @Detailed = 1 Then '
      ORDER BY Emp_No, RowNo' 
      Else '' End

	IF @Detailed = 0
	   SET @StrSelect4 = @StrSelect4 + N'
    ) B
    GROUP BY [کد تکروسیستم] ,[کد پرسنل], [نام پرسنل], [سمت], [بخش], Consecutive_Absence
    HAVING   (Select COUNT(Consecutive_Absence) Where Consecutive_Absence = ''دارد'') Is Not Null
    ORDER BY [کد پرسنل]
	'
	-- ========================================================================================================
	-- ======================================================================================================== END
	-- ========================================================================================================	
	
	-- =================================================== EXEC
	PRINT @StrSelect2;
	PRINT @StrSelect3;
	PRINT @StrSelect4;
	PRINT @StrSelect5;
	SET   @StrSelect = @StrSelect2 + @StrSelect3 + @StrSelect4 + @StrSelect5;
	EXEC  sp_executesql @StrSelect;	

END
GO
