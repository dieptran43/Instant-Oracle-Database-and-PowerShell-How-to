param ([Parameter(Mandatory=$true)][validateset(2,4)]
[int] $OdpVersion)
$SCRIPT:conn = $null

function Load {
param (
    [Parameter(Position=0, Mandatory=$true)]
    [validateset(2,4)] [int] $version, 
    [Parameter(Position=1)] [switch] $passThru
)
    $name = ("Oracle.DataAccess, Version={0}.112.3.0, Culture=neutral, PublicKeyToken=89b483f429c47342" -f $version)
    $asm = [System.Reflection.Assembly]::Load($name)
    if ($passThru) { $asm }
}

<#
.SYNOPSIS
Connects to oracle via a connection string.

.DESCRIPTION
Creates a new Oracle Connection and opens it using the specified connections string.
Created connection is stored and not returned unless -PassThru is specified.

.PARAMETER ConnectionString
The full connection string of the connection to be created and opened.

.PARAMETER PassThru
If -PassThru is supplied, the created connection will be returned and not stored.

.EXAMPLE
Connect to oracle with a connection string and store the connection for later use without outputting it.

Connect "Data Source=LOCALDEV;User Id=HR;Password=Pass"

.NOTES
If -PassThru isn't used, the connection will be available for later operations such as Disconnect, without having to pass it.
#>
function Connect {
[CmdletBinding()]
Param( 
[Parameter(Mandatory=$true)] [string]$ConnectionString,
[Parameter(Mandatory=$false)] [switch]$PassThru )
    $conn= New-Object Oracle.DataAccess.Client.OracleConnection($ConnectionString)
    $conn.Open()
    if (!$PassThru) {
        $SCRIPT:conn = $conn 
        Write-Verbose ("Connected with {0}" -f $conn.ConnectionString)
    }
    else {
        $conn
    }
}

function Connect-TNS {
[CmdletBinding()]
Param( 
[Parameter(Mandatory=$true)] [string]$TNS,
[Parameter(Mandatory=$true)] [string]$UserId,
[Parameter(Mandatory=$true)] [string]$Password,
[Parameter(Mandatory=$false)] [switch]$PassThru )
    $connectString = ("Data Source={0};User Id={1};Password={2};" -f $TNS, $UserId, $Password)
    Connect $connectString -PassThru:$PassThru
}

function Get-Connection ($conn) {
    if (!$conn) { $conn = $SCRIPT:conn }
    $conn
}

function Disconnect {
[CmdletBinding()]
Param( 
    [Parameter(Mandatory=$false)]
    [Oracle.DataAccess.Client.OracleConnection]$conn)
    $conn = Get-Connection($conn)
    if (!$conn) {
        Write-Verbose "No connection is available to disconnect from"; return
    }
    if ($conn -and $conn.State -eq [System.Data.ConnectionState]::Closed) {
        Write-Verbose "Connection is already closed"; return
    }
    $conn.Close()
    Write-Verbose ("Closed connection to {0}" -f $conn.ConnectionString)
    $conn.Dispose()
}

function Get-DataTable {
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$false)]
    [Oracle.DataAccess.Client.OracleConnection]$conn, 
    [Parameter(Mandatory=$true)] [string]$sql,
    [Parameter(Mandatory=$false)]
    [Hashtable]$paramValues
)
    $conn = Get-Connection($conn)
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
    Set-CommandParamsFromArray $cmd $paramValues
    $da = New-Object Oracle.DataAccess.Client.OracleDataAdapter($cmd)
    $dt = New-Object System.Data.DataTable
    [void]$da.Fill($dt)    
    ,$dt
}

function Set-CommandParamsFromArray($cmd, $paramValues) {
	if (!$paramValues) { return }
    $cmd.BindByName = $true
    foreach ($p in $paramValues.GetEnumerator()) {
        $op = New-Object Oracle.DataAccess.Client.OracleParameter
        $op.ParameterName = $p.Key; $op.Value = $p.Value
        $cmd.Parameters.Add($op) | Out-Null
    }    
}

function Invoke {
[CmdletBinding(SupportsShouldProcess = $true)] 
Param(
    [Parameter(Mandatory=$false)][Oracle.DataAccess.Client.OracleConnection]$conn, 
    [Parameter(Mandatory=$true)][string]$sql,        
    [Parameter(Mandatory=$false)][Hashtable]$paramValues,
    [Parameter(Mandatory=$false)][switch]$passThru
) 
    $conn = Get-Connection($conn)        
    $cmd = New-Object Oracle.DataAccess.Client.OracleCommand($sql,$conn)
    Set-CommandParamsFromArray $cmd $paramValues
    $trans = $conn.BeginTransaction()
    $result = $cmd.ExecuteNonQuery(); $cmd.Dispose()
    
    if ($psCmdlet.ShouldProcess($conn.DataSource)) {
        $trans.Commit()            
    }
    else {
        $trans.Rollback(); "$result row(s) affected"
    }    
    
    if ($passThru) { $result }        
}

Export-ModuleMember -Function Connect,Connect-TNS,Disconnect,Get-DataTable,Invoke
Load -version $OdpVersion