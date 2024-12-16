param(
[string]$vcenter,
[string]$vm,
[string]$un,
[string]$pw
)

Get-Module -ListAvailable PowerCLI* | Import-Module -Verbose:$false > /dev/null
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false > /dev/null
Connect-ViServer -Server $vcenter -User "$un" -Password "$pw" -Verbose:$false > /dev/null
Remove-VM -VM $vm -DeleteFromDisk -Confirm:$false -Verbose:$false > /dev/null