# see http://msdn.microsoft.com/en-us/library/dd153782.aspx
# see http://blogs.msdn.com/b/suzcook/archive/2003/09/19/loadfile-vs-loadfrom.aspx

# method 1:
[Reflection.Assembly]::LoadWithPartialName(“Oracle.DataAccess”)

# adjust the filename accordingly
$filename = "C:\Oracle\product\11.2.0\client_1\odp.net\bin\2.x\Oracle.DataAccess.dll"

# OR method 2:
[void][Reflection.Assembly]::LoadFile($filename)

# or method 3
[void][Reflection.Assembly]::LoadFrom($filename)