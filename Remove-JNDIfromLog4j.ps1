<#
.Synopsis
Function to remove the JNDILookup.class file from a specified log4j '.jar' file. 
.Description
Function creates a backup of the specified .jar file, opens it and searches the contents for the JNDILookup.class. It then removes that class file and closes the jar archive.  Will not succeed if the .jar file is in use by another process.  Accepts pipeline input, and therefore could be combined with Get-Log4jJarFiles.
.Parameter File
Required parameter specifying the full path to the .jar file. 
.Parameter NoBackup
A switch parameter to toffle Off the creation of a backup .jar file. 
.Notes
Version:        1.1
Author:         C. Bodett
Creation Date:  12/15/2021
Purpose/Change: Modified try/catch to handle specific error
#>
Function Remove-JNDIFromLog4j {
    [CmdletBinding()]
    Param(
        [Parameter(Position = 0, ValueFromPipeline = $true, Mandatory=$true)]
        [validatescript({
            if( -not ($_ | test-path)){
                throw "The file does not exist"
                }
            if(-not ($_ | test-path -pathtype Leaf)){
                throw "The -File argument must be a file"
                }
            if(-not ($_.Extension -eq ".jar")){
                throw "The -File value must be a .jar file"
            }
                return $true
        })]
        [system.io.fileinfo]$File,
        [Switch]$NoBackup
    )

# backup the jar file first, just in case
If (-not($NoBackup)) {
    Write-Verbose "Making a backup of $File"
    Try {
        Copy-Item -Path $File.FullName -Destination ('{0}\{1}{2}' -f $File.DirectoryName,($File.BaseName + "-Backup"),$File.Extension) -ErrorAction Stop 
    } Catch {
        $Error[0].Exception
    }
} Else {
    Write-Verbose "Skipping backup of $File"
}

# add the required assembly for dealing with archives
Add-Type -AssemblyName System.IO.Compression.FileSystem

$JNDILookupClass = "org/apache/logging/log4j/core/lookup/JndiLookup.class"

Write-Verbose "Opening $($File.Fullname) archive"
Try {
    $JarArch = [System.IO.Compression.ZipFile]::Open($File,'Update')
} Catch {
    $Error[0].Exception
    continue
}
Write-Verbose "Removing JNDILookup.class from archive"
Try {
    ($JarArch.Entries | Where-Object {$_.FullName -match $JNDILookupClass}).Delete()
} Catch [System.Management.Automation.RuntimeException]{
    Write-Verbose "No JNDILookup class found in $($File.Fullname)"
} Catch {
    $Error[0].Exception
}
Write-Verbose "Closing $($File.Fullname) archive"
$JarArch.Dispose()

}