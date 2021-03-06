# Load the ODP.NET 2.x assembly
$odpAssemblyName = "Oracle.DataAccess, Version=2.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342"
[System.Reflection.Assembly]::Load($odpAssemblyName)

# Uncomment and use the below instead to discard output
# [System.Reflection.Assembly]::Load($odpAssemblyName) | Out-Null

# Or capture the output and reformat
# $odpAsm = [System.Reflection.Assembly]::Load($odpAssemblyName)
# "Loaded Oracle.DataAccess from {0}" -f $odpAsm.Location


# this block is optional and is only for verification and discovery
# verify the assembly actually loaded. You could also get the reference via assigning a variable to the Load call result
$asm = [appdomain]::currentdomain.getassemblies() | where-object {$_.FullName -eq $odpAssemblyName}
# enumerate the public types in the assembly, sort on Full name and Format the table with specified properties
$asm.GetTypes() | Where-Object {$_.IsPublic} | Sort-Object {$_.FullName } | ft FullName, BaseType | Out-String

# with the assembly loaded and types known you can start creating types
$conn = New-Object Oracle.DataAccess.Client.OracleConnection

"Created empty connection object. State is {0}" -f $conn.State