#region Paramsection V 1.0
[CmdletBinding(SupportsShouldProcess)]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Search User: *")]
    [String]$UPN,

    [Parameter(Mandatory = $true, HelpMessage = "Do you want to Add, Update or Delete a Phone Method? *")]
    [ValidateSet("Add", "Update", "Delete")]
    [String]$ActionType,

    [Parameter(Mandatory = $false, HelpMessage = "Please Insert the Phone Number (Example: +49 1234567890): *")]
    [ValidatePattern("^\+[0-9]{1,3}\s[0-9]{1,11}")]
    [String]$PhoneNumber,

    [Parameter(Mandatory = $false, HelpMessage = "Select Phone Type: *")]
    [ValidateSet("mobile", "alternateMobile", "office")]
    [String]$PhoneType
)
#endregion Paramsection

# Function to modify the phone number
function Update-PhoneNumber {
    param (
        [parameter(Mandatory = $true)]
        [string]$ActionType,
        [parameter(Mandatory = $false)]
        [string]$PhoneType,
        [parameter(Mandatory = $false)]
        [string]$PhoneNumber,
        [parameter(Mandatory = $true)]
        [string]$user
    )

    # Retrieve existing authentication methods
    $authMethods = Get-MgUserAuthenticationPhoneMethod -UserId $user

    switch ($ActionType) {

        "Add" {
            try {
                New-MgUserAuthenticationPhoneMethod -UserId $user -PhoneNumber $PhoneNumber -PhoneType $PhoneType
                Write-Host "Added phone number for $UPN`n"
                $srxEnv.ResultMessage += "Added phone number for $UPN`n"
            }
            catch {
                Write-Host "Failed to add phone number for $UPN`n$_`n"
                $srxEnv.ResultMessage += "Failed to add phone number for $UPN`n$_`n"
            }
        }

        "Update" {
            $existingMethod = $authMethods | Where-Object { $_.PhoneType -eq $PhoneType }
            if ($existingMethod) {
                try {
                    Update-MgUserAuthenticationPhoneMethod -UserId $user -PhoneAuthenticationMethodId $existingMethod.Id -PhoneNumber $PhoneNumber
                    $srxEnv.ResultMessage += "Updated phone number for $UPN`n"
                }
                catch {
                    write-host "Failed to update phone number for $UPN`n$_`n"
                    $srxEnv.ResultMessage += "Failed to update phone number for $UPN`n$_`n"
                }
            } else {
                Write-Host "Phone method not found for the specified type."
                $srxEnv.ResultMessage += "Phone method not found for the specified type."
            }
        }
        
        "Delete" {
            $existingMethod = $authMethods | Where-Object { $_.PhoneType -eq $PhoneType }
            if ($existingMethod) {
                try {
                    Remove-MgUserAuthenticationPhoneMethod -UserId $user -PhoneAuthenticationMethodId $existingMethod.Id
                    write-host "Removed phone number for $UPN`n"
                    $srxEnv.ResultMessage += "Removed phone number for $UPN`n"
                }
                catch {
                    write-host "Failed to delete phone number for $UPN`n$_`n"
                    $srxEnv.ResultMessage += "Failed to delete phone number for $UPN`n$_`n"
                }
            } else {
                Write-Host "Phone method not found for the specified type." 
                $srxEnv.ResultMessage += "Phone method not found for the specified type."
            }
        }
    }
}

try {
    # Retrieve the user object based on UPN
    # $user = Get-MgUser -UserId $UPN
    $user = (Get-MgUser -UserId $UPN).Id
    Write-Host "User Id $user for User $UPN"
    $srxEnv.ResultMessage += "User Id $user for User $UPN. `n"
}
catch {
    Write-Host "Failed to get $UPN, Please enter valid user!"
    $srxEnv.ResultMessage += "Failed to get $UPN, Please enter valif user!`n$_`n"
    Exit
}
switch ($ActionType) {

    "Add" {
        Update-PhoneNumber -user $user -ActionType $ActionType -PhoneType $PhoneType -PhoneNumber $PhoneNumber
    }

    "Update" {
        Update-PhoneNumber -user $user -ActionType $ActionType -PhoneType $PhoneType -PhoneNumber $PhoneNumber
    }
    
    "Delete" {
        Update-PhoneNumber -user $user -ActionType $ActionType -PhoneType $PhoneType
    }
}
