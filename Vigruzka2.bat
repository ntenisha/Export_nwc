chcp 65001
SetLocal ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION
rem MainF это место проекта , кавычки обязательно
Set MainF="X:\00_BIM\14_Академика Волгина\04_VENT\1111"
rem Folders папки в которых нужно сделать навис модели
set Folders[0]=04_VENT
set Folders[1]=06_EOM
set Folders[2]=07_SS
set Folders[3]=05_PT
rem LsI это номер последнего индекса строкой выше
set LsI=3


Set MainF2=%MainF:~1,-1%
Set ext=*.rvt
Set ext1=*.nwc
Set ext2=*.nwd

rem удалются nwc и nwd модели
del /f /q "%MainF2%\!Folders[0]!\%ext1%"	"%MainF2%\!Folders[0]!\%ext2%"
del /f /q "%MainF2%\!Folders[1]!\%ext1%"	"%MainF2%\!Folders[1]!\%ext2%"
del /f /q "%MainF2%\!Folders[2]!\%ext1%"	"%MainF2%\!Folders[2]!\%ext2%"
del /f /q "%MainF2%\!Folders[3]!\%ext1%"	"%MainF2%\!Folders[3]!\%ext2%"


rem созадется пустой текстовый файл в каждой папке
cd.>%MainF%\!Folders[0]!\!Folders[0]!.txt
cd.>%MainF%\!Folders[1]!\!Folders[1]!.txt
cd.>%MainF%\!Folders[2]!\!Folders[2]!.txt
cd.>%MainF%\!Folders[3]!\!Folders[3]!.txt


rem в текстовый файл прописываются все rvt модели в папке (без подпапок)
For /F "Delims=" %%A in ('dir /b %MainF%\!Folders[0]!\%ext%') do echo %MainF2%\!Folders[0]!\%%A>>%MainF%\!Folders[0]!\!Folders[0]!.txt
For /F "Delims=" %%A in ('dir /b %MainF%\!Folders[1]!\%ext%') do echo %MainF2%\!Folders[1]!\%%A>>%MainF%\!Folders[1]!\!Folders[1]!.txt
For /F "Delims=" %%A in ('dir /b %MainF%\!Folders[2]!\%ext%') do echo %MainF2%\!Folders[2]!\%%A>>%MainF%\!Folders[2]!\!Folders[2]!.txt
For /F "Delims=" %%A in ('dir /b %MainF%\!Folders[3]!\%ext%') do echo %MainF2%\!Folders[3]!\%%A>>%MainF%\!Folders[3]!\!Folders[3]!.txt


rem запускается навис
start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "%MainF2%\!Folders[0]!\!Folders[0]!.txt" 	/od 	"%MainF2%\!Folders[0]!"	/version 2019
start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "%MainF2%\!Folders[1]!\!Folders[1]!.txt" 	/od 	"%MainF2%\!Folders[1]!"	/version 2019
start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "%MainF2%\!Folders[2]!\!Folders[2]!.txt" 	/od 	"%MainF2%\!Folders[2]!"	/version 2019
start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "%MainF2%\!Folders[3]!\!Folders[3]!.txt" 	/od 	"%MainF2%\!Folders[3]!"	/version 2019

rem чистим за собой. удалются txt файлы.
rem ТАК КАК НАВИС ЗАПУСКАЕТСЯ ПАРАЛЕЛЬНО,ТО УДАЛЕНИЕ ФАЙЛОВ ПРОИСХОДИТ БЫСТРЕЕ ЧЕМ ЗАПУСТИТСЯ НАВИС
rem ЛИБО ЗАПУСКАТЬ В ОТДЕЛЬНОМ ФАЙЛЕ, ЛИБО НАЙТИ КОМАНДА КОТОРАЯ ДОЖДЕТЬСЯ ЗАВЕРШЕНИЯ НАВИСА,ЛИБО ПОСЛЕДНИЙ ПРОЦЕСС ЗАПУСКАТЬ ПОСЛЕДОВАТЕЛЬНО
rem del /f /q "%MainF2%\!Folders[0]!\!Folders[0]!.txt"
rem del /f /q "%MainF2%\!Folders[1]!\!Folders[1]!.txt"
rem del /f /q "%MainF2%\!Folders[2]!\!Folders[2]!.txt"
rem del /f /q "%MainF2%\!Folders[3]!\!Folders[3]!.txt"

endlocal
rem pause можно удалить
pause
