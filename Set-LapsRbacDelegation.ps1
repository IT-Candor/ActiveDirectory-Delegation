#Requires -Version 7.0

<#
.Synopsis
Script requires a JSON source file for LAPS Active Directory delegation of allow management of LAPS passwords
.Description
A JSON file is used as a golden source to delegation LAPS permissions on OUs for Computer objects
.Parameter JsonPath
This is a Mandatory parameter to the full path of the JSON delegation input file.
.Example
Set-RbacDelegation -JsonFile C:\Files\LapsDelegation.json
Delegation of LAPSPermissions to the OUs based on the JSON file as input
.Inputs
Requires a JSON file with specific objects for the script to execute properly
.Outputs
Organizational Units will have the LAPS permissions delegated
#>

Param(

    [Parameter(Mandatory = $true)]
    [string]$JsonPath

) #end param


#Import Models
Import-Module AdmPwd.PS -ErrorAction Stop

#Get the Content of the delegation JSON source file from the required parameter
$Json = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json

#Loop through each of the OUs to delegate LAPS permissions
foreach ($LapsOU in $Json.LapsOrganizationUnits) {

            #Convert JSON entires to strings
            $OU = $LapsOU.OuDn
            #Convert JSON entires to strings
            $SamAccountName = $LapsOu.SamAccountName

            #Sets the read LAPS permission on the Computer Objects
            Set-AdmPwdReadPasswordPermission -Identity $OU -AllowedPrincipals $SamAccountName | Out-Null
            #Sets the expire LAPS permission on the Computer Objects
            Set-AdmPwdResetPasswordPermission -Identity $OU -AllowedPrincipals $SamAccountName | Out-Null

}