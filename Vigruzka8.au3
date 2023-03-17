#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         Motor4ikk

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <File.au3>

; главная папка где находся подпапки АР,КР и прочее
$MainF = "X:\00_BIM\14_Академика Волгина"

; путь для выгрузки nwd файлов
$FolderNW="T:\07-volgina\ingrad\11_Navis\xchange_actual"

; путь для лог файла (также там будут временные файлы)
$LogFile="C:\ForPlanirovshik"

Local $Folders[0]
; подпаки где хранятся модели, поиск в поддиректориях этих папок не производится
_ArrayAdd($Folders, "06_EOM")
_ArrayAdd($Folders, "04_VENT")
_ArrayAdd($Folders, "07_SS")
_ArrayAdd($Folders, "05_PT")
_ArrayAdd($Folders, "04_KV")
_ArrayAdd($Folders, "04_OT")
_ArrayAdd($Folders, "05_VK")

; файлы для исключения
Local $ExcludeArr[0]
;_ArrayAdd($ExcludeArr, "X:\00_BIM\14_Академика Волгина\04_OT\AV_04_OT_PPFK_RD_R19_UND.rvt")
;_ArrayAdd($ExcludeArr, "X:\00_BIM\14_Академика Волгина\05_VK\AV_05_VK_PPFK_RD_R19_UND.rvt")


;защита от дурака, проверка пути
Func checkPath(ByRef $sPath)
	if StringRight ( $sPath, 1 ) = "\" Then
		$sPath = StringTrimRight ( $sPath, 1)
	EndIf
EndFunc

;защита от дурака, проверка пути в массиве
Func checkPathArr(ByRef $aPath)
	For $i = 1 To UBound($aPath) - 1 Step 1
		if StringRight ( $aPath[$i], 1 ) = "\" Then
			$aPath[$i] = StringTrimRight ( $aPath[$i], 1)
		EndIf
		if StringLeft ( $aPath[$i], 1 ) = "\" Then
			$aPath[$i] = StringTrimLeft ( $aPath[$i], 1)
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

;запись массива во временные файлы и отправка на экпорт в 3 процесса
Func multiProcessPrint($LogFile, $FileList3)

	Dim $aRet[3] ; массив с PID-ами процессов

	For $i=0 To UBound($FileList3)-1
		Do
			Sleep(999)
			For $j=0 To 2
				$aRet[$j]=ProcessExists($aRet[$j])
			Next
		Until 0=$aRet[0]Or 0=$aRet[1]Or 0=$aRet[2]
		If 0=$aRet[0]Then
			$tempFile00 = $LogFile & "\temp_1.txt"
			printTofile3($tempFile00,  $FileList3[$i])
			Sleep(999)
			$aRet[0]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile00 & '" /od "'& $FolderNW & '" /version 2019 ')
		ElseIf 0=$aRet[1]Then
			$tempFile01 = $LogFile & "\temp_2.txt"
			printTofile3($tempFile01,  $FileList3[$i])
			Sleep(999)
			$aRet[1]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile01 & '" /od "'& $FolderNW & '" /version 2019 ')
		ElseIf 0=$aRet[2]Then
			$tempFile02 = $LogFile & "\temp_3.txt"
			printTofile3($tempFile02,  $FileList3[$i])
			Sleep(999)
			$aRet[2]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile02 & '" /od "'& $FolderNW & '" /version 2019 ')
		EndIf
	Next

EndFunc

;запись строки в файл
Func printTofile3($printFile,  $FileListInd)
	$hFile = FileOpen($printFile, 2)
		FileWriteLine($hFile, $FileListInd & @CRLF)
	FileClose($hFile)
EndFunc

;проверка после выгрузки даты nwc и rvt и запись в Log
Func proverkaNwc($LogFile2, $FileList3, $nwcExt)
	$hFile = FileOpen($LogFile2, 2)
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

;удаление временных файлов
Func purgeFiles($LogFile)
	For	$i= 0 To 3 Step 1
		FileDelete ( $LogFile & "\temp_" & $i & ".txt")
	Next
EndFunc


Func ExportNwc($MainF , $FolderNW , $LogFile, $Folders , $ExcludeArr)

	checkPath($MainF)
	checkPath($FolderNW)
	checkPath($LogFile)
	checkPathArr($Folders)
	Dim	$rvtExt="*.rvt"
	Dim	$nwcExt="nwc"
	Dim	$LogFile2= $LogFile & "\" & StringTrimRight (@ScriptName, 4) & "_log.txt"

	
	Dim $FileList2[0]
;ищет в папках файлы rvt и записывает в массив
	For $i = 0 To (UBound($Folders) - 1) Step 1
		$FileList=_FileListToArray($MainF & '\'& $Folders[$i] , $rvtExt , 0)
		For $j = 1 To (UBound($FileList) - 1) Step 1
			_ArrayAdd($FileList2, $MainF & '\'& $Folders[$i] & '\'&  $FileList[$j])
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

;	multiProcessPrint($LogFile, $FileList3)

	purgeFiles($LogFile)
	
	proverkaNwc($LogFile2, $FileList3, $nwcExt)

EndFunc

ExportNwc($MainF , $FolderNW , $LogFile, $Folders , $ExcludeArr)
