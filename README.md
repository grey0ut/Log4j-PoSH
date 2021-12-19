# Log4j-PoSH
These Powershell scripts/functions represent some quickly thrown together tools to assist in manually mitigating CVE-2021-44228.  These were based on the guidance provided by Apache on their [Security Page](https://logging.apache.org/log4j/2.x/security.html#CVE-2021-44228) for Log4j.  
This repository may change as new information about log4shell comes out, and as my need for tools evolves.  
  
# Get-Log4jJarFiles  
This is a function, requiring use in a Powershell script, or dot sourcing in a Powershell session for use.  Function does a recursive search through a specified directory and returns any log4j .jar files with "core" in the name.  This is in line with Apache's guidance on manually mitigating log4j-2. Objects returned are FileInfo objects for capturing in variables, or piping to other functions/cmdlets.  
  
# Log4j-v1-vulndetector  
This is a script.  I was using it in conjunction with vulnerability scan data that was telling me where v1.x log4j jar files were, but I needed to find nearby configuration files to check for JMSAppender. Provide this script with a directory and it will recursively search for v1.x log4j config files, check them for the presensce of "JMSAppender" and spit out an object with the file path, line number, and matching line where JMSAppender was found.  
  
# Remove-JNDIfromLog4j  
This is a function, requiring use in a Powershell script, or dot sourcing in a Powershell session for use.  Function takes a filepath as input to a log4j .jar file, opens the archive, searches for and removes the JNDILookup.class file and closes the archive.  It creates a backup of the jar file prior to doing this, which can be bypassed by providing the "-NoBackup" parameter when ran.  Function also accepts pipeline input so you could combine Get-Log4jJarFiles and Remove-JNDIfromLog4j to find v2.x log4j**core**.jar files and remove the JNDILookup class file.