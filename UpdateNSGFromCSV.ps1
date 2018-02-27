# Create an inbound network security group rule for port 3389

Param(
    [string]$nsgName = "FrontEnd-NSG1",
    [string]$resourceGroup = "bupa-lb-webapp02-RG",
    [string]$location = "northeurope",
    [string]$tagName = "bupa-nsg",
    [string]$tagValue = "Bupa-FrontEnd-NSG" ,
    [string]$defaultCsv = ".\AFTER\FrontEnd-NSG.csv",
    [string]$customCsv = ".\AFTER\FrontEnd-NSG.csv"
)
 
#Login-AzureRMAccount

#Connect-AzureRmAccount
 
cls
cd C:\bupa\ARMRepo\
ls

#mkdir C:\bupa\ARMRepo\Before
#mkdir C:\bupa\ARMRepo\After

CLS

$before =  "C:\bupa\ARMRepo\Before\FrontEnd-NSG.csv"
$After =  "C:\bupa\ARMRepo\After\FrontEnd-NSG.csv"
 
 Compare-Object -ReferenceObject $before -DifferenceObject  $After
if (diff $before $After) {
   write-host 'not equal, updating NSG'
   #Update NSG
#rules array
$rulesArray = @()
 
#add custom rules
Write-Verbose 'Importing custom CSV'
$customRules = Import-Csv $customCsv
 
foreach ($customRule in $customRules) {
    $customNsgRule = New-AzureRmNetworkSecurityRuleConfig `
        -Name $customRule.Name `
        -Protocol $customRule.protocol `
        -Description $customRule.Description `
        -SourcePortRange $customRule.SourcePortRange `
        -DestinationPortRange $customRule.DestinationPortRange `
        -SourceAddressPrefix $customRule.SourceAddressPrefix `
        -DestinationAddressPrefix $customRule.DestinationAddressPrefix `
        -Priority $customRule.priority `
        -Direction $customRule.direction
 
    $rulesArray += $customNsgRule
}



# Create a network security group
$NSG = New-AzureRmNetworkSecurityGroup `
-ResourceGroupName $resourceGroup `
-Location $Location `
-Name CustomNSG `
-SecurityRules $customNsgRule

}