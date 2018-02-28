# Create inbound network security group rules from Frontend-NSG.csv

Param(
    [string]$nsgName = "FrontEnd-NSG1",
    [string]$resourceGroup = "bupa-lb-webapp02-RG",
    [string]$location = "northeurope",
    [string]$tagName = "bupa-nsg",
    [string]$tagValue = "Bupa-FrontEnd-NSG" ,
    [string]$customCsv = ".\AFTER\FrontEnd-NSG.csv"
)
 
#Login-AzureRMAccount

#Connect-AzureRmAccount
 
cls
#cd C:\bupa\ARMRepo\
ls

#mkdir C:\bupa\ARMRepo\Before
#mkdir C:\bupa\ARMRepo\After



$before = ".\BEFORE\FrontEnd-NSG.csv"
$After =  ".\AFTER\FrontEnd-NSG.csv"
 
 Compare-Object -ReferenceObject $before -DifferenceObject  $After
if (diff $before $After) {
    write-host -ForegroundColor Green 'The NSG csv files are not equal, There are New Updates'
    write-host -ForegroundColor Green 'Updating NSG' $nsgName

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
        -Direction $customRule.direction `
        -Access $customRule.access 
 
    $rulesArray += $customNsgRule
}



# Create a network security group
$NSG = New-AzureRmNetworkSecurityGroup -force `
-ResourceGroupName $resourceGroup `
-Location $Location `
-Name $nsgName  `
-SecurityRules $customNsgRule

}


