function Download-From-Github {
    [cmdletbinding(SupportsShouldProcess)]
    Param(
        [Parameter(Mandatory = $true, Position = 0)][string]$Author,
        [Parameter(Mandatory = $true, Position = 1)][string]$RepoName,
        [Parameter(Mandatory = $true, Position = 2)][string]$PackageToDownload
    )

    $uri = "https://api.github.com/repos/${Author}/${RepoName}/releases"
    $Request = Invoke-RestMethod -uri $uri
    $Data = $Request[0].assets | Where-Object name -Match $PackageToDownload
    $DownloadUrl = $Data.browser_download_url
    $File = Join-Path -path $env:temp -ChildPath $Data.name
    Invoke-WebRequest -Uri $DownloadUrl -UseBasicParsing -DisableKeepAlive -OutFile $File
    return $File
}