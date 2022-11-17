function Export-GroupMembersFromUser {
<#
.SYNOPSIS
    Creates a CSV file for each group of an Azure AD to which the user KnownObjectId belongs.
	These CSVs contain the essential information to contact the members of the group

.PARAMETER Connect
    Allows a connection to the TenantId instance

.PARAMETER TenantId
    Tenant to be connected to

.EXAMPLE
     Export-GroupMembersFromUser -knownObjectId 'email@example.onmicrosoft.com'

.EXAMPLE
     Export-GroupMembersFromUser -Connect $true -TenantId 'example.com' -knownObjectId 'email@example.onmicrosoft.com'

#>
	[CmdletBinding()]
	param(
		[bool] $Connect = $false,
		[string] $TenantId,
		[Parameter(Mandatory)]
		[string] $KnownObjectId
	)

	PROCESS {
		if ( $Connect ) {
			Connect-AzureAD -TenantId $TenantId
		}
		
		$Groups = Get-AzureADUserMembership -ObjectId $KnownObjectId

		ForEach ($Group in $Groups) {
			$output_filename = "$($Group.DisplayName)_members.csv" -replace '[\\/]','-'
			$Users = Get-AzureADGroupMember -All $True -ObjectId $Group.ObjectId | Where-Object {$_.ObjectType -eq "User"}  | Select-Object DisplayName, JobTitle, Mail, OtherMails, Mobile, TelephoneNumber 
			
			$Users | ForEach-Object { $_.OtherMails = $_.OtherMails -join ';' ; $_ } | Export-CSV -NoTypeInformation $output_filename
		}
	}
}
