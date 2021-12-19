<#
.Synopsis
Function to check a v2.x log4j jar file for the presence of the JNDILookup.class file
.Parameter Boolean
A switch parameter that forces the function to only return a boolean response. True = JNDI present, False = JNDI is NOT present
.Notes
Version:        1.0
Author:         C. Bodett
Creation Date:  12/16/2021
Purpose/Change: initial development
#>
Function Test-Log4jJNDI {
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
        [Switch]$Boolean
    )

    Begin {
    $SearchString = 'JNDILookup.class'
    }

    Process {
    Write-Verbose "Checking $($File.Fullname) for presence of JNDI"
    Try {
        $Result = Select-String -Pattern $SearchString -Path $File.Fullname -Quiet
    } Catch {
        $Error[0].Exception
        $ErrorState = $True
    }

    If ($Boolean) {
        Return $Result
    } Else {
        [PSCustomObject]@{
            File = $File.FullName
            JNDIPresent = If ($ErrorState){'???'}Else{$Result}
            ErrorOnCheck = $ErrorState
        }
    }

}
}