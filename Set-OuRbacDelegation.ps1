#Requires -Version 7.0

<#
.Synopsis
Script requires a JSON source file for custom RBAC Active Directory OU delegation of Allow attribute changes
.Description
A JSON file is used as a golden source to delegation permissions on the OUs for Users, Groups, and Computer objects
.Parameter JsonPath
This is a Mandatory parameter to the full path of the JSON delegation input file.
.Parameter SkipRemoval
This is an optional parameter that should only be used when delegatin permissions for the first time as there have been no group delegations to remove.
.Example
Set-RbacDelegation -JsonFile C:\Files\Delegation.json
Delegation of ACLs to the OUs based on the JSON file as input
.Example
Set-RbacDelegation -JsonFile C:\Files\Delegation.json -SkipRemoval
Used only during the first delegation execution to skip the removal of groups that have not been delegated on the OUs
.Inputs
Requires a JSON file with specific objects for the script to execute properly
.Outputs
Organizational Units will have the correct ACL's applied to manage Users, Groups, and Computer objects
#>

Param(

    [Parameter(Mandatory = $true)]
    [string]$JsonPath,
    [Parameter(Mandatory = $false)]
    [Switch]$SkipRemoval

) #end param


#Import Models
Import-Module ActiveDirectory -ErrorAction Stop

#Get the Content of the delegation JSON source file from the required parameter
$Json = Get-Content -Raw -Path $JsonPath | ConvertFrom-Json

#Loop through each OU within the JSON file
foreach ($OU in $Json.OrganizationUnits) {

    #Creates a PSDrive AD path with the OU DN
    $OuAdDrivePath = "AD:\" + $OU.OuDN

    #Convert JSON entires to strings
    $SamAccountName = $OU.SamAccountName

    #If delegation object type is a USER create a securityid object of the SID, required for Access Rule object
    if ($Ou.SamAccountType -eq "user") {
    $SamAccountSid = New-Object System.Security.Principal.SecurityIdentifier (Get-ADUser -Identity $SamAccountName).SID
    }

    #If delegation object type is a GROUP create a securityid object of the SID, required for Access Rule object
    if ($Ou.SamAccountType -eq "group") {
    $SamAccountSid = New-Object System.Security.Principal.SecurityIdentifier (Get-ADGroup -Identity $SamAccountName).SID
    }

    # If skipremoval parameter is used it will only getting the current ACLs
    if ($SkipRemoval) {
        
        #Get the current ACL's delegated to the OU
        $OuAcl = Get-Acl -Path $OuAdDrivePath

    } else {

        #Gets the current ACLs delegated to the OU
        $RemoveAcl = Get-Acl -Path $OuAdDrivePath
    
        #Creates an object to remove the current object (User or Group) from the OU delegation
        $RemoveAcl.PurgeAccessRules($SamAccountSid)
   
        #Using the ACL Object to remove the current object (User or Group) delegated
        Set-ACL -Path $OuAdDrivePath -AclObject $RemoveAcl

        #Get the current ACL's delegated to the OU
        $OuAcl = Get-Acl -Path $OuAdDrivePath

    }


    #Convert JSON entires to strings, required for Access Rule object to be created
    $ActiveDirectoryRights = $OU.ActiveDirectoryRights
    #Convert JSON entires to strings, required for Access Rule object to be created
    $AccessControlType = $OU.AccessControlType
    #Convert JSON entires to strings, required for Access Rule object to be created
    $ActiveDirectorySecurityInheritance = $OU.ActiveDirectorySecurityInheritance
    #Convert JSON entires to strings, required for Access Rule object to be created
    $ActiveDirectorySecurityInheritanceObjectTypeGuid = $OU.ActiveDirectorySecurityInheritanceObjectTypeGuid

    #For each object property to delegate, loop through each to create a Access Rule object
    foreach ($Delegation in $OU.AccessControlTypeDelegations) {

        #Convert JSON entires to strings, required for Access Rule object to be created
        $AccessControlTypeDelegations = $Delegation.value

        #Create an Access rule using the System.DirectoryServices Class based on input from JSON file
        $AccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
                                $SamAccountSid,
                                [System.DirectoryServices.ActiveDirectoryRights]::$ActiveDirectoryRights,
                                [System.Security.AccessControl.AccessControlType]::$AccessControlType,$AccessControlTypeDelegations,
                                [DirectoryServices.ActiveDirectorySecurityInheritance]::$ActiveDirectorySecurityInheritance,$ActiveDirectorySecurityInheritanceObjectTypeGuid
                )
        
        #Combines each Access rule into a Active Directory Access Rule Object
        $OuAcl.AddAccessRule($AccessRule)

    }

    #Adds the new ACLs to the OU using the Active Directory Access Rule Object
    Set-ACL -Path $OuAdDrivePath -AclObject $OuAcl

}