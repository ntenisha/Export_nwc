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
$FileNWC="C:\ForPlanirovshik\Vigruzka6.txt"

Local $Folders[0]
; подпаки где хранятся модели, поиск в поддиректориях этих папок не производится
_ArrayAdd($Folders, "06_EOM")
_ArrayAdd($Folders, "04_VENT")
_ArrayAdd($Folders, "07_SS")
_ArrayAdd($Folders, "05_PT")
_ArrayAdd($Folders, "04_KV")
_ArrayAdd($Folders, "04_OT")
_ArrayAdd($Folders, "05_VK")

Local $ExcludeArr[0]
; файлы для исключения
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

$fileCount = multiThreadPrint($FileNWC, $FileList3)
multiExport($FileNWC, $FolderNW , $fileCount)
purgeFiles($FileNWC)
proverkaNwc($FileNWC, $FileList3)







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


Func printTofile($FileNWC, $FileList3)
	$hFile = FileOpen($FileNWC, 2)
	For $l = 0 to UBound( $FileList3 ) - 1
		FileWriteLine($hFile, $FileList3[$l] & @CRLF)
	Next
	FileClose($hFile)
EndFunc


Func printTofile2($FileNWC,  $FileList3 , $beginArrInd , $endtArrInd )
	$hFile = FileOpen($FileNWC, 2)
	For $l = $beginArrInd to $endtArrInd Step 1
		FileWriteLine($hFile, $FileList3[$l] & @CRLF)
	Next
	FileClose($hFile)
EndFunc

Func multiThreadPrint($FileNWC, $FileList3)
	$count = 0
	if UBound( $FileList3 ) >= 3	Then
		printTofile2(StringTrimRight ($FileNWC, 4) & "_1" & ".txt",  $FileList3 , 0 ,													 	Int(UBound($FileList3)/3) )
		printTofile2(StringTrimRight ($FileNWC, 4) & "_2" & ".txt",  $FileList3 , Int(UBound($FileList3)/3) + 1 , 							Int(UBound($FileList3)/3) + Int(UBound($FileList3)/3) )
		printTofile2(StringTrimRight ($FileNWC, 4) & "_3" & ".txt",  $FileList3 , Int(UBound($FileList3)/3)+ Int(UBound($FileList3)/3) + 1  ,UBound($FileList3) - 1 )
		$count = 3
	ElseIf	UBound( $FileList3 ) > 1 Then
		printTofile2(StringTrimRight ($FileNWC, 4) & "_1" & ".txt",  $FileList3 , 0 , 1 )
		printTofile2(StringTrimRight ($FileNWC, 4) & "_2" & ".txt",  $FileList3 , 1 , 2 )
		$count = 2
	Else
		printTofile($FileNWC, $FileList3)
		$count = 1
	EndIf
		
	return $count
EndFunc




Func simpleExport($FileNWC, $FolderNW)
	$tempPID=	Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $FileNWC & '" /od "'& $FolderNW & '" /version 2019 ')
	Sleep(10000)
	ProcessWaitClose($tempPID)
EndFunc

Func multiExport($FileNWC, $FolderNW , $fileCount)
	if $fileCount == 3 Then
		$tempPID01=	Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& StringTrimRight ($FileNWC, 4) & "_1" & ".txt" & '" /od "'& $FolderNW & '" /version 2019 ')
			Sleep(10000)
		$tempPID02=	Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& StringTrimRight ($FileNWC, 4) & "_2" & ".txt" & '" /od "'& $FolderNW & '" /version 2019 ')
			Sleep(10000)
		$tempPID03=	Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& StringTrimRight ($FileNWC, 4) & "_1" & ".txt" & '" /od "'& $FolderNW & '" /version 2019 ')
			Sleep(10000)
		ProcessWaitClose($tempPID01)
		ProcessWaitClose($tempPID02)
		ProcessWaitClose($tempPID03)
	ElseIf 	$fileCount == 2 Then
		$tempPID01=	Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& StringTrimRight ($FileNWC, 4) & "_1" & ".txt" & '" /od "'& $FolderNW & '" /version 2019 ')
			Sleep(10000)
		$tempPID02=	Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& StringTrimRight ($FileNWC, 4) & "_2" & ".txt" & '" /od "'& $FolderNW & '" /version 2019 ')
			Sleep(10000)
		ProcessWaitClose($tempPID01)
		ProcessWaitClose($tempPID02)
	Else
		simpleExport($FileNWC, $FolderNW)
	EndIf	
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




#cs ----------------------------------------------------------------------------

Func doBat($FileNWC, $FileList3 , $FolderNW)
	$hFile = FileOpen(StringTrimRight ($FileNWC, 3) & "bat", 2)
	FileWriteLine($hFile, "chcp 65001" & @CRLF)
	FileWriteLine($hFile, "SetLocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION" & @CRLF)
	FileWriteLine($hFile, '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $FileNWC & '" /od "'& $FolderNW & '" /version 2019 '& @CRLF)
	FileClose($hFile)
EndFunc

doBat($FileNWC, $FileList3, $FolderNW)

$RunWait=	Run( StringTrimRight ($FileNWC, 3) & "bat")
Sleep(20000)
ProcessClose($tempPID)

#ce ----------------------------------------------------------------------------