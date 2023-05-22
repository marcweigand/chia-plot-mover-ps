function Get-DriveFreeSpace($drive){
    $fso = New-Object -ComObject Scripting.FileSystemObject
    $drive = $fso.GetDrive($fso.GetDriveName($drive))
    return $drive.FreeSpace / 1GB
}

function Test-PathAvailability($path){
    return Test-Path -Path $path
}

function IsEnoughSpace($path, $size){
    return (Get-DriveFreeSpace($path) -gt $size)
}

$sourceDir = 'D:\'
$destinationDrives = '\\SERVER\SHARE1', '\\SERVER\SHARE2'

while($true){
    $plotFiles = Get-ChildItem -Path $sourceDir -Filter *.plot
    Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Checking for new .plot files."
    foreach($plotFile in $plotFiles){
        $mostSpace = $destinationDrives | Sort-Object {Get-DriveFreeSpace($_)} -Descending | Select-Object -First 1
        Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Most free space on drive: $mostSpace with " (Get-DriveFreeSpace($mostSpace)) "GB free."
        $fileSize = $plotFile.Length / 1GB
        if(Test-PathAvailability($mostSpace) -and IsEnoughSpace($mostSpace, $fileSize)){
            Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Beginning to move $plotFile to $mostSpace"
            $destinationFile = Join-Path -Path $mostSpace -ChildPath $plotFile.Name
            $transferred = 0
            $progress = @{
                Activity = "Moving $plotFile to $mostSpace"
                Status = "$transferred of $fileSize transferred"
                PercentComplete = 0
            }
            Write-Progress @progress
            try{
                Copy-Item -Path $plotFile.FullName -Destination $destinationFile -ErrorAction Stop
                Remove-Item -Path $plotFile.FullName
                $transferred = $fileSize
                $progress.Status = "$transferred of $fileSize transferred"
                $progress.PercentComplete = 100
                Write-Progress @progress
                Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Finished moving $plotFile to $mostSpace"
                Write-Progress -Activity $progress.Activity -Completed
            }
            catch{
                Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Failed to move $plotFile to $mostSpace due to error: $_"
                Start-Sleep -Seconds 600
            }
        }else{
            Write-Host (Get-Date -Format "yyyy-MM-dd HH:mm:ss") "- Cannot move $plotFile to $mostSpace due to insufficient space or path unavailability"
            Start-Sleep -Seconds 600
        }
    }
    Start-Sleep -Seconds 600
}
