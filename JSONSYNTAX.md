# Overview
The documents the properties of the OuRbacDelegation.json file and the expected input values or format and where these can be found. Where possible Microsoft support links have been provided.

## Organization Units (OU)
The Active Directory OU where the ACL's will be delegated. This is the parent directory JSON where the script will loop through each OU.

| Json Property | Example | Description |
|:--------------|:-----:|:--------------------|
| OuDN  |  "OU=UsersAccounts,DC=lab,DC=com" | Can be found in the attributes of an OU in AD |
| SamAccountName  | TestUser  | Sam Account of the user or group object that will be delegated permissions on the OU | 
| SamAccountType | Group or User | Used within the script to get the object SID within Active Directory |
| SamAccountSid | Group or User | SID of the User or Group that will be delegated permission |
| ActiveDirectoryRights | WriteProperty, Delete, Read, ExtendedRight, etc.  | Review the Microsoft documentation for a list of all possible values, link below |
| AccessControlType | Allow or Deny | Allowing or Denying permission to objects|
| AccessControlTypeDelegations | Key Pairs | The property and Schema GUID value of that property to be delegated, Excel sheet has a collect of common values, link below |
| AccessControlTypeDelegations - name | mobile, name, member, phone, etc. | Name of the property to delegate, only used to make it legiable within the JSON file for a human to read without having to look up the GUID in the Excel sheet or AD |
| AccessControlTypeDelegations - value | Schema GUID | GUID of the property to delegate |
| ActiveDirectorySecurityInheritance | Children, Descendents, None, SelfAndChildren | Where to apply within the OU - link below  |
| ActiveDirectorySecurityInheritanceObjectType | Computer, Group, or User | Type of object to delegate, only used to make it legiable within the JSON file for a human to read without having to look up the GUID in the Excel sheet or AD |
| ctiveDirectorySecurityInheritanceObjectTypeGuid | Schema GUID of Computer, Group, or User | GUID of the object type to delegate permission to control |

### ActiveDirectoryRights

List of possbiel AD Rights

 https://learn.microsoft.com/en-us/dotnet/api/system.directoryservices.activedirectoryrights?view=windowsdesktop-8.0 
 
 ### AccessControlType 
 
 List of Possible AD Access Control Types
 
 https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.accesscontroltype?view=net-7.0 
 
 ### AccessControlTypeDelegations
 
 Exported from an Active Directory where Exchange Schema has been preformed. There many be additional schema properties with in an Active Directory if the admins have extended the additonal schemas. The Excel sheet should contain most of the Basic and Extended GUIDs
 
 https://github.com/IT-Candor/ActiveDirectory-Delegation/blob/main/SchemaMapGuidList.xlsx
 
 ### ActiveDirectorySecurityInheritance
 
 List of Possible AD Access Control Types, the script is not designed to support the "All" value. All should not be used as it violated least privildge access framework.
 
 https://learn.microsoft.com/en-us/dotnet/api/system.directoryservices.activedirectorysecurityinheritance?view=windowsdesktop-8.0|
