. ./variables.ps1

# Find Source Directories
Write-Output "Finding Source Directories to copy Include Files..."
Push-Location $CppSourcePath
$sourceDirectories = (Get-ChildItem -Path . -Directory -Recurse | Where { $_.FullName -NotMatch $ExcludedFolders }).FullName | Resolve-Path -Relative
if (!$sourceDirectories) {
    Write-Output "Error : No Source Directories found!"
    Pop-Location
    exit 1
}
Write-Output "Source Directories Found : "
Write-Output "$sourceDirectories`n"
Pop-Location

# Remove Include output directory
if (Test-Path $IncludeDir) {
    Write-Output "Removing existing Output Include directory..."
    Remove-Item $IncludeDir -Force -Recurse
}

# Make the Include output directory
Write-Output "Creating output Include directory..."
New-Item -ItemType directory -Force -Path $IncludeDir
$includeFileDest = Resolve-Path $IncludeDir

# Copy Headers to Include Directory
Write-Output "Copying Include Files to $includeFileDest ..."
foreach ($sourceDir in $sourceDirectories) {
    Push-Location $CppSourcePath/$sourceDir
    $includeFiles = (Get-ChildItem -Path $IncludeFilePattern -Exclude $ExcludedFiles).FullName
    
    foreach ($includeFile in $includeFiles) {
        $fileName = Resolve-Path -Relative -Path "$includeFile"
        $fileDestination = "$includeFileDest/$sourceDir/$fileName"
        New-Item -Force $fileDestination
        Copy-Item -Force $includeFile -Destination $fileDestination
    }
    Pop-Location
}
Write-Output "Successfully copied Protobuf Include Files to $includeFileDest !"
