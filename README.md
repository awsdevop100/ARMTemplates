# ARMTemplates

Authored by : Gary Gordon

This repo allows you an easier way to create your Azure ARM Network Network using Azure ARM Templates and also allows you to maintain your Network Security Groups using a CSV file


Go to the After\FrontEnd-NSG.csv file to udate the FrontEnd-NSG network security group
Update the file After\FrontEnd-NSG.csv with the new network security group rules. 
As soon as the file is updated, Visual Studio Team Services Online will trigger a CI/CD pipeline and will call the PowerShell script UpdateNSGFromCSV.ps1 
The script UpdateNSGFromCSV.ps1 will update the Network security group rules for the NSG FrontEnd-NSG
When the Script updates the rules in the Azure Network Security Group it processes them based on the priority value defined in the CSV.
If there is a clash in priority numbers between a new/updated rule and a rule that already exists in the Azure Network Security Group rule, the rule that already exist will be overwritten. 
This makes creating and maintaining Network Security Group rules easier

