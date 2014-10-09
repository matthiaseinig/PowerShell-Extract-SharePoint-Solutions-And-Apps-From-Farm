### 
### Exports all SharePoint farm solutions, sandboxed solutions and apps to the file system
### Author: Matthias Einig, http://www.twitter.com/mattein
### Url: http: www.spcaf.com
###
Add-PSSnapin Microsoft.SharePoint.PowerShell
Write-Host "Exporting SharePoint Customizations"

# Preparation: (re)create folder named after the current date to collect all customizations
$foldername = (Get-Date -Format "yyyyMMdd").ToString()
rmdir  $foldername -Recurse -ErrorAction SilentlyContinue
$basePath = (mkdir $foldername).FullName

# Collect all disposable objects
Start-SPAssignment -Global

try {
    # Step 1: Save all farm solutions
    $ftcPath = (mkdir ($basePath +"\FullTrust")).FullName
    Write-Host "  Saving farm solutions to $ftcPath"

    (Get-SPFarm).Solutions | % {
        Write-Host "    $($_.Name)..." -NoNewline
        try{
            $_.SolutionFile.SaveAs($ftcPath + "\" + $_.Name)
           Write-Host -ForegroundColor Green "Done"
        }
        catch{
            Write-Host -ForegroundColor Red "Failed"
            Write-Error $_.Exception.Message; 
        }
    }

    # Step 2: Save all sandboxed solutions
    $sbsPath = (mkdir($basePath +"\Sandboxed")).FullName
    Write-Host "  Saving sandboxed solutions to $sbsPath"

    # Get all accessible SharePoint sites in the farm 
    # Warning: this might take a while, so consider to limit it to specific sites
    # Also it might retrieve duplicate solutions (in different versions) form different sites
    Get-SPSite -limit All -WarningAction SilentlyContinue | % {
        Write-Host "    $($_.Url)..." -NoNewline
        try{
            $listTemplate = [Microsoft.SharePoint.SPListTemplateType]::SolutionCatalog
            $solGallery = $_.GetCatalog($listTemplate)

            if($solGallery.ItemCount -gt 0)
            {
                Write-Host -ForegroundColor Green $solGallery.ItemCount

                # create subfolder for site with safe folder name removing the protocol and special chars
                $subfolder = [RegEx]::Replace($_.Url.Substring($_.url.IndexOf(":")+3), "[{0}]" -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), '')
                $sitePath = (mkdir ($sbsPath +"\"+ $subfolder)).FullName

                # save all sandboxed solutions of this site
                $solGallery.Items | % {
                    Write-Host "        $($_.File.Name)..." -NoNewline
                    try{

                        [System.IO.FileStream]$outStream = New-Object System.IO.FileStream(($sitePath+"\"+$_.File.Name), [System.IO.FileMode]::Create);
                        $fileData = $_.File.OpenBinary();
                        $outStream.Write($fileData, 0, $fileData.Length);
                        $outStream.Close();
                        Write-Host -ForegroundColor Green "Done"
                    }
                    catch{
                        Write-Host -ForegroundColor Red "Failed"
                        Write-Error $_.Exception.Message; 
                    }
                }
            }
            else{
               Write-Host "None" 
            }
        }
        catch{
            Write-Host -ForegroundColor Red "Failed"
            Write-Error $_.Exception.Message; 
        }
    }


    # Step 3: Save all SharePoint Apps
    $appPath = (mkdir($basePath +"\Apps")).FullName
    Write-Host "  Saving Apps to $appPath"

    # Get all accessible SharePoint webs in the farm 
    # Warning: this might take a while, so consider to limit it to specific sites
    # Also it might retrieve duplicate solutions (in different versions) form different sites
    Get-SPSite -Limit All -WarningAction SilentlyContinue | Get-SPWeb -Limit All -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | % {
        Write-Host "    $($_.Url)..." -NoNewline
        try{
            $instances = Get-SPAppInstance -Web $_.Url

            if($instances.Count -gt 0)
            {
                Write-Host -ForegroundColor Green $instances.Count

                # create subfolder for web with safe folder name removing the protocol and special chars
                $subfolder = [RegEx]::Replace($_.Url.Substring($_.url.IndexOf(":")+3), "[{0}]" -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), '')
                $webPath = (mkdir ($appPath +"\"+ $subfolder)).FullName

                # export all apps
                foreach ($instance in $instances) {
                    # create safe file name
                    $filename = [RegEx]::Replace($instance.Title, "[{0}]" -f ([RegEx]::Escape([String][System.IO.Path]::GetInvalidFileNameChars())), '')+".app"
                    Write-Host "        $filename..." -NoNewline
                     try{
                        Export-SPAppPackage -App $instance.App -Path ($webPath + "\"+ $filename)
                        Write-Host -ForegroundColor Green "Done"
                    }
                    catch{
                        Write-Host -ForegroundColor Red "Failed"
                        Write-Error $_.Exception.Message; 
                    }
             
                 }
            }
            else{
               Write-Host "None" 
            }
        }
        catch{
            Write-Host -ForegroundColor Red "Failed"
            Write-Error $_.Exception.Message; 
        }
    }
}
finally{
    #Cleanup disposable objects
    Stop-SPAssignment -Global
    Write-Host "Finished"
}
