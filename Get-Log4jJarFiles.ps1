<#
.Synopsis
Function to search a directory, recursively, and return the paths of any found Log4j*core*.jar files.  These will likely all be version 2.x.
.Description
Function does a recursive search through a specified directory and returns any log4j .jar files with "core" in the name.  This is in line with Apache's guidance on manually mitigating log4j-2. 
.Notes
Version:        1.0
Author:         C. Bodett
Creation Date:  12/15/2021
Purpose/Change: Initial function development
#>
Function Get-Log4jJarFiles {
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

    # this is the filter for our files
    $log4Filter = "log4j*core*.jar"
    
    # start the search
    Write-Verbose "Searching $($Directory.FullName)"
    Write-Verbose "This may take some time..."
    $JarFiles = Get-ChildItem -Path $Directory -File -Recurse -Filter $log4Filter -ErrorAction SilentlyContinue 
    # how many files were found
    Write-Verbose "Found $($JarFiles.count) Jar files"
    # return the found files to standard output
    $JarFiles
}