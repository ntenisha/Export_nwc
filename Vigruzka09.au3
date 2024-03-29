#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Ntenisha

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <File.au3>
#include <Date.au3>

; папки в которых нужно проверять модели, без разницы есть на конце "\" или нет
Dim $MainF[0]
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\04_KV")
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\04_OT")
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\04_VENT")
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\05_PT")
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\05_VK")
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\06_EOM")
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\07_SS")
_ArrayAdd($MainF, "X:\00_BIM\14_Академика Волгина\09_TM")


; путь для выгрузки nwd файлов, варианты:
;$FolderNW="T:\07-volgina\ingrad\11_Navis\xchange_actual"
;$FolderNW="T:\07-volgina\ingrad\11_Navis\xchange_actual\"
;$FolderNW="" - в этом случае будет выгружать в теже папки где находится rvt файл
$FolderNW="T:\07-volgina\ingrad\11_Navis\xchange_actual"

; путь для лог файла , варианты:
;$LogFile="" берется полный путь до исполняемого файла только в конце добавляется "_log.txt"
;$LogFile="C:\ForPlanirovshik" имя будет совпадать с иполняемым фалом только в конце добавляется "_log.txt"
;$LogFile="C:\ForPlanirovshik\" тоже самое
;$LogFile="C:\ForPlanirovshik\log.txt" тут конкретно указывается путь и имя файла
$LogFile="C:\ForPlanirovshik"

; файлы для исключения из выгрузки
Dim $ExcludeArr[0]
;_ArrayAdd($ExcludeArr, "X:\00_BIM\14_Академика Волгина\04_OT\AV_04_OT_PPFK_RD_R19_UND.rvt")
;_ArrayAdd($ExcludeArr, "X:\00_BIM\14_Академика Волгина\05_VK\AV_05_VK_PPFK_RD_R19_UND.rvt")




#cs ----------------------------------------------------------------------------


далее идет код


#ce ----------------------------------------------------------------------------

;проверка пути
Func checkPath(ByRef $sPath, $bFlag)
	$sPath = StringStripWS ( $sPath, 3 )
	if $bFlag == 1 Then
			if StringRight ( $sPath, 1 ) <> "\" Then
				$sPath = $sPath & "\"
			EndIf
		
		Else
			if StringRight ( $sPath, 1 ) = "\" Then
				$sPath = StringTrimRight ( $sPath, 1)
			EndIf
	EndIf
EndFunc


	
;проверка пути в массиве
Func checkPathArr(ByRef $aPath)
	For $i = 0 To UBound($aPath) - 1 Step 1
		$aPath[$i] = StringStripWS ( $aPath[$i], 3 )
		if StringRight ( $aPath[$i], 1 ) <> "\" Then
			$aPath[$i] = $aPath[$i] & "\"
		EndIf
	Next
EndFunc


;сверяет дату изменения файлов
Func Datecompare($nwc, $rvt)
	if (FileExists ( $nwc )) Then
		if (FileGetTime($nwc, 0, 1) < FileGetTime($rvt, 0, 1)) Then
			Return $rvt
		Else
			Return 0
		EndIf
		
	Else
		Return $rvt
	EndIf
EndFunc

;сортирует массив по размеру файла,чтобы те файлы которые больше первыми грузились
Func sortingArrSize(ByRef $FileList3)
	Dim $FileList4[UBound( $FileList3 )][2]
	For $i = 0 to UBound( $FileList3 ) - 1 Step 1
		$FileList4[$i][0] = $FileList3[$i]
		$FileList4[$i][1] = FileGetSize($FileList3[$i])
	Next
	_ArraySort($FileList4 , 1, 0, 0, 1)
	For $i = 0 to UBound( $FileList3 ) - 1 Step 1
		$FileList3[$i] = $FileList4[$i][0]
	Next
EndFunc

;запись строки в файл
Func printTofile($printFile,  $FileListInd)
	$hFile = FileOpen($printFile, 2)
		FileWriteLine($hFile, $FileListInd & @CRLF)
	FileClose($hFile)
EndFunc

;проверяет путь FolderNW если пустой то указывает туже папку для выгрузки где находится файл
Func checkEmptyfolderNW ( byref $FolderNW , $fullPathtoFile )
	if $FolderNW == "" Then
		$FolderNW = StringLeft( $fullPathtoFile , StringInStr($fullPathtoFile, "\" , 0 , -1) - 1)
	EndIF
	
	Return $FolderNW
EndFunc

;запись массива во временные файлы и отправка на экпорт в 3 процесса
Func multiProcessExport($tempFiles, $FileList3 , $FolderNW)

	Dim $aRet[3] ; массив с PID-ами процессов

	For $i=0 To UBound($FileList3)-1
		Do
			Sleep(5000)
			For $j=0 To 2
				$aRet[$j]=ProcessExists($aRet[$j])
			Next
		Until 0=$aRet[0]Or 0=$aRet[1]Or 0=$aRet[2]
		If 0=$aRet[0]Then
			$tempFile00 = $tempFiles & "_temp_1.txt"
			printTofile($tempFile00,  $FileList3[$i])
			Sleep(999)
			$aRet[0]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile00 & '" /od "'& checkEmptyfolderNW ($FolderNW , $FileList3[$i]) & '" /version 2019 ')
			if UBound($FileList3) - 1 - $i <= 3 then
				Sleep(30000)
			EndIf
		ElseIf 0=$aRet[1]Then
			$tempFile01 = $tempFiles & "_temp_2.txt"
			printTofile($tempFile01,  $FileList3[$i])
			Sleep(999)
			$aRet[1]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile01 & '" /od "'& checkEmptyfolderNW ($FolderNW , $FileList3[$i]) & '" /version 2019 ')
			if UBound($FileList3) - 1 - $i <= 3 then
				Sleep(30000)
			EndIf
		ElseIf 0=$aRet[2]Then
			$tempFile02 = $tempFiles & "_temp_3.txt"
			printTofile($tempFile02,  $FileList3[$i])
			Sleep(999)
			$aRet[2]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile02 & '" /od "'& checkEmptyfolderNW ($FolderNW , $FileList3[$i]) & '" /version 2019 ')
			if UBound($FileList3) - 1 - $i <= 3 then
				Sleep(30000)
			EndIf
		EndIf
	Next
	
	Sleep(30000)
	
	Do
		Sleep(5000)
		For $j=0 To 2
		  $aRet[$j]=ProcessExists($aRet[$j])
		Next
	Until 0=$aRet[0]+$aRet[1]+$aRet[2]
EndFunc

;удаление временных файлов
Func purgeFiles($tempFiles)
	For	$i= 0 To 3 Step 1
		FileDelete ( $tempFiles & "_temp_" & $i & ".txt")
	Next
EndFunc

;проверка после выгрузки даты nwc и rvt и запись в Log
Func proverkaNwc($LogFile2, $FileList3, $nwcExt)
	$hFile = FileOpen($LogFile2, 1)
	FileWriteLine($hFile, @CRLF & "-------------------------------------------------------------")
	FileWriteLine($hFile, "Дата выгрузки   " & _NowDate() & "   " &  _NowTime())
	FileWriteLine($hFile, "Были подготовлены к выгрузке следующие файлы" & @CRLF& @CRLF)
	For $k = 0 To (UBound($FileList3) - 1) Step 1
		FileWriteLine($hFile, $FileList3[$k] & @CRLF)
	Next
	FileWriteLine($hFile,  @CRLF &"Либо не выгружены либо были изменены в процессе выгрузки след файлы" & @CRLF& @CRLF)
	For $k = 0 To (UBound($FileList3) - 1) Step 1
		if (Datecompare (StringTrimRight ($FileList3[$k], 3) & $nwcExt  , $FileList3[$k])) Then
			FileWriteLine($hFile, $FileList3[$k] & @CRLF)
		EndIf
	Next
	FileClose($hFile)
EndFunc


Func ExportNwc($MainF , $FolderNW , $LogFile , $ExcludeArr)

	checkPath($FolderNW , 0)
	checkPathArr($MainF)
	Dim	$rvtExt="*.rvt"
	Dim	$nwcExt="nwc"
	Dim	$LogFile2

	if StringLen ( $LogFile) == 0 Then
			$LogFile2 = @ScriptDir & "\" & StringTrimRight (@ScriptName, 4) & "_log.txt"
		ElseIf StringLeft(StringRight ( $LogFile, 4 ) , 1) == "." Then
			$LogFile2 = $LogFile
		Else
			checkPath($LogFile, 1) 
			$LogFile2 = $LogFile & StringTrimRight (@ScriptName, 4) & "_log.txt"
	EndIf
	
	$tempFiles =  @ScriptDir & "\" & StringTrimRight (@ScriptName, 4)

	Dim $FileList2[0]
;ищет в папках файлы rvt и записывает в массив
	For $i = 0 To (UBound($MainF) - 1) Step 1
		$FileList=_FileListToArray($MainF[$i] , $rvtExt , 0)
		For $j = 1 To (UBound($FileList) - 1) Step 1
			_ArrayAdd($FileList2, $MainF[$i] &  $FileList[$j])
		Next
	Next
	;можно проверить список всех rvt  файлов в папках
	;_ArrayDisplay($FileList2,"$FileList222")

;сверяет дату изменения rvt и nwc , если rvt новее то создает добавляет в новый массив
	Dim $FileList3[0]
	For $k = 0 To (UBound($FileList2) - 1) Step 1
		if (Datecompare (StringTrimRight ($FileList2[$k], 3) & $nwcExt  , $FileList2[$k])) Then
			_ArrayAdd($FileList3, $FileList2[$k])
		EndIf
	Next
	;можно проверить список всех rvt  для выгрузки
	;_ArrayDisplay($FileList3,"$FileList333")

;проверяет со списком для исключения, если файлы есть то они удаляются
	if UBound( $ExcludeArr ) > 0 Then
		For $i = 0 to UBound( $ExcludeArr ) - 1 Step 1
			if _ArraySearch($FileList3, $ExcludeArr[$i]) Then
				_ArrayDelete($FileList3, _ArraySearch($FileList3, $ExcludeArr[$i]))
			EndIf
		Next
	EndIf

	sortingArrSize($FileList3)

	multiProcessExport($tempFiles, $FileList3 , $FolderNW)

	purgeFiles($tempFiles)
	
	proverkaNwc($LogFile2, $FileList3, $nwcExt)

EndFunc


ExportNwc($MainF , $FolderNW , $LogFile , $ExcludeArr)
