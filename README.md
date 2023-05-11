# Chia Plot Mover

This PowerShell script was developed as a solution for moving Chia plots in a Windows-based farming environment. The aim is to automate the process of transferring finished plots from a fast SSD intermediary storage to the final storage drives (HDDs) over network paths.

## Why This Script

While there are similar projects, none fit the specific scenario of handling Chia plotting and farming on Windows machines. The unique advantage of this script is its ability to intelligently choose the target HDD with the largest free space. This way, you can continuously plot and extend your drive pool, while the script takes care of the rest, optimizing space usage.

## How it Works

The script checks the SSD disk for new plots every 10 minutes. If it finds one, it moves those files to a defined list of UNC paths, prioritizing the path with the most available storage. During the transfer, a progress bar is shown, though it currently doesn't display transfer rates.

## Setup

To adapt the script to your environment, you need to adjust the following variables:

```powershell
#Define the directory of the SSD where new Plots are plotted to:
$sourceDir = 'D:\' 
#Define the pool of the destination UNC paths where the plots will be moved to
$destinationDrives = '\\SERVER\SHARE1', '\\SERVER\SHARE2'
```

## Usage

1. Start PowerShell as admin.
2. Make sure you have proper rights to run the script: `Set-ExecutionPolicy Unrestricted`
3. Start the script and let it do its job.

## Recommendations

Test this with a dummy file (like an empty txt file renamed to `anything.plot`) to see if the script catches and moves it. If you don't want to wait 10 minutes for the check, you can adjust the `Start-Sleep -Seconds 600` from 600 seconds to any other value you desire.

## License

This project is licensed under the [GNU GENERAL PUBLIC LICENSE v3.0](LICENSE).
