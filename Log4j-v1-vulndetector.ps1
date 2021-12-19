<#
.Synopsis
A script to detect vunerable log4j configurations that reference the JMSAppender class.  This is specifically for v1.x log4j versions.
.Description
This script retrieves all of the log4j v1.x configuration files and then searches them for references to the "JMSAppender" class which, if in use, renders v1.x log4j vulnerable to log4shell.
.Parameter Directory
The directory where you'd like to run the search. 
.Notes
Version:        1.0
Author:         C. Bodett
Creation Date:  12/15/2021
Purpose/Change: Initial function development
#>

Param (
    [Parameter(Position = 0, Mandatory=$true)]
    [validatescript({
        if( -not ($_ | test-path) ){
            throw "The directory path doesn't exist"
            }
        if(-not ( $_ | test-path -pathtype Container) ){
            throw "The -Directory argument must be a directory"
            }
            return $true
    })]
    [system.io.fileinfo]$Directory
)

$ConfigFiles = Get-ChildItem -Path $Directory -Recurse -ErrorAction SilentlyContinue | Where-Object {$_.name -match 'log4j.properties' -or $_.name -match 'log4j.xml'}
$ConfigFilesCount = $ConfigFiles.count
$ConfigFileMatches = $ConfigFiles | Select-String -Pattern "JMSAppender"

If ($ConfigFileMatches) {
    Write-Host "Vulnerable configuration files found:" -ForegroundColor Yellow
    $ConfigFileMatches | Foreach-Object {
        [PSCustomObject]@{
            FilePath = $_.Path
            LineNum = $_.LineNumber
            MatchingLine = $_.Line
        }
    }
} Else {
    Write-Host "No vulnerable configuration files found out of $ConfigFilesCount inspected" -ForegroundColor Cyan
}