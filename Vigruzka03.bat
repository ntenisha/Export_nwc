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





set /a LsIp=%LsI-1
echo %LsIp%
Set MainF2=%MainF:~1,-1%
Set ext=*.rvt
Set ext1=*.nwc
Set ext2=*.nwd

rem удалются nwc и nwd модели
for /L %%i in (0,1,LsI) do (
    del /f /q "%MainF2%\!Folders[%%i]!\%ext1%"	"%MainF2%\!Folders[%%i]!\%ext2%"
)

rem созадется пустой текстовый файл в каждой папке
for /L %%i in (0,1,LsI) do (
    cd.>%MainF%\!Folders[%%i]!\!Folders[%%i]!.txt
)

rem в текстовый файл прописываются все rvt модели в папке (без подпапок)
for /L %%i in (0,1,LsI) do (
    For /F "Delims=" %%A in ('dir /b %MainF%\!Folders[%%i]!\%ext%') do echo %MainF2%\!Folders[%%i]!\%%A>>%MainF%\!Folders[%%i]!\!Folders[%%i]!.txt
)

rem запускается навис
for /L %%i in (0,1,%LsIp%) do (
    start "" "C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "%MainF2%\!Folders[%%i]!\!Folders[%%i]!.txt" 	/od 	"%MainF2%\!Folders[%%i]!"	/version 2019
)
"C:\Program Files\Autodesk\Navisworks Manage 2019\FiletoolsTaskRunner.exe" /i "%MainF2%\!Folders[%LsI%]!\!Folders[%LsI%]!.txt" 	/od 	"%MainF2%\!Folders[%LsI%]!"	/version 2019


rem чистим за собой. удалются txt файлы
rem ТАК КАК НАВИС ЗАПУСКАЕТСЯ ПАРАЛЕЛЬНО,ТО УДАЛЕНИЕ ФАЙЛОВ ПРОИСХОДИТ БЫСТРЕЕ ЧЕМ ЗАПУСТИТСЯ НАВИС
rem ЛИБО ЗАПУСКАТЬ В ОТДЕЛЬНОМ ФАЙЛЕ, ЛИБО НАЙТИ КОМАНДУ КОТОРАЯ ДОЖДЕТСЯ ЗАВЕРШЕНИЯ НАВИСА,ЛИБО ПОСЛЕДНИЙ ПРОЦЕСС ЗАПУСКАТЬ ПОСЛЕДОВАТЕЛЬНО
rem for /L %%i in (0,1,LsI) do (
rem     del /f /q "%MainF2%\!Folders[%%i]!\!Folders[%%i]!.txt"
rem )

endlocal
rem pause можно удалить
pause
