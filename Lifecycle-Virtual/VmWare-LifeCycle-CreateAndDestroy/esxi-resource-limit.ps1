param(
[string]$vcenter,
[string]$vmName,
[string]$un,
[string]$pw
)

Get-Module -ListAvailable PowerCLI* | Import-Module -Verbose:$false
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-ViServer -Server $vcenter -User $un -Password $pw -Verbose:$false

Get-VM -Name "$vmName" | Get-VMResourceConfiguration |Set-VMResourceConfiguration -CpuLimitMhz 3000
