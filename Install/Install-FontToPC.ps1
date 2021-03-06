#House keeping
$scriptpath = $MyInvocation.MyCommand.Path
$wDir = Split-Path $scriptpath

#Change this to be specific for your deployment
$FontDir = "$wDir\Fonts"
 
foreach($FontFile in (Get-ChildItem -file -path $FontDir)) {
        $filePath="$FontDir\$FontFile"
        $fontRegistryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts"
        $fontsFolderPath = "$($env:windir)\fonts"
        # Create hashtable containing valid font file extensions and text to append to Registry entry name.
        $hashFontFileTypes = @{}
        $hashFontFileTypes.Add(".fon", "")
        $hashFontFileTypes.Add(".fnt", "")
        $hashFontFileTypes.Add(".ttf", " (TrueType)")
        $hashFontFileTypes.Add(".ttc", " (TrueType)")
        $hashFontFileTypes.Add(".otf", " (OpenType)")

        try {
            [string]$filePath = (Get-Item $filePath).FullName
            [string]$fileDir  = split-path $filePath
            [string]$fileName = split-path $filePath -leaf
            [string]$fileExt = (Get-Item $filePath).extension
            [string]$fileBaseName = $fileName -replace($fileExt ,"")

            $shell = new-object -com shell.application
            $myFolder = $shell.Namespace($fileDir)
            $fileobj = $myFolder.Items().Item($fileName)
            $fontName = $myFolder.GetDetailsOf($fileobj,21)
            
            if ($fontName -eq "") { $fontName = $fileBaseName }

            copy-item $filePath -destination $fontsFolderPath

            $fontFinalPath = Join-Path $fontsFolderPath $fileName
            if (-not($hashFontFileTypes.ContainsKey($fileExt))){Write-Host "File Extension Unsupported";$retVal = 0}
            if ($retVal -eq 0) {
                Write-Host "Font `'$($filePath)`' installation failed on $env:computername" -ForegroundColor Red
                Write-Host ""
                1
            }
            
            else
            {
                Set-ItemProperty -path "$($fontRegistryPath)" -name "$($fontName)$($hashFontFileTypes.$fileExt)" -value "$($fileName)" -type STRING
                Write-Host "Font `'$($filePath)`' $fontName $($hashFontFileTypes.$fileExt) installed successfully on $env:computername" -ForegroundColor Green
            }

        }
    catch
    {
        Write-Host "An error occured installing `'$($filePath)`' on $env:computername" -ForegroundColor Red
        Write-Host "$($error[0].ToString())" -ForegroundColor Red
        $error.clear()
    }
}