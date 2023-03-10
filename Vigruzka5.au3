#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.16.1
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <File.au3>


$MainF = "X:\00_BIM\14_Академика Волгина"

$FolderNW="T:\07-volgina\ingrad\11_Navis\xchange_actual"

$FileNWC="C:\ForPlanirovshik\Vigruzka5.txt"

Local $Folders[0]

_ArrayAdd($Folders, "06_EOM")
_ArrayAdd($Folders, "04_VENT")
_ArrayAdd($Folders, "07_SS")
_ArrayAdd($Folders, "05_PT")
_ArrayAdd($Folders, "04_KV")
_ArrayAdd($Folders, "04_OT")
_ArrayAdd($Folders, "05_VK")


$ext="*.rvt"
$ext1="*.nwc"
$ext11="nwc"
$ext2="*.nwd"

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



Func printTofile($FileNWC, $FileList3)
	$hFile = FileOpen($FileNWC, 2)
	For $l = 0 to UBound( $FileList3 ) - 1
		FileWriteLine($hFile, $FileList3[$l] & @CRLF)
	Next
	FileClose($hFile)
EndFunc

;можно проверить какие файлы будут для выгрузки
printTofile($FileNWC, $FileList3)

$tempPID=	Run( '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $FileNWC & '" /od "'& $FolderNW & '" /version 2019 ')
;MsgBox ( 4096, "title", $tempPID)
;Sleep(20000)
ProcessWaitClose($tempPID)

Func doBat($FileNWC, $FileList3 , $FolderNW)
	$hFile = FileOpen(StringTrimRight ($FileNWC, 3) & "bat", 2)
	FileWriteLine($hFile, "chcp 65001" & @CRLF)
	FileWriteLine($hFile, "SetLocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION" & @CRLF)
	FileWriteLine($hFile, '"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "'& $FileNWC & '" /od "'& $FolderNW & '" /version 2019 '& @CRLF)
	FileClose($hFile)
EndFunc

;doBat($FileNWC, $FileList3, $FolderNW)

;$RunWait=	Run( StringTrimRight ($FileNWC, 3) & "bat")
;Sleep(20000)
;ProcessClose($tempPID)