function Get-ODfBSyncLibrary {
<#
.SYNOPSIS

Returns all synchronized libraries in OneDrive for Business under current logged-in user

.PARAMETER Detailed

Returns detailed information about each synchronized library

.OUTPUTS

TypeName: Selected.System.Management.Automation.PSCustomObject. Get-ODfBSyncLibrary returns a PSCustomObject

.EXAMPLE


Get-ODfBSyncLibrary
.EXAMPLE

Get-ODfBSyncLibrary -Detailed

.LINK

https://github.com/freddiecode/Get-ODfBSyncLibrary

.AUTHOR

Freddie Christiansen | www.cloudpilot.no
#>
        [cmdletbinding()]

        param(

        [Parameter(Mandatory=$false)]
        [switch]
        $Detailed

        )
  
  try {


    $ODfBSync = Get-ChildItem -Path Registry::HKEY_CURRENT_USER\SOFTWARE\SyncEngines\Providers\OneDrive
    $Items = $ODfBSync | Where-Object {$_.Name -notmatch "Personal"} | ForEach-Object { Get-ItemProperty $_.PsPath }  

    $AllODfBLibs = [System.Collections.ArrayList]@()

    ForEach ($Item in $Items) {

    $Obj = New-Object PSCustomObject

    $ODfBLib = [ordered]@{

            Url              = $Item.UrlNamespace
            MountPoint       = $Item.MountPoint
            LibraryType       = $Item.LibraryType
            LastModifiedTime = $(if ($Item.LastModifiedTime -as [DateTime]) { [datetime]::Parse($Item.LastModifiedTime) } else { $_ })

            }

            
            $Obj | Add-Member -MemberType NoteProperty -Name Url -Value $ODfBLib.Url
            $Obj | Add-Member -MemberType NoteProperty -Name MountPoint -Value $ODfBLib.MountPoint
            $Obj | Add-Member -MemberType NoteProperty -Name LibraryType -Value (Get-Culture).TextInfo.ToTitleCase($ODfBLib.LibraryType)
            $Obj | Add-Member -MemberType NoteProperty -Name LastModifiedTime -Value $ODfBLib.LastModifiedTime

                        
            $AllODfBLibs += $Obj
               
        }
    }

    catch {

    Write-Host $_

    } 

if(!$Detailed) { return $AllODfBLibs | Select-Object Url} else { return $AllODfBLibs | Sort-Object LibraryType }


}
