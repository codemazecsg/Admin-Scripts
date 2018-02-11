
param (

    [Parameter(Mandatory=$true)] [string] $directory,
    [Parameter(Mandatory=$true)] [string] $baseFileName,
    [Parameter(Mandatory=$true)] [string] $extension,
    [Parameter(Mandatory=$true)] [int] $count,
    [Parameter(Mandatory=$true)] [int] $startIndex

)

$files = Get-ChildItem -File $directory

for ($i = $startIndex; $i -lt $count; $i++)
{
    Rename-Item $files[$i].FullName -NewName $baseFileName$i.$extension
}