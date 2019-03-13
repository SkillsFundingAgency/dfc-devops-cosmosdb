[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $CosmosDbAccountName,
    [Parameter(Mandatory = $true)]
    [string] $CosmosDbDatabase,
    [Parameter(Mandatory = $true)]
    [string] $CosmosDbCollection
)

$MinCosmosDBModuleVersion = "2.1.3.528"
$MaxCosmosDBModuleVersion = "2.1.15.239"
$CosmosDBModuleVersion = Get-Module CosmosDB | Where-Object { ([System.Version] $_.Version.ToString() -ge [System.Version] $MinCosmosDBModuleVersion) -and ([System.Version] $_.Version.ToString() -le [System.Version] $MaxCosmosDBModuleVersion) }
if ($CosmosDBModuleVersion) {
    Write-Verbose "Cosmos DB module $($CosmosDBModuleVersion.Version.ToString()) installed"
}
else {
    Write-Verbose "No Cosmos DB module version between $MinCosmosDBModuleVersion and $MaxCosmosDBModuleVersion found"
    if (!(Get-InstalledModule CosmosDB -MinimumVersion $MinCosmosDBModuleVersion -MaximumVersion $MaxCosmosDBModuleVersion -ErrorAction SilentlyContinue)) {
        Write-Verbose "No module meeting this version requirement is installed ... installing locally"
        Install-Module CosmosDB -MinimumVersion $MinCosmosDBModuleVersion -MaximumVersion $MaxCosmosDBModuleVersion -Scope CurrentUser -Force
    }
    Import-Module CosmosDB -MinimumVersion $MinCosmosDBModuleVersion -MaximumVersion $MaxCosmosDBModuleVersion
}

$CosmosDbContext = New-CosmosDbContext -Account $CosmosDbAccountName -ResourceGroup $ResourceGroupName -MasterKeyType 'PrimaryMasterKey'

Write-Verbose "Checking for Database $CosmosDbDatabase"
$ExistingDatabase = Get-CosmosDbDatabase -Context $CosmosDbContext -Id $CosmosDbDatabase -ErrorAction SilentlyContinue

if (!$ExistingDatabase) {
    Write-Output "Missing Database: $CosmosDbDatabase"
    exit
}

Write-Verbose "Checking for $CosmosDbCollection"
$ExistingCollection = Get-CosmosDbCollection -Context $CosmosDbContext -Database $CosmosDbDatabase -Id $CosmosDbCollection -ErrorAction SilentlyContinue

if (!$ExistingCollection) {
    Write-Output "Missing Collection: $CosmosDbCollection"
    exit
}