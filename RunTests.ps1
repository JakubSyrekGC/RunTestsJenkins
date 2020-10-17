param(
    [string] $sourceDirectory      = "C:\__Jenkins\ServiceLauncher\GIOŚ_Client.Tests1\bin\Debug\",
    $fileFiltersTests              = @("*.*Tests*.dll"),
    $pathXmlOutput                 = @("C:/__Jenkins")
)

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{   
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process powershell -Verb runAs -ArgumentList $arguments
    Break
}


$newline = [Environment]::NewLine
Write-Output $newline.TrimEnd() "Source          : $sourceDirectory"
Write-Output $newline.TrimEnd() "File Filters    : $fileFiltersTests"

$cFiles = ""
[string]$nUnitExecutable = "C:\Program Files (x86)\NUnit.org\nunit-console\nunit3-console.exe"
[string]$path = "C:\Program Files (x86)\NUnit.org\nunit-console"

[array]$filesTests = get-childitem $sourceDirectory -include $fileFiltersTests -recurse | select -expand FullName 

foreach ($file in $filesTests)
{
    $cFiles = $cFiles + '"' + $file + '"' + " "
}

$date = $([DateTime]::Now.ToString("yyyyMMdd-HHmmss"))

$argumentList = @("$cFiles".Trim(), "--result=$pathXmlOutput/TestResult_$date.xml")

Set-Location $path

$result = (.\nunit3-console.exe  $argumentList) | Out-String

[xml]$xml = Get-Content "$pathXmlOutput/TestResult_$date.xml"

$display = New-Object PSObject -Property @{
                                             OverallResult = $xml.DocumentElement.result
                                             Passed        = $xml.DocumentElement.passed
                                             Failed        = $xml.DocumentElement.failed
                                             TestsCount    = $xml.DocumentElement.testcasecount
                                             ClrVersion    = $xml.DocumentElement.'clr-version'
                                          }
                                          
Write-Output $display | Format-Table -AutoSize

exit $xml.DocumentElement.failed