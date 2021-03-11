


# Open hel section in browser
Get-Help New-AzResourceGroup -online 

Get-Help New-AzResourceGroup -ShowWindow

Get-Help New-AzResourceGroup -Full 

# Create Resource Group 

New-AzResourceGroup -Location eastus2 -Name rg-azurepowershell

<#

Deploy an Azure VM using PowerShell with the below specifications ?

Name: AzureDemoVM
Resource Group : rg-azurepowershell
Location : eastus2
Open Ports: 80,3389
OS: Windows 2019 Data center
Vnet Name : eastus2-vnet
Subnet Name: az-prod-subnet


#>

# Method 1
# Deploying an Azure VMwith additional options

New-AzVm -ResourceGroupName "rg-azurepowershell" -Name "AzureDemoVM" -Location "eastus2" -VirtualNetworkName "eastus2-vnet" -SubnetName "az-prod-subnet" -OpenPorts 80,3389 -Image Win2019Datacenter

# Method 2

New-AzVm `
    -ResourceGroupName "rg-azureposershell" `
    -Name "AzureDemoVM" `
    -Location "eastus2" `
    -VirtualNetworkName "eastus2-vnet" `
    -SubnetName "az-prod-subnet" `
    -OpenPorts 80,3389 `
    -Image Win2019DAtacenter


# Method 3

$vmParams = @{
    ResourceGroupName = "rg-azurepowershell"
    Name = "AzureDemoVM"
    Location = "eastus2"
    VirtualNetworkName = "eastus2-vnet"
    SubnetName = "az-prod-subnet"
    OpenPorts = 80,3389
    Image = 'Win2019Datacenter'
}

$vmParams

New-AzVM @vnParams


# Get List of Resource Groups 

Get-AzResourceGroup

Get-AzResourceGroup | Get-Member

#Filter Resource Groups by name

# Method 1 : Pulling specific data as per condition. More Efficient Method
Get-AzResourceGroup -name '*prod*'

#--OR--


# Method 2 : Pulling complete list and then filter the results. LEss Efficient Method.
Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like '*prod*'}


#===============================================================================#

#Filter by LOCATION

# MEthod 1 : Pulling specific data as per condition. More Efficient Method.
Get-AzResourceGroup -Location 'eastus'


#---OR---

# Method 2 : Pulling complete list and then filter the results. Less Efficient Method.
Get-AzResourceGroup | Where-Object { $_.Location -eq 'eastus'}


#=============================================================================#



# Demo : Multiples pipes
Get-AzResourceGroup | Where-Object { $_.Location -eq 'eastus'} | Where-Object {$_.ResourceGroupName -like '*-rg'}




# Filter and Format Output

# Example 1
Get-AzResourceGroup | Where-Object { $_.Location -eq 'eastus'} | Format-List

# Example 2 
Get-AzResourceGroup | Where-Object { $_.Location -eq 'eastus'} | Format-Table -AutoSize

# Example 3 
Get-AzResourceGroup | Where-Object { $_.Location -eq 'eastus'} |
                    Where-Object { $_.ResourceGroupName -like '*-rg'} |
                    Format-Table -AutoSize -Wrap
                    
                    
# Filter, Select and Format Output
Get-AzResourceGroup | Where-Object { $_.Location -eq 'eastus'} | 
    Select-Object ResourceGroupName, Location, ProvisioningState |
    Format-Table -AutoSize
    
    
# Filter, Select and Format Output
Get-AzResourceGroup | Where-Object { $_.ResourceGroupName -like '*rg*'} |
    Select-Object ResourceGroupName, Location, ProvisioningState |
    Format-List
    


# All commandlets containing 'Az' in name
Get-Command -Name '*Az*' | Measure-Object    
                            

# Access Online help
Get-help get-azvm -Online

# Analyze your PowerShell Object
Get-AzVm | Get-Member

Get-AzVm | select * # Select is an alias of Select-Object so this statement can also be written as : 
Get-AzVm | Select-Object


# We can access the singular properties values (like String integer, boolean etc).
Get-AzVm | select name, LicenseType, Location, VmId, Type, StatusCode, RequestId, ResourceGroupName


# But we CANNOT directly access the values of collection objects or Arrays that are stored as a property.
Get-AzVm | select HardwareProfile, StorageProfile, OSProfile, BillingProfile

#*** So we need to expand such property (array/collection objects) in order to access the values stored in them.
Get-AzVm | select HardwareProfile -ExpandProperty HardwareProfile

Get-AzVm | select OSProfile -ExpandProperty OSProfile

Get-AzVm | select StorageProfile -ExpandProperty StorageProfile

# The StorageProfile again contains objects properties only. So we can expend our desired property from this level again.
Get-AzVm | select StorageProfile -ExpandProperty StorageProfile | Select-Object ImageReference -ExpandProperty ImageReference

#1.) List all the Virtual Machine names in Azure within a given resource group (say demo1_group)
#    whose name starts with "prod" and ends with "webserver"
#    Output should be formatted in a table with only VM Name amd its Resource group as columns


Get-AzVm -Name 'prod*webserver' -ResourceGroupName demo1_group |
                Select Name, ResourceGroupName |
                Format-Table -AutoSize 


# 2.) List Virtual Machines within eastus2 or westus2 location.
    # Output should be in List format using properties: name, location, ResourceGroupName, ProvioningState

Get-AzVm | Where-Object {  ($_.Location -eq 'eastus2') -or ($_.Location -eq 'westus2' ) } |
            Format-List name, location, ResourceGroupName, ProvioningState



# 3.) List all virtual Machine that are in deallocated state. Display only VM name and PowerState
    # tip: To check the powerstate we need to pass - status switch
        Get-AzVm -Status | Select-Object -Property Name, PowerState

# Step A.) All VMs in deallocated state
Get-AzVm -Status | Where-Object {$_.PowerState -eq 'VM deallocated'}

# Step B.) VMs filtered and necessary columns selected in output
Get-AzVm -Status | Where-Object {$_.PowerState -eq 'VM deallocated'} | select name, powerstate


#   OR

Get-AzVm -Status | Where-Object {$_.PowerState -eq 'VM deallocated'} |
    Select-Object -Property Name, @{name='VM Power Status'; Expression = {$_.PowerState}}



# 4.) List Virtual Machines that are in running state and VMs are in eastus2 location.

Get-AzVm -Status | Where-Object {$_.PowerState -eq 'VM running' -and $_.Location -eq 'eastus2'}

# 5.) List Virtual Machines that are NOT in eastus2 region.

Get-AzVm -Status | Where-Object { $_.Location -ne 'eastus2'}

#-----OR

Get-AzVm -Status | Where-Object { -not ($_.Location -eq 'eastus2') }

# 6.) List all Virtual Machines with their OS. Display only VM name and OSType
    #Tip: To get a OS property we need to expand its StorageProfile property

Get-AzVm | select *

Get-AzVm | select StorageProfile -ExpandProperty StorageProfile

Get-AzVm | select StorageProfile -ExpandProperty StorageProfile | select OsDisk -ExpandProperty OsDisk

Get-AzVm | select StorageProfile -ExpandProperty StorageProfile | select OsDisk -ExpandProperty OsDisk | select OsType -ExpandProperty OsType

Get-AzVm | select StorageProfile -ExpandProperty StorageProfile | 
            select OsDisk -ExpandProperty OsDisk |
            select OsType -ExpandProperty OsType |
            select name, OsType
    
Get-AzVM | Select-Object -Property Name, @{ name='My OS Type'; Expression = {$_.StorageProfile.OsDisk.OsType }}

# 7.) List all virtual Machines that has Linux OS
Get-AzVm | Where-Object {$_.StorageProfile.OsDisk.OsType -eq 'Linux'}

    # To list Windows VMs
    # Get-AzVM | Where-Object {$_.StorageProfile.OsDisk.OsType -eq 'windows'}


# 8.) List all VMs with their VM size
Get-AzVm | Select-Object -Property Name, @{name='Size'; Expression = {$_.HarwareProfile.VmSize}}


# 9.) 8. List all Virtual Machines that are in D series of VM size
Get-AzVm | Where-Object {$_.HardwareProfile.VmSize -like '*_D*'}


# 10.) List all virtual Machines that are of D series Vm Size and resource group name contains word 'demo'
        # Output should be a table with only 3 columns : VM Name, VM Size, VM OS
Get-AzVm | Select-Object HardwareProfile -ExpandProperty HardwareProfile | select VmSize


Get-AzVm | Where-Object  {$_.HardwareProfile.VMSize -like '*_D*' -and $_.ResourceGroupName -like 'demo*' } |
            Select-Object -Property Name `
                        , @{name='VMSize' ; Expression = {$_.HardwareProfile.VMSize}}
                        , @{name='OsType' ; Expression = {$_.StoragePRofile.OsDisk.OsType}}



# 11.) List all virtual machine that satisfy below conditions
#  Status: stopped
#  Region : eus2
#  Resource Group : demo_group1
#  OS : Windows (any version)

# In output, display only VM name, ProvisioningState, VMSize and OSType


Get-AzVm -Status | Where-Object {$_.PowerState -like '*deallocated*' `
                        -and $_.Location -like 'eastus2' `
                        -and $_.ResourceGroupName -eq 'demo1_group' `
                        -and $_.StorageProfile.OsDisk.OsType -like '*windows*' `
                        } |
                    Select-Object -Property Name, ProvisioningState `
                            , @{name='VMSize'; Expression = {$_.HardwareProfile.VMSize}} `
                            , @{name='OsType'; Expression = {$_.StorageProfile.OsDisk.OsType}}




                   
#--------------------------Export to ------------------------------#

Get-AzVm | select Name, Type, Location, StatusCode


# VM data export to CSV
Get-AzVm | select Name, Type, Location, StatusCode | Export-Csv -Path 'azure_vms.csv'

Get-AzVm | select Name, Type, Location, StatusCode | Export-Csv -Path 'azure_vms.csv' -NoTypeInformation

# Export all resources by resourcegroup name
Get-AzResource -ResourceGroupName 'demo*' | Export-Csv -Path 'azure_resources_in_demo_rg.csv' -NoTypeInformation

# Export selected Azure resources
Get-AzResource | Where-Object {$_.Location -eq 'eastus2'} |
            Where-Object {$_.ResourceType -ne 'Microsoft.Compute/virtualMachines' } |
            Select ResourceGroupName, Name, ResourceType |
            Export-Csv -Path 'selected_azure_resources.csv' -NoTypeInformation
            


# Grabbing the necessary data and storing it in $data

$data = Get-AzResource | Where-Object {$_.ResourceGroupName -like '*demo*'} |
                        Where-Object {$_.ResourceType -eq 'Microsoft.Compute/virtualMachines'} |
                        Select ResourceGroupName, Name, ResourceType
                        
                        
# Export to JSON Format
$data | ConvertTo-Json | Out-File "json_formatdata.json"  


# Exoport to XML Format
$data | Export-Clixml -Path "xml_format_data.xml"

# Export to HTML Format
$data | ConvertTo-Html -Property * | out-file html_format_data.html

                                 

                   
