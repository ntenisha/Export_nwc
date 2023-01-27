chcp 65001
SetLocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
Set VentFolder=X:\00_BIM\14_Академика Волгина\04_VENT
Set EomFolder=X:\00_BIM\14_Академика Волгина\06_EOM
Set SSFolder=X:\00_BIM\14_Академика Волгина\07_SS
Set PtFolder=X:\00_BIM\14_Академика Волгина\05_PT

Set ext1=*.nwc
Set ext2=*.nwd
del /f /q "%VentFolder%\%ext1%"		"%VentFolder%\%ext2%"
del /f /q "%EomFolder%\%ext1%"		"%EomFolder%\%ext2%"
del /f /q "%SSFolder%\%ext1%"		"%SSFolder%\%ext2%"
del /f /q "%PtFolder%\%ext1%"		"%PtFolder%\%ext2%"


start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "C:\Users\713\Desktop\Navis_volgina\Vent.txt" 	/od "%VentFolder%"	/version 2019
start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "C:\Users\713\Desktop\Navis_volgina\Eom.txt" 	/od "%EomFolder%"	/version 2019
start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "C:\Users\713\Desktop\Navis_volgina\SS.txt" 		/od "%SSFolder%"	/version 2019
start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "C:\Users\713\Desktop\Navis_volgina\Pt.txt" 		/od "%PtFolder%"	/version 2019

endlocal
pause
