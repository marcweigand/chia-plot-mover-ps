function Get-DriveFreeSpace($drive){
    $fso = New-Object -ComObject Scripting.FileSystemObject
    $drive = $fso.GetDrive($fso.GetDriveName($drive))
    return $drive.FreeSpace / 1GB
}

$sourceDir = 'D:\'
$destinationDrives = '\\SERVER\SHARE1', '\\SERVER\SHARE2'

while($true){
    $plotFiles = Get-ChildItem -Path $sourceDir -Filter *.plot
    Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Checking for new .plot files."
    foreach($plotFile in $plotFiles){
        $mostSpace = $destinationDrives | Sort-Object {Get-DriveFreeSpace($_)} -Descending | Select-Object -First 1
        if($null -eq $mostSpace){
            Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- No available drives. Will check again later."
            break
        }
        $fileSize = (Get-Item $sourceFile).length / 1GB
        if($fileSize -gt (Get-DriveFreeSpace($mostSpace))){
            Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Not enough free space on drive: $mostSpace. Will check again later."
            break
        }
        Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Most free space on drive: $mostSpace with " (Get-DriveFreeSpace($mostSpace)) "GB free."
        Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Beginning to move $plotFile to $mostSpace"
        $sourceFile = Join-Path -Path $sourceDir -ChildPath $plotFile
        $destinationFile = Join-Path -Path $mostSpace -ChildPath $plotFile
        $transferred = 0
        $progress = @{
            Activity = "Moving $plotFile to $mostSpace"
            Status = "$transferred of $fileSize transferred"
            PercentComplete = 0
        }
        Write-Progress @progress
        Copy-Item -Path $sourceFile -Destination $destinationFile
        if(Test-Path $destinationFile){
            Remove-Item -Path $sourceFile
            $transferred = $fileSize
            $progress.Status = "$transferred of $fileSize transferred"
            $progress.PercentComplete = 100
            Write-Progress @progress
            Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Finished moving $plotFile to $mostSpace"
            Write-Progress -Activity $progress.Activity -Completed
        }
        else{
            Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Failed to move $plotFile to $mostSpace"
        }
    }
    Start-Sleep -Seconds 600
}
