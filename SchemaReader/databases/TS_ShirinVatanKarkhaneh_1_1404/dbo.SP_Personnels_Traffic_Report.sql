USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =============================================================================================
-- =============================================================================================
-- =============================================================================================
CREATE PROCEDURE dbo.SP_Personnels_Traffic_Report
	
	@Emp_No  VarChar(200) = '101, 2509',
	@Date_Fr Int          = 14030501,
	@Date_To Int          = 14030531,
	@Grp_No  VarChar(200) = '19, 20'

WITH ENCRYPTION
AS 

DECLARE @StrSelect	NVarChar(Max) = '';
DECLARE @StrSelect2	NVarChar(Max) = '';
DECLARE @StrSelect3	NVarChar(Max) = '';
DECLARE @StrSelect4	NVarChar(Max) = '';
DECLARE @StrSelect5	NVarChar(Max) = '1 = 1';
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
	SET @StrWhere3 = @StrWhere3 + '
	            And Emp_No IN(DF.Emp_No)'

	IF @Emp_No <> '' And @Emp_No Is Not Null
	Begin
	   SET @StrWhere = @StrWhere + '
		And E.Emp_No Not IN(105, 117, 346, 99030064)
	    And E.Emp_No     IN(' + @Emp_No + ')'

	   SET @StrWhere4 = @StrWhere4 + '
	      And Emp_No >= 101 
	      And Emp_No IN(' + @Emp_No + ')
		  And Emp_No Not IN(105, 117, 346, 99030064)'
	End

	IF @Date_Fr > 0 And @Date_Fr Is Not Null
	Begin
	   SET @StrWhere = @StrWhere + '
		And E.End_Date    > ' + LTrim(RTrim(Str(@Date_Fr))) + '
	    And DF.Date      >= ' + LTrim(RTrim(Str(@Date_Fr)))

	   SET @StrWhere2 = @StrWhere2 + '
	    And M_Date >= ' + LTrim(RTrim(Str(@Date_Fr)))

	   SET @StrWhere3 = @StrWhere3 + '
	            And S_Date >= ' + LTrim(RTrim(Str(@Date_Fr)))
    End

	IF @Date_To > 0 And @Date_To Is Not Null
	Begin
	   SET @StrWhere = @StrWhere + '
	    And DF.Date      <= ' + LTrim(RTrim(Str(@Date_To)))

	   SET @StrWhere2 = @StrWhere2 + '
	    And M_Date <= ' + LTrim(RTrim(Str(@Date_To)))

	   SET @StrWhere3 = @StrWhere3 + '
	            And E_Date <= ' + LTrim(RTrim(Str(@Date_To)))
    End

	IF @Grp_No <> '' And @Grp_No Is Not Null
	   SET @StrWhere = @StrWhere + '
	     And G.NewGrp_No IN(' + @Grp_No + ')'

	-- ====================================================================================================
	-- ==================================================================================================== SELECT
	-- ====================================================================================================
	SET @StrSelect2 = N'
	IF object_id (''Kara.dbo.TmpTable_1'') Is Not Null DROP TABLE Kara.dbo.TmpTable_1

	-- ====================================================================================================
	-- ==================================================================================================== CREATE Date List
	-- ====================================================================================================
	IF object_id (''Kara.dbo.Tbl_Days'') Is Not Null DROP TABLE Kara.dbo.Tbl_Days
	
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
	SELECT Emp_No, Emp_Name, Date, Time, NewGrp_No, Section_Name, Parent_Sec, Position_Name, End_Date, RowNo
	INTO Kara.dbo.TmpTable_1
	FROM
	(
	  Select DF.Emp_No, E.Name + '' '' + E.Family Emp_Name, DF.Date, DF.Time, 0 NewGrp_No, S.Title Section_Name, '''' Parent_Sec, 
	         P.Title Position_Name, E.End_Date, ROW_NUMBER() OVER(PARTITION BY DF.Emp_No, DF.Date ORDER BY DF.Emp_No, DF.Date ASC) RowNo
	  From      Kara.dbo.DataFile DF
	  Left Join Kara.dbo.EmpGrps   G ON DF.Emp_No = G.Emp_No
	  Left Join Kara.dbo.Employee  E ON E.Emp_No  = DF.Emp_No And E.Sys_Active = 1 And E.IsCut = 0
	  Left Join Kara.dbo.Sections  S ON S.Sec_No  = E.Sec_No
	  Left Join Kara.dbo.Position  P ON P.Pos_No  = E.Pos_No
	  Where ' + @StrWhere + '
		And G.Date       <= DF.Date
		And G.Date       >= (
                             Select Top 1 Date 
                             From Kara.dbo.EmpGrps 
                             Where Emp_No = DF.Emp_No And Date <= DF.Date
                             Order By Date Desc
                            )
	) A
	WHERE 1 = 1
	ORDER BY Date, Time

	--SELECT * FROM Kara.dbo.TmpTable_1'

	SET @StrSelect4 = N'
	-- ==========================================================================================================
	-- ========================================================================================================== SELECT
	-- ==========================================================================================================
	SELECT Emp_No [کد پرسنل], Emp_Name [نام پرسنل], Grp_Code [کد گروه], IsNull(G.Title, '''') [نام گروه], Sec_Name [بخش], Date [تاریخ],
		   Enter_1 [ورود 1], Exit_1 [خروج 1], Enter_2 [ورود 2], Exit_2 [خروج 2], Enter_3 [ورود 3], Exit_3 [خروج 3],
		   Case When Enter_1 = '''' And Enter_2 = '''' And Enter_3 = '''' And Exit_1 = '''' And Exit_2 = '''' And Exit_3 = '''' And Absence_Reason = '''' Then ''غیبت''
				Else Absence_Reason End [دليل غيبت], End_Date [تاريخ ترک کار], Week_Date [روز هفته]
	FROM
	(
		SELECT 
		   D.Date M_Date,
		   IsNull(D.Emp_No, '''') Emp_No, IsNull(E.Name, '''') + '' '' + IsNull(E.Family, '''') Emp_Name,
		   IsNull((Select NewGrp_No 
				   From Kara.dbo.EmpGrps
				   Where 1 = 1 
				   And Emp_No = D.Emp_No
				   And Date  <= D.Date 
				   And Date  >= (Select Top 1 Date From Kara.dbo.EmpGrps Where Emp_No = D.Emp_No And Date <= D.Date Order By Date Desc)
				  ), E.Grp_No) Grp_Code,	   
	   
		   Kara.dbo.Fun_Get_Section_Parent(E.Sec_No) Sec_Name,

		   IsNull(SubString(LTrim(RTrim(Str(D.Date))), 1, 4) + ''/'' + SubString(LTrim(RTrim(Str(D.Date))), 5, 2) + ''/'' + SubString(LTrim(RTrim(Str(D.Date))), 7, 2), '''') Date,

		   IsNull(SubString(Right(''0000'' + Convert(Varchar(4), T1.Time), 4), 1, 2) + '':'' + SubString(Right(''0000'' +  Convert(Varchar(4), T1.Time), 4), 3, 2), '''') Enter_1,
		   IsNull(SubString(Right(''0000'' + Convert(Varchar(4), T2.Time), 4), 1, 2) + '':'' + SubString(Right(''0000'' +  Convert(Varchar(4), T2.Time), 4), 3, 2), '''') Exit_1,

		   IsNull(SubString(Right(''0000'' + Convert(Varchar(4), T3.Time), 4), 1, 2) + '':'' + SubString(Right(''0000'' +  Convert(Varchar(4), T3.Time), 4), 3, 2), '''') Enter_2,
		   IsNull(SubString(Right(''0000'' + Convert(Varchar(4), T4.Time), 4), 1, 2) + '':'' + SubString(Right(''0000'' +  Convert(Varchar(4), T4.Time), 4), 3, 2), '''') Exit_2,

		   IsNull(SubString(Right(''0000'' + Convert(Varchar(4), T5.Time), 4), 1, 2) + '':'' + SubString(Right(''0000'' +  Convert(Varchar(4), T5.Time), 4), 3, 2), '''') Enter_3,
		   IsNull(SubString(Right(''0000'' + Convert(Varchar(4), T6.Time), 4), 1, 2) + '':'' + SubString(Right(''0000'' +  Convert(Varchar(4), T6.Time), 4), 3, 2), '''') Exit_3,
	   
           dbo.Fun_Get_Personnel_Absence_Type(D.Emp_No, ' + LTrim(RTrim(Str(@Date_Fr))) + ', ' + LTrim(RTrim(Str(@Date_To))) + ', D.Date) Absence_Reason,

		   IsNull(SubString(LTrim(RTrim(Str(T1.End_Date))), 1, 4) + ''/'' + SubString(LTrim(RTrim(Str(T1.End_Date))), 5, 2) + 
											 ''/'' + SubString(LTrim(RTrim(Str(T1.End_Date))), 7, 2), '''') End_Date,

		   Case When DATEPART(DW, pub.funChangeDate_PersianToGergorian(SubString(LTrim(RTrim(Str(D.Date))), 1, 4) + ''/'' + 
						SubString(LTrim(RTrim(Str(D.Date))), 5, 2) + ''/'' + SubString(LTrim(RTrim(Str(D.Date))), 7, 2))) + 1 = 7 Then ''جمعه'' Else '''' End Week_Date'
	SET @StrSelect5 = N'
		FROM Kara.dbo.Tbl_Days D
		Left  Join (Select * From Kara.dbo.TmpTable_1 Where RowNo = 1) T1 ON D.Date = T1.Date And D.Emp_No = T1.Emp_No
		Left  Join (Select * From Kara.dbo.TmpTable_1 Where RowNo = 2) T2 ON T1.Emp_No = T2.Emp_No And T1.Date = T2.Date --And T1.NewGrp_No = T2.NewGrp_No
		Left  Join (Select * From Kara.dbo.TmpTable_1 Where RowNo = 3) T3 ON T1.Emp_No = T3.Emp_No And T1.Date = T3.Date --And T1.NewGrp_No = T3.NewGrp_No
		Left  Join (Select * From Kara.dbo.TmpTable_1 Where RowNo = 4) T4 ON T1.Emp_No = T4.Emp_No And T1.Date = T4.Date --And T1.NewGrp_No = T4.NewGrp_No
		Left  Join (Select * From Kara.dbo.TmpTable_1 Where RowNo = 5) T5 ON T1.Emp_No = T5.Emp_No And T1.Date = T5.Date --And T1.NewGrp_No = T5.NewGrp_No
		Left  Join (Select * From Kara.dbo.TmpTable_1 Where RowNo = 6) T6 ON T1.Emp_No = T6.Emp_No And T1.Date = T6.Date --And T1.NewGrp_No = T6.NewGrp_No
		Inner Join Kara.dbo.Employee E ON E.Emp_No = D.Emp_No And E.Sys_Active = 1 And E.IsCut = 0
	) A
	Left  Join Kara.dbo.Groups   G ON G.Grp_No = Grp_Code
	WHERE ' + @StrWhere2 + '
	ORDER BY A.Emp_No, A.Date
	'

	-- ========================================================================================================
	-- ======================================================================================================== END
	-- ========================================================================================================	

	-- ==================================== EXEC
	PRINT @StrSelect2;
	PRINT @StrSelect3;
	PRINT @StrSelect4;
	PRINT @StrSelect5;
	SET   @StrSelect = @StrSelect2 + @StrSelect3 + @StrSelect4 + @StrSelect5;
	EXEC  sp_executesql @StrSelect;	

END

GO
