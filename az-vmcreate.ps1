##  This example provisions a new network and deploys a Windows VM from the Marketplace without creating a public IP address or Network Security Group. This script can be used for automatic provisioning
##  because it uses the local virtual machine admin credentials inline instead of calling Get-Credential which requires user interaction.

## 1. First create the resource group on Azure
## 2. Update password string


    $VMLocalAdminUser = "LocalAdminUser"
    $VMLocalAdminSecurePassword = ConvertTo-SecureString <password> -AsPlainText -Force
    $LocationName = "westus"
    $ResourceGroupName = "MyResourceGroup"
    $ComputerName = "MyVM"
    $VMName = "MyVM"
    $VMSize = "Standard_DS3"

    $NetworkName = "MyNet"
    $NICName = "MyNIC"
    $SubnetName = "MySubnet"
    $SubnetAddressPrefix = "10.0.0.0/24"
    $VnetAddressPrefix = "10.0.0.0/16"

    $SingleSubnet = New-AzVirtualNetworkSubnetConfig -Name $SubnetName -AddressPrefix $SubnetAddressPrefix
    $Vnet = New-AzVirtualNetwork -Name $NetworkName -ResourceGroupName $ResourceGroupName -Location $LocationName -AddressPrefix $VnetAddressPrefix -Subnet $SingleSubnet
    $NIC = New-AzNetworkInterface -Name $NICName -ResourceGroupName $ResourceGroupName -Location $LocationName -SubnetId $Vnet.Subnets[0].Id

    $Credential = New-Object System.Management.Automation.PSCredential ($VMLocalAdminUser, $VMLocalAdminSecurePassword);

    $VirtualMachine = New-AzVMConfig -VMName $VMName -VMSize $VMSize
    $VirtualMachine = Set-AzVMOperatingSystem -VM $VirtualMachine -Windows -ComputerName $ComputerName -Credential $Credential -ProvisionVMAgent -EnableAutoUpdate
    $VirtualMachine = Add-AzVMNetworkInterface -VM $VirtualMachine -Id $NIC.Id
    $VirtualMachine = Set-AzVMSourceImage -VM $VirtualMachine -PublisherName 'MicrosoftWindowsServer' -Offer 'WindowsServer' -Skus '2012-R2-Datacenter' -Version latest

    New-AzVM -ResourceGroupName $ResourceGroupName -Location $LocationName -VM $VirtualMachine -Verbose