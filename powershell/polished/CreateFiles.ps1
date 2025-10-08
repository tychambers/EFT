<#
.SYNOPSIS
    Creates a specified number of files of a given size in a target directory.

.DESCRIPTION
    This script generates test files for performance or load testing.
    It automatically creates the target directory if it doesn't exist.

.PARAMETER FolderPath
    The directory where the files will be created.
    Defaults to 'C:\Temp'.

.PARAMETER FileCount
    The number of files to create.
    Defaults to 100.

.PARAMETER FileSizeKB
    The size of each file in kilobytes.
    Defaults to 5 KB.

.EXAMPLE
    .\CreateFiles.ps1

    Creates 100 files of 5KB each in C:\Temp\TestFiles.

.EXAMPLE
    .\CreateFiles.ps1 -FolderPath "D:\Output" -FileCount 500 -FileSizeKB 10

    Creates 500 files of 10KB each in D:\Output.

.NOTES
    Author: Tyler Chambers  
    Created: October 2025  
    Version: 1.0
#>

param(
    [string]$DestinationFolder = 'C:\Temp',
    [int]$FileSizeKB = 5,
    [int]$FileCount = 100
)

foreach ($i in 1..$FileCount) {

$fileSize = $FileSizeKB * 1024

# creates files of a certain size
fsutil file createnew "$($DestinationFolder)\file$($i).txt" $fileSize

}