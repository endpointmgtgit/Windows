#Creates a new VM for Windows11VM in Hyper-V. $image/$path_to_disk need to be updated.

$datetimevar = $(get-date -Format "ddMMMyy-HHmm")
$vm = "Windows11VM"+"-"+$datetimevar # name of VM, this just applies in Windows, it isn't applied to the OS guest itself.

$image = "D:\MS Software\Win11_22H2_EnglishInternational_x64v2.iso"
$path_to_disk = "d:\VMS\"+$vm # Where you want the VM's virtual disk to reside
$path_to_disk2 = $path_to_disk+"\"

#Create path using VM name to keep all files in one folder for easier maintainance and cleanup
New-Item -ItemType Directory -Path $path_to_disk

#setup vm------------------------------------------------------------------
New-VM -name $vm -Generation 2 -MemoryStartupBytes 8100MB -SwitchName "External"
Set-VMProcessor -vmname $vm -count 10
Set-VMMemory -vmname $vm -DynamicMemoryEnabled $false
New-VHD -Path $path_to_disk2$vm-disk1.vhdx -SizeBytes 50GB
Add-VMHardDiskDrive -VMName $vm -Path $path_to_disk2$vm-disk1.vhdx
Set-VMDvdDrive -VMName $vm -Path $image

#Turn on TPM---------------------------------------------------------------
$owner = Get-HgsGuardian UntrustedGuardian
$kp = New-HgsKeyProtector -Owner $owner -AllowUntrustedRoot
Set-VMKeyProtector -VMName $vm -KeyProtector $kp.RawData
Enable-VMTPM -VMName $vm

#add DVD drive-------------------------------------------------------------
Add-VMDvdDrive -VMName $vm
Set-VMDvdDrive -VMName $vm -Path $image

#--------------------------------------------------------------------------
#Boot Order - Change the boot order to DVD Drive, HHD and then PXE.
$VMBOOT = Get-VMFirmware $vm
#$VMBOOT.bootorder #Display boot order
$pxe = $VMBOOT.BootOrder[0]
$hhd = $VMBOOT.BootOrder[1]
$dvddrive = $VMBOOT.BootOrder[2]
#Set boot order
Set-VMFirmware -VMName $vm -BootOrder $dvddrive,$hhd,$pxe

#--------------------------------------------------------------------------
#Start vm
#Start-VM $vm