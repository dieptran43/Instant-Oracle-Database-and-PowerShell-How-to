[void][System.Reflection.Assembly]::Load("Oracle.DataAccess, Version=2.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342")

function Connect-Oracle([string] $connectionString = $(throw "connectionString is required"))
{
    $conn= New-Object Oracle.DataAccess.Client.OracleConnection($connectionString)
    $conn.Open()    
    Write-Output $conn
}

function Get-ConnectionString
{
    $dataSource = "LOCALDEV"
    Write-Output ("Data Source={0};User Id=HR;Password=pass;Connection Timeout=10" -f $dataSource)
}

$conn = Connect-Oracle (Get-ConnectionString)
# TODO: use connection
"Connection state is {0}, Server Version is {1}" -f $conn.State, $conn.ServerVersion
$conn.Close()
"Connection state is {0}" -f $conn.State