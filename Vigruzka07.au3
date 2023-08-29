#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <File.au3>

; главная папка где находся подпапки АР,КР и прочее
$MainF = "X:\00_BIM\14_Академика Волгина"

; путь для выгрузки nwd файлов
$FolderNW="T:\07-volgina\ingrad\11_Navis\xchange_actual"

; путь для TXT файла, не важно куда указать его
$FileNWC="C:\ForPlanirovshik\Vigruzka7.txt"

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


$ext="*.rvt"
$ext1="*.nwc"
$ext11="nwc"
$ext2="*.nwd"



Local $FileList2[0]

For $i = 0 To (UBound($Folders) - 1) Step 1
	$FileList=_FileListToArray($MainF & '\'& $Folders[$i] , $ext , 0)
	For $j = 1 To (UBound($FileList) - 1) Step 1
		_ArrayAdd($FileList2, $MainF & '\'& $Folders[$i] & '\'&  $FileList[$j])
	Next
Next
;можно проверить список всех rvt  файлов в папках
;_ArrayDisplay($FileList2,"$FileList222")

Local $FileList3[0]
For $k = 0 To (UBound($FileList2) - 1) Step 1
	if (Datecompare (StringTrimRight ($FileList2[$k], 3) & $ext11  , $FileList2[$k])) Then
		_ArrayAdd($FileList3, $FileList2[$k])
	EndIf
Next
;можно проверить список всех rvt  для выгрузки
;_ArrayDisplay($FileList3,"$FileList333")


if UBound( $ExcludeArr ) > 0 Then
	For $i = 0 to UBound( $ExcludeArr ) - 1 Step 1
		if _ArraySearch($FileList3, $ExcludeArr[$i]) Then
			_ArrayDelete($FileList3, _ArraySearch($FileList3, $ExcludeArr[$i]))
		EndIf
	Next
EndIf

sortingArrSize($FileList3)

multiProcessPrint($FileNWC, $FileList3)

purgeFiles($FileNWC)
proverkaNwc($FileNWC, $FileList3)




Func sortingArrSize(byref $FileList3)
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

Func multiProcessPrint($FileNWC, $FileList3)

Dim $aRet[3] ; массив с PID-ами процессов

	For $i=0 To UBound($FileList3)-1
		Do
			Sleep(99)
			For $j=0 To 2
				$aRet[$j]=ProcessExists($aRet[$j])
			Next
		Until 0=$aRet[0]Or 0=$aRet[1]Or 0=$aRet[2]
		If 0=$aRet[0]Then
			$tempFile00 = StringTrimRight ($FileNWC, 4) & "_1" & ".txt"
			printTofile3($tempFile00,  $FileList3[$i])
			Sleep(99)
			$aRet[0]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile00 & '" /od "'& $FolderNW & '" /version 2019 ')
		ElseIf 0=$aRet[1]Then
			$tempFile01 = StringTrimRight ($FileNWC, 4) & "_2" & ".txt"
			printTofile3($tempFile01,  $FileList3[$i])
			Sleep(99)
			$aRet[1]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile01 & '" /od "'& $FolderNW & '" /version 2019 ')
		ElseIf 0=$aRet[2]Then
			$tempFile02 = StringTrimRight ($FileNWC, 4) & "_3" & ".txt"
			printTofile3($tempFile02,  $FileList3[$i])
			Sleep(99)
			$aRet[2]=Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $tempFile02 & '" /od "'& $FolderNW & '" /version 2019 ')
		EndIf
	Next

EndFunc

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


Func printTofile3($FileNWC,  $FileListInd)
	$hFile = FileOpen($FileNWC, 2)
		FileWriteLine($hFile, $FileListInd & @CRLF)
	FileClose($hFile)
EndFunc


Func proverkaNwc($FileNWC, $FileList3)
	$FileNWC = 	StringTrimRight ($FileNWC, 4) & "_log" & ".txt"
	$hFile = FileOpen($FileNWC, 2)
	FileWriteLine($hFile, "Были подготовлены к выгрузке следующие файлы" & @CRLF& @CRLF)
	For $k = 0 To (UBound($FileList3) - 1) Step 1
		FileWriteLine($hFile, $FileList3[$k] & @CRLF)
	Next
	FileWriteLine($hFile,  @CRLF &"Либо не выгружены либо были изменены в процессе выгрузки след файлы" & @CRLF& @CRLF)
	For $k = 0 To (UBound($FileList3) - 1) Step 1
		if (Datecompare (StringTrimRight ($FileList3[$k], 3) & $ext11  , $FileList3[$k])) Then
			FileWriteLine($hFile, $FileList3[$k] & @CRLF)
		EndIf
	Next
	FileClose($hFile)
EndFunc


Func purgeFiles($FileNWC)
	FileDelete ( $FileNWC )
	FileDelete ( StringTrimRight ($FileNWC, 4) & "_1" & ".txt")
	FileDelete ( StringTrimRight ($FileNWC, 4) & "_2" & ".txt" )
	FileDelete ( StringTrimRight ($FileNWC, 4) & "_3" & ".txt" )
EndFunc
